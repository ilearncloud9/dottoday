import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'test_alarm.g.dart';

/// When the requested test alarm fires, kept in `local_meta` so the one
/// reconcile path (`NotificationSync`) plans it like any reminder (docs/09
/// M6.5.9, local-notifications-scheduler: never schedule ad hoc).
final class TestAlarmStore {
  const TestAlarmStore(this._db);

  static const _key = 'test_alarm_at';

  /// Seconds the user waits (owner's copy: "in 60 seconds").
  static const delay = Duration(seconds: 60);

  final AppDatabase _db;

  Future<DateTime?> at() async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_key))).getSingleOrNull();
    final ms = int.tryParse(row?.value ?? '');
    return ms == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  Future<void> set(DateTime atUtc) => _db
      .into(_db.localMeta)
      .insertOnConflictUpdate(
        LocalMetaCompanion.insert(
          key: _key,
          value: '${atUtc.millisecondsSinceEpoch}',
        ),
      );

  Future<void> clear() =>
      (_db.delete(_db.localMeta)..where((m) => m.key.equals(_key))).go();
}

@Riverpod(keepAlive: true)
TestAlarmStore testAlarmStore(Ref ref) =>
    TestAlarmStore(ref.watch(appDatabaseProvider));

/// Sends or cancels the test alarm, then re-plans so the OS holds exactly
/// what the store says.
@Riverpod(keepAlive: true)
class TestAlarm extends _$TestAlarm {
  @override
  void build() {}

  /// Asks for one test alarm [TestAlarmStore.delay] from now; returns when
  /// it is due.
  Future<DateTime> send() async {
    final at = ref.read(clockProvider).nowUtc().add(TestAlarmStore.delay);
    await ref.read(testAlarmStoreProvider).set(at);
    await _resync();
    return at;
  }

  /// Takes the test alarm back (the screen was left before it rang).
  Future<void> cancel() async {
    await ref.read(testAlarmStoreProvider).clear();
    await _resync();
  }

  Future<void> _resync() async {
    final profile = await ref.read(localProfileProvider.future);
    await ref.read(notificationSyncProvider).resync(profile.id);
  }
}
