import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:dottoday/app_shell.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/shared/navigation/dot_rail.dart';
import 'package:dottoday/shared/navigation/dot_shell.dart';
import 'package:dottoday/shared/navigation/dot_sidebar.dart';
import 'package:dottoday/shared/navigation/material_nav_bar.dart';
import 'package:dottoday/shared/navigation/pill_tab_bar.dart';
import 'package:dottoday/shared/navigation/tablet_shells.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
  testWidgets('iPhone compact: pill bar with 3 tabs and the add dot; '
      'Settings is behind the profile, not a tab (ED-238)', (tester) async {
    await _size(tester, 390);
    await tester.pumpWidget(_shell());
    expect(find.byType(PillTabShell), findsOneWidget);
    expect(_order(tester, find.byType(PillTabShell)), [
      'Today',
      'Inbox',
      'Search',
    ]);
    expect(find.bySemanticsLabel('Add a task'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('Android compact: the floating toolbar 24 above the bottom, '
      'the + beside it (ED-125)', (tester) async {
    await _size(tester, 412, 892);
    await tester.pumpWidget(_shell());
    expect(find.byType(MaterialBarShell), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Week'), findsNothing);
    final add = tester.getRect(find.byTooltip('Add a task'));
    final today = tester.getRect(find.text('Today'));
    expect(add.right, 412 - 16);
    expect(add.left, greaterThan(today.right));
    expect(892 - add.bottom, 32);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('medium on Android and the web: the rail, its menu opens the '
      'drawer with every place (E-R2-1)', (tester) async {
    await _size(tester, 700);
    await tester.pumpWidget(_shell());
    expect(find.byType(DotRailShell), findsOneWidget);
    expect(find.text('Week'), findsNothing);
    expect(find.byTooltip('Add a task'), findsOneWidget);
    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Drawer), matching: find.text('Settings')),
      findsOneWidget,
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('iPad at medium: top tabs without Settings; the sidebar button '
      'shows every place, Settings at the foot (E-R2-1 1b, 1c)', (
    tester,
  ) async {
    await _size(tester, 820, 1180);
    await tester.pumpWidget(_shell());
    expect(find.byType(TopTabsShell), findsOneWidget);
    expect(find.text('Settings'), findsNothing);
    expect(find.byTooltip('Add a task'), findsOneWidget);
    await tester.tap(find.byTooltip('Show sidebar'));
    await tester.pumpAndSettle();
    expect(_order(tester, find.byType(Drawer)), [
      'Today',
      'Inbox',
      'Search',
      'Settings',
    ]);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('expanded: the sidebar of places, Settings at its foot; it '
      'folds to the rail and back (ED-267)', (tester) async {
    await _size(tester, 1280);
    await tester.pumpWidget(_shell());
    expect(find.byType(SidebarShell), findsOneWidget);
    expect(_order(tester, find.byType(DotSidebar)), [
      'Today',
      'Inbox',
      'Week',
      'Search',
      'Settings',
    ]);
    expect(find.byTooltip('Add a task'), findsNothing);
    await tester.tap(find.byTooltip('Hide sidebar'));
    await tester.pumpAndSettle();
    expect(find.byType(DotRailShell), findsOneWidget);
    await tester.tap(find.byTooltip('Show sidebar'));
    await tester.pumpAndSettle();
    expect(find.byType(DotSidebar), findsOneWidget);
  }, variant: TargetPlatformVariant.all());

  testWidgets('a foldable half open on a table gets the phone layout '
      '(ED-334)', (tester) async {
    await _size(tester, 841, 760);
    tester.view.displayFeatures = [
      const DisplayFeature(
        bounds: Rect.fromLTRB(0, 380, 841, 380),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.postureHalfOpened,
      ),
    ];
    addTearDown(tester.view.resetDisplayFeatures);
    await tester.pumpWidget(_shell());
    expect(find.byType(MaterialBarShell), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('nothing crosses a hinge with a gap (ED-334)', (tester) async {
    await _size(tester, 1114, 705);
    tester.view.displayFeatures = [
      const DisplayFeature(
        bounds: Rect.fromLTRB(540, 0, 574, 705),
        type: DisplayFeatureType.hinge,
        state: DisplayFeatureState.postureFlat,
      ),
    ];
    addTearDown(tester.view.resetDisplayFeatures);
    await tester.pumpWidget(_shell(body: const ColoredBox(color: Colors.red)));
    final body = tester.getRect(find.byType(ColoredBox).last);
    expect(body.right <= 540 || body.left >= 574, isTrue);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

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

    testWidgets('Android: the floating toolbar shows the count and says it '
        'with the place', (tester) async {
      final semantics = tester.ensureSemantics();
      await _size(tester, 412);
      await tester.pumpWidget(_shell(inbox: 2));
      expect(
        find.descendant(
          of: find.byType(MaterialBarShell),
          matching: find.byType(Badge),
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Inbox, 2 tasks'), findsOneWidget);
      semantics.dispose();
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  });

  testWidgets('taps map back to the full destination list', (tester) async {
    await _size(tester, 390);
    final taps = <int>[];
    await tester.pumpWidget(_shell(onSelect: taps.add));
    await tester.tap(find.text('Search'));
    await tester.tap(find.text('Inbox'));
    expect(taps, [3, 1]);
  });

  testWidgets('Week selected at phone width lights no tab', (tester) async {
    await _size(tester, 390);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_shell(selected: 2));
    for (final l in ['Today', 'Inbox', 'Search']) {
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

  for (final width in [700.0, 1280.0]) {
    testWidgets('the rail add button opens Add on a mouse click ($width)', (
      tester,
    ) async {
      await _size(tester, width);
      // A mouse: the Mac (an Android tablet's + opens its menu, E-R2-3).
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        var added = 0;
        await tester.pumpWidget(
          testApp(
            Builder(
              builder: (context) => DotShell(
                destinations: shellDestinations(context.l10n),
                selected: 0,
                onSelect: (_) {},
                onAdd: () => added++,
                addLabel: context.l10n.quickAddTooltip,
                addAtEveryWidth: true,
                body: const SizedBox.expand(),
              ),
            ),
          ),
        );
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(find.byTooltip('Add a task')));
        await tester.pump();
        await mouse.down(tester.getCenter(find.byTooltip('Add a task')));
        await mouse.up();
        await tester.pumpAndSettle();
        expect(added, 1);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }
}
