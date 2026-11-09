#!/usr/bin/env bash
# The 0015 checks that need more than one session or the real Auth API
# (CR-160 W2). Local stack only, after `supabase db reset`:
#   supabase/concurrency/run.sh
set -euo pipefail
cd "$(dirname "$0")/../.."
eval "$(supabase status -o env 2>/dev/null | grep -E '^(API_URL|DB_URL)=')"
case "$DB_URL" in
  postgresql://*@127.0.0.1:*|postgresql://*@localhost:*) ;;
  *) echo "refusing: $DB_URL is not the local stack" >&2; exit 2 ;;
esac
psql "$DB_URL" -X -q -v ON_ERROR_STOP=1 -f supabase/concurrency/0015_account_revision_race.sql 2>&1 \
  | sed -n 's/^.*NOTICE:  //p; /passed/,+2p'
supabase/concurrency/auth_admin_delete.sh
supabase/concurrency/restart_check.sh
