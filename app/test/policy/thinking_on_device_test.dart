import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// ADR-0009 / CLAUDE.md §11 (docs/09 M10.1): no thinking backend makes a
// network call — prompts never leave the device — and the thinking code
// can't write: it imports no repository or write path, so a proposal is
// applied only by Accept in ProposalSheet.

const _dirs = ['lib/domain/thinking', 'lib/data/thinking'];
const _native = [
  'ios/Runner/ThinkingBridge.swift',
  'android/app/src/main/kotlin/app/dottoday/planner/thinking',
];

final _network = RegExp(
  r'supabase|package:http/|dart:io|HttpClient|fetch\(|XMLHttpRequest|'
  r'WebSocket|URLSession|URLRequest|HttpURLConnection|OkHttp|Retrofit|'
  r'https?://',
  caseSensitive: false,
);

final _writes = RegExp(
  r'repositories/|writes/|write_use_case|WriteBatch|change_log|'
  r'Repository\b',
);

List<File> _files(String path) {
  if (File(path).existsSync()) return [File(path)];
  if (!Directory(path).existsSync()) fail('missing thinking source $path');
  return [
    for (final f in Directory(path).listSync(recursive: true).whereType<File>())
      if (!f.path.endsWith('.g.dart')) f,
  ];
}

void main() {
  test('no thinking source reaches the network', () {
    final hits = [
      for (final path in [..._dirs, ..._native])
        for (final f in _files(path))
          if (_network.hasMatch(f.readAsStringSync())) f.path,
    ];
    expect(hits, isEmpty);
  });

  test('the domain thinking code cannot write', () {
    final hits = [
      for (final f in _files('lib/domain/thinking'))
        if (_writes.hasMatch(f.readAsStringSync())) f.path,
    ];
    expect(hits, isEmpty);
  });

  test('no remote backend is implemented while the flag is off', () {
    final hits = [
      for (final path in ['lib/domain', 'lib/data'])
        for (final f in Directory(
          path,
        ).listSync(recursive: true).whereType<File>())
          if (f.path.endsWith('.dart') &&
              RegExp(
                r'implements[^{]*RemoteThinkingBackend',
              ).hasMatch(f.readAsStringSync()))
            f.path,
    ];
    expect(hits, isEmpty);
  });
}
