-- ===========================================
-- EMERGENCY FIX: Profile Creation Issues
-- Run this script in Supabase SQL Editor
-- ===========================================

-- Step 1: Ensure the school exists
INSERT INTO public.schools (id, name, created_at)
VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Gymnazium Budoucnost', now())
ON CONFLICT (id) DO NOTHING;

-- Step 2: Create admin invite codes
INSERT INTO public.invite_codes (id, code, role, school_id, class_id, usage_limit, times_used, is_active, expires_at, created_at)
VALUES
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'SUPERADMIN-START', 'superadmin', NULL, NULL, 10, 0, true, now() + interval '1 year', now()),
  ('d2eebc99-9c0b-4ef8-bb6d-6bb9bd380a55', 'BIGADMIN-START', 'bigadmin', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', NULL, 5, 0, true, now() + interval '1 year', now()),
  ('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a66', 'ADMIN-START', 'admin', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', NULL, 10, 0, true, now() + interval '1 year', now()),
  ('d4eebc99-9c0b-4ef8-bb6d-6bb9bd380a77', 'TEACHER-START', 'teacher', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', NULL, 50, 0, true, now() + interval '1 year', now()),
  ('d5eebc99-9c0b-4ef8-bb6d-6bb9bd380a88', 'PARENT-START', 'parent', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', NULL, 100, 0, true, now() + interval '1 year', now()),
  ('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'STUDENT-2026', 'student', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', NULL, 100, 0, true, now() + interval '1 year', now())
ON CONFLICT (code) DO UPDATE SET
  is_active = true,
  expires_at = now() + interval '1 year',
  times_used = 0;

-- Step 3: Create safe UUID casting helper
CREATE OR REPLACE FUNCTION public.safe_cast_uuid(text_value text)
RETURNS uuid
LANGUAGE plpgsql
AS $$
BEGIN
  IF text_value IS NULL OR text_value = '' OR text_value = 'null' THEN
    RETURN NULL;
  END IF;
  RETURN text_value::uuid;
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END;
$$;

-- Step 4: Create fault-tolerant trigger function
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
  -- Extract role with safe default
  _role := COALESCE(NULLIF(TRIM(NEW.raw_user_meta_data->>'role'), ''), 'student');

  -- Safely cast role to enum
  BEGIN
    _role_enum := _role::user_role;
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Invalid role "%" for user %, defaulting to student', _role, NEW.id;
    _role_enum := 'student'::user_role;
  END;

  -- Safely extract school_id
  _school_id_text := NEW.raw_user_meta_data->>'school_id';
  _school_id := public.safe_cast_uuid(_school_id_text);

  -- Verify school exists
  IF _school_id IS NOT NULL THEN
    SELECT EXISTS(SELECT 1 FROM public.schools WHERE id = _school_id) INTO _school_exists;
    IF NOT _school_exists THEN
      RAISE WARNING 'School % does not exist for user %, will use fallback', _school_id, NEW.id;
      _school_id := NULL;
    END IF;
  END IF;

  -- Fallback for non-superadmin users without a school
  IF _school_id IS NULL AND _role_enum != 'superadmin' THEN
    SELECT id INTO _fallback_school_id FROM public.schools ORDER BY created_at LIMIT 1;
    IF _fallback_school_id IS NOT NULL THEN
      RAISE NOTICE 'Using fallback school % for user %', _fallback_school_id, NEW.id;
      _school_id := _fallback_school_id;
    END IF;
  END IF;

  -- Extract optional fields
  _first_name := NULLIF(TRIM(NEW.raw_user_meta_data->>'first_name'), '');
  _last_name := NULLIF(TRIM(NEW.raw_user_meta_data->>'last_name'), '');

  -- Insert profile with upsert
  INSERT INTO public.profiles (id, email, role, school_id, first_name, last_name, created_at, updated_at)
  VALUES (NEW.id, NEW.email, _role_enum, _school_id, _first_name, _last_name, NOW(), NOW())
  ON CONFLICT (id) DO UPDATE SET
    role = EXCLUDED.role,
    school_id = COALESCE(EXCLUDED.school_id, profiles.school_id),
    first_name = COALESCE(EXCLUDED.first_name, profiles.first_name),
    last_name = COALESCE(EXCLUDED.last_name, profiles.last_name),
    updated_at = NOW();

  RAISE NOTICE 'Profile created for user % with role % and school %', NEW.id, _role_enum, _school_id;
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RAISE WARNING 'handle_new_user failed for %: % (SQLSTATE: %)', NEW.id, SQLERRM, SQLSTATE;
  RETURN NEW;
END;
$$;

-- Step 5: Create/recreate the trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Step 6: Grant permissions
GRANT EXECUTE ON FUNCTION public.safe_cast_uuid(text) TO authenticated, service_role, postgres;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO authenticated, service_role, postgres;

-- Step 7: Verification queries (check the results)
SELECT 'Schools:' as check, count(*) as count FROM public.schools;
SELECT 'Invite Codes:' as check, count(*) as count FROM public.invite_codes WHERE is_active = true;
SELECT code, role, school_id FROM public.invite_codes WHERE is_active = true ORDER BY role;
