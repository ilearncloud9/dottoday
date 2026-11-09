import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/notifications/in_app_alerts.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/owners/account_actions.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:dottoday/data/sync/outbox.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/notifications/notification_payload.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// CR-160 criteria 10/11 on a real device or browser against the LOCAL
// Supabase stack only (docs/cr-160-verification.md). The app talks to the
// stack through a test-only pass-through on the host (CR160_SWITCH_URL
// turns it off and on: a real network failure for the app's client);
// checks a user can't make use the local service-role key, test-only.

// `localhost`, not 127.0.0.1: on the web GoTrue shares sessions between
// clients whose URL host matches (one BroadcastChannel per host), and the
// admin client must never pick up the app's session.
const _adminUrl = String.fromEnvironment(
  'CR160_ADMIN_URL',
  defaultValue: 'http://localhost:54321',
);
const _serviceKey = String.fromEnvironment('CR160_SERVICE_KEY');
const _switchUrl = String.fromEnvironment(
  'CR160_SWITCH_URL',
  defaultValue: 'http://127.0.0.1:54332',
);

/// A local test account.
typedef LabAccount = ({String id, String email});

/// Prints one result line the run log keeps (ids and counts only).
void report(String line) => debugPrint('CR160 $line');

/// Drives the real app's providers for the CR-160 device runs.
final class Cr160Lab {
  Cr160Lab(this.c) {
    if (_serviceKey.isEmpty) {
      throw StateError('CR160_SERVICE_KEY (local stack only) is not defined');
    }
  }

  final ProviderContainer c;
  final admin = SupabaseClient(
    _adminUrl,
    _serviceKey,
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );
  final _switch = SupabaseClient(_switchUrl, 'cr160-switch');

  AppDatabase get db => c.read(appDatabaseProvider);
  SupabaseClient get app => c.read(supabaseClientProvider)!;
  AccountActions get actions => c.read(accountActionsProvider);

  /// Cuts or restores the app's network to the stack.
  Future<void> network({required bool online}) async {
    final rows = await _switch.from(online ? 'on' : 'off').select();
    final state = rows.first['state'];
    if (state != (online ? 'online' : 'offline')) {
      throw StateError('network switch says $state');
    }
    report('network ${online ? 'online' : 'offline'}');
  }

  /// A new confirmed account on the local stack.
  Future<LabAccount> newAccount(String tag) async {
    final email =
        'cr160-$tag-${DateTime.now().microsecondsSinceEpoch}@example.com';
    final r = await admin.auth.admin.createUser(
      AdminUserAttributes(email: email, emailConfirm: true),
    );
    return (id: r.user!.id, email: email);
  }

  /// Signs [a] in on the app's own client (a magic-link token, verified
  /// as the link would), with [choice] recorded first as G1 would, then
  /// waits until the app shows [a] and its first sync ran.
  Future<void> signIn(LabAccount a, {GuestChoice? choice}) async {
    if (choice != null) await recordGuestChoice(db, a.id, choice);
    await verifyOnly(a);
    await until('shown ${a.id}', () async {
      if (await activeOwnerId(db) != a.id) return false;
      return (await c.read(localProfileProvider.future)).id == a.id;
    });
    await actions.signedIn();
    await c.read(afterWriteEffectsProvider).idle;
    await until('first sync of ${a.id}', () async => syncOk());
    report('signed in ${a.id}');
  }

  /// The sign-in link's token verified on the app's client; the app's own
  /// sign-in step then runs on the auth change, not awaited here.
  Future<void> verifyOnly(LabAccount a) async {
    final link = await admin.auth.admin.generateLink(
      type: GenerateLinkType.magiclink,
      email: a.email,
    );
    await app.auth.verifyOTP(
      type: OtpType.magiclink,
      tokenHash: link.properties.hashedToken,
    );
  }

  /// A1/A2 "Sign out" as the Account page does it.
  Future<bool> signOut() async {
    final r = await actions.signOut();
    await c.read(afterWriteEffectsProvider).idle;
    report(
      'signed out: auth ${r is Ok ? 'ok' : 'err (local session cleared)'}',
    );
    return r is Ok;
  }

  /// Whether the sync status shows offline or error (a failed run), read
  /// without starting a run.
  Future<bool> syncShowsOffline() async {
    final s = await c.read(syncServiceProvider).watch().first;
    return s.state == SyncState.offline || s.state == SyncState.error;
  }

  /// One "Sync now"; true when it reached the server. A run already under
  /// way makes it return at once with the status as it stands.
  Future<bool> syncOk() async {
    final r = await c.read(syncServiceProvider).syncNow();
    final s = await c.read(syncServiceProvider).watch().first;
    report('sync ${r is Ok ? 'ok' : 'err'} state=${s.state.name}');
    return r is Ok;
  }

  /// A task for [owner] starting in [startIn], with one at-start alert.
  Future<Occurrence> addTask(
    String owner,
    String title, {
    Duration startIn = const Duration(hours: 2),
  }) async {
    final profile = await c.read(localProfileProvider.future);
    final now = DateTime.now().toUtc();
    final o = Occurrence(
      id: const UuidV7Generator().newId(),
      userId: owner,
      title: title,
      tzId: profile.tzId,
      startUtc: now.add(startIn),
      durationMin: 15,
      alerts: const [Alert(kind: AlertKind.atStart)],
      createdAt: now,
      updatedAt: now,
    );
    await c
        .read(writeUseCaseProvider)
        .apply(WriteBatch(userId: owner, occurrences: [o]));
    await c.read(afterWriteEffectsProvider).idle;
    return o;
  }

  /// [owner]'s task ids on this device.
  Future<Set<String>> localIds(String owner) async => {
    for (final r in await (db.select(
      db.occurrences,
    )..where((o) => o.userId.equals(owner))).get())
      r.id,
  };

  /// The task ids Today's day view is built from now (the shown owner).
  Future<Set<String>> todayIds() async {
    final date = await c.read(todayDateProvider.future);
    final sub = c.listen(timelineDataProvider(date).future, (_, _) {});
    try {
      final data = await sub.read();
      return {
        for (final o in [...data.blocks, ...data.allDay]) o.id,
      };
    } finally {
      sub.close();
    }
  }

  /// [owner]'s unsynced changes on this device.
  Future<int> outbox(String owner) => Outbox(db).watchCount(owner).first;

  /// Task ids as the server holds them for [uid] (admin key), one entry
  /// per row, so a duplicate shows twice.
  Future<List<String>> serverIds(String uid) async => [
    for (final r
        in await admin.from('occurrences').select('id').eq('user_id', uid))
      r['id'] as String,
  ];

  /// Task ids the signed-in account can read (RLS-scoped, its own session).
  Future<List<String>> rlsIds() async => [
    for (final r in await app.from('occurrences').select('id'))
      r['id'] as String,
  ];

  /// OS notification id → task id of every pending notification.
  Future<Map<int, String>> pendingNotifications() async {
    final platform = await c.read(notificationPlatformProvider.future);
    return {
      for (final (id, raw) in await platform.pending())
        if (decodeNotificationPayload(id, raw) case final p?)
          id: p.occurrenceId,
    };
  }

  /// Ids of delivered notifications still shown: the OS notification
  /// centre; on the web (no permission in a test browser) the in-app strip
  /// a fired reminder lands in.
  Future<Set<int>> deliveredNotifications() async {
    if (kIsWeb) return {for (final n in c.read(inAppAlertsProvider)) n.id};
    final shown = await c
        .read(localNotificationsPluginProvider)
        .getActiveNotifications();
    return {for (final n in shown) ?n.id};
  }

  /// [owner]'s backups on this device.
  Future<int> backups(String owner) async {
    final b = c.read(backupDatabaseProvider);
    return (await (b.select(
      b.backups,
    )..where((r) => r.owner.equals(owner))).get()).length;
  }

  /// Rows any table of this device's database still holds for [owner].
  Future<Map<String, int>> leftovers(String owner) async {
    Future<int> count(String sql) async =>
        (await db.customSelect(sql, variables: [Variable(owner)]).get()).length;
    return {
      'occurrences': await count('SELECT 1 FROM occurrences WHERE user_id = ?'),
      'profiles': await count('SELECT 1 FROM profiles WHERE id = ?'),
      'change_log': await count('SELECT 1 FROM change_log WHERE owner_id = ?'),
      'local_meta': await count(
        "SELECT 1 FROM local_meta WHERE key LIKE '%' || ?",
      ),
      'backups': await backups(owner),
    };
  }

  /// Polls [probe] until true, at most [timeout].
  Future<void> until(
    String what,
    Future<bool> Function() probe, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      if (await probe()) return;
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    throw StateError('timed out waiting for: $what');
  }
}
