import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

Future<void> _size(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _host(ValueChanged<Future<int?>> onOpen, {ThemeMode? mode}) => testApp(
  Scaffold(
    body: Builder(
      builder: (context) => Center(
        child: TextButton(
          onPressed: () => onOpen(
            showAppSheet<int>(
              context: context,
              title: 'Pick', // l10n-ignore: test fixture
              builder: (c) => TextButton(
                onPressed: () => Navigator.of(c).pop(7),
                child: const Text('seven'), // l10n-ignore: test fixture
              ),
            ),
          ),
          child: const Text('open'), // l10n-ignore: test fixture
        ),
      ),
    ),
  ),
  themeMode: mode ?? ThemeMode.light,
);

void main() {
  testWidgets('compact width opens a bottom sheet that returns a value', (
    tester,
  ) async {
    await _size(tester, const Size(400, 800));
    Future<int?>? result;
    await tester.pumpWidget(_host((f) => result = f));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Pick'), findsOneWidget);
    await tester.tap(find.text('seven'));
    await tester.pumpAndSettle();
    expect(await result, 7);
  });

  testWidgets('wide layout opens a popover dialog', (tester) async {
    await _size(tester, const Size(1000, 700));
    await tester.pumpWidget(_host((_) {}));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });

  for (final size in [const Size(400, 800), const Size(1000, 700)]) {
    testWidgets('close button and Esc dismiss ($size)', (tester) async {
      await _size(tester, size);
      Future<int?>? result;
      await tester.pumpWidget(_host((f) => result = f));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Pick'), findsNothing);
      expect(await result, isNull);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Pick'), findsNothing);
    });
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final size in [const Size(400, 800), const Size(1000, 700)]) {
      testWidgets('meets a11y guidelines ($mode, $size)', (tester) async {
        await _size(tester, size);
        await tester.pumpWidget(_host((_) {}, mode: mode));
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        await expectA11yGuidelines(tester);
      });
    }
  }

  for (final (name, size) in [
    ('compact', const Size(390, 844)),
    ('wide', const Size(1280, 800)),
  ]) {
    testWidgets('an open sheet follows a light → dark switch ($name)', (
      tester,
    ) async {
      await _size(tester, size);
      await tester.pumpWidget(_host((_) {}, mode: ThemeMode.light));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(_host((_) {}, mode: ThemeMode.dark));
      await tester.pumpAndSettle();
      final dark = DotTheme.dark().extension<DotTheme>()!.colors.raised;
      final surface = tester
          .widgetList<Material>(
            find.ancestor(
              of: find.text('seven'),
              matching: find.byType(Material),
            ),
          )
          .map((m) => m.color)
          .whereType<Color>();
      expect(surface, contains(dark));
    });
  }
}
