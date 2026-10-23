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
app_id="com.yourcompany.dottoday"
adb="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb"

run_phase_one() {
  local log
  log=$(mktemp)
  flutter drive --driver=test_driver/integration_test.dart \
    --target=integration_test/killed_app_schedule_test.dart --keep-app-running \
    ${device:+-d "$device"} --dart-define-from-file="${DEFINES:-.env}" >"$log" 2>&1 || {
    cat "$log"
    return 1
  }
  # The OS notification id phase 1 scheduled: only that one counts.
  scheduled_id=$(grep -o "KILLED_APP scheduled id=[0-9]*" "$log" | grep -o "[0-9]*$")
  echo "KILLED_APP scheduled id=$scheduled_id"
}

# Notifications Android shows now with the id phase 1 scheduled.
android_delivered() {
  local out
  out=$("$adb" ${device:+-s "$device"} shell dumpsys notification --noredact)
  grep -c "pkg=$app_id .* id=$scheduled_id " <<<"$out" || true
}

# Banners SpringBoard posted for the app since [start] (bash 3.2 can't
# parse a multi-line $(… | …) inside `case`, hence a function).
ios_delivered() {
  local out
  out=$(xcrun simctl spawn "$1" log show --start "$2" --style compact \
    --predicate 'process == "SpringBoard"')
  grep "Posting notification id" <<<"$out" | grep -c "section: $app_id;" || true
}

case "$mode" in
  android | android-reboot)
    a() { "$adb" ${device:+-s "$device"} "$@"; }
    a shell pm grant "$app_id" android.permission.POST_NOTIFICATIONS || true
    a shell appops set "$app_id" SCHEDULE_EXACT_ALARM allow || true
    a shell cmd notification dismiss-all >/dev/null 2>&1 || true
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
    xcrun simctl privacy "$udid" grant notifications "$app_id" 2>/dev/null || true
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
