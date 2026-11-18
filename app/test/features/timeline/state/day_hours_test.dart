import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/state/day_hours.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// The Day view's thread on hours (E-FullA-v2 web Day, M19.2 part 2), in
// Berlin on Wednesday 21 October 2026 (UTC+2).
void main() {
  tz_data.initializeTimeZones();
  final berlin = tz.getLocation('Europe/Berlin');
  DateTime at(int h, int m) => tz.TZDateTime(berlin, 2026, 10, 21, h, m);

  ThreadEntry task(String id, int h, int m, int minutes) => ThreadTaskEntry(
    ThreadTask(
      id: id,
      title: id,
      color: TaskColor.values.first,
      icon: TaskIcon.values.first,
      state: DotState.upcoming,
      timeRange: '',
      startUtc: at(h, m),
      minutes: minutes,
    ),
  );
  ThreadEntry gap(int h, int m, int minutes) =>
      ThreadGap(minutes: minutes, startLabel: '', startUtc: at(h, m));

  ThreadHours hours(List<ThreadEntry> entries) => dayHours(
    entries,
    zone: berlin,
    pxPerMinute: 70 / 60,
    label: (local) => '${local.hour}',
  );

  test('a row stands for its time and carries the hours inside it', () {
    final h = hours([
      const ThreadCap.wake('6:30'),
      task('run', 6, 45, 45),
      gap(7, 30, 90),
      task('deep', 9, 0, 120),
    ]);
    expect(h.spans[0], isNull, reason: 'a cap has no time');
    expect(h.spans[1]!.minutes, 45);
    expect(h.spans[1]!.marks, [(at: 1 / 3, label: '7')]);
    expect(h.spans[2]!.marks.single.label, '8');
    expect(h.spans[3]!.marks.map((m) => (m.at, m.label)), [
      (0.0, '9'),
      (0.5, '10'),
    ]);
  });

  test('an overlapped row ends where the next one starts', () {
    final h = hours([
      task('deep', 9, 0, 120),
      const ThreadNow('10:00'),
      task('call', 10, 30, 30),
    ]);
    expect(h.spans[0]!.minutes, 90);
    expect(h.spans[1], isNull);
    expect(h.spans[2]!.minutes, 30);
    expect(h.spans[0]!.marks.map((m) => m.label), ['9', '10']);
    expect(h.spans[2]!.marks, isEmpty, reason: 'each hour once');
  });
}
