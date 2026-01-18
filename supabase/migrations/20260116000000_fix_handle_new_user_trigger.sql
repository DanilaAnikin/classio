-- =============================================================================
-- Migration: Fix handle_new_user() Trigger
-- =============================================================================
-- Description: Combines token-based validation with fault-tolerant profile creation
--              Fixes the "Database error saving new user" issue by properly handling
--              invite_tokens with times_used/usage_limit columns.
--
-- Author: Classio Team
-- Created: 2026-01-16
-- =============================================================================

-- Drop existing trigger first
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- =============================================================================
-- FUNCTION: public.handle_new_user()
-- =============================================================================
-- Purpose: Creates a profile when a new auth.users row is created
--          Validates invite_token if provided and assigns role/school accordingly
-- Security: SECURITY DEFINER bypasses RLS to ensure profile is always created
-- =============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  _role user_role;
  _school_id UUID;
  _class_id UUID;
  _invite_token TEXT;
  _token_record RECORD;
  _first_name TEXT;
  _last_name TEXT;
BEGIN
  -- Extract values from user metadata
  _invite_token := NEW.raw_user_meta_data->>'invite_token';
  _first_name := NULLIF(TRIM(NEW.raw_user_meta_data->>'first_name'), '');
  _last_name := NULLIF(TRIM(NEW.raw_user_meta_data->>'last_name'), '');

  -- ==========================================================================
  -- Step 1: Process invite token if provided
  -- ==========================================================================
  IF _invite_token IS NOT NULL AND _invite_token != '' THEN
    -- Fetch and validate token using times_used < usage_limit
    SELECT * INTO _token_record FROM invite_tokens
    WHERE token = _invite_token
      AND times_used < usage_limit
      AND (expires_at IS NULL OR expires_at > now());

    IF FOUND THEN
      -- Valid token found - use its values
      _role := _token_record.role;
      _school_id := _token_record.school_id;
      _class_id := _token_record.specific_class_id;

      -- Increment times_used
      UPDATE invite_tokens
      SET times_used = times_used + 1
      WHERE token = _invite_token;

      RAISE NOTICE 'Token validated for user %: role=%, school=%', NEW.id, _role, _school_id;
    ELSE
      -- Token not found or invalid - fall back to metadata
      RAISE WARNING 'Invalid or expired token for user %, falling back to metadata', NEW.id;

      -- Try to get role from metadata
      BEGIN
        _role := (NEW.raw_user_meta_data->>'role')::user_role;
      EXCEPTION WHEN OTHERS THEN
        _role := 'student'::user_role;
      END;

      -- Try to get school_id from metadata
      BEGIN
        _school_id := (NEW.raw_user_meta_data->>'school_id')::uuid;
      EXCEPTION WHEN OTHERS THEN
        _school_id := NULL;
      END;
    END IF;
  ELSE
    -- No token provided - use metadata values
    BEGIN
      _role := COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'student'::user_role);
    EXCEPTION WHEN OTHERS THEN
      _role := 'student'::user_role;
    END;

    BEGIN
      _school_id := (NEW.raw_user_meta_data->>'school_id')::uuid;
    EXCEPTION WHEN OTHERS THEN
      _school_id := NULL;
    END;

    BEGIN
      _class_id := (NEW.raw_user_meta_data->>'class_id')::uuid;
    EXCEPTION WHEN OTHERS THEN
      _class_id := NULL;
    END;
  END IF;

  -- ==========================================================================
  -- Step 2: Fallback for non-superadmin users without a school
  -- ==========================================================================
  IF _school_id IS NULL AND _role != 'superadmin' THEN
    -- Verify school exists if we have one from metadata
    IF _school_id IS NOT NULL THEN
      IF NOT EXISTS(SELECT 1 FROM schools WHERE id = _school_id) THEN
        RAISE WARNING 'School % does not exist for user %', _school_id, NEW.id;
        _school_id := NULL;
      END IF;
    END IF;

    -- Try to get the first available school as fallback
    IF _school_id IS NULL THEN
      SELECT id INTO _school_id FROM schools ORDER BY created_at LIMIT 1;
      IF _school_id IS NOT NULL THEN
        RAISE NOTICE 'Using fallback school % for user %', _school_id, NEW.id;
      END IF;
    END IF;
  END IF;

  -- ==========================================================================
  -- Step 3: Insert profile with upsert behavior
  -- ==========================================================================
  INSERT INTO profiles (
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
    _role,
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

  RAISE NOTICE 'Profile created for user % with role % and school %', NEW.id, _role, _school_id;

  -- ==========================================================================
  -- Step 4: Enroll student in class if specified
  -- ==========================================================================
  IF _role = 'student' AND _class_id IS NOT NULL THEN
    BEGIN
      INSERT INTO class_students (class_id, student_id, enrolled_at)
      VALUES (_class_id, NEW.id, NOW())
      ON CONFLICT (class_id, student_id) DO NOTHING;
      RAISE NOTICE 'Student % enrolled in class %', NEW.id, _class_id;
    EXCEPTION WHEN OTHERS THEN
      RAISE WARNING 'Failed to enroll student % in class %: %', NEW.id, _class_id, SQLERRM;
    END;
  END IF;

  RETURN NEW;

EXCEPTION WHEN OTHERS THEN
  -- ==========================================================================
  -- Error Handling: Log error but NEVER fail user creation
  -- ==========================================================================
  RAISE WARNING 'handle_new_user failed for %: % (SQLSTATE: %)', NEW.id, SQLERRM, SQLSTATE;

  -- Last resort: Try to create a minimal profile
  BEGIN
    INSERT INTO profiles (id, email, role, created_at, updated_at)
    VALUES (NEW.id, NEW.email, 'student', NOW(), NOW())
    ON CONFLICT (id) DO NOTHING;
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Even minimal profile creation failed for %: %', NEW.id, SQLERRM;
  END;

  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.handle_new_user() IS
'Creates a profile for new users. Validates invite tokens if provided, falls back to metadata. Never fails user creation.';

-- =============================================================================
-- TRIGGER: on_auth_user_created
-- =============================================================================
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- =============================================================================
-- PERMISSIONS
-- =============================================================================
REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO authenticated;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO postgres;

-- =============================================================================
-- Ensure invite_tokens can be read by the trigger (service_role)
-- =============================================================================
DROP POLICY IF EXISTS "service_role_full_access_invite_tokens" ON invite_tokens;
CREATE POLICY "service_role_full_access_invite_tokens"
  ON invite_tokens
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);
