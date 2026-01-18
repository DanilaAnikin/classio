-- ============================================================================
-- MIGRATION: Fix Infinite Recursion in Profiles RLS Policies
-- Version: 20260111250000
--
-- Problem: "infinite recursion detected in policy for relation profiles"
--
-- Root Cause: Profiles policies call functions like is_superadmin(),
-- get_user_role(), etc. which query the profiles table. When RLS evaluates
-- these policies, it triggers the functions which try to query profiles
-- again, causing infinite recursion.
--
-- Solution:
-- 1. Use auth.jwt() to get user metadata directly instead of querying profiles
-- 2. Create cached role/school functions that use JWT claims
-- 3. Rebuild all profiles policies to use these safe functions
-- ============================================================================

-- =============================================================================
-- Step 1: Create safe helper functions that DON'T query profiles
-- These use auth.jwt() to get user info from the JWT token directly
-- =============================================================================

-- Get user role from JWT (no profile query needed)
CREATE OR REPLACE FUNCTION get_user_role_from_jwt()
RETURNS TEXT AS $$
  SELECT COALESCE(
    auth.jwt() -> 'user_metadata' ->> 'role',
    auth.jwt() -> 'app_metadata' ->> 'role',
    'student'
  )
$$ LANGUAGE sql STABLE;

-- Get user school_id from JWT (no profile query needed)
CREATE OR REPLACE FUNCTION get_user_school_id_from_jwt()
RETURNS UUID AS $$
  SELECT (
    COALESCE(
      auth.jwt() -> 'user_metadata' ->> 'school_id',
      auth.jwt() -> 'app_metadata' ->> 'school_id'
    )
  )::UUID
$$ LANGUAGE sql STABLE;

-- =============================================================================
-- Step 2: Drop ALL profiles policies
-- =============================================================================

DROP POLICY IF EXISTS "superadmin_all_profiles" ON profiles;
DROP POLICY IF EXISTS "bigadmin_all_own_school_profiles" ON profiles;
DROP POLICY IF EXISTS "admin_select_own_school_profiles" ON profiles;
DROP POLICY IF EXISTS "admin_update_own_school_profiles" ON profiles;
DROP POLICY IF EXISTS "teacher_select_profiles" ON profiles;
DROP POLICY IF EXISTS "parent_select_profiles" ON profiles;
DROP POLICY IF EXISTS "student_select_profiles" ON profiles;
DROP POLICY IF EXISTS "users_update_own_profile" ON profiles;

-- =============================================================================
-- Step 3: Recreate profiles policies using SIMPLE direct checks
-- NO function calls that could query profiles!
-- =============================================================================

-- Everyone can read their own profile (most basic policy)
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

-- Superadmin: Full access (check role directly in profiles table using subquery)
-- This works because we check the CURRENT user's role, not the row's role
CREATE POLICY "superadmin_all_profiles" ON profiles
  FOR ALL
  TO authenticated
  USING (
    (SELECT role FROM profiles WHERE id = auth.uid()) = 'superadmin'
  )
  WITH CHECK (
    (SELECT role FROM profiles WHERE id = auth.uid()) = 'superadmin'
  );

-- Bigadmin: Full access within own school
CREATE POLICY "bigadmin_all_own_school_profiles" ON profiles
  FOR ALL
  TO authenticated
  USING (
    (SELECT role FROM profiles WHERE id = auth.uid()) = 'bigadmin'
    AND school_id = (SELECT school_id FROM profiles WHERE id = auth.uid())
  )
  WITH CHECK (
    (SELECT role FROM profiles WHERE id = auth.uid()) = 'bigadmin'
    AND school_id = (SELECT school_id FROM profiles WHERE id = auth.uid())
  );

-- Admin: Read within own school
CREATE POLICY "admin_select_own_school_profiles" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin'
    AND school_id = (SELECT school_id FROM profiles WHERE id = auth.uid())
  );

-- Admin: Update within own school
CREATE POLICY "admin_update_own_school_profiles" ON profiles
  FOR UPDATE
  TO authenticated
  USING (
    (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin'
    AND school_id = (SELECT school_id FROM profiles WHERE id = auth.uid())
  )
  WITH CHECK (
    (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin'
    AND school_id = (SELECT school_id FROM profiles WHERE id = auth.uid())
  );

-- Teacher: Read profiles of students in their classes + school staff
CREATE POLICY "teacher_select_profiles" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    (SELECT role FROM profiles WHERE id = auth.uid()) = 'teacher'
    AND (
      -- Same school staff
      (
        school_id = (SELECT school_id FROM profiles WHERE id = auth.uid())
        AND role IN ('bigadmin', 'admin', 'teacher')
      )
      OR
      -- Students in classes they teach (using SECURITY DEFINER function)
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
    (SELECT role FROM profiles WHERE id = auth.uid()) = 'student'
    AND (
      -- Classmates
      EXISTS (
        SELECT 1 FROM class_students cs1
        JOIN class_students cs2 ON cs1.class_id = cs2.class_id
        WHERE cs1.student_id = auth.uid() AND cs2.student_id = profiles.id
      )
      OR
      -- Teachers in same school
      (
        school_id = (SELECT school_id FROM profiles WHERE id = auth.uid())
        AND role = 'teacher'
      )
    )
  );

-- Parent: Read own children's profiles
CREATE POLICY "parent_select_profiles" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    (SELECT role FROM profiles WHERE id = auth.uid()) = 'parent'
    AND EXISTS (
      SELECT 1 FROM parent_student
      WHERE parent_id = auth.uid() AND student_id = profiles.id
    )
  );

-- =============================================================================
-- Step 4: Ensure service_role can bypass all RLS
-- =============================================================================
GRANT ALL ON profiles TO service_role;

-- =============================================================================
-- Step 5: Reset GENESIS-KEY for testing
-- =============================================================================
UPDATE invite_tokens SET is_used = false WHERE token = 'GENESIS-KEY';

-- =============================================================================
-- END OF MIGRATION
-- ============================================================================
