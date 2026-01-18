-- ============================================================================
-- MIGRATION: Fix Profiles RLS for User Search in Messages
-- Version: 20260113000001
--
-- Problem: Users can't search for other users in the Messages tab because
-- the current RLS policies on profiles are too restrictive. The search
-- feature and getAvailableRecipients() need to query profiles but get
-- blocked by RLS.
--
-- Solution:
-- 1. Add a policy that allows users to search profiles within their school
--    for messaging purposes
-- 2. Add a policy that allows reading profiles of users involved in existing
--    conversations
-- 3. Create an RPC function get_messageable_users() that bypasses RLS
-- 4. The policies respect the messaging hierarchy but allow visibility for
--    searching potential recipients
-- ============================================================================

-- =============================================================================
-- Step 0: Ensure helper functions exist (may already exist from previous migrations)
-- =============================================================================

-- Get current user's role (bypasses RLS completely)
CREATE OR REPLACE FUNCTION auth_user_role()
RETURNS user_role
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
  _role user_role;
BEGIN
  SELECT role INTO _role FROM profiles WHERE id = auth.uid();
  RETURN _role;
END;
$$;

-- Get current user's school_id (bypasses RLS completely)
CREATE OR REPLACE FUNCTION auth_user_school_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
  _school_id UUID;
BEGIN
  SELECT school_id INTO _school_id FROM profiles WHERE id = auth.uid();
  RETURN _school_id;
END;
$$;

GRANT EXECUTE ON FUNCTION auth_user_role() TO authenticated;
GRANT EXECUTE ON FUNCTION auth_user_school_id() TO authenticated;

-- =============================================================================
-- Step 1: Create helper function to check if user can message another user
-- This bypasses RLS to prevent recursion
-- =============================================================================

CREATE OR REPLACE FUNCTION can_message_user(target_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
  current_role user_role;
  current_school UUID;
  target_school UUID;
  target_role user_role;
BEGIN
  -- Get current user info
  SELECT role, school_id INTO current_role, current_school
  FROM profiles WHERE id = auth.uid();

  -- Get target user info
  SELECT role, school_id INTO target_role, target_school
  FROM profiles WHERE id = target_user_id;

  -- If target doesn't exist, can't message
  IF target_role IS NULL THEN
    RETURN FALSE;
  END IF;

  -- SuperAdmin can message all BigAdmins
  IF current_role = 'superadmin' AND target_role = 'bigadmin' THEN
    RETURN TRUE;
  END IF;

  -- BigAdmin can message everyone in their school
  IF current_role = 'bigadmin' AND current_school = target_school THEN
    RETURN TRUE;
  END IF;

  -- Admin can message staff and parents in school
  IF current_role = 'admin' AND current_school = target_school
     AND target_role IN ('bigadmin', 'admin', 'teacher', 'parent') THEN
    RETURN TRUE;
  END IF;

  -- Teacher can message other teachers, admins in school
  IF current_role = 'teacher' AND current_school = target_school
     AND target_role IN ('bigadmin', 'admin', 'teacher') THEN
    RETURN TRUE;
  END IF;

  -- Teacher can message parents of their students
  IF current_role = 'teacher' AND target_role = 'parent' THEN
    IF EXISTS (
      SELECT 1 FROM parent_student ps
      JOIN class_students cs ON ps.student_id = cs.student_id
      JOIN subjects s ON cs.class_id = s.class_id
      WHERE ps.parent_id = target_user_id AND s.teacher_id = auth.uid()
    ) THEN
      RETURN TRUE;
    END IF;
  END IF;

  -- Parent can message teachers of their children
  IF current_role = 'parent' AND target_role = 'teacher' THEN
    IF EXISTS (
      SELECT 1 FROM parent_student ps
      JOIN class_students cs ON ps.student_id = cs.student_id
      JOIN subjects s ON cs.class_id = s.class_id
      WHERE ps.parent_id = auth.uid() AND s.teacher_id = target_user_id
    ) THEN
      RETURN TRUE;
    END IF;
  END IF;

  -- Parent can message admins in school
  IF current_role = 'parent' AND current_school = target_school
     AND target_role IN ('bigadmin', 'admin') THEN
    RETURN TRUE;
  END IF;

  -- Student can message their teachers
  IF current_role = 'student' AND target_role = 'teacher' THEN
    IF EXISTS (
      SELECT 1 FROM class_students cs
      JOIN subjects s ON cs.class_id = s.class_id
      WHERE cs.student_id = auth.uid() AND s.teacher_id = target_user_id
    ) THEN
      RETURN TRUE;
    END IF;
  END IF;

  RETURN FALSE;
END;
$$;

GRANT EXECUTE ON FUNCTION can_message_user(UUID) TO authenticated;

-- =============================================================================
-- Step 2: Create function to check if users have an existing conversation
-- =============================================================================

CREATE OR REPLACE FUNCTION has_conversation_with(target_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM messages
    WHERE (sender_id = auth.uid() AND recipient_id = target_user_id)
       OR (sender_id = target_user_id AND recipient_id = auth.uid())
  );
END;
$$;

GRANT EXECUTE ON FUNCTION has_conversation_with(UUID) TO authenticated;

-- =============================================================================
-- Step 3: Add new RLS policy for messaging/search access to profiles
-- This allows users to see profiles of people they CAN message
-- =============================================================================

-- Drop the policy if it exists (for re-running this migration)
DROP POLICY IF EXISTS "users_select_messageable_profiles" ON profiles;

-- Create policy that allows reading profiles for messaging purposes
-- Users can see:
-- 1. Their own profile (already covered by users_read_own_profile)
-- 2. Profiles of users they can message according to role rules
-- 3. Profiles of users they have an existing conversation with
CREATE POLICY "users_select_messageable_profiles" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    -- Can message this user based on role hierarchy
    can_message_user(id)
    OR
    -- Have an existing conversation
    has_conversation_with(id)
  );

-- =============================================================================
-- Step 4: Update teacher policy to also include parents of their students
-- (The existing teacher_select_profiles policy may be missing parents)
-- =============================================================================

-- Drop existing teacher policy if it exists
DROP POLICY IF EXISTS "teacher_select_profiles" ON profiles;

-- Recreate with broader access for messaging
CREATE POLICY "teacher_select_profiles" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    auth_user_role() = 'teacher'
    AND (
      -- Same school staff
      (school_id = auth_user_school_id() AND role IN ('bigadmin', 'admin', 'teacher'))
      OR
      -- Students in classes they teach
      EXISTS (
        SELECT 1 FROM class_students cs
        JOIN subjects s ON s.class_id = cs.class_id
        WHERE cs.student_id = profiles.id AND s.teacher_id = auth.uid()
      )
      OR
      -- Parents of students in classes they teach
      (
        role = 'parent' AND EXISTS (
          SELECT 1 FROM parent_student ps
          JOIN class_students cs ON ps.student_id = cs.student_id
          JOIN subjects s ON cs.class_id = s.class_id
          WHERE ps.parent_id = profiles.id AND s.teacher_id = auth.uid()
        )
      )
    )
  );

-- =============================================================================
-- Step 5: Update parent policy to include teachers and admins
-- =============================================================================

-- Drop existing parent policy if it exists
DROP POLICY IF EXISTS "parent_select_profiles" ON profiles;

-- Recreate with access to teachers and admins
CREATE POLICY "parent_select_profiles" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    auth_user_role() = 'parent'
    AND (
      -- Own children
      EXISTS (
        SELECT 1 FROM parent_student
        WHERE parent_id = auth.uid() AND student_id = profiles.id
      )
      OR
      -- Teachers of their children
      (
        role = 'teacher' AND EXISTS (
          SELECT 1 FROM parent_student ps
          JOIN class_students cs ON ps.student_id = cs.student_id
          JOIN subjects s ON cs.class_id = s.class_id
          WHERE ps.parent_id = auth.uid() AND s.teacher_id = profiles.id
        )
      )
      OR
      -- Admins in same school
      (
        school_id = auth_user_school_id() AND role IN ('bigadmin', 'admin')
      )
    )
  );

-- =============================================================================
-- Step 6: Update student policy to include their teachers
-- =============================================================================

-- Drop existing student policy if it exists
DROP POLICY IF EXISTS "student_select_profiles" ON profiles;

-- Recreate with proper teacher access
CREATE POLICY "student_select_profiles" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    auth_user_role() = 'student'
    AND (
      -- Classmates
      EXISTS (
        SELECT 1 FROM class_students cs1
        JOIN class_students cs2 ON cs1.class_id = cs2.class_id
        WHERE cs1.student_id = auth.uid() AND cs2.student_id = profiles.id
      )
      OR
      -- Teachers who teach their classes
      (
        role = 'teacher' AND EXISTS (
          SELECT 1 FROM class_students cs
          JOIN subjects s ON cs.class_id = s.class_id
          WHERE cs.student_id = auth.uid() AND s.teacher_id = profiles.id
        )
      )
      OR
      -- Admins in same school (for announcements)
      (school_id = auth_user_school_id() AND role IN ('bigadmin', 'admin'))
    )
  );

-- =============================================================================
-- Step 7: Create RPC function to get messageable users (bypasses RLS)
-- This is the most reliable way for Flutter to get available recipients
-- =============================================================================

CREATE OR REPLACE FUNCTION get_messageable_users()
RETURNS TABLE (
  id UUID,
  email TEXT,
  role user_role,
  school_id UUID,
  first_name TEXT,
  last_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
  current_user_id UUID;
  current_role user_role;
  current_school UUID;
BEGIN
  current_user_id := auth.uid();

  -- Get current user info
  SELECT p.role, p.school_id INTO current_role, current_school
  FROM profiles p WHERE p.id = current_user_id;

  -- Return users based on role hierarchy
  RETURN QUERY
  SELECT DISTINCT
    p.id,
    p.email,
    p.role,
    p.school_id,
    p.first_name,
    p.last_name,
    p.avatar_url,
    p.created_at
  FROM profiles p
  WHERE p.id != current_user_id
    AND (
      -- SuperAdmin can message all BigAdmins
      (current_role = 'superadmin' AND p.role = 'bigadmin')

      -- BigAdmin can message everyone in their school
      OR (current_role = 'bigadmin' AND p.school_id = current_school)

      -- Admin can message staff and parents in school
      OR (current_role = 'admin' AND p.school_id = current_school
          AND p.role IN ('bigadmin', 'admin', 'teacher', 'parent'))

      -- Teacher can message staff in school
      OR (current_role = 'teacher' AND p.school_id = current_school
          AND p.role IN ('bigadmin', 'admin', 'teacher'))

      -- Teacher can message parents of their students
      OR (current_role = 'teacher' AND p.role = 'parent' AND EXISTS (
        SELECT 1 FROM parent_student ps
        JOIN class_students cs ON ps.student_id = cs.student_id
        JOIN subjects s ON cs.class_id = s.class_id
        WHERE ps.parent_id = p.id AND s.teacher_id = current_user_id
      ))

      -- Parent can message teachers of their children
      OR (current_role = 'parent' AND p.role = 'teacher' AND EXISTS (
        SELECT 1 FROM parent_student ps
        JOIN class_students cs ON ps.student_id = cs.student_id
        JOIN subjects s ON cs.class_id = s.class_id
        WHERE ps.parent_id = current_user_id AND s.teacher_id = p.id
      ))

      -- Parent can message admins in school
      OR (current_role = 'parent' AND p.school_id = current_school
          AND p.role IN ('bigadmin', 'admin'))

      -- Student can message their teachers
      OR (current_role = 'student' AND p.role = 'teacher' AND EXISTS (
        SELECT 1 FROM class_students cs
        JOIN subjects s ON cs.class_id = s.class_id
        WHERE cs.student_id = current_user_id AND s.teacher_id = p.id
      ))
    )
  ORDER BY p.role, p.first_name, p.last_name;
END;
$$;

GRANT EXECUTE ON FUNCTION get_messageable_users() TO authenticated;

-- =============================================================================
-- END OF MIGRATION
-- =============================================================================
