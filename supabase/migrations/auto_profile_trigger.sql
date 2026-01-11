-- =============================================================================
-- Migration: Automatic Profile Creation Trigger
-- =============================================================================
-- Description: Creates a database trigger that automatically creates a profile
--              row in public.profiles whenever a new user is created in auth.users.
--              This ensures data consistency and removes the need for client-side
--              profile creation logic.
--
-- Author: Classio Team
-- Created: 2026-01-11
-- =============================================================================

-- =============================================================================
-- FUNCTION: public.handle_new_user()
-- =============================================================================
-- Purpose: Automatically creates a profile row when a new auth.users row is created
-- Security: SECURITY DEFINER bypasses RLS to ensure profile is always created
-- =============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER  -- Bypasses RLS to ensure profile is always created
SET search_path = public
AS $$
DECLARE
  _role text;
  _school_id uuid;
  _first_name text;
  _last_name text;
BEGIN
  -- ==========================================================================
  -- Extract metadata from the new user record
  -- Supabase stores custom data in raw_user_meta_data jsonb column
  -- ==========================================================================

  -- Role defaults to 'student' if not provided
  _role := COALESCE(NEW.raw_user_meta_data->>'role', 'student');

  -- School ID is optional, cast to UUID (will be NULL if not provided or invalid)
  _school_id := (NEW.raw_user_meta_data->>'school_id')::uuid;

  -- Name fields are optional
  _first_name := NEW.raw_user_meta_data->>'first_name';
  _last_name := NEW.raw_user_meta_data->>'last_name';

  -- ==========================================================================
  -- Insert the new profile with upsert behavior
  -- ON CONFLICT handles race conditions where profile might already exist
  -- ==========================================================================

  INSERT INTO public.profiles (
    id,
    email,
    role,
    school_id,
    first_name,
    last_name,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,
    NEW.email,
    _role::user_role,  -- Cast to user_role enum type
    _school_id,
    _first_name,
    _last_name,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    -- Update existing profile if it already exists
    -- This handles race conditions or client-side pre-creation attempts
    role = EXCLUDED.role,
    school_id = COALESCE(EXCLUDED.school_id, profiles.school_id),
    first_name = COALESCE(EXCLUDED.first_name, profiles.first_name),
    last_name = COALESCE(EXCLUDED.last_name, profiles.last_name),
    updated_at = NOW();

  RETURN NEW;

EXCEPTION
  WHEN OTHERS THEN
    -- ==========================================================================
    -- Error Handling
    -- Log the error but don't fail the user creation
    -- This ensures users can still sign up even if profile creation fails
    -- The profile can be created/fixed later through other means
    -- ==========================================================================
    RAISE WARNING 'Failed to create profile for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$;

-- =============================================================================
-- Add function comment for documentation
-- =============================================================================
COMMENT ON FUNCTION public.handle_new_user() IS
'Trigger function that automatically creates a profile in public.profiles when a new user signs up via Supabase Auth. Extracts role, school_id, first_name, and last_name from raw_user_meta_data. Uses SECURITY DEFINER to bypass RLS policies.';


-- =============================================================================
-- TRIGGER: on_auth_user_created
-- =============================================================================
-- Purpose: Fires after a new user is inserted into auth.users
-- Timing: AFTER INSERT ensures the user record is fully committed
-- =============================================================================

-- Drop existing trigger if it exists (makes migration idempotent)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Add trigger comment for documentation
COMMENT ON TRIGGER on_auth_user_created ON auth.users IS
'Automatically creates a profile in public.profiles when a new user is created in auth.users. Ensures every authenticated user has a corresponding profile record.';


-- =============================================================================
-- PERMISSIONS
-- =============================================================================
-- Grant execute permission on the function to necessary roles
-- The function uses SECURITY DEFINER, so it runs with owner privileges
-- =============================================================================

-- Revoke all permissions first (security best practice)
REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC;

-- Grant execute to authenticated users (required for trigger to fire)
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO authenticated;

-- Grant execute to service_role for administrative operations
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;

-- Grant execute to postgres role (owner)
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO postgres;


-- =============================================================================
-- VERIFICATION QUERY (for testing - commented out)
-- =============================================================================
-- Run this query to verify the trigger is set up correctly:
--
-- SELECT
--   t.tgname AS trigger_name,
--   t.tgenabled AS enabled,
--   p.proname AS function_name,
--   n.nspname AS schema
-- FROM pg_trigger t
-- JOIN pg_proc p ON t.tgfoid = p.oid
-- JOIN pg_namespace n ON p.pronamespace = n.oid
-- WHERE t.tgname = 'on_auth_user_created';
-- =============================================================================
