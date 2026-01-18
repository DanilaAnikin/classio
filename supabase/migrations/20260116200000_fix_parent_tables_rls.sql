-- ============================================================================
-- MIGRATION: Fix RLS Policies for parent_invites and parent_students
-- Version: 20260116200000
--
-- PROBLEM 1: "permission denied for table parent_invites"
-- The RLS policies on parent_invites use direct queries to profiles table
-- which can cause recursion issues. Need to use rls_* helper functions.
--
-- PROBLEM 2: "permission denied for view parent_students"
-- The view was created but no SELECT permission was granted to authenticated
-- users. Views require explicit GRANT permissions.
--
-- SOLUTION:
-- 1. Grant SELECT permission on parent_students view to authenticated users
-- 2. Drop existing RLS policies on parent_invites
-- 3. Recreate RLS policies using the rls_* helper functions (created in
--    migration 20260113300000_fix_principal_rls_policies.sql)
-- ============================================================================

-- =============================================================================
-- PART 1: Fix parent_students view permissions
-- =============================================================================
-- The view exists but authenticated users don't have permission to query it

-- Grant SELECT permission on the view to authenticated users
GRANT SELECT ON parent_students TO authenticated;

-- Also grant to anon in case it's needed for registration flows
GRANT SELECT ON parent_students TO anon;

-- =============================================================================
-- PART 2: Fix parent_invites RLS policies
-- =============================================================================
-- Drop all existing policies and recreate using rls_* helper functions

-- -----------------------------------------------------------------------------
-- 2.1 Drop ALL existing RLS policies on parent_invites
-- -----------------------------------------------------------------------------
DROP POLICY IF EXISTS "School staff can view parent invites" ON parent_invites;
DROP POLICY IF EXISTS "School staff can create parent invites" ON parent_invites;
DROP POLICY IF EXISTS "School staff can update parent invites" ON parent_invites;
DROP POLICY IF EXISTS "School staff can delete parent invites" ON parent_invites;
DROP POLICY IF EXISTS "Anyone can view active invites by code" ON parent_invites;
DROP POLICY IF EXISTS "Parents can view their used invites" ON parent_invites;
DROP POLICY IF EXISTS "Superadmin has full access to parent invites" ON parent_invites;

-- -----------------------------------------------------------------------------
-- 2.2 Create new superadmin policy (full access)
-- -----------------------------------------------------------------------------
CREATE POLICY "parent_invites_superadmin_all" ON parent_invites
    FOR ALL
    TO authenticated
    USING (rls_is_superadmin())
    WITH CHECK (rls_is_superadmin());

-- -----------------------------------------------------------------------------
-- 2.3 Create bigadmin (principal) policy - full access within own school
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- 2.4 Create admin policy - full access within own school
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- 2.5 Create teacher SELECT policy
-- Teachers can view parent invites for students in their classes
-- -----------------------------------------------------------------------------
CREATE POLICY "parent_invites_teacher_select" ON parent_invites
    FOR SELECT
    TO authenticated
    USING (
        rls_is_teacher()
        AND school_id = rls_get_user_school_id()
        AND EXISTS (
            SELECT 1 FROM class_students cs
            JOIN subjects s ON s.class_id = cs.class_id
            WHERE cs.student_id = parent_invites.student_id
            AND s.teacher_id = auth.uid()
        )
    );

-- -----------------------------------------------------------------------------
-- 2.6 Create policy for validating active invites (used during registration)
-- Anyone can view active (unused, non-expired) invites by code
-- -----------------------------------------------------------------------------
CREATE POLICY "parent_invites_validate_active" ON parent_invites
    FOR SELECT
    TO anon, authenticated
    USING (
        times_used < usage_limit
        AND (expires_at IS NULL OR expires_at > now())
    );

-- -----------------------------------------------------------------------------
-- 2.7 Create policy for parents to view their own used invites (for history)
-- -----------------------------------------------------------------------------
CREATE POLICY "parent_invites_parent_own" ON parent_invites
    FOR SELECT
    TO authenticated
    USING (parent_id = auth.uid());

-- =============================================================================
-- PART 3: Ensure parent_student table also has proper permissions
-- =============================================================================
-- The underlying table needs proper grants too since the view queries it

-- Grant SELECT on parent_student to authenticated (for the view to work)
GRANT SELECT ON parent_student TO authenticated;

-- =============================================================================
-- PART 4: Verification - List current policies
-- =============================================================================

DO $$
DECLARE
    pol RECORD;
BEGIN
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Current parent_invites policies:';
    RAISE NOTICE '===========================================';
    FOR pol IN
        SELECT policyname, cmd, permissive
        FROM pg_policies
        WHERE tablename = 'parent_invites' AND schemaname = 'public'
        ORDER BY policyname
    LOOP
        RAISE NOTICE '  - % (%)', pol.policyname, pol.cmd;
    END LOOP;
    RAISE NOTICE '===========================================';
END $$;

-- =============================================================================
-- END OF MIGRATION
-- =============================================================================
