import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/data/thinking/thinking_settings.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_status.dart';
import 'package:dottoday/features/settings/pages/thinking_status_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/test_app.dart';

// Settings › Privacy › Help with thinking (docs/09 M14.2): the status and
// its next step; Open Settings only where the OS has a link, and on
// iPhone the note that it opens Dottoday's own page.

Future<List<ThinkingVendor>> _pump(
  WidgetTester tester,
  ThinkingAvailability a,
  ThinkingVendor v, {
  ThemeMode mode = ThemeMode.light,
}) async {
  final opened = <ThinkingVendor>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        thinkingStatusProvider.overrideWith(
          (ref) async => ThinkingStatus(availability: a, vendor: v),
        ),
        thinkingSettingsOpenerProvider.overrideWithValue((vendor) async {
          opened.add(vendor);
          return true;
        }),
      ],
      child: testApp(
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: ThinkingStatusBlock(),
          ),
        ),
        themeMode: mode,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return opened;
}

void main() {
  testWidgets('iPhone, Apple Intelligence off: step, button, note', (
    tester,
  ) async {
    final opened = await _pump(
      tester,
      ThinkingAvailability.notEnabled,
      ThinkingVendor.appleIos,
    );
    expect(find.textContaining('iPhone Settings ›'), findsOneWidget);
    expect(find.textContaining("Opens Dottoday's page"), findsOneWidget);
    await tester.tap(find.text('Open Settings'));
    expect(opened, [ThinkingVendor.appleIos]);
  });

  testWidgets('Mac, Apple Intelligence off: System Settings, no note', (
    tester,
  ) async {
    final opened = await _pump(
      tester,
      ThinkingAvailability.notEnabled,
      ThinkingVendor.appleMac,
    );
    expect(find.textContaining('System Settings ›'), findsOneWidget);
    expect(find.textContaining("Opens Dottoday's page"), findsNothing);
    await tester.tap(find.text('Open Settings'));
    expect(opened, [ThinkingVendor.appleMac]);
  });

  for (final (a, v, text) in [
    (
      ThinkingAvailability.downloadable,
      ThinkingVendor.google,
      'Gemini Nano can be downloaded',
    ),
    (
      ThinkingAvailability.downloading,
      ThinkingVendor.appleIos,
      'Apple Intelligence is getting ready',
    ),
    (
      ThinkingAvailability.downloadable,
      ThinkingVendor.chrome,
      'This browser can download',
    ),
    (ThinkingAvailability.notEligible, ThinkingVendor.google, "can't run"),
    (ThinkingAvailability.available, ThinkingVendor.chrome, 'built-in model'),
  ]) {
    testWidgets('${v.name} × ${a.name}: no Open Settings', (tester) async {
      await _pump(tester, a, v);
      expect(find.textContaining(text), findsOneWidget);
      expect(find.text('Open Settings'), findsNothing);
    });
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('meets a11y guidelines (${mode.name})', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        ThinkingAvailability.notEnabled,
        ThinkingVendor.appleIos,
        mode: mode,
      );
      await expectA11yGuidelines(tester);
      handle.dispose();
    });
  }
}
