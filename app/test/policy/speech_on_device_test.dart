import 'dart:io';

import 'package:dottoday/data/speech/speech_wire.dart';
import 'package:dottoday/domain/speech/speech_recognizer.dart';
import 'package:flutter_test/flutter_test.dart';

// ADR-0014 (D1, D2): dictation runs on the device's own recognizer or not
// at all. Each bridge must ask for on-device recognition, none may reach
// the network, and the words they send must be ones Dart reads (docs/09
// M14.4). The permission texts are the owner's (D5).

const _swift = 'ios/Runner/SpeechBridge.swift';
const _kotlin =
    'android/app/src/main/kotlin/app/dottoday/planner/speech/SpeechBridge.kt';
const _web = 'lib/data/speech/web/speech_web.dart';
const _dirs = ['lib/domain/speech', 'lib/data/speech'];

final _network = RegExp(
  r'supabase|package:http/|dart:io|HttpClient|fetch\(|XMLHttpRequest|'
  r'WebSocket|URLSession|URLRequest|HttpURLConnection|OkHttp|Retrofit|'
  r'https?://',
  caseSensitive: false,
);

String _read(String path) => File(path).readAsStringSync();

List<File> _sources(String path) => [
  for (final f in Directory(path).listSync(recursive: true).whereType<File>())
    if (!f.path.endsWith('.g.dart')) f,
];

final _quoted = RegExp('"([a-z_]+)"');
Set<String> _words(String src) => {
  for (final m in _quoted.allMatches(src)) m.group(1)!,
};

void main() {
  test('Swift requires on-device recognition', () {
    final src = _read(_swift);
    expect(src, contains('request.requiresOnDeviceRecognition = true'));
    expect(src, contains('supportsOnDeviceRecognition else'));
  });

  test('Kotlin only creates the on-device recognizer, API 31+', () {
    final src = _read(_kotlin);
    expect(src, contains('SpeechRecognizer.createOnDeviceSpeechRecognizer('));
    expect(src, contains('SpeechRecognizer.isOnDeviceRecognitionAvailable('));
    expect(src, contains('Build.VERSION_CODES.S'));
    expect(
      RegExp(r'\bcreateSpeechRecognizer\(').hasMatch(src),
      isFalse,
      reason: 'the default recognizer may use a server',
    );
  });

  test('the web uses only the on-device mode', () {
    final src = _read(_web);
    expect(src, contains("'processLocally'.toJS, true.toJS"));
    expect(src, contains("'processLocally': true"));
    expect(src, contains("has('processLocally')"));
    expect(src, isNot(contains("'webkitSpeechRecognition'")));
  });

  test('no speech source reaches the network', () {
    final hits = [
      for (final f in [
        for (final d in _dirs) ..._sources(d),
        File(_swift),
        File(_kotlin),
      ])
        if (_network.hasMatch(f.readAsStringSync())) f.path,
    ];
    expect(hits, isEmpty);
  });

  test('no bridge logs what was said', () {
    final logs = RegExp(r'\bNSLog|\bprint\(|os_log|Logger\(|\bLog\.[dviwe]\(');
    for (final path in [_swift, _kotlin]) {
      expect(logs.hasMatch(_read(path)), isFalse, reason: path);
    }
  });

  test('the bridges send only words Dart reads', () {
    const availability = {
      'available': SpeechAvailability.available,
      'needs_permission': SpeechAvailability.needsPermission,
      'denied': SpeechAvailability.denied,
      'unavailable': SpeechAvailability.unavailable,
    };
    for (final MapEntry(key: w, value: a) in availability.entries) {
      expect(parseSpeechAvailability(w), a);
    }
    const events = {'type', 'text', 'code', 'partial', 'final', 'stopped'};
    const codes = {'permission', 'unavailable', 'interrupted', 'recognizer'};
    const known = {...events, 'error', ...codes};
    for (final path in [_swift, _kotlin]) {
      final src = _read(path);
      final sent = {
        for (final w in _words(src))
          if (availability.containsKey(w) || known.contains(w)) w,
      };
      expect(sent, containsAll(['partial', 'final', 'stopped', 'error']));
      expect(sent, containsAll(['available', 'needs_permission', 'denied']));
      expect(sent, containsAll(['permission', 'unavailable', 'recognizer']));
    }
    expect(
      parseSpeechEvent({'type': 'error', 'code': 'permission'}),
      isA<SpeechError>(),
    );
    expect(
      parseSpeechEvent({'type': 'partial', 'text': 'x'}),
      isA<SpeechPartial>(),
    );
    expect(
      parseSpeechEvent({'type': 'final', 'text': 'x'}),
      isA<SpeechFinal>(),
    );
    expect(parseSpeechEvent({'type': 'stopped'}), isA<SpeechStopped>());
    expect(parseSpeechEvent({'type': 'other'}), isNull);
  });

  test("the permission texts are the owner's (D5)", () {
    const mic =
        'Dottoday listens only while the mic button is on, to turn your '
        'words into text on this device.';
    const speech =
        'Your words are turned into text on this device. Nothing is sent to '
        'a server.';
    for (final plist in ['ios/Runner/Info.plist', 'macos/Runner/Info.plist']) {
      final src = _read(plist);
      expect(
        src,
        contains(
          '<key>NSMicrophoneUsageDescription</key>\n\t<string>$mic</string>',
        ),
        reason: plist,
      );
      expect(
        src,
        contains(
          '<key>NSSpeechRecognitionUsageDescription</key>\n'
          '\t<string>$speech</string>',
        ),
        reason: plist,
      );
    }
    // Android's in-app rationale says the same (ARB).
    expect(_read('lib/core/l10n/arb/app_en.arb'), contains('"$mic"'));
    for (final e in ['DebugProfile', 'Release']) {
      expect(
        _read('macos/Runner/$e.entitlements'),
        contains('com.apple.security.device.audio-input'),
      );
    }
  });
}
