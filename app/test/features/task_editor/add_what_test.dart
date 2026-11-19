import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/task_editor/add/add_flow_sheet.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_title_field.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';
import 'add_harness.dart';

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

  // R-06 from the shell, the ⌘N key and a failed save's reopen run on
  // Create task, the phones' Add: create_task_test.dart.

  testWidgets('typing fills time live; a chip × keeps its word (E-R2-36)', (
    tester,
  ) async {
    final repo = await pumpAddHost(tester, rows: _history());
    expect(find.text('Type a time too: ‘Go shopping 5pm 1h’'), findsOneWidget);
    await tester.enterText(_title, 'Read 9pm 45m');
    await tester.pump();
    expect(find.widgetWithText(InputChip, '9pm'), findsOneWidget);
    expect(find.widgetWithText(InputChip, '45m'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove “9pm”'));
    await tester.pump();
    expect(find.widgetWithText(InputChip, '9pm'), findsNothing);
    expect(find.widgetWithText(TextField, 'Read 9pm 45m'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    // "9pm" is title text now, not a time: Minimal puts it in the first
    // free slot (docs/14 §4).
    final o = _added(repo, 'Read 9pm')!;
    expect((o.isInbox, o.durationMin), (false, 45));
  });

  // Suggestions and the colour row are Create task's and the popover's now
  // (create_task_test, add_popover_test); Minimal guesses the look.
  testWidgets('the title guesses the icon and colour; Undo removes it', (
    tester,
  ) async {
    final repo = await pumpAddHost(tester, rows: _history());
    await tester.enterText(_title, 'Dentist 3pm');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    final o = _added(repo, 'Dentist')!;
    expect((o.colorKey, o.iconKey), ('rose', 'tooth'));
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(_added(repo, 'Dentist')!.deletedAt, isNotNull);
  });

  testWidgets('close discards; a11y guidelines hold', (tester) async {
    final repo = await pumpAddHost(tester, rows: _history());
    await expectA11yGuidelines(tester);
    await tester.enterText(_title, 'Nope');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(_added(repo, 'Nope'), isNull);
    expect(find.text('More'), findsNothing);
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
                  onPressed: () => showAppSheet<void>(
                    context: context,
                    fullHeight: true,
                    builder: (_) => const AddFlowSheet(
                      request: AddRequest(
                        languageCode: 'en',
                        text: 'Go shopping',
                      ),
                    ),
                  ),
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
        expect(find.text('More'), findsOneWidget);
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
    expect(find.text('More'), findsOneWidget);
  });
}
