#!/usr/bin/env bash
# "The ongoing notification's Done works with the app killed" (docs/09 M9.4).
#
#   tool/ongoing_killed_check.sh [emulator-5554]
#
# DEFINES picks the --dart-define-from-file (default .env; CI: .env.example).
#
# 1. integration_test/ongoing_killed_post_test.dart writes a live task and
#    waits for its ongoing notification (flutter drive --keep-app-running).
# 2. The app is killed as the OS kills it (`am kill` from the background,
#    then SIGKILL), never force-stopped.
# 3. The notification shade is opened and its Done button tapped
#    (uiautomator): DotActionReceiver queues the action with no Flutter
#    engine; the notification must disappear.
# 4. integration_test/ongoing_killed_verify_test.dart opens the app, which
#    drains the queue: the task is done.
set -euo pipefail
cd "$(dirname "$0")/.."
device="${1:-}"
app_id="app.dottoday.planner"
adb="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb"
a() { "$adb" ${device:+-s "$device"} "$@"; }
log=build/device_logs/android_ongoing_killed.log
mkdir -p build/device_logs
: >"$log"
defines="${DEFINES:-.env}"

drive() { # target, extra define
  local target=$1 binary=build/app/outputs/flutter-apk/app-debug.apk
  flutter build apk --debug -t "$target" --dart-define-from-file="$defines" ${2:+--dart-define="$2"} \
    >>"$log" 2>&1 || { cat "$log"; exit 1; }
  a install -r "$binary" >>"$log" 2>&1
  a shell pm grant "$app_id" android.permission.POST_NOTIFICATIONS >>"$log" 2>&1
  perl -e 'alarm shift; exec @ARGV or die "exec: $!"' 900 \
    flutter drive --driver=test_driver/integration_test.dart --target="$target" \
    --keep-app-running --use-application-binary="$binary" ${device:+-d "$device"} \
    --dart-define-from-file="$defines" ${2:+--dart-define="$2"} >>"$log" 2>&1 || { cat "$log"; exit 1; }
}

posted() { a shell dumpsys notification --noredact | grep -c "pkg=$app_id .* id=3335 " || true; }

drive integration_test/ongoing_killed_post_test.dart
id=$(grep -o "ONGOING_KILLED id=[0-9a-f-]*" "$log" | tail -1 | cut -d= -f2)
[[ -n "$id" ]] || { echo "phase 1 printed no id" >&2; exit 1; }

a shell input keyevent KEYCODE_HOME
sleep 2
a shell am kill "$app_id"
if pid=$(a shell pidof "$app_id"); then a shell run-as "$app_id" kill -9 "$pid" || true; fi
[[ -z "$(a shell pidof "$app_id" || true)" ]] || { echo "app still running" >&2; exit 1; }
echo "app process: gone; ongoing notifications: $(posted)"
[[ "$(posted)" -ge 1 ]] || { echo "the ongoing notification is gone with the app" >&2; exit 1; }

a shell cmd statusbar expand-notifications
sleep 2
# uiautomator never sees the shade idle while the chronometer ticks, so the
# Done button's position comes from DONE_TAP="x y" (read it off a shade
# screenshot once per device; Medium Phone API 37: "274 856"); without it
# the script tries uiautomator anyway.
if [[ -n "${DONE_TAP:-}" ]]; then
  a shell input tap $DONE_TAP
else
  a shell uiautomator dump /sdcard/ongoing.xml >/dev/null || true
  bounds=$(a shell cat /sdcard/ongoing.xml 2>/dev/null | grep -o 'text="Done"[^>]*bounds="\[[0-9]*,[0-9]*\]\[[0-9]*,[0-9]*\]"' |
    head -1 | grep -o '\[[0-9]*,[0-9]*\]\[[0-9]*,[0-9]*\]' || true)
  [[ -n "$bounds" ]] || { echo "no Done button found: set DONE_TAP" >&2; exit 1; }
  read -r x1 y1 x2 y2 <<<"$(tr '[],' '   ' <<<"$bounds")"
  a shell input tap $(((x1 + x2) / 2)) $(((y1 + y2) / 2))
fi
sleep 3
a shell cmd statusbar collapse
echo "after Done: ongoing notifications: $(posted)"
[[ "$(posted)" -eq 0 ]] || { echo "Done did not remove the notification" >&2; exit 1; }

drive integration_test/ongoing_killed_verify_test.dart "ONGOING_KILLED_ID=$id"
grep -q "All tests passed" "$log" && echo "ONGOING_KILLED ok: task $id done after a killed-app Done"
