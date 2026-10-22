import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

/// The Month header (`A-mac-month`): "42 done · 5 missed · 23 ahead ·
/// busiest day Tue 13". Skipped tasks count nowhere.
final class MonthStats {
  const MonthStats({
    required this.done,
    required this.missed,
    required this.ahead,
    this.busiest,
  });

  /// [byDay]'s tasks at [nowUtc]: done ones; planned ones that already
  /// ended (missed); planned ones still to end (ahead, the live one
  /// included). The busiest day has the most planned minutes; ties go to
  /// the earlier day; none for an empty month.
  factory MonthStats.of(
    Map<DateTime, List<Occurrence>> byDay,
    DateTime nowUtc,
  ) {
    var done = 0;
    var missed = 0;
    var ahead = 0;
    DateTime? busiest;
    var most = 0;
    final days = byDay.keys.toList()..sort();
    for (final day in days) {
      var minutes = 0;
      for (final o in byDay[day]!) {
        if (o.status == OccurrenceStatus.skipped) continue;
        minutes += o.durationMin;
        if (o.status == OccurrenceStatus.done) {
          done++;
        } else if (o.endUtc != null && !o.endUtc!.isAfter(nowUtc)) {
          missed++;
        } else {
          ahead++;
        }
      }
      if (minutes > most) {
        most = minutes;
        busiest = day;
      }
    }
    return MonthStats(
      done: done,
      missed: missed,
      ahead: ahead,
      busiest: busiest,
    );
  }

  final int done;
  final int missed;
  final int ahead;

  /// Local date of the day with the most planned time.
  final DateTime? busiest;
}
