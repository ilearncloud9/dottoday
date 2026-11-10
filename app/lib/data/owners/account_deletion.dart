import 'dart:async';
import 'dart:ui' show Rect;

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/db/owned_local_meta.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/intents/action_queue_drainer.dart';
import 'package:dottoday/data/intents/intent_providers.dart';
import 'package:dottoday/data/intents/queue_owners.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/data/owners/account_meta.dart';
import 'package:dottoday/data/owners/deletion_seal.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/data/sync/pull_guard.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter/foundation.dart' show setEquals;
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// What D1 last reviewed for an owner (summary or export): its queued
/// action ids, its local write revision, and what the server check found.
typedef _Review = ({Set<String> queued, int revision, DeletionCheck check});

/// D1's review, export and deletion (CR-160 policy §4, I7, W0–W2), for
/// `DeviceAccountActions`.
///
/// The review verifies the server state first ([SyncService.verifyForDeletion]:
/// everything at server revision R is on this device), then records the
/// local write revision and queued actions, then the summary or export
/// reads the rows. The deletion seals, re-checks both, and asks the server
/// to delete at R only: any change on either side since stops it.
final class AccountDeletion {
  AccountDeletion(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(appDatabaseProvider);
  ActionQueueDrainer get _drainer => _ref.read(actionQueueDrainerProvider);

  final _reviewed = <String, _Review>{};

  /// Owners whose deletion outcome is unknown: their seal and the queue
  /// refusal stay until a retry settles it or D1 closes, so nothing local
  /// moves while a retry may still finish it. Closing D1 never touches the
  /// server's freeze.
  final _sealKept = <String>{};

  /// Applies what is queued for [owner], holds what comes after, verifies
  /// the server state; returns what is left queued (could not be applied).
  Future<Set<String>> _review(String owner) async {
    _drainer.hold(owner);
    await _drainer.drain(force: owner);
    final check = await _ref.read(syncServiceProvider).verifyForDeletion(owner);
    // Read after the check and before the summary or the export reads the
    // rows: a save or a pull after this moves it, so D1 can only
    // over-report a change.
    final revision = await writeRevision(_db, owner);
    final left = await queuedIdsFor(_ref.read(actionQueueStoreProvider), owner);
    _reviewed[owner] = (queued: left, revision: revision, check: check);
    return left;
  }

  /// See `AccountActions.exportFirst`.
  Future<OwnerExportOutcome> exportFirst(String owner, {Rect? origin}) async {
    if ((await _review(owner)).isNotEmpty) {
      // Queued work the file can't hold: never "exported" without it.
      _ref.read(loggerProvider).error('account.export_queue_unapplied');
      return OwnerExportOutcome.failed;
    }
    if (_reviewed[owner]?.check is! DeletionVerified) {
      // This device's copy may lack what the server has: never presented
      // as the account's complete export.
      _ref.read(loggerProvider).info('account.export_unverified');
      return OwnerExportOutcome.failed;
    }
    return exportOwnerChecked(
      db: _db,
      exports: _ref.read(exportServiceProvider),
      files: _ref.read(fileGatewayProvider),
      logger: _ref.read(loggerProvider),
      owner: owner,
      origin: origin,
    );
  }

  /// See `AccountActions.summary`.
  Future<OwnerSummary> summary(String owner) async {
    await _review(owner);
    return ownerSummary(_db, owner);
  }

  /// See `AccountActions.deleteAccount`.
  Future<Result<void, AppFailure>> deleteAccount() async {
    final owner = await shownOwnerId(_db);
    final reviewed = owner == null ? null : _reviewed[owner];
    if (owner == null || reviewed == null) {
      return const Err(ReviewChangedFailure());
    }
    // Not verified: the deletion function is never asked.
    final check = reviewed.check;
    if (check is DeletionUnverified) return Err(check.failure);
    final token = check as DeletionVerified;
    // Verified in another owner session (A → B → A): never reused.
    if (await ownerGeneration(_db) != token.generation) {
      await _review(owner);
      return const Err(ReviewChangedFailure());
    }
    final owners = _ref.read(ownerSwitchProvider);
    // From here no surface can queue for the account: work that would
    // vanish with it, or land with the next owner, is refused instead.
    // Already refused when an earlier attempt's outcome is unknown.
    if (!_sealKept.contains(owner)) await owners.refuseQueue();
    var unknown = false;
    var reReview = false;
    try {
      // And no save or pull can land for it: each is either counted in
      // this revision or refused (deletion_seal.dart, pull_guard.dart).
      final int revision;
      try {
        revision = await sealForDeletion(_db, owner);
      } on Exception catch (e, s) {
        _ref
            .read(loggerProvider)
            .error('account.seal_failed', error: e, stackTrace: s);
        return const Err(StorageFailure());
      }
      final now = await queuedIdsFor(
        _ref.read(actionQueueStoreProvider),
        owner,
      );
      if (!setEquals(now, reviewed.queued) || revision != reviewed.revision) {
        // Reviewed again (the person was told); the server is not asked.
        reReview = true;
        return const Err(ReviewChangedFailure());
      }
      final result = await _ref
          .read(accountServiceProvider)
          .deleteAccount(expectedRevision: token.serverRevision);
      switch (result) {
        case Err(failure: ReviewChangedFailure()):
          reReview = true; // the server changed since the review
        case Err(failure: NetworkFailure(kind: NetworkFailureKind.timeout)):
          unknown = true; // maybe deleted, maybe frozen: nothing undone
        case _:
      }
      return result;
    } finally {
      if (unknown) {
        _sealKept.add(owner);
      } else {
        // Settled (or stopped before the server was asked): a seal that
        // never committed is a no-op to remove; the refusal ends once.
        _sealKept.remove(owner);
        await _unseal(owner);
        await owners.releaseQueue();
      }
      if (reReview) await _review(owner);
    }
  }

  /// Saves for [owner] go through again: after a refused, failed or
  /// finished deletion. If this fails, the app's next launch clears it.
  Future<void> _unseal(String owner) async {
    try {
      await unsealDeletion(_db, owner);
    } on Exception catch (e, s) {
      _ref
          .read(loggerProvider)
          .error('account.unseal_failed', error: e, stackTrace: s);
    }
  }

  /// See `AccountActions.endDeletion`.
  void endDeletion(String owner) {
    _reviewed.remove(owner);
    if (_sealKept.remove(owner)) {
      // Local only: the server's freeze (if the request got that far)
      // stays until a deletion finishes or is proven refused.
      unawaited(_unseal(owner));
      unawaited(_ref.read(ownerSwitchProvider).releaseQueue());
    }
    _drainer.release(owner);
    unawaited(_drainer.drain().catchError((Object _) => 0));
  }
}
