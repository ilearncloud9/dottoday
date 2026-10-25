import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// The action queue (docs/09 M9.2) is written by Swift, Kotlin and the
// service worker and read by Dart: the kinds and keys must be spelled the
// same everywhere, or an action is dropped as unreadable.

const _dart = 'lib/domain/intents/dot_action.dart';

/// Native writers of queue entries.
const _writers = {
  'ios/Shared/DotStore.swift': 'Swift',
  'android/app/src/main/kotlin/app/dottoday/planner/intents/DotQueue.kt':
      'Kotlin',
};

const _wire = [
  'add_task',
  'mark_done',
  'add_fifteen',
  'start_focus',
  'occurrence_id',
  'planned_end_ms',
  'at_ms',
];

void main() {
  final dart = File(_dart).readAsStringSync();

  test('Dart reads every wire name', () {
    for (final name in _wire) {
      expect(dart, contains("'$name'"), reason: name);
    }
  });

  for (final MapEntry(key: path, value: lang) in _writers.entries) {
    test('$lang writes the same names', () {
      final src = File(path).readAsStringSync();
      for (final name in _wire) {
        expect(src, contains('"$name"'), reason: '$path: $name');
      }
      expect(src, contains('"action_queue"'), reason: path);
    });
  }

  test('the service worker writes the same names and path', () {
    final js = File('web/action_queue.js').readAsStringSync();
    for (final name in ['mark_done', 'add_fifteen']) {
      expect(js, contains("'$name'"), reason: name);
    }
    for (final key in ['occurrence_id', 'planned_end_ms', 'at_ms']) {
      expect(js, matches(RegExp('\\b$key\\b')), reason: key);
    }
    final dart = File(
      'lib/data/snapshot/web/snapshot_store_web.dart',
    ).readAsStringSync();
    expect(js, contains("PATH = '__snapshot/actions.json'"));
    expect(dart, contains("queuePath = '__snapshot/actions.json'"));
    expect(js, contains("CACHE = 'dottoday-day-snapshot'"));
  });

  // B6 surface rule (CLAUDE.md §11): widgets, controls and tiles act only
  // through the five intents / the action receiver (docs/09 M9.5).
  test('widgets, controls and tiles use the B6 paths', () {
    String read(String p) => File(p).readAsStringSync();
    const kotlin = 'android/app/src/main/kotlin/app/dottoday/planner';
    expect(
      read('$kotlin/widgets/NextUpWidget.kt'),
      contains('DotActionReceiver.ACTION_MARK_DONE'),
    );
    expect(
      read('$kotlin/tiles/DotTiles.kt'),
      contains('DotActionKind.START_FOCUS'),
    );
    expect(
      read('ios/DottodayWidgets/Views.swift'),
      contains('MarkDoneIntent(occurrenceId:'),
    );
    final controls = read('ios/DottodayWidgets/DotControls.swift');
    expect(controls, contains('OpenQuickAddIntent()'));
    expect(controls, contains('StartFocusIntent()'));
    final phrases = read('ios/Runner/DotShortcuts.swift');
    for (final intent in [
      'AddTaskIntent',
      'WhatsNextIntent',
      'MarkDoneIntent',
      'AddFifteenIntent',
      'StartFocusIntent',
    ]) {
      expect(phrases, contains('$intent()'), reason: intent);
    }
  });

  test('the queue key matches the Dart stores', () {
    expect(
      File('lib/data/intents/action_queue_json.dart').readAsStringSync(),
      contains("actionQueueKey = 'action_queue'"),
    );
  });
}
