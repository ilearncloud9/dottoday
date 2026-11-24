import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/settings/panes/settings_pane_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../timeline/calendar/calendar_world.dart';

// Settings in two panes (docs/09 M20.7 part 5a; E-R2-11, ED-291; E-R2-18,
// ED-311; E-FullA-v2 "Web · Settings, two panes"; owner answers 5a).

const _ipad = Size(1180, 820);

Finder _pane(SettingsPane pane) =>
    find.byWidgetPredicate((w) => w is SettingsPaneScope && w.pane == pane);

Finder _inPane(SettingsPane pane, Finder f) =>
    find.descendant(of: _pane(pane), matching: f);

/// The row titled [title] in the list pane, as a screen reader hears it.
SemanticsNode _row(WidgetTester tester, String title) =>
    tester.getSemantics(_inPane(SettingsPane.list, find.text(title)).first);

/// Whether that row says it is selected.
bool _selected(WidgetTester tester, String title) =>
    isSemantics(isSelected: true).matches(_row(tester, title), {});

Future<GoRouter> _open(
  WidgetTester tester, {
  Size size = _ipad,
  UiLayout layout = UiLayout.full,
  String to = AppRoutes.settings,
}) async {
  final router = await pumpCalendar(tester, size: size, layout: layout);
  router.go(to);
  await tester.pumpAndSettle();
  return router;
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('iPad landscape: list beside Your day, tinted', (tester) async {
    final handle = tester.ensureSemantics();
    await _open(tester);
    expect(_pane(SettingsPane.list), findsOneWidget);
    expect(
      tester.getSize(_pane(SettingsPane.list)).width + DotSpace.hairline,
      DotSize.settingsListIos,
    );
    expect(_inPane(SettingsPane.detail, find.text('Your day')), findsWidgets);
    expect(_selected(tester, 'Your day'), isTrue);
    // The group page drops ‹ Settings in two panes (E-R2-11).
    expect(_inPane(SettingsPane.detail, find.text('Settings')), findsNothing);
    handle.dispose();
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('picking a group swaps the detail; the list stays', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final router = await _open(tester);
    await tester.tap(_inPane(SettingsPane.list, find.text('Appearance')));
    await tester.pumpAndSettle();
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      AppRoutes.settingsPage(SettingsPage.appearance),
    );
    expect(_selected(tester, 'Appearance'), isTrue);
    expect(_selected(tester, 'Your day'), isFalse);
    expect(_pane(SettingsPane.list), findsOneWidget);
    handle.dispose();
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('iPad: a sub-page pushes in the detail with ‹ Your day', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final router = await _open(
      tester,
      to: AppRoutes.settingsPage(SettingsPage.yourDay),
    );
    await tester.tap(
      _inPane(SettingsPane.detail, find.text('Wake Up and Wind Down')).first,
    );
    await tester.pumpAndSettle();
    expect(_selected(tester, 'Your day'), isTrue);
    final back = find.bySemanticsLabel(RegExp('^Back to Your day'));
    expect(_inPane(SettingsPane.detail, back), findsOneWidget);
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      AppRoutes.settingsPage(SettingsPage.yourDay),
    );
    handle.dispose();
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('Android tablet: 412 list, no ← in the detail', (tester) async {
    await _open(
      tester,
      size: const Size(1280, 800),
      to: AppRoutes.settingsPage(SettingsPage.wakeWindDown),
    );
    expect(
      tester.getSize(_pane(SettingsPane.list)).width + DotSpace.hairline,
      DotSize.settingsListAndroid,
    );
    expect(
      _inPane(SettingsPane.detail, find.byType(IconButton)).evaluate().where(
        (e) => (e.widget as IconButton).tooltip?.startsWith('Back') ?? false,
      ),
      isEmpty,
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('Mac: 360 list', (tester) async {
    await _open(tester, size: const Size(1280, 800));
    expect(
      tester.getSize(_pane(SettingsPane.list)).width + DotSpace.hairline,
      DotSize.settingsListWide,
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('medium width stacks, as on phones', (tester) async {
    await _open(tester, size: const Size(820, 1180));
    expect(_pane(SettingsPane.list), findsNothing);
    expect(find.text('Search settings'), findsWidgets);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('Minimal: short list, Account and sync open and tinted', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _open(tester, layout: UiLayout.minimal);
    expect(_selected(tester, 'Account and sync'), isTrue);
    expect(_inPane(SettingsPane.detail, find.text('Account')), findsWidgets);
    handle.dispose();
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('Minimal: Everything else swaps the list to the full root', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final router = await _open(tester, layout: UiLayout.minimal);
    await tester.tap(_inPane(SettingsPane.list, find.text('Everything else…')));
    await tester.pumpAndSettle();
    expect(_inPane(SettingsPane.list, find.text('Planning')), findsOneWidget);
    expect(_selected(tester, 'Your day'), isTrue);
    await tester.tap(_inPane(SettingsPane.list, find.text('Planning')));
    await tester.pumpAndSettle();
    expect(_inPane(SettingsPane.list, find.text('Planning')), findsOneWidget);
    expect(_selected(tester, 'Planning'), isTrue);
    // ‹ Settings goes back to the short list.
    // The first "Settings" in the pane is ‹ Settings, over the title.
    await tester.tap(_inPane(SettingsPane.list, find.text('Settings')).first);
    await tester.pumpAndSettle();
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      AppRoutes.settings,
    );
    expect(_inPane(SettingsPane.list, find.text('Planning')), findsNothing);
    handle.dispose();
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
