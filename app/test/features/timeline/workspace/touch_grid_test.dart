import 'package:dottoday/app_screens.dart';
import 'package:dottoday/core/router/app_router.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/features/timeline/week/grid_scale.dart';
import 'package:dottoday/features/timeline/week/week_card.dart';
import 'package:dottoday/features/timeline/week/week_day_column.dart';
import 'package:dottoday/features/timeline/workspace/inspector/workspace_inspector.dart';
import 'package:dottoday/features/timeline/workspace/plan_panel_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../../support/test_app.dart';
import '../../../support/timeline_fakes.dart';

/// The Workspace at touch sizes on expanded tablets (E-R2-2, ED-269,
/// M19.2 part 3a): the touch grid's values, the Plan panel's and the
/// inspector's room rules, and holding a block to drag it.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('GridScale (ED-269)', () {
    test('pointer keeps the board, touch has the tablet values', () {
      const p = GridScale.pointer;
      const t = GridScale.touchSizes;
      expect((p.hour, p.column, p.pillUnder), (84.0, 144.0, 30));
      expect((t.hour, t.column, t.pillUnder), (96.0, 180.0, 35));
      expect((t.ring, t.liveRing), (36.0, 45.0));
      expect(p.ringFor(live: true), p.ring);
    });

    test('a touch pill: dot 28 from 44 tall, 24 below; corners ≤ 16', () {
      const t = GridScale.touchSizes;
      expect(t.pillDot(44), 28);
      expect(t.pillDot(20), 24);
      expect(t.pillRadius(20), 10);
      expect(t.pillRadius(44), 16);
      expect(GridScale.pointer.pillDot(44), DotSize.gridPillDot);
    });

    test('the Plan panel needs 3 days of 180 at touch sizes', () {
      // 820 − 260 − 1 = 559: room for 3 × 144 + 44, not 3 × 180 + 44.
      expect(planPanelHasRoom(820, 260, touch: false), isTrue);
      expect(planPanelHasRoom(820, 260, touch: true), isFalse);
      expect(planPanelHasRoom(900, 260, touch: true), isTrue);
    });
  });

  Future<FakeOccurrenceRepository> pump(
    WidgetTester tester, {
    required Size size,
    String at = '/week/2026-10-21',
  }) async {
    tester.view
      ..physicalSize = size
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
    router.go(at);
    await tester.pumpAndSettle();
    return repo;
  }

  Future<void> onIPad(Future<void> Function() body) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  testWidgets('a wide iPad: the inspector floats over the grid', (
    tester,
  ) async {
    await onIPad(() async {
      // Wide enough to dock with a pointer (1440, ED-170 C1).
      await pump(tester, size: const Size(1440, 900));
      await tester.tap(find.text('Reply to email').first);
      await tester.pumpAndSettle();
      final panel = tester.getRect(find.byType(WorkspaceInspector));
      final last = tester.getRect(find.byType(WeekDayColumn).last);
      // Over the grid, not beside it: the columns run on under it.
      expect(last.right, greaterThan(panel.left));
    });
  });

  testWidgets('touch blocks use the touch sizes', (tester) async {
    await onIPad(() async {
      await pump(tester, size: const Size(1180, 820));
      final title = tester.widget<Text>(find.text('Lunch with Sam').first);
      expect(title.style?.fontSize, 17);
      final column = tester.getSize(find.byType(WeekDayColumn).first);
      expect(column.width, greaterThanOrEqualTo(DotSize.gridTouchColumn));
    });
  });

  testWidgets('hold a block, then drag it an hour earlier, with Undo', (
    tester,
  ) async {
    await onIPad(() async {
      final repo = await pump(tester, size: const Size(1180, 820));
      final email = repo.rows.firstWhere((o) => o.title == 'Reply to email');
      final card = find.text('Reply to email').first;
      final g = await tester.startGesture(tester.getCenter(card));
      // A plain swipe would scroll: the hold lifts it first.
      await tester.pump(DotTouch.liftDelay + const Duration(milliseconds: 50));
      await g.moveBy(const Offset(0, 20));
      await tester.pump();
      expect(
        find.byWidgetPredicate((w) => w is WeekCard && w.lifted),
        findsOneWidget,
      );
      // 96 px up: an hour earlier at touch sizes.
      await g.moveBy(const Offset(0, -116));
      await tester.pump();
      await g.up();
      await tester.pumpAndSettle();
      final moved = repo.rows.singleWhere((o) => o.id == email.id);
      expect(
        moved.startUtc!.difference(email.startUtc!),
        const Duration(hours: -1),
      );
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(
        repo.rows.singleWhere((o) => o.id == email.id).startUtc,
        email.startUtc,
      );
    });
  });
}
