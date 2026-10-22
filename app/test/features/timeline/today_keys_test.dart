import 'package:dottoday/domain/entities/enums.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

// Today's keys (docs/09 M3e.6): one test per binding. Tests run on
// Android, so Ctrl.

Future<void> _ctrl(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  for (final (label, size) in [
    ('phone', const Size(390, 844)),
    ('spread', const Size(1280, 900)),
  ]) {
    testWidgets('$label: Ctrl+→ next day, Ctrl+← back, Ctrl+T today', (
      tester,
    ) async {
      await pumpToday(tester, size: size);
      await _ctrl(tester, LogicalKeyboardKey.arrowRight);
      expect(find.text('Thursday'), findsWidgets);
      expect(find.text('Good morning, Kody'), findsNothing);
      await _ctrl(tester, LogicalKeyboardKey.arrowLeft);
      await _ctrl(tester, LogicalKeyboardKey.arrowLeft);
      expect(find.text('Tuesday'), findsWidgets);
      await _ctrl(tester, LogicalKeyboardKey.keyT);
      expect(find.text('Good morning, Kody'), findsOneWidget);
    });
  }

  testWidgets('Ctrl+D marks the task running now done, with Undo', (
    tester,
  ) async {
    final repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
    await pumpToday(tester, repo: repo);
    await _ctrl(tester, LogicalKeyboardKey.keyD);
    final deep = repo.rows.singleWhere((o) => o.title == 'Deep work: roadmap');
    expect(deep.status, OccurrenceStatus.done);
    expect(find.text('Deep work: roadmap done'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(
      repo.rows.singleWhere((o) => o.id == deep.id).status,
      OccurrenceStatus.planned,
    );
  });
}
