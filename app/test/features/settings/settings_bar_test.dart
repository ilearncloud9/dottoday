import 'dart:async';

import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../timeline/calendar/calendar_world.dart';

// The phone's bottom bar on every Settings page, no tab selected, and not
// over pull-ups (ED-234, ED-238): checked in the whole app, page by page.

void main() {
  setUpAll(tz_data.initializeTimeZones);

  /// The bar's Add, as a finger reaches it: a labelled button on iPhone,
  /// a tooltip on Android's toolbar.
  Finder add() => find
      .byWidgetPredicate(
        (w) =>
            (w is Semantics && w.properties.label == 'Add a task') ||
            (w is Tooltip && w.message == 'Add a task'),
      )
      .hitTestable();

  /// A tab of the bar marked selected (Settings is not a tab, so none).
  /// Page content can be selected too (Appearance's theme), so only the
  /// bar's own places count.
  const tabs = ['Now', 'Today', 'Inbox', 'Calendar', 'Search'];
  Finder selectedTab() => find.byWidgetPredicate(
    (w) =>
        w is Semantics &&
        w.properties.selected == true &&
        tabs.any((tab) => w.properties.label?.startsWith(tab) ?? false),
  );

  for (final (name, platform, layout) in [
    ('iPhone', TargetPlatform.iOS, UiLayout.full),
    ('Android', TargetPlatform.android, UiLayout.full),
    ('iPhone, Minimal', TargetPlatform.iOS, UiLayout.minimal),
  ]) {
    testWidgets('$name: the bar on Settings and every page under it', (
      t,
    ) async {
      final router = await pumpCalendar(
        t,
        size: const Size(390, 844),
        layout: layout,
      );
      // The check can see a selected tab: Today's, on Today.
      router.go(AppRoutes.today);
      await t.pumpAndSettle();
      expect(selectedTab(), findsOneWidget, reason: 'Today');
      router.go(AppRoutes.settings);
      await t.pumpAndSettle();
      expect(add(), findsOneWidget, reason: 'Settings');
      expect(selectedTab(), findsNothing, reason: 'Settings');
      for (final page in SettingsPage.values) {
        router.go(AppRoutes.settingsPage(page));
        await t.pumpAndSettle();
        expect(add(), findsOneWidget, reason: page.name);
        expect(selectedTab(), findsNothing, reason: page.name);
      }
    }, variant: TargetPlatformVariant.only(platform));
  }

  testWidgets('a pull-up covers the bar; closing it shows it again', (t) async {
    final router = await pumpCalendar(t, size: const Size(390, 844));
    router.go(AppRoutes.settings);
    await t.pumpAndSettle();
    unawaited(router.push(AppRoutes.settingsPage(SettingsPage.help)));
    await t.pumpAndSettle();
    expect(add(), findsOneWidget);
    await t.tap(find.widgetWithText(FilledButton, 'Send feedback'));
    await t.pumpAndSettle();
    expect(find.text('Write email'), findsOneWidget);
    expect(add(), findsNothing, reason: 'the sheet is over the bar');
    await t.tapAt(const Offset(195, 40));
    await t.pumpAndSettle();
    expect(add(), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
