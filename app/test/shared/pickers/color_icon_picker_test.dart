import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/pickers/block_names.dart';
import 'package:dottoday/shared/pickers/color_icon_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

Widget _picker({
  TaskColor color = TaskColor.teal,
  TaskIcon icon = TaskIcon.gym,
  ValueChanged<TaskColor>? onColor,
  ValueChanged<TaskIcon>? onIcon,
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
    expect(
      find.byWidgetPredicate((w) => w is DotIcon && w.glyph == DotGlyphs.check),
      findsOneWidget,
    );
  });

  testWidgets('taps report the choice', (tester) async {
    TaskColor? color;
    TaskIcon? icon;
    await tester.pumpWidget(
      _picker(onColor: (c) => color = c, onIcon: (i) => icon = i),
    );
    await tester.tap(find.bySemanticsLabel('Rose'));
    await tester.tap(find.byTooltip('Camera'));
    expect(color, TaskColor.rose);
    expect(icon, TaskIcon.camera);
  });

  testWidgets('names exist for every colour and icon', (tester) async {
    await tester.pumpWidget(testApp(const SizedBox()));
    final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)));
    final colors = {for (final c in TaskColor.values) taskColorName(l10n, c)};
    final icons = {for (final i in TaskIcon.picker) taskIconName(l10n, i)};
    expect(colors, hasLength(TaskColor.values.length));
    expect(icons, hasLength(TaskIcon.picker.length));
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
