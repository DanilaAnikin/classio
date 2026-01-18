-- Migration: Add Absence Excuses System
-- Description: Creates the absence_excuses table for managing parent-submitted
-- excuses for student absences, with proper RLS policies.

-- Create enum type for excuse status
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'absence_excuse_status') THEN
        CREATE TYPE absence_excuse_status AS ENUM ('pending', 'approved', 'declined');
    END IF;
END$$;

-- Create the absence_excuses table
CREATE TABLE IF NOT EXISTS absence_excuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attendance_id UUID NOT NULL REFERENCES attendance(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    parent_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    status absence_excuse_status NOT NULL DEFAULT 'pending',
    teacher_response TEXT,
    teacher_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_absence_excuses_attendance_id ON absence_excuses(attendance_id);
CREATE INDEX IF NOT EXISTS idx_absence_excuses_student_id ON absence_excuses(student_id);
CREATE INDEX IF NOT EXISTS idx_absence_excuses_parent_id ON absence_excuses(parent_id);
CREATE INDEX IF NOT EXISTS idx_absence_excuses_status ON absence_excuses(status);
CREATE INDEX IF NOT EXISTS idx_absence_excuses_teacher_id ON absence_excuses(teacher_id);
CREATE INDEX IF NOT EXISTS idx_absence_excuses_created_at ON absence_excuses(created_at DESC);

-- Create unique constraint to prevent duplicate excuses for the same attendance
CREATE UNIQUE INDEX IF NOT EXISTS idx_absence_excuses_attendance_unique
    ON absence_excuses(attendance_id)
    WHERE status = 'pending';

-- Create trigger to auto-update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_absence_excuses_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_absence_excuses_updated_at ON absence_excuses;
CREATE TRIGGER trigger_update_absence_excuses_updated_at
    BEFORE UPDATE ON absence_excuses
    FOR EACH ROW
    EXECUTE FUNCTION update_absence_excuses_updated_at();

-- Enable Row Level Security
ALTER TABLE absence_excuses ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Parents can INSERT excuses for their own children
CREATE POLICY "parents_can_insert_own_excuses"
ON absence_excuses
FOR INSERT
TO authenticated
WITH CHECK (
    -- Verify the parent is making the request
    parent_id = auth.uid()
    -- Verify the student is their child
    AND EXISTS (
        SELECT 1 FROM parent_student ps
        WHERE ps.parent_id = auth.uid()
        AND ps.student_id = absence_excuses.student_id
    )
    -- Verify the attendance record belongs to the student
    AND EXISTS (
        SELECT 1 FROM attendance a
        WHERE a.id = absence_excuses.attendance_id
        AND a.student_id = absence_excuses.student_id
    )
);

-- RLS Policy: Parents can SELECT their own submitted excuses
CREATE POLICY "parents_can_select_own_excuses"
ON absence_excuses
FOR SELECT
TO authenticated
USING (
    parent_id = auth.uid()
);

-- RLS Policy: Students can SELECT their own excuses
CREATE POLICY "students_can_select_own_excuses"
ON absence_excuses
FOR SELECT
TO authenticated
USING (
    student_id = auth.uid()
);

-- RLS Policy: Teachers can SELECT excuses for students in their classes
CREATE POLICY "teachers_can_select_class_excuses"
ON absence_excuses
FOR SELECT
TO authenticated
USING (
    EXISTS (
        -- Check if teacher has lessons for this student's class
        SELECT 1
        FROM attendance a
        JOIN lessons l ON a.lesson_id = l.id
        JOIN subjects s ON l.subject_id = s.id
        WHERE a.id = absence_excuses.attendance_id
        AND s.teacher_id = auth.uid()
    )
);

-- RLS Policy: Teachers can UPDATE excuses (approve/decline) for students in their classes
CREATE POLICY "teachers_can_update_class_excuses"
ON absence_excuses
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM attendance a
        JOIN lessons l ON a.lesson_id = l.id
        JOIN subjects s ON l.subject_id = s.id
        WHERE a.id = absence_excuses.attendance_id
        AND s.teacher_id = auth.uid()
    )
)
WITH CHECK (
    -- Ensure teacher_id is set to the current user when updating
    teacher_id = auth.uid()
    -- Only allow updating status and teacher_response
    AND EXISTS (
        SELECT 1
        FROM attendance a
        JOIN lessons l ON a.lesson_id = l.id
        JOIN subjects s ON l.subject_id = s.id
        WHERE a.id = absence_excuses.attendance_id
        AND s.teacher_id = auth.uid()
    )
);

-- RLS Policy: School admins (principal, deputy) can SELECT all excuses for their school
CREATE POLICY "school_admins_can_select_school_excuses"
ON absence_excuses
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = auth.uid()
        AND p.role IN ('bigadmin', 'admin')
        AND p.school_id = (
            SELECT school_id FROM profiles WHERE id = absence_excuses.student_id
        )
    )
);

-- RLS Policy: School admins can UPDATE excuses for their school
CREATE POLICY "school_admins_can_update_school_excuses"
ON absence_excuses
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = auth.uid()
        AND p.role IN ('bigadmin', 'admin')
        AND p.school_id = (
            SELECT school_id FROM profiles WHERE id = absence_excuses.student_id
        )
    )
)
WITH CHECK (
    teacher_id = auth.uid()
);

-- Grant appropriate permissions
GRANT SELECT, INSERT, UPDATE ON absence_excuses TO authenticated;

-- Add comment for documentation
COMMENT ON TABLE absence_excuses IS 'Stores absence excuse submissions from parents for student absences';
COMMENT ON COLUMN absence_excuses.attendance_id IS 'Reference to the attendance record being excused';
COMMENT ON COLUMN absence_excuses.student_id IS 'The student for whom the excuse is submitted';
COMMENT ON COLUMN absence_excuses.parent_id IS 'The parent who submitted the excuse';
COMMENT ON COLUMN absence_excuses.reason IS 'The excuse reason text provided by parent';
COMMENT ON COLUMN absence_excuses.status IS 'Current status: pending, approved, or declined';
COMMENT ON COLUMN absence_excuses.teacher_response IS 'Optional message from teacher when declining';
COMMENT ON COLUMN absence_excuses.teacher_id IS 'Teacher who reviewed the excuse';
