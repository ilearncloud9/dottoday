import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import 'settings_harness.dart';

// Settings › Appearance (M20.7 part 3; E-G3-9b, ED-161, ED-221).

void main() {
  setUpAll(tz_data.initializeTimeZones);
  final appearance = AppRoutes.settingsPage(SettingsPage.appearance);

  test('the nearest built-in accent goes beside a custom colour', () {
    expect(nearestAccent(AppColourSuggestion.pine.colour), DotAccent.teal);
    expect(nearestAccent(AppColourSuggestion.blush.colour), DotAccent.coral);
    expect(nearestAccent(DotAccent.violet.light), DotAccent.violet);
  });

  test('a custom App colour themes the app, its text derived for 4.5:1', () {
    const sage = Color(0xFF7A9E4A);
    for (final b in Brightness.values) {
      final colors = DotTheme.custom(b, sage).extension<DotTheme>()!.colors;
      expect(colors.accent, sage, reason: '$b: the stored colour, unchanged');
      for (final ground in [colors.surface, colors.raised]) {
        expect(contrastRatio(colors.accentInk, ground), greaterThan(4.5));
      }
    }
  });

  testWidgets('Edit palette: a colour from the grid is the App colour', (
    tester,
  ) async {
    final h = await pumpSettings(tester, location: appearance);
    await tester.ensureVisible(find.text('Edit palette'));
    await tester.tap(find.text('Edit palette'));
    await tester.pumpAndSettle();
    expect(find.text('App colour'), findsWidgets);
    await tester.tap(find.bySemanticsLabel('Plum').last);
    // Written once the pick settles.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    final profile = await storedProfile(h);
    expect(profile.accentHex, isNotNull);
    expect(
      profile.settings.accent,
      nearestAccent(parseHex(profile.accentHex!)!).key,
    );
    await expectA11yGuidelines(tester);
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();
    expect(find.text('Edit palette'), findsOneWidget);
  });

  testWidgets('Layout: Less switches to minimal at once', (tester) async {
    final h = await pumpSettings(tester, location: appearance);
    expect(h.container.read(layoutPolicyProvider).isMinimal, isFalse);
    await tester.tap(find.text('Less'));
    await tester.pumpAndSettle();
    expect(h.container.read(layoutPolicyProvider).isMinimal, isTrue);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('a11y ${mode.name}', (tester) async {
      await pumpSettings(tester, location: appearance, mode: mode);
      await expectA11yGuidelines(tester);
    });
  }
}
