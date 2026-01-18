-- Migration: Add parent_students and parent_invites tables
-- =====================================================================
-- ISSUE: The deputy repository code expects two tables that don't exist:
-- 1. 'parent_students' (plural) - but schema has 'parent_student' (singular)
-- 2. 'parent_invites' - for parent-specific invite codes linked to students
--
-- This migration creates:
-- 1. A view 'parent_students' that aliases 'parent_student' for compatibility
-- 2. A new 'parent_invites' table for parent onboarding functionality
-- =====================================================================

-- =====================================================================
-- PART 1: Create parent_students view (alias for parent_student table)
-- =====================================================================
-- The code uses 'parent_students' (plural) but the table is 'parent_student' (singular)
-- Create a view to provide compatibility

DO $$
BEGIN
    -- Check if the view already exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.views
        WHERE table_schema = 'public'
        AND table_name = 'parent_students'
    ) THEN
        -- Create a view that aliases the parent_student table
        -- Note: parent_student table only has: parent_id, student_id, relationship (no created_at)
        CREATE VIEW parent_students AS
        SELECT
            parent_id,
            student_id,
            relationship,
            -- Add school_id by joining with profiles for queries that filter by school
            (SELECT school_id FROM profiles WHERE id = parent_student.student_id) as school_id
        FROM parent_student;

        COMMENT ON VIEW parent_students IS 'Compatibility view for parent_student table (plural naming)';

        RAISE NOTICE 'Created parent_students view';
    ELSE
        RAISE NOTICE 'parent_students view already exists, skipping creation';
    END IF;
END $$;

-- =====================================================================
-- PART 2: Create parent_invites table
-- =====================================================================
-- This table stores invite codes specifically for parents to link with students

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'parent_invites'
    ) THEN
        -- Create the parent_invites table
        CREATE TABLE parent_invites (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            code TEXT UNIQUE NOT NULL,
            student_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
            school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
            times_used INT NOT NULL DEFAULT 0,
            usage_limit INT NOT NULL DEFAULT 1,
            parent_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
            created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            used_at TIMESTAMPTZ,
            expires_at TIMESTAMPTZ,
            created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
            CONSTRAINT check_parent_invite_usage CHECK (times_used <= usage_limit),
            CONSTRAINT check_parent_invite_usage_limit CHECK (usage_limit > 0)
        );

        -- Add comment
        COMMENT ON TABLE parent_invites IS 'Invite codes for parents to register and link to their children';

        -- Create indexes for performance
        CREATE INDEX idx_parent_invites_code ON parent_invites(code);
        CREATE INDEX idx_parent_invites_student_id ON parent_invites(student_id);
        CREATE INDEX idx_parent_invites_school_id ON parent_invites(school_id);
        CREATE INDEX idx_parent_invites_parent_id ON parent_invites(parent_id);
        CREATE INDEX idx_parent_invites_expires_at ON parent_invites(expires_at);
        CREATE INDEX idx_parent_invites_active ON parent_invites(school_id) WHERE times_used < usage_limit;

        -- Enable RLS
        ALTER TABLE parent_invites ENABLE ROW LEVEL SECURITY;

        -- =====================================================================
        -- RLS Policies for parent_invites
        -- =====================================================================

        -- Admins and bigadmins (principals) can view parent invites for their school
        CREATE POLICY "School staff can view parent invites"
            ON parent_invites FOR SELECT
            TO authenticated
            USING (
                EXISTS (
                    SELECT 1 FROM profiles p
                    WHERE p.id = auth.uid()
                    AND (
                        p.role = 'superadmin'
                        OR (
                            p.role IN ('admin', 'bigadmin')
                            AND p.school_id = parent_invites.school_id
                        )
                    )
                )
            );

        -- Admins and bigadmins (principals) can create parent invites for their school
        CREATE POLICY "School staff can create parent invites"
            ON parent_invites FOR INSERT
            TO authenticated
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM profiles p
                    WHERE p.id = auth.uid()
                    AND (
                        p.role = 'superadmin'
                        OR (
                            p.role IN ('admin', 'bigadmin')
                            AND p.school_id = parent_invites.school_id
                        )
                    )
                )
            );

        -- Admins and bigadmins (principals) can update parent invites for their school
        CREATE POLICY "School staff can update parent invites"
            ON parent_invites FOR UPDATE
            TO authenticated
            USING (
                EXISTS (
                    SELECT 1 FROM profiles p
                    WHERE p.id = auth.uid()
                    AND (
                        p.role = 'superadmin'
                        OR (
                            p.role IN ('admin', 'bigadmin')
                            AND p.school_id = parent_invites.school_id
                        )
                    )
                )
            );

        -- Admins and bigadmins (principals) can delete parent invites for their school
        CREATE POLICY "School staff can delete parent invites"
            ON parent_invites FOR DELETE
            TO authenticated
            USING (
                EXISTS (
                    SELECT 1 FROM profiles p
                    WHERE p.id = auth.uid()
                    AND (
                        p.role = 'superadmin'
                        OR (
                            p.role IN ('admin', 'bigadmin')
                            AND p.school_id = parent_invites.school_id
                        )
                    )
                )
            );

        -- Anyone can view active (unused, non-expired) invites by code for registration
        -- This allows parents to validate their invite code during registration
        CREATE POLICY "Anyone can view active invites by code"
            ON parent_invites FOR SELECT
            TO authenticated
            USING (
                times_used < usage_limit
                AND (expires_at IS NULL OR expires_at > now())
            );

        -- Parents can view their own used invites (for history)
        CREATE POLICY "Parents can view their used invites"
            ON parent_invites FOR SELECT
            TO authenticated
            USING (parent_id = auth.uid());

        -- Superadmin has full access
        CREATE POLICY "Superadmin has full access to parent invites"
            ON parent_invites FOR ALL
            TO authenticated
            USING (
                EXISTS (
                    SELECT 1 FROM profiles
                    WHERE id = auth.uid()
                    AND role = 'superadmin'
                )
            )
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM profiles
                    WHERE id = auth.uid()
                    AND role = 'superadmin'
                )
            );

        RAISE NOTICE 'Created parent_invites table with RLS policies';
    ELSE
        RAISE NOTICE 'parent_invites table already exists, skipping creation';
    END IF;
END $$;

-- =====================================================================
-- PART 3: Create helper function for using parent invites
-- =====================================================================
-- This function is called when a parent uses an invite code to link with a student

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
AS $$
DECLARE
    v_invite parent_invites%ROWTYPE;
BEGIN
    -- Find the invite by code
    SELECT * INTO v_invite
    FROM parent_invites
    WHERE code = p_code;

    -- Check if invite exists
    IF v_invite.id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Invalid invite code'::TEXT, NULL::UUID, NULL::UUID;
        RETURN;
    END IF;

    -- Check if invite has been fully used
    IF v_invite.times_used >= v_invite.usage_limit THEN
        RETURN QUERY SELECT FALSE, 'Invite code has already been used'::TEXT, NULL::UUID, NULL::UUID;
        RETURN;
    END IF;

    -- Check if invite has expired
    IF v_invite.expires_at IS NOT NULL AND v_invite.expires_at < now() THEN
        RETURN QUERY SELECT FALSE, 'Invite code has expired'::TEXT, NULL::UUID, NULL::UUID;
        RETURN;
    END IF;

    -- Update the invite to mark it as used
    UPDATE parent_invites
    SET
        times_used = times_used + 1,
        parent_id = p_parent_id,
        used_at = now()
    WHERE id = v_invite.id;

    -- Create the parent-student relationship
    INSERT INTO parent_student (parent_id, student_id, relationship)
    VALUES (p_parent_id, v_invite.student_id, 'parent')
    ON CONFLICT (parent_id, student_id) DO NOTHING;

    -- Return success with student and school info
    RETURN QUERY SELECT
        TRUE,
        'Successfully linked to student'::TEXT,
        v_invite.student_id,
        v_invite.school_id;
END;
$$;

COMMENT ON FUNCTION use_parent_invite IS 'Validates and uses a parent invite code, creating the parent-student relationship';

-- =====================================================================
-- END OF MIGRATION
-- =====================================================================
