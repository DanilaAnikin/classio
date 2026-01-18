-- ============================================================================
-- MIGRATION: Bulletproof Parent-Student Linking
-- Version: 20260117600000
--
-- PROBLEM:
-- Parent registration with P- invite codes should automatically link the parent
-- to their child in the parent_student table. This is NOT happening because:
--
-- 1. RLS policies may be blocking the insert
-- 2. The RPC functions may not have proper SECURITY DEFINER settings
-- 3. The functions may not exist in the database
-- 4. There may be permission issues with the functions
--
-- SOLUTION:
-- This migration creates a completely bulletproof system:
-- 1. Creates/recreates the RPC functions with proper settings
-- 2. Grants all necessary permissions
-- 3. Adds RLS policies that allow the parent to insert their own link
-- 4. Creates a simple, guaranteed-to-work function
-- ============================================================================

-- =============================================================================
-- STEP 1: Ensure parent_student table has required columns
-- =============================================================================

DO $$
BEGIN
    -- Add created_at if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'parent_student'
        AND column_name = 'created_at'
    ) THEN
        ALTER TABLE parent_student ADD COLUMN created_at TIMESTAMPTZ DEFAULT now();
        RAISE NOTICE 'Added created_at column to parent_student';
    END IF;
END $$;

-- =============================================================================
-- STEP 2: Drop ALL existing RLS policies on parent_student for a clean slate
-- =============================================================================

DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN
        SELECT policyname
        FROM pg_policies
        WHERE tablename = 'parent_student' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON parent_student', pol.policyname);
        RAISE NOTICE 'Dropped policy: %', pol.policyname;
    END LOOP;
END $$;

-- =============================================================================
-- STEP 3: Create new, simple, working RLS policies for parent_student
-- =============================================================================

-- Enable RLS (should already be enabled, but just in case)
ALTER TABLE parent_student ENABLE ROW LEVEL SECURITY;

-- Superadmin: Full access
CREATE POLICY "ps_superadmin_all" ON parent_student
    FOR ALL TO authenticated
    USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'superadmin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'superadmin')
    );

-- Admin/BigAdmin: Full access to links involving students in their school
CREATE POLICY "ps_admin_all" ON parent_student
    FOR ALL TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles p
            WHERE p.id = auth.uid()
            AND p.role IN ('admin', 'bigadmin')
            AND EXISTS (
                SELECT 1 FROM profiles student
                WHERE student.id = parent_student.student_id
                AND student.school_id = p.school_id
            )
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM profiles p
            WHERE p.id = auth.uid()
            AND p.role IN ('admin', 'bigadmin')
            AND EXISTS (
                SELECT 1 FROM profiles student
                WHERE student.id = parent_student.student_id
                AND student.school_id = p.school_id
            )
        )
    );

-- Parent: SELECT their own links
CREATE POLICY "ps_parent_select_own" ON parent_student
    FOR SELECT TO authenticated
    USING (parent_id = auth.uid());

-- Parent: INSERT their own link (this is the KEY policy for registration)
-- This allows a parent to insert a record where they are the parent
CREATE POLICY "ps_parent_insert_own" ON parent_student
    FOR INSERT TO authenticated
    WITH CHECK (
        parent_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'parent'
        )
    );

-- Student: SELECT links involving themselves
CREATE POLICY "ps_student_select_own" ON parent_student
    FOR SELECT TO authenticated
    USING (student_id = auth.uid());

-- Teacher: SELECT links for students in their classes
CREATE POLICY "ps_teacher_select_class_students" ON parent_student
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles p
            WHERE p.id = auth.uid()
            AND p.role = 'teacher'
        )
        AND EXISTS (
            SELECT 1 FROM class_students cs
            JOIN subjects s ON s.class_id = cs.class_id
            WHERE cs.student_id = parent_student.student_id
            AND s.teacher_id = auth.uid()
        )
    );

-- =============================================================================
-- STEP 4: Drop and recreate the use_parent_invite function
-- =============================================================================

DROP FUNCTION IF EXISTS use_parent_invite(TEXT, UUID);

CREATE FUNCTION use_parent_invite(
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
SECURITY DEFINER  -- Run as function owner, not caller
SET search_path = public  -- Prevent search_path manipulation
SET row_security = off  -- Bypass RLS completely
AS $$
DECLARE
    v_invite_id UUID;
    v_student_id UUID;
    v_school_id UUID;
    v_times_used INT;
    v_usage_limit INT;
    v_expires_at TIMESTAMPTZ;
BEGIN
    -- Log entry
    RAISE LOG 'use_parent_invite called: code=%, parent_id=%', p_code, p_parent_id;

    -- Validate inputs
    IF p_code IS NULL OR p_code = '' THEN
        RETURN QUERY SELECT FALSE, 'Code is required'::TEXT, NULL::UUID, NULL::UUID;
        RETURN;
    END IF;

    IF p_parent_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Parent ID is required'::TEXT, NULL::UUID, NULL::UUID;
        RETURN;
    END IF;

    -- Find the invite
    SELECT id, student_id, school_id, times_used, usage_limit, expires_at
    INTO v_invite_id, v_student_id, v_school_id, v_times_used, v_usage_limit, v_expires_at
    FROM parent_invites
    WHERE code = p_code;

    IF v_invite_id IS NULL THEN
        RAISE LOG 'use_parent_invite: Invalid code %', p_code;
        RETURN QUERY SELECT FALSE, 'Invalid invite code'::TEXT, NULL::UUID, NULL::UUID;
        RETURN;
    END IF;

    -- Check usage limit
    IF v_times_used >= v_usage_limit THEN
        RAISE LOG 'use_parent_invite: Code already used (used=%, limit=%)', v_times_used, v_usage_limit;
        RETURN QUERY SELECT FALSE, 'Invite code has already been used'::TEXT, NULL::UUID, NULL::UUID;
        RETURN;
    END IF;

    -- Check expiry
    IF v_expires_at IS NOT NULL AND v_expires_at < now() THEN
        RAISE LOG 'use_parent_invite: Code expired at %', v_expires_at;
        RETURN QUERY SELECT FALSE, 'Invite code has expired'::TEXT, NULL::UUID, NULL::UUID;
        RETURN;
    END IF;

    RAISE LOG 'use_parent_invite: Valid invite, linking parent % to student %', p_parent_id, v_student_id;

    -- Update the invite record
    UPDATE parent_invites
    SET
        times_used = times_used + 1,
        parent_id = p_parent_id,
        used_at = now()
    WHERE id = v_invite_id;

    RAISE LOG 'use_parent_invite: Updated parent_invites';

    -- Insert the parent-student link
    -- Use ON CONFLICT to handle duplicates gracefully
    INSERT INTO parent_student (parent_id, student_id, relationship, created_at)
    VALUES (p_parent_id, v_student_id, 'parent', now())
    ON CONFLICT (parent_id, student_id) DO UPDATE SET
        relationship = EXCLUDED.relationship,
        created_at = COALESCE(parent_student.created_at, EXCLUDED.created_at);

    RAISE LOG 'use_parent_invite: Created parent_student link';

    -- Return success
    RETURN QUERY SELECT TRUE, 'Successfully linked to student'::TEXT, v_student_id, v_school_id;

EXCEPTION WHEN OTHERS THEN
    RAISE LOG 'use_parent_invite EXCEPTION: %', SQLERRM;
    RETURN QUERY SELECT FALSE, ('Error: ' || SQLERRM)::TEXT, v_student_id, v_school_id;
END;
$$;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION use_parent_invite(TEXT, UUID) TO authenticated;

COMMENT ON FUNCTION use_parent_invite IS 'Links a parent to a student using an invite code. SECURITY DEFINER to bypass RLS.';

-- =============================================================================
-- STEP 5: Drop and recreate the fallback function
-- =============================================================================

DROP FUNCTION IF EXISTS link_parent_to_student_from_invite(TEXT);

CREATE FUNCTION link_parent_to_student_from_invite(p_invite_code TEXT)
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
    v_parent_id UUID;
    v_invite RECORD;
BEGIN
    -- Get current user
    v_parent_id := auth.uid();

    IF v_parent_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Not authenticated'::TEXT, NULL::UUID;
        RETURN;
    END IF;

    -- Find the invite
    SELECT * INTO v_invite
    FROM parent_invites
    WHERE code = p_invite_code;

    IF v_invite.id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Invalid invite code'::TEXT, NULL::UUID;
        RETURN;
    END IF;

    -- Check if already linked
    IF EXISTS (
        SELECT 1 FROM parent_student
        WHERE parent_id = v_parent_id AND student_id = v_invite.student_id
    ) THEN
        RETURN QUERY SELECT TRUE, 'Already linked'::TEXT, v_invite.student_id;
        RETURN;
    END IF;

    -- Create the link
    INSERT INTO parent_student (parent_id, student_id, relationship, created_at)
    VALUES (v_parent_id, v_invite.student_id, 'parent', now())
    ON CONFLICT (parent_id, student_id) DO NOTHING;

    -- Update invite if not already updated by another process
    UPDATE parent_invites
    SET
        times_used = GREATEST(times_used, 1),
        parent_id = v_parent_id,
        used_at = COALESCE(used_at, now())
    WHERE id = v_invite.id;

    RETURN QUERY SELECT TRUE, 'Successfully linked'::TEXT, v_invite.student_id;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, ('Error: ' || SQLERRM)::TEXT, NULL::UUID;
END;
$$;

GRANT EXECUTE ON FUNCTION link_parent_to_student_from_invite(TEXT) TO authenticated;

COMMENT ON FUNCTION link_parent_to_student_from_invite IS 'Links current user to a student using invite code. Fallback function.';

-- =============================================================================
-- STEP 6: Create a super simple guaranteed function as backup
-- =============================================================================

DROP FUNCTION IF EXISTS simple_link_parent(TEXT);

CREATE FUNCTION simple_link_parent(p_code TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    v_parent_id UUID;
    v_student_id UUID;
    v_result JSONB;
BEGIN
    v_parent_id := auth.uid();

    IF v_parent_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Not authenticated');
    END IF;

    -- Get student_id from invite
    SELECT student_id INTO v_student_id
    FROM parent_invites
    WHERE code = p_code
    AND times_used < usage_limit
    AND (expires_at IS NULL OR expires_at > now());

    IF v_student_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Invalid or expired invite');
    END IF;

    -- Do the insert
    INSERT INTO parent_student (parent_id, student_id, relationship, created_at)
    VALUES (v_parent_id, v_student_id, 'parent', now())
    ON CONFLICT (parent_id, student_id) DO NOTHING;

    -- Mark invite as used
    UPDATE parent_invites
    SET times_used = times_used + 1, parent_id = v_parent_id, used_at = now()
    WHERE code = p_code;

    RETURN jsonb_build_object(
        'success', true,
        'parent_id', v_parent_id,
        'student_id', v_student_id
    );

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$$;

GRANT EXECUTE ON FUNCTION simple_link_parent(TEXT) TO authenticated;

COMMENT ON FUNCTION simple_link_parent IS 'Simplest possible parent-student linking function.';

-- =============================================================================
-- STEP 7: Verify everything is set up correctly
-- =============================================================================

DO $$
DECLARE
    pol_count INT;
    func_count INT;
BEGIN
    -- Count policies
    SELECT COUNT(*) INTO pol_count
    FROM pg_policies
    WHERE tablename = 'parent_student' AND schemaname = 'public';

    -- Count functions
    SELECT COUNT(*) INTO func_count
    FROM pg_proc
    WHERE proname IN ('use_parent_invite', 'link_parent_to_student_from_invite', 'simple_link_parent');

    RAISE NOTICE '';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'BULLETPROOF PARENT-STUDENT LINKING MIGRATION';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'parent_student RLS policies: %', pol_count;
    RAISE NOTICE 'Linking functions created: %', func_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Functions available:';
    RAISE NOTICE '  1. use_parent_invite(code, parent_id) - Primary';
    RAISE NOTICE '  2. link_parent_to_student_from_invite(code) - Fallback';
    RAISE NOTICE '  3. simple_link_parent(code) - Super simple backup';
    RAISE NOTICE '';
    RAISE NOTICE 'RLS policies on parent_student:';
    RAISE NOTICE '  - ps_superadmin_all';
    RAISE NOTICE '  - ps_admin_all';
    RAISE NOTICE '  - ps_parent_select_own';
    RAISE NOTICE '  - ps_parent_insert_own';
    RAISE NOTICE '  - ps_student_select_own';
    RAISE NOTICE '  - ps_teacher_select_class_students';
    RAISE NOTICE '==============================================';
END $$;

-- =============================================================================
-- END OF MIGRATION
-- =============================================================================
