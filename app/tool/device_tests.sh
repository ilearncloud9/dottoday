#!/usr/bin/env bash
# Device integration tests that can't hang (docs/09 M6.5.12).
#
#   tool/device_tests.sh android [emulator-5554] [test ...]
#   tool/device_tests.sh ios [<simulator udid>] [test ...]
#
# Tests are names under integration_test/ without `_test.dart`; default:
# the device suite below. The calendar checks (calendar_prompt,
# calendar_denied, calendar_import, calendar_live_change, calendar_write_back,
# calendar_revoked, iOS also calendar_regranted; docs/08 §5b) are named
# explicitly, in that order. thread_perf is not here: it needs
# `flutter drive --profile --no-dds` on physical hardware (M5.9b).
#
# For each test: build the app with that test as its entry, install it as an
# *update* (`adb install -r` keeps runtime grants and app-ops), answer every
# permission dialog up front (Android: `pm grant` POST_NOTIFICATIONS and
# `appops` SCHEDULE_EXACT_ALARM; iOS: tests take provisional authorisation,
# which never prompts — integration_test/support/no_dialog_notifications.dart),
# then `flutter drive --use-application-binary` so nothing reinstalls.
# Every run writes its full log to build/device_logs/<platform>_<test>.log
# and fails with TIMEOUT after 15 minutes instead of hanging.
#
# DEFINES picks the --dart-define-from-file (default .env; CI .env.example).
# DRIVER picks the driver (default test_driver/integration_test.dart; the
# sweep uses test_driver/screenshot_driver.dart automatically).
# SWEEP_THEME=dark runs the sweep dark (shots named <platform>_dark_*).
set -uo pipefail
cd "$(dirname "$0")/.."
platform="${1:?android | ios}"
shift
device=""
# A device id is an emulator serial or a simulator UDID.
if [[ $# -gt 0 && ( "$1" == emulator-* || "$1" =~ ^[0-9A-F-]{36}$ ) ]]; then
  device="$1"
  shift
fi
tests=("$@")
if [[ ${#tests[@]} -eq 0 ]]; then
  tests=(app_launch onboarding journey deep_link background_refresh
    notification_exactness surface_consistency)
  # The live dot (M9.3, M9.4): each platform's own surface.
  if [[ "$platform" == ios ]]; then tests+=(live_activity); else tests+=(ongoing_dot); fi
  # The Wake Up alarm's ringing service (M17.2); AlarmKit is a device gate.
  if [[ "$platform" == android ]]; then tests+=(wake_up_alarm); fi
  # The on-device model (M10.1): availability, and < 2 s where one is ready.
  tests+=(thinking sweep)
fi
defines="${DEFINES:-.env}"
limit=$((15 * 60))
app_id="app.dottoday.planner"
adb="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb"
logs="build/device_logs"
mkdir -p "$logs"

# Runs "$@" with a hard limit: SIGALRM after $limit s (exit 142 = timeout).
with_limit() { perl -e 'alarm shift; exec @ARGV or die "exec: $!"' "$limit" "$@"; }

a() { "$adb" ${device:+-s "$device"} "$@"; }

android_grants() {
  a shell pm grant "$app_id" android.permission.POST_NOTIFICATIONS
  a shell appops set "$app_id" SCHEDULE_EXACT_ALARM allow
}

# The calendar checks (docs/08 §6.2, M7.7) set the calendar permission up
# front, never through the OS prompt: prompt = never asked, denied = no
# without a prompt (Android: user-fixed), revoked = granted earlier, now
# off (revoking ends a running app, so it happens before the launch).
cal_perms="android.permission.READ_CALENDAR android.permission.WRITE_CALENDAR"
calendar_access() {
  local state="$1" p
  if [[ "$platform" == ios ]]; then
    case "$state" in
      grant) xcrun simctl privacy "${device:-booted}" grant calendar "$app_id" ;;
      reset) xcrun simctl privacy "${device:-booted}" reset calendar "$app_id" ;;
      *) xcrun simctl privacy "${device:-booted}" revoke calendar "$app_id" ;;
    esac
    return
  fi
  for p in $cal_perms; do
    case "$state" in
      grant) a shell pm grant "$app_id" "$p" ;;
      reset)
        a shell pm revoke "$app_id" "$p"
        a shell pm clear-permission-flags "$app_id" "$p" user-set user-fixed
        ;;
      *)
        a shell pm revoke "$app_id" "$p"
        a shell pm set-permission-flags "$app_id" "$p" user-fixed
        ;;
    esac
  done
}

prepare() {
  case "$1" in
    calendar_prompt) calendar_access reset ;;
    calendar_denied | calendar_revoked) calendar_access revoke ;;
    calendar_import | calendar_live_change | calendar_write_back | calendar_regranted) calendar_access grant ;;
  esac
}

# Back from the browser a test opened (a backgrounded app draws no
# frames, so the test can't finish on its own).
bring_to_front() {
  if [[ "$platform" == ios ]]; then
    xcrun simctl launch "${device:-booted}" "$app_id"
  else
    a shell am start -n "$app_id/.MainActivity"
  fi
}

# A test asks for a screenshot with `DEVICE_SHOT <name>` (saved as
# build/device_shots/<platform>_<name>.png) and for calendar access back
# with `DEVICE_GRANT calendar`; `DEVICE_FRONT app` brings the app back; `DEVICE_AWAY <name>` (before a
# tap that leaves the app) waits, shoots and brings it back; `DEVICE_BACK
# <name>` (before a tap that opens a system sheet) waits, shoots and presses
# Back on Android.
shoot() {
  local out="build/device_shots/${platform}_$1.png"
  mkdir -p build/device_shots
  if [[ "$platform" == ios ]]; then
    xcrun simctl io "${device:-booted}" screenshot "$out" >/dev/null 2>&1
  else
    a exec-out screencap -p >"$out" 2>/dev/null
  fi
}

run_one() {
  local t="$1" log="$logs/${platform}_$1.log" driver binary
  driver="${DRIVER:-test_driver/integration_test.dart}"
  [[ "$t" == sweep ]] && driver=test_driver/screenshot_driver.dart
  : >"$log"
  if [[ "$t" == sweep ]]; then
    :
  elif [[ "$platform" == android ]]; then
    flutter build apk --debug -t "integration_test/${t}_test.dart" \
      --dart-define-from-file="$defines" >>"$log" 2>&1 || return 1
    binary=build/app/outputs/flutter-apk/app-debug.apk
    a install -r "$binary" >>"$log" 2>&1 || return 1
    android_grants >>"$log" 2>&1 || return 1
  else
    flutter build ios --simulator --debug -t "integration_test/${t}_test.dart" \
      --dart-define-from-file="$defines" >>"$log" 2>&1 || return 1
    binary=build/ios/iphonesimulator/Runner.app
    xcrun simctl install "${device:-booted}" "$binary" >>"$log" 2>&1 || return 1
  fi
  [[ "$t" != sweep ]] && { prepare "$t" >>"$log" 2>&1 || return 1; }
  # The sweep needs no permission; its screenshots come out blank from a
  # prebuilt binary, so it is driven from source, tagged per platform
  # (build/sweep/<platform>_<shot>.png).
  if [[ "$t" == sweep ]]; then
    with_limit flutter drive --driver="$driver" \
      --target="integration_test/${t}_test.dart" \
      --dart-define=SWEEP_TAG="$platform" \
      ${SWEEP_THEME:+--dart-define=SWEEP_THEME="$SWEEP_THEME"} \
      ${device:+-d "$device"} --dart-define-from-file="$defines" >>"$log" 2>&1 &
    local drive=$!
    # iOS: the test announces each shot (its own capture is blank) and holds
    # still while the simulator's screen is saved.
    local seen=""
    while kill -0 "$drive" 2>/dev/null; do
      if [[ "$platform" == ios ]]; then
        for name in $(grep -o 'SWEEP_SHOT [a-z0-9_]*' "$log" | cut -d' ' -f2); do
          case " $seen " in *" $name "*) continue ;; esac
          sleep 1
          xcrun simctl io "${device:-booted}" screenshot "build/sweep/$name.png" >/dev/null 2>&1
          seen="$seen $name"
        done
      fi
      sleep 0.5
    done
    wait "$drive"
    return
  fi
  # flutter drive uninstalls the app when it stops it; calendar_revoked
  # (and calendar_regranted after it) need what the run before left.
  local keep=""
  [[ "$t" == calendar_write_back || "$t" == calendar_revoked ]] &&
    keep="--keep-app-running"
  with_limit flutter drive --driver="$driver" \
    --target="integration_test/${t}_test.dart" \
    --use-application-binary="$binary" $keep \
    ${device:+-d "$device"} --dart-define-from-file="$defines" >>"$log" 2>&1 &
  local drive=$! done_marks="" mark
  while kill -0 "$drive" 2>/dev/null; do
    for mark in $(grep -oE 'DEVICE_(SHOT|GRANT|FRONT|AWAY|BACK) [a-z0-9_]+' "$log" | tr ' ' ':'); do
      case " $done_marks " in *" $mark "*) continue ;; esac
      done_marks="$done_marks $mark"
      case "$mark" in
        DEVICE_SHOT:*) shoot "${mark#DEVICE_SHOT:}" ;;
        DEVICE_GRANT:calendar) calendar_access grant >>"$log" 2>&1 ;;
        DEVICE_FRONT:*) bring_to_front >>"$log" 2>&1 ;;
        DEVICE_BACK:*)
          # A system sheet over the app (Android's share chooser, the mail
          # app): shoot it, then Back — `am start` would re-create the
          # activity there and restart the test (found in M8.5).
          sleep 5
          shoot "${mark#DEVICE_BACK:}"
          if [[ "$platform" == android ]]; then
            a shell input keyevent KEYCODE_BACK >>"$log" 2>&1
          else
            bring_to_front >>"$log" 2>&1
          fi
          ;;
        DEVICE_AWAY:*)
          # The test is about to send the app away (browser, Settings);
          # iOS suspends it there, so the script shoots and brings it back.
          sleep 5
          shoot "${mark#DEVICE_AWAY:}"
          bring_to_front >>"$log" 2>&1
          ;;
      esac
    done
    sleep 0.5
  done
  wait "$drive"
}

# Start clean: a system alert left over from an earlier run sits over
# everything (found in M6.5.12: an hours-old notification prompt covered a
# whole sweep). iOS: reboot the simulator, which drops it; Android: close
# system dialogs.
if [[ "$platform" == ios ]]; then
  udid="${device:-booted}"
  [[ "$udid" == booted ]] && udid=$(xcrun simctl list devices booted | grep -o "[0-9A-F-]\{36\}" | head -1)
  xcrun simctl shutdown "$udid" >/dev/null 2>&1 || true
  xcrun simctl boot "$udid" && xcrun simctl bootstatus "$udid" -b >/dev/null
else
  a shell am broadcast -a android.intent.action.CLOSE_SYSTEM_DIALOGS >/dev/null 2>&1 || true
fi

failed=0
for t in "${tests[@]}"; do
  start=$SECONDS
  run_one "$t"
  code=$?
  took=$((SECONDS - start))
  result=PASS
  [[ $code -ne 0 ]] && result=FAIL && failed=1
  [[ $code -eq 142 ]] && result="TIMEOUT (>15 min)"
  extra=$(grep -ho "EXACTNESS .*" "$logs/${platform}_$t.log" | tail -1)
  echo "DEVICE $platform $t: $result ${took}s ${extra} log=$logs/${platform}_$t.log"
  grep -ho "CAL_CHECK .*" "$logs/${platform}_$t.log" | sort -u
done
exit $failed
