# Database Push Pre-Flight Checklist

**Date Created:** 2026-01-18
**Purpose:** Verify database migrations are safe to push to production

---

## Migration Files Overview

### New Migrations Created (2026-01-18)

| Order | File | Purpose |
|-------|------|---------|
| 1 | `20260118000000_unify_schema.sql` | Unifies schema.sql and ultimate_schema.sql, adds missing columns |
| 2 | `20260118000001_secure_genesis_token.sql` | Secure bootstrap token system, removes hardcoded GENESIS-KEY |
| 3 | `20260118000002_rls_hardening_audit.sql` | Audit logging, superadmin protection, soft delete |

### Total Migration Count: 52 files

---

## Pre-Push Verification Checklist

### 1. Backup Your Database

```bash
# Option A: Supabase Dashboard
# Go to Settings > Database > Backups > Create Backup

# Option B: pg_dump (requires database URL)
pg_dump "postgresql://postgres.[PROJECT_REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres" > backup_$(date +%Y%m%d_%H%M%S).sql

# Option C: Supabase CLI
supabase db dump -f backup_$(date +%Y%m%d_%H%M%S).sql
```

### 2. Review Migration Order

All timestamped migrations will run in chronological order:
- `20260111180000` through `20260117700000` - Existing migrations
- `20260118000000` - Unify Schema (NEW)
- `20260118000001` - Secure Genesis Token (NEW)
- `20260118000002` - RLS Hardening Audit (NEW)

### 3. Known Issues (RESOLVED)

| Issue | Status | Resolution |
|-------|--------|------------|
| `CREATE POLICY IF NOT EXISTS` invalid syntax | FIXED | Changed to `DROP POLICY IF EXISTS` + `CREATE POLICY` |
| Non-timestamped migration files | KNOWN | These run alphabetically, may conflict |

### 4. Non-Timestamped Files (Potential Conflicts)

These files lack timestamps and may cause issues:

| File | Risk | Recommendation |
|------|------|----------------|
| `auto_profile_trigger.sql` | Medium | Should be run before timestamped migrations |
| `emergency_fix.sql` | HIGH | References `invite_codes` table which may be renamed |
| `fix_profile_trigger.sql` | Medium | Duplicates functionality in other migrations |
| `rbac_update.sql` | HIGH | `ALTER TYPE ... ADD VALUE` fails if value exists |

**Recommendation:** Consider renaming or removing non-timestamped files before push.

### 5. Schema Deprecation Verified

- [x] `schema.sql` renamed to `schema.sql.deprecated`
- [x] Deprecation notice added at top of file
- [x] References to new migration files included

---

## Push Commands

### Dry Run (Preview Changes)

```bash
# Preview what will be run
supabase db diff
```

### Execute Push

```bash
# Push migrations to remote database
supabase db push
```

### Alternative: Reset and Push (DESTRUCTIVE)

```bash
# WARNING: This will reset your database!
supabase db reset
```

---

## Expected Outcomes

After successful push:

1. **New Tables Created:**
   - `audit_log` - Audit trail for sensitive operations
   - `genesis_token_audit_log` - Bootstrap token generation tracking
   - `submissions` table (if not exists) - Teacher repository compatibility

2. **New Columns Added:**
   - `profiles.deleted_at`, `profiles.deleted_by` - Soft delete support
   - `schools.deleted_at`, `schools.deleted_by` - Soft delete support
   - `lessons.class_id` - Teacher repository compatibility
   - `subjects.school_id` - School-wide queries support
   - `grades.teacher_id`, `grades.note`, `grades.comment` - Column variants

3. **New Functions Created:**
   - `generate_genesis_token()` - Secure bootstrap token generation
   - `check_bootstrap_status()` - Check if system needs bootstrap
   - `log_audit_event()` - Audit logging function
   - `soft_delete_profile()` - Safe profile deletion
   - `restore_profile()` - Restore deleted profiles
   - `count_superadmins()`, `is_last_superadmin()` - Protection checks

4. **Triggers Installed:**
   - `audit_profiles_changes` - Audit all profile changes
   - `audit_grades_changes` - Audit grade operations
   - `audit_attendance_changes` - Audit attendance operations
   - `audit_schools_changes` - Audit school operations
   - `prevent_hardcoded_tokens` - Block weak tokens

5. **Security Improvements:**
   - Hardcoded `GENESIS-KEY` removed
   - RLS helper functions hardened with `search_path`
   - Superadmin self-deletion prevented
   - Last superadmin deletion blocked

---

## Rollback Procedure

If issues occur after push:

### Option 1: Restore from Backup

```bash
# Restore from backup file
psql "postgresql://..." < backup_YYYYMMDD_HHMMSS.sql
```

### Option 2: Manual Rollback

Each migration file contains rollback instructions in comments. See:
- `20260118000000_unify_schema.sql` - Lines 687-698
- `20260118000002_rls_hardening_audit.sql` - Lines 993-1030

### Option 3: Key Rollback Commands

```sql
-- Remove audit system
DROP TRIGGER IF EXISTS audit_profiles_changes ON profiles;
DROP TRIGGER IF EXISTS audit_grades_changes ON grades;
DROP TRIGGER IF EXISTS audit_attendance_changes ON attendance;
DROP TRIGGER IF EXISTS audit_schools_changes ON schools;
DROP TABLE IF EXISTS audit_log CASCADE;

-- Remove soft delete
ALTER TABLE profiles DROP COLUMN IF EXISTS deleted_at;
ALTER TABLE profiles DROP COLUMN IF EXISTS deleted_by;
ALTER TABLE schools DROP COLUMN IF EXISTS deleted_at;
ALTER TABLE schools DROP COLUMN IF EXISTS deleted_by;

-- Remove genesis token system
DROP FUNCTION IF EXISTS generate_genesis_token CASCADE;
DROP FUNCTION IF EXISTS check_bootstrap_status CASCADE;
DROP TABLE IF EXISTS genesis_token_audit_log CASCADE;
```

---

## Bootstrap First Superadmin (After Push)

After pushing to a fresh database:

```sql
-- Check if bootstrap is needed
SELECT * FROM check_bootstrap_status();

-- Generate bootstrap token (only works if no superadmin exists)
SELECT * FROM generate_genesis_token();

-- Use the returned token in the app's registration flow
```

---

## Final Checklist

- [ ] Database backed up
- [ ] Non-timestamped migrations reviewed
- [ ] `supabase db diff` shows expected changes
- [ ] Team notified of pending push
- [ ] Rollback plan understood
- [ ] `supabase db push` executed
- [ ] Post-push verification completed

---

## Contact

If issues occur, check:
1. Supabase Dashboard > Logs > Postgres Logs
2. Migration error messages in CLI output
3. RLS policy errors in application logs
