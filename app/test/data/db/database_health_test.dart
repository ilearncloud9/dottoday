import 'dart:io';

import 'package:dottoday/data/db/connection/connection_native.dart';
import 'package:dottoday/data/db/database_health.dart';
import 'package:dottoday/data/db/database_unavailable.dart';
import 'package:flutter_test/flutter_test.dart';

// Database recovery (docs/09 M3f.9; 06 §4, M2.4).

void main() {
  group('unavailableReason', () {
    test('reads the exception, or its text from the background isolate', () {
      expect(
        unavailableReason(
          const DatabaseUnavailable(DatabaseUnavailableReason.keyRejected),
        ),
        DatabaseUnavailableReason.keyRejected,
      );
      expect(
        unavailableReason(
          Exception('Remote error: DatabaseUnavailable(keyMissing)'),
        ),
        DatabaseUnavailableReason.keyMissing,
      );
      expect(unavailableReason(const FormatException('x')), isNull);
    });
  });

  test(
    'Start fresh moves the file and its -wal aside, never deletes',
    () async {
      final dir = await Directory.systemTemp.createTemp('dottoday-db');
      addTearDown(() => dir.delete(recursive: true));
      final db = File('${dir.path}/dottoday.db')..writeAsStringSync('old');
      File('${db.path}-wal').writeAsStringSync('wal');
      final kept = await moveFileAside(
        db,
        now: DateTime.utc(2026, 10, 22, 9, 30),
      );
      expect(kept, '${db.path}.unreadable-2026-10-22T09-30-00.000Z');
      expect(db.existsSync(), isFalse);
      expect(File(kept!).readAsStringSync(), 'old');
      expect(File('$kept-wal').readAsStringSync(), 'wal');
      expect(await moveFileAside(db, now: DateTime.utc(2026)), isNull);
    },
  );
}
