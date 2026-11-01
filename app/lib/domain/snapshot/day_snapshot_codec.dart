import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/domain/validation/field_rules.dart';

/// JSON v1 of [DaySnapshot] (docs/11 B5): the shape in the App Group,
/// `home_widget` prefs and the web's Cache Storage. Instants are UTC epoch
/// milliseconds; the derived fields (`progress`, `current_id`, `next_ids`,
/// `end_ms`) are written for readers that can't compute them and ignored
/// on decode. Platform sinks add display fields (labels, formatted times,
/// colours) next to these keys; [decodeDaySnapshot] ignores those too.
///
/// ```dart
/// decodeDaySnapshot(jsonDecode(jsonEncode(encodeDaySnapshot(s)))) == s
/// ```
Map<String, Object?> encodeDaySnapshot(DaySnapshot s) => {
  'v': DaySnapshot.version,
  'generated_ms': s.generatedAtUtc.millisecondsSinceEpoch,
  'wake_ms': s.wakeUtc.millisecondsSinceEpoch,
  'bed_ms': s.bedUtc.millisecondsSinceEpoch,
  'progress': s.dayProgress,
  // The night (docs/15 W6): the next Wake Up, and the ring share where the
  // day ends and the night starts (1 = no night), so native painters draw
  // it without the geometry's maths.
  'tomorrow_wake_ms': s.tomorrowWakeUtc?.millisecondsSinceEpoch,
  'night_start': s.geometry.dayEnd,
  'current_id': s.current?.id,
  'next_ids': [for (final d in s.next) d.id],
  // Today's one thing (docs/15 §8): its dot is ringed on the widgets.
  'one_thing_id': s.oneThingId,
  'inbox_count': s.inboxCount,
  'day_done': s.dayDone,
  'day_total': s.dayTotal,
  'blocks': [for (final d in s.dots) _encodeDot(d)],
};

Map<String, Object?> _encodeDot(SnapshotDot d) => {
  'id': d.id,
  'title': d.title,
  'start_ms': d.startUtc.millisecondsSinceEpoch,
  'end_ms': d.endUtc.millisecondsSinceEpoch,
  'duration_min': d.durationMin,
  'color_key': d.colorKey,
  'icon_key': d.iconKey,
  'done': d.done,
  'actual_start_ms': d.actualStartUtc?.millisecondsSinceEpoch,
  'actual_end_ms': d.actualEndUtc?.millisecondsSinceEpoch,
};

/// The snapshot in [json], or null when it isn't a well-formed v1 record
/// (another version, a missing or mistyped field, out-of-range values).
/// Total: never throws, whatever [json] holds.
DaySnapshot? decodeDaySnapshot(Object? json) {
  if (json is! Map<String, Object?>) return null;
  if (json['v'] != DaySnapshot.version) return null;
  final generated = _instant(json['generated_ms']);
  final wake = _instant(json['wake_ms']);
  final bed = _instant(json['bed_ms']);
  final inbox = json['inbox_count'];
  final dayDone = json['day_done'];
  final dayTotal = json['day_total'];
  final blocks = json['blocks'];
  if (generated == null || wake == null || bed == null) return null;
  if (inbox is! int || inbox < 0) return null;
  if (dayTotal is! int || dayDone is! int) return null;
  if (dayDone < 0 || dayDone > dayTotal) return null;
  if (blocks is! List<Object?> || blocks.length > DaySnapshot.maxDots) {
    return null;
  }
  final dots = <SnapshotDot>[];
  for (final b in blocks) {
    final dot = _decodeDot(b);
    if (dot == null) return null;
    dots.add(dot);
  }
  return DaySnapshot(
    generatedAtUtc: generated,
    wakeUtc: wake,
    bedUtc: bed,
    dots: List.unmodifiable(dots),
    inboxCount: inbox,
    dayDone: dayDone,
    dayTotal: dayTotal,
    tomorrowWakeUtc: _instant(json['tomorrow_wake_ms']),
    oneThingId: _text(json['one_thing_id'], 64),
  );
}

SnapshotDot? _decodeDot(Object? json) {
  if (json is! Map<String, Object?>) return null;
  final id = _text(json['id'], 64);
  final title = _text(json['title'], maxTitleLength, allowEmpty: true);
  final start = _instant(json['start_ms']);
  final duration = json['duration_min'];
  final color = _text(json['color_key'], 32);
  final icon = _text(json['icon_key'], 64);
  final done = json['done'];
  if (id == null || title == null || start == null) return null;
  if (duration is! int || duration < 0 || duration > maxDurationMin) {
    return null;
  }
  if (color == null || icon == null || done is! bool) return null;
  final actualStart = json['actual_start_ms'];
  final actualEnd = json['actual_end_ms'];
  final decodedStart = actualStart == null ? null : _instant(actualStart);
  final decodedEnd = actualEnd == null ? null : _instant(actualEnd);
  if ((actualStart != null && decodedStart == null) ||
      (actualEnd != null && decodedEnd == null)) {
    return null;
  }
  return SnapshotDot(
    id: id,
    title: title,
    startUtc: start,
    durationMin: duration,
    colorKey: color,
    iconKey: icon,
    done: done,
    actualStartUtc: decodedStart,
    actualEndUtc: decodedEnd,
  );
}

// Years 2000–2200: anything outside is corrupt, not a plan.
const _minMs = 946684800000;
const _maxMs = 7258118400000;

DateTime? _instant(Object? ms) => ms is int && ms >= _minMs && ms <= _maxMs
    ? DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true)
    : null;

String? _text(Object? value, int max, {bool allowEmpty = false}) {
  if (value is! String || value.length > max) return null;
  return value.isEmpty && !allowEmpty ? null : value;
}
