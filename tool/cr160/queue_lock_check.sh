#!/usr/bin/env bash
# CR-160 I7: the queue's file lock works across processes (macOS host).
#
#   tool/cr160/queue_lock_check.sh
#
# Builds tool/cr160/queue_lock/main.swift with the real ios/Shared/DotStore.swift
# and runs 8 processes at once on one preferences suite: 6 append 60 entries
# each while 2 remove 50 seeded entries one by one (under the 500 cap). With the lock every append
# survives and every removal lands; the control run without it shows what the
# lock prevents. A throwaway suite and lock directory; nothing of the app's.
set -euo pipefail
cd "$(dirname "$0")/../.."
work="$(mktemp -d)"
suite="app.dottoday.lockcheck.$$"
bin="$work/qlock"
trap 'defaults delete "$suite" >/dev/null 2>&1 || true; rm -rf "$work"' EXIT
swiftc -O -o "$bin" app/ios/Shared/DotStore.swift tool/cr160/queue_lock/main.swift

run() { # run <shared|separate>: one lock dir for all, or one each (control)
  local mode="$1" lock="$work/shared"
  mkdir -p "$work/shared"
  l() { if [[ "$mode" == shared ]]; then echo "$work/shared"; else mkdir -p "$work/$1"; echo "$work/$1"; fi; }
  defaults delete "$suite" >/dev/null 2>&1 || true
  "$bin" "$suite" "$lock" publish '{"v":1,"owner":"01928c3e-0000-7000-8000-00000000000a"}'
  "$bin" "$suite" "$lock" append seed 100 >/dev/null
  local ids
  ids=$(defaults read "$suite" action_queue | python3 -c 'import json,sys; print(" ".join(e["id"] for e in json.loads(sys.stdin.read())))')
  read -r -a seeded <<<"$ids"
  for p in 1 2 3 4 5 6; do "$bin" "$suite" "$(l "p$p")" append "p$p" 60 & done
  "$bin" "$suite" "$(l r1)" remove "${seeded[@]:0:50}" &
  "$bin" "$suite" "$(l r2)" remove "${seeded[@]:50:50}" &
  wait
  "$bin" "$suite" "$lock" count
}

echo "with the lock (expect entries 360, one owner, nothing refused):"
locked=$(run shared)
echo "$locked" | sed "s/^/  /"
echo "control, each process its own lock (no exclusion; losses expected):"
run separate | sed "s/^/  /"
[[ "$(tail -1 <<<"$locked")" == "entries 360 owners 01928c3e-0000-7000-8000-00000000000a" ]] \
  && echo "QUEUE LOCK CROSS-PROCESS: PASS ($(sw_vers -productVersion))" \
  || { echo "QUEUE LOCK CROSS-PROCESS: FAIL"; exit 1; }
