-- ============================================================================
-- MIGRATION: Fix class_subjects Table RLS Policies
-- Version: 20260117300000
--
-- PROBLEM: "permission denied for table class_subjects"
-- Both fetching deputy stats and creating lessons fail because the existing
-- RLS policies use old helper functions (is_superadmin, is_school_admin,
-- get_user_school_id) which cause recursion issues or don't properly grant
-- access.
--
-- SOLUTION:
-- 1. Grant proper permissions on class_subjects table
-- 2. Drop all existing policies that use old helper functions
-- 3. Create new policies using rls_* helper functions:
--    - Superadmin: full access to all class_subjects
--    - Bigadmin (principal): full access within their school
--    - Admin (deputy): full access within their school
--    - Teacher: SELECT access for subjects they teach
--    - Student: SELECT access for their enrolled classes
--    - Parent: SELECT access for their children's classes
-- ============================================================================

-- =============================================================================
-- PART 1: Grant permissions on class_subjects table
-- =============================================================================

-- Grant necessary permissions to authenticated users
GRANT ALL ON class_subjects TO authenticated;

-- =============================================================================
-- PART 2: Drop all existing policies on class_subjects table
-- =============================================================================

DROP POLICY IF EXISTS "superadmin_all_class_subjects" ON class_subjects;
DROP POLICY IF EXISTS "admin_all_own_school_class_subjects" ON class_subjects;
DROP POLICY IF EXISTS "teacher_select_class_subjects" ON class_subjects;
DROP POLICY IF EXISTS "teacher_manage_own_class_subjects" ON class_subjects;
DROP POLICY IF EXISTS "student_select_enrolled_class_subjects" ON class_subjects;
DROP POLICY IF EXISTS "parent_select_children_class_subjects" ON class_subjects;

-- Also drop any policies with the new naming convention (if migration ran before)
DROP POLICY IF EXISTS "class_subjects_superadmin_all" ON class_subjects;
DROP POLICY IF EXISTS "class_subjects_bigadmin_all" ON class_subjects;
DROP POLICY IF EXISTS "class_subjects_admin_all" ON class_subjects;
DROP POLICY IF EXISTS "class_subjects_teacher_select" ON class_subjects;
DROP POLICY IF EXISTS "class_subjects_teacher_own" ON class_subjects;
DROP POLICY IF EXISTS "class_subjects_student_select" ON class_subjects;
DROP POLICY IF EXISTS "class_subjects_parent_select" ON class_subjects;

-- =============================================================================
-- PART 3: Ensure RLS is enabled
-- =============================================================================

ALTER TABLE class_subjects ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- PART 4: Create new RLS policies using rls_* helper functions
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Policy 1: Superadmin full access to all class_subjects
-- -----------------------------------------------------------------------------
CREATE POLICY "class_subjects_superadmin_all" ON class_subjects
    FOR ALL
    TO authenticated
    USING (rls_is_superadmin())
    WITH CHECK (rls_is_superadmin());

-- -----------------------------------------------------------------------------
-- Policy 2: Bigadmin (principal) full access within their school
-- -----------------------------------------------------------------------------
CREATE POLICY "class_subjects_bigadmin_all" ON class_subjects
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
-- Policy 3: Admin (deputy) full access within their school
-- This allows admin to:
-- - SELECT class_subjects in their school
-- - INSERT new class_subject assignments
-- - UPDATE class_subject assignments
-- - DELETE class_subject assignments
-- -----------------------------------------------------------------------------
CREATE POLICY "class_subjects_admin_all" ON class_subjects
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
-- Policy 4: Teacher SELECT access for subjects they teach
-- Teachers can view class_subjects for any class in their school
-- -----------------------------------------------------------------------------
CREATE POLICY "class_subjects_teacher_select" ON class_subjects
    FOR SELECT
    TO authenticated
    USING (
        rls_is_teacher()
        AND rls_class_in_user_school(class_id)
    );

-- -----------------------------------------------------------------------------
-- Policy 5: Teacher can manage class_subjects for their own subjects
-- Teachers can add/remove their subjects from classes
-- -----------------------------------------------------------------------------
CREATE POLICY "class_subjects_teacher_own" ON class_subjects
    FOR ALL
    TO authenticated
    USING (
        rls_is_teacher()
        AND EXISTS (
            SELECT 1 FROM subjects
            WHERE id = class_subjects.subject_id
            AND teacher_id = auth.uid()
        )
    )
    WITH CHECK (
        rls_is_teacher()
        AND EXISTS (
            SELECT 1 FROM subjects
            WHERE id = class_subjects.subject_id
            AND teacher_id = auth.uid()
        )
    );

-- -----------------------------------------------------------------------------
-- Policy 6: Student SELECT access for their enrolled classes
-- -----------------------------------------------------------------------------
CREATE POLICY "class_subjects_student_select" ON class_subjects
    FOR SELECT
    TO authenticated
    USING (
        rls_get_user_role() = 'student'
        AND EXISTS (
            SELECT 1 FROM class_students
            WHERE class_id = class_subjects.class_id
            AND student_id = auth.uid()
        )
    );

-- -----------------------------------------------------------------------------
-- Policy 7: Parent SELECT access for their children's classes
-- -----------------------------------------------------------------------------
CREATE POLICY "class_subjects_parent_select" ON class_subjects
    FOR SELECT
    TO authenticated
    USING (
        rls_get_user_role() = 'parent'
        AND EXISTS (
            SELECT 1 FROM class_students cs
            JOIN parent_student ps ON cs.student_id = ps.student_id
            WHERE cs.class_id = class_subjects.class_id
            AND ps.parent_id = auth.uid()
        )
    );

-- =============================================================================
-- PART 5: Verification
-- =============================================================================

DO $$
DECLARE
    pol RECORD;
BEGIN
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Current class_subjects policies after migration:';
    RAISE NOTICE '===========================================';
    FOR pol IN
        SELECT policyname, cmd
        FROM pg_policies
        WHERE tablename = 'class_subjects' AND schemaname = 'public'
        ORDER BY policyname
    LOOP
        RAISE NOTICE '  - % (%)', pol.policyname, pol.cmd;
    END LOOP;
    RAISE NOTICE '===========================================';
END $$;

-- =============================================================================
-- END OF MIGRATION
-- =============================================================================
