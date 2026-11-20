@Tags(['golden'])
library;

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/look/colour_sampler.dart';
import 'package:dottoday/data/look/recent_icons.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/shared/pickers/look/look_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';
import 'look_popover_test.dart' show FakeSampler;

/// Colour and icon beyond phones (M19.4 part 4c-3): the Mac and web
/// popover (E-G3-9b, E-FullA-v2; ED-156) with Custom colour… open on
/// #F0A28E, light and dark; the iPad popover and the Android dialog
/// (E-R2-15, ED-298).
class _Recent extends RecentIcons {
  @override
  Future<List<String>> build() async => const ['book_open'];
}

void main() {
  setUpAll(tz_data.initializeTimeZones);
  setUpAll(loadAppFonts);

  Future<void> pump(WidgetTester tester, ThemeMode mode, Size size) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final profile = testProfile(
      settings: const Settings(use24h: false),
    ).copyWith(yourColours: const ['#E8A598', '#2E4A6B', '#000000']);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...timelineOverrides(
            now: DateTime.utc(2026, 11, 20, 9),
            profile: profile,
          ),
          recentIconsProvider.overrideWith(_Recent.new),
          colourSamplerProvider.overrideWithValue(FakeSampler()),
        ],
        child: testApp(
          Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(DotSpace.xxl),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showTaskLook(
                      context,
                      colour: TaskColor.indigo,
                      icon: TaskIcon.fromKey('deep_work'),
                      title: 'Deep work: roadmap',
                      onChanged: (_) {},
                    ),
                    child: const Text('Deep work: roadmap'),
                  ),
                ),
              ),
            ),
          ),
          themeMode: mode,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deep work: roadmap'));
    await tester.pumpAndSettle();
  }

  Future<void> on(TargetPlatform p, Future<void> Function() body) async {
    debugDefaultTargetPlatformOverride = p;
    debugDisableShadows = false;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
      debugDisableShadows = true;
    }
  }

  Future<void> shot(String name) => expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('golden: Mac popover, ${mode.name}', (tester) async {
      await on(TargetPlatform.macOS, () async {
        await pump(tester, mode, const Size(720, 900));
        await shot('look_popover_mac_${mode.name}');
        await tester.tap(find.text('Custom colour…'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '#F0A28E');
        await tester.pumpAndSettle();
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await shot('look_popover_custom_mac_${mode.name}');
      });
    });
  }

  testWidgets('golden: wide iPad popover, light', (tester) async {
    await on(TargetPlatform.iOS, () async {
      await pump(tester, ThemeMode.light, const Size(1180, 820));
      await shot('look_popover_ipad_light');
    });
  });

  testWidgets('golden: wide Android dialog, light', (tester) async {
    await on(TargetPlatform.android, () async {
      await pump(tester, ThemeMode.light, const Size(1280, 800));
      await shot('look_dialog_android_light');
    });
  });
}
