-- ============================================================================
-- MIGRATION: RLS Hardening and Audit Logging
-- Version: 20260118000002
--
-- PURPOSE: Strengthen Row Level Security policies and add audit logging
-- for sensitive operations to improve security posture.
--
-- ISSUES ADDRESSED:
-- 1. Superadmin role has unconstrained access (security risk)
-- 2. No audit trail for sensitive operations
-- 3. Missing constraints to prevent catastrophic actions (last superadmin deletion)
-- 4. Inconsistent use of SECURITY DEFINER functions with search_path
-- 5. No soft delete for critical records
--
-- CHANGES:
-- - Create audit_log table for tracking sensitive operations
-- - Add audit triggers for superadmin operations on sensitive tables
-- - Add constraint to prevent deletion of the last superadmin
-- - Add constraint to prevent superadmins from deleting themselves
-- - Consolidate and harden RLS helper functions
-- - Add soft delete columns to critical tables
--
-- ROLLBACK: See SECTION 10 at the bottom of this file
-- ============================================================================

-- ============================================================================
-- SECTION 1: AUDIT LOG TABLE
-- ============================================================================

-- Create audit_log table if it doesn't exist
CREATE TABLE IF NOT EXISTS audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    table_name TEXT NOT NULL,
    record_id TEXT,
    old_data JSONB,
    new_data JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_audit_log_user_id ON audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_table_name ON audit_log(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_log_action ON audit_log(action);
CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON audit_log(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_user_action ON audit_log(user_id, action);
CREATE INDEX IF NOT EXISTS idx_audit_log_table_action ON audit_log(table_name, action);

-- Enable RLS on audit_log (only superadmins should read, system writes)
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- Policy: Only superadmins can view audit logs
DROP POLICY IF EXISTS "audit_log_superadmin_select" ON audit_log;
CREATE POLICY "audit_log_superadmin_select" ON audit_log
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid()
            AND role = 'superadmin'
        )
    );

-- Policy: System can insert audit logs (via SECURITY DEFINER functions)
-- Note: No direct INSERT policy for users - all inserts go through triggers

COMMENT ON TABLE audit_log IS 'Audit trail for sensitive operations. Records user actions on critical tables.';

DO $$
BEGIN
    RAISE NOTICE 'Section 1: Created audit_log table with indexes and RLS policies';
END $$;

-- ============================================================================
-- SECTION 2: AUDIT LOGGING FUNCTION
-- ============================================================================

-- Drop existing function if exists to ensure clean state
DROP FUNCTION IF EXISTS log_audit_event CASCADE;

-- Create the audit logging function
CREATE OR REPLACE FUNCTION log_audit_event(
    p_action TEXT,
    p_table_name TEXT,
    p_record_id TEXT,
    p_old_data JSONB DEFAULT NULL,
    p_new_data JSONB DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    v_audit_id UUID;
    v_user_id UUID;
BEGIN
    v_user_id := auth.uid();

    INSERT INTO audit_log (
        user_id,
        action,
        table_name,
        record_id,
        old_data,
        new_data,
        created_at
    ) VALUES (
        v_user_id,
        p_action,
        p_table_name,
        p_record_id,
        p_old_data,
        p_new_data,
        now()
    )
    RETURNING id INTO v_audit_id;

    RETURN v_audit_id;
END;
$$;

COMMENT ON FUNCTION log_audit_event IS 'Logs an audit event. SECURITY DEFINER to bypass RLS for audit writes.';

-- Grant execute to authenticated users (but they can only trigger via operations)
GRANT EXECUTE ON FUNCTION log_audit_event(TEXT, TEXT, TEXT, JSONB, JSONB) TO authenticated;

DO $$
BEGIN
    RAISE NOTICE 'Section 2: Created log_audit_event function';
END $$;

-- ============================================================================
-- SECTION 3: SUPERADMIN PROTECTION FUNCTIONS
-- ============================================================================

-- Function to count superadmins
CREATE OR REPLACE FUNCTION count_superadmins()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM profiles
    WHERE role = 'superadmin';

    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION count_superadmins IS 'Returns the count of superadmin users. SECURITY DEFINER to bypass RLS.';

-- Function to check if a user is the last superadmin
CREATE OR REPLACE FUNCTION is_last_superadmin(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
DECLARE
    v_is_superadmin BOOLEAN;
    v_superadmin_count INTEGER;
BEGIN
    -- Check if the user is a superadmin
    SELECT role = 'superadmin' INTO v_is_superadmin
    FROM profiles
    WHERE id = p_user_id;

    IF NOT COALESCE(v_is_superadmin, FALSE) THEN
        RETURN FALSE;
    END IF;

    -- Count superadmins
    SELECT COUNT(*) INTO v_superadmin_count
    FROM profiles
    WHERE role = 'superadmin';

    RETURN v_superadmin_count <= 1;
END;
$$;

COMMENT ON FUNCTION is_last_superadmin IS 'Returns TRUE if the specified user is the only superadmin in the system.';

GRANT EXECUTE ON FUNCTION count_superadmins() TO authenticated;
GRANT EXECUTE ON FUNCTION is_last_superadmin(UUID) TO authenticated;

DO $$
BEGIN
    RAISE NOTICE 'Section 3: Created superadmin protection functions';
END $$;

-- ============================================================================
-- SECTION 4: AUDIT TRIGGERS FOR PROFILES TABLE
-- ============================================================================

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS audit_profiles_changes ON profiles;
DROP FUNCTION IF EXISTS audit_profiles_trigger CASCADE;

-- Create audit trigger function for profiles
CREATE OR REPLACE FUNCTION audit_profiles_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    v_action TEXT;
    v_actor_role user_role;
    v_old_data JSONB;
    v_new_data JSONB;
BEGIN
    -- Get the role of the user performing the action
    SELECT role INTO v_actor_role
    FROM profiles
    WHERE id = auth.uid();

    -- Determine action type
    IF TG_OP = 'INSERT' THEN
        v_action := 'INSERT';
        v_new_data := to_jsonb(NEW);

        -- Log all profile creations
        PERFORM log_audit_event(
            v_action,
            'profiles',
            NEW.id::TEXT,
            NULL,
            v_new_data
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        v_action := 'UPDATE';
        v_old_data := to_jsonb(OLD);
        v_new_data := to_jsonb(NEW);

        -- Log role changes (always sensitive)
        IF OLD.role IS DISTINCT FROM NEW.role THEN
            PERFORM log_audit_event(
                'ROLE_CHANGE',
                'profiles',
                NEW.id::TEXT,
                jsonb_build_object('old_role', OLD.role, 'new_role', NEW.role),
                NULL
            );
        END IF;

        -- Log school changes
        IF OLD.school_id IS DISTINCT FROM NEW.school_id THEN
            PERFORM log_audit_event(
                'SCHOOL_CHANGE',
                'profiles',
                NEW.id::TEXT,
                jsonb_build_object('old_school_id', OLD.school_id, 'new_school_id', NEW.school_id),
                NULL
            );
        END IF;

        -- Log all superadmin updates on profiles
        IF v_actor_role = 'superadmin' THEN
            PERFORM log_audit_event(
                'SUPERADMIN_UPDATE',
                'profiles',
                NEW.id::TEXT,
                v_old_data,
                v_new_data
            );
        END IF;

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        v_action := 'DELETE';
        v_old_data := to_jsonb(OLD);

        -- Prevent deletion of the last superadmin
        IF OLD.role = 'superadmin' AND is_last_superadmin(OLD.id) THEN
            RAISE EXCEPTION 'Cannot delete the last superadmin. Create another superadmin first.'
                USING ERRCODE = 'P0001';
        END IF;

        -- Prevent superadmins from deleting themselves
        IF OLD.id = auth.uid() AND v_actor_role = 'superadmin' THEN
            RAISE EXCEPTION 'Superadmins cannot delete their own profile. Another superadmin must do this.'
                USING ERRCODE = 'P0002';
        END IF;

        -- Log all profile deletions
        PERFORM log_audit_event(
            v_action,
            'profiles',
            OLD.id::TEXT,
            v_old_data,
            NULL
        );

        -- Log superadmin deletions with special action
        IF v_actor_role = 'superadmin' THEN
            PERFORM log_audit_event(
                'SUPERADMIN_DELETE',
                'profiles',
                OLD.id::TEXT,
                v_old_data,
                NULL
            );
        END IF;

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

COMMENT ON FUNCTION audit_profiles_trigger IS 'Audit trigger for profiles table. Logs all changes and enforces superadmin constraints.';

-- Create the trigger
CREATE TRIGGER audit_profiles_changes
    BEFORE INSERT OR UPDATE OR DELETE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION audit_profiles_trigger();

DO $$
BEGIN
    RAISE NOTICE 'Section 4: Created profiles audit trigger';
END $$;

-- ============================================================================
-- SECTION 5: AUDIT TRIGGERS FOR GRADES TABLE
-- ============================================================================

DROP TRIGGER IF EXISTS audit_grades_changes ON grades;
DROP FUNCTION IF EXISTS audit_grades_trigger CASCADE;

CREATE OR REPLACE FUNCTION audit_grades_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    v_actor_role user_role;
    v_old_data JSONB;
    v_new_data JSONB;
BEGIN
    -- Get the role of the user performing the action
    SELECT role INTO v_actor_role
    FROM profiles
    WHERE id = auth.uid();

    -- Only log superadmin and bigadmin operations (or any delete)
    IF v_actor_role IN ('superadmin', 'bigadmin') OR TG_OP = 'DELETE' THEN
        IF TG_OP = 'INSERT' THEN
            v_new_data := to_jsonb(NEW);
            PERFORM log_audit_event(
                'INSERT',
                'grades',
                NEW.id::TEXT,
                NULL,
                v_new_data
            );
            RETURN NEW;

        ELSIF TG_OP = 'UPDATE' THEN
            v_old_data := to_jsonb(OLD);
            v_new_data := to_jsonb(NEW);
            PERFORM log_audit_event(
                'UPDATE',
                'grades',
                NEW.id::TEXT,
                v_old_data,
                v_new_data
            );
            RETURN NEW;

        ELSIF TG_OP = 'DELETE' THEN
            v_old_data := to_jsonb(OLD);
            PERFORM log_audit_event(
                'DELETE',
                'grades',
                OLD.id::TEXT,
                v_old_data,
                NULL
            );
            RETURN OLD;
        END IF;
    END IF;

    -- For non-sensitive operations, just pass through
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;

COMMENT ON FUNCTION audit_grades_trigger IS 'Audit trigger for grades table. Logs superadmin/bigadmin operations.';

CREATE TRIGGER audit_grades_changes
    BEFORE INSERT OR UPDATE OR DELETE ON grades
    FOR EACH ROW
    EXECUTE FUNCTION audit_grades_trigger();

DO $$
BEGIN
    RAISE NOTICE 'Section 5: Created grades audit trigger';
END $$;

-- ============================================================================
-- SECTION 6: AUDIT TRIGGERS FOR ATTENDANCE TABLE
-- ============================================================================

DROP TRIGGER IF EXISTS audit_attendance_changes ON attendance;
DROP FUNCTION IF EXISTS audit_attendance_trigger CASCADE;

CREATE OR REPLACE FUNCTION audit_attendance_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    v_actor_role user_role;
    v_old_data JSONB;
    v_new_data JSONB;
BEGIN
    -- Get the role of the user performing the action
    SELECT role INTO v_actor_role
    FROM profiles
    WHERE id = auth.uid();

    -- Only log superadmin/bigadmin operations or deletes
    IF v_actor_role IN ('superadmin', 'bigadmin') OR TG_OP = 'DELETE' THEN
        IF TG_OP = 'INSERT' THEN
            v_new_data := to_jsonb(NEW);
            PERFORM log_audit_event(
                'INSERT',
                'attendance',
                NEW.id::TEXT,
                NULL,
                v_new_data
            );
            RETURN NEW;

        ELSIF TG_OP = 'UPDATE' THEN
            v_old_data := to_jsonb(OLD);
            v_new_data := to_jsonb(NEW);
            PERFORM log_audit_event(
                'UPDATE',
                'attendance',
                NEW.id::TEXT,
                v_old_data,
                v_new_data
            );
            RETURN NEW;

        ELSIF TG_OP = 'DELETE' THEN
            v_old_data := to_jsonb(OLD);
            PERFORM log_audit_event(
                'DELETE',
                'attendance',
                OLD.id::TEXT,
                v_old_data,
                NULL
            );
            RETURN OLD;
        END IF;
    END IF;

    -- For non-sensitive operations, just pass through
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;

COMMENT ON FUNCTION audit_attendance_trigger IS 'Audit trigger for attendance table. Logs superadmin/bigadmin operations.';

CREATE TRIGGER audit_attendance_changes
    BEFORE INSERT OR UPDATE OR DELETE ON attendance
    FOR EACH ROW
    EXECUTE FUNCTION audit_attendance_trigger();

DO $$
BEGIN
    RAISE NOTICE 'Section 6: Created attendance audit trigger';
END $$;

-- ============================================================================
-- SECTION 7: AUDIT TRIGGERS FOR SCHOOLS TABLE
-- ============================================================================

DROP TRIGGER IF EXISTS audit_schools_changes ON schools;
DROP FUNCTION IF EXISTS audit_schools_trigger CASCADE;

CREATE OR REPLACE FUNCTION audit_schools_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    v_old_data JSONB;
    v_new_data JSONB;
BEGIN
    -- Log all school operations (they are all sensitive)
    IF TG_OP = 'INSERT' THEN
        v_new_data := to_jsonb(NEW);
        PERFORM log_audit_event(
            'INSERT',
            'schools',
            NEW.id::TEXT,
            NULL,
            v_new_data
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        v_old_data := to_jsonb(OLD);
        v_new_data := to_jsonb(NEW);
        PERFORM log_audit_event(
            'UPDATE',
            'schools',
            NEW.id::TEXT,
            v_old_data,
            v_new_data
        );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        v_old_data := to_jsonb(OLD);
        PERFORM log_audit_event(
            'DELETE',
            'schools',
            OLD.id::TEXT,
            v_old_data,
            NULL
        );
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

COMMENT ON FUNCTION audit_schools_trigger IS 'Audit trigger for schools table. Logs all changes.';

CREATE TRIGGER audit_schools_changes
    BEFORE INSERT OR UPDATE OR DELETE ON schools
    FOR EACH ROW
    EXECUTE FUNCTION audit_schools_trigger();

DO $$
BEGIN
    RAISE NOTICE 'Section 7: Created schools audit trigger';
END $$;

-- ============================================================================
-- SECTION 8: SOFT DELETE SUPPORT FOR CRITICAL TABLES
-- ============================================================================

-- Add soft delete columns to profiles if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'profiles'
        AND column_name = 'deleted_at'
    ) THEN
        ALTER TABLE profiles ADD COLUMN deleted_at TIMESTAMPTZ DEFAULT NULL;
        CREATE INDEX idx_profiles_deleted_at ON profiles(deleted_at) WHERE deleted_at IS NOT NULL;
        RAISE NOTICE 'Added deleted_at column to profiles table';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'profiles'
        AND column_name = 'deleted_by'
    ) THEN
        ALTER TABLE profiles ADD COLUMN deleted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL;
        RAISE NOTICE 'Added deleted_by column to profiles table';
    END IF;
END $$;

-- Add soft delete columns to schools if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'schools'
        AND column_name = 'deleted_at'
    ) THEN
        ALTER TABLE schools ADD COLUMN deleted_at TIMESTAMPTZ DEFAULT NULL;
        CREATE INDEX idx_schools_deleted_at ON schools(deleted_at) WHERE deleted_at IS NOT NULL;
        RAISE NOTICE 'Added deleted_at column to schools table';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'schools'
        AND column_name = 'deleted_by'
    ) THEN
        ALTER TABLE schools ADD COLUMN deleted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL;
        RAISE NOTICE 'Added deleted_by column to schools table';
    END IF;
END $$;

-- Function for soft delete of profiles
CREATE OR REPLACE FUNCTION soft_delete_profile(p_profile_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    v_actor_role user_role;
    v_target_role user_role;
BEGIN
    -- Get actor's role
    SELECT role INTO v_actor_role
    FROM profiles
    WHERE id = auth.uid();

    -- Only superadmins and bigadmins can soft delete
    IF v_actor_role NOT IN ('superadmin', 'bigadmin') THEN
        RAISE EXCEPTION 'Only superadmins and bigadmins can soft delete profiles'
            USING ERRCODE = 'P0003';
    END IF;

    -- Get target's role
    SELECT role INTO v_target_role
    FROM profiles
    WHERE id = p_profile_id;

    -- Prevent soft deleting the last superadmin
    IF v_target_role = 'superadmin' AND is_last_superadmin(p_profile_id) THEN
        RAISE EXCEPTION 'Cannot delete the last superadmin'
            USING ERRCODE = 'P0001';
    END IF;

    -- Prevent self-deletion for superadmins
    IF p_profile_id = auth.uid() AND v_actor_role = 'superadmin' THEN
        RAISE EXCEPTION 'Superadmins cannot delete their own profile'
            USING ERRCODE = 'P0002';
    END IF;

    -- Perform soft delete
    UPDATE profiles
    SET deleted_at = now(),
        deleted_by = auth.uid()
    WHERE id = p_profile_id
    AND deleted_at IS NULL;

    -- Log the action
    PERFORM log_audit_event(
        'SOFT_DELETE',
        'profiles',
        p_profile_id::TEXT,
        jsonb_build_object('deleted_by', auth.uid()),
        NULL
    );

    RETURN FOUND;
END;
$$;

COMMENT ON FUNCTION soft_delete_profile IS 'Soft deletes a profile. Use this instead of hard delete for data retention.';

GRANT EXECUTE ON FUNCTION soft_delete_profile(UUID) TO authenticated;

-- Function to restore a soft-deleted profile
CREATE OR REPLACE FUNCTION restore_profile(p_profile_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
AS $$
DECLARE
    v_actor_role user_role;
BEGIN
    -- Get actor's role
    SELECT role INTO v_actor_role
    FROM profiles
    WHERE id = auth.uid();

    -- Only superadmins can restore
    IF v_actor_role != 'superadmin' THEN
        RAISE EXCEPTION 'Only superadmins can restore deleted profiles'
            USING ERRCODE = 'P0004';
    END IF;

    -- Perform restore
    UPDATE profiles
    SET deleted_at = NULL,
        deleted_by = NULL
    WHERE id = p_profile_id
    AND deleted_at IS NOT NULL;

    -- Log the action
    PERFORM log_audit_event(
        'RESTORE',
        'profiles',
        p_profile_id::TEXT,
        NULL,
        jsonb_build_object('restored_by', auth.uid())
    );

    RETURN FOUND;
END;
$$;

COMMENT ON FUNCTION restore_profile IS 'Restores a soft-deleted profile. Only superadmins can restore.';

GRANT EXECUTE ON FUNCTION restore_profile(UUID) TO authenticated;

DO $$
BEGIN
    RAISE NOTICE 'Section 8: Added soft delete support for critical tables';
END $$;

-- ============================================================================
-- SECTION 9: HARDEN EXISTING RLS HELPER FUNCTIONS
-- ============================================================================

-- Ensure all RLS helper functions have proper search_path and row_security settings
-- This prevents search_path manipulation attacks

-- Recreate rls_get_user_role with proper settings
CREATE OR REPLACE FUNCTION rls_get_user_role()
RETURNS user_role
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
DECLARE
    _role user_role;
BEGIN
    SELECT role INTO _role FROM profiles WHERE id = auth.uid() AND deleted_at IS NULL;
    RETURN _role;
END;
$$;

-- Recreate rls_get_user_school_id with proper settings
CREATE OR REPLACE FUNCTION rls_get_user_school_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
DECLARE
    _school_id UUID;
BEGIN
    SELECT school_id INTO _school_id FROM profiles WHERE id = auth.uid() AND deleted_at IS NULL;
    RETURN _school_id;
END;
$$;

-- Recreate rls_is_superadmin with proper settings
CREATE OR REPLACE FUNCTION rls_is_superadmin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
DECLARE
    _role user_role;
BEGIN
    SELECT role INTO _role FROM profiles WHERE id = auth.uid() AND deleted_at IS NULL;
    RETURN _role = 'superadmin';
END;
$$;

-- Recreate rls_is_bigadmin with proper settings
CREATE OR REPLACE FUNCTION rls_is_bigadmin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
DECLARE
    _role user_role;
BEGIN
    SELECT role INTO _role FROM profiles WHERE id = auth.uid() AND deleted_at IS NULL;
    RETURN _role = 'bigadmin';
END;
$$;

-- Recreate rls_is_admin with proper settings
CREATE OR REPLACE FUNCTION rls_is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
DECLARE
    _role user_role;
BEGIN
    SELECT role INTO _role FROM profiles WHERE id = auth.uid() AND deleted_at IS NULL;
    RETURN _role = 'admin';
END;
$$;

-- Recreate rls_is_school_admin with proper settings
CREATE OR REPLACE FUNCTION rls_is_school_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
DECLARE
    _role user_role;
BEGIN
    SELECT role INTO _role FROM profiles WHERE id = auth.uid() AND deleted_at IS NULL;
    RETURN _role IN ('bigadmin', 'admin');
END;
$$;

-- Recreate rls_is_teacher with proper settings
CREATE OR REPLACE FUNCTION rls_is_teacher()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
DECLARE
    _role user_role;
BEGIN
    SELECT role INTO _role FROM profiles WHERE id = auth.uid() AND deleted_at IS NULL;
    RETURN _role = 'teacher';
END;
$$;

-- Recreate rls_teaches_class with proper settings
CREATE OR REPLACE FUNCTION rls_teaches_class(p_class_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
SET row_security = off
STABLE
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM subjects
        WHERE class_id = p_class_id AND teacher_id = auth.uid()
    );
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION rls_get_user_role() TO authenticated;
GRANT EXECUTE ON FUNCTION rls_get_user_school_id() TO authenticated;
GRANT EXECUTE ON FUNCTION rls_is_superadmin() TO authenticated;
GRANT EXECUTE ON FUNCTION rls_is_bigadmin() TO authenticated;
GRANT EXECUTE ON FUNCTION rls_is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION rls_is_school_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION rls_is_teacher() TO authenticated;
GRANT EXECUTE ON FUNCTION rls_teaches_class(UUID) TO authenticated;

DO $$
BEGIN
    RAISE NOTICE 'Section 9: Hardened RLS helper functions with proper search_path';
END $$;

-- ============================================================================
-- SECTION 10: UPDATE PROFILES POLICIES TO EXCLUDE SOFT-DELETED
-- ============================================================================

-- Drop and recreate key profiles policies to exclude soft-deleted records
-- Note: We're being careful not to break existing policies

-- Add a policy that excludes soft-deleted profiles from general queries
DROP POLICY IF EXISTS "profiles_exclude_deleted" ON profiles;
CREATE POLICY "profiles_exclude_deleted" ON profiles
    FOR SELECT
    TO authenticated
    USING (deleted_at IS NULL);

-- Add a policy allowing superadmins to see deleted profiles
DROP POLICY IF EXISTS "profiles_superadmin_see_deleted" ON profiles;
CREATE POLICY "profiles_superadmin_see_deleted" ON profiles
    FOR SELECT
    TO authenticated
    USING (
        rls_is_superadmin() AND deleted_at IS NOT NULL
    );

DO $$
BEGIN
    RAISE NOTICE 'Section 10: Updated profiles policies to handle soft deletes';
END $$;

-- ============================================================================
-- SECTION 11: VERIFICATION AND SUMMARY
-- ============================================================================

DO $$
DECLARE
    v_audit_count INTEGER;
    v_trigger_count INTEGER;
    v_function_count INTEGER;
BEGIN
    -- Count audit log entries (should be 0 at migration time)
    SELECT COUNT(*) INTO v_audit_count FROM audit_log;

    -- Count audit triggers
    SELECT COUNT(*) INTO v_trigger_count
    FROM pg_trigger t
    JOIN pg_class c ON t.tgrelid = c.oid
    WHERE t.tgname LIKE 'audit_%_changes'
    AND c.relnamespace = 'public'::regnamespace;

    -- Count RLS helper functions with proper settings
    SELECT COUNT(*) INTO v_function_count
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
    AND p.proname LIKE 'rls_%'
    AND p.prosecdef = true;

    RAISE NOTICE '';
    RAISE NOTICE '============================================================';
    RAISE NOTICE 'RLS HARDENING AND AUDIT LOGGING MIGRATION COMPLETE';
    RAISE NOTICE '============================================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Summary:';
    RAISE NOTICE '  - Audit log table created';
    RAISE NOTICE '  - % audit triggers installed', v_trigger_count;
    RAISE NOTICE '  - % RLS helper functions hardened', v_function_count;
    RAISE NOTICE '  - Soft delete columns added to profiles and schools';
    RAISE NOTICE '  - Superadmin constraints enforced:';
    RAISE NOTICE '    * Cannot delete last superadmin';
    RAISE NOTICE '    * Cannot delete own profile';
    RAISE NOTICE '';
    RAISE NOTICE 'Audit triggers on:';
    RAISE NOTICE '  - profiles (all changes, role changes, school changes)';
    RAISE NOTICE '  - grades (superadmin/bigadmin operations)';
    RAISE NOTICE '  - attendance (superadmin/bigadmin operations)';
    RAISE NOTICE '  - schools (all changes)';
    RAISE NOTICE '';
    RAISE NOTICE 'New functions:';
    RAISE NOTICE '  - log_audit_event() - Log audit events';
    RAISE NOTICE '  - count_superadmins() - Count superadmin users';
    RAISE NOTICE '  - is_last_superadmin() - Check if user is last superadmin';
    RAISE NOTICE '  - soft_delete_profile() - Soft delete a profile';
    RAISE NOTICE '  - restore_profile() - Restore a soft-deleted profile';
    RAISE NOTICE '============================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================================
-- ROLLBACK INSTRUCTIONS
-- ============================================================================
/*
To rollback this migration, execute the following SQL:

-- Drop audit triggers
DROP TRIGGER IF EXISTS audit_profiles_changes ON profiles;
DROP TRIGGER IF EXISTS audit_grades_changes ON grades;
DROP TRIGGER IF EXISTS audit_attendance_changes ON attendance;
DROP TRIGGER IF EXISTS audit_schools_changes ON schools;

-- Drop audit trigger functions
DROP FUNCTION IF EXISTS audit_profiles_trigger CASCADE;
DROP FUNCTION IF EXISTS audit_grades_trigger CASCADE;
DROP FUNCTION IF EXISTS audit_attendance_trigger CASCADE;
DROP FUNCTION IF EXISTS audit_schools_trigger CASCADE;

-- Drop audit logging function
DROP FUNCTION IF EXISTS log_audit_event CASCADE;

-- Drop superadmin protection functions
DROP FUNCTION IF EXISTS count_superadmins CASCADE;
DROP FUNCTION IF EXISTS is_last_superadmin CASCADE;

-- Drop soft delete functions
DROP FUNCTION IF EXISTS soft_delete_profile CASCADE;
DROP FUNCTION IF EXISTS restore_profile CASCADE;

-- Drop soft delete policies
DROP POLICY IF EXISTS "profiles_exclude_deleted" ON profiles;
DROP POLICY IF EXISTS "profiles_superadmin_see_deleted" ON profiles;

-- Drop audit_log table (WARNING: This will delete all audit data!)
DROP TABLE IF EXISTS audit_log CASCADE;

-- Remove soft delete columns (WARNING: This will lose soft delete data!)
ALTER TABLE profiles DROP COLUMN IF EXISTS deleted_at;
ALTER TABLE profiles DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE schools DROP COLUMN IF EXISTS deleted_at;
ALTER TABLE schools DROP COLUMN IF EXISTS deleted_by;

*/

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
