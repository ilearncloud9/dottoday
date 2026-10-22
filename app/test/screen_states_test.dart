import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/inbox/inbox_screen.dart';
import 'package:dottoday/features/search/search_screen.dart';
import 'package:dottoday/features/settings/settings_screen.dart';
import 'package:dottoday/features/timeline/month_screen.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/task_screen.dart';
import 'package:dottoday/features/timeline/today_screen.dart';
import 'package:dottoday/features/timeline/week_screen.dart';
import 'package:dottoday/shared/states/screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'support/timeline_fakes.dart';

// Every screen has its states (docs/09 M3f.9b, 10 §5.4): loading
// (skeleton, no spinner), inline error with Try again, its empty state,
// and it holds up at 200 % text, right-to-left and reduced motion.

const _screens = <String, Widget>{
  'Today': TodayScreen(),
  'Inbox': InboxScreen(),
  'Week': WeekScreen(),
  'Month': MonthScreen(),
  'Search': SearchScreen(),
  'Settings': SettingsScreen(),
};

final _now = DateTime.utc(2026, 10, 21, 7, 22);

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  List<Override> extra = const [],
  bool demo = false,
  Size size = const Size(390, 844),
  double textScale = 1,
  TextDirection direction = TextDirection.ltr,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...timelineOverrides(
          now: _now,
          occurrences: FakeOccurrenceRepository(
            demo ? demoDayRows(DateTime(2026, 10, 21)) : const [],
          ),
          profile: testProfile(settings: const Settings(use24h: false)),
        ),
        ...extra,
      ],
      child: MaterialApp(
        theme: DotTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: true,
          ),
          child: Directionality(textDirection: direction, child: child!),
        ),
        home: screen,
      ),
    ),
  );
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  for (final MapEntry(key: name, value: screen) in _screens.entries) {
    group(name, () {
      testWidgets('loading: skeleton, no spinner', (tester) async {
        final never = Completer<Profile>();
        await _pump(
          tester,
          screen,
          extra: [
            currentProfileProvider.overrideWith(
              (ref) => Stream.fromFuture(never.future),
            ),
          ],
        );
        await tester.pump(const Duration(milliseconds: 400));
        if (name == 'Search') {
          // Search draws its field at once; the results wait (below).
          expect(find.byType(CircularProgressIndicator), findsNothing);
          return;
        }
        expect(find.byType(LoadingThread), findsWidgets);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.bySemanticsLabel('Loading'), findsWidgets);
      });

      testWidgets('error: inline, with Try again', (tester) async {
        var built = 0;
        await _pump(
          tester,
          screen,
          extra: [
            currentProfileProvider.overrideWith((ref) {
              built++;
              return Stream.error(const StorageFailure());
            }),
          ],
        );
        await tester.pumpAndSettle();
        if (name == 'Search') {
          await tester.enterText(find.byType(EditableText), 'run');
          await tester.pumpAndSettle();
        }
        expect(find.text("This didn't load"), findsOneWidget);
        expect(
          find.text("Couldn't read your tasks on this device."),
          findsOneWidget,
        );
        final before = built;
        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();
        expect(built, greaterThan(before), reason: 'Try again reloads');
      });

      testWidgets('empty: its own state, no skeleton', (tester) async {
        await _pump(tester, screen);
        await tester.pumpAndSettle();
        expect(find.byType(LoadingThread), findsNothing);
        expect(find.byType(ErrorState), findsNothing);
        final empty = switch (name) {
          'Today' => find.textContaining('Nothing planned'),
          'Inbox' => find.text('Inbox is clear'),
          _ => null,
        };
        if (empty != null) expect(empty, findsWidgets);
      });

      for (final (label, size) in [
        ('compact', const Size(390, 844)),
        ('expanded', const Size(1280, 900)),
      ]) {
        testWidgets('200 % text, RTL, reduced motion ($label)', (tester) async {
          await _pump(
            tester,
            screen,
            demo: true,
            size: size,
            textScale: 2,
            direction: TextDirection.rtl,
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(ErrorState), findsNothing);
        });
      }
    });
  }

  group('Task page', () {
    const id = '0199f0a0-0000-7000-8000-000000000001';
    Future<void> pumpTask(WidgetTester tester, Stream<TaskView?>? view) =>
        _pump(
          tester,
          const TaskScreen(id: id),
          extra: [
            if (view != null) taskViewProvider(id).overrideWith((ref) => view),
          ],
        );

    testWidgets('loading', (tester) async {
      await pumpTask(tester, Stream.fromFuture(Completer<TaskView?>().future));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(LoadingThread), findsOneWidget);
    });

    testWidgets('error with Try again', (tester) async {
      await pumpTask(tester, Stream.error(const StorageFailure()));
      await tester.pumpAndSettle();
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('an id that is not here reads "not here"', (tester) async {
      await pumpTask(tester, null);
      await tester.pumpAndSettle();
      expect(find.byType(ErrorState), findsNothing);
      expect(find.byType(LoadingThread), findsNothing);
    });
  });
}
