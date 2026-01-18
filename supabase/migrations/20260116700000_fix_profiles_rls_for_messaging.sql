-- ============================================================================
-- Migration: 20260116700000_fix_profiles_rls_for_messaging.sql
-- Fix: Allow users to view profiles of users they have message conversations with
--
-- PROBLEM: Users see "Unknown User" instead of actual names in the chat because
-- RLS policies on profiles table don't allow viewing profiles of messaging
-- partners who fall outside their normal visibility scope.
--
-- EXAMPLE SCENARIOS:
-- - Teacher messages a parent -> Teacher sees "Unknown User" (can't view parent profiles)
-- - Parent messages a student (not their child) -> Parent sees "Unknown User"
-- - Student receives message from parent -> Student sees "Unknown User"
--
-- SOLUTION: Add an RLS policy that allows users to view the profile of anyone
-- they have exchanged messages with (sender_id or recipient_id in messages table).
-- ============================================================================

-- ============================================================================
-- STEP 1: Create helper function to check if user has message relationship
-- This function checks if the current user has exchanged messages with a target user
-- ============================================================================

CREATE OR REPLACE FUNCTION auth_has_message_relationship(target_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1 FROM messages
        WHERE (sender_id = auth.uid() AND recipient_id = target_user_id)
           OR (sender_id = target_user_id AND recipient_id = auth.uid())
        LIMIT 1
    );
$$;

COMMENT ON FUNCTION auth_has_message_relationship(UUID) IS
'Returns TRUE if the current user has exchanged direct messages with the target user. Used for RLS policies.';

GRANT EXECUTE ON FUNCTION auth_has_message_relationship(UUID) TO authenticated;

DO $$
BEGIN
    RAISE NOTICE '✓ Created auth_has_message_relationship() function';
END $$;

-- ============================================================================
-- STEP 2: Create helper function to check if user shares a message group
-- This function checks if the current user shares a message group with a target user
-- ============================================================================

CREATE OR REPLACE FUNCTION auth_shares_message_group(target_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1 FROM message_group_members mgm1
        JOIN message_group_members mgm2 ON mgm1.group_id = mgm2.group_id
        WHERE mgm1.user_id = auth.uid()
          AND mgm2.user_id = target_user_id
        LIMIT 1
    );
$$;

COMMENT ON FUNCTION auth_shares_message_group(UUID) IS
'Returns TRUE if the current user shares at least one message group with the target user. Used for RLS policies.';

GRANT EXECUTE ON FUNCTION auth_shares_message_group(UUID) TO authenticated;

DO $$
BEGIN
    RAISE NOTICE '✓ Created auth_shares_message_group() function';
END $$;

-- ============================================================================
-- STEP 3: Add RLS policy for viewing profiles of messaging contacts
-- ============================================================================

-- Drop if exists to allow re-running
DROP POLICY IF EXISTS "profiles_select_message_contacts" ON profiles;

-- Policy: Users can view profiles of users they have direct message conversations with
CREATE POLICY "profiles_select_message_contacts" ON profiles
    FOR SELECT
    TO authenticated
    USING (auth_has_message_relationship(id));

COMMENT ON POLICY "profiles_select_message_contacts" ON profiles IS
'Allow users to view profiles of users they have exchanged direct messages with';

DO $$
BEGIN
    RAISE NOTICE '✓ Created "profiles_select_message_contacts" policy';
END $$;

-- ============================================================================
-- STEP 4: Add RLS policy for viewing profiles of group members
-- ============================================================================

-- Drop if exists to allow re-running
DROP POLICY IF EXISTS "profiles_select_group_members" ON profiles;

-- Policy: Users can view profiles of users they share message groups with
CREATE POLICY "profiles_select_group_members" ON profiles
    FOR SELECT
    TO authenticated
    USING (auth_shares_message_group(id));

COMMENT ON POLICY "profiles_select_group_members" ON profiles IS
'Allow users to view profiles of users they share message groups with';

DO $$
BEGIN
    RAISE NOTICE '✓ Created "profiles_select_group_members" policy';
END $$;

-- ============================================================================
-- STEP 5: Create indexes to optimize the message relationship queries
-- ============================================================================

-- Index for efficient lookups of messages by sender_id
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);

-- Index for efficient lookups of messages by recipient_id
CREATE INDEX IF NOT EXISTS idx_messages_recipient_id ON messages(recipient_id);

-- Composite index for sender/recipient lookup (common query pattern)
CREATE INDEX IF NOT EXISTS idx_messages_sender_recipient ON messages(sender_id, recipient_id);

-- Index for efficient group member lookups
CREATE INDEX IF NOT EXISTS idx_message_group_members_user_id ON message_group_members(user_id);

DO $$
BEGIN
    RAISE NOTICE '✓ Created performance indexes for message queries';
END $$;

-- ============================================================================
-- STEP 6: Verification
-- ============================================================================

DO $$
DECLARE
    policy_count INTEGER;
BEGIN
    -- Check that the new policies exist
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies
    WHERE tablename = 'profiles'
      AND schemaname = 'public'
      AND policyname IN ('profiles_select_message_contacts', 'profiles_select_group_members');

    IF policy_count < 2 THEN
        RAISE EXCEPTION 'FAILED: Expected 2 new policies, found %', policy_count;
    END IF;

    RAISE NOTICE '';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'MIGRATION COMPLETE: Profiles RLS for Messaging';
    RAISE NOTICE '============================================';
    RAISE NOTICE '';
    RAISE NOTICE 'NEW POLICIES ADDED:';
    RAISE NOTICE '  1. profiles_select_message_contacts';
    RAISE NOTICE '     - Allows viewing profiles of users you have messaged';
    RAISE NOTICE '';
    RAISE NOTICE '  2. profiles_select_group_members';
    RAISE NOTICE '     - Allows viewing profiles of users in shared groups';
    RAISE NOTICE '';
    RAISE NOTICE 'HELPER FUNCTIONS:';
    RAISE NOTICE '  - auth_has_message_relationship(UUID)';
    RAISE NOTICE '  - auth_shares_message_group(UUID)';
    RAISE NOTICE '';
    RAISE NOTICE 'This fixes the "Unknown User" issue in messaging!';
    RAISE NOTICE '============================================';
    RAISE NOTICE '';
END $$;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
