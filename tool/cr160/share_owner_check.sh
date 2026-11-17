#!/usr/bin/env bash
# CR-160 I7 on the Android emulator: shares through the real ACTION_SEND
# path keep the owner they were queued under (app/integration_test/
# cr160_share_owner_test.dart says what each launch checks).
#
#   tool/cr160/share_owner_check.sh [<adb serial>]
#
# Local only: no server, no defines with keys. Installs the test as the
# app on a cleared app, then:
#   launch 1  plain start: A signs in.
#   kill      force-stop, then a share cold-starts the app (stamped A).
#   launch 2  the test asks for shares ("CR160S SEND …"); each is a real
#             ACTION_SEND to the running app.
#   kill      force-stop with A's share still waiting.
#   launch 3  plain start: it still waits; A signs back in and gets it; a
#             share mid-switch names nobody; a share while an account is
#             being deleted is refused (nothing queued).
set -eo pipefail
cd "$(dirname "$0")/../../app"
adb="${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools/adb"
serial="${1:-emulator-5554}"
app_id="app.dottoday.planner"
log=build/device_logs/android_cr160_share_owner.log
mkdir -p build/device_logs
: >"$log"
a() { "$adb" -s "$serial" "$@"; }

flutter build apk --debug -t integration_test/cr160_share_owner_test.dart >>"$log" 2>&1 \
  || { tail -40 "$log"; exit 1; }
a install -r build/app/outputs/flutter-apk/app-debug.apk >>"$log" 2>&1
a shell pm clear "$app_id" >>"$log" 2>&1
a shell pm grant "$app_id" android.permission.POST_NOTIFICATIONS >>"$log" 2>&1 || true

share() {
  a shell am start -n "$app_id/.MainActivity" -a android.intent.action.SEND -t text/plain \
    --es android.intent.extra.TEXT "'$1'" >>"$log" 2>&1
}

# Waits for "CR160S <step>" in logcat; fails on a test failure.
wait_for() {
  for _ in $(seq 1 180); do
    if a logcat -d -s flutter | grep -q "CR160S $1"; then return 0; fi
    if a logcat -d -s flutter | grep -qE "Some tests failed|EXCEPTION CAUGHT|TestFailure"; then
      a logcat -d -s flutter | tail -80 | tee -a "$log"
      exit 1
    fi
    sleep 1
  done
  echo "timed out waiting for $1" >&2
  a logcat -d -s flutter | tail -80 >&2
  exit 1
}

echo "launch 1: A signs in"
a logcat -c
a shell am start -W -n "$app_id/.MainActivity" >>"$log" 2>&1
wait_for "STAGE1 DONE"
a shell am force-stop "$app_id"

echo "launch 2: a share cold-starts the app"
a logcat -c
share "Cold share for A https://a.example"
wait_for "SEND B"
share "Share while B is shown"
wait_for "SEND STALE"
share "Share while the owner still read A"
wait_for "STAGE2 DONE"
a shell am force-stop "$app_id"

echo "launch 3: after the force-stop"
a logcat -c
a shell am start -W -n "$app_id/.MainActivity" >>"$log" 2>&1
wait_for "SEND SWITCHING"
share "Share mid-switch"
wait_for "SEND REFUSED"
share "Share while deleting"
wait_for "RESULT PASS"
a logcat -d -s flutter | grep "CR160S" | tee -a "$log"
a shell am force-stop "$app_id"
echo "CR160 share owner check: PASS ($(a shell getprop ro.build.version.release | tr -d '\r'), API $(a shell getprop ro.build.version.sdk | tr -d '\r'))"
