-- ============================================================================
-- MIGRATION: Fix invite_tokens for SuperAdmin Bootstrap
-- Version: 20260111210000
-- Description: Makes school_id and created_by_user_id nullable to allow
--              genesis/bootstrap tokens for the first SuperAdmin registration
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Step 1: Make school_id nullable
-- This allows SuperAdmin tokens that are not associated with any school
-- -----------------------------------------------------------------------------
ALTER TABLE invite_tokens
  ALTER COLUMN school_id DROP NOT NULL;

-- -----------------------------------------------------------------------------
-- Step 2: Make created_by_user_id nullable
-- This allows bootstrap tokens created before any users exist in the system
-- -----------------------------------------------------------------------------
ALTER TABLE invite_tokens
  ALTER COLUMN created_by_user_id DROP NOT NULL;

-- -----------------------------------------------------------------------------
-- Step 3: Add explanatory comments
-- -----------------------------------------------------------------------------
COMMENT ON COLUMN invite_tokens.school_id IS
  'NULL for superadmin genesis tokens, required for school-specific roles';

COMMENT ON COLUMN invite_tokens.created_by_user_id IS
  'NULL for bootstrap tokens created before any users exist';

-- -----------------------------------------------------------------------------
-- Step 4: Insert a SECURE bootstrap token for first SuperAdmin registration
--
-- SECURITY NOTE: This token is auto-generated using cryptographically secure
-- random bytes. The token expires in 7 days for security.
--
-- DEPLOYMENT INSTRUCTIONS:
-- 1. After running this migration, query the token:
--    SELECT token, expires_at FROM invite_tokens WHERE role = 'superadmin' AND is_used = false;
-- 2. Use this token to register the first superadmin within 7 days
-- 3. After registration, the token will be marked as used automatically
-- 4. For additional superadmin tokens, use the admin panel
--
-- DO NOT hardcode tokens in migrations for production deployments!
-- -----------------------------------------------------------------------------

-- Generate a secure random bootstrap token
DO $$
DECLARE
    bootstrap_token TEXT;
    token_expiry TIMESTAMPTZ;
BEGIN
    -- Generate a cryptographically secure random token (32 bytes = 64 hex chars)
    -- Uses gen_random_bytes which is provided by pgcrypto extension
    bootstrap_token := 'BOOTSTRAP-' || encode(gen_random_bytes(16), 'hex');

    -- Token expires in 7 days for security
    token_expiry := NOW() + INTERVAL '7 days';

    -- Insert or update the bootstrap token
    INSERT INTO invite_tokens (token, role, school_id, created_by_user_id, is_used, expires_at)
    VALUES (bootstrap_token, 'superadmin', NULL, NULL, false, token_expiry)
    ON CONFLICT (token) DO UPDATE SET
        is_used = false,
        expires_at = token_expiry;

    -- Log the token for retrieval (visible in migration output)
    RAISE NOTICE '';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'BOOTSTRAP TOKEN CREATED';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Token: %', bootstrap_token;
    RAISE NOTICE 'Expires: %', token_expiry;
    RAISE NOTICE '';
    RAISE NOTICE 'Use this token to register the first SuperAdmin.';
    RAISE NOTICE 'Query to retrieve: SELECT token FROM invite_tokens WHERE role = ''superadmin'' AND is_used = false;';
    RAISE NOTICE '============================================';
END $$;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
