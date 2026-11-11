/// The staged import pipeline (CR-160 Stage B3,
/// docs/cr-160-multipart-export.md §5, ADR-0019 D4): one path for a JSON v1
/// file, a multipart set and a stored backup. Begin (owner session) →
/// stage a part at a time → check the whole set → the safety backup → one
/// commit transaction. Nothing live changes before the commit, and a
/// refusal anywhere discards the staging.
///
/// Every Settings import, backup restore and Undo runs here (B5, through
/// `DriftBackupService`); the caller's safety backup is its verified one,
/// single file or parts. Main isolate only (cross_runtime_fence_test.dart).
library;

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/backup_privacy.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/backup/staged_import_checks.dart';
import 'package:dottoday/data/backup/staged_import_commit.dart';
import 'package:dottoday/data/backup/staged_import_sources.dart';
import 'package:dottoday/data/backup/staged_import_store.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/writes/after_write_effects.dart';
import 'package:dottoday/data/writes/drift_write_use_case.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:flutter/foundation.dart';

/// Takes the pre-import (or pre-restore) backup, restorable or refused.
typedef SafetyBackup = Future<Result<void, AppFailure>> Function();

final class StagedImporter {
  StagedImporter({
    required AppDatabase db,
    required DriftWriteUseCase writes,
    required AfterWriteEffects effects,
    required Clock clock,
    required IdGenerator ids,
    required Logger logger,
    required String runId,
    @visibleForTesting this.afterChunk,
  }) : _db = db,
       _writes = writes,
       _effects = effects,
       _clock = clock,
       _ids = ids,
       _logger = logger,
       _runId = runId;

  final AppDatabase _db;
  final DriftWriteUseCase _writes;
  final AfterWriteEffects _effects;
  final Clock _clock;
  final IdGenerator _ids;
  final Logger _logger;
  final String _runId;

  /// Runs inside the commit after each chunk (crash and fault tests).
  final Future<void> Function()? afterChunk;

  /// A JSON v1 file's [text], for [userId], the owner shown.
  Future<Result<void, AppFailure>> importText(
    String userId,
    String text, {
    required SafetyBackup safety,
  }) => _run(
    userId,
    declared: text.length * 3, // UTF-8 bound; staging re-measures
    stage: (i) async {
      await stageLegacyText(_db, i, text);
      return null;
    },
    safety: safety,
  );

  /// A multipart set: [manifest], then each of [parts] read when needed.
  Future<Result<void, AppFailure>> importMultipart(
    String userId,
    String manifest, {
    required List<Future<String> Function()> parts,
    required SafetyBackup safety,
  }) {
    final m = ExportManifest.decode(manifest);
    final declared = m?.parts.fold(0, (n, p) => n + p.bytes);
    if (declared == null) return Future.value(Err(badImportFile.failure));
    return _run(
      userId,
      declared: declared,
      stage: (i) => stageMultipart(_db, i, manifest, parts),
      safety: safety,
    );
  }

  /// Stored backup [backupId] of [userId], the owner shown. Under
  /// `guestBackupFence` from the visibility check to the commit, so no
  /// privacy scrub can rewrite it in between; [safety] runs inside the
  /// fence too and must not take it again.
  Future<Result<void, AppFailure>> restoreBackup(
    String userId,
    BackupDatabase backups,
    int backupId, {
    required SafetyBackup safety,
  }) => guestBackupFence.run(() async {
    await prepareFencedBackupWork(_db, backups, nowUtc: _clock.nowUtc());
    if ((await guestBackupVisibility(_db, userId)).hides(backupId)) {
      return const Err(StorageFailure());
    }
    final bytes = await storedBackupBytes(backups, backupId, userId);
    if (bytes == null) return const Err(StorageFailure());
    return _run(
      userId,
      declared: bytes,
      stage: (i) => stageStoredBackup(_db, backups, i, backupId),
      safety: safety,
    );
  });

  Future<Result<void, AppFailure>> _run(
    String userId, {
    required int declared,
    required Future<TableCounts?> Function(StagedImport) stage,
    required SafetyBackup safety,
  }) async {
    final StagedImport import;
    try {
      import = await beginStagedImport(
        _db,
        userId,
        importId: _ids.newId(),
        declaredBytes: declared.clamp(0, maxStagedImportBytes),
        runId: _runId,
        nowUtc: _clock.nowUtc(),
      );
    } on StagingRefusedException catch (e) {
      return Err(_failureOf(e.reason));
    }
    try {
      final totals = await stage(import);
      await verifyStagedRows(_db, import, totals: totals);
      if (await safety() case Err(:final failure)) return Err(failure);
      await commitStagedImport(
        _db,
        _writes,
        import,
        nowUtc: _clock.nowUtc(),
        ids: _ids,
        afterChunk: afterChunk,
      );
      // Once, after the commit, never inside its transaction.
      _effects.schedule(userId);
      return const Ok(null);
    } on SourceRefused catch (e) {
      _logger.warn('import.refused');
      return Err(e.failure);
    } on StagingRefusedException catch (e) {
      _logger.warn('import.staging_refused', fields: {'reason': e.reason});
      return Err(_failureOf(e.reason));
    } on CommitFailed catch (e) {
      _logger.warn('import.commit_refused');
      return Err(e.failure);
    } on Exception catch (e, st) {
      _logger.error('import.failed', error: e, stackTrace: st);
      return const Err(StorageFailure());
    } finally {
      await discardStagedImport(_db, import);
    }
  }

  static AppFailure _failureOf(StagingRefusal reason) => switch (reason) {
    StagingRefusal.tooLarge => const ValidationFailure(
      ValidationField.importFile,
      ValidationRule.tooLarge,
    ),
    StagingRefusal.badRow => badImportFile.failure,
    StagingRefusal.ownerChanged ||
    StagingRefusal.busy ||
    StagingRefusal.unknownImport => const StorageFailure(),
  };
}
