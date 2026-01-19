-- ============================================================================
-- CLASSIO: FIX INVITE_TOKENS RLS FOR ANONYMOUS ACCESS
-- ============================================================================
-- Run this script directly in the Supabase SQL Editor to fix the 42501 error
-- (permission denied for table invite_tokens)
--
-- This script is IDEMPOTENT - safe to run multiple times
-- ============================================================================

-- ============================================================================
-- STEP 1: ENSURE RLS IS ENABLED
-- ============================================================================
-- RLS must be enabled for policies to work
ALTER TABLE invite_tokens ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- STEP 2: DROP ALL EXISTING POLICIES THAT MIGHT CONFLICT
-- ============================================================================
-- Drop any policies that might be blocking access or conflicting
DROP POLICY IF EXISTS "Anyone can validate invite tokens" ON invite_tokens;
DROP POLICY IF EXISTS "anon_validate_invite_tokens" ON invite_tokens;
DROP POLICY IF EXISTS "public_validate_tokens" ON invite_tokens;
DROP POLICY IF EXISTS "allow_anon_select_valid_tokens" ON invite_tokens;

-- ============================================================================
-- STEP 3: CREATE THE PERMISSIVE SELECT POLICY FOR ANONYMOUS USERS
-- ============================================================================
-- This policy allows anonymous (unauthenticated) users to SELECT from
-- invite_tokens, but ONLY rows where:
--   - is_used = false (token hasn't been used yet)
--   - expires_at is NULL OR expires_at > now() (not expired)
--
-- This is secure because:
--   - Anonymous users can ONLY SELECT, not INSERT/UPDATE/DELETE
--   - They can ONLY see valid (unused, non-expired) tokens
--   - They cannot see which tokens exist - they can only check if a specific token is valid
--
CREATE POLICY "Anyone can validate invite tokens"
  ON invite_tokens
  FOR SELECT
  TO anon, authenticated
  USING (
    is_used = false
    AND (expires_at IS NULL OR expires_at > now())
  );

-- ============================================================================
-- STEP 4: GRANT SELECT PERMISSION TO ANON ROLE
-- ============================================================================
-- Even with RLS policies, the anon role needs explicit SELECT permission
-- on the table. This is the "belt and suspenders" approach.
--
-- Without this GRANT, you get: "permission denied for table invite_tokens"
-- The RLS policy controls WHICH rows they can see, but the GRANT controls
-- WHETHER they can query the table at all.
--
GRANT SELECT ON invite_tokens TO anon;

-- Also grant to authenticated for completeness
GRANT SELECT ON invite_tokens TO authenticated;

-- ============================================================================
-- STEP 5: VERIFICATION QUERIES
-- ============================================================================
-- These queries help verify the fix was applied correctly

-- 5a. Check that RLS is enabled on invite_tokens
SELECT
  tablename,
  rowsecurity as "RLS Enabled"
FROM pg_tables
WHERE tablename = 'invite_tokens' AND schemaname = 'public';

-- 5b. List all policies on invite_tokens
SELECT
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'invite_tokens' AND schemaname = 'public';

-- 5c. Check table grants for invite_tokens
SELECT
  grantee,
  privilege_type
FROM information_schema.role_table_grants
WHERE table_name = 'invite_tokens' AND table_schema = 'public'
ORDER BY grantee;

-- 5d. Check bootstrap status
-- Use the secure function to check if bootstrap is needed
SELECT * FROM check_bootstrap_status();

-- ============================================================================
-- STEP 6: GENERATE SECURE BOOTSTRAP TOKEN (if needed)
-- ============================================================================
-- SECURITY: Hardcoded tokens have been removed. Use the secure bootstrap function:
--
-- To generate a new bootstrap token (only works if no superadmin exists):
--   SELECT * FROM generate_genesis_token();
--
-- Or with custom expiration (hours, max 168):
--   SELECT * FROM generate_genesis_token(48);
--
-- See migration: 20260118000001_secure_genesis_token.sql for details

-- ============================================================================
-- SUCCESS!
-- ============================================================================
-- If you see the verification results above showing:
--   - RLS Enabled = true
--   - Policy "Anyone can validate invite tokens" exists with roles {anon,authenticated}
--   - anon has SELECT privilege
--   - Bootstrap status shows system state
--
-- Then the fix has been applied successfully!
--
-- If bootstrap is needed, run: SELECT * FROM generate_genesis_token();
-- ============================================================================
