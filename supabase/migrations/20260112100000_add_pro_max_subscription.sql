-- Migration: Add Pro and Max subscription tiers
-- This migration updates the subscription_status enum to include 'pro' and 'max' tiers
-- and removes the 'active' and 'cancelled' statuses in favor of the new tier system

-- Add new enum values to subscription_status
-- PostgreSQL requires a specific approach for adding enum values

-- First, add the new values
ALTER TYPE subscription_status ADD VALUE IF NOT EXISTS 'pro';
ALTER TYPE subscription_status ADD VALUE IF NOT EXISTS 'max';

-- Note: We keep 'active' for backwards compatibility - existing 'active' schools
-- will be migrated to 'pro' via a data migration script if needed
-- The 'cancelled' status is replaced by setting subscription to 'expired'

-- Update any existing 'active' subscriptions to 'pro' (the default paid tier)
-- Only run if 'active' is still a valid enum value
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pg_enum
        WHERE enumlabel = 'active'
        AND enumtypid = 'subscription_status'::regtype
    ) THEN
        UPDATE schools SET subscription_status = 'pro' WHERE subscription_status = 'active';
    END IF;
END $$;

-- Add comment for documentation
COMMENT ON TYPE subscription_status IS 'Subscription tiers: trial (free trial), pro (standard paid), max (premium paid), expired, suspended';
