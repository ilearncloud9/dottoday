import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/day_shape.dart';

/// One dot of a [DaySnapshot]: planned and, once known, actual (B1).
final class SnapshotDot {
  const SnapshotDot({
    required this.id,
    required this.title,
    required this.startUtc,
    required this.durationMin,
    required this.colorKey,
    required this.iconKey,
    required this.done,
    this.actualStartUtc,
    this.actualEndUtc,
  });

  /// Timed occurrence [o] as a dot (it must have a start).
  factory SnapshotDot.fromOccurrence(Occurrence o) => SnapshotDot(
    id: o.id,
    title: o.title,
    startUtc: o.startUtc!,
    durationMin: o.durationMin,
    colorKey: o.colorKey,
    iconKey: o.iconKey,
    done: o.status == OccurrenceStatus.done,
    actualStartUtc: o.actualStartUtc,
    actualEndUtc: o.actualEndUtc,
  );

  /// The occurrence id: what the five intents (B6) act on.
  final String id;
  final String title;
  final DateTime startUtc;
  final int durationMin;
  final String colorKey;
  final String iconKey;
  final bool done;
  final DateTime? actualStartUtc;
  final DateTime? actualEndUtc;

  /// Planned end.
  DateTime get endUtc => startUtc.add(Duration(minutes: durationMin));

  /// Whether the dot is under way at [nowUtc]: started, not ended, not done.
  bool liveAt(DateTime nowUtc) =>
      !done && !startUtc.isAfter(nowUtc) && endUtc.isAfter(nowUtc);

  @override
  bool operator ==(Object other) =>
      other is SnapshotDot &&
      other.id == id &&
      other.title == title &&
      other.startUtc == startUtc &&
      other.durationMin == durationMin &&
      other.colorKey == colorKey &&
      other.iconKey == iconKey &&
      other.done == done &&
      other.actualStartUtc == actualStartUtc &&
      other.actualEndUtc == actualEndUtc;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    startUtc,
    durationMin,
    colorKey,
    iconKey,
    done,
    actualStartUtc,
    actualEndUtc,
  );
}

/// B5 (docs/11 §0): the one immutable record of the day that every surface
/// outside the app reads — widgets, Live Activity, ongoing notification,
/// menu bar, the web's service worker and, later, the watch (ADR-0010).
/// Written after every write, by the daily refresh (which also covers
/// Bedtime) and on demand; none of those surfaces talks to Supabase.
///
/// The dots cover the next [window] from [generatedAtUtc] (the widgets'
/// view), the day fields today's Wake Up → Bedtime.
final class DaySnapshot {
  const DaySnapshot({
    required this.generatedAtUtc,
    required this.wakeUtc,
    required this.bedUtc,
    required this.dots,
    required this.inboxCount,
    this.dayDone = 0,
    this.dayTotal = 0,
  });

  /// Builds the snapshot at [nowUtc] from occurrences overlapping the next
  /// 24 h. Running dots are kept; skipped and deleted ones dropped; at most
  /// [maxDots], earliest first (ties by id, so the order is stable).
  ///
  /// ```dart
  /// DaySnapshot.build(nowUtc: now, occurrences: rows, inboxCount: 3,
  ///     shape: DayShape.on(zone, today, settings.boundaryFor(weekday)));
  /// ```
  factory DaySnapshot.build({
    required DateTime nowUtc,
    required Iterable<Occurrence> occurrences,
    required int inboxCount,
    required DayShape shape,
    Iterable<Occurrence> dayOccurrences = const [],
  }) {
    final today = [
      for (final o in dayOccurrences)
        if (_inDay(o, shape)) o,
    ];
    final end = nowUtc.add(window);
    final dots = [
      for (final o in occurrences)
        if (_shows(o, nowUtc, end)) _dot(o),
    ]..sort(_byStart);
    return DaySnapshot(
      generatedAtUtc: nowUtc,
      wakeUtc: shape.wakeUtc,
      bedUtc: shape.bedUtc,
      dots: List.unmodifiable(dots.take(maxDots)),
      inboxCount: inboxCount,
      dayDone: today.where((o) => o.status == OccurrenceStatus.done).length,
      dayTotal: today.length,
    );
  }

  /// The JSON format version every reader checks (docs/11 B5).
  static const version = 1;
  static const window = Duration(hours: 24);
  static const maxDots = 20;

  /// How many dots after the current one the record names (M9.3: the Live
  /// Activity counts down to them without an update).
  static const nextCount = 2;

  final DateTime generatedAtUtc;
  final DateTime wakeUtc;
  final DateTime bedUtc;
  final List<SnapshotDot> dots;
  final int inboxCount;

  /// Today's dots (Wake Up → Bedtime, not skipped) that are done, and all
  /// of them: the Live Activity's "1 of 3" (M9.3). Past dots are outside
  /// [dots], so these are counted when the snapshot is built.
  final int dayDone;
  final int dayTotal;

  /// The dot under way when the snapshot was made, if any.
  SnapshotDot? get current => currentAt(generatedAtUtc);

  /// The next dots after [current] (at most [nextCount]).
  List<SnapshotDot> get next => nextAt(generatedAtUtc);

  /// Share of today's waking day elapsed when the snapshot was made.
  double get dayProgress =>
      DayShape(wakeUtc: wakeUtc, bedUtc: bedUtc).progressAt(generatedAtUtc);

  /// The dot under way at [nowUtc]; the earliest wins an overlap.
  SnapshotDot? currentAt(DateTime nowUtc) {
    for (final d in dots) {
      if (d.liveAt(nowUtc)) return d;
    }
    return null;
  }

  /// The not-done dots starting after [nowUtc], earliest first.
  List<SnapshotDot> nextAt(DateTime nowUtc) => [
    for (final d in dots)
      if (!d.done && d.startUtc.isAfter(nowUtc)) d,
  ].take(nextCount).toList();

  @override
  bool operator ==(Object other) =>
      other is DaySnapshot &&
      other.generatedAtUtc == generatedAtUtc &&
      other.wakeUtc == wakeUtc &&
      other.bedUtc == bedUtc &&
      other.inboxCount == inboxCount &&
      other.dayDone == dayDone &&
      other.dayTotal == dayTotal &&
      _sameDots(other.dots, dots);

  @override
  int get hashCode => Object.hash(
    generatedAtUtc,
    wakeUtc,
    bedUtc,
    inboxCount,
    dayDone,
    dayTotal,
    Object.hashAll(dots),
  );

  static bool _sameDots(List<SnapshotDot> a, List<SnapshotDot> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _shows(Occurrence o, DateTime now, DateTime end) {
    final start = o.startUtc;
    if (start == null || o.deletedAt != null) return false;
    if (o.status == OccurrenceStatus.skipped) return false;
    return start.isBefore(end) && o.endUtc!.isAfter(now);
  }

  static bool _inDay(Occurrence o, DayShape shape) {
    final start = o.startUtc;
    if (start == null || o.deletedAt != null) return false;
    if (o.status == OccurrenceStatus.skipped) return false;
    return !start.isBefore(shape.wakeUtc) && start.isBefore(shape.bedUtc);
  }

  static SnapshotDot _dot(Occurrence o) => SnapshotDot.fromOccurrence(o);

  static int _byStart(SnapshotDot a, SnapshotDot b) {
    final byStart = a.startUtc.compareTo(b.startUtc);
    return byStart != 0 ? byStart : a.id.compareTo(b.id);
  }
}

/// Where the snapshot goes: the shared store of each platform (App Group
/// on iOS, `home_widget` prefs on Android, the menu bar on the Mac, Cache
/// Storage on the web).
abstract interface class DaySnapshotSink {
  Future<void> write(DaySnapshot snapshot);
}
