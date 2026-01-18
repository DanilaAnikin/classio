-- Create trigger on auth.users to auto-create profiles
-- This migration runs with elevated permissions via Supabase CLI

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();
