import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:dottoday/shared/navigation/glass_capsule.dart';
import 'package:dottoday/shared/navigation/settings_button.dart';
import 'package:dottoday/shared/sync/sync_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/today_harness.dart';

/// Today in Full as E-Phones draws it (M19.1): the top row's Sync and
/// profile (one glass capsule on iPhone, bare on Android), the week strip
/// per platform with no completion dots, the thread straight on the page,
/// landscape's strip folded into the title row, and phones' /week.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  Future<void> onIphone(Future<void> Function() body) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  testWidgets('iPhone: Sync and the profile share one glass capsule', (
    tester,
  ) async {
    await onIphone(() async {
      await pumpToday(tester);
      final capsule = find.byType(GlassCapsule);
      expect(capsule, findsOneWidget);
      expect(
        find.descendant(of: capsule, matching: find.byType(SyncButton)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: capsule, matching: find.byType(SettingsButton)),
        findsOneWidget,
      );
      // The strip: one letter per day, no "Wed".
      expect(find.text('W'), findsOneWidget);
      expect(find.text('Wed'), findsNothing);
    });
  });

  testWidgets('Android: Sync and the profile bare; "Wed" over the date', (
    tester,
  ) async {
    await pumpToday(tester);
    expect(find.byType(GlassCapsule), findsNothing);
    expect(find.byType(SyncButton), findsOneWidget);
    expect(find.byType(SettingsButton), findsOneWidget);
    expect(find.text('Wed'), findsOneWidget);
  });

  testWidgets('no completion dot in the strip, no raised sheet', (
    tester,
  ) async {
    await pumpToday(tester);
    expect(
      find.descendant(
        of: find.byType(WeekStrip),
        matching: find.byType(CompletionDot),
      ),
      findsNothing,
    );
    expect(find.byType(PullHandle), findsNothing);
  });

  testWidgets('Sync says its state in words and opens the Sync sheet', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpToday(tester);
    final sync = tester.getSemantics(find.byType(SyncButton));
    expect(sync.label, 'Sync');
    expect(sync.value, isNotEmpty);
    handle.dispose();
  });

  testWidgets('landscape: the strip folds into the title row', (tester) async {
    await pumpToday(tester, size: const Size(874, 402));
    expect(find.byType(WeekStrip), findsNothing);
    final title = tester.getCenter(
      find.textContaining('Wed, Oct 21', findRichText: true),
    );
    final numbers = tester.getCenter(
      find.textContaining(RegExp(r'^\d+ of \d+ done · ')),
    );
    expect((numbers.dy - title.dy).abs(), lessThan(12));
    expect(numbers.dx, greaterThan(title.dx));
  });
}
