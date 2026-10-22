import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/state/day_text.dart';
import 'package:dottoday/shared/dot/month_cells.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// The day's ⋯: Duplicate day… and Copy day as text (docs/09 M3f.6).

late FakeOccurrenceRepository _repo;

Future<void> _openMenu(WidgetTester tester, String item) async {
  _repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
  await pumpToday(tester, repo: _repo, size: const Size(390, 1000));
  await tester.tap(find.byTooltip('More options'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(item));
  await tester.pumpAndSettle();
}

bool _on(DateTime utc, int day) => utc.day == day;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  testWidgets('Duplicate day copies the one-offs to the picked day', (
    tester,
  ) async {
    await _openMenu(tester, 'Duplicate day…');
    expect(find.text('Copy to which day?'), findsOneWidget);
    final oneOffs = _repo.rows
        .where((o) => o.seriesId == null && o.startUtc != null)
        .where((o) => _on(o.startUtc!, 21))
        .length;
    final cell = tester
        .widgetList<CompactMonthCell>(find.byType(CompactMonthCell))
        .firstWhere((c) => c.day.date == '28');
    await tester.tap(find.byWidget(cell));
    await tester.pumpAndSettle();
    final copies = _repo.rows.where(
      (o) =>
          o.startUtc != null &&
          _on(o.startUtc!, 28) &&
          o.status == OccurrenceStatus.planned,
    );
    expect(copies, hasLength(oneOffs));
    expect(find.text('Copied $oneOffs tasks'), findsOneWidget);
  });

  testWidgets('Copy day as text puts the day on the clipboard', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await _openMenu(tester, 'Copy day as text');
    expect(find.text('Day copied as text'), findsOneWidget);
    final lines = copied!.split('\n');
    expect(lines.first, 'Wednesday, October 21');
    expect(lines, contains('○ 9:00 AM – 11:00 AM  Deep work: roadmap'));
  });

  test('dayAsText: time order, done marked, skipped left out', () {
    final rows = demoDayRows(todayTestDate);
    final skipped = rows.first.copyWith(status: OccurrenceStatus.skipped);
    final text = dayAsText(
      heading: 'Today',
      blocks: [...rows.skip(1).toList().reversed, skipped],
      time: (utc) => '${utc.hour}:${utc.minute}',
    );
    final lines = text.split('\n');
    expect(lines.first, 'Today');
    expect(lines.any((l) => l.endsWith(skipped.title)), isFalse);
    expect(lines.where((l) => l.startsWith('✓')), isNotEmpty);
  });
}
