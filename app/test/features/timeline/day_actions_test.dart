import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/day_drag.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../support/timeline_fakes.dart';

// A tap carries the id its row was drawn with; by then the day's list may
// no longer hold it (deleted elsewhere, synced away). Every action is then
// a no-op, never a "Bad state: No element".

final _date = DateTime(2026, 10, 21);
final _now = DateTime.utc(2026, 10, 21, 7, 22);

Future<(ThreadActions, ThreadDrag, FakeOccurrenceRepository)> _pump(
  WidgetTester tester,
) async {
  final rows = demoDayRows(_date);
  final repo = FakeOccurrenceRepository(rows);
  late ThreadActions actions;
  late ThreadDrag drag;
  await tester.pumpWidget(
    ProviderScope(
      overrides: timelineOverrides(now: _now, occurrences: repo),
      child: MaterialApp(
        theme: DotTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              actions = dayThreadActions(
                context,
                ref,
                blocks: rows,
                timeText: (utc) => utc.toIso8601String(),
              );
              drag = dayThreadDrag(
                context,
                ref,
                blocks: rows,
                zone: tz.getLocation('Europe/Berlin'),
                snapMinutes: 5,
                timeText: (utc) => utc.toIso8601String(),
                allDayStartUtc: _now,
              );
              return const SizedBox();
            },
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (actions, drag, repo);
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  const gone = '01928c3e-0000-7000-8000-00000000dead';

  testWidgets('a tap on a task no longer in the day does nothing', (
    tester,
  ) async {
    final (actions, _, repo) = await _pump(tester);
    final before = repo.rows;
    actions.onToggleDone!(gone);
    actions.onExtend!(gone);
    actions.onShiftRest!(gone);
    actions.onUnstick!(gone, 'Open the doc');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(repo.rows, before);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('dropping a task no longer in the day does nothing', (
    tester,
  ) async {
    final (_, drag, repo) = await _pump(tester);
    final before = repo.rows;
    final span = DropSpan(startUtc: _now, minutes: 60);
    drag.onDrop(gone, span, 0.5, const DropShift(followers: true));
    drag.onAllDay!(gone);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(repo.rows, before);
  });
}
