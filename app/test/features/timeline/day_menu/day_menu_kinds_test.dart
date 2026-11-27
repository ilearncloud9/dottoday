import 'package:dottoday/core/shortcuts/day_action.dart';
import 'package:dottoday/core/theme/dot_idiom.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/widgets/day_menu_chip.dart';
import 'package:dottoday/features/timeline/widgets/today_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/a11y.dart';
import '../../../support/timeline_fakes.dart';
import '../../../support/today_harness.dart';

/// The Day menu (ED-093, G2-9; tablets ED-254; docs/09 M20.3 part 1).
void main() {
  setUpAll(tz_data.initializeTimeZones);

  final ios = TargetPlatformVariant.only(TargetPlatform.iOS);
  final android = TargetPlatformVariant.only(TargetPlatform.android);

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip('More options').hitTestable().first);
    await tester.pumpAndSettle();
  }

  testWidgets('Full on an iPhone: Day ▾ floats at the end, four groups', (
    tester,
  ) async {
    await pumpToday(tester);
    final chip = tester.getRect(find.byType(DayMenuChip));
    expect(chip.center.dx, greaterThan(390 / 2), reason: 'the end');
    await openMenu(tester);
    for (final text in [
      'Time',
      'Need more time',
      'Shift the rest from here…',
      'Rebalance…',
      'Plan',
      'Brain dump…',
      'Drop a routine…',
      "Pick today's one thing…",
      'Day',
      'Duplicate day…',
      'Copy day as text',
      'Review the day',
      'This week',
      'Layout',
      'Low-energy mode',
      'Plan / Reality',
      'Show less',
    ]) {
      expect(find.text(text), findsWidgets, reason: text);
    }
  }, variant: ios);

  testWidgets('Android: Day ▾ floats at the start', (tester) async {
    await pumpToday(tester, size: const Size(412, 892));
    final chip = tester.getRect(find.byType(DayMenuChip));
    expect(chip.center.dx, lessThan(412 / 2));
  }, variant: android);

  testWidgets('Need more time ▸ +15 makes the task on now longer, with Undo', (
    tester,
  ) async {
    final repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
    await pumpToday(tester, repo: repo);
    final before = repo.rows.singleWhere(
      (o) => o.title == 'Deep work: roadmap',
    );
    await openMenu(tester);
    await tester.tap(find.text('Need more time'));
    await tester.pumpAndSettle();
    expect(find.text('Then shift the rest'), findsOneWidget);
    await tester.tap(find.text('+15 min'));
    await tester.pumpAndSettle();
    final after = repo.rows.singleWhere((o) => o.title == 'Deep work: roadmap');
    expect(after.durationMin, before.durationMin + 15);
    expect(find.text('Undo'), findsOneWidget);
  }, variant: ios);

  testWidgets('another day: Time is off, the rest works', (tester) async {
    await pumpToday(tester, date: DateTime(2026, 10, 23));
    await openMenu(tester);
    final menu = tester.widget<PopupMenuItem<VoidCallback>>(
      find.ancestor(
        of: find.text('Shift the rest from here…'),
        matching: find.byType(PopupMenuItem<VoidCallback>),
      ),
    );
    expect(menu.enabled, isFalse);
    final copy = tester.widget<PopupMenuItem<VoidCallback>>(
      find.ancestor(
        of: find.text('Copy day as text'),
        matching: find.byType(PopupMenuItem<VoidCallback>),
      ),
    );
    expect(copy.enabled, isTrue);
  }, variant: ios);

  testWidgets('Minimal on a phone: the three items (docs/14 §4)', (
    tester,
  ) async {
    await pumpToday(
      tester,
      settings: const Settings(uiLayout: UiLayout.minimal, use24h: false),
    );
    expect(find.byType(DayMenuChip), findsNothing, reason: 'the ⋯ stays');
    await openMenu(tester);
    expect(find.text('Show everything'), findsOneWidget);
    expect(find.text('Low-energy mode'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Need more time'), findsNothing);
  }, variant: ios);

  testWidgets('Minimal from medium width: E-Minimal\'s list (ED-254)', (
    tester,
  ) async {
    await pumpToday(
      tester,
      size: const Size(820, 1180),
      settings: const Settings(uiLayout: UiLayout.minimal, use24h: false),
    );
    await openMenu(tester);
    for (final text in [
      'Need more time',
      'Shift the rest from here…',
      'Brain dump…',
      'Drop a routine…',
      'Duplicate day…',
      'Copy day as text',
      'Review the day',
      'Low-energy mode',
      'Show everything',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('Rebalance…'), findsNothing, reason: 'Full and ⌘K');
    expect(find.text('Time'), findsNothing, reason: 'no group titles');
  }, variant: ios);

  testWidgets('the web: the minutes as chips and the switch', (tester) async {
    debugWebChromeOverride = true;
    addTearDown(() => debugWebChromeOverride = null);
    await pumpToday(tester);
    await openMenu(tester);
    expect(find.widgetWithText(ActionChip, '+5 min'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, '+30 min'), findsOneWidget);
    expect(find.text('Then shift the rest'), findsNothing);
    expect(find.byType(Switch), findsWidgets);
  });

  testWidgets('the Mac menu bar\'s intent runs on the day on screen', (
    tester,
  ) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (_) async => null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpToday(tester);
    // As sendToFocus does from inside Today.
    final inside = tester.element(find.byType(DayMenuChip));
    Actions.invoke(inside, const DayActionIntent(DayAction.copyText));
    await tester.pumpAndSettle();
    expect(find.text('Day copied as text'), findsOneWidget);
  });

  testWidgets('the open menu meets a11y guidelines', (tester) async {
    await pumpToday(tester);
    await openMenu(tester);
    await expectA11yGuidelines(tester);
  }, variant: android);

  testWidgets('Full on a phone in landscape keeps the ⋯', (tester) async {
    await pumpToday(tester, size: const Size(844, 390));
    expect(find.byType(DayMenuChip), findsNothing);
    expect(find.byType(TodayMenu), findsWidgets);
  }, variant: ios);
}
