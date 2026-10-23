#!/usr/bin/env bash
# Runs supabase/tests against the linked (hosted) project (docs/09 M6.0).
# The CLI's temporary login role has no USAGE on `extensions`, where hosted
# pgTAP lives, so each copy switches to `postgres` and puts `extensions` on
# the path — both `set local`, undone by the tests' own rollback. Nothing is
# written to the hosted database.
set -euo pipefail
cd "$(dirname "$0")/.."
tmp="supabase/tests/_hosted"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp"
for f in supabase/tests/0*.sql; do
  perl -0pe 's/^begin;\n/begin;\nset local role postgres;\nset local search_path = "\$user", public, extensions;\n/m' \
    "$f" >"$tmp/$(basename "$f")"
done
supabase test db --linked "$tmp" </dev/null
