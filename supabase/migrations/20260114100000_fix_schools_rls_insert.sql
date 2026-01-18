-- ============================================================================
-- FIX: Schools RLS INSERT Policy for Superadmins
-- Version: 20260114100000
--
-- PROBLEM: Superadmins cannot create schools. Error:
-- "Failed to create school: new row violates row-level security policy for table 'schools'"
--
-- ROOT CAUSE: The existing schools RLS policies may have conflicts or use
-- functions that don't properly bypass RLS recursion. Additionally, there
-- might be duplicate policies from different migrations.
--
-- SOLUTION: Drop all existing schools policies and recreate them using the
-- secure `auth_is_superadmin()` and `auth_get_user_school_id()` functions
-- from migration 20260113400000.
-- ============================================================================

-- ============================================================================
-- STEP 1: Drop ALL existing schools policies to start clean
-- ============================================================================

-- Drop policies from 20260111200000_ultimate_schema.sql
DROP POLICY IF EXISTS "superadmin_all_schools" ON schools;
DROP POLICY IF EXISTS "admin_select_own_school" ON schools;
DROP POLICY IF EXISTS "admin_update_own_school" ON schools;
DROP POLICY IF EXISTS "users_select_own_school" ON schools;

-- Drop policies from rbac_update.sql
DROP POLICY IF EXISTS "superadmin_schools_all" ON schools;
DROP POLICY IF EXISTS "users_view_own_school" ON schools;

-- Drop any other possible policy names
DROP POLICY IF EXISTS "Superadmins can view all schools" ON schools;
DROP POLICY IF EXISTS "Users can view their own school" ON schools;
DROP POLICY IF EXISTS "Superadmins can insert schools" ON schools;
DROP POLICY IF EXISTS "Admins can update their school" ON schools;
DROP POLICY IF EXISTS "Superadmins can create schools" ON schools;
DROP POLICY IF EXISTS "Superadmins can update schools" ON schools;
DROP POLICY IF EXISTS "Superadmins can delete schools" ON schools;

DO $$
BEGIN
    RAISE NOTICE '✓ Dropped all existing schools policies';
END $$;

-- ============================================================================
-- STEP 2: Ensure RLS is enabled on schools table
-- ============================================================================

ALTER TABLE schools ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    RAISE NOTICE '✓ Ensured RLS is enabled on schools table';
END $$;

-- ============================================================================
-- STEP 3: Create clean, comprehensive schools policies
-- Using auth_is_superadmin() and auth_get_user_school_id() to avoid recursion
-- ============================================================================

-- Policy 1: Superadmins have FULL access to ALL schools (SELECT, INSERT, UPDATE, DELETE)
-- This is the most important policy - superadmins must be able to create schools
CREATE POLICY "schools_superadmin_all" ON schools
    FOR ALL
    TO authenticated
    USING (auth_is_superadmin())
    WITH CHECK (auth_is_superadmin());

COMMENT ON POLICY "schools_superadmin_all" ON schools IS
'Superadmins have full access to all schools (SELECT, INSERT, UPDATE, DELETE)';

DO $$
BEGIN
    RAISE NOTICE '✓ Created policy: schools_superadmin_all (FOR ALL)';
END $$;

-- Policy 2: School admins (bigadmin, admin) can SELECT their own school
CREATE POLICY "schools_admin_select" ON schools
    FOR SELECT
    TO authenticated
    USING (
        auth_is_school_admin()
        AND id = auth_get_user_school_id()
    );

COMMENT ON POLICY "schools_admin_select" ON schools IS
'School admins (bigadmin, admin) can view their own school';

DO $$
BEGIN
    RAISE NOTICE '✓ Created policy: schools_admin_select (FOR SELECT)';
END $$;

-- Policy 3: School admins (bigadmin, admin) can UPDATE their own school
CREATE POLICY "schools_admin_update" ON schools
    FOR UPDATE
    TO authenticated
    USING (
        auth_is_school_admin()
        AND id = auth_get_user_school_id()
    )
    WITH CHECK (
        auth_is_school_admin()
        AND id = auth_get_user_school_id()
    );

COMMENT ON POLICY "schools_admin_update" ON schools IS
'School admins (bigadmin, admin) can update their own school';

DO $$
BEGIN
    RAISE NOTICE '✓ Created policy: schools_admin_update (FOR UPDATE)';
END $$;

-- Policy 4: All authenticated users can SELECT their own school
-- This allows teachers, students, parents to view their school info
CREATE POLICY "schools_users_select_own" ON schools
    FOR SELECT
    TO authenticated
    USING (id = auth_get_user_school_id());

COMMENT ON POLICY "schools_users_select_own" ON schools IS
'All authenticated users can view their own school';

DO $$
BEGIN
    RAISE NOTICE '✓ Created policy: schools_users_select_own (FOR SELECT)';
END $$;

-- ============================================================================
-- STEP 4: Verification
-- ============================================================================

DO $$
DECLARE
    policy_count INTEGER;
    pol RECORD;
BEGIN
    -- Count schools policies
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies
    WHERE tablename = 'schools' AND schemaname = 'public';

    RAISE NOTICE '';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'SCHOOLS POLICIES VERIFICATION';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Total policies on schools table: %', policy_count;
    RAISE NOTICE '';

    -- List all schools policies
    FOR pol IN
        SELECT policyname, cmd, permissive, qual::text as using_clause, with_check::text as check_clause
        FROM pg_policies
        WHERE tablename = 'schools' AND schemaname = 'public'
        ORDER BY cmd, policyname
    LOOP
        RAISE NOTICE '[%] %', pol.cmd, pol.policyname;
        IF pol.using_clause IS NOT NULL THEN
            RAISE NOTICE '    USING: %', pol.using_clause;
        END IF;
        IF pol.check_clause IS NOT NULL THEN
            RAISE NOTICE '    WITH CHECK: %', pol.check_clause;
        END IF;
    END LOOP;

    RAISE NOTICE '';
    RAISE NOTICE '============================================';

    -- Verify we have the superadmin policy
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'schools'
        AND schemaname = 'public'
        AND policyname = 'schools_superadmin_all'
    ) THEN
        RAISE EXCEPTION 'CRITICAL: schools_superadmin_all policy was not created!';
    END IF;

    RAISE NOTICE '✓ Verification passed: All required policies exist';
    RAISE NOTICE '============================================';
END $$;

-- ============================================================================
-- STEP 5: Summary
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'FIX APPLIED SUCCESSFULLY';
    RAISE NOTICE '============================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Schools RLS Policies Summary:';
    RAISE NOTICE '';
    RAISE NOTICE '1. schools_superadmin_all (FOR ALL)';
    RAISE NOTICE '   - Superadmins can SELECT, INSERT, UPDATE, DELETE any school';
    RAISE NOTICE '   - Uses auth_is_superadmin() to avoid RLS recursion';
    RAISE NOTICE '';
    RAISE NOTICE '2. schools_admin_select (FOR SELECT)';
    RAISE NOTICE '   - BigAdmins and Admins can view their own school';
    RAISE NOTICE '';
    RAISE NOTICE '3. schools_admin_update (FOR UPDATE)';
    RAISE NOTICE '   - BigAdmins and Admins can update their own school';
    RAISE NOTICE '';
    RAISE NOTICE '4. schools_users_select_own (FOR SELECT)';
    RAISE NOTICE '   - All users (teachers, students, parents) can view their school';
    RAISE NOTICE '';
    RAISE NOTICE 'The superadmin should now be able to create schools.';
    RAISE NOTICE '============================================';
    RAISE NOTICE '';
END $$;

-- ============================================================================
-- END OF FIX
-- ============================================================================
