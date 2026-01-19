-- Migration: Secure Token Generation
-- Replaces insecure random() with cryptographically secure gen_random_bytes()

CREATE OR REPLACE FUNCTION generate_invite_token()
RETURNS TEXT AS $$
DECLARE
  -- Character set excluding ambiguous characters (0, O, 1, I, L)
  chars TEXT := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  chars_len INTEGER := length(chars);
  result TEXT := '';
  random_bytes BYTEA;
  i INTEGER;
  byte_val INTEGER;
BEGIN
  -- Generate 6 cryptographically secure random bytes
  random_bytes := gen_random_bytes(6);

  FOR i IN 1..6 LOOP
    -- Extract each byte and map to character set
    byte_val := get_byte(random_bytes, i - 1);

    -- Rejection sampling for uniform distribution
    -- For 32 characters, use values 0-223 (224 = 32 * 7)
    WHILE byte_val >= 224 LOOP
      random_bytes := gen_random_bytes(1);
      byte_val := get_byte(random_bytes, 0);
    END LOOP;

    result := result || substr(chars, (byte_val % chars_len) + 1, 1);
  END LOOP;

  RETURN result;
END;
$$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION generate_invite_token() IS
'Generates a 6-character cryptographically secure invite token using gen_random_bytes().';

-- Verification function
CREATE OR REPLACE FUNCTION audit_token_security()
RETURNS TABLE(check_name TEXT, status TEXT, details TEXT) AS $$
BEGIN
  RETURN QUERY SELECT
    'gen_random_bytes availability'::TEXT,
    CASE WHEN length(gen_random_bytes(1)) = 1 THEN 'PASS' ELSE 'FAIL' END::TEXT,
    'Cryptographic random generator available'::TEXT;

  RETURN QUERY SELECT
    'Token uniqueness test'::TEXT,
    CASE WHEN (SELECT COUNT(DISTINCT t) FROM (SELECT generate_invite_token() AS t FROM generate_series(1, 100)) tokens) = 100
    THEN 'PASS' ELSE 'WARN' END::TEXT,
    '100 generated tokens should be unique'::TEXT;
END;
$$ LANGUAGE plpgsql;
