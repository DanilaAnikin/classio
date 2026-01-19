-- ============================================================================
-- MIGRATION: Secure Genesis Token Bootstrap System
-- Version: 20260118000001
--
-- SECURITY FIX: Replaces hardcoded GENESIS-KEY with secure token generation
--
-- This migration:
-- 1. Removes any existing hardcoded genesis tokens (GENESIS-KEY)
-- 2. Creates a secure function to generate bootstrap tokens on-demand
-- 3. Adds logging for audit purposes
-- 4. Implements safeguards to prevent misuse
--
-- IMPORTANT: Bootstrap tokens should NEVER be hardcoded in migrations.
-- Always generate them via the secure function through a protected channel.
-- ============================================================================

-- ============================================================================
-- STEP 1: Create audit log table for genesis token generation events
-- ============================================================================
CREATE TABLE IF NOT EXISTS genesis_token_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type TEXT NOT NULL,
  token_prefix TEXT, -- Only store first 8 chars for audit (never full token)
  generated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ,
  ip_address INET,
  user_agent TEXT,
  notes TEXT
);

-- Secure the audit log - only postgres/service_role can access
ALTER TABLE genesis_token_audit_log ENABLE ROW LEVEL SECURITY;

-- No RLS policies = no access via API (only direct DB access)
COMMENT ON TABLE genesis_token_audit_log IS
  'Audit log for genesis token generation. Only accessible via direct DB connection.';

-- ============================================================================
-- STEP 2: Remove any existing hardcoded GENESIS-KEY tokens
-- ============================================================================
DELETE FROM invite_tokens WHERE token = 'GENESIS-KEY';

-- Also remove any obviously hardcoded tokens (common patterns)
DELETE FROM invite_tokens
WHERE token IN (
  'GENESIS-KEY',
  'GENESIS_KEY',
  'genesis-key',
  'SUPERADMIN',
  'ADMIN',
  'admin',
  'TEST',
  'test'
)
AND role = 'superadmin';

-- ============================================================================
-- STEP 3: Create the secure genesis token generation function
-- ============================================================================
CREATE OR REPLACE FUNCTION generate_genesis_token(
  p_expires_in_hours INTEGER DEFAULT 24
)
RETURNS TABLE (
  token TEXT,
  expires_at TIMESTAMPTZ,
  instructions TEXT
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_token TEXT;
  v_expires_at TIMESTAMPTZ;
  v_superadmin_count INTEGER;
  v_unused_bootstrap_count INTEGER;
BEGIN
  -- ========================================================================
  -- SECURITY CHECK 1: Verify no superadmin exists yet
  -- ========================================================================
  SELECT COUNT(*) INTO v_superadmin_count
  FROM profiles
  WHERE role = 'superadmin';

  IF v_superadmin_count > 0 THEN
    RAISE EXCEPTION 'SECURITY: Cannot generate genesis token - % superadmin(s) already exist. Use standard invite flow instead.', v_superadmin_count
      USING ERRCODE = 'P0010';
  END IF;

  -- ========================================================================
  -- SECURITY CHECK 2: No unused bootstrap tokens should exist
  -- ========================================================================
  SELECT COUNT(*) INTO v_unused_bootstrap_count
  FROM invite_tokens it
  WHERE it.role = 'superadmin'
    AND it.school_id IS NULL
    AND it.is_used = false
    AND (it.expires_at IS NULL OR it.expires_at > now());

  IF v_unused_bootstrap_count > 0 THEN
    -- Invalidate old unused tokens before creating new one
    UPDATE invite_tokens it
    SET expires_at = now() - interval '1 second'
    WHERE it.role = 'superadmin'
      AND it.school_id IS NULL
      AND it.is_used = false;

    -- Log this event
    INSERT INTO genesis_token_audit_log (event_type, notes)
    VALUES ('INVALIDATED_EXISTING', format('Invalidated %s unused bootstrap token(s)', v_unused_bootstrap_count));
  END IF;

  -- ========================================================================
  -- VALIDATION: Expiration must be reasonable (1-168 hours / 1 week max)
  -- ========================================================================
  IF p_expires_in_hours < 1 OR p_expires_in_hours > 168 THEN
    RAISE EXCEPTION 'Expiration must be between 1 and 168 hours (1 week). Got: %', p_expires_in_hours
      USING ERRCODE = 'P0011';
  END IF;

  -- ========================================================================
  -- Generate cryptographically random token
  -- Format: GEN-XXXX-XXXX-XXXX (16 random chars from UUID)
  -- ========================================================================
  v_token := 'GEN-' ||
    UPPER(SUBSTRING(REPLACE(gen_random_uuid()::TEXT, '-', '') FROM 1 FOR 4)) || '-' ||
    UPPER(SUBSTRING(REPLACE(gen_random_uuid()::TEXT, '-', '') FROM 1 FOR 4)) || '-' ||
    UPPER(SUBSTRING(REPLACE(gen_random_uuid()::TEXT, '-', '') FROM 1 FOR 4));

  v_expires_at := now() + (p_expires_in_hours || ' hours')::INTERVAL;

  -- ========================================================================
  -- Insert the token
  -- ========================================================================
  INSERT INTO invite_tokens (
    token,
    role,
    school_id,
    created_by_user_id,
    specific_class_id,
    is_used,
    expires_at,
    created_at
  )
  VALUES (
    v_token,
    'superadmin',
    NULL,  -- No school for superadmin
    NULL,  -- No creator (bootstrap)
    NULL,  -- No class
    false,
    v_expires_at,
    now()
  );

  -- ========================================================================
  -- Log the generation event (only token prefix for security)
  -- ========================================================================
  INSERT INTO genesis_token_audit_log (
    event_type,
    token_prefix,
    expires_at,
    notes
  )
  VALUES (
    'GENERATED',
    SUBSTRING(v_token FROM 1 FOR 8),
    v_expires_at,
    format('Token expires in %s hours', p_expires_in_hours)
  );

  -- ========================================================================
  -- Return result with instructions
  -- ========================================================================
  RETURN QUERY SELECT
    v_token,
    v_expires_at,
    format(
      E'GENESIS TOKEN GENERATED SUCCESSFULLY\n' ||
      E'=====================================\n' ||
      E'Token: %s\n' ||
      E'Expires: %s\n' ||
      E'Hours until expiry: %s\n\n' ||
      E'INSTRUCTIONS:\n' ||
      E'1. Use this token as the invite code during registration\n' ||
      E'2. Register as the first superadmin user\n' ||
      E'3. This token can only be used ONCE\n' ||
      E'4. DO NOT share this token or store it anywhere\n' ||
      E'5. After use, generate new tokens for other admins via the app\n\n' ||
      E'SECURITY NOTICE:\n' ||
      E'This token grants SUPERADMIN access to the entire system.\n' ||
      E'Keep it secure and use it immediately.',
      v_token,
      v_expires_at,
      p_expires_in_hours
    );
END;
$$;

-- Only postgres and service_role can execute this function
REVOKE EXECUTE ON FUNCTION generate_genesis_token(INTEGER) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION generate_genesis_token(INTEGER) FROM anon;
REVOKE EXECUTE ON FUNCTION generate_genesis_token(INTEGER) FROM authenticated;
GRANT EXECUTE ON FUNCTION generate_genesis_token(INTEGER) TO postgres;
GRANT EXECUTE ON FUNCTION generate_genesis_token(INTEGER) TO service_role;

COMMENT ON FUNCTION generate_genesis_token(INTEGER) IS
  'Securely generates a bootstrap token for the first superadmin. '
  'Can only be called when NO superadmin exists. '
  'Token expires in specified hours (default 24, max 168). '
  'Must be called via direct DB connection (Supabase Dashboard, psql, etc).';

-- ============================================================================
-- STEP 4: Create function to check bootstrap status
-- ============================================================================
CREATE OR REPLACE FUNCTION check_bootstrap_status()
RETURNS TABLE (
  needs_bootstrap BOOLEAN,
  superadmin_count INTEGER,
  pending_bootstrap_tokens INTEGER,
  message TEXT
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_superadmin_count INTEGER;
  v_pending_tokens INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_superadmin_count
  FROM profiles
  WHERE role = 'superadmin';

  SELECT COUNT(*) INTO v_pending_tokens
  FROM invite_tokens it
  WHERE it.role = 'superadmin'
    AND it.school_id IS NULL
    AND it.is_used = false
    AND (it.expires_at IS NULL OR it.expires_at > now());

  RETURN QUERY SELECT
    v_superadmin_count = 0,
    v_superadmin_count,
    v_pending_tokens,
    CASE
      WHEN v_superadmin_count > 0 THEN
        format('System has %s superadmin(s). No bootstrap needed.', v_superadmin_count)
      WHEN v_pending_tokens > 0 THEN
        format('Bootstrap token exists. %s pending token(s) available.', v_pending_tokens)
      ELSE
        'System needs bootstrap. Run: SELECT * FROM generate_genesis_token();'
    END;
END;
$$;

-- This function can be called by service_role to check status
REVOKE EXECUTE ON FUNCTION check_bootstrap_status() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION check_bootstrap_status() FROM anon;
GRANT EXECUTE ON FUNCTION check_bootstrap_status() TO authenticated;
GRANT EXECUTE ON FUNCTION check_bootstrap_status() TO postgres;
GRANT EXECUTE ON FUNCTION check_bootstrap_status() TO service_role;

COMMENT ON FUNCTION check_bootstrap_status() IS
  'Check if the system needs bootstrap (first superadmin creation).';

-- ============================================================================
-- STEP 5: Create constraint to prevent hardcoded tokens in future
-- ============================================================================
CREATE OR REPLACE FUNCTION check_token_not_hardcoded()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_forbidden_patterns TEXT[] := ARRAY[
    'GENESIS-KEY', 'GENESIS_KEY', 'genesis-key', 'genesis_key',
    'SUPERADMIN', 'superadmin', 'ADMIN', 'admin',
    'TEST', 'test', 'PASSWORD', 'password',
    'SECRET', 'secret', '123456', 'qwerty'
  ];
BEGIN
  -- Check if token matches any forbidden patterns
  IF NEW.token = ANY(v_forbidden_patterns) THEN
    RAISE EXCEPTION 'SECURITY: Token value "%" is forbidden. Use generate_genesis_token() for bootstrap tokens.', NEW.token
      USING ERRCODE = 'P0012';
  END IF;

  -- Check if token is too short (potential hardcoded value)
  IF NEW.role = 'superadmin' AND LENGTH(NEW.token) < 10 THEN
    RAISE EXCEPTION 'SECURITY: Superadmin tokens must be at least 10 characters. Use generate_genesis_token() for secure tokens.'
      USING ERRCODE = 'P0013';
  END IF;

  RETURN NEW;
END;
$$;

-- Create trigger to enforce the check
DROP TRIGGER IF EXISTS prevent_hardcoded_tokens ON invite_tokens;
CREATE TRIGGER prevent_hardcoded_tokens
  BEFORE INSERT OR UPDATE ON invite_tokens
  FOR EACH ROW
  EXECUTE FUNCTION check_token_not_hardcoded();

COMMENT ON FUNCTION check_token_not_hardcoded() IS
  'Prevents insertion of known hardcoded or weak token values.';

-- ============================================================================
-- STEP 6: Grant necessary permissions
-- ============================================================================
GRANT ALL ON genesis_token_audit_log TO postgres;
GRANT ALL ON genesis_token_audit_log TO service_role;

-- ============================================================================
-- DOCUMENTATION
-- ============================================================================
/*
SECURE BOOTSTRAP PROCESS
========================

To initialize a fresh Classio installation with the first superadmin:

1. CONNECT TO DATABASE
   - Use Supabase Dashboard SQL Editor, OR
   - Use psql with your database connection string, OR
   - Use any PostgreSQL client with admin credentials

2. CHECK BOOTSTRAP STATUS (optional)
   SELECT * FROM check_bootstrap_status();

   This shows if bootstrap is needed and any pending tokens.

3. GENERATE BOOTSTRAP TOKEN
   SELECT * FROM generate_genesis_token();

   Or with custom expiration (hours):
   SELECT * FROM generate_genesis_token(48);  -- 48 hours

   This will:
   - Verify no superadmin exists
   - Generate a cryptographically random token
   - Set expiration (default 24 hours)
   - Log the generation event
   - Return the token with instructions

4. REGISTER FIRST SUPERADMIN
   - Go to the Classio app registration page
   - Enter the generated token as the invite code
   - Complete registration
   - The token is automatically marked as used

5. DONE
   The first superadmin can now:
   - Create schools
   - Generate invite tokens for principals
   - Manage the entire platform

SECURITY NOTES
==============
- Tokens are NEVER stored in migration files
- Each token can only be used once
- Tokens expire (default 24 hours, max 7 days)
- All token generations are logged
- Function can only be called by postgres/service_role
- Hardcoded tokens are blocked by trigger
- Only works when NO superadmin exists
*/

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
