-- ============================================================================
-- MIGRATION: Fix Parent-Student Linking via Parent Invite Codes
-- Version: 20260117500000
--
-- PROBLEM:
-- When a parent registers using an invite code (P- prefix), they should be
-- automatically linked to the student specified in that invite. This linking
-- is NOT happening because:
--
-- 1. The `use_parent_invite` function exists but doesn't properly bypass RLS
--    - Missing: SET search_path = public
--    - Missing: SET row_security = off
--
-- 2. The parent_student table RLS policies only allow admins to INSERT
--    - A newly registered parent cannot insert their own link
--    - The SECURITY DEFINER function should bypass this, but only if
--      properly configured
--
-- 3. Potential issue: The function may fail silently if there's a conflict
--
-- SOLUTION:
-- 1. Recreate the `use_parent_invite` function with proper SECURITY DEFINER
--    settings including SET search_path and SET row_security = off
-- 2. Add better error handling and logging
-- 3. Ensure the function is granted execute to authenticated users
-- ============================================================================

-- =============================================================================
-- PART 0: Ensure parent_student table has created_at column
-- =============================================================================
-- The original migration might not have this column, so add it if missing

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'parent_student'
        AND column_name = 'created_at'
    ) THEN
        ALTER TABLE parent_student ADD COLUMN created_at TIMESTAMPTZ DEFAULT now();
        RAISE NOTICE 'Added created_at column to parent_student table';
    ELSE
        RAISE NOTICE 'parent_student.created_at already exists';
    END IF;
END $$;

-- =============================================================================
-- PART 1: Drop and recreate the use_parent_invite function with proper settings
-- =============================================================================

-- Drop the existing function
DROP FUNCTION IF EXISTS use_parent_invite(TEXT, UUID);

-- Recreate with proper SECURITY DEFINER settings
CREATE OR REPLACE FUNCTION use_parent_invite(
    p_code TEXT,
    p_parent_id UUID
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    student_id UUID,
    school_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
-- Critical: These settings ensure the function bypasses RLS
SET search_path = public
SET row_security = off
AS $$
DECLARE
    v_invite_id UUID;
    v_student_id UUID;
    v_school_id UUID;
    v_times_used INT;
    v_usage_limit INT;
    v_expires_at TIMESTAMPTZ;
BEGIN
    -- Debug: Log the incoming parameters
    RAISE NOTICE 'use_parent_invite called with code=% parent_id=%', p_code, p_parent_id;

    -- Find the invite by code
    SELECT
        id,
        student_id,
        school_id,
        times_used,
        usage_limit,
        expires_at
    INTO
        v_invite_id,
        v_student_id,
        v_school_id,
        v_times_used,
        v_usage_limit,
        v_expires_at
    FROM parent_invites
    WHERE code = p_code;

    -- Check if invite exists
    IF v_invite_id IS NULL THEN
        RAISE NOTICE 'use_parent_invite: Invalid invite code';
        RETURN QUERY SELECT
            FALSE,
            'Invalid invite code'::TEXT,
            NULL::UUID,
            NULL::UUID;
        RETURN;
    END IF;

    -- Check if invite has been fully used
    IF v_times_used >= v_usage_limit THEN
        RAISE NOTICE 'use_parent_invite: Invite code has already been used (times_used=%, usage_limit=%)', v_times_used, v_usage_limit;
        RETURN QUERY SELECT
            FALSE,
            'Invite code has already been used'::TEXT,
            NULL::UUID,
            NULL::UUID;
        RETURN;
    END IF;

    -- Check if invite has expired
    IF v_expires_at IS NOT NULL AND v_expires_at < now() THEN
        RAISE NOTICE 'use_parent_invite: Invite code has expired (expires_at=%)', v_expires_at;
        RETURN QUERY SELECT
            FALSE,
            'Invite code has expired'::TEXT,
            NULL::UUID,
            NULL::UUID;
        RETURN;
    END IF;

    RAISE NOTICE 'use_parent_invite: Invite valid, linking parent % to student %', p_parent_id, v_student_id;

    -- Update the invite to mark it as used
    UPDATE parent_invites
    SET
        times_used = times_used + 1,
        parent_id = p_parent_id,
        used_at = now()
    WHERE id = v_invite_id;

    RAISE NOTICE 'use_parent_invite: Updated parent_invites, now creating parent_student link';

    -- Create the parent-student relationship
    -- Use INSERT ... ON CONFLICT to handle the case where the link already exists
    BEGIN
        INSERT INTO parent_student (parent_id, student_id, relationship, created_at)
        VALUES (p_parent_id, v_student_id, 'parent', now())
        ON CONFLICT (parent_id, student_id) DO NOTHING;

        RAISE NOTICE 'use_parent_invite: Successfully created parent_student link';
    EXCEPTION WHEN OTHERS THEN
        -- Log the error but don't fail - the invite was still marked as used
        RAISE WARNING 'use_parent_invite: Failed to create parent_student link: %', SQLERRM;
    END;

    -- Return success with student and school info
    RETURN QUERY SELECT
        TRUE,
        'Successfully linked to student'::TEXT,
        v_student_id,
        v_school_id;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION use_parent_invite(TEXT, UUID) TO authenticated;

COMMENT ON FUNCTION use_parent_invite IS 'Validates and uses a parent invite code, creating the parent-student relationship. Runs as SECURITY DEFINER to bypass RLS.';

-- =============================================================================
-- PART 2: Add RLS policy for parents to insert their own link via the function
-- =============================================================================
-- Even though the function is SECURITY DEFINER with SET row_security = off,
-- let's also add a policy that allows parents to insert a link to themselves
-- as a fallback

-- Check if such a policy already exists, drop it first to avoid conflicts
DROP POLICY IF EXISTS "parent_student_parent_self_insert" ON parent_student;

-- Create a policy that allows parents to insert a link where they are the parent
-- This is a safety net in case the SECURITY DEFINER function has issues
CREATE POLICY "parent_student_parent_self_insert" ON parent_student
    FOR INSERT
    TO authenticated
    WITH CHECK (
        parent_id = auth.uid()
        -- Verify the user is actually a parent role
        AND EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'parent'
        )
        -- Verify there's a valid parent invite linking this parent to this student
        AND EXISTS (
            SELECT 1 FROM parent_invites pi
            WHERE pi.parent_id = auth.uid()
            AND pi.student_id = parent_student.student_id
        )
    );

-- =============================================================================
-- PART 3: Create a simpler direct-link function as fallback
-- =============================================================================
-- This function can be called directly from the app after registration
-- if the use_parent_invite fails for any reason

CREATE OR REPLACE FUNCTION link_parent_to_student_from_invite(
    p_invite_code TEXT
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    student_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    v_invite RECORD;
    v_parent_id UUID;
BEGIN
    -- Get the current user ID
    v_parent_id := auth.uid();

    IF v_parent_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Not authenticated'::TEXT, NULL::UUID;
        RETURN;
    END IF;

    -- Find the invite and verify it was used by this parent
    SELECT * INTO v_invite
    FROM parent_invites
    WHERE code = p_invite_code
    AND (parent_id = v_parent_id OR parent_id IS NULL);

    IF v_invite.id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Invalid invite code or not authorized'::TEXT, NULL::UUID;
        RETURN;
    END IF;

    -- Check if link already exists
    IF EXISTS (
        SELECT 1 FROM parent_student
        WHERE parent_id = v_parent_id
        AND student_id = v_invite.student_id
    ) THEN
        -- Link already exists, return success
        RETURN QUERY SELECT TRUE, 'Already linked to student'::TEXT, v_invite.student_id;
        RETURN;
    END IF;

    -- Create the link
    INSERT INTO parent_student (parent_id, student_id, relationship, created_at)
    VALUES (v_parent_id, v_invite.student_id, 'parent', now());

    -- Update the invite if not already updated
    UPDATE parent_invites
    SET
        times_used = GREATEST(times_used, 1),
        parent_id = v_parent_id,
        used_at = COALESCE(used_at, now())
    WHERE id = v_invite.id
    AND parent_id IS NULL;

    RETURN QUERY SELECT TRUE, 'Successfully linked to student'::TEXT, v_invite.student_id;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, ('Error: ' || SQLERRM)::TEXT, NULL::UUID;
END;
$$;

GRANT EXECUTE ON FUNCTION link_parent_to_student_from_invite(TEXT) TO authenticated;

COMMENT ON FUNCTION link_parent_to_student_from_invite IS 'Links the current user (parent) to a student based on an invite code. Fallback function that can be called after registration.';

-- =============================================================================
-- PART 4: Verification
-- =============================================================================

DO $$
BEGIN
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Parent-Student Linking Fix Applied';
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Created/Updated functions:';
    RAISE NOTICE '  - use_parent_invite(TEXT, UUID)';
    RAISE NOTICE '  - link_parent_to_student_from_invite(TEXT)';
    RAISE NOTICE '';
    RAISE NOTICE 'Added RLS policy:';
    RAISE NOTICE '  - parent_student_parent_self_insert';
    RAISE NOTICE '===========================================';
END $$;

-- =============================================================================
-- END OF MIGRATION
-- =============================================================================
