import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/look/recent_icons.dart';
import 'package:dottoday/shared/dot/colour_icon_block.dart';
import 'package:dottoday/shared/pickers/task_icon_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';

class _Recent extends RecentIcons {
  @override
  Future<List<String>> build() async => const [];

  @override
  Future<void> use(String iconKey) async {}
}

Widget _block({
  ValueChanged<TaskColor>? onColor,
  ValueChanged<TaskIcon>? onIcon,
  ThemeMode mode = ThemeMode.light,
}) => UncontrolledProviderScope(
  container: ProviderContainer(
    overrides: [
      ...timelineOverrides(now: DateTime.utc(2026, 11, 20, 9)),
      recentIconsProvider.overrideWith(_Recent.new),
    ],
  ),
  child: testApp(
    Scaffold(
      body: ColourIconBlock(
        color: TaskColor.coral,
        icon: TaskIcon.bag,
        onColor: onColor ?? (_) {},
        onIcon: onIcon ?? (_) {},
      ),
    ),
    themeMode: mode,
  ),
);

/// The icon library alone (Search's "with icon" filter): the full picker's
/// colour mode is Colour and icon now (M19.4 part 4c-3).
Widget _library({ThemeMode mode = ThemeMode.light}) => testApp(
  Scaffold(
    body: Builder(
      builder: (context) => TextButton(
        onPressed: () => showTaskIconPicker(context: context, title: 'Icon'),
        child: const Text('open'),
      ),
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

  testWidgets('taps report colour and quick icon', (tester) async {
    final colors = <TaskColor>[];
    final icons = <TaskIcon>[];
    await tester.pumpWidget(_block(onColor: colors.add, onIcon: icons.add));
    await tester.tap(find.bySemanticsLabel('Teal'));
    await tester.tap(find.bySemanticsLabel('Cart'));
    await tester.pumpAndSettle();
    expect(colors, [TaskColor.teal]);
    expect(icons, [TaskIcon.cart]);
  });

  testWidgets('⋯ opens Colour and icon; its picks land as made (4c-3)', (
    tester,
  ) async {
    final colors = <TaskColor>[];
    final icons = <TaskIcon>[];
    await tester.pumpWidget(_block(onColor: colors.add, onIcon: icons.add));
    await tester.ensureVisible(find.byTooltip('All icons'));
    await tester.tap(find.byTooltip('All icons'));
    await tester.pumpAndSettle();
    expect(find.text('Colour and icon'), findsOneWidget);
    await tester.ensureVisible(find.bySemanticsLabel('Plum').last);
    await tester.tap(find.bySemanticsLabel('Plum').last);
    await tester.pump();
    expect(colors, [TaskColor.plum], reason: 'before Done');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(icons, isEmpty);
  });

  testWidgets('the library is grouped by category and searchable', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_library());
    await tester.tap(find.text('open'));
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

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('the library sheet meets a11y guidelines (${mode.name})', (
      tester,
    ) async {
      await tester.pumpWidget(_library(mode: mode));
      await tester.tap(find.text('open'));
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
