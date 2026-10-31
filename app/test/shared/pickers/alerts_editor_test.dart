import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/alert.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/shared/pickers/alerts/alerts_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';

// The Alerts editor (docs/09 M3f.2, R-10).

Future<Future<List<Alert>?>> _open(
  WidgetTester tester,
  List<Alert> initial, {
  ValueChanged<bool>? onWindDown,
  ThemeMode mode = ThemeMode.light,
}) async {
  tester.view
    ..physicalSize = const Size(390, 1200)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  late BuildContext ctx;
  await tester.pumpWidget(
    MaterialApp(
      theme: DotTheme.light(),
      darkTheme: DotTheme.dark(),
      themeMode: mode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (c) {
          ctx = c;
          return const Scaffold();
        },
      ),
    ),
  );
  final result = showAlertsEditor(
    ctx,
    initial: initial,
    onWindDown: onWindDown,
  );
  await tester.pumpAndSettle();
  return result;
}

const _ten = Alert(kind: AlertKind.before, offsetMin: 10);

void main() {
  testWidgets('add and remove; the result is in time order', (tester) async {
    final result = await _open(tester, const [_ten]);
    await tester.tap(find.widgetWithText(ActionChip, 'at start'));
    await tester.tap(find.widgetWithText(ActionChip, '30 min before'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove 10 min before'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    expect(await result, const [
      Alert(kind: AlertKind.before, offsetMin: 30),
      Alert(kind: AlertKind.atStart),
    ]);
  });

  testWidgets('five at most: the choices turn off', (tester) async {
    await _open(tester, [
      for (final m in [60, 30, 15, 10, 5])
        Alert(kind: AlertKind.before, offsetMin: m),
    ]);
    expect(find.text('Up to 5 alerts'), findsOneWidget);
    final chip = tester.widget<ActionChip>(
      find.widgetWithText(ActionChip, 'at start'),
    );
    expect(chip.onPressed, isNull);
  });

  testWidgets('the Wind Down switch reports at once', (tester) async {
    bool? windDown;
    await _open(tester, const [], onWindDown: (v) => windDown = v);
    await tester.tap(find.text('Wind Down reminder'));
    await tester.pumpAndSettle();
    expect(windDown, isTrue);
  });

  testWidgets('meets a11y guidelines in both themes', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await _open(tester, const [_ten], onWindDown: (_) {}, mode: mode);
      await expectA11yGuidelines(tester);
    }
  });
}
