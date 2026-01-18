-- Migration: Add NOT NULL constraints to assignment_submissions
-- This migration is idempotent
-- Problem: assignment_submissions table allows NULL for assignment_id and student_id which should be required
-- Prerequisite: Requires 20260113900000_create_assignment_submissions_table.sql to run first

DO $$
BEGIN
    -- Only proceed if the table exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'assignment_submissions'
    ) THEN
        RAISE NOTICE 'assignment_submissions table does not exist, skipping constraint updates';
        RETURN;
    END IF;

    -- First, clean up any orphan records (if any exist)
    DELETE FROM assignment_submissions
    WHERE assignment_id IS NULL OR student_id IS NULL OR submitted_at IS NULL;

    -- Add NOT NULL constraint to assignment_id (if not already NOT NULL)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'assignment_submissions'
        AND column_name = 'assignment_id'
        AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE assignment_submissions ALTER COLUMN assignment_id SET NOT NULL;
        RAISE NOTICE 'Added NOT NULL constraint to assignment_id';
    END IF;

    -- Add NOT NULL constraint to student_id (if not already NOT NULL)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'assignment_submissions'
        AND column_name = 'student_id'
        AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE assignment_submissions ALTER COLUMN student_id SET NOT NULL;
        RAISE NOTICE 'Added NOT NULL constraint to student_id';
    END IF;

    -- Add NOT NULL constraint to submitted_at (if not already NOT NULL)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'assignment_submissions'
        AND column_name = 'submitted_at'
        AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE assignment_submissions ALTER COLUMN submitted_at SET NOT NULL;
        RAISE NOTICE 'Added NOT NULL constraint to submitted_at';
    END IF;

    RAISE NOTICE 'assignment_submissions constraints verified/updated successfully';
END $$;
