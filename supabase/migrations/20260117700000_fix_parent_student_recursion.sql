-- ============================================================================
-- MIGRATION: Fix Parent-Student RLS Infinite Recursion
-- Version: 20260117700000
--
-- PROBLEM:
-- The policies created in 20260117600000_bulletproof_parent_student_linking.sql
-- directly query the `profiles` table to check roles, which causes infinite
-- recursion when combined with profiles policies that reference parent_student.
--
-- Error messages:
-- - "infinite recursion detected in policy for relation 'parent_student'"
-- - "infinite recursion detected in policy for relation 'profiles'"
--
-- ROOT CAUSE:
-- Policies like this are BAD:
--   USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'superadmin'))
--
-- They query `profiles` which may have policies that query other tables,
-- creating a circular dependency chain.
--
-- SOLUTION:
-- Use SECURITY DEFINER helper functions (rls_*) that have `SET row_security = off`
-- These functions bypass RLS when checking conditions, preventing recursion.
--
-- GOOD pattern:
--   USING (rls_is_superadmin())
--
-- BAD pattern:
--   USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'superadmin'))
-- ============================================================================

-- =============================================================================
-- STEP 1: Create missing rls_* helper functions
-- =============================================================================

-- Helper function to check if current user is a parent
CREATE OR REPLACE FUNCTION rls_is_parent()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
DECLARE
    _role user_role;
BEGIN
    SELECT role INTO _role FROM profiles WHERE id = auth.uid();
    RETURN _role = 'parent';
END;
$$;

COMMENT ON FUNCTION rls_is_parent IS 'SECURITY DEFINER function to check if user is parent for RLS policies. Bypasses RLS.';
GRANT EXECUTE ON FUNCTION rls_is_parent() TO authenticated;

-- Helper function to check if current user is a student
CREATE OR REPLACE FUNCTION rls_is_student()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
DECLARE
    _role user_role;
BEGIN
    SELECT role INTO _role FROM profiles WHERE id = auth.uid();
    RETURN _role = 'student';
END;
$$;

COMMENT ON FUNCTION rls_is_student IS 'SECURITY DEFINER function to check if user is student for RLS policies. Bypasses RLS.';
GRANT EXECUTE ON FUNCTION rls_is_student() TO authenticated;

-- Helper function to check if a student is in any of the current user's (teacher's) classes
-- This is a SECURITY DEFINER version that bypasses RLS
CREATE OR REPLACE FUNCTION rls_student_in_my_class(p_student_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM class_students cs
        JOIN subjects s ON s.class_id = cs.class_id
        WHERE cs.student_id = p_student_id AND s.teacher_id = auth.uid()
    );
END;
$$;

COMMENT ON FUNCTION rls_student_in_my_class IS 'SECURITY DEFINER function to check if a student is in the teachers classes. Bypasses RLS.';
GRANT EXECUTE ON FUNCTION rls_student_in_my_class(UUID) TO authenticated;

-- Helper function to check if a student belongs to the same school as the current user
CREATE OR REPLACE FUNCTION rls_student_in_school(p_student_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
DECLARE
    _user_school_id UUID;
    _student_school_id UUID;
BEGIN
    SELECT school_id INTO _user_school_id FROM profiles WHERE id = auth.uid();
    SELECT school_id INTO _student_school_id FROM profiles WHERE id = p_student_id;
    RETURN _user_school_id IS NOT NULL AND _user_school_id = _student_school_id;
END;
$$;

COMMENT ON FUNCTION rls_student_in_school IS 'SECURITY DEFINER function to check if a student is in the same school. Bypasses RLS.';
GRANT EXECUTE ON FUNCTION rls_student_in_school(UUID) TO authenticated;

-- Helper function to check if a user is a child of the current user (parent)
-- Used in profiles RLS to allow parents to see their children's profiles
CREATE OR REPLACE FUNCTION rls_is_my_child(p_student_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM parent_student ps
        WHERE ps.parent_id = auth.uid()
        AND ps.student_id = p_student_id
    );
END;
$$;

COMMENT ON FUNCTION rls_is_my_child IS 'SECURITY DEFINER function to check if a user is the childs parent. Bypasses RLS.';
GRANT EXECUTE ON FUNCTION rls_is_my_child(UUID) TO authenticated;

-- =============================================================================
-- STEP 2: Drop ALL existing RLS policies on parent_student
-- =============================================================================

DO $$
DECLARE
    pol RECORD;
BEGIN
    RAISE NOTICE 'Dropping all existing parent_student policies...';

    FOR pol IN
        SELECT policyname
        FROM pg_policies
        WHERE tablename = 'parent_student' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON parent_student', pol.policyname);
        RAISE NOTICE 'Dropped policy: %', pol.policyname;
    END LOOP;

    RAISE NOTICE 'All parent_student policies dropped.';
END $$;

-- =============================================================================
-- STEP 3: Create new, safe RLS policies for parent_student
-- These ONLY use rls_* helper functions and auth.uid() comparisons
-- =============================================================================

-- Enable RLS (should already be enabled, but just in case)
ALTER TABLE parent_student ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- Policy 1: Superadmin - Full access
-- -----------------------------------------------------------------------------
CREATE POLICY "ps_superadmin_all" ON parent_student
    FOR ALL TO authenticated
    USING (rls_is_superadmin())
    WITH CHECK (rls_is_superadmin());

-- -----------------------------------------------------------------------------
-- Policy 2: BigAdmin (Principal) - Full access for students in their school
-- Uses rls_student_in_school() to check without direct profiles query
-- -----------------------------------------------------------------------------
CREATE POLICY "ps_bigadmin_all" ON parent_student
    FOR ALL TO authenticated
    USING (
        rls_is_bigadmin()
        AND rls_student_in_school(student_id)
    )
    WITH CHECK (
        rls_is_bigadmin()
        AND rls_student_in_school(student_id)
    );

-- -----------------------------------------------------------------------------
-- Policy 3: Admin - Full access for students in their school
-- -----------------------------------------------------------------------------
CREATE POLICY "ps_admin_all" ON parent_student
    FOR ALL TO authenticated
    USING (
        rls_is_admin()
        AND rls_student_in_school(student_id)
    )
    WITH CHECK (
        rls_is_admin()
        AND rls_student_in_school(student_id)
    );

-- -----------------------------------------------------------------------------
-- Policy 4: Parent - SELECT their own links
-- Uses only auth.uid() - no recursion possible
-- -----------------------------------------------------------------------------
CREATE POLICY "ps_parent_select_own" ON parent_student
    FOR SELECT TO authenticated
    USING (parent_id = auth.uid());

-- -----------------------------------------------------------------------------
-- Policy 5: Parent - INSERT their own link
-- This allows a parent to insert a record where they are the parent
-- Only uses auth.uid() and rls_is_parent() - safe from recursion
-- -----------------------------------------------------------------------------
CREATE POLICY "ps_parent_insert_own" ON parent_student
    FOR INSERT TO authenticated
    WITH CHECK (
        parent_id = auth.uid()
        AND rls_is_parent()
    );

-- -----------------------------------------------------------------------------
-- Policy 6: Student - SELECT links involving themselves
-- Uses only auth.uid() - no recursion possible
-- -----------------------------------------------------------------------------
CREATE POLICY "ps_student_select_own" ON parent_student
    FOR SELECT TO authenticated
    USING (student_id = auth.uid());

-- -----------------------------------------------------------------------------
-- Policy 7: Teacher - SELECT links for students in their classes
-- Uses rls_* helper functions - safe from recursion
-- -----------------------------------------------------------------------------
CREATE POLICY "ps_teacher_select_class_students" ON parent_student
    FOR SELECT TO authenticated
    USING (
        rls_is_teacher()
        AND rls_student_in_my_class(student_id)
    );

-- =============================================================================
-- STEP 4: Fix profiles policies that query parent_student
-- The policy "profiles_select_parent_children" directly queries parent_student,
-- which can cause recursion when parent_student policies query profiles.
-- We replace it with a policy that uses the rls_is_my_child() helper function.
-- =============================================================================

-- Drop the problematic profiles policy that queries parent_student
DROP POLICY IF EXISTS "profiles_select_parent_children" ON profiles;

-- Recreate it using the helper function that bypasses RLS
CREATE POLICY "profiles_select_parent_children" ON profiles
    FOR SELECT TO authenticated
    USING (
        rls_is_parent()
        AND rls_is_my_child(id)
    );

COMMENT ON POLICY "profiles_select_parent_children" ON profiles IS
'Parents can view their children profiles - uses rls_is_my_child() to avoid recursion';

-- =============================================================================
-- STEP 5: Verification
-- =============================================================================

DO $$
DECLARE
    pol RECORD;
    pol_count INT;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'PARENT-STUDENT RLS RECURSION FIX COMPLETE';
    RAISE NOTICE '==============================================';

    -- Count policies
    SELECT COUNT(*) INTO pol_count
    FROM pg_policies
    WHERE tablename = 'parent_student' AND schemaname = 'public';

    RAISE NOTICE 'Total parent_student policies: %', pol_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Policies created:';

    FOR pol IN
        SELECT policyname, cmd
        FROM pg_policies
        WHERE tablename = 'parent_student' AND schemaname = 'public'
        ORDER BY policyname
    LOOP
        RAISE NOTICE '  - % (%)', pol.policyname, pol.cmd;
    END LOOP;

    RAISE NOTICE '';
    RAISE NOTICE 'Helper functions created/used (all SECURITY DEFINER with row_security=off):';
    RAISE NOTICE '  - rls_is_superadmin()';
    RAISE NOTICE '  - rls_is_bigadmin()';
    RAISE NOTICE '  - rls_is_admin()';
    RAISE NOTICE '  - rls_is_parent() [NEW]';
    RAISE NOTICE '  - rls_is_student() [NEW]';
    RAISE NOTICE '  - rls_is_teacher()';
    RAISE NOTICE '  - rls_student_in_school(UUID) [NEW]';
    RAISE NOTICE '  - rls_student_in_my_class(UUID) [NEW]';
    RAISE NOTICE '  - rls_is_my_child(UUID) [NEW]';
    RAISE NOTICE '';
    RAISE NOTICE 'Also fixed profiles policy:';
    RAISE NOTICE '  - profiles_select_parent_children (now uses rls_is_my_child)';
    RAISE NOTICE '==============================================';
END $$;

-- =============================================================================
-- END OF MIGRATION
-- =============================================================================
