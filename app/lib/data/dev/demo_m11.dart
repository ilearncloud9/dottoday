// DEBUG ONLY. The M11 sample on top of the demo day (docs/09 M11.6): real
// times on two tasks (the Reality thread), ten earlier finished runs of
// the task under way (so the reality thread is revealed and learning has
// something to say, docs/13) and three routines. Reached from
// the debug menu, behind kDebugMode like the demo day, and used by the
// design sweeps (device and web). Titles are sample data, not UI copy.
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/writes/write_batch.dart';

/// The sample for [day] (today's demo rows): its first task finished 12
/// min after its plan and took 34; its last still-planned task under way
/// for 20 min at [nowUtc], with [historyRuns] earlier runs on the days
/// before, each started 10 min after plan and 20 min longer; Morning,
/// Shutdown and Gym day.
WriteBatch buildM11Sample({
  required String userId,
  required List<Occurrence> day,
  required DateTime nowUtc,
}) {
  final timed = [
    for (final o in day)
      if (o.startUtc != null &&
          o.deletedAt == null &&
          o.source == OccurrenceSource.user)
        o,
  ]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
  final planned = [
    for (final o in timed)
      if (o.status == OccurrenceStatus.planned) o,
  ];
  final first = timed.firstOrNull;
  final start = first?.startUtc!.add(const Duration(minutes: 12));
  final live = planned.lastOrNull;
  return WriteBatch(
    userId: userId,
    occurrences: [
      if (first != null)
        first.copyWith(
          status: OccurrenceStatus.done,
          actualStartUtc: start,
          actualEndUtc: start!.add(const Duration(minutes: 34)),
          updatedAt: nowUtc,
        ),
      if (live case final o? when o.id != first?.id) ...[
        o.copyWith(
          actualStartUtc: nowUtc.subtract(const Duration(minutes: 20)),
          updatedAt: nowUtc,
        ),
        ..._history(o, nowUtc),
      ],
    ],
    routines: [
      for (final (i, r) in _routines.indexed)
        Routine(
          id: '01928c3e-0000-7000-8000-00000000${i}aa1',
          userId: userId,
          title: r.$1,
          anchor: r.$2,
          anchorMinute: r.$2 == RoutineAnchor.time ? 17 * 60 + 30 : null,
          sortOrder: i.toDouble(),
          items: [
            for (final (j, s) in r.$3.indexed)
              RoutineItem(
                id: 'demo-step-$i$j',
                title: s.$1,
                colorKey: s.$2,
                iconKey: s.$3,
                offsetMin: s.$4,
                durationMin: s.$5,
              ),
          ],
          createdAt: nowUtc,
          updatedAt: nowUtc,
        ),
    ],
  );
}

/// Earlier runs of the task under way: finished, 10 min after plan, 20 min
/// longer than planned.
const historyRuns = 10;

List<Occurrence> _history(Occurrence live, DateTime nowUtc) => [
  for (var d = 1; d <= historyRuns; d++)
    () {
      final plan = live.startUtc!.subtract(Duration(days: d));
      final began = plan.add(const Duration(minutes: 10));
      return live.copyWith(
        id: '01928c3e-0000-7000-8000-0000000eb0${d.toString().padLeft(2, '0')}',
        seriesId: null,
        startUtc: plan,
        status: OccurrenceStatus.done,
        actualStartUtc: began,
        actualEndUtc: began.add(Duration(minutes: live.durationMin + 20)),
        updatedAt: nowUtc,
      );
    }(),
];

const _routines = [
  (
    'Morning',
    RoutineAnchor.wake,
    [
      ('Wake up stretch', 'mint', 'heart', 0, 10),
      ('Run', 'coral', 'run', 10, 30),
      ('Shower', 'sky', 'water', 40, 15),
      ('Breakfast', 'amber', 'meal', 55, 20),
    ],
  ),
  (
    'Shutdown',
    RoutineAnchor.bed,
    [
      ('Review today', 'slate', 'list', 0, 10),
      ('Plan tomorrow', 'indigo', 'document', 10, 15),
      ('Read', 'violet', 'book', 25, 15),
    ],
  ),
  (
    'Gym day',
    RoutineAnchor.time,
    [
      ('Pack bag', 'amber', 'bag', 0, 10),
      ('Gym', 'mint', 'gym', 10, 60),
      ('Protein', 'rose', 'meal', 70, 5),
    ],
  ),
];
