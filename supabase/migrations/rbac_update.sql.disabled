-- ============================================================================
-- RBAC UPDATE MIGRATION
-- ============================================================================
-- This migration adds the 'bigadmin' (Principal) role to the user_role enum
-- and creates comprehensive RLS policies for the new role structure.
-- ============================================================================

-- ============================================================================
-- STEP 1: Add 'bigadmin' to user_role enum
-- ============================================================================
-- The bigadmin role represents a Principal who can manage users and classes
-- within their own school.

ALTER TYPE user_role ADD VALUE 'bigadmin' AFTER 'superadmin';

-- ============================================================================
-- STEP 2: Create helper functions for RBAC checks
-- ============================================================================

-- Function to get the current user's role
CREATE OR REPLACE FUNCTION get_current_user_role()
RETURNS user_role
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$;

-- Function to get the current user's school_id
CREATE OR REPLACE FUNCTION get_current_user_school_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT school_id FROM profiles WHERE id = auth.uid();
$$;

-- Function to check if current user is a superadmin
CREATE OR REPLACE FUNCTION is_superadmin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'superadmin'
  );
$$;

-- Function to check if current user is a bigadmin (Principal)
CREATE OR REPLACE FUNCTION is_bigadmin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'bigadmin'
  );
$$;

-- Function to check if current user is an admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'admin'
  );
$$;

-- Function to check if current user is a teacher
CREATE OR REPLACE FUNCTION is_teacher()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'teacher'
  );
$$;

-- Function to check if user is school staff (bigadmin, admin, or teacher) for a given school
CREATE OR REPLACE FUNCTION is_school_staff(check_school_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND school_id = check_school_id
    AND role IN ('bigadmin', 'admin', 'teacher')
  );
$$;

-- Overloaded version that checks against current user's school
CREATE OR REPLACE FUNCTION is_school_staff()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role IN ('bigadmin', 'admin', 'teacher')
  );
$$;

-- Function to check if user belongs to a specific school
CREATE OR REPLACE FUNCTION is_same_school(check_school_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND school_id = check_school_id
  );
$$;

-- ============================================================================
-- STEP 3: Enable RLS on all tables (if not already enabled)
-- ============================================================================

ALTER TABLE IF EXISTS schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS grades ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS invite_codes ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- STEP 4: Drop existing policies (to recreate them cleanly)
-- ============================================================================

-- Schools policies
DROP POLICY IF EXISTS "superadmin_schools_all" ON schools;
DROP POLICY IF EXISTS "users_view_own_school" ON schools;

-- Profiles policies
DROP POLICY IF EXISTS "superadmin_profiles_all" ON profiles;
DROP POLICY IF EXISTS "bigadmin_profiles_school" ON profiles;
DROP POLICY IF EXISTS "users_view_own_profile" ON profiles;
DROP POLICY IF EXISTS "users_update_own_profile" ON profiles;

-- Classes policies
DROP POLICY IF EXISTS "superadmin_classes_all" ON classes;
DROP POLICY IF EXISTS "bigadmin_classes_school" ON classes;
DROP POLICY IF EXISTS "staff_view_classes" ON classes;

-- Subjects policies
DROP POLICY IF EXISTS "superadmin_subjects_all" ON subjects;
DROP POLICY IF EXISTS "school_view_subjects" ON subjects;

-- Grades policies
DROP POLICY IF EXISTS "superadmin_grades_all" ON grades;
DROP POLICY IF EXISTS "bigadmin_grades_view" ON grades;
DROP POLICY IF EXISTS "teacher_grades_insert" ON grades;
DROP POLICY IF EXISTS "teacher_grades_update" ON grades;
DROP POLICY IF EXISTS "student_view_own_grades" ON grades;
DROP POLICY IF EXISTS "parent_view_child_grades" ON grades;

-- Assignments policies
DROP POLICY IF EXISTS "superadmin_assignments_all" ON assignments;
DROP POLICY IF EXISTS "bigadmin_assignments_view" ON assignments;
DROP POLICY IF EXISTS "teacher_assignments_insert" ON assignments;
DROP POLICY IF EXISTS "teacher_assignments_update" ON assignments;
DROP POLICY IF EXISTS "student_view_assignments" ON assignments;

-- Materials policies
DROP POLICY IF EXISTS "superadmin_materials_all" ON materials;
DROP POLICY IF EXISTS "bigadmin_materials_view" ON materials;
DROP POLICY IF EXISTS "teacher_materials_insert" ON materials;
DROP POLICY IF EXISTS "teacher_materials_update" ON materials;
DROP POLICY IF EXISTS "student_view_materials" ON materials;

-- Lessons policies
DROP POLICY IF EXISTS "superadmin_lessons_all" ON lessons;
DROP POLICY IF EXISTS "bigadmin_lessons_view" ON lessons;
DROP POLICY IF EXISTS "staff_view_lessons" ON lessons;
DROP POLICY IF EXISTS "student_view_lessons" ON lessons;

-- Invite codes policies
DROP POLICY IF EXISTS "superadmin_invite_codes_all" ON invite_codes;
DROP POLICY IF EXISTS "bigadmin_invite_codes_school" ON invite_codes;

-- ============================================================================
-- STEP 5: Create RLS Policies for SCHOOLS table
-- ============================================================================

-- Superadmin: Full access to all schools
CREATE POLICY "superadmin_schools_all" ON schools
  FOR ALL
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- All users: Can view their own school
CREATE POLICY "users_view_own_school" ON schools
  FOR SELECT
  USING (id = get_current_user_school_id());

-- ============================================================================
-- STEP 6: Create RLS Policies for PROFILES table
-- ============================================================================

-- Superadmin: Full access to all profiles
CREATE POLICY "superadmin_profiles_all" ON profiles
  FOR ALL
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin: Can view and edit profiles in their school
CREATE POLICY "bigadmin_profiles_school" ON profiles
  FOR ALL
  USING (
    is_bigadmin()
    AND school_id = get_current_user_school_id()
  )
  WITH CHECK (
    is_bigadmin()
    AND school_id = get_current_user_school_id()
  );

-- All users: Can view their own profile
CREATE POLICY "users_view_own_profile" ON profiles
  FOR SELECT
  USING (id = auth.uid());

-- All users: Can update their own profile (limited fields handled by triggers/app logic)
CREATE POLICY "users_update_own_profile" ON profiles
  FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- ============================================================================
-- STEP 7: Create RLS Policies for CLASSES table
-- ============================================================================

-- Superadmin: Full access to all classes
CREATE POLICY "superadmin_classes_all" ON classes
  FOR ALL
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin: Can view and edit classes in their school
CREATE POLICY "bigadmin_classes_school" ON classes
  FOR ALL
  USING (
    is_bigadmin()
    AND school_id = get_current_user_school_id()
  )
  WITH CHECK (
    is_bigadmin()
    AND school_id = get_current_user_school_id()
  );

-- Staff (admin, teacher): Can view classes in their school
CREATE POLICY "staff_view_classes" ON classes
  FOR SELECT
  USING (
    is_school_staff(school_id)
  );

-- ============================================================================
-- STEP 8: Create RLS Policies for SUBJECTS table
-- ============================================================================

-- Superadmin: Full access to all subjects
CREATE POLICY "superadmin_subjects_all" ON subjects
  FOR ALL
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- All users in school: Can view subjects in their school
CREATE POLICY "school_view_subjects" ON subjects
  FOR SELECT
  USING (
    school_id = get_current_user_school_id()
  );

-- ============================================================================
-- STEP 9: Create RLS Policies for GRADES table
-- ============================================================================

-- Superadmin: Full access to all grades
CREATE POLICY "superadmin_grades_all" ON grades
  FOR ALL
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin: Can view all grades in their school
CREATE POLICY "bigadmin_grades_view" ON grades
  FOR SELECT
  USING (
    is_bigadmin()
    AND EXISTS (
      SELECT 1 FROM subjects s
      WHERE s.id = grades.subject_id
      AND s.school_id = get_current_user_school_id()
    )
  );

-- Teacher: Can insert grades for subjects they teach
CREATE POLICY "teacher_grades_insert" ON grades
  FOR INSERT
  WITH CHECK (
    is_teacher()
    AND teacher_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM subjects s
      WHERE s.id = grades.subject_id
      AND s.teacher_id = auth.uid()
    )
  );

-- Teacher: Can update their own grades
CREATE POLICY "teacher_grades_update" ON grades
  FOR UPDATE
  USING (
    is_teacher()
    AND teacher_id = auth.uid()
  )
  WITH CHECK (
    is_teacher()
    AND teacher_id = auth.uid()
  );

-- Student: Can view their own grades
CREATE POLICY "student_view_own_grades" ON grades
  FOR SELECT
  USING (student_id = auth.uid());

-- Parent: Can view their children's grades (assumes parent_student_relations table)
CREATE POLICY "parent_view_child_grades" ON grades
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND p.role = 'parent'
    )
    AND EXISTS (
      SELECT 1 FROM parent_student_relations psr
      WHERE psr.parent_id = auth.uid()
      AND psr.student_id = grades.student_id
    )
  );

-- ============================================================================
-- STEP 10: Create RLS Policies for ASSIGNMENTS table
-- ============================================================================

-- Superadmin: Full access to all assignments
CREATE POLICY "superadmin_assignments_all" ON assignments
  FOR ALL
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin: Can view all assignments in their school
CREATE POLICY "bigadmin_assignments_view" ON assignments
  FOR SELECT
  USING (
    is_bigadmin()
    AND EXISTS (
      SELECT 1 FROM subjects s
      WHERE s.id = assignments.subject_id
      AND s.school_id = get_current_user_school_id()
    )
  );

-- Teacher: Can insert assignments for subjects they teach
CREATE POLICY "teacher_assignments_insert" ON assignments
  FOR INSERT
  WITH CHECK (
    is_teacher()
    AND teacher_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM subjects s
      WHERE s.id = assignments.subject_id
      AND s.teacher_id = auth.uid()
    )
  );

-- Teacher: Can update their own assignments
CREATE POLICY "teacher_assignments_update" ON assignments
  FOR UPDATE
  USING (
    is_teacher()
    AND teacher_id = auth.uid()
  )
  WITH CHECK (
    is_teacher()
    AND teacher_id = auth.uid()
  );

-- Students: Can view assignments for their class
CREATE POLICY "student_view_assignments" ON assignments
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      JOIN subjects s ON s.class_id = p.class_id
      WHERE p.id = auth.uid()
      AND s.id = assignments.subject_id
    )
  );

-- ============================================================================
-- STEP 11: Create RLS Policies for MATERIALS table
-- ============================================================================

-- Superadmin: Full access to all materials
CREATE POLICY "superadmin_materials_all" ON materials
  FOR ALL
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin: Can view all materials in their school
CREATE POLICY "bigadmin_materials_view" ON materials
  FOR SELECT
  USING (
    is_bigadmin()
    AND EXISTS (
      SELECT 1 FROM subjects s
      WHERE s.id = materials.subject_id
      AND s.school_id = get_current_user_school_id()
    )
  );

-- Teacher: Can insert materials for subjects they teach
CREATE POLICY "teacher_materials_insert" ON materials
  FOR INSERT
  WITH CHECK (
    is_teacher()
    AND teacher_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM subjects s
      WHERE s.id = materials.subject_id
      AND s.teacher_id = auth.uid()
    )
  );

-- Teacher: Can update their own materials
CREATE POLICY "teacher_materials_update" ON materials
  FOR UPDATE
  USING (
    is_teacher()
    AND teacher_id = auth.uid()
  )
  WITH CHECK (
    is_teacher()
    AND teacher_id = auth.uid()
  );

-- Students: Can view materials for their class
CREATE POLICY "student_view_materials" ON materials
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      JOIN subjects s ON s.class_id = p.class_id
      WHERE p.id = auth.uid()
      AND s.id = materials.subject_id
    )
  );

-- ============================================================================
-- STEP 12: Create RLS Policies for LESSONS table
-- ============================================================================

-- Superadmin: Full access to all lessons
CREATE POLICY "superadmin_lessons_all" ON lessons
  FOR ALL
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin: Can view all lessons in their school
CREATE POLICY "bigadmin_lessons_view" ON lessons
  FOR SELECT
  USING (
    is_bigadmin()
    AND EXISTS (
      SELECT 1 FROM subjects s
      WHERE s.id = lessons.subject_id
      AND s.school_id = get_current_user_school_id()
    )
  );

-- Staff: Can view lessons for subjects in their school
CREATE POLICY "staff_view_lessons" ON lessons
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM subjects s
      WHERE s.id = lessons.subject_id
      AND s.school_id = get_current_user_school_id()
    )
    AND is_school_staff()
  );

-- Students: Can view lessons for their class
CREATE POLICY "student_view_lessons" ON lessons
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      JOIN subjects s ON s.class_id = p.class_id
      WHERE p.id = auth.uid()
      AND s.id = lessons.subject_id
    )
  );

-- ============================================================================
-- STEP 13: Create RLS Policies for INVITE_CODES table
-- ============================================================================

-- Superadmin: Full access to all invite codes
CREATE POLICY "superadmin_invite_codes_all" ON invite_codes
  FOR ALL
  USING (is_superadmin())
  WITH CHECK (is_superadmin());

-- Bigadmin: Can manage invite codes for their school
CREATE POLICY "bigadmin_invite_codes_school" ON invite_codes
  FOR ALL
  USING (
    is_bigadmin()
    AND school_id = get_current_user_school_id()
  )
  WITH CHECK (
    is_bigadmin()
    AND school_id = get_current_user_school_id()
  );

-- ============================================================================
-- STEP 14: Grant necessary permissions to authenticated users
-- ============================================================================

-- Ensure authenticated users can execute the helper functions
GRANT EXECUTE ON FUNCTION get_current_user_role() TO authenticated;
GRANT EXECUTE ON FUNCTION get_current_user_school_id() TO authenticated;
GRANT EXECUTE ON FUNCTION is_superadmin() TO authenticated;
GRANT EXECUTE ON FUNCTION is_bigadmin() TO authenticated;
GRANT EXECUTE ON FUNCTION is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION is_teacher() TO authenticated;
GRANT EXECUTE ON FUNCTION is_school_staff(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION is_school_staff() TO authenticated;
GRANT EXECUTE ON FUNCTION is_same_school(uuid) TO authenticated;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
-- Summary of changes:
-- 1. Added 'bigadmin' role to user_role enum (represents Principal)
-- 2. Created helper functions for role checking:
--    - get_current_user_role()
--    - get_current_user_school_id()
--    - is_superadmin()
--    - is_bigadmin()
--    - is_admin()
--    - is_teacher()
--    - is_school_staff(uuid) / is_school_staff()
--    - is_same_school(uuid)
-- 3. Enabled RLS on all relevant tables
-- 4. Created comprehensive RLS policies for:
--    - superadmin: Full access to everything
--    - bigadmin: Manage users/classes/invite_codes in their school
--    - teacher: Insert/update grades, assignments, materials for their subjects
--    - student: View their own data
--    - parent: View their children's grades
-- ============================================================================
