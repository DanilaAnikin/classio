-- ============================================================================
-- FINAL FIX: Profiles RLS Recursion
-- Version: 20260111260000
--
-- Problem: Even inline subqueries like (SELECT role FROM profiles WHERE id = auth.uid())
-- inside policies trigger RLS evaluation, causing infinite recursion.
--
-- Solution: Create plpgsql functions with SECURITY DEFINER that explicitly
-- bypass RLS using SET row_security = off.
-- ============================================================================

-- =============================================================================
-- Step 1: Create helper functions that TRULY bypass RLS
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

-- Check if current user is superadmin (bypasses RLS)
CREATE OR REPLACE FUNCTION auth_is_superadmin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
BEGIN
  RETURN (SELECT role = 'superadmin' FROM profiles WHERE id = auth.uid());
END;
$$;

-- =============================================================================
-- Step 2: Drop ALL existing profiles policies
-- =============================================================================

DROP POLICY IF EXISTS "superadmin_all_profiles" ON profiles;
DROP POLICY IF EXISTS "bigadmin_all_own_school_profiles" ON profiles;
DROP POLICY IF EXISTS "admin_select_own_school_profiles" ON profiles;
DROP POLICY IF EXISTS "admin_update_own_school_profiles" ON profiles;
DROP POLICY IF EXISTS "teacher_select_profiles" ON profiles;
DROP POLICY IF EXISTS "parent_select_profiles" ON profiles;
DROP POLICY IF EXISTS "student_select_profiles" ON profiles;
DROP POLICY IF EXISTS "users_update_own_profile" ON profiles;
DROP POLICY IF EXISTS "users_read_own_profile" ON profiles;

-- =============================================================================
-- Step 3: Create simple, non-recursive policies using the safe functions
-- =============================================================================

-- Everyone can read their own profile (no function call needed - just auth.uid())
CREATE POLICY "users_read_own_profile" ON profiles
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

-- Everyone can update their own profile
CREATE POLICY "users_update_own_profile" ON profiles
  FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- Superadmin: Full access to all profiles
CREATE POLICY "superadmin_all_profiles" ON profiles
  FOR ALL
  TO authenticated
  USING (auth_is_superadmin())
  WITH CHECK (auth_is_superadmin());

-- Bigadmin: Full access within own school
CREATE POLICY "bigadmin_all_own_school_profiles" ON profiles
  FOR ALL
  TO authenticated
  USING (
    auth_user_role() = 'bigadmin'
    AND school_id = auth_user_school_id()
  )
  WITH CHECK (
    auth_user_role() = 'bigadmin'
    AND school_id = auth_user_school_id()
  );

-- Admin: Read within own school
CREATE POLICY "admin_select_own_school_profiles" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    auth_user_role() = 'admin'
    AND school_id = auth_user_school_id()
  );

-- Admin: Update within own school
CREATE POLICY "admin_update_own_school_profiles" ON profiles
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

-- Teacher: Read students in their classes + school staff
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
    )
  );

-- Student: Read classmates and school teachers
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
      -- Teachers in same school
      (school_id = auth_user_school_id() AND role = 'teacher')
    )
  );

-- Parent: Read own children's profiles
CREATE POLICY "parent_select_profiles" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    auth_user_role() = 'parent'
    AND EXISTS (
      SELECT 1 FROM parent_student
      WHERE parent_id = auth.uid() AND student_id = profiles.id
    )
  );

-- =============================================================================
-- Step 4: Grant execute on new functions
-- =============================================================================
GRANT EXECUTE ON FUNCTION auth_user_role() TO authenticated;
GRANT EXECUTE ON FUNCTION auth_user_school_id() TO authenticated;
GRANT EXECUTE ON FUNCTION auth_is_superadmin() TO authenticated;

-- =============================================================================
-- NOTE: Hardcoded GENESIS-KEY token removed for security.
-- Use SELECT * FROM generate_genesis_token(); for bootstrap (see migration 20260118000001)
-- =============================================================================

-- =============================================================================
-- END OF MIGRATION
-- ============================================================================
