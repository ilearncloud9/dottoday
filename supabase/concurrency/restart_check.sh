#!/usr/bin/env bash
# A deletion freeze survives a database restart (CR-160 W2, 0015): freeze an
# account with one Auth Admin call recorded (outcome unknown), restart the
# local database container, and check the freeze, its attempt id and that
# call are all still there and writes are still refused. Local stack only.
# Run with: supabase/concurrency/run.sh
set -euo pipefail
cd "$(dirname "$0")/../.."

eval "$(supabase status -o env 2>/dev/null | grep -E '^(DB_URL)=')"
case "$DB_URL" in
  postgresql://*@127.0.0.1:*|postgresql://*@localhost:*) ;;
  *) echo "refusing: $DB_URL is not the local stack" >&2; exit 2 ;;
esac
project=$(sed -nE 's/^project_id = "([^"]+)"/\1/p' supabase/config.toml)
container="supabase_db_${project}"
docker inspect "$container" >/dev/null

pass=0; fail=0
check() { # check <name> <got> <want>
  if [ "$2" = "$3" ]; then pass=$((pass + 1)); echo "ok - $1"
  else fail=$((fail + 1)); echo "NOT OK - $1"; echo "  got: [$2] want: [$3]"; fi
}
q() { psql "$DB_URL" -X -q -At -v ON_ERROR_STOP=1 -c "$1"; }

q "delete from auth.users where email = 'restart@restart.test'"
user=$(q "insert into auth.users (id, email) values (gen_random_uuid(), 'restart@restart.test') returning id")
task=$(q "insert into public.occurrences (id, user_id, title, tz_id, duration_min)
          values (gen_random_uuid(), '$user', 'Before restart', 'UTC', 30) returning id")
rev=$(q "select revision from public.account_revisions where user_id = '$user'")
attempt=$(q "set role service_role; select attempt from public.begin_account_deletion('$user', $rev)")
q "set role service_role; select public.note_account_deletion_call('$user', '$attempt')" >/dev/null
check "frozen before the restart" "$(q "select deletion_attempt from public.account_revisions where user_id = '$user'")" "$attempt"

docker restart "$container" >/dev/null
for _ in $(seq 1 60); do
  if q "select 1" >/dev/null 2>&1; then break; fi
  sleep 1
done

check "after the restart: the same attempt" "$(q "select deletion_attempt from public.account_revisions where user_id = '$user'")" "$attempt"
check "its unresolved Auth Admin call is still recorded" "$(q "select deletion_calls_unresolved from public.account_revisions where user_id = '$user'")" "1"
check "and the revision is unchanged" "$(q "select revision from public.account_revisions where user_id = '$user'")" "$rev"
refused=$(psql "$DB_URL" -X -q -At -c "set role authenticated;
  set request.jwt.claims = '{\"sub\":\"$user\",\"role\":\"authenticated\"}';
  update public.occurrences set title = 'After restart' where id = '$task';" 2>&1 || true)
check "writes are still refused" "$(grep -c 'is being deleted' <<<"$refused")" "1"
check "release is still refused (that call's outcome is unknown)" \
  "$(q "set role service_role; select public.release_account_deletion('$user', '$attempt')")" "unresolved"

q "delete from auth.users where id = '$user'"
check "the deletion path still removes it" "$(q "select count(*) from public.account_revisions where user_id = '$user'")" "0"
echo "passed $pass, failed $fail"
[ "$fail" -eq 0 ]
