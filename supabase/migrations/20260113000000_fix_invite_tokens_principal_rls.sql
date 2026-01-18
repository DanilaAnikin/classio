-- ============================================================================
-- MIGRATION: Fix invite_tokens RLS for Principal (bigadmin) Role
-- Version: 20260113000000
-- Description: Allows principals (bigadmin) to create invite tokens for ALL
--              user roles within their school, including student and parent
--
-- Problem: The existing bigadmin_insert_tokens policy only allowed creating
--          tokens for 'bigadmin', 'admin', 'teacher' roles, but NOT for
--          'student' or 'parent' roles. This caused the error:
--          "AdminException: Failed to generate invite code: new row violates
--          row-level security policy for table invite_tokens"
--
-- Solution: Drop the existing policy and create a new one that allows
--           bigadmin to create tokens for ALL roles within their school.
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Step 1: Drop the existing restrictive bigadmin insert policy
-- -----------------------------------------------------------------------------
DROP POLICY IF EXISTS "bigadmin_insert_tokens" ON invite_tokens;

-- -----------------------------------------------------------------------------
-- Step 2: Create new policy allowing bigadmin to insert tokens for ALL roles
-- A principal (bigadmin) should be able to invite any type of user to their school
-- -----------------------------------------------------------------------------
CREATE POLICY "bigadmin_insert_tokens" ON invite_tokens
  FOR INSERT
  TO authenticated
  WITH CHECK (
    get_user_role() = 'bigadmin'
    AND school_id = get_user_school_id()
    -- bigadmin can create tokens for any role EXCEPT superadmin
    -- (only superadmins can create superadmin tokens)
    AND role != 'superadmin'
  );

-- -----------------------------------------------------------------------------
-- Step 3: Also update admin policy to allow creating student tokens
-- Admins should be able to invite students as well as teachers and parents
-- -----------------------------------------------------------------------------
DROP POLICY IF EXISTS "admin_insert_tokens" ON invite_tokens;

CREATE POLICY "admin_insert_tokens" ON invite_tokens
  FOR INSERT
  TO authenticated
  WITH CHECK (
    get_user_role() = 'admin'
    AND school_id = get_user_school_id()
    AND role IN ('teacher', 'student', 'parent')
  );

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
