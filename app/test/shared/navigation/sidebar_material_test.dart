import 'package:dottoday/app_shell.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/theme/tokens.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/dot_sidebar.dart';
import 'package:dottoday/shared/navigation/tablet_shells.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

Widget _shell({required bool vibrant, ThemeMode mode = ThemeMode.light}) =>
    testApp(
      Builder(
        builder: (context) => DotShell(
          destinations: shellDestinations(context.l10n, inbox: 0),
          selected: 0,
          onSelect: (_) {},
          onAdd: () {},
          addLabel: context.l10n.quickAddTooltip,
          vibrantSidebar: vibrant,
          body: const SizedBox.expand(),
        ),
      ),
      themeMode: mode,
    );

Future<void> _wide(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(1280, 800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// The colour the sidebar paints behind its rows.
Color _sidebarFill(WidgetTester tester) => tester
    .widget<ColoredBox>(
      find
          .descendant(
            of: find.byType(DotSidebar),
            matching: find.byType(ColoredBox),
          )
          .first,
    )
    .color;

Color _shellFill(WidgetTester tester) => tester
    .widget<Scaffold>(
      find
          .descendant(
            of: find.byType(SidebarShell),
            matching: find.byType(Scaffold),
          )
          .first,
    )
    .backgroundColor!;

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('vibrant: the sidebar paints only its tint and the content '
        'stays opaque (${mode.name}, ED-130, ED-176)', (tester) async {
      await _wide(tester);
      await tester.pumpWidget(_shell(vibrant: true, mode: mode));
      final c = DotTheme.of(tester.element(find.byType(DotSidebar))).colors;
      expect(_sidebarFill(tester), c.sidebarTint);
      expect(_shellFill(tester), Colors.transparent);
      final content = tester.widget<ColoredBox>(
        find
            .ancestor(
              of: find.byType(SizedBox).last,
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(content.color, c.ground);
      expect(content.color.a, 1);
    });
  }

  test('the tints are the approved ones: #EFE7DB at 35 % light, #3B2F2A '
      'at 30 % dark', () {
    expect(DotPalette.light.sidebarTint, const Color(0x59EFE7DB));
    expect(DotPalette.dark.sidebarTint, const Color(0x4D3B2F2A));
  });

  testWidgets('not vibrant (Reduce Transparency, Increase Contrast, other '
      'targets): the sidebar is solid', (tester) async {
    await _wide(tester);
    await tester.pumpWidget(_shell(vibrant: false));
    final c = DotTheme.of(tester.element(find.byType(DotSidebar))).colors;
    expect(_sidebarFill(tester), c.canvas);
    expect(_sidebarFill(tester).a, 1);
  });

  Color labelColor(WidgetTester tester) => tester
      .widget<Text>(
        find.descendant(
          of: find.byType(DotSidebar),
          matching: find.text('Today'),
        ),
      )
      .style!
      .color!;

  testWidgets('dark Mac: the current place reads in the primary text '
      '(ED-176)', (tester) async {
    await _wide(tester);
    await tester.pumpWidget(_shell(vibrant: true, mode: ThemeMode.dark));
    final c = DotTheme.of(tester.element(find.byType(DotSidebar))).colors;
    expect(labelColor(tester), c.ink);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('light Mac keeps the accent text', (tester) async {
    await _wide(tester);
    await tester.pumpWidget(_shell(vibrant: true));
    final c = DotTheme.of(tester.element(find.byType(DotSidebar))).colors;
    expect(labelColor(tester), c.accentText);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets(
    'other targets keep the accent text in dark',
    (tester) async {
      await _wide(tester);
      await tester.pumpWidget(_shell(vibrant: false, mode: ThemeMode.dark));
      final c = DotTheme.of(tester.element(find.byType(DotSidebar))).colors;
      expect(labelColor(tester), c.accentText);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.iOS,
      TargetPlatform.android,
    }),
  );
}
