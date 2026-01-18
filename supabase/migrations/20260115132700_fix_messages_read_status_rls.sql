-- ============================================================================
-- Migration: 20260115132700_fix_messages_read_status_rls.sql
-- FIX: Allow marking both direct and group messages as read
--
-- PROBLEM: The current UPDATE policy only allows updating messages where
-- recipient_id = auth.uid(). This works for direct messages, but group messages
-- have recipient_id = NULL (they use group_id instead). As a result, users
-- cannot mark group messages as read, and the unread notification badge
-- never clears for group conversations.
--
-- SOLUTION: Modify the UPDATE policy to allow:
-- 1. Direct messages: recipient_id = auth.uid() (existing behavior)
-- 2. Group messages: group_id IS NOT NULL AND is_group_member(group_id)
--                    AND sender_id != auth.uid() (can't mark own messages)
-- ============================================================================

-- Drop the existing restrictive policy
DROP POLICY IF EXISTS "messages_update_read_status" ON messages;

DO $$
BEGIN
    RAISE NOTICE 'Dropped existing messages_update_read_status policy';
END $$;

-- Create new policy that handles both direct and group messages
CREATE POLICY "messages_update_read_status" ON messages
    FOR UPDATE
    TO authenticated
    USING (
        -- Direct messages: user is the recipient
        (recipient_id = auth.uid())
        OR
        -- Group messages: user is a member of the group and not the sender
        (group_id IS NOT NULL AND is_group_member(group_id) AND sender_id != auth.uid())
    )
    WITH CHECK (
        -- Direct messages: user is the recipient
        (recipient_id = auth.uid())
        OR
        -- Group messages: user is a member of the group and not the sender
        (group_id IS NOT NULL AND is_group_member(group_id) AND sender_id != auth.uid())
    );

COMMENT ON POLICY "messages_update_read_status" ON messages IS
'SECURITY: Users can update read status on:
  1. Direct messages where they are the recipient
  2. Group messages where they are a member (not their own messages)';

DO $$
BEGIN
    RAISE NOTICE 'Created new messages_update_read_status policy that handles both direct and group messages';
END $$;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

DO $$
DECLARE
    policy_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'messages'
          AND policyname = 'messages_update_read_status'
          AND schemaname = 'public'
    ) INTO policy_exists;

    IF NOT policy_exists THEN
        RAISE EXCEPTION 'ERROR: messages_update_read_status policy was not created';
    END IF;

    RAISE NOTICE '';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'FIX COMPLETE: Messages Read Status RLS';
    RAISE NOTICE '============================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Users can now mark as read:';
    RAISE NOTICE '  - Direct messages where they are the recipient';
    RAISE NOTICE '  - Group messages where they are a member';
    RAISE NOTICE '';
    RAISE NOTICE 'This fixes the notification badge not clearing';
    RAISE NOTICE 'after reading messages in a conversation.';
    RAISE NOTICE '============================================';
END $$;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
