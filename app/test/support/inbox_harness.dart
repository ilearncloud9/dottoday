import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/inbox/inbox_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sample_inbox.dart';
import 'test_l10n.dart';
import 'timeline_fakes.dart';

/// 11:00 in Berlin on the demo day: Design review ends 11:15 and Lunch
/// starts 11:30, so the next free slot fits only the 15-min call.
final inboxTestNow = DateTime.utc(2026, 10, 21, 9);

/// Pumps [home] (the Inbox by default) over the demo day's timed tasks and
/// [inbox] (the sample Inbox) at [inboxTestNow], 1 px per pt.
Future<FakeOccurrenceRepository> pumpInbox(
  WidgetTester tester, {
  List<Occurrence>? inbox,
  Size size = const Size(390, 1200),
  ThemeMode mode = ThemeMode.light,
  Widget home = const InboxScreen(),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeOccurrenceRepository([
    // The demo day's timed tasks; its own inbox items would crowd these.
    for (final o in demoDayRows(DateTime(2026, 10, 21)))
      if (o.startUtc != null) o,
    ...inbox ?? sampleInbox(),
  ]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(
        now: inboxTestNow,
        occurrences: repo,
        profile: testProfile(settings: const Settings(use24h: false)),
      ),
      child: MaterialApp(
        theme: DotTheme.light(),
        darkTheme: DotTheme.dark(),
        themeMode: mode,
        localizationsDelegates: testL10nDelegates,
        supportedLocales: testL10nLocales,
        locale: testL10nLocale,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}
