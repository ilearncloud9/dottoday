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
  'android/app/src/main/kotlin/app/dottoday/planner/intents',
  'android/app/src/main/kotlin/app/dottoday/planner/tiles',
  'lib/data/live_activity',
  'lib/data/intents',
  'lib/data/snapshot',
  'lib/data/widgets',
  'lib/features/widgets_home',
];

/// Single native files that feed a surface (the Mac menu bar, M9.6).
const _surfaceFiles = ['macos/Runner/DayDotStatusItem.swift'];

final _network = RegExp(
  r'supabase|access_?token|refresh_?token|URLSession|HttpURLConnection|'
  r'OkHttp|package:http/',
  caseSensitive: false,
);

void main() {
  test('no surface source reaches the network or a session', () {
    final hits = <String>[];
    final files = [
      for (final dir in _surfaceDirs) ...[
        // A renamed folder must fail here, not drop out of the check.
        if (!Directory(dir).existsSync()) fail('missing surface dir $dir'),
        ...Directory(dir).listSync(recursive: true).whereType<File>(),
      ],
      for (final path in _surfaceFiles) File(path),
    ];
    for (final f in files) {
      final ok = ['.swift', '.kt', '.dart'].any(f.path.endsWith);
      if (!ok || f.path.endsWith('.g.dart')) continue;
      if (_network.hasMatch(f.readAsStringSync())) hits.add(f.path);
    }
    expect(hits, isEmpty);
  });
}
