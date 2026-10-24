import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/feedback/diagnostics_reader.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/feedback/feedback_diagnostics.dart';
import 'package:dottoday/domain/feedback/feedback_mail.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_providers.g.dart';

@riverpod
DiagnosticsReader diagnosticsReader(Ref ref) =>
    DriftDiagnosticsReader(ref.watch(appDatabaseProvider));

/// The platform as feedback names it: `web`, else the target.
String get currentFeedbackPlatform =>
    feedbackPlatform(web: kIsWeb, target: defaultTargetPlatform.name);

/// The opt-in feedback diagnostics, read fresh each time the sheet opens
/// (PRD F11, R-19): versions, platform, sync state and counts only.
@riverpod
Future<FeedbackDiagnostics> feedbackDiagnostics(Ref ref) async {
  final version = await ref.watch(appVersionProvider.future);
  final ({DiagnosticCounts counts, String? deviceId}) db;
  try {
    db = await ref.read(diagnosticsReaderProvider).read();
  } on Exception catch (e, st) {
    // The sheet says so and the email goes without them.
    ref
        .read(loggerProvider)
        .error('feedback.diagnostics_failed', error: e, stackTrace: st);
    rethrow;
  }
  final sync = ref.read(syncStatusProvider).value ?? SyncStatus.localOnly;
  final locale =
      ref.read(currentProfileProvider).value?.locale ??
      PlatformDispatcher.instance.locale.languageCode;
  return FeedbackDiagnostics(
    appVersion: version,
    platform: currentFeedbackPlatform,
    locale: locale,
    schemaVersion: AppDatabase.latestSchemaVersion,
    deviceId: db.deviceId,
    sync: sync.state,
    pendingChanges: sync.pending,
    conflicts: sync.conflicts.length,
    lastSyncedUtc: sync.lastSyncedUtc,
    counts: db.counts,
    generatedUtc: ref.read(clockProvider).nowUtc(),
  );
}
