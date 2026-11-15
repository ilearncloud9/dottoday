#!/usr/bin/env bash
# An isolated local Supabase stack for integration tests (Q9, ED-352).
#
# The original app's local stack is `project_id = "dottoday"` on 54321. This
# script runs a second one, `dottoday-test` on 55321 (every port +1000), from a
# generated, git-ignored `.test-stack/` folder, so `db reset` and the client
# tests never touch the original stack's users or data.
#
#   tool/test_stack.sh start   # start (or reuse) the test stack
#   tool/test_stack.sh reset   # db reset: the test stack only
#   tool/test_stack.sh test    # pgTAP, then flutter test --tags supabase
#   tool/test_stack.sh env     # print the exports the client tests need
#   tool/test_stack.sh stop    # stop, keep nothing (--no-backup)
#
# Local only: the test stack is never linked, and this script never runs
# `db push`, `link`, `secrets` or `functions deploy`.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/supabase"
WORK="$ROOT/.test-stack"
DEST="$WORK/supabase"
PROJECT_ID="dottoday-test"
OFFSET=1000

die() { echo "test_stack: $*" >&2; exit 1; }

# P4: a linked test stack could reach the hosted project. Refuse outright.
guard_unlinked() {
  [[ ! -e "$DEST/.temp/project-ref" ]] ||
    die "$DEST/.temp/project-ref exists: the test stack must never be linked. Remove .test-stack/ and retry."
}

sb() { supabase --workdir "$WORK" "$@"; }

# config.toml from the real one, so the two never drift: new project_id and
# every port moved up by OFFSET (inspector 8083 -> 9083 too).
write_config() {
  awk -v id="$PROJECT_ID" -v off="$OFFSET" '
    /^project_id[[:space:]]*=/ { print "project_id = \"" id "\""; next }
    /^[[:space:]]*(port|shadow_port|inspector_port)[[:space:]]*=[[:space:]]*[0-9]+/ {
      split($0, kv, "="); n = kv[2] + 0
      sub(/[0-9]+/, n + off); print; next
    }
    { print }
  ' "$SRC/config.toml" >"$DEST/config.toml"
}

# functions/ is a fresh copy of each function plus a placeholder .env from
# .env.example, so a real functions/.env never reaches this stack. A copy, not
# a symlink: the edge runtime container cannot follow links to host paths.
# The folder itself stays (only its contents are replaced) because a running
# edge runtime has it bind-mounted.
write_functions() {
  mkdir -p "$DEST/functions"
  find "$DEST/functions" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
  local entry
  for entry in "$SRC"/functions/*; do
    cp -R "$entry" "$DEST/functions/"
  done
  sed -e "s#localhost:54321#localhost:$((54321 + OFFSET))#g" \
    "$SRC/functions/.env.example" >"$DEST/functions/.env"
}

prepare() {
  guard_unlinked
  mkdir -p "$DEST"
  write_config
  local dir
  for dir in migrations tests; do
    ln -sfn "$SRC/$dir" "$DEST/$dir"
  done
  write_functions
}

api_port() { echo $((54321 + OFFSET)); }

# The stack's own URL and keys, as shell exports.
print_env() {
  sb status -o env 2>/dev/null |
    grep -E '^(API_URL|ANON_KEY|SERVICE_ROLE_KEY|MAILPIT_URL)=' |
    sed -e 's/^API_URL=/export SUPABASE_URL=/' \
      -e 's/^ANON_KEY=/export SUPABASE_ANON_KEY=/' \
      -e 's/^SERVICE_ROLE_KEY=/export SUPABASE_SERVICE_ROLE_KEY=/' \
      -e 's/^MAILPIT_URL=/export MAILPIT_URL=/'
}

run_tests() {
  sb test db
  local exports
  exports="$(print_env)"
  [[ "$exports" == *"127.0.0.1:$(api_port)"* ]] ||
    die "test stack is not running on $(api_port); run: tool/test_stack.sh start"
  eval "$exports"
  (cd "$ROOT/app" && flutter test --tags supabase --concurrency=1)
}

case "${1:-}" in
  start) prepare; sb start ;;
  reset) prepare; sb db reset ;;
  test) prepare; run_tests ;;
  env) guard_unlinked; print_env ;;
  stop) guard_unlinked; sb stop --no-backup ;;
  *) die "usage: tool/test_stack.sh start|reset|test|env|stop" ;;
esac
