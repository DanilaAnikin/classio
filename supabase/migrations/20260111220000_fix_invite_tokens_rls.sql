-- Fix: Allow anonymous users to validate invite tokens during registration
-- Problem: Users are NOT authenticated when registering, so they can't read
-- the invite_tokens table to validate their invite code (error 42501)
--
-- Solution: Add a SELECT policy for anon and authenticated roles that only
-- allows reading unused, non-expired tokens (minimal exposure)

-- Allow anonymous users to validate invite tokens during registration
-- They can only SELECT (not insert/update/delete)
-- They can only see unused, non-expired tokens
CREATE POLICY "Anyone can validate invite tokens"
  ON invite_tokens
  FOR SELECT
  TO anon, authenticated
  USING (
    is_used = false
    AND (expires_at IS NULL OR expires_at > now())
  );
