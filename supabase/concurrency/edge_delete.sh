#!/usr/bin/env bash
# The delete-account Edge Function against the local stack (CR-160 W2,
# Stage 2): served with verify_jwt on, called with real sessions, deleting
# through the real GoTrue. Outcomes the real Auth can't be made to produce
# on demand (timeouts, 5xx) are in deletion_test.ts. Local stack only.
# Run with: supabase/concurrency/run.sh
set -euo pipefail
cd "$(dirname "$0")/../.."

eval "$(supabase status -o env 2>/dev/null | grep -E '^(API_URL|ANON_KEY|SERVICE_ROLE_KEY|DB_URL)=')"
case "$API_URL" in
  http://127.0.0.1:*|http://localhost:*) ;;
  *) echo "refusing: $API_URL is not the local stack" >&2; exit 2 ;;
esac

pass=0; fail=0
check() { # check <name> <got> <want>
  if [ $# -eq 3 ] && [ "$2" = "$3" ]; then pass=$((pass + 1)); echo "ok - $1"
  else fail=$((fail + 1)); echo "NOT OK - $1"; echo "  got: [${2-}] want: [${3-}] ($# args)"; fi
}
sql() { psql "$DB_URL" -X -q -At -c "$1"; }

# Serve the function (verify_jwt on, as deployed) for the length of this run.
log=$(mktemp)
supabase functions serve delete-account >"$log" 2>&1 &
serve=$!
trap 'kill $serve 2>/dev/null || true; rm -f "$log"' EXIT
for _ in $(seq 1 90); do
  code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$API_URL/functions/v1/delete-account" || true)
  [ "$code" = "401" ] && break
  sleep 1
done

fn() { # fn <token|-> <json body|-> → "status body"
  local auth=() data=()
  [ "$1" != "-" ] && auth=(-H "Authorization: Bearer $1")
  [ "$2" != "-" ] && data=(-d "$2")
  curl -s -X POST "$API_URL/functions/v1/delete-account" -H "apikey: $ANON_KEY" \
    -H 'Content-Type: application/json' ${auth[@]+"${auth[@]}"} ${data[@]+"${data[@]}"} -w '\n%{http_code}' \
    | { read -r body || true; read -r status || true; echo "$status $body"; }
}
status_of() { cut -d' ' -f1 <<<"$1"; }
field() { cut -d' ' -f2- <<<"$1" | jq -r ".$2"; }
svc() { # svc <rpc> <json>
  curl -s -X POST "$API_URL/rest/v1/rpc/$1" -H "apikey: $SERVICE_ROLE_KEY" \
    -H "Authorization: Bearer $SERVICE_ROLE_KEY" -H 'Content-Type: application/json' -d "$2"
}
new_user() { # new_user <email> → "id token"
  local id tok
  id=$(curl -s -X POST "$API_URL/auth/v1/admin/users" -H "apikey: $SERVICE_ROLE_KEY" \
    -H "Authorization: Bearer $SERVICE_ROLE_KEY" -H 'Content-Type: application/json' \
    -d "{\"email\":\"$1\",\"password\":\"edge-pass-123\",\"email_confirm\":true}" | jq -r .id)
  tok=$(curl -s "$API_URL/auth/v1/token?grant_type=password" -H "apikey: $ANON_KEY" \
    -H 'Content-Type: application/json' -d "{\"email\":\"$1\",\"password\":\"edge-pass-123\"}" | jq -r .access_token)
  echo "$id $tok"
}
task() { # task <id> <token>: one task written through the API as the user → status
  local body="{\"id\":\"$(uuidgen | tr A-Z a-z)\",\"user_id\":\"$1\",\"title\":\"Task\",\"tz_id\":\"UTC\",\"duration_min\":30}"
  curl -s -o /dev/null -w '%{http_code}' -X POST "$API_URL/rest/v1/occurrences" -H "apikey: $ANON_KEY" \
    -H "Authorization: Bearer $2" -H 'Content-Type: application/json' -H 'Prefer: return=minimal' -d "$body"
}
rev() { sql "select revision from public.account_revisions where user_id = '$1'"; }
frozen() { sql "select coalesce((select (deletion_attempt is not null)::text from public.account_revisions where user_id = '$1'), 'gone')"; }
rows() { sql "select count(*) from public.occurrences where user_id = '$1'"; }
exists() { sql "select count(*) from auth.users where id = '$1'"; }
begin_as_crashed() { # begin_as_crashed <id> <rev> → attempt (an invocation that froze, then died)
  local body="{\"p_user\":\"$1\",\"p_expected\":$2}"
  svc begin_account_deletion "$body" | jq -r '.[0].attempt'
}
note_as_crashed() { # note_as_crashed <id> <attempt> (… recorded its call, then died)
  local body="{\"p_user\":\"$1\",\"p_attempt\":\"$2\"}"
  svc note_account_deletion_call "$body" >/dev/null
}

sql "delete from auth.users where email like '%@edge-delete.test'"
for n in A B C D E F G; do
  read -r id tok <<<"$(new_user "$(tr A-Z a-z <<<"$n")-$RANDOM@edge-delete.test")"
  [[ "$id" =~ ^[0-9a-f-]{36}$ && "$tok" == ey* ]] || { echo "could not make user $n: [$id]" >&2; exit 3; }
  printf -v "ID_$n" '%s' "$id"; printf -v "TOK_$n" '%s' "$tok"
  task "$id" "$tok" >/dev/null; task "$id" "$tok" >/dev/null
done
check "seven accounts with two tasks each" "$(sql "select count(*) from public.occurrences o join auth.users u on u.id = o.user_id where u.email like '%@edge-delete.test'")" "14"

# --- the request ---
r=$(fn - '{"expected_revision":1}')
check "no session: refused at the gateway" "$(status_of "$r")" "401"
r=$(fn "$TOK_A" -)
check "an older app (no body): 400 update_required" "$(status_of "$r") $(field "$r" error)" "400 update_required"
r=$(fn "$TOK_A" '{"expected_revision":"3"}')
check "a revision that isn't a number: 400" "$(status_of "$r") $(field "$r" error)" "400 update_required"
check "nothing frozen by either" "$(frozen "$ID_A")" "false"

# --- stale revision: another device wrote after the export ---
ra=$(rev "$ID_A")
check "another device writes after the export" "$(task "$ID_A" "$TOK_A")" "201"
r=$(fn "$TOK_A" "{\"expected_revision\":$ra}")
check "the old revision: 409 changed" "$(status_of "$r") $(field "$r" error)" "409 changed"
check "nothing frozen, nothing deleted" "$(frozen "$ID_A") $(exists "$ID_A")" "false 1"

# --- current revision: deleted, the other accounts untouched ---
r=$(fn "$TOK_A" "{\"expected_revision\":$(rev "$ID_A")}")
check "the current revision: 200 deleted" "$(status_of "$r") $(field "$r" deleted)" "200 true"
check "the account and its rows are gone" "$(exists "$ID_A") $(rows "$ID_A") $(frozen "$ID_A")" "0 0 gone"
check "G is untouched" "$(rows "$ID_G") $(frozen "$ID_G")" "2 false"
r=$(fn "$TOK_A" "{\"expected_revision\":$ra}")
check "a repeat after success: 200 already (no new account, no mail)" "$(status_of "$r") $(field "$r" already) $(field "$r" mailed)" "200 true false"
check "and no user came back" "$(exists "$ID_A")" "0"

# --- an unresolved deletion at another revision: never taken over ---
rb=$(rev "$ID_B")
ab=$(begin_as_crashed "$ID_B" "$rb")
note_as_crashed "$ID_B" "$ab"
r=$(fn "$TOK_B" "{\"expected_revision\":$((rb + 1))}")
check "another revision while frozen: 503 pending" "$(status_of "$r") $(field "$r" error)" "503 pending"
check "a write while frozen is refused" "$(task "$ID_B" "$TOK_B")" "400"
r=$(fn "$TOK_B" '{"action":"cancel"}')
check "cancel while a call's outcome is unknown: 409 pending" "$(status_of "$r") $(field "$r" error)" "409 pending"
check "still frozen, same attempt" "$(sql "select deletion_attempt from public.account_revisions where user_id = '$ID_B'")" "$ab"
r=$(fn "$TOK_B" "{\"expected_revision\":$rb}")
check "a retry at the frozen revision rejoins and finishes: 200 deleted" "$(status_of "$r") $(field "$r" deleted)" "200 true"
check "B is gone" "$(exists "$ID_B") $(rows "$ID_B")" "0 0"

# --- crash after the freeze, before any call was recorded: cancel is safe ---
rc=$(rev "$ID_C")
begin_as_crashed "$ID_C" "$rc" >/dev/null
check "frozen with no call recorded" "$(frozen "$ID_C")" "true"
r=$(fn "$TOK_C" '{"action":"cancel"}')
check "cancel: 200 released" "$(status_of "$r") $(field "$r" released)" "200 true"
check "C writes again" "$(task "$ID_C" "$TOK_C")" "201"
r=$(fn "$TOK_C" "{\"expected_revision\":$rc}")
check "the revision from before the cancel: 409 changed" "$(status_of "$r") $(field "$r" error)" "409 changed"
r=$(fn "$TOK_C" '{"action":"cancel"}')
check "cancel with nothing frozen: nothing to do" "$(status_of "$r") $(field "$r" frozen)" "200 false"

# --- crash after the Auth deletion, before the answer ---
rd=$(rev "$ID_D")
ad=$(begin_as_crashed "$ID_D" "$rd")
note_as_crashed "$ID_D" "$ad"
curl -s -o /dev/null -X DELETE "$API_URL/auth/v1/admin/users/$ID_D" -H "apikey: $SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY"
r=$(fn "$TOK_D" "{\"expected_revision\":$rd}")
check "the retry finds it deleted: 200 already, no mail" "$(status_of "$r") $(field "$r" already) $(field "$r" mailed)" "200 true false"

# --- two requests at once, same revision ---
re=$(rev "$ID_E")
fn "$TOK_E" "{\"expected_revision\":$re}" >"$log.1" & p1=$!
fn "$TOK_E" "{\"expected_revision\":$re}" >"$log.2" & p2=$!
wait $p1 $p2
x=$(cat "$log.1"); y=$(cat "$log.2"); rm -f "$log.1" "$log.2"
check "both answer 200" "$(status_of "$x") $(status_of "$y")" "200 200"
check "exactly one did the deletion, the other reports it" \
  "$( (field "$x" already; field "$y" already) | grep -c true)" "1"
check "E is gone" "$(exists "$ID_E")" "0"

# --- a write racing the freeze from another session ---
rf=$(rev "$ID_F")
check "F writes just before the request" "$(task "$ID_F" "$TOK_F")" "201"
r=$(fn "$TOK_F" "{\"expected_revision\":$rf}")
check "the request at the revision before that write: 409 changed" "$(status_of "$r") $(field "$r" error)" "409 changed"
r=$(fn "$TOK_F" "{\"expected_revision\":$(rev "$ID_F")}")
check "at the new revision: 200 deleted" "$(status_of "$r") $(field "$r" deleted)" "200 true"

# --- the refusals the function trusts are what this Auth answers, and they delete nothing ---
probe() { # probe <label> <curl args…> → "status error_code"
  shift
  curl -s -X DELETE "$API_URL/auth/v1/admin/users/$ID_G" "$@" -w '\n%{http_code}' \
    | { read -r b || true; read -r s || true; echo "$s $(jq -r '.error_code // .code' <<<"$b" 2>/dev/null)"; }
}
check "malformed body: 400 bad_json" "$(probe x -H "apikey: $SERVICE_ROLE_KEY" -H "Authorization: Bearer $SERVICE_ROLE_KEY" -H 'Content-Type: application/json' -d '{')" "400 bad_json"
check "no bearer: 401 no_authorization" "$(probe x -H "apikey: $SERVICE_ROLE_KEY")" "401 no_authorization"
check "a malformed token: 403 bad_jwt" "$(probe x -H "apikey: $SERVICE_ROLE_KEY" -H "Authorization: Bearer a.b.c")" "403 bad_jwt"
check "a non-admin token: 403 not_admin" "$(probe x -H "apikey: $ANON_KEY" -H "Authorization: Bearer $ANON_KEY")" "403 not_admin"
check "wrong method: 405 with no Auth error code (so never trusted)" "$(probe x -X PATCH -H "apikey: $SERVICE_ROLE_KEY" -H "Authorization: Bearer $SERVICE_ROLE_KEY")" "405 "
check "none of them deleted G" "$(exists "$ID_G") $(rows "$ID_G")" "1 2"

check "G is still untouched" "$(rows "$ID_G") $(frozen "$ID_G")" "2 false"
grep -iE 'error|exception' "$log" | grep -v 'no confirmation mail' | head -5 || true
sql "delete from auth.users where email like '%@edge-delete.test'"
echo "passed $pass, failed $fail"
[ "$fail" -eq 0 ]
