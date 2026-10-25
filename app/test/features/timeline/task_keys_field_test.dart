import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/task_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/test_app.dart';
import '../../support/timeline_fakes.dart';
import '../../support/today_harness.dart';

/// Today's task keys stand aside while a text field has focus: ⌫ and
/// Space are typing there, not Trash and Done (docs/09 M8.6b).
void main() {
  setUpAll(tz_data.initializeTimeZones);

  Future<FakeOccurrenceRepository> pump(
    WidgetTester tester, {
    required bool field,
  }) async {
    final repo = FakeOccurrenceRepository(demoDayRows(todayTestDate));
    await tester.pumpWidget(
      ProviderScope(
        overrides: timelineOverrides(
          now: todayTestNow,
          occurrences: repo,
          profile: testProfile(),
        ),
        child: testApp(
          Scaffold(
            body: TaskKeys(
              day: todayTestDate,
              child: field
                  ? const TextField(autofocus: true)
                  : const Focus(autofocus: true, child: SizedBox()),
            ),
          ),
        ),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(TaskKeys)),
    );
    // Keep the day and the pick alive, as Today's thread does.
    container
      ..listen(timelineDataProvider(todayTestDate), (_, _) {})
      ..listen(taskSelectionProvider, (_, _) {});
    await tester.pumpAndSettle();
    final gym = repo.rows.firstWhere((o) => o.title == 'Gym');
    container.read(taskSelectionProvider.notifier).only(todayTestDate, gym.id);
    await tester.pump();
    return repo;
  }

  bool gymGone(FakeOccurrenceRepository repo) =>
      repo.rows.firstWhere((o) => o.title == 'Gym').deletedAt != null;

  testWidgets('Delete trashes the pick when no field has focus', (
    tester,
  ) async {
    final repo = await pump(tester, field: false);
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pumpAndSettle();
    expect(gymGone(repo), isTrue);
  });

  testWidgets('a focused field keeps Delete, ⌫ and Space', (tester) async {
    final repo = await pump(tester, field: true);
    await tester.enterText(find.byType(TextField), 'Gym bag');
    for (final key in [
      LogicalKeyboardKey.delete,
      LogicalKeyboardKey.backspace,
      LogicalKeyboardKey.space,
    ]) {
      await tester.sendKeyEvent(key);
    }
    await tester.pumpAndSettle();
    expect(gymGone(repo), isFalse);
    expect(
      repo.rows.firstWhere((o) => o.title == 'Gym').status.name,
      'planned',
    );
  });
}
