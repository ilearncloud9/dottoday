import 'dart:convert';

import 'package:dottoday/domain/sync/sync_status.dart';

/// How much is on this device, as counts only (docs/04 §9).
final class DiagnosticCounts {
  const DiagnosticCounts({
    this.tasks = 0,
    this.inbox = 0,
    this.done = 0,
    this.repeats = 0,
    this.trash = 0,
    this.calendarEvents = 0,
  });

  /// Tasks the person made (not in Trash), scheduled or in the Inbox.
  final int tasks;
  final int inbox;
  final int done;

  /// Repeating series (not in Trash).
  final int repeats;
  final int trash;

  /// Events imported from a calendar.
  final int calendarEvents;

  /// The counts as `diagnostics.json` names them.
  Map<String, int> toJson() => {
    'tasks': tasks,
    'inbox': inbox,
    'done': done,
    'repeats': repeats,
    'trash': trash,
    'calendarEvents': calendarEvents,
  };
}

/// The opt-in diagnostics a feedback email may carry (PRD F11, R-19,
/// docs/04 §9 `diagnostics.json`): IDs, versions, platform and counts —
/// never a title, a note, an email address or an account id (CLAUDE.md §4).
/// Every field is a number, an enum name, a version or a random id, so
/// nothing typed by the person can get in.
///
/// ```dart
/// FeedbackDiagnostics(appVersion: '0.1.0 (1)', platform: 'iOS', …).toText();
/// ```
final class FeedbackDiagnostics {
  const FeedbackDiagnostics({
    required this.appVersion,
    required this.platform,
    required this.locale,
    required this.schemaVersion,
    required this.sync,
    required this.counts,
    required this.generatedUtc,
    this.deviceId,
    this.pendingChanges = 0,
    this.conflicts = 0,
    this.lastSyncedUtc,
  });

  /// "0.1.0 (1)".
  final String appVersion;

  /// `iOS`, `android`, `macOS` or `web`.
  final String platform;

  /// The app's language code, e.g. `en`.
  final String locale;

  /// The local database's schema version.
  final int schemaVersion;

  /// This install's random sync node id (8 bytes hex, ADR-0002), so a
  /// report can be matched with sync logs; null before the first write.
  final String? deviceId;
  final SyncState sync;
  final int pendingChanges;
  final int conflicts;
  final DateTime? lastSyncedUtc;
  final DiagnosticCounts counts;
  final DateTime generatedUtc;

  /// The block as `diagnostics.json` (docs/04 §9).
  Map<String, Object?> toJson() => {
    'app': appVersion,
    'platform': platform,
    'locale': locale,
    'schema': schemaVersion,
    'device': ?deviceId,
    'sync': {
      'state': sync.name,
      'pending': pendingChanges,
      'conflicts': conflicts,
      'lastSynced': ?lastSyncedUtc?.toUtc().toIso8601String(),
    },
    'counts': counts.toJson(),
    'generated': generatedUtc.toUtc().toIso8601String(),
  };

  /// Pretty JSON, as shown in the sheet and pasted into the email body.
  String toText() => const JsonEncoder.withIndent('  ').convert(toJson());
}
