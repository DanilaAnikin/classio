-- ============================================================================
-- MIGRATION: Fix Lessons Table RLS Policies
-- Version: 20260116600000
--
-- PROBLEM: "new row violates row-level security policy for table lessons"
-- Deputies (admin role) cannot create lessons because the existing RLS policies
-- use old helper functions (is_school_admin, get_user_school_id) which may
-- cause recursion issues or don't properly grant access.
--
-- SOLUTION:
-- 1. Create a SECURITY DEFINER helper function to check if a subject is in the user's school
-- 2. Drop all existing lessons policies
-- 3. Create new policies using rls_* helper functions:
--    - Superadmin: full access to all lessons
--    - Bigadmin (principal): full access to lessons in their school
--    - Admin (deputy): full access to lessons in their school
--    - Teacher: full access to their own lessons (where they are the teacher of the subject)
--    - Students: SELECT access to lessons in their enrolled classes
--    - Parents: SELECT access to their children's lessons
-- ============================================================================

-- =============================================================================
-- PART 1: Create helper function for subject-school relationship check
-- =============================================================================

-- Helper function to check if a subject is in the user's school
-- This follows the same pattern as rls_class_in_user_school but for subjects
-- The relationship is: lessons -> subjects -> classes -> schools
CREATE OR REPLACE FUNCTION rls_subject_in_user_school(p_subject_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM subjects s
        JOIN classes c ON s.class_id = c.id
        WHERE s.id = p_subject_id
        AND c.school_id = (SELECT school_id FROM profiles WHERE id = auth.uid())
    );
END;
$$;

GRANT EXECUTE ON FUNCTION rls_subject_in_user_school(UUID) TO authenticated;

COMMENT ON FUNCTION rls_subject_in_user_school IS 'SECURITY DEFINER function to check if a subject belongs to the user school. Bypasses RLS on subjects and classes tables.';

-- =============================================================================
-- PART 2: Drop all existing lessons policies
-- =============================================================================

DROP POLICY IF EXISTS "superadmin_all_lessons" ON lessons;
DROP POLICY IF EXISTS "admin_all_own_school_lessons" ON lessons;
DROP POLICY IF EXISTS "teacher_select_own_lessons" ON lessons;
DROP POLICY IF EXISTS "teacher_update_own_lessons" ON lessons;
DROP POLICY IF EXISTS "teacher_insert_own_lessons" ON lessons;
DROP POLICY IF EXISTS "teacher_delete_own_lessons" ON lessons;
DROP POLICY IF EXISTS "student_select_enrolled_lessons" ON lessons;
DROP POLICY IF EXISTS "parent_select_children_lessons" ON lessons;
DROP POLICY IF EXISTS "lessons_superadmin_all" ON lessons;
DROP POLICY IF EXISTS "lessons_bigadmin_all" ON lessons;
DROP POLICY IF EXISTS "lessons_admin_all" ON lessons;
DROP POLICY IF EXISTS "lessons_teacher_own" ON lessons;
DROP POLICY IF EXISTS "lessons_teacher_school_select" ON lessons;
DROP POLICY IF EXISTS "lessons_student_enrolled_select" ON lessons;
DROP POLICY IF EXISTS "lessons_parent_children_select" ON lessons;

-- =============================================================================
-- PART 3: Ensure table setup
-- =============================================================================

-- Ensure RLS is enabled
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;

-- Grant necessary permissions
GRANT ALL ON lessons TO authenticated;

-- =============================================================================
-- PART 4: Create new RLS policies using rls_* helper functions
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Policy 1: Superadmin full access to all lessons
-- -----------------------------------------------------------------------------
CREATE POLICY "lessons_superadmin_all" ON lessons
    FOR ALL
    TO authenticated
    USING (rls_is_superadmin())
    WITH CHECK (rls_is_superadmin());

-- -----------------------------------------------------------------------------
-- Policy 2: Bigadmin (principal) full access to lessons in their school
-- -----------------------------------------------------------------------------
CREATE POLICY "lessons_bigadmin_all" ON lessons
    FOR ALL
    TO authenticated
    USING (
        rls_is_bigadmin()
        AND rls_subject_in_user_school(subject_id)
    )
    WITH CHECK (
        rls_is_bigadmin()
        AND rls_subject_in_user_school(subject_id)
    );

-- -----------------------------------------------------------------------------
-- Policy 3: Admin (deputy) full access to lessons in their school
-- -----------------------------------------------------------------------------
CREATE POLICY "lessons_admin_all" ON lessons
    FOR ALL
    TO authenticated
    USING (
        rls_is_admin()
        AND rls_subject_in_user_school(subject_id)
    )
    WITH CHECK (
        rls_is_admin()
        AND rls_subject_in_user_school(subject_id)
    );

-- -----------------------------------------------------------------------------
-- Policy 4: Teacher full access to their own subjects' lessons
-- Teachers can create/update/delete lessons for subjects they teach
-- -----------------------------------------------------------------------------
CREATE POLICY "lessons_teacher_own" ON lessons
    FOR ALL
    TO authenticated
    USING (
        rls_is_teacher()
        AND EXISTS (
            SELECT 1 FROM subjects
            WHERE id = lessons.subject_id
            AND teacher_id = auth.uid()
        )
    )
    WITH CHECK (
        rls_is_teacher()
        AND EXISTS (
            SELECT 1 FROM subjects
            WHERE id = lessons.subject_id
            AND teacher_id = auth.uid()
        )
    );

-- -----------------------------------------------------------------------------
-- Policy 5: Teacher can view all lessons in their school
-- Teachers should be able to see other lessons for scheduling purposes
-- -----------------------------------------------------------------------------
CREATE POLICY "lessons_teacher_school_select" ON lessons
    FOR SELECT
    TO authenticated
    USING (
        rls_is_teacher()
        AND rls_subject_in_user_school(subject_id)
    );

-- -----------------------------------------------------------------------------
-- Policy 6: Students can view lessons in their enrolled classes
-- -----------------------------------------------------------------------------
CREATE POLICY "lessons_student_enrolled_select" ON lessons
    FOR SELECT
    TO authenticated
    USING (
        rls_get_user_role() = 'student'
        AND EXISTS (
            SELECT 1 FROM subjects s
            JOIN class_students cs ON s.class_id = cs.class_id
            WHERE s.id = lessons.subject_id
            AND cs.student_id = auth.uid()
        )
    );

-- -----------------------------------------------------------------------------
-- Policy 7: Parents can view their children's lessons
-- -----------------------------------------------------------------------------
CREATE POLICY "lessons_parent_children_select" ON lessons
    FOR SELECT
    TO authenticated
    USING (
        rls_get_user_role() = 'parent'
        AND EXISTS (
            SELECT 1 FROM subjects s
            JOIN class_students cs ON s.class_id = cs.class_id
            JOIN parent_student ps ON cs.student_id = ps.student_id
            WHERE s.id = lessons.subject_id
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
    RAISE NOTICE 'Current lessons policies after migration:';
    RAISE NOTICE '===========================================';
    FOR pol IN
        SELECT policyname, cmd
        FROM pg_policies
        WHERE tablename = 'lessons' AND schemaname = 'public'
        ORDER BY policyname
    LOOP
        RAISE NOTICE '  - % (%)', pol.policyname, pol.cmd;
    END LOOP;
    RAISE NOTICE '===========================================';
END $$;

-- =============================================================================
-- END OF MIGRATION
-- =============================================================================
