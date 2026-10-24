import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/editor/task_editor.dart';
import 'package:dottoday/features/timeline/task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/a11y.dart';
import '../../support/timeline_fakes.dart';
import '../settings/settings_harness.dart' show FakeLinkLauncher;

// Links in an imported event's notes open in the browser (docs/02 F5,
// docs/09 M7.2, R-02 "links in events are plain text").

final _now = DateTime.utc(2026, 10, 21, 6);

/// An imported meeting whose description carried a video link.
final _meeting = Occurrence(
  id: 'imported-1',
  userId: testUserId,
  title: 'Design review',
  notes: 'Agenda in the doc.\n\nhttps://meet.example.com/abc-def',
  colorKey: 'sky',
  startUtc: DateTime.utc(2026, 10, 21, 8),
  tzId: 'Europe/Berlin',
  durationMin: 45,
  source: OccurrenceSource.calendar,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

Future<FakeLinkLauncher> _pump(
  WidgetTester tester,
  Widget home, {
  ThemeMode mode = ThemeMode.light,
  double width = 390,
}) async {
  tester.view
    ..physicalSize = Size(width, 1400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final links = FakeLinkLauncher();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...timelineOverrides(
          now: _now,
          occurrences: FakeOccurrenceRepository([_meeting]),
        ),
        linkLauncherProvider.overrideWithValue(links),
      ],
      child: MaterialApp(
        theme: DotTheme.light(),
        darkTheme: DotTheme.dark(),
        themeMode: mode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return links;
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('the sheet lists the link and a tap opens it', (tester) async {
    final links = await _pump(tester, TaskScreen(id: _meeting.id));
    expect(find.text('LINKS'), findsOneWidget);
    final row = find.text('https://meet.example.com/abc-def');
    expect(row, findsOneWidget);
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(links.opened, [Uri.parse('https://meet.example.com/abc-def')]);
  });

  testWidgets('a link the browser cannot open says so', (tester) async {
    final links = await _pump(tester, TaskScreen(id: _meeting.id));
    links.handled = false;
    await tester.tap(find.text('https://meet.example.com/abc-def'));
    await tester.pump();
    expect(find.text("Couldn't open that link"), findsOneWidget);
  });

  testWidgets('the editor shows the links under the notes', (tester) async {
    final links = await _pump(
      tester,
      Scaffold(body: TaskEditor(id: _meeting.id)),
    );
    await tester.scrollUntilVisible(
      find.text('https://meet.example.com/abc-def'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('https://meet.example.com/abc-def'));
    await tester.pumpAndSettle();
    expect(links.opened, hasLength(1));
  });

  testWidgets('a screen reader hears a link to the host', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, TaskScreen(id: _meeting.id));
    expect(
      tester.getSemantics(
        find.bySemanticsLabel('https://meet.example.com/abc-def'),
      ),
      isSemantics(
        isLink: true,
        hasTapAction: true,
        label: 'https://meet.example.com/abc-def',
        hint: 'Open meet.example.com in the browser',
      ),
    );
    semantics.dispose();
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final (name, width) in [('compact', 390.0), ('expanded', 1280.0)]) {
      testWidgets('meets a11y guidelines: ${mode.name} $name', (tester) async {
        await _pump(
          tester,
          TaskScreen(id: _meeting.id),
          mode: mode,
          width: width,
        );
        await expectA11yGuidelines(tester);
      });
    }
  }
}
