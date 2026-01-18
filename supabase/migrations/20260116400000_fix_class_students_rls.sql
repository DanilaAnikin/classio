-- =============================================================================
-- Migration: Fix class_students RLS Policies for Admin/Deputy
-- =============================================================================
-- Version: 20260116400000
--
-- PROBLEM: "new row violates row-level security policy for table class_students"
-- When admin or bigadmin (deputy/principal) tries to add students to classes,
-- the INSERT operation fails due to RLS policy restrictions.
--
-- ROOT CAUSE:
-- The existing policy "admin_all_own_school_class_students" uses the old helper
-- functions (is_school_admin(), get_user_school_id()) which may trigger RLS
-- recursion issues during INSERT policy evaluation (WITH CHECK).
--
-- SOLUTION:
-- 1. Drop the existing policies that use old helper functions
-- 2. Create new policies using the rls_* helper functions (from migration
--    20260113300000) which have SET row_security = off to prevent recursion
-- 3. Ensure INSERT policy properly validates that the class belongs to the
--    user's school
-- =============================================================================

-- =============================================================================
-- STEP 1: Drop ALL existing policies on class_students table
-- =============================================================================

DROP POLICY IF EXISTS "superadmin_all_class_students" ON class_students;
DROP POLICY IF EXISTS "admin_all_own_school_class_students" ON class_students;
DROP POLICY IF EXISTS "teacher_select_class_students" ON class_students;
DROP POLICY IF EXISTS "teacher_insert_class_students" ON class_students;
DROP POLICY IF EXISTS "student_select_own_enrollment" ON class_students;
DROP POLICY IF EXISTS "parent_select_children_enrollment" ON class_students;

-- Also drop any policies that might have been created with the new naming convention
DROP POLICY IF EXISTS "class_students_superadmin_all" ON class_students;
DROP POLICY IF EXISTS "class_students_bigadmin_all" ON class_students;
DROP POLICY IF EXISTS "class_students_admin_all" ON class_students;
DROP POLICY IF EXISTS "class_students_admin_insert" ON class_students;
DROP POLICY IF EXISTS "class_students_admin_select" ON class_students;
DROP POLICY IF EXISTS "class_students_admin_update" ON class_students;
DROP POLICY IF EXISTS "class_students_admin_delete" ON class_students;
DROP POLICY IF EXISTS "class_students_teacher_select" ON class_students;
DROP POLICY IF EXISTS "class_students_teacher_insert" ON class_students;
DROP POLICY IF EXISTS "class_students_student_select" ON class_students;
DROP POLICY IF EXISTS "class_students_parent_select" ON class_students;

-- =============================================================================
-- STEP 2: Create helper function to check if class belongs to user's school
-- =============================================================================
-- This function safely checks class ownership without RLS recursion

CREATE OR REPLACE FUNCTION rls_class_in_user_school(p_class_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
DECLARE
    _user_school_id UUID;
    _class_school_id UUID;
BEGIN
    -- Get user's school_id
    SELECT school_id INTO _user_school_id FROM profiles WHERE id = auth.uid();

    -- Get class's school_id
    SELECT school_id INTO _class_school_id FROM classes WHERE id = p_class_id;

    -- Return true if both exist and match
    RETURN _user_school_id IS NOT NULL
       AND _class_school_id IS NOT NULL
       AND _user_school_id = _class_school_id;
END;
$$;

COMMENT ON FUNCTION rls_class_in_user_school IS
'SECURITY DEFINER function to check if a class belongs to the current user''s school. Bypasses RLS.';

GRANT EXECUTE ON FUNCTION rls_class_in_user_school(UUID) TO authenticated;

-- =============================================================================
-- STEP 3: Create new class_students policies using rls_* helper functions
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 3.1 Superadmin policy (full access to all class_students)
-- -----------------------------------------------------------------------------
CREATE POLICY "class_students_superadmin_all" ON class_students
    FOR ALL
    TO authenticated
    USING (rls_is_superadmin())
    WITH CHECK (rls_is_superadmin());

-- -----------------------------------------------------------------------------
-- 3.2 Bigadmin (principal) policy - full access within own school
-- -----------------------------------------------------------------------------
CREATE POLICY "class_students_bigadmin_all" ON class_students
    FOR ALL
    TO authenticated
    USING (
        rls_is_bigadmin()
        AND rls_class_in_user_school(class_id)
    )
    WITH CHECK (
        rls_is_bigadmin()
        AND rls_class_in_user_school(class_id)
    );

-- -----------------------------------------------------------------------------
-- 3.3 Admin (deputy) policy - full access within own school
-- This allows admin to:
-- - SELECT students in classes of their school
-- - INSERT students into classes of their school
-- - UPDATE enrollments in classes of their school
-- - DELETE students from classes of their school
-- -----------------------------------------------------------------------------
CREATE POLICY "class_students_admin_all" ON class_students
    FOR ALL
    TO authenticated
    USING (
        rls_is_admin()
        AND rls_class_in_user_school(class_id)
    )
    WITH CHECK (
        rls_is_admin()
        AND rls_class_in_user_school(class_id)
    );

-- -----------------------------------------------------------------------------
-- 3.4 Teacher policy - SELECT students in classes they teach
-- -----------------------------------------------------------------------------
CREATE POLICY "class_students_teacher_select" ON class_students
    FOR SELECT
    TO authenticated
    USING (
        rls_is_teacher()
        AND rls_teaches_class(class_id)
    );

-- -----------------------------------------------------------------------------
-- 3.5 Teacher policy - INSERT students into classes they teach
-- -----------------------------------------------------------------------------
CREATE POLICY "class_students_teacher_insert" ON class_students
    FOR INSERT
    TO authenticated
    WITH CHECK (
        rls_is_teacher()
        AND rls_teaches_class(class_id)
    );

-- -----------------------------------------------------------------------------
-- 3.6 Student policy - SELECT own enrollments only
-- -----------------------------------------------------------------------------
CREATE POLICY "class_students_student_select" ON class_students
    FOR SELECT
    TO authenticated
    USING (
        rls_get_user_role() = 'student'
        AND student_id = auth.uid()
    );

-- -----------------------------------------------------------------------------
-- 3.7 Parent policy - SELECT children's enrollments
-- Uses is_parent_of which is already defined as SECURITY DEFINER
-- -----------------------------------------------------------------------------
CREATE POLICY "class_students_parent_select" ON class_students
    FOR SELECT
    TO authenticated
    USING (
        rls_get_user_role() = 'parent'
        AND is_parent_of(student_id)
    );

-- =============================================================================
-- STEP 4: Verification - List current policies on class_students
-- =============================================================================

DO $$
DECLARE
    pol RECORD;
BEGIN
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Current class_students policies:';
    RAISE NOTICE '===========================================';
    FOR pol IN
        SELECT policyname, cmd, permissive
        FROM pg_policies
        WHERE tablename = 'class_students' AND schemaname = 'public'
        ORDER BY policyname
    LOOP
        RAISE NOTICE '  - % (%)', pol.policyname, pol.cmd;
    END LOOP;
    RAISE NOTICE '===========================================';
END $$;

-- =============================================================================
-- END OF MIGRATION
-- =============================================================================
