import 'package:dottoday/app_shell.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/shared/navigation/dot_rail.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/material_nav_bar.dart';
import 'package:dottoday/shared/navigation/pill_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

Widget _shell({
  int selected = 0,
  int inbox = 0,
  ValueChanged<int>? onSelect,
  VoidCallback? onAdd,
  Widget? body,
  ThemeMode mode = ThemeMode.light,
}) => testApp(
  Builder(
    builder: (context) => DotShell(
      destinations: shellDestinations(context.l10n, inbox: inbox),
      selected: selected,
      onSelect: onSelect ?? (_) {},
      onAdd: onAdd ?? () {},
      addLabel: context.l10n.quickAddTooltip,
      body: body ?? const SizedBox.expand(),
    ),
  ),
  themeMode: mode,
);

Future<void> _size(
  WidgetTester tester,
  double width, [
  double height = 800,
]) async {
  tester.view
    ..physicalSize = Size(width, height)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Labels of [within] in reading order: top to bottom, then start to end.
List<String> _order(WidgetTester tester, Finder within) {
  final found = <(double, double, String)>[];
  for (final label in ['Today', 'Inbox', 'Week', 'Search', 'Settings']) {
    final f = find.descendant(of: within, matching: find.text(label));
    if (!tester.any(f)) continue;
    final c = tester.getCenter(f.first);
    found.add((c.dy.roundToDouble(), c.dx, label));
  }
  found.sort(
    (a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2),
  );
  return [for (final f in found) f.$3];
}

void main() {
  testWidgets('iPhone compact: pill bar with 4 tabs and the add dot', (
    tester,
  ) async {
    await _size(tester, 390);
    await tester.pumpWidget(_shell());
    expect(find.byType(PillTabShell), findsOneWidget);
    expect(_order(tester, find.byType(PillTabShell)), [
      'Today',
      'Inbox',
      'Search',
      'Settings',
    ]);
    expect(find.bySemanticsLabel('Add task'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('Android compact: M3 NavigationBar + rounded-square FAB', (
    tester,
  ) async {
    await _size(tester, 412);
    await tester.pumpWidget(_shell());
    expect(find.byType(MaterialBarShell), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Week'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('medium: rail with the phone set and an add button', (
    tester,
  ) async {
    await _size(tester, 700);
    await tester.pumpWidget(_shell());
    expect(find.byType(DotRailShell), findsOneWidget);
    expect(find.text('Week'), findsNothing);
    expect(find.byTooltip('Add task'), findsOneWidget);
  });

  testWidgets('expanded: the same rail on every platform, Week included', (
    tester,
  ) async {
    await _size(tester, 1280);
    await tester.pumpWidget(_shell());
    expect(find.byType(DotRailShell), findsOneWidget);
    expect(_order(tester, find.byType(DotRailShell)), [
      'Today',
      'Inbox',
      'Week',
      'Search',
      'Settings',
    ]);
    expect(find.byTooltip('Add task'), findsNothing);
  }, variant: TargetPlatformVariant.all());

  group('Inbox badge (F3.3)', () {
    for (final (name, width, platform) in [
      ('iPhone compact', 390.0, TargetPlatform.iOS),
      ('medium', 700.0, TargetPlatform.android),
      ('expanded', 1280.0, TargetPlatform.macOS),
    ]) {
      testWidgets('$name: the count on the Inbox, said with the tab', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await _size(tester, width);
        await tester.pumpWidget(_shell(inbox: 3));
        expect(find.byType(Badge), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.bySemanticsLabel('Inbox, 3 tasks'), findsOneWidget);
        semantics.dispose();
      }, variant: TargetPlatformVariant.only(platform));
    }

    testWidgets('none when the Inbox is clear; 99+ past 99', (tester) async {
      await _size(tester, 390);
      await tester.pumpWidget(_shell());
      expect(find.byType(Badge), findsNothing);
      await tester.pumpWidget(_shell(inbox: 140));
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('Android: the Material bar shows and says it too', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _size(tester, 412);
      await tester.pumpWidget(_shell(inbox: 2));
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byType(Badge),
        ),
        findsOneWidget,
      );
      // NavigationBar merges the icon's badge text with the label.
      expect(find.bySemanticsLabel(RegExp(r'2\s+Inbox')), findsOneWidget);
      semantics.dispose();
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  });

  testWidgets('taps map back to the full destination list', (tester) async {
    await _size(tester, 390);
    final taps = <int>[];
    await tester.pumpWidget(_shell(onSelect: taps.add));
    await tester.tap(find.text('Search'));
    await tester.tap(find.text('Settings'));
    expect(taps, [3, 4]);
  });

  testWidgets('Week selected at phone width lights no tab', (tester) async {
    await _size(tester, 390);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_shell(selected: 2));
    for (final l in ['Today', 'Inbox', 'Search', 'Settings']) {
      expect(
        tester.getSemantics(find.bySemanticsLabel(l)),
        isSemantics(isSelected: false, isButton: true),
        reason: l,
      );
    }
    handle.dispose();
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('scrolled content clears the floating bar', (tester) async {
    await _size(tester, 390, 600);
    await tester.pumpWidget(
      _shell(
        body: ListView.builder(
          itemCount: 40,
          itemExtent: 48,
          itemBuilder: (_, i) => SizedBox(key: ValueKey('row$i')),
        ),
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -5000));
    await tester.pumpAndSettle();
    final last = tester.getRect(find.byKey(const ValueKey('row39')));
    final bar = tester.getRect(find.byType(PillTabShell).last);
    expect(last.bottom, lessThanOrEqualTo(bar.bottom - PillTabShell.height));
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  for (final (name, width, platform) in [
    ('iPhone', 390.0, TargetPlatform.iOS),
    ('Android', 412.0, TargetPlatform.android),
    ('medium', 700.0, TargetPlatform.android),
    ('expanded', 1280.0, TargetPlatform.macOS),
  ]) {
    testWidgets('$name shell meets a11y guidelines (light, dark)', (
      tester,
    ) async {
      await _size(tester, width);
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        // With the Inbox badge too (F3.3): its contrast and the tab's name.
        for (final inbox in [0, 12]) {
          await tester.pumpWidget(_shell(mode: mode, inbox: inbox));
          await tester.pumpAndSettle();
          await expectA11yGuidelines(tester);
        }
      }
    }, variant: TargetPlatformVariant.only(platform));
  }
}
