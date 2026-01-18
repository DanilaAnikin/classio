-- ============================================================================
-- MIGRATION: Add UPDATE policy for invite_tokens table
-- Version: 20260117400000
--
-- PROBLEM: Principal (bigadmin) cannot deactivate invite tokens because there
--          is no UPDATE policy on the invite_tokens table. The existing policies
--          only cover INSERT and SELECT operations.
--
-- SOLUTION: Add UPDATE policies for bigadmin and admin roles to allow them
--           to update invite tokens within their school.
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Step 1: Add UPDATE policy for bigadmin (principal)
-- Principal can update tokens within their own school
-- -----------------------------------------------------------------------------
CREATE POLICY "invite_tokens_bigadmin_update" ON invite_tokens
    FOR UPDATE
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
-- Step 2: Add UPDATE policy for admin
-- Admin can update tokens within their own school
-- -----------------------------------------------------------------------------
CREATE POLICY "invite_tokens_admin_update" ON invite_tokens
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
-- Step 3: Add UPDATE policy for teacher (only their own tokens)
-- Teacher can update tokens they created
-- -----------------------------------------------------------------------------
CREATE POLICY "invite_tokens_teacher_update" ON invite_tokens
    FOR UPDATE
    TO authenticated
    USING (
        rls_is_teacher()
        AND school_id = rls_get_user_school_id()
        AND created_by_user_id = auth.uid()
    )
    WITH CHECK (
        rls_is_teacher()
        AND school_id = rls_get_user_school_id()
        AND created_by_user_id = auth.uid()
    );

-- =============================================================================
-- END OF MIGRATION
-- =============================================================================
