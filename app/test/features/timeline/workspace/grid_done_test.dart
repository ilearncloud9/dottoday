import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/week/week_card.dart';
import 'package:dottoday/shared/dot/done_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// The done circle on grid blocks at touch sizes (E-R2-5 "Complete",
/// ED-276, M19.5 part 5a): done with Undo, and reopened by the same
/// circle; the Mac's blocks keep none (the inspector's Done does it).
void main() {
  setUpAll(tz_data.initializeTimeZones);

  Future<FakeOccurrenceRepository> pump(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1366, 1024)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = FakeOccurrenceRepository(demoDayRows(DateTime(2026, 10, 21)));
    final router = buildRouter(appScreens);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      testRouterApp(
        router,
        overrides: [
          ...timelineOverrides(
            now: DateTime.utc(2026, 10, 21, 8),
            occurrences: repo,
          ),
          siriTipDueProvider.overrideWith((ref) => Stream.value(false)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    router.go('/week/2026-10-21');
    await tester.pumpAndSettle();
    return repo;
  }

  Finder circleOf(String title) => find.descendant(
    of: find.ancestor(
      of: find.text(title).first,
      matching: find.byType(WeekCard),
    ),
    matching: find.byType(DoneCircle),
  );

  OccurrenceStatus status(FakeOccurrenceRepository r, String title) =>
      r.rows.singleWhere((o) => o.title == title).status;

  testWidgets("an iPad: a block's circle marks it done, with Undo; again "
      'reopens it', (tester) async {
    final repo = await pump(tester);
    await tester.tap(circleOf('Reply to email'));
    await tester.pumpAndSettle();
    expect(status(repo, 'Reply to email'), OccurrenceStatus.done);
    expect(find.text('Undo'), findsOneWidget);
    await tester.tap(circleOf('Reply to email'));
    await tester.pumpAndSettle();
    expect(status(repo, 'Reply to email'), isNot(OccurrenceStatus.done));
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('an Android tablet: the same circle', (tester) async {
    await pump(tester);
    expect(circleOf('Reply to email'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('the Mac: no circles on the grid', (tester) async {
    await pump(tester);
    expect(
      find.descendant(
        of: find.byType(WeekCard),
        matching: find.byType(DoneCircle),
      ),
      findsNothing,
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
