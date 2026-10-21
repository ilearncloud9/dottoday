import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/layout/day_layout.dart';
import 'package:dottoday/features/timeline/layout/time_scale.dart';
import 'package:dottoday/features/timeline/layout/timeline_day.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../domain/fixtures.dart';

void main() {
  late TimelineDay day;
  late TimeScale scale; // 1 px per minute, whole day core

  setUpAll(() {
    tz_data.initializeTimeZones();
    day = TimelineDay.of(DateTime(2026, 10, 21), tz.getLocation('UTC'));
    scale = TimeScale.forDay(
      dayMinutes: 1440,
      coreFrom: 0,
      coreTo: 1440,
      pxPerMin: 1,
      collapsedPxPerMin: 1,
    );
  });

  var n = 0;
  Occurrence b(int startMin, int duration) => occurrenceFixture().copyWith(
    id: 'b${n++}'.padLeft(4, '0'),
    startUtc: day.startUtc.add(Duration(minutes: startMin)),
    durationMin: duration,
  );

  DayLayout lay(List<Occurrence> blocks, {double min = 10}) =>
      layoutDay(blocks: blocks, day: day, scale: scale, minHeight: min);

  test('non-overlapping blocks get one column each', () {
    final l = lay([b(60, 30), b(90, 30), b(200, 60)]);
    expect(l.placements.map((p) => (p.column, p.columns)), [
      (0, 1),
      (0, 1),
      (0, 1),
    ]);
    expect(l.placements.first.top, 60);
    expect(l.placements.first.height, 30);
  });

  test('overlapping pair sits side by side', () {
    final l = lay([b(540, 120), b(630, 45)]);
    expect(l.placements.map((p) => (p.column, p.columns)), [(0, 2), (1, 2)]);
  });

  test('a freed column is reused inside a cluster', () {
    final l = lay([b(0, 120), b(10, 20), b(40, 20)]);
    expect(l.placements.map((p) => p.column), [0, 1, 1]);
    expect(l.placements.every((p) => p.columns == 2), isTrue);
  });

  test('more than 3 columns hides the rest behind one +n marker', () {
    final blocks = [for (var i = 0; i < 5; i++) b(100 + i, 60)];
    final l = lay(blocks);
    expect(l.placements, hasLength(3));
    expect(l.placements.every((p) => p.columns == 3), isTrue);
    expect(l.overflow.single.hidden, hasLength(2));
    expect(l.overflow.single.top, 103);
  });

  test('short blocks grow to the minimum height and that drives overlap', () {
    final l = lay([b(0, 5), b(20, 5)], min: 44);
    expect(l.placements.first.height, 44);
    expect(l.placements.map((p) => p.columns), [2, 2]);
  });

  test('blocks crossing midnight are clamped and flagged', () {
    final yesterday = b(-60, 120);
    final tonight = b(1400, 120);
    final l = lay([yesterday, tonight]);
    final first = l.placements.first;
    expect((first.top, first.height, first.startsBefore), (0, 60, true));
    final last = l.placements.last;
    expect((last.top, last.bottom, last.endsAfter), (1400, 1440, true));
  });

  test('visibleIn returns only intersecting placements', () {
    final l = lay([b(0, 30), b(300, 30), b(600, 30)]);
    expect(l.visibleIn(290, 400).map((p) => p.top), [300]);
    expect(l.visibleIn(0, 1440), hasLength(3));
  });

  test('inbox items are ignored', () {
    final inbox = occurrenceFixture().copyWith(startUtc: null);
    expect(lay([inbox]).placements, isEmpty);
  });
}
