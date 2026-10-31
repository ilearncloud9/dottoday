import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/today_harness.dart';

Future<Settings> _stored(WidgetTester tester) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(TodayScreen)),
  );
  final profile = await container
      .read(settingsRepositoryProvider)
      .findLocalProfile();
  return profile!.settings;
}

Future<void> _type(WidgetTester tester, String digits) async {
  await tester.enterText(find.byType(TextField).last, digits);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();
}

// The thread's caps open their time (R-17): every day, or only this
// weekday (the demo day is a Wednesday).
void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Wake Up for every Wednesday moves only Wednesdays', (
    tester,
  ) async {
    await pumpToday(tester);
    await tester.tap(find.text('Wake Up · 7:00 AM'));
    await tester.pumpAndSettle();
    await _type(tester, '0630');
    await tester.tap(find.text('Every Wednesday'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Done').last);
    await tester.pumpAndSettle();
    final s = await _stored(tester);
    expect(s.boundaryFor(Weekday.wed).start, '06:30');
    expect(s.boundaryFor(Weekday.tue).start, '07:00');
    expect(find.text('Wake Up · 6:30 AM'), findsOneWidget);
  });

  testWidgets('Wind Down for every day moves every weekday', (tester) async {
    await pumpToday(tester);
    final cap = find.text('Wind Down · 10:00 PM');
    await tester.scrollUntilVisible(
      cap,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(cap);
    await tester.pumpAndSettle();
    expect(find.text('Every day'), findsOneWidget);
    await _type(tester, '2230');
    await tester.tap(find.widgetWithText(FilledButton, 'Done').last);
    await tester.pumpAndSettle();
    final s = await _stored(tester);
    for (final d in Weekday.values) {
      expect(s.boundaryFor(d).end, '22:30');
    }
  });

  testWidgets('dismissing the sheet changes nothing', (tester) async {
    await pumpToday(tester);
    await tester.tap(find.text('Wake Up · 7:00 AM'));
    await tester.pumpAndSettle();
    await _type(tester, '0500');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect((await _stored(tester)).boundaryFor(Weekday.wed).start, '07:00');
  });
}
