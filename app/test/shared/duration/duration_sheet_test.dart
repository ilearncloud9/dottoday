import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/time/duration_presets.dart';
import 'package:dottoday/shared/duration/duration_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

/// Opens the sheet; [result] gets what it returns, [saved] every preset
/// list handed back.
Future<void> _open(
  WidgetTester tester, {
  required List<int?> result,
  required List<List<int>> saved,
  int initial = 90,
  List<int> presets = defaultDurationPresets,
  ThemeMode mode = ThemeMode.light,
  Size size = const Size(390, 844),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    testApp(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async => result.add(
                await showDurationSheet(
                  context,
                  initial: initial,
                  color: TaskColor.coral,
                  icon: TaskIcon.bag,
                  presets: presets,
                  onPresets: saved.add,
                  preview: (m) => (
                    start: '5:00 PM',
                    end: m == 90 ? '6:30 PM' : 'later',
                    note: 'Still fits before Spanish review at 7:30',
                    fill: m / 150,
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
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('preview, presets with the current one picked, Done', (
    tester,
  ) async {
    final result = <int?>[];
    await _open(tester, result: result, saved: []);
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('ends 6:30 PM'), findsOneWidget);
    expect(
      find.text('Still fits before Spanish review at 7:30'),
      findsOneWidget,
    );
    final chip = tester.widget<InputChip>(
      find.widgetWithText(InputChip, '1h 30m'),
    );
    expect(chip.selected, isTrue);
    // 1h 30m is a preset already: no "+ preset".
    expect(find.text('preset'), findsNothing);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(result, [90]);
  });

  testWidgets('a preset tap picks it; × removes it; Reset restores', (
    tester,
  ) async {
    final result = <int?>[];
    final saved = <List<int>>[];
    await _open(tester, result: result, saved: saved);
    await tester.tap(find.text('45m'));
    await tester.pump();
    await tester.tap(find.byTooltip('Remove the 2 h preset'));
    await tester.pump();
    expect(saved.last, [15, 30, 45, 60, 90]);
    expect(find.text('2h'), findsNothing);
    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(saved.last, defaultDurationPresets);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(result, [45]);
  });

  testWidgets('a typed length moves the pick; "+ preset" keeps it', (
    tester,
  ) async {
    final result = <int?>[];
    final saved = <List<int>>[];
    await _open(tester, result: result, saved: saved);
    await tester.enterText(find.byType(TextField), '40m');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('preset'));
    await tester.pump();
    expect(saved.last, [15, 30, 40, 45, 60, 90, 120]);
    expect(find.text('40m'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'soon');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('Use 5 min to 24 h, like 40m or 1h30'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(result, [40]);
  });

  testWidgets('the last preset cannot be removed', (tester) async {
    await _open(tester, result: [], saved: [], presets: const [30]);
    final chip = tester.widget<InputChip>(
      find.widgetWithText(InputChip, '30m'),
    );
    expect(chip.onDeleted, isNull);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final (name, size) in [
      ('compact', const Size(390, 900)),
      ('expanded', const Size(1280, 900)),
    ]) {
      testWidgets('a11y ${mode.name} $name', (tester) async {
        await _open(tester, result: [], saved: [], mode: mode, size: size);
        await expectA11yGuidelines(tester);
      });
    }
  }
}
