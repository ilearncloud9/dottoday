#!/usr/bin/env bash
# Design sweep on macOS (docs/08 §7): runs integration_test/sweep_test.dart
# and captures the app window each time the test prints SWEEP_SHOT <name>
# (integration_test's takeScreenshot doesn't support macOS).
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/sweep
log=build/sweep/macos_run.log
winid() {
  swift - <<'SWIFT'
import CoreGraphics
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as! [[String: Any]]
for w in list where (w[kCGWindowOwnerName as String] as? String) == "dottoday"
  && (w[kCGWindowLayer as String] as? Int) == 0 {
  print(w[kCGWindowNumber as String]!); break
}
SWIFT
}
flutter drive -d macos --dart-define-from-file=.env.example \
  --dart-define=SWEEP_TAG=macos \
  --driver=test_driver/screenshot_driver.dart \
  --target=integration_test/sweep_test.dart >"$log" 2>&1 &
drive=$!
seen=""
while kill -0 "$drive" 2>/dev/null; do
  for name in $(grep -o 'SWEEP_SHOT [a-z_]*' "$log" | cut -d' ' -f2); do
    case " $seen " in *" $name "*) continue ;; esac
    sleep 1
    screencapture -x -o -l"$(winid)" "build/sweep/$name.png"
    seen="$seen $name"
  done
  sleep 0.5
done
wait "$drive"
