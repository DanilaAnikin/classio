-- ============================================================================
-- MIGRATION: Fix Principal (bigadmin) RLS Policies for invite_tokens and classes
-- Version: 20260113300000
--
-- PROBLEM 1: "Failed to generate invite code: new row violates row-level
--             security policy for table invite_tokens"
-- When principal tries to invite students, the policy fails because the
-- existing policies call get_user_role() and get_user_school_id() which
-- may trigger recursion or fail during policy evaluation.
--
-- PROBLEM 2: "Failed to create class: new row violates row-level security
--             policy for table classes"
-- Same issue - the policies use helper functions that can cause issues
-- during RLS policy evaluation.
--
-- ROOT CAUSE:
-- The existing policies use get_user_role() and get_user_school_id() which
-- query the profiles table. Even with SECURITY DEFINER, these can fail
-- during INSERT policy evaluation (WITH CHECK) because PostgreSQL evaluates
-- the policy before the helper function's row_security=off takes effect.
--
-- SOLUTION:
-- 1. Create dedicated SECURITY DEFINER helper functions specifically for
--    RLS policy use, with proper SET row_security = off
-- 2. Drop all existing INSERT policies on both tables
-- 3. Create new, simpler policies using these dedicated helper functions
-- ============================================================================

-- =============================================================================
-- STEP 1: Create dedicated RLS helper functions with SECURITY DEFINER
-- These functions are designed to be called ONLY from RLS policies
-- They must have SET row_security = off to prevent recursion
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1.1 Helper function to get current user's role (for RLS use)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rls_get_user_role()
RETURNS user_role
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
    RETURN _role;
END;
$$;

COMMENT ON FUNCTION rls_get_user_role IS 'SECURITY DEFINER function to get user role for RLS policies. Bypasses RLS.';

-- -----------------------------------------------------------------------------
-- 1.2 Helper function to get current user's school_id (for RLS use)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rls_get_user_school_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
DECLARE
    _school_id UUID;
BEGIN
    SELECT school_id INTO _school_id FROM profiles WHERE id = auth.uid();
    RETURN _school_id;
END;
$$;

COMMENT ON FUNCTION rls_get_user_school_id IS 'SECURITY DEFINER function to get user school_id for RLS policies. Bypasses RLS.';

-- -----------------------------------------------------------------------------
-- 1.3 Helper function to check if current user is bigadmin (principal)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rls_is_bigadmin()
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
    RETURN _role = 'bigadmin';
END;
$$;

COMMENT ON FUNCTION rls_is_bigadmin IS 'SECURITY DEFINER function to check if user is bigadmin for RLS policies. Bypasses RLS.';

-- -----------------------------------------------------------------------------
-- 1.4 Helper function to check if current user is admin
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rls_is_admin()
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
    RETURN _role = 'admin';
END;
$$;

COMMENT ON FUNCTION rls_is_admin IS 'SECURITY DEFINER function to check if user is admin for RLS policies. Bypasses RLS.';

-- -----------------------------------------------------------------------------
-- 1.5 Helper function to check if current user is superadmin
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rls_is_superadmin()
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
    RETURN _role = 'superadmin';
END;
$$;

COMMENT ON FUNCTION rls_is_superadmin IS 'SECURITY DEFINER function to check if user is superadmin for RLS policies. Bypasses RLS.';

-- -----------------------------------------------------------------------------
-- 1.6 Helper function to check if current user is teacher
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rls_is_teacher()
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
    RETURN _role = 'teacher';
END;
$$;

COMMENT ON FUNCTION rls_is_teacher IS 'SECURITY DEFINER function to check if user is teacher for RLS policies. Bypasses RLS.';

-- -----------------------------------------------------------------------------
-- 1.7 Helper function to check if current user is school admin (bigadmin OR admin)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rls_is_school_admin()
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
    RETURN _role IN ('bigadmin', 'admin');
END;
$$;

COMMENT ON FUNCTION rls_is_school_admin IS 'SECURITY DEFINER function to check if user is bigadmin or admin for RLS policies. Bypasses RLS.';

-- -----------------------------------------------------------------------------
-- 1.8 Helper function to check if teacher teaches a specific class
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rls_teaches_class(p_class_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM subjects
        WHERE class_id = p_class_id AND teacher_id = auth.uid()
    );
END;
$$;

COMMENT ON FUNCTION rls_teaches_class IS 'SECURITY DEFINER function to check if user teaches a class for RLS policies. Bypasses RLS.';

-- =============================================================================
-- STEP 2: Grant execute permissions on helper functions
-- =============================================================================

GRANT EXECUTE ON FUNCTION rls_get_user_role() TO authenticated;
GRANT EXECUTE ON FUNCTION rls_get_user_school_id() TO authenticated;
GRANT EXECUTE ON FUNCTION rls_is_bigadmin() TO authenticated;
GRANT EXECUTE ON FUNCTION rls_is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION rls_is_superadmin() TO authenticated;
GRANT EXECUTE ON FUNCTION rls_is_teacher() TO authenticated;
GRANT EXECUTE ON FUNCTION rls_is_school_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION rls_teaches_class(UUID) TO authenticated;

-- =============================================================================
-- STEP 3: Fix invite_tokens INSERT policies
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 3.1 Drop ALL existing INSERT policies on invite_tokens
-- -----------------------------------------------------------------------------
DROP POLICY IF EXISTS "bigadmin_insert_tokens" ON invite_tokens;
DROP POLICY IF EXISTS "admin_insert_tokens" ON invite_tokens;
DROP POLICY IF EXISTS "teacher_insert_tokens" ON invite_tokens;
DROP POLICY IF EXISTS "superadmin_all_invite_tokens" ON invite_tokens;

-- Also drop SELECT policies that we'll recreate
DROP POLICY IF EXISTS "bigadmin_select_tokens" ON invite_tokens;
DROP POLICY IF EXISTS "admin_select_tokens" ON invite_tokens;
DROP POLICY IF EXISTS "teacher_select_tokens" ON invite_tokens;
DROP POLICY IF EXISTS "Anyone can validate invite tokens" ON invite_tokens;

-- -----------------------------------------------------------------------------
-- 3.2 Create new superadmin policy (full access)
-- -----------------------------------------------------------------------------
CREATE POLICY "invite_tokens_superadmin_all" ON invite_tokens
    FOR ALL
    TO authenticated
    USING (rls_is_superadmin())
    WITH CHECK (rls_is_superadmin());

-- -----------------------------------------------------------------------------
-- 3.3 Create new bigadmin (principal) INSERT policy
-- Principal can create tokens for ANY role EXCEPT superadmin
-- -----------------------------------------------------------------------------
CREATE POLICY "invite_tokens_bigadmin_insert" ON invite_tokens
    FOR INSERT
    TO authenticated
    WITH CHECK (
        rls_is_bigadmin()
        AND school_id = rls_get_user_school_id()
        AND role != 'superadmin'
    );

-- -----------------------------------------------------------------------------
-- 3.4 Create bigadmin SELECT policy
-- -----------------------------------------------------------------------------
CREATE POLICY "invite_tokens_bigadmin_select" ON invite_tokens
    FOR SELECT
    TO authenticated
    USING (
        rls_is_bigadmin()
        AND school_id = rls_get_user_school_id()
    );

-- -----------------------------------------------------------------------------
-- 3.5 Create new admin INSERT policy
-- Admin can create tokens for teacher, student, parent roles
-- -----------------------------------------------------------------------------
CREATE POLICY "invite_tokens_admin_insert" ON invite_tokens
    FOR INSERT
    TO authenticated
    WITH CHECK (
        rls_is_admin()
        AND school_id = rls_get_user_school_id()
        AND role IN ('teacher', 'student', 'parent')
    );

-- -----------------------------------------------------------------------------
-- 3.6 Create admin SELECT policy
-- -----------------------------------------------------------------------------
CREATE POLICY "invite_tokens_admin_select" ON invite_tokens
    FOR SELECT
    TO authenticated
    USING (
        rls_is_admin()
        AND school_id = rls_get_user_school_id()
    );

-- -----------------------------------------------------------------------------
-- 3.7 Create new teacher INSERT policy
-- Teacher can create tokens for student role with specific_class_id they teach
-- -----------------------------------------------------------------------------
CREATE POLICY "invite_tokens_teacher_insert" ON invite_tokens
    FOR INSERT
    TO authenticated
    WITH CHECK (
        rls_is_teacher()
        AND school_id = rls_get_user_school_id()
        AND role = 'student'
        AND specific_class_id IS NOT NULL
        AND rls_teaches_class(specific_class_id)
    );

-- -----------------------------------------------------------------------------
-- 3.8 Create teacher SELECT policy
-- -----------------------------------------------------------------------------
CREATE POLICY "invite_tokens_teacher_select" ON invite_tokens
    FOR SELECT
    TO authenticated
    USING (
        rls_is_teacher()
        AND school_id = rls_get_user_school_id()
        AND created_by_user_id = auth.uid()
    );

-- -----------------------------------------------------------------------------
-- 3.9 Anyone can validate unused, non-expired invite tokens during registration
-- -----------------------------------------------------------------------------
CREATE POLICY "invite_tokens_validate" ON invite_tokens
    FOR SELECT
    TO anon, authenticated
    USING (
        is_used = false
        AND (expires_at IS NULL OR expires_at > now())
    );

-- =============================================================================
-- STEP 4: Fix classes INSERT policies
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 4.1 Drop ALL existing policies on classes table
-- -----------------------------------------------------------------------------
DROP POLICY IF EXISTS "superadmin_all_classes" ON classes;
DROP POLICY IF EXISTS "bigadmin_all_own_school_classes" ON classes;
DROP POLICY IF EXISTS "admin_select_own_school_classes" ON classes;
DROP POLICY IF EXISTS "admin_insert_own_school_classes" ON classes;
DROP POLICY IF EXISTS "admin_update_own_school_classes" ON classes;
DROP POLICY IF EXISTS "teacher_select_own_classes" ON classes;
DROP POLICY IF EXISTS "student_select_enrolled_classes" ON classes;
DROP POLICY IF EXISTS "parent_select_children_classes" ON classes;

-- -----------------------------------------------------------------------------
-- 4.2 Create new superadmin policy (full access)
-- -----------------------------------------------------------------------------
CREATE POLICY "classes_superadmin_all" ON classes
    FOR ALL
    TO authenticated
    USING (rls_is_superadmin())
    WITH CHECK (rls_is_superadmin());

-- -----------------------------------------------------------------------------
-- 4.3 Create new bigadmin (principal) policy - full access within own school
-- -----------------------------------------------------------------------------
CREATE POLICY "classes_bigadmin_all" ON classes
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
-- 4.4 Create admin SELECT policy
-- -----------------------------------------------------------------------------
CREATE POLICY "classes_admin_select" ON classes
    FOR SELECT
    TO authenticated
    USING (
        rls_is_admin()
        AND school_id = rls_get_user_school_id()
    );

-- -----------------------------------------------------------------------------
-- 4.5 Create admin INSERT policy
-- -----------------------------------------------------------------------------
CREATE POLICY "classes_admin_insert" ON classes
    FOR INSERT
    TO authenticated
    WITH CHECK (
        rls_is_admin()
        AND school_id = rls_get_user_school_id()
    );

-- -----------------------------------------------------------------------------
-- 4.6 Create admin UPDATE policy
-- -----------------------------------------------------------------------------
CREATE POLICY "classes_admin_update" ON classes
    FOR UPDATE
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
-- 4.7 Create teacher SELECT policy (classes they teach)
-- -----------------------------------------------------------------------------
CREATE POLICY "classes_teacher_select" ON classes
    FOR SELECT
    TO authenticated
    USING (
        rls_is_teacher()
        AND rls_teaches_class(id)
    );

-- -----------------------------------------------------------------------------
-- 4.8 Create student SELECT policy (enrolled classes)
-- -----------------------------------------------------------------------------
CREATE POLICY "classes_student_select" ON classes
    FOR SELECT
    TO authenticated
    USING (
        rls_get_user_role() = 'student'
        AND EXISTS (
            SELECT 1 FROM class_students
            WHERE class_id = classes.id AND student_id = auth.uid()
        )
    );

-- -----------------------------------------------------------------------------
-- 4.9 Create parent SELECT policy (children's classes)
-- -----------------------------------------------------------------------------
CREATE POLICY "classes_parent_select" ON classes
    FOR SELECT
    TO authenticated
    USING (
        rls_get_user_role() = 'parent'
        AND EXISTS (
            SELECT 1 FROM class_students cs
            JOIN parent_student ps ON cs.student_id = ps.student_id
            WHERE cs.class_id = classes.id AND ps.parent_id = auth.uid()
        )
    );

-- =============================================================================
-- STEP 5: Verification - List current policies
-- =============================================================================

DO $$
DECLARE
    pol RECORD;
BEGIN
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Current invite_tokens policies:';
    RAISE NOTICE '===========================================';
    FOR pol IN
        SELECT policyname, cmd, permissive
        FROM pg_policies
        WHERE tablename = 'invite_tokens' AND schemaname = 'public'
        ORDER BY policyname
    LOOP
        RAISE NOTICE '  - % (%)', pol.policyname, pol.cmd;
    END LOOP;

    RAISE NOTICE '';
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Current classes policies:';
    RAISE NOTICE '===========================================';
    FOR pol IN
        SELECT policyname, cmd, permissive
        FROM pg_policies
        WHERE tablename = 'classes' AND schemaname = 'public'
        ORDER BY policyname
    LOOP
        RAISE NOTICE '  - % (%)', pol.policyname, pol.cmd;
    END LOOP;
    RAISE NOTICE '===========================================';
END $$;

-- =============================================================================
-- END OF MIGRATION
-- =============================================================================
