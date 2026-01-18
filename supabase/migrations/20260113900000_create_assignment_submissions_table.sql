-- Migration: Create assignment_submissions table (if not exists)
-- =====================================================================
-- ISSUE: The Dart application code expects 'assignment_submissions' table,
-- but the ultimate_schema.sql created 'submissions' table instead.
-- This migration creates the missing 'assignment_submissions' table to
-- match the application requirements.
-- =====================================================================

-- Check if the table already exists before creating
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'assignment_submissions'
    ) THEN
        -- Create the assignment_submissions table
        CREATE TABLE assignment_submissions (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
            student_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
            content TEXT,
            file_url TEXT,
            submitted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            score DECIMAL(5,2),
            feedback TEXT,
            created_at TIMESTAMPTZ DEFAULT now(),
            CONSTRAINT unique_assignment_student_submission UNIQUE (assignment_id, student_id)
        );

        -- Add comment
        COMMENT ON TABLE assignment_submissions IS 'Student submissions for assignments';

        -- Enable RLS
        ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;

        -- Create indexes for performance
        CREATE INDEX IF NOT EXISTS idx_assignment_submissions_assignment
            ON assignment_submissions(assignment_id);

        CREATE INDEX IF NOT EXISTS idx_assignment_submissions_student
            ON assignment_submissions(student_id);

        CREATE INDEX IF NOT EXISTS idx_assignment_submissions_submitted_at
            ON assignment_submissions(submitted_at);

        -- RLS Policies
        -- Students can view their own submissions
        CREATE POLICY "Students can view their own submissions"
            ON assignment_submissions FOR SELECT
            TO authenticated
            USING (student_id = auth.uid());

        -- Students can create their own submissions
        CREATE POLICY "Students can create their own submissions"
            ON assignment_submissions FOR INSERT
            TO authenticated
            WITH CHECK (student_id = auth.uid());

        -- Students can update their own submissions
        CREATE POLICY "Students can update their own submissions"
            ON assignment_submissions FOR UPDATE
            TO authenticated
            USING (student_id = auth.uid());

        -- Teachers can view submissions for their assignments
        CREATE POLICY "Teachers can view submissions for their assignments"
            ON assignment_submissions FOR SELECT
            TO authenticated
            USING (
                EXISTS (
                    SELECT 1 FROM assignments a
                    JOIN subjects s ON s.id = a.subject_id
                    WHERE a.id = assignment_submissions.assignment_id
                    AND s.teacher_id = auth.uid()
                )
            );

        -- Teachers can grade submissions (update score/feedback)
        CREATE POLICY "Teachers can grade submissions"
            ON assignment_submissions FOR UPDATE
            TO authenticated
            USING (
                EXISTS (
                    SELECT 1 FROM assignments a
                    JOIN subjects s ON s.id = a.subject_id
                    WHERE a.id = assignment_submissions.assignment_id
                    AND s.teacher_id = auth.uid()
                )
            );

        -- Admins can view all submissions in their school
        CREATE POLICY "Admins can view submissions in their school"
            ON assignment_submissions FOR SELECT
            TO authenticated
            USING (
                EXISTS (
                    SELECT 1 FROM profiles p
                    WHERE p.id = auth.uid()
                    AND p.role IN ('admin', 'bigadmin', 'superadmin')
                    AND (
                        p.role = 'superadmin'
                        OR EXISTS (
                            SELECT 1 FROM assignments a
                            JOIN subjects s ON s.id = a.subject_id
                            JOIN classes c ON c.id = s.class_id
                            WHERE a.id = assignment_submissions.assignment_id
                            AND c.school_id = p.school_id
                        )
                    )
                )
            );

        -- Superadmin has full access
        CREATE POLICY "Superadmin has full access to submissions"
            ON assignment_submissions FOR ALL
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

        -- Parents can view their children's submissions
        CREATE POLICY "Parents can view their children's submissions"
            ON assignment_submissions FOR SELECT
            TO authenticated
            USING (
                EXISTS (
                    SELECT 1 FROM parent_student ps
                    WHERE ps.parent_id = auth.uid()
                    AND ps.student_id = assignment_submissions.student_id
                )
            );

        RAISE NOTICE 'Created assignment_submissions table with RLS policies';
    ELSE
        RAISE NOTICE 'assignment_submissions table already exists, skipping creation';
    END IF;
END $$;
