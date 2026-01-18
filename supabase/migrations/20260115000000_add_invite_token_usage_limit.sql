-- Add usage_limit and times_used columns to invite_tokens table
-- This enables multi-use tokens instead of single-use only

-- Add usage_limit column (defaults to 1 for backwards compatibility)
ALTER TABLE invite_tokens
ADD COLUMN IF NOT EXISTS usage_limit INTEGER DEFAULT 1 NOT NULL;

-- Add times_used column (defaults to 0)
ALTER TABLE invite_tokens
ADD COLUMN IF NOT EXISTS times_used INTEGER DEFAULT 0 NOT NULL;

-- Migrate existing data: set times_used based on is_used
UPDATE invite_tokens SET times_used = CASE WHEN is_used THEN 1 ELSE 0 END;

-- Drop policies that depend on is_used column BEFORE dropping the column
DROP POLICY IF EXISTS "anon_validate_tokens" ON invite_tokens;
DROP POLICY IF EXISTS "invite_tokens_validate" ON invite_tokens;
DROP POLICY IF EXISTS "Anyone can validate invite tokens" ON invite_tokens;

-- Drop the is_used boolean since we now use times_used
ALTER TABLE invite_tokens
DROP COLUMN IF EXISTS is_used;

-- Add constraint to ensure times_used doesn't exceed usage_limit
ALTER TABLE invite_tokens
ADD CONSTRAINT check_usage_limit CHECK (times_used <= usage_limit);

-- Add constraint to ensure usage_limit is at least 1
ALTER TABLE invite_tokens
ADD CONSTRAINT check_usage_limit_positive CHECK (usage_limit >= 1);

-- Update the handle_new_user function to work with usage_limit/times_used
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  _role user_role;
  _school_id UUID;
  _token_record RECORD;
  _invite_token TEXT;
  _class_id UUID;
BEGIN
  -- Extract invite token from metadata
  _invite_token := NEW.raw_user_meta_data->>'invite_token';

  IF _invite_token IS NULL OR _invite_token = '' THEN
    RAISE EXCEPTION 'Registration requires a valid invite token';
  END IF;

  -- Validate and fetch token (check times_used < usage_limit instead of is_used = false)
  SELECT * INTO _token_record FROM invite_tokens
  WHERE token = _invite_token
    AND times_used < usage_limit
    AND (expires_at IS NULL OR expires_at > now());

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invalid or expired invite token';
  END IF;

  -- Increment times_used instead of setting is_used = true
  UPDATE invite_tokens SET times_used = times_used + 1 WHERE token = _invite_token;

  -- Set values from token
  _role := _token_record.role;
  _school_id := _token_record.school_id;
  _class_id := _token_record.specific_class_id;

  -- Create profile
  INSERT INTO profiles (id, email, role, school_id, first_name, last_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    _role,
    _school_id,
    COALESCE(NEW.raw_user_meta_data->>'first_name', 'New'),
    COALESCE(NEW.raw_user_meta_data->>'last_name', 'User'),
    NEW.raw_user_meta_data->>'avatar_url'
  );

  -- If student and class specified, enroll in class
  IF _role = 'student' AND _class_id IS NOT NULL THEN
    INSERT INTO class_students (class_id, student_id) VALUES (_class_id, NEW.id);
  END IF;

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate policy with new logic using times_used < usage_limit
CREATE POLICY "Anyone can validate invite tokens"
  ON invite_tokens
  FOR SELECT
  TO anon, authenticated
  USING (
    times_used < usage_limit
    AND (expires_at IS NULL OR expires_at > now())
  );

-- Update the index for active tokens
DROP INDEX IF EXISTS idx_invite_tokens_active;
DROP INDEX IF EXISTS idx_invite_tokens_is_used;

CREATE INDEX idx_invite_tokens_active ON invite_tokens(school_id, times_used, usage_limit, expires_at)
  WHERE times_used < usage_limit;

CREATE INDEX idx_invite_tokens_usage ON invite_tokens(times_used, usage_limit);

-- Create helper function to check if a token is still valid
CREATE OR REPLACE FUNCTION is_token_valid(p_token TEXT)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM invite_tokens
    WHERE token = p_token
    AND times_used < usage_limit
    AND (expires_at IS NULL OR expires_at > NOW())
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

COMMENT ON FUNCTION is_token_valid(TEXT) IS 'Returns true if the invite token is valid (not expired and has remaining uses)';

-- Drop old function overloads first if they exist
DROP FUNCTION IF EXISTS create_invite_token(user_role, UUID, UUID, INTERVAL);

-- Update the create_invite_token function to support usage_limit
CREATE OR REPLACE FUNCTION create_invite_token(
  p_role user_role,
  p_school_id UUID,
  p_class_id UUID DEFAULT NULL,
  p_expires_in INTERVAL DEFAULT '7 days',
  p_usage_limit INTEGER DEFAULT 1
)
RETURNS TEXT AS $$
DECLARE
  new_token TEXT;
  attempts INTEGER := 0;
BEGIN
  -- Validate usage_limit
  IF p_usage_limit < 1 THEN
    RAISE EXCEPTION 'usage_limit must be at least 1';
  END IF;

  LOOP
    new_token := generate_invite_token();

    BEGIN
      INSERT INTO invite_tokens (token, role, school_id, created_by_user_id, specific_class_id, expires_at, usage_limit, times_used)
      VALUES (new_token, p_role, p_school_id, auth.uid(), p_class_id, now() + p_expires_in, p_usage_limit, 0);

      RETURN new_token;
    EXCEPTION
      WHEN unique_violation THEN
        attempts := attempts + 1;
        IF attempts >= 10 THEN
          RAISE EXCEPTION 'Could not generate unique token after 10 attempts';
        END IF;
    END;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION create_invite_token(user_role, UUID, UUID, INTERVAL, INTEGER) IS 'Creates a new invite token with the specified role, school, and usage limit';
