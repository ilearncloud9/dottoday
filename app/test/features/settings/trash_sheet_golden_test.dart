// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import 'settings_harness.dart';

/// Trash beside its boards (M20.10 part 2, ED-478): the E-R2-32 sheet on
/// iPhone and Android (rows in one list with "Deleted today · 30 days
/// left", Delete now in ink, Restore in the accent, Empty Trash centred),
/// the E-R2-30 centred dialog on the Mac with push buttons, and the
/// iPhone at 200 % text, where the actions go under the title.
Occurrence _gone(int n, String title, String colour, DateTime deleted) =>
    Occurrence(
      id: '0199f0c0-0000-7000-8000-00000000000$n',
      userId: testUserId,
      title: title,
      tzId: 'Europe/Berlin',
      durationMin: 30,
      colorKey: colour,
      createdAt: DateTime.utc(2026, 9),
      updatedAt: DateTime.utc(2026, 9),
      deletedAt: deleted,
    );

// The harness's now is 21 Oct 2026, 11:00 in Berlin.
final _rows = [
  _gone(1, 'Pick up parcel', 'mint', DateTime.utc(2026, 10, 21, 7)),
  _gone(2, 'Dentist', 'slate', DateTime.utc(2026, 10, 20, 15)),
  _gone(3, 'Old: book flights', 'sky', DateTime.utc(2026, 10, 12, 9)),
  _gone(4, 'Call the bank', 'amber', DateTime.utc(2026, 10, 9, 9)),
];

Future<void> _open(
  WidgetTester tester,
  Size size,
  TargetPlatform platform,
  ThemeMode mode,
) async {
  await pumpSettings(
    tester,
    rows: _rows,
    size: size,
    mode: mode,
    platform: platform,
    location: '/settings/dataPrivacy',
  );
  await tester.ensureVisible(find.text('Trash').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Trash').first);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });

  const phone = Size(390, 844);
  const wide = Size(1280, 800);
  final cases = [
    ('iphone', phone, TargetPlatform.iOS),
    ('android', phone, TargetPlatform.android),
    ('mac', wide, TargetPlatform.macOS),
  ];
  for (final (name, size, platform) in cases) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('trash $name ${mode.name}', (tester) async {
        await _open(tester, size, platform, mode);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/trash_${name}_${mode.name}.png'),
        );
      }, variant: TargetPlatformVariant.only(platform));
    }
  }

  testWidgets('trash iphone 200 % text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _open(tester, phone, TargetPlatform.iOS, ThemeMode.light);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/trash_iphone_t2.png'),
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
