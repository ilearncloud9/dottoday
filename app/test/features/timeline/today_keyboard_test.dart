import 'package:dottoday/shared/dot/day_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/today_harness.dart';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  // Found by CI's journey test after Wind Down: with the Day review above the
  // card, the Add sheet's keyboard shrank Today behind it until the pager
  // overflowed (M5.0 carry-over CI run).
  testWidgets('a keyboard over Today after Wind Down leaves the card alone', (
    tester,
  ) async {
    await pumpToday(
      tester,
      size: const Size(411, 840),
      ticks: Stream.value(DateTime.utc(2026, 10, 21, 21, 30)),
    );
    final before = tester.getSize(find.byType(DayCard).first);
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(DayCard).first), before);
  });
}
