import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// tool/web_db_assets.sh pins one sqlite3mc.wasm digest per sqlite3 version.
// Catch a lockfile bump here instead of in the web CI build (M2.1).
void main() {
  test('sqlite3mc.wasm digest is pinned for the locked sqlite3 version', () {
    final lock = File('pubspec.lock').readAsStringSync();
    final version = RegExp(
      r'\n  sqlite3:\n(?:    .*\n)*?    version: "([^"]+)"',
    ).firstMatch(lock)!.group(1)!;
    final script = File('../tool/web_db_assets.sh').readAsStringSync();
    expect(
      RegExp(
        '\\n    ${RegExp.escape(version)}\\) echo [0-9a-f]{64} ;;',
      ).hasMatch(script),
      isTrue,
      reason:
          'pin sqlite3mc.wasm for sqlite3 $version in tool/web_db_assets.sh',
    );
  });
}
