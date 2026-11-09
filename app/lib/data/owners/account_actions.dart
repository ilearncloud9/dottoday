import 'dart:ui' show Rect;

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/data/owners/account_meta.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/guest_settings_choice.dart' as guest;
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_actions.g.dart';

/// What the CR-160 account screens do (A1–A3, G1, G1b, B1, D1, web
/// retry). A port so widget tests check the screens without a database.
@Riverpod(keepAlive: true)
AccountActions accountActions(Ref ref) => DeviceAccountActions(ref);

/// See [accountActionsProvider].
abstract interface class AccountActions {
  /// A1/A2 "Sign out": hides the account at once (policy §2), shows A3
  /// from now on, then signs out of the account ([everywhere]: every
  /// device, docs/06 §2).
  Future<Result<void, AppFailure>> signOut({bool everywhere = false});

  /// A2 "Stay signed in": tries to sync now.
  Future<void> syncNow();

  /// A3 "Use without an account": the device's guest plan.
  Future<void> useWithoutAccount();

  /// A3 after a sign-in finished: the gate goes.
  Future<void> signedIn();

  /// At launch with an account signed in: if A3 is recorded, a sign-out
  /// was interrupted after the account was hidden and before auth signed
  /// out; this finishes it, so A3 stays true.
  Future<void> finishInterruptedSignOut();

  /// G1 "Continue": records [choice], then runs the sign-in step again.
  Future<void> chooseGuestWork(String accountId, GuestChoice choice);

  /// G1b "Continue": never shown again.
  Future<void> dismissGuestNotice(String accountId);

  /// B1 "Continue" with "This device's settings".
  Future<Result<void, AppFailure>> useDeviceSettings(Profile account);

  /// B1 "Continue" with "Your account's settings".
  Future<void> keepAccountSettings(String accountId);

  /// B1 "Decide later" ([later]); Settings › Account asks again (false).
  Future<void> decideSettingsLater(String accountId, {required bool later});

  /// D1 "Export my data first" for [owner], checked (see
  /// [exportOwnerChecked]).
  Future<OwnerExportOutcome> exportFirst(String owner, {Rect? origin});

  /// D1's summary: [owner]'s tasks and unsynced changes.
  Future<OwnerSummary> summary(String owner);

  /// D1 "Delete account": the server deletion, then the device copy.
  Future<Result<void, AppFailure>> deleteAccount();

  /// Web retry "Finish removing": every pending removal, or the failure.
  Future<Result<void, AppFailure>> finishRemovals();
}

/// [AccountActions] on this device's database and services.
final class DeviceAccountActions implements AccountActions {
  DeviceAccountActions(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(appDatabaseProvider);

  @override
  Future<Result<void, AppFailure>> signOut({bool everywhere = false}) async {
    // Hidden first, and A3 recorded, before anything can fail or wait: an
    // interruption from here on still never shows the account (policy §2).
    await _ref.read(ownerSwitchProvider).signOut();
    await setSignedOutGate(_db);
    return _ref.read(accountServiceProvider).signOut(everywhere: everywhere);
  }

  @override
  Future<void> syncNow() async {
    await _ref.read(syncServiceProvider).syncNow();
  }

  @override
  Future<void> useWithoutAccount() async {
    // The guest the sign-out left shown; made now if there is none.
    await _ref.read(localProfileProvider.future);
    await clearSignedOutGate(_db);
  }

  @override
  Future<void> signedIn() => clearSignedOutGate(_db);

  @override
  Future<void> finishInterruptedSignOut() async {
    if (!await signedOutGateSet(_db)) return;
    await _ref.read(accountServiceProvider).signOut();
  }

  @override
  Future<void> chooseGuestWork(String accountId, GuestChoice choice) async {
    await recordGuestChoice(_db, accountId, choice);
    await _ref.read(syncServiceProvider).syncNow();
  }

  @override
  Future<void> dismissGuestNotice(String accountId) =>
      clearGuestNotice(_db, accountId);

  @override
  Future<Result<void, AppFailure>> useDeviceSettings(Profile account) async {
    final result = await guest.useGuestSettings(
      _db,
      _ref.read(writeUseCaseProvider),
      account,
    );
    if (result is Ok) await deferGuestSettings(_db, account.id, later: false);
    return result;
  }

  @override
  Future<void> keepAccountSettings(String accountId) async {
    await guest.keepAccountSettings(_db, accountId);
    await deferGuestSettings(_db, accountId, later: false);
  }

  @override
  Future<void> decideSettingsLater(String accountId, {required bool later}) =>
      deferGuestSettings(_db, accountId, later: later);

  @override
  Future<OwnerExportOutcome> exportFirst(String owner, {Rect? origin}) =>
      exportOwnerChecked(
        db: _db,
        exports: _ref.read(exportServiceProvider),
        files: _ref.read(fileGatewayProvider),
        logger: _ref.read(loggerProvider),
        owner: owner,
        origin: origin,
      );

  @override
  Future<OwnerSummary> summary(String owner) => ownerSummary(_db, owner);

  @override
  Future<Result<void, AppFailure>> deleteAccount() =>
      _ref.read(accountServiceProvider).deleteAccount();

  @override
  Future<Result<void, AppFailure>> finishRemovals() async {
    try {
      for (final id in await pendingRemovals(_db)) {
        await _ref.read(ownerSwitchProvider).finishRemoval(id);
      }
      return const Ok(null);
    } on Exception catch (e, s) {
      _ref
          .read(loggerProvider)
          .error('account.removal_failed', error: e, stackTrace: s);
      return const Err(StorageFailure());
    }
  }
}
