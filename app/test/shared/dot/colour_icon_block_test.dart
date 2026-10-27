import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/colour_icon_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

Widget _block({
  ValueChanged<TaskColor>? onColor,
  ValueChanged<TaskIcon>? onIcon,
  ThemeMode mode = ThemeMode.light,
}) => testApp(
  Scaffold(
    body: ColourIconBlock(
      color: TaskColor.coral,
      icon: TaskIcon.bag,
      onColor: onColor ?? (_) {},
      onIcon: onIcon ?? (_) {},
    ),
  ),
  themeMode: mode,
);

void main() {
  testWidgets('9 colours, the chosen icon + 2 quick ones, then "All icons"', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_block());
    expect(find.text('COLOUR AND ICON'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Coral')),
      isSemantics(isSelected: true, isButton: true, hasTapAction: true),
    );
    expect(find.bySemanticsLabel('Bag'), findsOneWidget);
    expect(find.bySemanticsLabel('Cart'), findsOneWidget);
    expect(find.byTooltip('All icons'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('taps report colour, quick icon and a grid icon', (tester) async {
    final colors = <TaskColor>[];
    final icons = <TaskIcon>[];
    await tester.pumpWidget(_block(onColor: colors.add, onIcon: icons.add));
    await tester.tap(find.bySemanticsLabel('Teal'));
    await tester.tap(find.bySemanticsLabel('Cart'));
    await tester.ensureVisible(find.byTooltip('All icons'));
    await tester.tap(find.byTooltip('All icons'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'camera');
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Camera'));
    await tester.pumpAndSettle();
    expect(colors, [TaskColor.teal]);
    expect(icons, [TaskIcon.cart, TaskIcon.camera]);
  });

  testWidgets('the full picker takes a colour and an icon together '
      '(M3f.3)', (tester) async {
    final colors = <TaskColor>[];
    final icons = <TaskIcon>[];
    await tester.pumpWidget(_block(onColor: colors.add, onIcon: icons.add));
    await tester.ensureVisible(find.byTooltip('All icons'));
    await tester.tap(find.byTooltip('All icons'));
    await tester.pumpAndSettle();
    expect(find.text('Colour and icon'), findsOneWidget);
    // The sheet's own colours come after the block's.
    await tester.tap(find.bySemanticsLabel('Mint').last);
    await tester.pumpAndSettle();
    // Dottoday's own planning icons open the library.
    await tester.tap(find.bySemanticsLabel('Focus Block'));
    await tester.pumpAndSettle();
    expect(colors, [TaskColor.mint]);
    expect(icons, [TaskIcon.focusBlock]);
  });

  testWidgets('a colour alone: Done keeps it', (tester) async {
    final colors = <TaskColor>[];
    final icons = <TaskIcon>[];
    await tester.pumpWidget(_block(onColor: colors.add, onIcon: icons.add));
    await tester.ensureVisible(find.byTooltip('All icons'));
    await tester.tap(find.byTooltip('All icons'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Sky').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(colors, [TaskColor.sky]);
    expect(icons, isEmpty);
  });

  testWidgets('the library is grouped by category and searchable', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_block());
    await tester.ensureVisible(find.byTooltip('All icons'));
    await tester.tap(find.byTooltip('All icons'));
    await tester.pumpAndSettle();
    expect(find.text('PLANNING & RHYTHM'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('PLANNING & RHYTHM')),
      isSemantics(isHeader: true),
    );
    // By name, by category title and by key ("gym" is Dumbbell's key).
    await tester.enterText(find.byType(TextField), 'washing');
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Washing Machine'), findsOneWidget);
    expect(find.text('HOME & CHORES'), findsOneWidget);
    expect(find.text('PLANNING & RHYTHM'), findsNothing);
    await tester.enterText(find.byType(TextField), 'gym');
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Dumbbell'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'qwxz');
    await tester.pumpAndSettle();
    expect(find.text('No icons match “qwxz”'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the chosen icon is marked selected in the library', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_block());
    await tester.ensureVisible(find.byTooltip('All icons'));
    await tester.tap(find.byTooltip('All icons'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'bag');
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Bag').last),
      isSemantics(isSelected: true, isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('the library sheet meets a11y guidelines (${mode.name})', (
      tester,
    ) async {
      await tester.pumpWidget(_block(mode: mode));
      await tester.ensureVisible(find.byTooltip('All icons'));
      await tester.tap(find.byTooltip('All icons'));
      await tester.pumpAndSettle();
      await expectA11yGuidelines(tester);
    });
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines (${mode.name})', (tester) async {
      await tester.pumpWidget(_block(mode: mode));
      await expectA11yGuidelines(tester);
    });
  }
}
