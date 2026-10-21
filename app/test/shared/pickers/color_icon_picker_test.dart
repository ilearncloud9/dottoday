import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/app_theme.dart';
import 'package:dottoday/shared/pickers/block_names.dart';
import 'package:dottoday/shared/pickers/color_icon_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

Widget _picker({
  BlockColor color = BlockColor.teal,
  BlockIcon icon = BlockIcon.gym,
  ValueChanged<BlockColor>? onColor,
  ValueChanged<BlockIcon>? onIcon,
  ThemeMode mode = ThemeMode.light,
}) => testApp(
  Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ColorIconPicker(
        color: color,
        icon: icon,
        onColorChanged: onColor ?? (_) {},
        onIconChanged: onIcon ?? (_) {},
      ),
    ),
  ),
  themeMode: mode,
);

void main() {
  testWidgets('every colour and icon is a labelled choice', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_picker());
    expect(find.bySemanticsLabel('Coral'), findsOneWidget);
    expect(find.bySemanticsLabel('Slate'), findsOneWidget);
    expect(find.byTooltip('Gym'), findsOneWidget);
    expect(find.byTooltip('Travel'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Teal')),
      isSemantics(isSelected: true, isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });

  testWidgets('selection carries a non-colour cue (check mark)', (
    tester,
  ) async {
    await tester.pumpWidget(_picker());
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('taps report the choice', (tester) async {
    BlockColor? color;
    BlockIcon? icon;
    await tester.pumpWidget(
      _picker(onColor: (c) => color = c, onIcon: (i) => icon = i),
    );
    await tester.tap(find.bySemanticsLabel('Rose'));
    await tester.tap(find.byTooltip('Coffee'));
    expect(color, BlockColor.rose);
    expect(icon, BlockIcon.coffee);
  });

  testWidgets('names exist for every colour and icon', (tester) async {
    await tester.pumpWidget(testApp(const SizedBox()));
    final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)));
    final colors = {for (final c in BlockColor.values) blockColorName(l10n, c)};
    final icons = {for (final i in BlockIcon.values) blockIconName(l10n, i)};
    expect(colors, hasLength(BlockColor.values.length));
    expect(icons, hasLength(BlockIcon.values.length));
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines ($mode)', (tester) async {
      tester.view.physicalSize = const Size(400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_picker(mode: mode));
      await expectA11yGuidelines(tester);
    });
  }
}
