#!/usr/bin/env bash
# "A dot-start fires with the app killed" (docs/09 M6.5.10, 11 A0).
#
#   tool/killed_app_check.sh android [emulator-5554]
#   tool/killed_app_check.sh ios [<simulator udid>]
#   tool/killed_app_check.sh android-reboot [emulator-5554]
#
# DEFINES picks the --dart-define-from-file (default .env; CI: .env.example).
#
# 1. integration_test/killed_app_schedule_test.dart schedules one dot-start
#    75 s out through the real write path and OS scheduler. It runs under
#    `flutter drive --keep-app-running`: `flutter test` force-stops (and by
#    default uninstalls) the app when it finishes, which cancels its alarms.
# 2. The app is killed as the OS kills it: Android `am kill` from the
#    background (`force-stop` would cancel its alarms itself), iOS
#    `simctl terminate`; with "android-reboot" the emulator also reboots.
# 3. After the start time, the OS is asked what it delivered: exactly one
#    notification titled "Killed-app check".
set -euo pipefail
cd "$(dirname "$0")/.."
mode="${1:?android | ios | android-reboot}"
device="${2:-}"
title="Killed-app check"
app_id="app.dottoday.planner"
adb="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb"
a() { "$adb" ${device:+-s "$device"} "$@"; }

run_phase_one() {
  local log="build/device_logs/${mode}_killed_app.log" binary
  local target=integration_test/killed_app_schedule_test.dart
  mkdir -p build/device_logs
  : >"$log"
  # Install as an update, then grant (no dialog ever, M6.5.12), then drive
  # that binary so nothing reinstalls.
  if [[ "$mode" == ios ]]; then
    flutter build ios --simulator --debug -t "$target" \
      --dart-define-from-file="${DEFINES:-.env}" >>"$log" 2>&1 || { cat "$log"; return 1; }
    binary=build/ios/iphonesimulator/Runner.app
    xcrun simctl install "${device:-booted}" "$binary" >>"$log" 2>&1
  else
    flutter build apk --debug -t "$target" \
      --dart-define-from-file="${DEFINES:-.env}" >>"$log" 2>&1 || { cat "$log"; return 1; }
    binary=build/app/outputs/flutter-apk/app-debug.apk
    a install -r "$binary" >>"$log" 2>&1
    a shell pm grant "$app_id" android.permission.POST_NOTIFICATIONS >>"$log" 2>&1
    a shell appops set "$app_id" SCHEDULE_EXACT_ALARM allow >>"$log" 2>&1
  fi
  # 15 min hard limit, as in tool/device_tests.sh: never hang.
  perl -e 'alarm shift; exec @ARGV or die "exec: $!"' 900 \
    flutter drive --driver=test_driver/integration_test.dart --target="$target" \
    --keep-app-running --use-application-binary="$binary" \
    ${device:+-d "$device"} --dart-define-from-file="${DEFINES:-.env}" >>"$log" 2>&1 || {
    cat "$log"
    return 1
  }
  # The OS notification id phase 1 scheduled: only that one counts.
  scheduled_id=$(grep -o "KILLED_APP scheduled id=[0-9]*" "$log" | grep -o "[0-9]*$")
  echo "KILLED_APP scheduled id=$scheduled_id log=$log"
}

# Notifications Android shows now with the id phase 1 scheduled.
android_delivered() {
  local out
  out=$("$adb" ${device:+-s "$device"} shell dumpsys notification --noredact)
  grep -c "pkg=$app_id .* id=$scheduled_id " <<<"$out" || true
}

# Banners SpringBoard posted since [start] for the request phase 1
# scheduled — by id, so a Bedtime reminder in the window doesn't count.
# SpringBoard names requests by a short id ("FFEF-4D1A"); the line that
# loads the request maps it to our identifier. (bash 3.2 can't parse a
# multi-line $(… | …) inside `case`, hence a function.)
ios_delivered() {
  local out request
  out=$(xcrun simctl spawn "$1" log show --start "$2" --style compact \
    --predicate 'process == "SpringBoard"')
  request=$(grep "identifier: $scheduled_id," <<<"$out" |
    grep -o "request [0-9A-F]\{4\}-[0-9A-F]\{4\}" | head -1 | cut -d' ' -f2)
  [[ -z "$request" ]] && { echo 0; return; }
  grep "Posting notification id: $request;" <<<"$out" | grep -c "section: $app_id;" || true
}

case "$mode" in
  android | android-reboot)
    run_phase_one
    a shell input keyevent KEYCODE_HOME
    sleep 2
    a shell am kill "$app_id"
    # Still there (recently in front): SIGKILL, as a low-memory kill does —
    # never force-stop, which would cancel the alarms.
    if pid=$(a shell pidof "$app_id"); then
      a shell run-as "$app_id" kill -9 "$pid" || true
    fi
    if [[ "$mode" == android-reboot ]]; then
      a reboot
      a wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 2; done'
    fi
    if [[ -z "$(a shell pidof "$app_id" || true)" ]]; then
      echo "app process: gone"
    else
      echo "app process: still running" >&2
      exit 1
    fi
    sleep 95
    count=$(android_delivered)
    ;;
  ios)
    udid="${device:-booted}"
    # No dialog: the test takes provisional authorisation (simctl privacy
    # has no notifications service).
    start=$(date +"%Y-%m-%d %H:%M:%S") # local: what log show reads
    run_phase_one
    xcrun simctl terminate "$udid" "$app_id" || true
    echo "app process: terminated"
    sleep 95
    count=$(ios_delivered "$udid" "$start")
    ;;
  *) echo "unknown mode $mode" >&2; exit 2 ;;
esac

echo "KILLED_APP delivered=$count (want 1)"
[[ "$count" == 1 ]]
