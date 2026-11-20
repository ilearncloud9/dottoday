import 'package:dottoday/features/timeline/now/now_screen.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../support/a11y.dart';
import 'slice_world.dart';

/// The slice's cases at the three widths (M19.7): each draws without an
/// overflow or exception, loading is the skeleton (never a spinner), a
/// failure is the inline error whose Try again reloads, and the drawn
/// screens pass the accessibility guidelines.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  for (final minimal in [false, true]) {
    final screen = minimal ? 'Now' : 'Today';
    for (final w in SliceWidth.values) {
      group('$screen, ${w.name}', () {
        testWidgets('loading: the skeleton, no spinner', (tester) async {
          await pumpSlice(tester, minimal: minimal, c: SliceCase.loading, w: w);
          expect(find.byType(LoadingThread), findsWidgets);
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(find.bySemanticsLabel('Loading'), findsWidgets);
        }, variant: TargetPlatformVariant.only(w.platform));

        testWidgets('error: inline, with Try again', (tester) async {
          await pumpSlice(tester, minimal: minimal, c: SliceCase.error, w: w);
          expect(find.text("This didn't load"), findsOneWidget);
          expect(find.text('Try again'), findsOneWidget);
          await tester.tap(find.text('Try again'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }, variant: TargetPlatformVariant.only(w.platform));

        for (final c in [
          SliceCase.empty,
          SliceCase.dense,
          SliceCase.long,
          SliceCase.large,
        ]) {
          testWidgets('${c.name}: drawn, accessible', (tester) async {
            await pumpSlice(tester, minimal: minimal, c: c, w: w);
            expect(tester.takeException(), isNull);
            expect(find.byType(ErrorState), findsNothing);
            expect(find.byType(LoadingThread), findsNothing);
            expect(
              find.byType(minimal ? NowScreen : TodayScreen),
              findsOneWidget,
            );
            await expectA11yGuidelines(tester);
          }, variant: TargetPlatformVariant.only(w.platform));
        }
      });
    }
  }
}
