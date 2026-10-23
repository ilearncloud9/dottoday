#!/usr/bin/env bash
# Device integration tests that can't hang (docs/09 M6.5.12).
#
#   tool/device_tests.sh android [emulator-5554] [test ...]
#   tool/device_tests.sh ios [<simulator udid>] [test ...]
#
# Tests are names under integration_test/ without `_test.dart`; default:
# the device suite below. thread_perf is not here: it needs
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
    notification_exactness sweep)
fi
defines="${DEFINES:-.env}"
limit=$((15 * 60))
app_id="com.yourcompany.dottoday"
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
  # The sweep needs no permission; its screenshots come out blank from a
  # prebuilt binary, so it is driven from source, tagged per platform
  # (build/sweep/<platform>_<shot>.png).
  if [[ "$t" == sweep ]]; then
    with_limit flutter drive --driver="$driver" \
      --target="integration_test/${t}_test.dart" \
      --dart-define=SWEEP_TAG="$platform" \
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
  with_limit flutter drive --driver="$driver" \
    --target="integration_test/${t}_test.dart" \
    --use-application-binary="$binary" \
    ${device:+-d "$device"} --dart-define-from-file="$defines" >>"$log" 2>&1
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
done
exit $failed
