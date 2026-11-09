import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/intents/intent_providers.dart';
import 'package:dottoday/data/notifications/permission_providers.dart';
import 'package:dottoday/data/notifications/wake_up_arming.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/snapshot/snapshot_providers.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/wake_up/wake_up_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'owner_switch.g.dart';

/// Moves on at every change of the owner the app shows (CR-160 I1, I5):
/// sign-in as another owner, sign-out, account removal. Every provider that
/// holds one owner's state (open editors, focus, proposals, undo, caches)
/// watches it, so nothing of the previous owner survives a switch, however
/// late a callback or a rebuild comes.
@Riverpod(keepAlive: true)
class OwnerEpoch extends _$OwnerEpoch {
  @override
  int build() => 0;

  /// A new owner is shown.
  void next() => state++;
}

/// The one place a change of owner happens on this device (CR-160 policy
/// §2, I1–I8). Every step runs in order; the visible app is invalidated
/// before anything else can read the old owner again.
@Riverpod(keepAlive: true)
OwnerSwitch ownerSwitch(Ref ref) => OwnerSwitch(ref);

/// See [ownerSwitchProvider].
final class OwnerSwitch {
  OwnerSwitch(this._ref);

  final Ref _ref;

  /// Signing out: the account stops showing at once (policy §2). Its rows
  /// and pending changes stay its own. Call it before the auth sign-out:
  /// clearing this browser's server reminders needs the session (I3).
  Future<void> signOut() async {
    await _before();
    await signOutOwner(_ref.read(appDatabaseProvider));
    await _after();
  }

  /// After the sign-in step made another owner the one shown.
  Future<void> signedIn() async {
    await _before();
    await _after();
  }

  /// After the server confirmed the deletion of [accountId] (policy §4):
  /// hidden at once, then removed; an interruption leaves it pending and
  /// hidden.
  Future<void> accountDeleted(String accountId) async {
    final db = _ref.read(appDatabaseProvider);
    await _before();
    await beginAccountRemoval(db, accountId);
    await _after();
    await finishRemoval(accountId);
  }

  /// Removes a deleted account's copy from this device, backups included
  /// (I2), or finishes a removal an interruption left pending. Idempotent;
  /// a failure leaves the copy pending and hidden, never anyone else's.
  Future<void> finishRemoval(String accountId) => finishAccountRemoval(
    _ref.read(appDatabaseProvider),
    accountId,
    alsoRemove: () =>
        _ref.read(backupDatabaseProvider).deleteBackupsOf(accountId),
  );

  /// Work that belongs to the owner still shown, done before it changes.
  /// Each step is guarded: none of them may keep the person from leaving.
  Future<void> _before() async {
    // Widget, Siri and share actions carry no owner: applied now, they
    // land with the owner they were made for (I7). `localProfileProvider`
    // still holds that owner until [_after].
    if (!await _done(() async {
      await _ref.read(actionQueueDrainerProvider).drain();
    })) {
      _ref.read(loggerProvider).warn('owner_switch.drain_failed');
    }
    // What the Wake Up alarms did (rang, snoozed, "I'm up") was the old
    // owner's morning: folded in now, never counted for the next owner.
    // A mission it would open is dropped: that owner is leaving.
    if (!await _done(() async {
      await _ref.read(alarmEventsDrainProvider.notifier).run();
    })) {
      _ref.read(loggerProvider).warn('owner_switch.alarm_events_failed');
    }
    final effects = _ref.read(afterWriteEffectsProvider);
    // The old owner's queued resyncs finish first, so none of them puts a
    // reminder back after the clear below.
    await effects.idle;
    // Pending and delivered notifications, the web tab's timers and, on
    // the web, this browser's server copies while the session still
    // allows deleting them (I3, I6).
    if (!await _done(() async {
      await _ref.read(notificationGatewayProvider).clearAll();
    })) {
      _ref.read(loggerProvider).warn('owner_switch.notifications_failed');
    }
    // Armed at the old owner's Wind Down; the provider builds a new one.
    _ref.read(windDownSnapshotProvider).cancel();
  }

  /// The new owner everywhere: screens, reminders, widgets, alarms.
  Future<void> _after() async {
    _ref.read(ownerEpochProvider.notifier).next();
    _ref.invalidate(localProfileProvider);
    final effects = _ref.read(afterWriteEffectsProvider);
    // Surfaces show an empty day first: if no owner can be shown, they
    // never keep the previous one's (I8).
    if (!await _done(() async {
      await _ref.read(daySnapshotWriterProvider).writeEmpty();
    })) {
      _ref.read(loggerProvider).warn('owner_switch.snapshot_failed');
    }
    if (!await _done(() async {
      await WakeUpArming(
        _ref.read(alarmGatewayProvider),
        _ref.read(appDatabaseProvider),
      ).disarmAll();
    })) {
      _ref.read(loggerProvider).warn('owner_switch.alarms_failed');
    }
    final String id;
    try {
      id = (await _ref.read(localProfileProvider.future)).id;
    } on Object {
      // Shown by the profile's own error state; the surfaces stay empty.
      _ref.read(loggerProvider).error('owner_switch.profile_failed');
      return;
    }
    // Reminders, Wake Up alarms and the snapshot for the new owner now,
    // not at its next write (I6, I8).
    effects.schedule(id);
    await effects.idle;
    if (!await _done(() async {
      await _ref.read(windDownSnapshotProvider).arm(id);
    })) {
      _ref.read(loggerProvider).warn('owner_switch.wind_down_failed');
    }
  }

  /// Runs [step]; false when it threw. The caller logs its event only:
  /// errors here may quote task text (CLAUDE.md §4).
  Future<bool> _done(Future<void> Function() step) async {
    try {
      await step();
      return true;
    } on Object {
      return false;
    }
  }
}
