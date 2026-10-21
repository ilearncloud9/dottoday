import 'package:dottoday/features/timeline/layout/drag_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('snapMinute rounds to the grid', () {
    expect(snapMinute(62, 5), 60);
    expect(snapMinute(63, 5), 65);
    expect(snapMinute(7.4, 15), 0);
    expect(snapMinute(7.6, 15), 15);
    expect(snapMinute(61, 1), 61);
  });

  test('move keeps the grab offset and stays inside the day', () {
    expect(
      moveSlot(
        pointerMin: 612,
        grabOffsetMin: 10,
        duration: 45,
        snap: 5,
        dayMinutes: 1440,
      ),
      (start: 600, duration: 45),
    );
    expect(
      moveSlot(
        pointerMin: -50,
        grabOffsetMin: 0,
        duration: 45,
        snap: 5,
        dayMinutes: 1440,
      ).start,
      0,
    );
    // May end past midnight, but never start after the last 5 minutes.
    expect(
      moveSlot(
        pointerMin: 1500,
        grabOffsetMin: 0,
        duration: 90,
        snap: 5,
        dayMinutes: 1440,
      ).start,
      1435,
    );
  });

  test('resizing the start keeps the end and the 5 min floor', () {
    const original = (start: 600, duration: 60);
    expect(resizeStartSlot(pointerMin: 571, original: original, snap: 5), (
      start: 570,
      duration: 90,
    ));
    expect(resizeStartSlot(pointerMin: 700, original: original, snap: 5), (
      start: 655,
      duration: 5,
    ));
    expect(
      resizeStartSlot(pointerMin: -30, original: original, snap: 5).start,
      0,
    );
  });

  test('resizing the end keeps the start within 5 min – 24 h', () {
    const original = (start: 600, duration: 60);
    expect(resizeEndSlot(pointerMin: 688, original: original, snap: 5), (
      start: 600,
      duration: 90,
    ));
    expect(
      resizeEndSlot(pointerMin: 500, original: original, snap: 5).duration,
      5,
    );
    expect(
      resizeEndSlot(pointerMin: 9999, original: original, snap: 5).duration,
      1440,
    );
  });

  test('a drop onto pinned blocks settles after them', () {
    const lunch = (start: 750, duration: 45); // 12:30–13:15
    const call = (start: 795, duration: 15); // 13:15–13:30, back to back
    expect(settleAfterPinned((start: 740, duration: 30), [call, lunch]), (
      (start: 810, duration: 30),
      true,
    ));
    expect(settleAfterPinned((start: 700, duration: 50), [lunch]), (
      (start: 700, duration: 50),
      false,
    ));
  });

  test('auto-scroll speeds up towards the edge', () {
    expect(autoScrollSpeed(80), 0);
    expect(autoScrollSpeed(64), 0);
    expect(autoScrollSpeed(32), closeTo(4.5, 1e-9));
    expect(autoScrollSpeed(0), 18);
    expect(autoScrollSpeed(-10), 18);
  });
}
