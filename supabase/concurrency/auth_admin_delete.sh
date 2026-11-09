#!/usr/bin/env bash
# The real Auth Admin deletion against 0015 (CR-160 W2): users made and
# deleted through GoTrue's admin API, data written through PostgREST with
# each user's own session, freezes through the service role's RPC. Local
# stack only: it refuses any API URL that isn't 127.0.0.1 / localhost.
# Run with: supabase/concurrency/run.sh
set -euo pipefail
cd "$(dirname "$0")/../.."

eval "$(supabase status -o env 2>/dev/null | grep -E '^(API_URL|ANON_KEY|SERVICE_ROLE_KEY|DB_URL)=')"
case "$API_URL" in
  http://127.0.0.1:*|http://localhost:*) ;;
  *) echo "refusing: $API_URL is not the local stack" >&2; exit 2 ;;
esac

pass=0; fail=0
check() { # check <name> <condition...>
  local name="$1"; shift
  if "$@"; then pass=$((pass + 1)); echo "ok - $name"; else fail=$((fail + 1)); echo "NOT OK - $name"; fi
}
eq() { [ "$1" = "$2" ] || { echo "  got: [$1] want: [$2]"; return 1; }; }
sql() { psql "$DB_URL" -X -At -c "$1"; }

admin() { # admin <method> <path> [json]
  curl -s -X "$1" "$API_URL/auth/v1/admin/$2" -H "apikey: $SERVICE_ROLE_KEY" \
    -H "Authorization: Bearer $SERVICE_ROLE_KEY" -H 'Content-Type: application/json' ${3:+-d "$3"} \
    -w '\n%{http_code}'
}
rest() { # rest <token> <method> <path> [json] → body, then status on the last line
  curl -s -X "$2" "$API_URL/rest/v1/$3" -H "apikey: $ANON_KEY" -H "Authorization: Bearer $1" \
    -H 'Content-Type: application/json' -H 'Prefer: return=minimal' ${4:+-d "$4"} -w '\n%{http_code}'
}
status_of() { tail -n1 <<<"$1"; }
body_of() { sed '$d' <<<"$1"; }

new_user() { # new_user <email> → "id token"
  local r id tok
  r=$(admin POST users "{\"email\":\"$1\",\"password\":\"race-pass-123\",\"email_confirm\":true}")
  id=$(body_of "$r" | jq -r .id)
  tok=$(curl -s "$API_URL/auth/v1/token?grant_type=password" -H "apikey: $ANON_KEY" \
    -H 'Content-Type: application/json' -d "{\"email\":\"$1\",\"password\":\"race-pass-123\"}" | jq -r .access_token)
  echo "$id $tok"
}

# A realistic account: settings, a repeating task, two tasks, a step, a
# routine, a reveal hint, and one change through sync_push.
fill() { # fill <id> <token>
  local id="$1" t="$2" s o1 o2
  s=$(uuidgen | tr A-Z a-z); o1=$(uuidgen | tr A-Z a-z); o2=$(uuidgen | tr A-Z a-z)
  rest "$t" PATCH "profiles?id=eq.$id" '{"tz_id":"Europe/Berlin"}' >/dev/null
  rest "$t" POST series "{\"id\":\"$s\",\"user_id\":\"$id\",\"title\":\"Run\",\"tz_id\":\"UTC\",\"duration_min\":30,\"rrule\":\"FREQ=DAILY\",\"dtstart_local\":\"2026-11-01T07:00:00\"}" >/dev/null
  rest "$t" POST occurrences "[{\"id\":\"$o1\",\"user_id\":\"$id\",\"title\":\"Gym\",\"tz_id\":\"UTC\",\"duration_min\":45,\"series_id\":\"$s\"},{\"id\":\"$o2\",\"user_id\":\"$id\",\"title\":\"Read\",\"tz_id\":\"UTC\",\"duration_min\":20,\"series_id\":null}]" >/dev/null
  rest "$t" POST subtasks "{\"id\":\"$(uuidgen | tr A-Z a-z)\",\"user_id\":\"$id\",\"occurrence_id\":\"$o1\",\"title\":\"Warm up\"}" >/dev/null
  rest "$t" POST routines "{\"id\":\"$(uuidgen | tr A-Z a-z)\",\"user_id\":\"$id\",\"title\":\"Morning\"}" >/dev/null
  rest "$t" POST reveal_hints "{\"id\":\"$(uuidgen | tr A-Z a-z)\",\"user_id\":\"$id\",\"hint_id\":\"unstick\"}" >/dev/null
  local hlc; hlc="$(($(date +%s) * 1000 - 60000))-0001-0000000000000001"
  rest "$t" POST rpc/sync_push "{\"changes\":[{\"owner\":\"$id\",\"entity\":\"occurrences\",\"id\":\"$(uuidgen | tr A-Z a-z)\",\"hlc\":\"$hlc\",\"fields\":{\"title\":\"Pushed\"}}]}" >/dev/null
}
rows_of() { # every exported row of <id>, plus its revision row
  sql "select (select count(*) from public.profiles where id = '$1') + (select count(*) from public.series where user_id = '$1')
         + (select count(*) from public.occurrences where user_id = '$1') + (select count(*) from public.subtasks where user_id = '$1')
         + (select count(*) from public.routines where user_id = '$1') + (select count(*) from public.reveal_hints where user_id = '$1')
         + (select count(*) from public.account_revisions where user_id = '$1')"
}
revision() { # the session's revision; fails the run if it isn't a number
  local v
  v=$(curl -s -X POST "$API_URL/rest/v1/rpc/account_revision" -H "apikey: $ANON_KEY" \
    -H "Authorization: Bearer $1" -H 'Content-Type: application/json' -d '{}' | jq -r '.[0].revision')
  [[ "$v" =~ ^[0-9]+$ ]] || { echo "revision read failed: $v" >&2; exit 3; }
  echo "$v"
}
freeze() { # freeze <id> <expected> → begin_account_deletion's answer, as the service role
  curl -s -X POST "$API_URL/rest/v1/rpc/begin_account_deletion" -H "apikey: $SERVICE_ROLE_KEY" \
    -H "Authorization: Bearer $SERVICE_ROLE_KEY" -H 'Content-Type: application/json' \
    -d "{\"p_user\":\"$1\",\"p_expected\":$2}" | jq -r .
}

sql "delete from auth.users where email like '%@admin-delete.test'" >/dev/null
read -r A TA <<<"$(new_user "a-$RANDOM@admin-delete.test")"
read -r B TB <<<"$(new_user "b-$RANDOM@admin-delete.test")"
read -r C TC <<<"$(new_user "c-$RANDOM@admin-delete.test")"
read -r D TD <<<"$(new_user "d-$RANDOM@admin-delete.test")"
fill "$A" "$TA"; fill "$B" "$TB"; fill "$C" "$TC"; fill "$D" "$TD"
check "the accounts have their data (9 rows each, revision row included)" eq "$(rows_of "$A") $(rows_of "$B") $(rows_of "$C") $(rows_of "$D")" "9 9 9 9"

# --- privileges through the API ---
r=$(rest "$TA" POST rpc/begin_account_deletion "{\"p_user\":\"$B\",\"p_expected\":0}")
check "a user's session can't call the freeze over the API ($(status_of "$r"))" eq "$(status_of "$r" | cut -c1)" "4"
r=$(rest "$TA" PATCH "account_revisions?user_id=eq.$A" '{"revision":0}')
check "a user's session can't write its revision over the API ($(status_of "$r"))" eq "$(status_of "$r" | cut -c1)" "4"

# --- 1. not frozen: the Admin deletion takes everything ---
r=$(admin DELETE "users/$A")
check "Admin deletes an unfrozen account ($(status_of "$r"))" eq "$(status_of "$r")" "200"
check "all its rows and its revision row are gone" eq "$(rows_of "$A")" "0"
check "B is untouched" eq "$(rows_of "$B")" "9"

# --- 2. stale revision: no freeze ---
rb=$(revision "$TB")
check "a stale revision is refused" eq "$(freeze "$B" $((rb - 1)))" "changed"

# --- 3. frozen: writes refused through the API, then the Admin deletion ---
check "the current revision freezes" eq "$(freeze "$B" "$rb")" "frozen"
r=$(rest "$TB" POST occurrences "{\"id\":\"$(uuidgen | tr A-Z a-z)\",\"user_id\":\"$B\",\"title\":\"late\",\"tz_id\":\"UTC\",\"duration_min\":5}")
check "frozen: a new task over the API is refused ($(status_of "$r"))" eq "$(body_of "$r" | jq -r .code)" "DT409"
r=$(rest "$TB" DELETE "occurrences?user_id=eq.$B")
check "frozen: a hard delete over the API is refused ($(status_of "$r"))" eq "$(body_of "$r" | jq -r .code)" "DT409"
r=$(rest "$TB" DELETE "profiles?id=eq.$B")
check "frozen: deleting the profile over the API is refused" eq "$(body_of "$r" | jq -r .code)" "DT409"
check "frozen: the revision did not move" eq "$(revision "$TB")" "$rb"
check "a retry of the freeze is idempotent" eq "$(freeze "$B" "$rb")" "frozen"
r=$(admin DELETE "users/$B")
check "Admin deletes the frozen account; the cascade is let through ($(status_of "$r"))" eq "$(status_of "$r")" "200"
check "all its rows and its revision row are gone" eq "$(rows_of "$B")" "0"
check "C is untouched" eq "$(rows_of "$C")" "9"
r=$(rest "$TB" POST occurrences "{\"id\":\"$(uuidgen | tr A-Z a-z)\",\"user_id\":\"$B\",\"title\":\"ghost\",\"tz_id\":\"UTC\",\"duration_min\":5}")
check "the deleted user's leftover token writes nothing back ($(status_of "$r"))" eq "$(rows_of "$B")" "0"

# --- 4. Admin failure: abort ends the freeze and voids the old revision ---
rc=$(revision "$TC")
check "C freezes" eq "$(freeze "$C" "$rc")" "frozen"
ab=$(curl -s -X POST "$API_URL/rest/v1/rpc/abort_account_deletion" -H "apikey: $SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY" -H 'Content-Type: application/json' -d "{\"p_user\":\"$C\"}")
check "abort ends it" eq "$ab" "true"
r=$(rest "$TC" PATCH "occurrences?user_id=eq.$C&title=eq.Read" '{"title":"Read more"}')
check "C writes again ($(status_of "$r"))" eq "$(status_of "$r")" "204"
check "the revision from before the abort no longer freezes" eq "$(freeze "$C" "$rc")" "changed"

# --- 5. unknown outcome: the lease runs out before the Admin deletion ---
rd=$(revision "$TD")
check "D freezes" eq "$(freeze "$D" "$rd")" "frozen"
sql "update public.account_revisions set deleting_until = clock_timestamp() - interval '1 second' where user_id = '$D'" >/dev/null
r=$(rest "$TD" PATCH "occurrences?user_id=eq.$D&title=eq.Read" '{"title":"written after the lease"}')
check "after the lease a write goes through ($(status_of "$r"))" eq "$(status_of "$r")" "204"
check "and moves the revision" eq "$(( $(revision "$TD") > rd ))" "1"
r=$(admin DELETE "users/$D")
# The Admin API checks nothing: this is the documented W2 limit. The Edge
# Function must not start the Admin call without lease left.
check "the Admin API still deletes after the lease (no database check: the W2 limit) ($(status_of "$r"))" eq "$(status_of "$r")" "200"
check "taking the late write with it" eq "$(rows_of "$D")" "0"

admin DELETE "users/$C" >/dev/null
echo "passed $pass, failed $fail"
[ "$fail" -eq 0 ]
