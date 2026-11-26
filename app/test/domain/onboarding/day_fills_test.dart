import 'package:dottoday/domain/onboarding/day_fills.dart';
import 'package:flutter_test/flutter_test.dart';

// What fills your days (prototype `rtime`, `gapTime`; ED-485).

void main() {
  test('the four land at the prototype\'s times', () {
    expect(FillPreset.morningRun.minuteOn(420, 1380), 435);
    expect(FillPreset.deepWork.minuteOn(420, 1380), 540);
    expect(FillPreset.deepWork.minuteOn(540, 1380), 600);
    expect(FillPreset.gym.minuteOn(420, 1380), 1080);
    expect(FillPreset.gym.minuteOn(420, 1140), 1020);
    expect(FillPreset.read.minuteOn(420, 1380), 1290);
    // On 15 minutes, after-midnight Wind Down included.
    expect(FillPreset.read.minuteOn(420, 1500), 1410);
    expect(FillPreset.morningRun.minuteOn(427, 1380) % 15, 0);
  });

  test('lengths, colours and icons', () {
    expect(
      [for (final p in FillPreset.values) p.durationMin],
      [45, 90, 60, 30],
    );
    expect(
      [for (final p in FillPreset.values) p.colorKey],
      ['coral', 'indigo', 'violet', 'brown'],
    );
    expect(
      [for (final p in FillPreset.values) p.iconKey],
      ['run', 'target', 'gym', 'book'],
    );
  });

  test('no time typed: the middle of the biggest gap', () {
    expect(fillGapMinute(420, 1380, []), 900);
    expect(fillGapMinute(420, 1380, [435]), 915);
    expect(fillGapMinute(420, 1380, [435, 1290, 540]), 915);
  });

  test('a typed time stays inside the day', () {
    expect(clampFillMinute(300, 420, 1380), 435);
    expect(clampFillMinute(1400, 420, 1380), 1365);
    expect(clampFillMinute(1140, 420, 1380), 1140);
  });

  test('each becomes a task that repeats every day from today', () {
    final now = DateTime.utc(2026, 10, 21, 9);
    final rows = fillsSeries(
      [
        DayFill.preset(id: 'a', title: 'Read', preset: FillPreset.read),
        const DayFill.typed(
          id: 'b',
          title: 'Night walk',
          colorKey: 'mint',
          iconKey: 'circle',
          minute: 1470,
          durationMin: 20,
        ),
      ],
      userId: 'u',
      tzId: 'Europe/Berlin',
      day: DateTime(2026, 10, 21),
      wake: 420,
      wind: 1500,
      nowUtc: now,
    );
    expect(rows.map((s) => s.rrule), everyElement('FREQ=DAILY'));
    expect(rows.first.id, 'a');
    expect(rows.first.dtstartLocal, '2026-10-21T23:30');
    expect(rows.first.durationMin, 30);
    // 00:30 the next morning starts tomorrow.
    expect(rows.last.dtstartLocal, '2026-10-22T00:30');
  });
}
