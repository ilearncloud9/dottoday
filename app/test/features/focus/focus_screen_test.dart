import 'package:dottoday/core/editing/focus_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/focus/focus_screen.dart';
import 'package:dottoday/features/focus/focus_view.dart';
import 'package:dottoday/shared/dot/focus_ring.dart';
import 'package:dottoday/shared/navigation/native_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/focus_fakes.dart';
import '../../support/timeline_fakes.dart';

// Focus (docs/09 M10.5; E-R2-9, ED-285): a route over the shell at every
// width, the tab underneath kept (never remounted); two columns on
// expanded windows, one below; the native navigation hides while it is
// up; Esc leaves.

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
      child: MaterialApp.router(
        theme: DotTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, _) => Consumer(
                builder: (context, ref, _) {
                  container = ProviderScope.containerOf(context);
                  return const Scaffold(body: _Tab());
                },
              ),
            ),
            GoRoute(
              path: '/focus/:id',
              builder: (_, state) =>
                  FocusScreen(id: state.pathParameters['id']!),
            ),
          ],
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

/// Opens Focus on Deep work as the app does, from the tab.
Future<void> _open(WidgetTester tester) async {
  openFocus(tester.element(find.text('Tab content')), _deepId());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('expanded: the whole window in two columns, the tab kept, '
      'the native navigation hidden, Esc leaves', (tester) async {
    final c = await _pump(tester, 1280);
    final builds = _TabState.builds;
    await _open(tester);
    expect(find.byType(FocusView), findsOneWidget);
    expect(c.read(focusTaskProvider), _deepId());
    expect(NativeBarObserver.wholeWindow.value, 1);
    // The ring on the start side, Done on the end side (ED-285).
    final ring = tester.getCenter(find.byType(FocusRing));
    final done = tester.getCenter(find.text('Done'));
    expect(ring.dx, lessThan(640));
    expect(done.dx, greaterThan(640));
    // The ring is one image with a spoken label: the time left, said once
    // (E-R2-9 accessibility).
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel(RegExp(r'min left$')), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp(r'min left$'))),
      matchesSemantics(isImage: true, label: '98 min left'),
    );
    semantics.dispose();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(c.read(focusTaskProvider), isNull);
    expect(NativeBarObserver.wholeWindow.value, 0);
    expect(find.text('Tab content'), findsOneWidget);
    expect(_TabState.builds, builds, reason: 'never remounted');
  });

  testWidgets('phone widths: one column, the ring above Done', (tester) async {
    await _pump(tester, 390);
    await _open(tester);
    expect(find.byType(FocusView), findsOneWidget);
    final ring = tester.getCenter(find.byType(FocusRing));
    expect(ring.dx, closeTo(195, 1));
    expect(find.text('Done', skipOffstage: false), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Tab content'), findsOneWidget);
  });

  testWidgets('an owner switch closes Focus (CR-160 I5)', (tester) async {
    final c = await _pump(tester, 1280);
    await _open(tester);
    c.read(focusTaskProvider.notifier).close();
    await tester.pumpAndSettle();
    expect(find.byType(FocusView), findsNothing);
    expect(find.text('Tab content'), findsOneWidget);
  });
}
