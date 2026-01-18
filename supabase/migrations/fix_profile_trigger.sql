-- ============================================================================
-- Migration: fix_profile_trigger.sql
-- Purpose: Implement a robust, fault-tolerant trigger for creating user profiles
--          when new users register via Supabase Auth
-- ============================================================================

-- ============================================================================
-- SECTION 1: Helper Function - safe_cast_uuid
-- Purpose: Safely cast a text value to UUID without throwing exceptions
-- Returns NULL for invalid inputs (NULL, empty string, malformed UUID)
-- ============================================================================

-- Drop existing function first (parameter name may differ)
DROP FUNCTION IF EXISTS public.safe_cast_uuid(TEXT);

CREATE OR REPLACE FUNCTION public.safe_cast_uuid(input_text TEXT)
RETURNS UUID
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    -- Return NULL for NULL or empty input
    IF input_text IS NULL OR input_text = '' THEN
        RETURN NULL;
    END IF;

    -- Attempt to cast to UUID, return NULL on failure
    BEGIN
        RETURN input_text::UUID;
    EXCEPTION
        WHEN invalid_text_representation THEN
            RETURN NULL;
        WHEN others THEN
            RETURN NULL;
    END;
END;
$$;

-- Add comment for documentation
COMMENT ON FUNCTION public.safe_cast_uuid(TEXT) IS
    'Safely casts a text value to UUID. Returns NULL if input is NULL, empty, or invalid UUID format. Never throws an exception.';

-- ============================================================================
-- SECTION 2: Main Function - handle_new_user
-- Purpose: Create a profile record when a new user is created in auth.users
-- Features:
--   - SECURITY DEFINER to bypass RLS policies
--   - Fault-tolerant: logs warnings but never fails user registration
--   - Validates school_id exists, falls back to first available school
--   - Safe enum casting with fallback to 'student' role
--   - Idempotent via ON CONFLICT clause
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    -- Extracted metadata fields
    v_role TEXT;
    v_school_id UUID;
    v_first_name TEXT;
    v_last_name TEXT;

    -- Validated/processed values
    v_valid_role user_role;
    v_valid_school_id UUID;
    v_fallback_school_id UUID;
    v_school_exists BOOLEAN;
BEGIN
    -- ========================================================================
    -- STEP 1: Extract raw values from user metadata
    -- raw_user_meta_data is a JSONB field populated during signup
    -- ========================================================================
    v_role := NEW.raw_user_meta_data->>'role';
    v_school_id := public.safe_cast_uuid(NEW.raw_user_meta_data->>'school_id');
    v_first_name := NEW.raw_user_meta_data->>'first_name';
    v_last_name := NEW.raw_user_meta_data->>'last_name';

    -- ========================================================================
    -- STEP 2: Safely cast role to user_role enum
    -- Falls back to 'student' if role is NULL, empty, or invalid
    -- ========================================================================
    BEGIN
        IF v_role IS NULL OR v_role = '' THEN
            v_valid_role := 'student'::user_role;
        ELSE
            v_valid_role := v_role::user_role;
        END IF;
    EXCEPTION
        WHEN invalid_text_representation THEN
            -- Role value doesn't match any enum value
            v_valid_role := 'student'::user_role;
        WHEN others THEN
            -- Catch any other casting errors
            v_valid_role := 'student'::user_role;
    END;

    -- ========================================================================
    -- STEP 3: Validate school_id exists in schools table
    -- If invalid/non-existent and role is NOT superadmin, get fallback school
    -- ========================================================================
    v_valid_school_id := NULL;

    IF v_school_id IS NOT NULL THEN
        -- Check if the provided school_id exists
        SELECT EXISTS(
            SELECT 1 FROM public.schools WHERE id = v_school_id
        ) INTO v_school_exists;

        IF v_school_exists THEN
            v_valid_school_id := v_school_id;
        END IF;
    END IF;

    -- If school_id is invalid/doesn't exist and user is NOT superadmin,
    -- attempt to assign the first available school as fallback
    IF v_valid_school_id IS NULL AND v_valid_role != 'superadmin'::user_role THEN
        SELECT id INTO v_fallback_school_id
        FROM public.schools
        ORDER BY created_at ASC
        LIMIT 1;

        v_valid_school_id := v_fallback_school_id;

        -- Log if we're using a fallback school
        IF v_fallback_school_id IS NOT NULL THEN
            RAISE NOTICE 'handle_new_user: Using fallback school_id % for user %',
                v_fallback_school_id, NEW.id;
        END IF;
    END IF;

    -- ========================================================================
    -- STEP 4: Insert profile record with exception handling
    -- Uses ON CONFLICT for idempotency (handles duplicate key scenarios)
    -- Catches ALL exceptions to ensure user registration never fails
    -- ========================================================================
    BEGIN
        INSERT INTO public.profiles (
            id,
            school_id,
            role,
            first_name,
            last_name,
            avatar_url,
            created_at,
            updated_at
        ) VALUES (
            NEW.id,
            v_valid_school_id,
            v_valid_role,
            v_first_name,
            v_last_name,
            NULL,  -- avatar_url defaults to NULL
            NOW(),
            NOW()
        )
        ON CONFLICT (id) DO UPDATE SET
            -- Update fields only if they were NULL before (preserve existing data)
            school_id = COALESCE(profiles.school_id, EXCLUDED.school_id),
            role = COALESCE(profiles.role, EXCLUDED.role),
            first_name = COALESCE(profiles.first_name, EXCLUDED.first_name),
            last_name = COALESCE(profiles.last_name, EXCLUDED.last_name),
            updated_at = NOW();

        RAISE NOTICE 'handle_new_user: Successfully created/updated profile for user %', NEW.id;

    EXCEPTION
        WHEN others THEN
            -- Log the error but DO NOT fail the transaction
            -- This ensures user registration always succeeds even if profile creation fails
            RAISE WARNING 'handle_new_user: Failed to create profile for user %. Error: % - %',
                NEW.id, SQLERRM, SQLSTATE;
    END;

    -- Always return NEW to allow the auth.users INSERT to complete
    RETURN NEW;
END;
$$;

-- Add comment for documentation
COMMENT ON FUNCTION public.handle_new_user() IS
    'Trigger function to create a profile when a new user registers. Fault-tolerant: logs errors but never fails user registration.';

-- ============================================================================
-- SECTION 3: Create Trigger
-- ============================================================================
--
-- IMPORTANT: The trigger must be created via Supabase Dashboard UI
-- because the SQL Editor doesn't have permission to modify auth.users
--
-- MANUAL STEPS (do this after running this SQL):
--
-- 1. Go to Supabase Dashboard → Database → Triggers
-- 2. Click "Create a new trigger"
-- 3. Configure:
--    - Name: on_auth_user_created
--    - Table: auth.users
--    - Events: INSERT
--    - Trigger type: After the event
--    - Orientation: Row
--    - Function: public.handle_new_user
-- 4. Click "Confirm"
--
-- ============================================================================

-- ============================================================================
-- SECTION 4: Grant Permissions
-- Grant execute permissions to necessary roles for proper function access
-- ============================================================================

-- Grant execute on helper function
GRANT EXECUTE ON FUNCTION public.safe_cast_uuid(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.safe_cast_uuid(TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION public.safe_cast_uuid(TEXT) TO postgres;

-- Grant execute on main trigger function
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO authenticated;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO postgres;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
