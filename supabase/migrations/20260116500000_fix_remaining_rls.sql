-- ============================================================================
-- MIGRATION: Fix Remaining RLS Issues
-- Version: 20260116500000
--
-- PROBLEM 1: "permission denied for table parent_invites"
-- The parent_invites table policies may still have issues. Need to ensure
-- the table has proper grants AND that RLS policies use SECURITY DEFINER
-- helper functions correctly.
--
-- PROBLEM 2: "new row violates row-level security policy for table subjects"
-- The subjects table is missing DELETE policy for admin role and the policies
-- use older helper functions that may cause recursion issues.
--
-- SOLUTION:
-- 1. Grant ALL on parent_invites to authenticated and ensure RLS is properly configured
-- 2. Drop and recreate all subjects policies using rls_* helper functions
-- 3. Add complete CRUD policies for admin and bigadmin on subjects
-- ============================================================================

-- =============================================================================
-- PART 1: Fix parent_invites permissions
-- =============================================================================

-- Grant necessary permissions on the table
GRANT ALL ON parent_invites TO authenticated;
GRANT SELECT ON parent_invites TO anon;

-- Drop ALL existing policies and recreate cleanly
DROP POLICY IF EXISTS "parent_invites_superadmin_all" ON parent_invites;
DROP POLICY IF EXISTS "parent_invites_bigadmin_all" ON parent_invites;
DROP POLICY IF EXISTS "parent_invites_admin_all" ON parent_invites;
DROP POLICY IF EXISTS "parent_invites_teacher_select" ON parent_invites;
DROP POLICY IF EXISTS "parent_invites_validate_active" ON parent_invites;
DROP POLICY IF EXISTS "parent_invites_parent_own" ON parent_invites;
DROP POLICY IF EXISTS "School staff can view parent invites" ON parent_invites;
DROP POLICY IF EXISTS "School staff can create parent invites" ON parent_invites;
DROP POLICY IF EXISTS "School staff can update parent invites" ON parent_invites;
DROP POLICY IF EXISTS "School staff can delete parent invites" ON parent_invites;
DROP POLICY IF EXISTS "Anyone can view active invites by code" ON parent_invites;
DROP POLICY IF EXISTS "Parents can view their used invites" ON parent_invites;
DROP POLICY IF EXISTS "Superadmin has full access to parent invites" ON parent_invites;

-- Ensure RLS is enabled
ALTER TABLE parent_invites ENABLE ROW LEVEL SECURITY;

-- Policy 1: Superadmin full access
CREATE POLICY "parent_invites_superadmin_all" ON parent_invites
    FOR ALL
    TO authenticated
    USING (rls_is_superadmin())
    WITH CHECK (rls_is_superadmin());

-- Policy 2: Bigadmin (principal) full access within own school
CREATE POLICY "parent_invites_bigadmin_all" ON parent_invites
    FOR ALL
    TO authenticated
    USING (
        rls_is_bigadmin()
        AND school_id = rls_get_user_school_id()
    )
    WITH CHECK (
        rls_is_bigadmin()
        AND school_id = rls_get_user_school_id()
    );

-- Policy 3: Admin full access within own school
CREATE POLICY "parent_invites_admin_all" ON parent_invites
    FOR ALL
    TO authenticated
    USING (
        rls_is_admin()
        AND school_id = rls_get_user_school_id()
    )
    WITH CHECK (
        rls_is_admin()
        AND school_id = rls_get_user_school_id()
    );

-- Policy 4: Teacher can view parent invites for students they teach
CREATE POLICY "parent_invites_teacher_select" ON parent_invites
    FOR SELECT
    TO authenticated
    USING (
        rls_is_teacher()
        AND school_id = rls_get_user_school_id()
    );

-- Policy 5: Anyone can validate active (unused, non-expired) invite codes
CREATE POLICY "parent_invites_validate_active" ON parent_invites
    FOR SELECT
    TO anon, authenticated
    USING (
        times_used < usage_limit
        AND (expires_at IS NULL OR expires_at > now())
    );

-- Policy 6: Parents can view their own used invites
CREATE POLICY "parent_invites_parent_own" ON parent_invites
    FOR SELECT
    TO authenticated
    USING (parent_id = auth.uid());

-- =============================================================================
-- PART 2: Fix subjects table RLS policies
-- =============================================================================

-- Drop all existing subjects policies
DROP POLICY IF EXISTS "superadmin_all_subjects" ON subjects;
DROP POLICY IF EXISTS "bigadmin_all_own_school_subjects" ON subjects;
DROP POLICY IF EXISTS "admin_select_own_school_subjects" ON subjects;
DROP POLICY IF EXISTS "admin_insert_own_school_subjects" ON subjects;
DROP POLICY IF EXISTS "admin_update_own_school_subjects" ON subjects;
DROP POLICY IF EXISTS "admin_delete_own_school_subjects" ON subjects;
DROP POLICY IF EXISTS "teacher_all_own_subjects" ON subjects;
DROP POLICY IF EXISTS "teacher_select_school_subjects" ON subjects;
DROP POLICY IF EXISTS "student_select_enrolled_subjects" ON subjects;
DROP POLICY IF EXISTS "parent_select_children_subjects" ON subjects;
DROP POLICY IF EXISTS "superadmin_subjects_all" ON subjects;
DROP POLICY IF EXISTS "school_view_subjects" ON subjects;

-- Create helper function to check if a class is in the user's school
-- (Using SECURITY DEFINER to bypass RLS on classes table)
CREATE OR REPLACE FUNCTION rls_class_in_user_school(p_class_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM classes
        WHERE id = p_class_id
        AND school_id = (SELECT school_id FROM profiles WHERE id = auth.uid())
    );
END;
$$;

GRANT EXECUTE ON FUNCTION rls_class_in_user_school(UUID) TO authenticated;

-- Policy 1: Superadmin full access to all subjects
CREATE POLICY "subjects_superadmin_all" ON subjects
    FOR ALL
    TO authenticated
    USING (rls_is_superadmin())
    WITH CHECK (rls_is_superadmin());

-- Policy 2: Bigadmin (principal) full access within own school
CREATE POLICY "subjects_bigadmin_all" ON subjects
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

-- Policy 3: Admin full access within own school (SELECT, INSERT, UPDATE, DELETE)
CREATE POLICY "subjects_admin_all" ON subjects
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

-- Policy 4: Teacher full access to own subjects
CREATE POLICY "subjects_teacher_own" ON subjects
    FOR ALL
    TO authenticated
    USING (
        rls_is_teacher()
        AND teacher_id = auth.uid()
    )
    WITH CHECK (
        rls_is_teacher()
        AND teacher_id = auth.uid()
    );

-- Policy 5: Teacher can view all subjects in their school
CREATE POLICY "subjects_teacher_school_select" ON subjects
    FOR SELECT
    TO authenticated
    USING (
        rls_is_teacher()
        AND rls_class_in_user_school(class_id)
    );

-- Policy 6: Students can view subjects in their enrolled classes
CREATE POLICY "subjects_student_enrolled_select" ON subjects
    FOR SELECT
    TO authenticated
    USING (
        rls_get_user_role() = 'student'
        AND EXISTS (
            SELECT 1 FROM class_students
            WHERE class_id = subjects.class_id
            AND student_id = auth.uid()
        )
    );

-- Policy 7: Parents can view subjects of their children
CREATE POLICY "subjects_parent_children_select" ON subjects
    FOR SELECT
    TO authenticated
    USING (
        rls_get_user_role() = 'parent'
        AND EXISTS (
            SELECT 1 FROM class_students cs
            JOIN parent_student ps ON cs.student_id = ps.student_id
            WHERE cs.class_id = subjects.class_id
            AND ps.parent_id = auth.uid()
        )
    );

-- =============================================================================
-- PART 3: Verification
-- =============================================================================

DO $$
DECLARE
    pol RECORD;
BEGIN
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Current parent_invites policies:';
    RAISE NOTICE '===========================================';
    FOR pol IN
        SELECT policyname, cmd
        FROM pg_policies
        WHERE tablename = 'parent_invites' AND schemaname = 'public'
        ORDER BY policyname
    LOOP
        RAISE NOTICE '  - % (%)', pol.policyname, pol.cmd;
    END LOOP;

    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Current subjects policies:';
    RAISE NOTICE '===========================================';
    FOR pol IN
        SELECT policyname, cmd
        FROM pg_policies
        WHERE tablename = 'subjects' AND schemaname = 'public'
        ORDER BY policyname
    LOOP
        RAISE NOTICE '  - % (%)', pol.policyname, pol.cmd;
    END LOOP;
    RAISE NOTICE '===========================================';
END $$;

-- =============================================================================
-- END OF MIGRATION
-- =============================================================================
