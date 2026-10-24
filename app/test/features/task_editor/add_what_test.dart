import 'package:dottoday/app.dart';
import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/task_editor/add/add_flow_sheet.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_title_field.dart';
import 'package:dottoday/features/task_editor/add/widgets/habit_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

/// 11:00 in Berlin, Wednesday 21 October 2026.
final _now = DateTime.utc(2026, 10, 21, 9);

/// Two past "Go shopping" runs and one "Answer emails": the habits.
List<Occurrence> _history() => [
  for (final day in [14, 7])
    Occurrence(
      id: '01928c3e-0000-7000-8000-0000000001$day',
      userId: testUserId,
      title: 'Go shopping',
      colorKey: 'coral',
      iconKey: 'bag',
      startUtc: DateTime.utc(2026, 10, day, 15),
      tzId: 'Europe/Berlin',
      durationMin: 60,
      createdAt: DateTime.utc(2026, 10),
      updatedAt: DateTime.utc(2026, 10),
    ),
  Occurrence(
    id: '01928c3e-0000-7000-8000-000000000199',
    userId: testUserId,
    title: 'Answer emails',
    colorKey: 'slate',
    iconKey: 'mail',
    startUtc: DateTime.utc(2026, 10, 20, 8),
    tzId: 'Europe/Berlin',
    durationMin: 15,
    createdAt: DateTime.utc(2026, 10),
    updatedAt: DateTime.utc(2026, 10),
  ),
];

/// The real router and shell; the add button opens Add as in the app.
Future<FakeOccurrenceRepository> _pumpApp(
  WidgetTester tester, {
  String location = AppRoutes.today,
  WriteFault? writeFault,
}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeOccurrenceRepository(_history());
  final router = buildRouter(appScreens);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    testRouterApp(
      router,
      onQuickAdd: () => openQuickAdd(router),
      overrides: timelineOverrides(
        now: _now,
        occurrences: repo,
        profile: testProfile(settings: const Settings(use24h: false)),
        writeFault: writeFault,
      ),
    ),
  );
  router.go(location);
  await tester.pumpAndSettle();
  return repo;
}

Finder get _addButton => find.byTooltip('Add task');

Finder get _title => find.descendant(
  of: find.byType(AddTitleField),
  matching: find.byType(TextField),
);

Occurrence? _added(FakeOccurrenceRepository repo, String title) => repo.rows
    .where(
      (o) =>
          o.title == title && o.createdAt.isAfter(DateTime.utc(2026, 10, 21)),
    )
    .firstOrNull;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('a11y', _a11yMatrix);

  group('≤ 2 taps + typing from any tab (R-06)', () {
    for (final tab in [AppRoutes.today, AppRoutes.inbox, AppRoutes.search]) {
      testWidgets('$tab: add button, type, Enter → on its day (1 tap)', (
        tester,
      ) async {
        final repo = await _pumpApp(tester, location: tab);
        var taps = 0;
        await tester.tap(_addButton);
        taps++;
        await tester.pumpAndSettle();
        // The title is focused: no tap needed before typing.
        await tester.enterText(_title, 'Pay rent 5pm 20m');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        final o = _added(repo, 'Pay rent')!;
        expect(o.startUtc, DateTime.utc(2026, 10, 21, 15));
        expect(o.durationMin, 20);
        expect(taps, lessThanOrEqualTo(2));
        expect(find.text('Pay rent added for 5:00 PM'), findsOneWidget);
      });
    }

    testWidgets('add button, type, "Add to Inbox instead" (2 taps)', (
      tester,
    ) async {
      final repo = await _pumpApp(tester);
      await tester.tap(_addButton);
      await tester.pumpAndSettle();
      await tester.enterText(_title, 'Call Mum 3pm');
      await tester.pump();
      await tester.tap(find.text('Add to Inbox instead'));
      await tester.pumpAndSettle();
      final o = _added(repo, 'Call Mum')!;
      expect(o.isInbox, isTrue);
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('⌘N / Ctrl+N opens Add too', (tester) async {
      await _pumpApp(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('a failed save reopens Add over the shell (M8.5b, R-08)', (
      tester,
    ) async {
      final fault = WriteFault()..failure = const StorageFailure();
      final repo = await _pumpApp(tester, writeFault: fault);
      await tester.tap(_addButton);
      await tester.pumpAndSettle();
      await tester.enterText(_title, 'Call Mum 3pm');
      await tester.pump();
      await tester.tap(find.text('Add to Inbox instead'));
      await tester.pumpAndSettle();
      expect(_added(repo, 'Call Mum'), isNull);
      expect(find.widgetWithText(TextField, 'Call Mum 3pm'), findsOneWidget);
      fault.failure = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(_added(repo, 'Call Mum')!.isInbox, isTrue);
      expect(find.byType(BottomSheet), findsNothing);
    });
  });

  testWidgets('typing fills time live; a chip removes its token', (
    tester,
  ) async {
    final repo = await _pumpApp(tester);
    await tester.tap(_addButton);
    await tester.pumpAndSettle();
    expect(find.text('Type a time too: ‘Go shopping 5pm 1h’'), findsOneWidget);
    await tester.enterText(_title, 'Read 9pm 45m');
    await tester.pump();
    expect(find.widgetWithText(InputChip, '9pm'), findsOneWidget);
    expect(find.widgetWithText(InputChip, '45m'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove “9pm”'));
    await tester.pump();
    expect(find.widgetWithText(InputChip, '9pm'), findsNothing);
    expect(find.widgetWithText(TextField, 'Read 45m'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    final o = _added(repo, 'Read')!;
    expect((o.isInbox, o.durationMin), (true, 45));
  });

  testWidgets('suggestions come from habits; picking one fills it all', (
    tester,
  ) async {
    final repo = await _pumpApp(tester);
    await tester.tap(_addButton);
    await tester.pumpAndSettle();
    expect(find.text('SUGGESTIONS'), findsOneWidget);
    expect(find.text('usually 5:00 PM – 6:00 PM · 1 h'), findsOneWidget);
    await tester.enterText(_title, 'shop');
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(HabitList),
        matching: find.text('Answer emails'),
      ),
      findsNothing,
    );
    await tester.tap(find.text('Go shopping'));
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Go shopping'), findsOneWidget);
    // The habit the title names is the ticked one.
    final list = tester.widget<HabitList>(find.byType(HabitList));
    expect(list.selected?.title, 'Go shopping');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    final o = _added(repo, 'Go shopping')!;
    expect(o.startUtc, DateTime.utc(2026, 10, 21, 15));
    expect((o.durationMin, o.colorKey, o.iconKey), (60, 'coral', 'bag'));
  });

  testWidgets('a picked colour and icon are saved; Undo removes the task', (
    tester,
  ) async {
    final repo = await _pumpApp(tester);
    await tester.tap(_addButton);
    await tester.pumpAndSettle();
    await tester.enterText(_title, 'Swim 7pm');
    await tester.tap(find.bySemanticsLabel('Teal'));
    // The colour row scrolls rather than shrink its 44 pt targets.
    await tester.ensureVisible(find.bySemanticsLabel('Shopping cart'));
    await tester.tap(find.bySemanticsLabel('Shopping cart'));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    final o = _added(repo, 'Swim')!;
    expect((o.colorKey, o.iconKey), ('teal', 'cart'));
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(_added(repo, 'Swim')!.deletedAt, isNotNull);
  });

  testWidgets('close discards; a11y guidelines hold', (tester) async {
    final repo = await _pumpApp(tester);
    await tester.tap(_addButton);
    await tester.pumpAndSettle();
    await expectA11yGuidelines(tester);
    await tester.enterText(_title, 'Nope');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(_added(repo, 'Nope'), isNull);
    expect(find.text('Continue'), findsNothing);
  });
}

/// Add opened from a plain host at [size] in [mode] (the expanded shell has
/// no add button; ⌘N opens the same sheet).
Future<void> _pumpHost(
  WidgetTester tester, {
  required Size size,
  required ThemeMode mode,
  double textScale = 1,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: _now,
        occurrences: FakeOccurrenceRepository(_history()),
        profile: testProfile(settings: const Settings(use24h: false)),
      ),
      child: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: testApp(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => showAddFlow(context, text: 'Go shopping'),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
          themeMode: mode,
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void _a11yMatrix() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final (name, size) in [
      ('compact', const Size(390, 844)),
      ('expanded', const Size(1280, 800)),
    ]) {
      testWidgets('A1 a11y ${mode.name} $name', (tester) async {
        await _pumpHost(tester, size: size, mode: mode);
        expect(find.text('Continue'), findsOneWidget);
        await expectA11yGuidelines(tester);
        // The token-chip state too.
        await tester.enterText(_title, 'Go shopping 5pm 1h');
        await tester.pump();
        await expectA11yGuidelines(tester);
      });
    }
  }

  testWidgets('A1 at 200 % text: nothing overflows', (tester) async {
    await _pumpHost(
      tester,
      size: const Size(390, 844),
      mode: ThemeMode.light,
      textScale: 2,
    );
    final e = tester.takeException();
    expect(e, isNull);
    expect(find.text('Continue'), findsOneWidget);
  });
}
