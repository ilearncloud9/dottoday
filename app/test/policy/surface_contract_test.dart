import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Surface rule (CLAUDE.md §11, docs/09 M6.5.11): widgets, Live Activity,
// the ongoing notification, menu bar, controls and the watch read the day
// snapshot and call the five intents; none talks to Supabase or holds a
// session (ADR-0010).

/// Native and Dart sources that feed OS surfaces.
const _surfaceDirs = [
  'ios/DottodayWidgets',
  'ios/Shared',
  'android/app/src/main/kotlin/app/dottoday/planner/widgets',
  'lib/data/snapshot',
  'lib/data/widgets',
  'lib/features/widgets_home',
];

final _network = RegExp(
  r'supabase|access_?token|refresh_?token|URLSession|HttpURLConnection|'
  r'OkHttp|package:http/',
  caseSensitive: false,
);

void main() {
  test('no surface source reaches the network or a session', () {
    final hits = <String>[];
    for (final dir in _surfaceDirs) {
      final root = Directory(dir);
      if (!root.existsSync()) continue;
      for (final f in root.listSync(recursive: true).whereType<File>()) {
        final ok = ['.swift', '.kt', '.dart'].any(f.path.endsWith);
        if (!ok || f.path.endsWith('.g.dart')) continue;
        if (_network.hasMatch(f.readAsStringSync())) hits.add(f.path);
      }
    }
    expect(hits, isEmpty);
  });
}
