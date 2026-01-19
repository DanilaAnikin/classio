-- =====================================================================
-- NUCLEAR RESET SCRIPT: Complete Database Wipe
-- =====================================================================
--
-- WARNING: This script will DELETE ALL DATA from the database!
--
-- Purpose: Reset the database to a clean state for a fresh start.
-- After running this script, you must:
--   1. Run: SELECT * FROM generate_genesis_token();
--   2. Use the returned token to register as the first Superadmin
--
-- Usage:
--   psql -h <host> -U postgres -d postgres -f reset_and_seed.sql
--   OR run in Supabase SQL Editor
-- =====================================================================

-- Disable triggers temporarily to allow deletions without constraint issues
SET session_replication_role = replica;

-- =====================================================================
-- SECTION 1: DELETE ALL DATA FROM PUBLIC TABLES
-- =====================================================================
-- Order matters due to foreign key constraints (children before parents)

-- First level: Tables with foreign keys to other tables
TRUNCATE TABLE audit_log CASCADE;
TRUNCATE TABLE genesis_token_audit_log CASCADE;
TRUNCATE TABLE message_group_members CASCADE;
TRUNCATE TABLE messages CASCADE;
TRUNCATE TABLE message_groups CASCADE;
TRUNCATE TABLE parent_student CASCADE;
TRUNCATE TABLE absence_excuses CASCADE;
TRUNCATE TABLE attendance CASCADE;
TRUNCATE TABLE submissions CASCADE;
TRUNCATE TABLE assignment_submissions CASCADE;
TRUNCATE TABLE grades CASCADE;
TRUNCATE TABLE assignments CASCADE;
TRUNCATE TABLE lessons CASCADE;
TRUNCATE TABLE materials CASCADE;
TRUNCATE TABLE class_subjects CASCADE;
TRUNCATE TABLE subjects CASCADE;
TRUNCATE TABLE class_students CASCADE;
TRUNCATE TABLE classes CASCADE;
TRUNCATE TABLE invite_tokens CASCADE;
TRUNCATE TABLE schools CASCADE;
TRUNCATE TABLE profiles CASCADE;

-- Re-enable triggers
SET session_replication_role = DEFAULT;

-- =====================================================================
-- SECTION 2: DELETE ALL AUTH USERS
-- =====================================================================
-- This requires superuser or service_role access

DELETE FROM auth.identities;
DELETE FROM auth.sessions;
DELETE FROM auth.refresh_tokens;
DELETE FROM auth.mfa_factors;
DELETE FROM auth.mfa_challenges;
DELETE FROM auth.mfa_amr_claims;
DELETE FROM auth.flow_state;
DELETE FROM auth.saml_relay_states;
DELETE FROM auth.sso_providers;
DELETE FROM auth.sso_domains;
DELETE FROM auth.one_time_tokens;
DELETE FROM auth.users;

-- =====================================================================
-- SECTION 3: RESET SEQUENCES (if any)
-- =====================================================================
-- Most tables use UUID so no sequences to reset, but just in case:

-- No sequences to reset in this schema

-- =====================================================================
-- SECTION 4: VERIFY CLEAN STATE
-- =====================================================================

DO $$
DECLARE
    table_name TEXT;
    row_count INTEGER;
    has_data BOOLEAN := FALSE;
BEGIN
    RAISE NOTICE '=== Database Reset Verification ===';

    FOR table_name IN
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I', table_name) INTO row_count;
        IF row_count > 0 THEN
            RAISE NOTICE 'WARNING: Table % still has % rows', table_name, row_count;
            has_data := TRUE;
        END IF;
    END LOOP;

    IF NOT has_data THEN
        RAISE NOTICE 'SUCCESS: All public tables are empty';
    END IF;

    -- Check auth.users
    SELECT COUNT(*) INTO row_count FROM auth.users;
    IF row_count > 0 THEN
        RAISE NOTICE 'WARNING: auth.users still has % rows', row_count;
    ELSE
        RAISE NOTICE 'SUCCESS: auth.users is empty';
    END IF;
END $$;

-- =====================================================================
-- SECTION 5: DISPLAY BOOTSTRAP INSTRUCTIONS
-- =====================================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'DATABASE RESET COMPLETE';
    RAISE NOTICE '==============================================';
    RAISE NOTICE '';
    RAISE NOTICE 'To create the first Superadmin account:';
    RAISE NOTICE '1. Run: SELECT * FROM generate_genesis_token();';
    RAISE NOTICE '2. Copy the returned token';
    RAISE NOTICE '3. Register in the app using that token';
    RAISE NOTICE '';
    RAISE NOTICE 'The token expires in 24 hours by default.';
    RAISE NOTICE '==============================================';
END $$;

-- =====================================================================
-- OPTIONAL: Generate a genesis token immediately
-- Uncomment the line below if you want to auto-generate the token
-- =====================================================================
-- SELECT * FROM generate_genesis_token();
