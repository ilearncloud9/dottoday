import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/series.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:timezone/timezone.dart' as tz;

// DEBUG ONLY. A realistic day for trying the timeline by hand before Quick
// Add exists (M4). Only reachable behind `kDebugMode`, so release builds
// tree-shake it. Titles are sample data, not UI copy, hence English here
// rather than ARB (and why this lives in data/, outside the l10n scan).

/// One scheduled demo block: local start, minutes, look and flags.
typedef _Block = ({
  String title,
  ClockTime at,
  int min,
  String color,
  String icon,
  bool done,
  bool pinned,
});

_Block _b(
  String title,
  int h,
  int m,
  int min,
  String color,
  String icon, {
  bool done = false,
  bool pinned = false,
}) => (
  title: title,
  at: ClockTime(h, m),
  min: min,
  color: color,
  icon: icon,
  done: done,
  pinned: pinned,
);

/// 12 one-off blocks (plus the recurring standup = 13 on the day):
/// two done, one pinned, an overlapping pair (Deep work / Design review)
/// and one crossing midnight (Night train).
final List<_Block> _blocks = [
  _b('Morning run', 6, 45, 45, 'coral', 'run', done: true),
  _b('Coffee & plan the day', 7, 30, 15, 'amber', 'coffee', done: true),
  _b('Deep work: roadmap', 9, 0, 120, 'indigo', 'code'),
  _b('Design review', 10, 30, 45, 'violet', 'meeting'),
  _b('Reply to email', 11, 30, 30, 'slate', 'mail'),
  _b('Lunch with Sam', 12, 30, 45, 'tangerine', 'meal', pinned: true),
  _b('Spanish lesson', 14, 0, 60, 'teal', 'study'),
  _b('Call the dentist', 15, 30, 15, 'rose', 'call'),
  _b('Gym', 17, 30, 60, 'lime', 'gym'),
  _b('Dinner', 19, 0, 45, 'mint', 'meal'),
  _b('Read', 20, 30, 30, 'magenta', 'book'),
  _b('Night train to Berlin', 23, 30, 75, 'sky', 'flight'),
];

const _inbox = [
  ('Buy a birthday gift', 'shopping'),
  ('Book the car service', 'commute'),
];

const _deepWorkSubtasks = [
  ('Outline Q1 goals', true),
  ('Draft milestones', false),
  ('Share with the team', false),
];

/// Builds the demo day for [date]'s calendar day in [location].
///
/// IDs are derived from that day, so loading twice resets the same rows
/// (including un-deleting them) instead of duplicating the day.
WriteBatch buildDemoDay({
  required String userId,
  required tz.Location location,
  required DateTime date,
  required DateTime nowUtc,
}) {
  final dayStart = const ClockTime(0, 0).onDate(location, date);
  String id(int n) => demoDayId(dayStart, n);

  Occurrence occurrence(int n, String title, String icon) => Occurrence(
    id: id(n),
    userId: userId,
    title: title,
    iconKey: icon,
    tzId: location.name,
    durationMin: 30,
    createdAt: nowUtc,
    updatedAt: nowUtc,
  );

  final blocks = [
    for (final (i, b) in _blocks.indexed)
      occurrence(i, b.title, b.icon).copyWith(
        colorKey: b.color,
        startUtc: b.at.onDate(location, date),
        durationMin: b.min,
        pinned: b.pinned,
        status: b.done ? OccurrenceStatus.done : OccurrenceStatus.planned,
        completedAtUtc: b.done ? nowUtc : null,
      ),
  ];
  final inbox = [
    for (final (i, (title, icon)) in _inbox.indexed)
      occurrence(40 + i, title, icon).copyWith(sortOrder: i.toDouble()),
  ];
  final deepWork = blocks[2];
  final subtasks = [
    for (final (i, (title, done)) in _deepWorkSubtasks.indexed)
      Subtask(
        id: id(60 + i),
        userId: userId,
        occurrenceId: deepWork.id,
        title: title,
        done: done,
        sortOrder: i.toDouble(),
        createdAt: nowUtc,
        updatedAt: nowUtc,
      ),
  ];
  return WriteBatch(
    userId: userId,
    series: [_standup(id(80), userId, location, date, nowUtc)],
    occurrences: [...blocks, ...inbox],
    subtasks: subtasks,
  );
}

/// Daily 08:00 standup starting [date]; the write path materialises its
/// occurrences (90 days), so today's appears on the timeline.
Series _standup(
  String id,
  String userId,
  tz.Location location,
  DateTime date,
  DateTime nowUtc,
) {
  final d =
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
  return Series(
    id: id,
    userId: userId,
    title: 'Team standup',
    colorKey: 'sky',
    iconKey: 'meeting',
    durationMin: 15,
    rrule: 'FREQ=DAILY',
    dtstartLocal: '${d}T08:00',
    tzId: location.name,
    createdAt: nowUtc,
    updatedAt: nowUtc,
  );
}

/// A UUID v7 whose timestamp is [dayStartUtc] and whose tail is [n], so demo
/// rows are stable per day and still pass the v7 deep-link guard (M0.5).
String demoDayId(DateTime dayStartUtc, int n) {
  final ms = dayStartUtc.millisecondsSinceEpoch.toRadixString(16);
  final t = ms.padLeft(12, '0');
  final tail = n.toRadixString(16).padLeft(12, '0');
  return '${t.substring(0, 8)}-${t.substring(8)}-7de0-8de0-$tail';
}
