-- Add subscription_expires_at column to schools table
-- This column tracks when a school's subscription expires

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'schools'
        AND column_name = 'subscription_expires_at'
    ) THEN
        ALTER TABLE schools ADD COLUMN subscription_expires_at TIMESTAMPTZ;
    END IF;
END $$;

COMMENT ON COLUMN schools.subscription_expires_at IS 'Timestamp when the subscription expires (NULL means no expiration or trial)';
