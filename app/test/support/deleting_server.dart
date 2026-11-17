import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/data/sync/pull_guard.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/sync/sync_status.dart';

import 'sync_fakes.dart';

/// The server's `delete-account` for [account], with hooks for what
/// happens while it runs ([during]) and right after the removal ([after]).
final class DeletingServer implements AccountService {
  DeletingServer(this.account);

  final String account;
  late OwnerSwitch owners;
  FutureOr<void> Function()? during;
  FutureOr<void> Function()? after;
  var fails = false;
  var deletes = 0;

  /// The server's revision (migration 0015): a deletion at another one is
  /// refused, nothing deleted (409 changed).
  var revision = 0;

  /// An answer to give instead of deleting (an unknown outcome, say).
  AppFailure? answer;

  /// The revisions deletions were asked at, in order.
  final askedAt = <int>[];

  /// D1's verification against this server for the app on [db]: all of
  /// [revision] is there, in the owner session shown now (the real check
  /// is deletion_verifier.dart, tested on its own).
  FakeSyncService verifier(AppDatabase db) =>
      FakeSyncService(SyncStatus.localOnly)
        ..verify = (owner) async => DeletionVerified(
          serverRevision: revision,
          generation: await ownerGeneration(db),
        );

  @override
  Future<Result<void, AppFailure>> deleteAccount({
    required int expectedRevision,
  }) async {
    deletes++;
    askedAt.add(expectedRevision);
    await during?.call();
    if (fails) return const Err(NetworkFailure(NetworkFailureKind.server));
    if (answer case final a?) return Err(a);
    if (expectedRevision != revision) return const Err(ReviewChangedFailure());
    await owners.accountDeleted(account);
    await after?.call();
    return const Ok(null);
  }

  @override
  bool get available => true;
  @override
  Stream<Account> watch() => const Stream.empty();
  @override
  Future<Result<void, AppFailure>> signIn(SignInMethod method) async =>
      const Ok(null);
  @override
  Future<Result<void, AppFailure>> sendMagicLink(String email) async =>
      const Ok(null);
  @override
  Stream<RestoreProgress?> watchRestore() => const Stream.empty();
  @override
  Future<Result<void, AppFailure>> signOut({bool everywhere = false}) async =>
      const Ok(null);
}
