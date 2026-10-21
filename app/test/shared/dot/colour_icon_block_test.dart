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
    expect(find.bySemanticsLabel('Shopping bag'), findsOneWidget);
    expect(find.bySemanticsLabel('Shopping cart'), findsOneWidget);
    expect(find.byTooltip('All icons'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('taps report colour, quick icon and a grid icon', (tester) async {
    final colors = <TaskColor>[];
    final icons = <TaskIcon>[];
    await tester.pumpWidget(_block(onColor: colors.add, onIcon: icons.add));
    await tester.tap(find.bySemanticsLabel('Teal'));
    await tester.tap(find.bySemanticsLabel('Shopping cart'));
    await tester.ensureVisible(find.byTooltip('All icons'));
    await tester.tap(find.byTooltip('All icons'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Camera'));
    await tester.pumpAndSettle();
    expect(colors, [TaskColor.teal]);
    expect(icons, [TaskIcon.cart, TaskIcon.camera]);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines (${mode.name})', (tester) async {
      await tester.pumpWidget(_block(mode: mode));
      await expectA11yGuidelines(tester);
    });
  }
}
