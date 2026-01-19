-- =============================================================================
-- Migration: Auto Profile Trigger (Fault-Tolerant Version)
-- =============================================================================
-- Description: Automatically creates a profile when a new user is created
--              This version handles all edge cases gracefully and never fails
--              user creation, even with invalid/missing metadata.
--
-- Author: Classio Team
-- Created: 2026-01-11
-- Updated: 2026-01-11 (Fault-tolerant rewrite)
-- =============================================================================

-- =============================================================================
-- HELPER FUNCTION: public.safe_cast_uuid()
-- =============================================================================
-- Purpose: Safely cast a text value to UUID without throwing errors
-- Returns: UUID if valid, NULL otherwise
-- =============================================================================

CREATE OR REPLACE FUNCTION public.safe_cast_uuid(text_value text)
RETURNS uuid
LANGUAGE plpgsql
AS $$
BEGIN
  IF text_value IS NULL OR text_value = '' THEN
    RETURN NULL;
  END IF;
  RETURN text_value::uuid;
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION public.safe_cast_uuid(text) IS
'Safely casts a text value to UUID. Returns NULL if the value is NULL, empty, or not a valid UUID format.';


-- =============================================================================
-- FUNCTION: public.handle_new_user()
-- =============================================================================
-- Purpose: Automatically creates a profile row when a new auth.users row is created
-- Security: SECURITY DEFINER bypasses RLS to ensure profile is always created
-- Fault-Tolerant: Handles all edge cases and NEVER fails user creation
-- =============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _role text;
  _role_enum user_role;
  _school_id uuid;
  _school_id_text text;
  _first_name text;
  _last_name text;
  _school_exists boolean;
  _fallback_school_id uuid;
BEGIN
  -- ==========================================================================
  -- Step 1: Extract role with safe default
  -- ==========================================================================
  _role := COALESCE(NULLIF(TRIM(NEW.raw_user_meta_data->>'role'), ''), 'student');

  -- ==========================================================================
  -- Step 2: Safely cast role to enum
  -- ==========================================================================
  BEGIN
    _role_enum := _role::user_role;
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Invalid role "%" for user %, defaulting to student', _role, NEW.id;
    _role_enum := 'student'::user_role;
  END;

  -- ==========================================================================
  -- Step 3: Safely extract and validate school_id
  -- Uses helper function to prevent UUID casting errors
  -- ==========================================================================
  _school_id_text := NEW.raw_user_meta_data->>'school_id';
  _school_id := public.safe_cast_uuid(_school_id_text);

  -- ==========================================================================
  -- Step 4: Verify school exists (if school_id was provided)
  -- ==========================================================================
  IF _school_id IS NOT NULL THEN
    SELECT EXISTS(SELECT 1 FROM public.schools WHERE id = _school_id) INTO _school_exists;
    IF NOT _school_exists THEN
      RAISE WARNING 'School % does not exist for user %, will use fallback', _school_id, NEW.id;
      _school_id := NULL;
    END IF;
  END IF;

  -- ==========================================================================
  -- Step 5: Fallback logic for non-superadmin users without a school
  -- Superadmins can have NULL school_id (they manage all schools)
  -- Other roles get the first available school as fallback
  -- ==========================================================================
  IF _school_id IS NULL AND _role_enum != 'superadmin' THEN
    -- Try to get the first available school as fallback
    SELECT id INTO _fallback_school_id FROM public.schools ORDER BY created_at LIMIT 1;
    IF _fallback_school_id IS NOT NULL THEN
      RAISE NOTICE 'Using fallback school % for user %', _fallback_school_id, NEW.id;
      _school_id := _fallback_school_id;
    END IF;
  END IF;

  -- ==========================================================================
  -- Step 6: Extract optional fields with safe trimming
  -- ==========================================================================
  _first_name := NULLIF(TRIM(NEW.raw_user_meta_data->>'first_name'), '');
  _last_name := NULLIF(TRIM(NEW.raw_user_meta_data->>'last_name'), '');

  -- ==========================================================================
  -- Step 7: Insert profile with upsert behavior
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
    _role_enum,
    _school_id,
    _first_name,
    _last_name,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    role = EXCLUDED.role,
    school_id = COALESCE(EXCLUDED.school_id, profiles.school_id),
    first_name = COALESCE(EXCLUDED.first_name, profiles.first_name),
    last_name = COALESCE(EXCLUDED.last_name, profiles.last_name),
    updated_at = NOW();

  RAISE NOTICE 'Profile created successfully for user % with role % and school %', NEW.id, _role_enum, _school_id;

  RETURN NEW;

EXCEPTION WHEN OTHERS THEN
  -- ==========================================================================
  -- Error Handling: Log error but NEVER fail user creation
  -- This ensures users can still sign up even if profile creation fails
  -- The profile can be created/fixed later through other means
  -- ==========================================================================
  RAISE WARNING 'handle_new_user failed for %: % (SQLSTATE: %)', NEW.id, SQLERRM, SQLSTATE;
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.handle_new_user() IS
'Fault-tolerant trigger function that creates a profile for new users. Handles invalid UUIDs, missing schools, and invalid roles gracefully. Never fails user creation.';


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

COMMENT ON TRIGGER on_auth_user_created ON auth.users IS
'Automatically creates a profile in public.profiles when a new user is created in auth.users. Uses fault-tolerant logic to handle edge cases.';


-- =============================================================================
-- PERMISSIONS
-- =============================================================================
-- Grant execute permission on the functions to necessary roles
-- The functions use SECURITY DEFINER, so they run with owner privileges
-- =============================================================================

-- Revoke all permissions first (security best practice)
REVOKE ALL ON FUNCTION public.safe_cast_uuid(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC;

-- Grant execute to authenticated users (required for trigger to fire)
GRANT EXECUTE ON FUNCTION public.safe_cast_uuid(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO authenticated;

-- Grant execute to service_role for administrative operations
GRANT EXECUTE ON FUNCTION public.safe_cast_uuid(text) TO service_role;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;

-- Grant execute to postgres role (owner)
GRANT EXECUTE ON FUNCTION public.safe_cast_uuid(text) TO postgres;
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
