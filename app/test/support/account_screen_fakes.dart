import 'dart:ui' show Rect;

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/owners/account_meta.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter_riverpod/misc.dart';

/// The CR-160 account screens' actions, recorded; answers set per test.
base class FakeAccountActions implements AccountActions {
  final calls = <String>[];
  OwnerExportOutcome exportOutcome = OwnerExportOutcome.done;
  Result<void, AppFailure> deleteResult = const Ok(null);
  Result<void, AppFailure> removalResult = const Ok(null);
  Result<void, AppFailure> settingsResult = const Ok(null);
  OwnerSummary summaryValue = (tasks: 42, pending: 3);

  @override
  Future<Result<void, AppFailure>> signOut({bool everywhere = false}) async {
    calls.add(everywhere ? 'signOutEverywhere' : 'signOut');
    return const Ok(null);
  }

  @override
  Future<void> syncNow() async => calls.add('syncNow');

  @override
  Future<void> useWithoutAccount() async => calls.add('useWithoutAccount');

  @override
  Future<void> signedIn() async => calls.add('signedIn');

  @override
  Future<void> finishInterruptedSignOut() async =>
      calls.add('finishInterruptedSignOut');

  @override
  Future<void> chooseGuestWork(String accountId, GuestChoice choice) async =>
      calls.add('guest:${choice.name}');

  @override
  Future<void> dismissGuestNotice(String accountId) async =>
      calls.add('dismissNotice');

  @override
  Future<Result<void, AppFailure>> useDeviceSettings(Profile account) async {
    calls.add('useDevice');
    return settingsResult;
  }

  @override
  Future<void> keepAccountSettings(String accountId) async =>
      calls.add('keepAccount');

  @override
  Future<void> decideSettingsLater(
    String accountId, {
    required bool later,
  }) async => calls.add(later ? 'later' : 'chooseNow');

  @override
  Future<OwnerExportOutcome> exportFirst(String owner, {Rect? origin}) async {
    calls.add('export');
    return exportOutcome;
  }

  @override
  Future<OwnerSummary> summary(String owner) async => summaryValue;

  @override
  Future<Result<void, AppFailure>> deleteAccount() async {
    calls.add('delete');
    return deleteResult;
  }

  @override
  Future<Result<void, AppFailure>> finishRemovals() async {
    calls.add('finishRemovals');
    return removalResult;
  }
}

/// Overrides for a screen test: [actions], no database behind the gate
/// helpers, [pending] changes waiting for every owner.
List<Override> accountScreenOverrides(
  FakeAccountActions actions, {
  int pending = 0,
  bool browser = false,
}) => [
  accountActionsProvider.overrideWithValue(actions),
  ownerPendingProvider.overrideWith((ref, owner) => Stream.value(pending)),
  settingsChoiceLaterProvider.overrideWith((ref) => Stream.value(false)),
  inBrowserProvider.overrideWithValue(browser),
];
