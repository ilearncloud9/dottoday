import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

/// One of the day's dots on the Android ringing screen's day dot
/// (E-R2-19-B "It rings: dawn round the day dot", ED-314): where it sits
/// on the ring as shares of the 24 hours from Wake Up, which is at the top.
final class WakeUpArc {
  const WakeUpArc({
    required this.from,
    required this.to,
    required this.colorKey,
  });

  /// Shares of the turn, 0 at Wake Up, clockwise; [to] ≥ [from], at most 1.
  final double from;
  final double to;

  /// The dot's stored `color_key`, resolved to a colour by the gateway.
  final String colorKey;

  @override
  bool operator ==(Object other) =>
      other is WakeUpArc &&
      other.from == from &&
      other.to == to &&
      other.colorKey == colorKey;

  @override
  int get hashCode => Object.hash(from, to, colorKey);
}

/// The ring is one day: the 24 hours from Wake Up round to the next.
const _day = Duration(hours: 24);

/// The arcs of the dots in [blocks] that start within the 24 hours from
/// [wakeUtc], in time order; skipped dots and the inbox left out. A dot
/// running past the next Wake Up stops at the top.
///
/// ```dart
/// // Wake Up 6:30, a run 6:45–7:30:
/// wakeUpArcs(wake, [run]).single; // from 0.0104, to 0.0417
/// ```
List<WakeUpArc> wakeUpArcs(DateTime wakeUtc, Iterable<Occurrence> blocks) {
  final end = wakeUtc.add(_day);
  final timed = [
    for (final b in blocks)
      if (b.startUtc case final start?)
        if (b.status != OccurrenceStatus.skipped &&
            !start.isBefore(wakeUtc) &&
            start.isBefore(end))
          b,
  ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
  double share(DateTime at) =>
      at.difference(wakeUtc).inSeconds / _day.inSeconds;
  return [
    for (final b in timed)
      WakeUpArc(
        from: share(b.startUtc!),
        to: b.endUtc!.isAfter(end) ? 1 : share(b.endUtc!),
        colorKey: b.colorKey,
      ),
  ];
}
