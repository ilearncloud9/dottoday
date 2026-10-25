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

  test('the queue key matches the Dart stores', () {
    expect(
      File('lib/data/intents/action_queue_json.dart').readAsStringSync(),
      contains("actionQueueKey = 'action_queue'"),
    );
  });
}
