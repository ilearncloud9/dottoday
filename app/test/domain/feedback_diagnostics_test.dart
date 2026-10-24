import 'dart:convert';

import 'package:dottoday/domain/feedback/feedback_diagnostics.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FeedbackDiagnostics diagnostics({String? device, DateTime? synced}) =>
      FeedbackDiagnostics(
        appVersion: '0.1.0 (1)',
        platform: 'android',
        locale: 'en',
        schemaVersion: 4,
        deviceId: device,
        sync: SyncState.synced,
        pendingChanges: 2,
        lastSyncedUtc: synced,
        counts: const DiagnosticCounts(tasks: 5, inbox: 1),
        generatedUtc: DateTime.utc(2026, 10, 24, 9),
      );

  test('diagnostics.json: versions, platform, sync and counts only', () {
    final json =
        jsonDecode(
              diagnostics(
                device: 'ab12',
                synced: DateTime.utc(2026, 10, 24, 8),
              ).toText(),
            )
            as Map<String, Object?>;
    expect(json.keys, [
      'app',
      'platform',
      'locale',
      'schema',
      'device',
      'sync',
      'counts',
      'generated',
    ]);
    expect(json['sync'], {
      'state': 'synced',
      'pending': 2,
      'conflicts': 0,
      'lastSynced': '2026-10-24T08:00:00.000Z',
    });
    expect((json['counts']! as Map)['tasks'], 5);
  });

  test('unknown values are left out, not written as null', () {
    final text = diagnostics().toText();
    expect(text, isNot(contains('device')));
    expect(text, isNot(contains('lastSynced')));
    expect(text, isNot(contains('null')));
  });
}
