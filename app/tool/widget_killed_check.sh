#!/usr/bin/env bash
# "Done from a widget ticks the task with the app killed" on the iPhone
# simulator (docs/09 M9.5).
#
#   tool/widget_killed_check.sh [<simulator udid>]
#
# A script can't tap a home-screen widget, so step 3 writes the queue entry
# the widget's MarkDone intent writes (ios/Shared/DotStore.swift: same key,
# same fields; its Swift unit tests pin that format) into the App Group
# while the app is terminated. Android's widget Done is DotActionReceiver,
# checked with the app killed by tool/ongoing_killed_check.sh.
#
# 1. integration_test/widget_killed_post_test.dart writes a live task.
# 2. The app is terminated (`simctl terminate`).
# 3. The MarkDone entry goes into the App Group's action_queue.
# 4. integration_test/ongoing_killed_verify_test.dart opens the app, which
#    drains the queue on launch: the task is done.
set -euo pipefail
cd "$(dirname "$0")/.."
udid="${1:-booted}"
app_id="app.dottoday.planner"
group="group.app.dottoday.planner"
log=build/device_logs/ios_widget_killed.log
defines="${DEFINES:-.env}"
mkdir -p build/device_logs
: >"$log"

drive() { # target, extra define
  local target=$1 binary=build/ios/iphonesimulator/Runner.app
  flutter build ios --simulator --debug -t "$target" --dart-define-from-file="$defines" \
    ${2:+--dart-define="$2"} >>"$log" 2>&1 || { cat "$log"; exit 1; }
  xcrun simctl install "$udid" "$binary" >>"$log" 2>&1
  perl -e 'alarm shift; exec @ARGV or die "exec: $!"' 900 \
    flutter drive --driver=test_driver/integration_test.dart --target="$target" \
    --keep-app-running --use-application-binary="$binary" -d "$udid" \
    --dart-define-from-file="$defines" ${2:+--dart-define="$2"} >>"$log" 2>&1 || { cat "$log"; exit 1; }
}

drive integration_test/widget_killed_post_test.dart
id=$(grep -o "WIDGET_KILLED id=[0-9a-f-]*" "$log" | tail -1 | cut -d= -f2)
[[ -n "$id" ]] || { echo "phase 1 printed no id" >&2; exit 1; }

xcrun simctl terminate "$udid" "$app_id" || true
echo "app process: terminated"

container=$(xcrun simctl get_app_container "$udid" "$app_id" "$group")
plist="$container/Library/Preferences/$group.plist"
now_ms=$(($(date +%s) * 1000))
entry_id=$(python3 -c "import uuid,time,os;b=bytearray(os.urandom(16));ms=int(time.time()*1000);b[0:6]=ms.to_bytes(6,'big');b[6]=(b[6]&0x0F)|0x70;b[8]=(b[8]&0x3F)|0x80;print(str(uuid.UUID(bytes=bytes(b))))")
queue="[{\"id\":\"$entry_id\",\"at_ms\":$now_ms,\"kind\":\"mark_done\",\"occurrence_id\":\"$id\"}]"
xcrun simctl spawn "$udid" defaults write "$plist" action_queue -string "$queue"
echo "queued: $(xcrun simctl spawn "$udid" defaults read "$plist" action_queue)"

drive integration_test/ongoing_killed_verify_test.dart "ONGOING_KILLED_ID=$id"
grep -q "All tests passed" "$log" && echo "WIDGET_KILLED ok: task $id done after a widget Done with the app killed"
