import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/notifications/notification_content.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/notifications/alarm_capabilities.dart';
import 'package:dottoday/domain/notifications/planned_notification.dart';

/// Hands the week's Wake Up alarms to [AlarmGateway] (docs/15 W1b,
/// ADR-0017) and returns the instants it armed, which the notification
/// path then leaves out, so a Wake Up rings exactly once (R-10).
///
/// The armed instants are kept per device in `local_meta`: a background
/// engine can't reach the gateway (Android registers its channel on the
/// activity), and it still leaves out what the last reachable sync armed,
/// while ringing the rest on the notification path (W1a) rather than not
/// at all.
final class WakeUpArming {
  const WakeUpArming(this._gateway, this._db, {bool Function()? minimal})
    : _minimal = minimal;

  static const _key = 'armed_wake_ups';

  final AlarmGateway _gateway;
  final AppDatabase _db;

  /// Whether the ringing screen is minimal mode's (the provider asks
  /// `LayoutPolicy`; this code never reads the layout, ADR-0016).
  final bool Function()? _minimal;

  /// Arms [wakeUps] (`NotificationPlanner.wakeUps`) for [profile]; with the
  /// switch off, disarms every alarm once. [tasks] finds each day's first
  /// block by id.
  Future<Set<DateTime>> arm(
    List<PlannedNotification> wakeUps, {
    required Profile profile,
    required Map<String, Occurrence> tasks,
  }) async {
    final known = await _read();
    if (!profile.settings.wakeUpAlarm) {
      if (known == null) return const {};
      await _gateway.disarmAll();
      await _write(null);
      return const {};
    }
    final armed = await _gateway.sync([
      for (final w in wakeUps)
        composeWakeUpAlarm(
          w,
          task: tasks[w.occurrenceId],
          profile: profile,
          minimal: _minimal?.call() ?? false,
        ),
    ]);
    if (armed == null) return known ?? const {};
    await _write(armed);
    return armed;
  }

  /// Null until the gateway armed something on this device, and after the
  /// switch went off.
  Future<Set<DateTime>?> _read() async {
    final row = await (_db.select(
      _db.localMeta,
    )..where((m) => m.key.equals(_key))).getSingleOrNull();
    if (row == null) return null;
    return {
      for (final ms in row.value.split(',').map(int.tryParse).nonNulls)
        DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
    };
  }

  Future<void> _write(Set<DateTime>? armed) async {
    if (armed == null) {
      await (_db.delete(_db.localMeta)..where((m) => m.key.equals(_key))).go();
      return;
    }
    await _db
        .into(_db.localMeta)
        .insertOnConflictUpdate(
          LocalMetaCompanion.insert(
            key: _key,
            value: [
              for (final at in armed) at.millisecondsSinceEpoch,
            ].join(','),
          ),
        );
  }
}
