import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_models.dart';

/// Most dots the Earlier row shows (ED-164: up to three, overlapping).
const earlierDots = 3;

/// [entries] as the rest of today (ED-164, board E-Earlier): done tasks
/// behind now fold into one [ThreadEarlier] row at the top, with no count.
///
/// The view starts at the fold, so the Wake Up cap and the free time
/// already behind now are left out. Only done tasks fold: a reopened or
/// missed task keeps its time in the thread. With nothing done yet there
/// is no row. [open] keeps the folded tasks in their rows under it;
/// folded, they and the knots between two of them are left out.
///
/// ```dart
/// foldEarlier([wake, run, gap, now, lunch, bed], open: false);
/// // [earlier(run), now, lunch, bed]
/// ```
List<ThreadEntry> foldEarlier(List<ThreadEntry> entries, {required bool open}) {
  final solid = threadSolid(entries);
  bool folds(int i) => switch (entries[i]) {
    ThreadTaskEntry(:final task) =>
      task.state == DotState.done && solid[i] != null,
    _ => false,
  };
  final folded = [
    for (final (i, e) in entries.indexed)
      if (folds(i)) (e as ThreadTaskEntry).task.color,
  ];
  final out = <ThreadEntry>[];
  for (final (i, e) in entries.indexed) {
    switch (e) {
      case ThreadCap(windDown: false):
        if (folded.isEmpty) continue;
        out.add(
          ThreadEarlier(
            dots: folded.take(earlierDots).toList(),
            first: folded.first,
            last: folded.last,
            open: open,
          ),
        );
      case ThreadGap(addable: false):
        continue;
      case ThreadOverlap() when !open && _between(i, entries.length, folds):
        continue;
      case ThreadTaskEntry() when !open && folds(i):
        continue;
      default:
        out.add(e);
    }
  }
  return out;
}

/// Whether the knot at [i] sits between two folded tasks.
bool _between(int i, int length, bool Function(int) folds) =>
    i > 0 && i + 1 < length && folds(i - 1) && folds(i + 1);
