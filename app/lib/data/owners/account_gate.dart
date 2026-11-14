import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/db/owner_meta.dart';
import 'package:dottoday/data/mappers/entity_mappers.dart';
import 'package:dottoday/data/owners/account_meta.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/guest_settings_choice.dart';
import 'package:dottoday/data/sync/outbox.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/profile/settings_difference.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_gate.g.dart';

/// What the app shows in front of the planner after a change of owner
/// (CR-160): one screen at a time, in this order of precedence.
sealed class AccountGate {
  const AccountGate();
}

/// Nothing: the planner.
final class NoAccountGate extends AccountGate {
  const NoAccountGate();
}

/// Web only: a deleted account's copy whose removal didn't finish
/// (policy §4, "Removal from this browser didn't finish").
final class RemovalPendingGate extends AccountGate {
  const RemovalPendingGate(this.accountIds);

  final List<String> accountIds;
}

/// A3 "You're signed out".
final class SignedOutGate extends AccountGate {
  const SignedOutGate();
}

/// G1: [accountId] signed in while the guest has [eligible] tasks that
/// could be brought in; the sign-in step waits for the choice.
final class GuestWorkGate extends AccountGate {
  const GuestWorkGate({
    required this.accountId,
    required this.email,
    required this.eligible,
  });

  final String accountId;
  final String email;
  final int eligible;
}

/// G1b, once: the sign-in left [count] guest tasks that may not move.
final class GuestNoticeGate extends AccountGate {
  const GuestNoticeGate({required this.accountId, required this.count});

  final String accountId;
  final int count;
}

/// B1: the account's settings and the device's differ in [fields].
final class SettingsChoiceGate extends AccountGate {
  const SettingsChoiceGate({
    required this.account,
    required this.device,
    required this.fields,
  });

  final Profile account;
  final Profile device;
  final List<SettingsField> fields;
}

/// Whether this build runs in a browser: the copy says "this browser", and
/// an interrupted removal waits for "Finish removing" (policy §4). Tests
/// override it.
@Riverpod(keepAlive: true)
bool inBrowser(Ref ref) => kIsWeb;

/// The signed-in account's auth id, or null; tests override it.
@Riverpod(keepAlive: true)
Stream<String?> signedInAccountId(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return Stream.value(null);
  return accountIdChanges(client);
}

/// The gate in front of the planner, live.
@Riverpod(keepAlive: true)
Stream<AccountGate> accountGate(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final id = ref.watch(signedInAccountIdProvider).value;
  final account = ref.watch(accountProvider).value;
  final sync = ref.watch(syncStatusProvider).value;
  final browser = ref.watch(inBrowserProvider);
  return _live(
    db,
    () => readAccountGate(
      db,
      accountId: id,
      email: account is SignedIn ? account.email : '',
      browser: browser,
      settled: _settled(sync),
    ),
  );
}

/// Whether Settings › Account offers "Choose settings" (B1 deferred).
@Riverpod(keepAlive: true)
Stream<bool> settingsChoiceLater(Ref ref) {
  final id = ref.watch(signedInAccountIdProvider).value;
  if (id == null) return Stream.value(false);
  final db = ref.watch(appDatabaseProvider);
  return _live(db, () async {
    if (!await guestSettingsDeferred(db, id)) return false;
    return (await _settingsChoice(db, id)) != null;
  });
}

/// The shown owner's changes not yet synced (A1 vs A2, D1's summary).
@Riverpod(keepAlive: true)
Stream<int> ownerPending(Ref ref, String owner) =>
    Outbox(ref.watch(appDatabaseProvider)).watchCount(owner);

/// The gate for this device now. [settled]: the first sync after sign-in
/// finished, so the account's own settings are here (B1 waits for it).
Future<AccountGate> readAccountGate(
  AppDatabase db, {
  required String? accountId,
  required String email,
  required bool browser,
  required bool settled,
}) async {
  if (browser) {
    final pending = await pendingRemovals(db);
    if (pending.isNotEmpty) return RemovalPendingGate(pending);
  }
  if (await signedOutGateSet(db)) return const SignedOutGate();
  if (accountId == null) return const NoAccountGate();
  if (!await isShownAccount(db, accountId)) {
    final work = await guestWork(db);
    final chosen = await _has(db, guestChoiceKey(accountId));
    return work.eligible > 0 && !chosen
        ? GuestWorkGate(
            accountId: accountId,
            email: email,
            eligible: work.eligible,
          )
        : const NoAccountGate();
  }
  if (await guestNoticePending(db, accountId)) {
    return GuestNoticeGate(
      accountId: accountId,
      count: await leftGuestTaskCount(db),
    );
  }
  if (!settled || await guestSettingsDeferred(db, accountId)) {
    return const NoAccountGate();
  }
  return await _settingsChoice(db, accountId) ?? const NoAccountGate();
}

/// B1 for [accountId] if a kept guest snapshot differs in a shown field.
Future<SettingsChoiceGate?> _settingsChoice(
  AppDatabase db,
  String accountId,
) async {
  final device = await pendingGuestSettings(db, accountId);
  if (device == null) return null;
  final row = await (db.select(
    db.profiles,
  )..where((p) => p.id.equals(accountId))).getSingleOrNull();
  if (row == null) return null;
  final account = profileFromRow(row);
  final fields = settingsDifferences(account, device);
  if (fields.isEmpty) return null;
  return SettingsChoiceGate(account: account, device: device, fields: fields);
}

/// A completed run confirmed by the server: synced, with its time.
bool _settled(SyncStatus? s) =>
    s != null && s.state == SyncState.synced && s.lastSyncedUtc != null;

Future<bool> _has(AppDatabase db, String key) async =>
    await (db.select(
      db.localMeta,
    )..where((m) => m.key.equals(key))).getSingleOrNull() !=
    null;

/// [read] now and again after every write to the tables it reads.
Stream<T> _live<T>(AppDatabase db, Future<T> Function() read) async* {
  yield await read();
  final tables = TableUpdateQuery.onAllTables([
    db.localMeta,
    db.profiles,
    db.seriesTable,
    db.occurrences,
    db.routinesTable,
  ]);
  await for (final _ in db.tableUpdates(tables)) {
    yield await read();
  }
}
