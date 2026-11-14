import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/repositories/occurrence_repository.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/time/wind_down.dart';
import 'package:dottoday/domain/wake_up/one_thing.dart';
import 'package:timezone/timezone.dart' as tz;

/// Rebuilds the day snapshot (B5) from the database and hands it to the
/// platform's sink (docs/04 §4, docs/11 B5).
final class DaySnapshotWriter {
  DaySnapshotWriter({
    required Clock clock,
    required OccurrenceRepository occurrences,
    required Future<Profile> Function() profile,
    required DaySnapshotSink sink,
  }) : _clock = clock,
       _occurrences = occurrences,
       _profile = profile,
       _sink = sink;

  final Clock _clock;
  final OccurrenceRepository _occurrences;
  final Future<Profile> Function() _profile;
  final DaySnapshotSink _sink;

  /// Builds the snapshot of the owner shown now, without writing it.
  /// [userId] is who asked; a request made before a change of owner (a
  /// queued write, a late timer) still gets the owner shown, never the one
  /// who left (CR-160 I8): every surface reads this snapshot.
  Future<DaySnapshot> build(String userId) async {
    final now = _clock.nowUtc();
    final profile = await _profile();
    final owner = profile.id;
    final blocks = await _occurrences
        .watchRange(owner, now, now.add(DaySnapshot.window))
        .first;
    final inbox = await _occurrences.watchInbox(owner).first;
    final location = tz.getLocation(profile.tzId);
    final settings = profile.settings;
    final local = tz.TZDateTime.from(now, location);
    final date = DateTime(local.year, local.month, local.day);
    final next = nextWakeUtc(location, date, settings);
    final tomorrow = await _occurrences
        .watchRange(owner, next, next.add(const Duration(hours: 18)))
        .first;
    // The effective Wind Down (docs/15 W4) and, while it shows, the night.
    final shape = effectiveDayShape(
      location,
      date,
      settings,
      nowUtc: now,
      tomorrowHasThread: tomorrow.any((o) => o.startUtc != null),
    );
    final day = await _occurrences
        .watchRange(owner, shape.wakeUtc, shape.bedUtc)
        .first;
    return DaySnapshot.build(
      nowUtc: now,
      occurrences: blocks,
      inboxCount: inbox.length,
      shape: shape,
      dayOccurrences: day,
      tomorrowWakeUtc: settings.showNightArc ? next : null,
      oneThingId: oneThingOn(settings.oneThing, formatRouteDate(local)),
    );
  }

  /// Builds and writes the shown owner's snapshot (see [build]); returns
  /// what was written.
  Future<DaySnapshot> write(String userId) async {
    final snapshot = await build(userId);
    await _sink.write(snapshot);
    return snapshot;
  }

  /// Writes an empty day (no dots, nothing in the Inbox, a default UTC day
  /// shape) without reading any owner: the first thing a change of owner
  /// does, so widgets, the live dot, the menu bar and the web cache never
  /// keep the previous owner's day, even when no owner can be shown
  /// (CR-160 I8).
  Future<DaySnapshot> writeEmpty() async {
    final now = _clock.nowUtc();
    final date = DateTime(now.year, now.month, now.day);
    final snapshot = DaySnapshot.build(
      nowUtc: now,
      occurrences: const [],
      inboxCount: 0,
      shape: effectiveDayShape(
        tz.UTC,
        date,
        const Settings(),
        nowUtc: now,
        tomorrowHasThread: false,
      ),
    );
    await _sink.write(snapshot);
    return snapshot;
  }
}
