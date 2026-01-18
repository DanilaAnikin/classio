-- ============================================================================
-- Migration: 20260117000000_fix_messages_rls_security.sql
-- CRITICAL SECURITY FIX: Ensure users can ONLY see their own messages
--
-- PROBLEM: Users were seeing ALL messages from ALL users in the system.
-- This was a massive security/privacy breach.
--
-- ROOT CAUSE: RLS policies may have been bypassed or incorrectly configured,
-- particularly with the NOT is_superadmin() checks causing policy evaluation issues.
--
-- SOLUTION: Simplify the RLS policies to be more explicit and secure:
-- 1. Drop all existing message policies
-- 2. Create new, simplified policies that are bulletproof
-- 3. Ensure superadmin access is properly handled
-- ============================================================================

-- ============================================================================
-- STEP 1: DROP ALL EXISTING MESSAGE POLICIES
-- ============================================================================

DROP POLICY IF EXISTS "users_insert_own_messages" ON messages;
DROP POLICY IF EXISTS "users_select_own_messages" ON messages;
DROP POLICY IF EXISTS "users_update_read_status" ON messages;
DROP POLICY IF EXISTS "superadmin_all_messages" ON messages;

DO $$
BEGIN
    RAISE NOTICE 'Step 1: Dropped all existing message policies';
END $$;

-- ============================================================================
-- STEP 2: CREATE NEW SECURE MESSAGE POLICIES
-- ============================================================================

-- Ensure RLS is enabled
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Policy 1: Users can INSERT messages where they are the sender
CREATE POLICY "messages_insert_by_sender" ON messages
    FOR INSERT
    TO authenticated
    WITH CHECK (sender_id = auth.uid());

COMMENT ON POLICY "messages_insert_by_sender" ON messages IS
'SECURITY: Users can only insert messages where they are the sender';

DO $$
BEGIN
    RAISE NOTICE 'Step 2a: Created messages_insert_by_sender policy';
END $$;

-- Policy 2: Users can SELECT their own direct messages (sent or received)
CREATE POLICY "messages_select_direct" ON messages
    FOR SELECT
    TO authenticated
    USING (
        -- For direct messages: user must be sender OR recipient
        (message_type = 'direct' AND (sender_id = auth.uid() OR recipient_id = auth.uid()))
    );

COMMENT ON POLICY "messages_select_direct" ON messages IS
'SECURITY: Users can only see direct messages where they are sender or recipient';

DO $$
BEGIN
    RAISE NOTICE 'Step 2b: Created messages_select_direct policy';
END $$;

-- Policy 3: Users can SELECT group messages if they are a member
CREATE POLICY "messages_select_group" ON messages
    FOR SELECT
    TO authenticated
    USING (
        -- For group messages: user must be a member of the group
        (message_type = 'group' AND group_id IS NOT NULL AND is_group_member(group_id))
    );

COMMENT ON POLICY "messages_select_group" ON messages IS
'SECURITY: Users can only see group messages if they are a group member';

DO $$
BEGIN
    RAISE NOTICE 'Step 2c: Created messages_select_group policy';
END $$;

-- Policy 4: Superadmins can see ALL messages (for admin purposes)
CREATE POLICY "messages_superadmin_select" ON messages
    FOR SELECT
    TO authenticated
    USING (is_superadmin());

COMMENT ON POLICY "messages_superadmin_select" ON messages IS
'ADMIN: Superadmins can view all messages for administrative purposes';

DO $$
BEGIN
    RAISE NOTICE 'Step 2d: Created messages_superadmin_select policy';
END $$;

-- Policy 5: Users can UPDATE is_read on messages they received
CREATE POLICY "messages_update_read_status" ON messages
    FOR UPDATE
    TO authenticated
    USING (recipient_id = auth.uid())
    WITH CHECK (recipient_id = auth.uid());

COMMENT ON POLICY "messages_update_read_status" ON messages IS
'SECURITY: Users can only update read status on messages they received';

DO $$
BEGIN
    RAISE NOTICE 'Step 2e: Created messages_update_read_status policy';
END $$;

-- ============================================================================
-- STEP 3: VERIFICATION
-- ============================================================================

DO $$
DECLARE
    policy_count INTEGER;
BEGIN
    -- Verify all policies are created
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies
    WHERE tablename = 'messages'
      AND schemaname = 'public';

    IF policy_count < 5 THEN
        RAISE EXCEPTION 'SECURITY ERROR: Expected at least 5 message policies, found %', policy_count;
    END IF;

    RAISE NOTICE '';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'SECURITY FIX COMPLETE: Messages RLS';
    RAISE NOTICE '============================================';
    RAISE NOTICE '';
    RAISE NOTICE 'NEW POLICIES:';
    RAISE NOTICE '  1. messages_insert_by_sender - Only insert as sender';
    RAISE NOTICE '  2. messages_select_direct - Only see own direct messages';
    RAISE NOTICE '  3. messages_select_group - Only see messages in joined groups';
    RAISE NOTICE '  4. messages_superadmin_select - Admin access to all messages';
    RAISE NOTICE '  5. messages_update_read_status - Only update own received messages';
    RAISE NOTICE '';
    RAISE NOTICE 'SECURITY STATUS: FIXED';
    RAISE NOTICE '  - Users can NO LONGER see other users private messages';
    RAISE NOTICE '  - Direct messages are filtered by sender/recipient';
    RAISE NOTICE '  - Group messages are filtered by membership';
    RAISE NOTICE '============================================';
END $$;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
