-- ============================================================================
-- MIGRATION: COMPLETE Fix for Infinite Recursion in Profiles RLS Policies
-- Version: 20260113100000
--
-- PROBLEM: "infinite recursion detected in policy for relation 'profiles'"
-- This error occurs in:
--   - ChatException: Failed to fetch conversations
--   - AdminException: Failed to fetch school users
--   - Messages and Manage pages
--
-- ROOT CAUSE ANALYSIS:
-- 1. RLS policies on profiles table call functions that query profiles table
-- 2. Even SECURITY DEFINER functions can cause recursion if not properly configured
-- 3. Multiple overlapping SELECT policies compound the issue
-- 4. Functions like can_message_user() query profiles without proper RLS bypass
--
-- SOLUTION:
-- 1. Drop ALL existing profiles policies
-- 2. Create truly RLS-bypassing helper functions with SECURITY DEFINER + row_security=off
-- 3. Use session-cached variables for user role/school to minimize queries
-- 4. Create simple, non-recursive policies using these safe helpers
-- 5. Ensure no policy WHERE clause directly queries profiles without bypass
-- ============================================================================

-- =============================================================================
-- STEP 0: Create session cache for user info (prevents repeated queries)
-- =============================================================================

-- Session variable initialization function
-- This caches the user's role and school_id in session variables on first access
CREATE OR REPLACE FUNCTION init_user_session_cache()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
  _role user_role;
  _school_id UUID;
  _user_id UUID;
BEGIN
  _user_id := auth.uid();

  -- Only initialize if we have a valid user and haven't already cached
  IF _user_id IS NOT NULL THEN
    BEGIN
      -- Check if already cached this session
      PERFORM current_setting('app.user_role', true);
      -- If we get here without exception, cache exists
      RETURN;
    EXCEPTION WHEN OTHERS THEN
      -- Not cached yet, fetch from DB
      SELECT role, school_id INTO _role, _school_id
      FROM profiles
      WHERE id = _user_id;

      -- Store in session variables
      IF _role IS NOT NULL THEN
        PERFORM set_config('app.user_role', _role::TEXT, false);
        PERFORM set_config('app.user_school_id', COALESCE(_school_id::TEXT, ''), false);
      END IF;
    END;
  END IF;
END;
$$;

-- =============================================================================
-- STEP 1: Create SAFE helper functions that TRULY bypass RLS
-- These use SECURITY DEFINER + SET row_security = off
-- =============================================================================

-- Get current user's role (bypasses RLS completely, uses cache when available)
CREATE OR REPLACE FUNCTION auth_user_role()
RETURNS user_role
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
  _role user_role;
  _cached TEXT;
BEGIN
  -- Try to get from session cache first
  BEGIN
    _cached := current_setting('app.user_role', true);
    IF _cached IS NOT NULL AND _cached != '' THEN
      RETURN _cached::user_role;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    -- Continue to fetch from DB
    NULL;
  END;

  -- Fetch directly from profiles (RLS is off for this function)
  SELECT role INTO _role FROM profiles WHERE id = auth.uid();

  -- Cache for subsequent calls in this session
  IF _role IS NOT NULL THEN
    PERFORM set_config('app.user_role', _role::TEXT, false);
  END IF;

  RETURN _role;
END;
$$;

-- Get current user's school_id (bypasses RLS completely, uses cache when available)
CREATE OR REPLACE FUNCTION auth_user_school_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
  _school_id UUID;
  _cached TEXT;
BEGIN
  -- Try to get from session cache first
  BEGIN
    _cached := current_setting('app.user_school_id', true);
    IF _cached IS NOT NULL AND _cached != '' THEN
      RETURN _cached::UUID;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    -- Continue to fetch from DB
    NULL;
  END;

  -- Fetch directly from profiles (RLS is off for this function)
  SELECT school_id INTO _school_id FROM profiles WHERE id = auth.uid();

  -- Cache for subsequent calls in this session
  IF _school_id IS NOT NULL THEN
    PERFORM set_config('app.user_school_id', _school_id::TEXT, false);
  END IF;

  RETURN _school_id;
END;
$$;

-- Check if current user is superadmin (bypasses RLS)
CREATE OR REPLACE FUNCTION auth_is_superadmin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
BEGIN
  RETURN auth_user_role() = 'superadmin';
END;
$$;

-- Check if current user is a school admin (bigadmin or admin)
CREATE OR REPLACE FUNCTION auth_is_school_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
BEGIN
  RETURN auth_user_role() IN ('bigadmin', 'admin');
END;
$$;

-- =============================================================================
-- STEP 2: Drop ALL existing profiles policies (comprehensive cleanup)
-- =============================================================================

-- Drop all known profile policies from all migrations
DROP POLICY IF EXISTS "superadmin_all_profiles" ON profiles;
DROP POLICY IF EXISTS "bigadmin_all_own_school_profiles" ON profiles;
DROP POLICY IF EXISTS "admin_select_own_school_profiles" ON profiles;
DROP POLICY IF EXISTS "admin_update_own_school_profiles" ON profiles;
DROP POLICY IF EXISTS "teacher_select_profiles" ON profiles;
DROP POLICY IF EXISTS "parent_select_profiles" ON profiles;
DROP POLICY IF EXISTS "student_select_profiles" ON profiles;
DROP POLICY IF EXISTS "users_update_own_profile" ON profiles;
DROP POLICY IF EXISTS "users_read_own_profile" ON profiles;
DROP POLICY IF EXISTS "users_select_messageable_profiles" ON profiles;
DROP POLICY IF EXISTS "superadmin_profiles_all" ON profiles;
DROP POLICY IF EXISTS "bigadmin_profiles_school" ON profiles;
DROP POLICY IF EXISTS "users_view_own_profile" ON profiles;

-- =============================================================================
-- STEP 3: Create simple, non-recursive policies
-- KEY PRINCIPLE: Only use auth.uid() comparisons or SECURITY DEFINER functions
-- NEVER query profiles table directly in policy WHERE clauses
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 3.1 BASIC POLICIES (self-access, no recursion possible)
-- -----------------------------------------------------------------------------

-- Everyone can read their own profile
-- This uses ONLY auth.uid() - no recursion possible
CREATE POLICY "profiles_select_own" ON profiles
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

-- Everyone can update their own profile (limited fields)
CREATE POLICY "profiles_update_own" ON profiles
  FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- -----------------------------------------------------------------------------
-- 3.2 SUPERADMIN POLICIES
-- Uses auth_is_superadmin() which is SECURITY DEFINER with row_security=off
-- -----------------------------------------------------------------------------

CREATE POLICY "profiles_superadmin_all" ON profiles
  FOR ALL
  TO authenticated
  USING (auth_is_superadmin())
  WITH CHECK (auth_is_superadmin());

-- -----------------------------------------------------------------------------
-- 3.3 BIGADMIN POLICIES (full access within own school)
-- -----------------------------------------------------------------------------

CREATE POLICY "profiles_bigadmin_select" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    auth_user_role() = 'bigadmin'
    AND school_id = auth_user_school_id()
  );

CREATE POLICY "profiles_bigadmin_insert" ON profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth_user_role() = 'bigadmin'
    AND school_id = auth_user_school_id()
  );

CREATE POLICY "profiles_bigadmin_update" ON profiles
  FOR UPDATE
  TO authenticated
  USING (
    auth_user_role() = 'bigadmin'
    AND school_id = auth_user_school_id()
  )
  WITH CHECK (
    auth_user_role() = 'bigadmin'
    AND school_id = auth_user_school_id()
  );

CREATE POLICY "profiles_bigadmin_delete" ON profiles
  FOR DELETE
  TO authenticated
  USING (
    auth_user_role() = 'bigadmin'
    AND school_id = auth_user_school_id()
  );

-- -----------------------------------------------------------------------------
-- 3.4 ADMIN POLICIES (read/update within own school)
-- -----------------------------------------------------------------------------

CREATE POLICY "profiles_admin_select" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    auth_user_role() = 'admin'
    AND school_id = auth_user_school_id()
  );

CREATE POLICY "profiles_admin_update" ON profiles
  FOR UPDATE
  TO authenticated
  USING (
    auth_user_role() = 'admin'
    AND school_id = auth_user_school_id()
  )
  WITH CHECK (
    auth_user_role() = 'admin'
    AND school_id = auth_user_school_id()
  );

-- -----------------------------------------------------------------------------
-- 3.5 TEACHER POLICIES
-- Can see: school staff, students in their classes, parents of their students
-- -----------------------------------------------------------------------------

CREATE POLICY "profiles_teacher_select" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    auth_user_role() = 'teacher'
    AND (
      -- School staff (same school, staff roles)
      (school_id = auth_user_school_id() AND role IN ('bigadmin', 'admin', 'teacher'))
      OR
      -- Students in classes they teach (uses subjects table, no profiles recursion)
      (role = 'student' AND EXISTS (
        SELECT 1 FROM class_students cs
        JOIN subjects s ON s.class_id = cs.class_id
        WHERE cs.student_id = profiles.id AND s.teacher_id = auth.uid()
      ))
      OR
      -- Parents of students in classes they teach
      (role = 'parent' AND EXISTS (
        SELECT 1 FROM parent_student ps
        JOIN class_students cs ON ps.student_id = cs.student_id
        JOIN subjects s ON cs.class_id = s.class_id
        WHERE ps.parent_id = profiles.id AND s.teacher_id = auth.uid()
      ))
    )
  );

-- -----------------------------------------------------------------------------
-- 3.6 STUDENT POLICIES
-- Can see: classmates, their teachers, school admins
-- -----------------------------------------------------------------------------

CREATE POLICY "profiles_student_select" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    auth_user_role() = 'student'
    AND (
      -- Classmates (students in same classes)
      (role = 'student' AND EXISTS (
        SELECT 1 FROM class_students cs1
        JOIN class_students cs2 ON cs1.class_id = cs2.class_id
        WHERE cs1.student_id = auth.uid() AND cs2.student_id = profiles.id
      ))
      OR
      -- Teachers who teach their classes
      (role = 'teacher' AND EXISTS (
        SELECT 1 FROM class_students cs
        JOIN subjects s ON cs.class_id = s.class_id
        WHERE cs.student_id = auth.uid() AND s.teacher_id = profiles.id
      ))
      OR
      -- School admins (same school)
      (school_id = auth_user_school_id() AND role IN ('bigadmin', 'admin'))
    )
  );

-- -----------------------------------------------------------------------------
-- 3.7 PARENT POLICIES
-- Can see: their children, children's teachers, school admins
-- -----------------------------------------------------------------------------

CREATE POLICY "profiles_parent_select" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    auth_user_role() = 'parent'
    AND (
      -- Own children
      (role = 'student' AND EXISTS (
        SELECT 1 FROM parent_student
        WHERE parent_id = auth.uid() AND student_id = profiles.id
      ))
      OR
      -- Teachers of their children
      (role = 'teacher' AND EXISTS (
        SELECT 1 FROM parent_student ps
        JOIN class_students cs ON ps.student_id = cs.student_id
        JOIN subjects s ON cs.class_id = s.class_id
        WHERE ps.parent_id = auth.uid() AND s.teacher_id = profiles.id
      ))
      OR
      -- School admins (same school)
      (school_id = auth_user_school_id() AND role IN ('bigadmin', 'admin'))
    )
  );

-- =============================================================================
-- STEP 4: Recreate messaging helper functions with proper RLS bypass
-- =============================================================================

-- Drop existing function first
DROP FUNCTION IF EXISTS can_message_user(UUID);

-- Check if user can message another user (SECURITY DEFINER bypasses RLS)
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
  -- Get current user info (directly, RLS is off)
  SELECT role, school_id INTO current_role, current_school
  FROM profiles WHERE id = auth.uid();

  -- Get target user info (directly, RLS is off)
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

-- Drop and recreate has_conversation_with
DROP FUNCTION IF EXISTS has_conversation_with(UUID);

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

-- =============================================================================
-- STEP 5: Create RPC function for getting messageable users (bypasses RLS)
-- This is the RECOMMENDED way for the app to fetch available message recipients
-- =============================================================================

DROP FUNCTION IF EXISTS get_messageable_users();

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

  -- Get current user info (directly, no RLS)
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

-- =============================================================================
-- STEP 6: Create function to get school users (for admin panel, bypasses RLS)
-- =============================================================================

DROP FUNCTION IF EXISTS get_school_users(UUID);

CREATE OR REPLACE FUNCTION get_school_users(p_school_id UUID DEFAULT NULL)
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
  target_school UUID;
BEGIN
  current_user_id := auth.uid();

  -- Get current user info
  SELECT p.role, p.school_id INTO current_role, current_school
  FROM profiles p WHERE p.id = current_user_id;

  -- Determine which school to query
  IF current_role = 'superadmin' AND p_school_id IS NOT NULL THEN
    target_school := p_school_id;
  ELSE
    target_school := current_school;
  END IF;

  -- Only superadmin, bigadmin, and admin can use this function
  IF current_role NOT IN ('superadmin', 'bigadmin', 'admin') THEN
    RETURN;
  END IF;

  -- Return all users in the target school
  RETURN QUERY
  SELECT
    p.id,
    p.email,
    p.role,
    p.school_id,
    p.first_name,
    p.last_name,
    p.avatar_url,
    p.created_at
  FROM profiles p
  WHERE p.school_id = target_school
  ORDER BY p.role, p.first_name, p.last_name;
END;
$$;

-- =============================================================================
-- STEP 7: Create function to get conversation partners (for chat, bypasses RLS)
-- =============================================================================

DROP FUNCTION IF EXISTS get_conversation_partners();

CREATE OR REPLACE FUNCTION get_conversation_partners()
RETURNS TABLE (
  id UUID,
  email TEXT,
  role user_role,
  school_id UUID,
  first_name TEXT,
  last_name TEXT,
  avatar_url TEXT,
  last_message_at TIMESTAMPTZ,
  unread_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
  current_user_id UUID;
BEGIN
  current_user_id := auth.uid();

  RETURN QUERY
  WITH conversation_partners AS (
    SELECT DISTINCT
      CASE
        WHEN m.sender_id = current_user_id THEN m.recipient_id
        ELSE m.sender_id
      END AS partner_id,
      MAX(m.created_at) AS last_msg_at
    FROM messages m
    WHERE (m.sender_id = current_user_id OR m.recipient_id = current_user_id)
      AND m.message_type = 'direct'
      AND m.recipient_id IS NOT NULL
    GROUP BY
      CASE
        WHEN m.sender_id = current_user_id THEN m.recipient_id
        ELSE m.sender_id
      END
  )
  SELECT
    p.id,
    p.email,
    p.role,
    p.school_id,
    p.first_name,
    p.last_name,
    p.avatar_url,
    cp.last_msg_at AS last_message_at,
    (
      SELECT COUNT(*)
      FROM messages m2
      WHERE m2.sender_id = p.id
        AND m2.recipient_id = current_user_id
        AND m2.is_read = false
    ) AS unread_count
  FROM conversation_partners cp
  JOIN profiles p ON p.id = cp.partner_id
  ORDER BY cp.last_msg_at DESC;
END;
$$;

-- =============================================================================
-- STEP 8: Grant execute permissions on all functions
-- =============================================================================

GRANT EXECUTE ON FUNCTION init_user_session_cache() TO authenticated;
GRANT EXECUTE ON FUNCTION auth_user_role() TO authenticated;
GRANT EXECUTE ON FUNCTION auth_user_school_id() TO authenticated;
GRANT EXECUTE ON FUNCTION auth_is_superadmin() TO authenticated;
GRANT EXECUTE ON FUNCTION auth_is_school_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION can_message_user(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION has_conversation_with(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_messageable_users() TO authenticated;
GRANT EXECUTE ON FUNCTION get_school_users(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_conversation_partners() TO authenticated;

-- =============================================================================
-- STEP 9: Ensure service_role and postgres can bypass RLS
-- =============================================================================

GRANT ALL ON profiles TO service_role;
GRANT ALL ON profiles TO postgres;

-- =============================================================================
-- STEP 10: Verify RLS is enabled (just in case)
-- =============================================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- STEP 11: Reset GENESIS-KEY for testing (if exists)
-- =============================================================================

UPDATE invite_tokens SET is_used = false WHERE token = 'GENESIS-KEY';

-- =============================================================================
-- END OF MIGRATION
-- ============================================================================
