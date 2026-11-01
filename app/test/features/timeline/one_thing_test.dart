import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/wake_up/one_thing.dart';
import 'package:dottoday/features/timeline/one_thing/one_thing_picker.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/inbox_harness.dart';
import '../../support/sample_inbox.dart';
import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// docs/15 §8 (M17.7b): today's one thing from Today's ⋯, its ring and
// "Your one thing" on Today and in the Inbox; one a day, a new pick
// replaces the old, and yesterday's pick shows nowhere.

const _today = '2026-10-21';

List<Occurrence> _ahead() => [
  for (final o in demoDayRows(todayTestDate))
    if (o.startUtc != null && o.endUtc!.isAfter(todayTestNow)) o,
]..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));

Future<Settings> _stored(WidgetTester tester) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(Scaffold).first),
  );
  final p = await container.read(settingsRepositoryProvider).findLocalProfile();
  return p!.settings;
}

Iterable<TaskDot> _ringed(WidgetTester tester) =>
    tester.widgetList<TaskDot>(find.byType(TaskDot)).where((d) => d.oneThing);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets("Today ⋯ › Pick today's one thing stores it and rings it", (
    tester,
  ) async {
    await pumpToday(tester, size: const Size(390, 1400));
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Pick today's one thing…"));
    await tester.pumpAndSettle();
    expect(find.text('What matters most today?'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    final pick = _ahead()[1];
    await tester.tap(
      find.descendant(
        of: find.byType(OneThingPicker),
        matching: find.text(pick.title),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(OneThingPicker), findsNothing);
    expect(
      (await _stored(tester)).oneThing,
      OneThing(date: _today, occurrenceId: pick.id),
    );
    expect(find.text('Your one thing'), findsOneWidget);
    expect(_ringed(tester), hasLength(1));
  });

  testWidgets('a new pick quietly replaces the old', (tester) async {
    final ahead = _ahead();
    await pumpToday(
      tester,
      size: const Size(390, 1400),
      settings: Settings(
        oneThing: OneThing(date: _today, occurrenceId: ahead[0].id),
      ),
    );
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Pick today's one thing…"));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(OneThingPicker),
        matching: find.text(ahead[2].title),
      ),
    );
    await tester.pumpAndSettle();
    expect((await _stored(tester)).oneThing?.occurrenceId, ahead[2].id);
    expect(find.text('Your one thing'), findsOneWidget);
    expect(_ringed(tester), hasLength(1));
  });

  testWidgets("screen readers hear it in the row's label", (tester) async {
    final handle = tester.ensureSemantics();
    final pick = _ahead().first;
    await pumpToday(
      tester,
      size: const Size(390, 1400),
      settings: Settings(
        oneThing: OneThing(date: _today, occurrenceId: pick.id),
      ),
    );
    expect(find.bySemanticsLabel(RegExp('your one thing')), findsWidgets);
    handle.dispose();
  });

  testWidgets("yesterday's pick shows nowhere", (tester) async {
    await pumpToday(
      tester,
      size: const Size(390, 1400),
      settings: Settings(
        oneThing: OneThing(date: '2026-10-20', occurrenceId: _ahead()[0].id),
      ),
    );
    expect(find.text('Your one thing'), findsNothing);
    expect(_ringed(tester), isEmpty);
  });

  testWidgets('an Inbox one thing is ringed in the Inbox', (tester) async {
    final item = sampleInbox().first;
    await pumpInbox(
      tester,
      settings: Settings(
        use24h: false,
        oneThing: OneThing(date: _today, occurrenceId: item.id),
      ),
    );
    expect(find.textContaining('Your one thing'), findsOneWidget);
    expect(_ringed(tester), hasLength(1));
  });
}
