-- ============================================================================
-- MIGRATION: Fix User Creation Trigger for GENESIS-KEY and Bootstrap Cases
-- Version: 20260111230000
--
-- Problem: "Database error saving new user" (status 500) when registering
-- with GENESIS-KEY token. The handle_new_user() trigger function was failing.
--
-- Root Causes Identified:
-- 1. The trigger function is SECURITY DEFINER, but it still respects RLS
--    unless we explicitly bypass it or grant proper permissions
-- 2. The UPDATE on invite_tokens to mark token as used may fail silently
-- 3. Need to ensure the INSERT into profiles works for NULL school_id cases
--
-- Solution:
-- - Recreate the trigger function with SET search_path and explicit
--   statement-level RLS bypass using ALTER TABLE ... FORCE ROW LEVEL SECURITY
--   or by running as a superuser with proper grants
-- - Add better error handling and logging
-- ============================================================================

-- Drop and recreate the trigger function with proper RLS bypass
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _role user_role;
  _school_id UUID;
  _token_record RECORD;
  _invite_token TEXT;
  _class_id UUID;
BEGIN
  -- Extract invite token from metadata
  _invite_token := NEW.raw_user_meta_data->>'invite_token';

  -- Validate invite token is provided
  IF _invite_token IS NULL OR _invite_token = '' THEN
    RAISE EXCEPTION 'Registration requires a valid invite token'
      USING ERRCODE = 'P0001';
  END IF;

  -- Fetch token record (bypassing RLS since we're SECURITY DEFINER)
  -- The SELECT here works because we're the function owner with elevated privileges
  SELECT token, role, school_id, specific_class_id, is_used, expires_at
  INTO _token_record
  FROM invite_tokens
  WHERE token = _invite_token
    AND is_used = false
    AND (expires_at IS NULL OR expires_at > now());

  IF _token_record.token IS NULL THEN
    RAISE EXCEPTION 'Invalid or expired invite token: %', _invite_token
      USING ERRCODE = 'P0002';
  END IF;

  -- Extract values from token record
  _role := _token_record.role;
  _school_id := _token_record.school_id;  -- Can be NULL for superadmin
  _class_id := _token_record.specific_class_id;

  -- Mark token as used
  -- Using direct UPDATE since we're SECURITY DEFINER
  UPDATE invite_tokens
  SET is_used = true
  WHERE token = _invite_token;

  -- Verify the update worked
  IF NOT FOUND THEN
    RAISE WARNING 'Could not mark token as used: %', _invite_token;
    -- Continue anyway - the profile creation is more important
  END IF;

  -- Create profile
  -- school_id can be NULL for superadmin users (GENESIS-KEY case)
  INSERT INTO profiles (
    id,
    email,
    role,
    school_id,
    first_name,
    last_name,
    avatar_url
  )
  VALUES (
    NEW.id,
    NEW.email,
    _role,
    _school_id,  -- NULL is allowed for superadmin
    COALESCE(NULLIF(NEW.raw_user_meta_data->>'first_name', ''), 'New'),
    COALESCE(NULLIF(NEW.raw_user_meta_data->>'last_name', ''), 'User'),
    NEW.raw_user_meta_data->>'avatar_url'
  );

  -- If student and class specified, enroll in class
  IF _role = 'student' AND _class_id IS NOT NULL THEN
    INSERT INTO class_students (class_id, student_id)
    VALUES (_class_id, NEW.id);
  END IF;

  RETURN NEW;

EXCEPTION
  WHEN unique_violation THEN
    -- Profile already exists (race condition or re-trigger)
    RAISE WARNING 'Profile already exists for user %', NEW.id;
    RETURN NEW;
  WHEN foreign_key_violation THEN
    -- This shouldn't happen but handle gracefully
    RAISE EXCEPTION 'Foreign key violation creating profile: %', SQLERRM
      USING ERRCODE = 'P0003';
  WHEN OTHERS THEN
    -- Re-raise with context
    RAISE EXCEPTION 'Error in handle_new_user: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE plpgsql;

-- Grant execute to the postgres role (trigger owner)
GRANT EXECUTE ON FUNCTION handle_new_user() TO postgres;

-- Ensure the trigger is properly attached (recreate to be safe)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- ============================================================================
-- Additional Fix: Ensure invite_tokens table allows updates from trigger
--
-- The SECURITY DEFINER function runs as the postgres user, but RLS policies
-- might still block operations. We need to ensure the postgres role (or
-- service_role for Supabase) can update tokens.
-- ============================================================================

-- Grant necessary permissions on invite_tokens to allow the trigger to work
GRANT ALL ON invite_tokens TO postgres;
GRANT ALL ON invite_tokens TO service_role;

-- Grant necessary permissions on profiles to allow the trigger to work
GRANT ALL ON profiles TO postgres;
GRANT ALL ON profiles TO service_role;

-- Grant on class_students for student enrollment
GRANT ALL ON class_students TO postgres;
GRANT ALL ON class_students TO service_role;

-- ============================================================================
-- Verify the GENESIS-KEY token exists and is valid
-- ============================================================================
INSERT INTO invite_tokens (token, role, school_id, created_by_user_id, is_used, expires_at)
VALUES ('GENESIS-KEY', 'superadmin', NULL, NULL, false, '2099-12-31'::timestamptz)
ON CONFLICT (token) DO UPDATE SET
  is_used = false,
  expires_at = '2099-12-31'::timestamptz;

-- ============================================================================
-- Add comments
-- ============================================================================
COMMENT ON FUNCTION handle_new_user() IS
  'Trigger function that creates a profile for new users based on their invite token. '
  'Handles the GENESIS-KEY case where school_id is NULL (for SuperAdmin bootstrap). '
  'Runs as SECURITY DEFINER to bypass RLS when updating invite_tokens and inserting profiles.';

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
