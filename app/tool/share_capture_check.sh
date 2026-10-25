#!/usr/bin/env bash
# "Share → Dottoday" on the Android emulator (docs/09 M12.4, 11 B6).
#
#   tool/share_capture_check.sh [<adb serial>]
#
# 1. Builds integration_test/share_capture_verify_test.dart as the app and
#    installs it on a cleared app.
# 2. Sends a real ACTION_SEND (text/plain: a title and a link) to
#    MainActivity, as any app's share sheet does: ShareIntake queues it
#    before Flutter starts and turns the intent into dottoday://inbox.
# 3. The test inside the app drains the queue and finds the Inbox task
#    with the link kept as its note; it prints SHARE_CAPTURE ok to logcat.
set -euo pipefail
cd "$(dirname "$0")/.."
adb="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb"
serial="${1:-emulator-5554}"
app_id="app.dottoday.planner"
defines="${DEFINES:-.env}"
log=build/device_logs/android_share_capture.log
mkdir -p build/device_logs
: >"$log"

flutter build apk --debug -t integration_test/share_capture_verify_test.dart \
  --dart-define-from-file="$defines" >>"$log" 2>&1 || { cat "$log"; exit 1; }
"$adb" -s "$serial" install -r build/app/outputs/flutter-apk/app-debug.apk >>"$log" 2>&1
"$adb" -s "$serial" shell pm clear "$app_id" >>"$log" 2>&1
"$adb" -s "$serial" logcat -c
"$adb" -s "$serial" shell am start -W -n "$app_id/.MainActivity" \
  -a android.intent.action.SEND -t text/plain \
  --es android.intent.extra.TEXT "'Dentist booking https://dentist.example/book'" >>"$log" 2>&1
for _ in $(seq 1 120); do
  if "$adb" -s "$serial" logcat -d -s flutter | grep -q "SHARE_CAPTURE ok"; then
    echo "SHARE_CAPTURE ok: an ACTION_SEND landed in the Inbox with its link as the note"
    exit 0
  fi
  if "$adb" -s "$serial" logcat -d -s flutter | grep -qE "Some tests failed|EXCEPTION CAUGHT"; then
    "$adb" -s "$serial" logcat -d -s flutter | tail -60
    exit 1
  fi
  sleep 1
done
echo "timed out; logcat:" >&2
"$adb" -s "$serial" logcat -d -s flutter | tail -60 >&2
exit 1
