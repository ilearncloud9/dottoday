import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/task_color_keys.gen.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:timezone/timezone.dart' as tz;

/// Longest all-day event Dottoday spreads over days; anything longer (a
/// "whole year" subscription) shows on its first year only.
const maxAllDaySpanDays = 366;

/// The task colour a calendar's events take (docs/02 F5 "colour
/// inheritance", R-02): the [palette] key nearest to [argb] in RGB, so an
/// imported block is always drawn with theme tokens, never a raw colour.
/// No colour → [defaultTaskColorKey].
///
/// ```dart
/// inheritColorKey(0xFFFF2D55, {'coral': 0xFFE5674F, 'sky': 0xFF2E8FD6});
/// // 'coral'
/// ```
String inheritColorKey(int? argb, Map<String, int> palette) {
  if (argb == null || palette.isEmpty) return defaultTaskColorKey;
  var best = defaultTaskColorKey;
  var bestDistance = double.infinity;
  for (final MapEntry(:key, :value) in palette.entries) {
    final d = _distance(argb, value);
    if (d < bestDistance) {
      bestDistance = d;
      best = key;
    }
  }
  return best;
}

/// Squared "redmean" distance: plain RGB weighted the way eyes are, cheap
/// and good enough to pick one of nine colours.
double _distance(int a, int b) {
  final (r1, g1, b1) = _rgb(a);
  final (r2, g2, b2) = _rgb(b);
  final mean = (r1 + r2) / 2;
  final dr = r1 - r2;
  final dg = g1 - g2;
  final db = b1 - b2;
  return (2 + mean / 256) * dr * dr +
      4 * dg * dg +
      (2 + (255 - mean) / 256) * db * db;
}

(int, int, int) _rgb(int argb) =>
    ((argb >> 16) & 0xFF, (argb >> 8) & 0xFF, argb & 0xFF);

/// The calendar dates an all-day [event] covers, as date-only UTC values
/// (docs/03 §3.1 all-day strip). Each becomes one all-day item on that day
/// (M7.2), since an item lasts at most 24 h. At least one day; at most
/// [maxAllDaySpanDays]. Empty for a timed event.
///
/// ```dart
/// // Fri–Sun conference: start 2026-10-23Z, end 2026-10-26Z (exclusive)
/// allDayDates(event); // [Oct 23, Oct 24, Oct 25]
/// ```
List<DateTime> allDayDates(ExternalEvent event) {
  if (!event.allDay) return const [];
  final end = _date(event.endUtc);
  final days = [_date(event.startUtc)];
  var next = _nextDay(days.last);
  while (next.isBefore(end) && days.length < maxAllDaySpanDays) {
    days.add(next);
    next = _nextDay(next);
  }
  return days;
}

DateTime _date(DateTime utc) => DateTime.utc(utc.year, utc.month, utc.day);

DateTime _nextDay(DateTime d) => DateTime.utc(d.year, d.month, d.day + 1);

/// Where an all-day item for [date] starts: that day's local midnight in
/// [location]. With the maximum duration it is what the all-day strip
/// shows (`TimelineDay.isAllDay`, docs/03 §3.1 clarified in M3.2).
DateTime allDayStartUtc(DateTime date, tz.Location location) =>
    const ClockTime(0, 0).onDate(location, date);

/// Settings › Calendars rows: each device calendar with its switch and
/// inherited colour, grouped by account, then by name. A calendar the
/// person never switched is on: connecting means "show my calendars"
/// (R-02), and one added to the device later comes in the same way.
List<CalendarChoice> calendarChoices(
  List<DeviceCalendar> calendars,
  List<CalendarAccount> rows,
  Map<String, int> palette,
) {
  final enabled = {for (final r in rows) ?r.externalAccountId: r.enabled};
  final sorted = [...calendars]
    ..sort((a, b) {
      final byAccount = (a.accountName ?? '').compareTo(b.accountName ?? '');
      return byAccount != 0 ? byAccount : a.name.compareTo(b.name);
    });
  return [
    for (final c in sorted)
      CalendarChoice(
        calendar: c,
        enabled: enabled[c.id] ?? true,
        colorKey: inheritColorKey(c.colorArgb, palette),
      ),
  ];
}

/// Whether [o] stays on this device, never synced: an import from this
/// device's calendars, with its subtasks (docs/05 "Device calendars").
/// Every device imports its own calendars, so a synced copy would show
/// twice on the others (docs/09 M7.2). M7.4's cloud calendars revisit
/// this once their events come from the server.
bool isDeviceOnly(Occurrence o) => o.source == OccurrenceSource.calendar;
