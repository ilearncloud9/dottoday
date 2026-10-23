import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/recurrence/repeat_rule.dart';
import 'package:dottoday/domain/time/wall_clock.dart';
import 'package:timezone/timezone.dart' as tz;

/// What an edit of one instance changed; null fields are unchanged.
/// [startMinute] is the new local time of day; [rule] a new repeat rule.
final class SeriesChange {
  const SeriesChange({
    this.title,
    this.notes,
    this.colorKey,
    this.iconKey,
    this.durationMin,
    this.pinned,
    this.startMinute,
    this.rule,
    this.alerts,
    this.tzId,
  });

  final String? title;
  final String? notes;
  final String? colorKey;
  final String? iconKey;
  final int? durationMin;
  final bool? pinned;
  final int? startMinute;
  final RepeatRule? rule;

  /// New alerts (M3f.2): the series takes them and later rows inherit;
  /// "this one" keeps them on the row.
  final List<Alert>? alerts;

  /// A new zone (M5.9, travel "keep times"): later instances keep their
  /// clock time in it. Moves instances, so the series is split.
  final String? tzId;

  /// The fields [after] changes from [before] (the instance as it was
  /// opened); the time of day as minutes in [zone].
  factory SeriesChange.between(
    Occurrence before,
    Occurrence after,
    tz.Location zone,
  ) {
    int? minute(Occurrence o) => switch (o.startUtc) {
      final s? => _minuteOf(utcToWallClock(zone, s)),
      null => null,
    };
    T? diff<T extends Object>(T? a, T? b) => a == b ? null : b;
    return SeriesChange(
      title: diff<String>(before.title, after.title),
      notes: diff<String>(before.notes, after.notes),
      colorKey: diff<String>(before.colorKey, after.colorKey),
      iconKey: diff<String>(before.iconKey, after.iconKey),
      durationMin: diff<int>(before.durationMin, after.durationMin),
      pinned: diff<bool>(before.pinned, after.pinned),
      startMinute: diff<int>(minute(before), minute(after)),
    );
  }

  /// Whether nothing changed.
  bool get isEmpty =>
      title == null &&
      notes == null &&
      colorKey == null &&
      iconKey == null &&
      durationMin == null &&
      pinned == null &&
      startMinute == null &&
      rule == null &&
      alerts == null &&
      tzId == null;

  /// A new time or rule moves instances: the series is split.
  bool get moves => startMinute != null || rule != null || tzId != null;

  /// [o] with the field changes (not the time). New alerts become the
  /// row's own when [own] (this one), else it inherits the series'.
  Occurrence fields(Occurrence o, {bool own = false}) => o.copyWith(
    alerts: alerts == null ? o.alerts : (own ? alerts : null),
    title: title ?? o.title,
    notes: notes ?? o.notes,
    colorKey: colorKey ?? o.colorKey,
    iconKey: iconKey ?? o.iconKey,
    durationMin: durationMin ?? o.durationMin,
    pinned: pinned ?? o.pinned,
    tzId: tzId ?? o.tzId,
  );

  /// [s]'s template with the field changes.
  Series template(Series s) => s.copyWith(
    alerts: alerts ?? s.alerts,
    title: title ?? s.title,
    notes: notes ?? s.notes,
    colorKey: colorKey ?? s.colorKey,
    iconKey: iconKey ?? s.iconKey,
    durationMin: durationMin ?? s.durationMin,
    pinned: pinned ?? s.pinned,
    tzId: tzId ?? s.tzId,
  );

  static int _minuteOf(DateTime wall) => wall.hour * 60 + wall.minute;
}
