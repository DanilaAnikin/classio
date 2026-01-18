-- Migration: Add NOT NULL constraints to lessons table
-- This migration is idempotent
-- Problem: lessons table allows NULL for start_time and end_time which breaks schedule display

-- First, update any existing NULL times to default values (08:00-08:45)
UPDATE lessons SET start_time = '08:00:00' WHERE start_time IS NULL;
UPDATE lessons SET end_time = '08:45:00' WHERE end_time IS NULL;

-- Add NOT NULL constraint to start_time (if not already NOT NULL)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'lessons'
        AND column_name = 'start_time'
        AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE lessons ALTER COLUMN start_time SET NOT NULL;
    END IF;
END $$;

-- Add NOT NULL constraint to end_time (if not already NOT NULL)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'lessons'
        AND column_name = 'end_time'
        AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE lessons ALTER COLUMN end_time SET NOT NULL;
    END IF;
END $$;
