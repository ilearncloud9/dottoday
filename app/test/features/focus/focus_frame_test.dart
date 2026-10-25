import 'package:dottoday/core/editing/focus_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/focus/focus_screen.dart';
import 'package:dottoday/features/focus/focus_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/focus_fakes.dart';
import '../../support/timeline_fakes.dart';

// Focus on Mac/web (docs/09 M10.5, docs/10 §4): in the content area with
// the rest of the shell kept (here, the tab content stays mounted under
// it), Esc to leave; nothing changes at the phone widths.

final _date = DateTime(2026, 10, 21);

class _Tab extends StatefulWidget {
  const _Tab();

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  static var builds = 0;

  @override
  void initState() {
    super.initState();
    builds++;
  }

  @override
  Widget build(BuildContext context) => const Text('Tab content');
}

Future<ProviderContainer> _pump(WidgetTester tester, double width) async {
  tester.view
    ..physicalSize = Size(width, 1200)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final rows = demoDayRows(_date);
  late ProviderContainer container;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...timelineOverrides(
          now: DateTime.utc(2026, 10, 21, 7, 22),
          occurrences: FakeOccurrenceRepository(rows),
          subtasks: FakeSubtaskRepository(demoDaySubtasks(_date)),
          profile: testProfile(settings: const Settings(use24h: false)),
        ),
        ...focusOverrides(deepWork: FakeDeepWork(), sounds: FakeSoundPlayer()),
      ],
      child: MaterialApp(
        theme: DotTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const Scaffold(body: FocusFrame(child: _Tab()));
          },
        ),
      ),
    ),
  );
  await tester.pump();
  addTearDown(() => tester.pumpWidget(const SizedBox()));
  return container;
}

String _deepId() =>
    demoDayRows(_date).firstWhere((o) => o.title == 'Deep work: roadmap').id;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('expanded: Focus in the content area, tab kept, Esc leaves', (
    tester,
  ) async {
    final c = await _pump(tester, 1280);
    final builds = _TabState.builds;
    c.read(focusTaskProvider.notifier).open(_deepId());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(FocusView), findsOneWidget);
    expect(find.text('Tab content'), findsNothing, reason: 'under Focus');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(c.read(focusTaskProvider), isNull);
    expect(find.text('Tab content'), findsOneWidget);
    expect(_TabState.builds, builds, reason: 'never remounted');
  });

  testWidgets('phone widths: the frame shows the tab (Focus is a route)', (
    tester,
  ) async {
    final c = await _pump(tester, 390);
    c.read(focusTaskProvider.notifier).open(_deepId());
    await tester.pump();
    expect(find.byType(FocusView), findsNothing);
    expect(find.text('Tab content'), findsOneWidget);
  });
}
