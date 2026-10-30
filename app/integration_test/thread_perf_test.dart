import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/day_card.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// R-15 (docs/09 M3b.9): a 200-task day scrolls at ≥ 55 fps. Run in
/// profile mode on a physical device (Flutter has no profile mode on
/// emulators or simulators; M5.9b), with `--no-dds` so the test can reach
/// the VM service for its timeline:
///   flutter drive --profile --no-dds --driver=test_driver/integration_test.dart \
///     --target=integration_test/thread_perf_test.dart
/// Not in `tool/device_tests.sh`: under `flutter test` it fails before
/// measuring, and debug numbers say nothing about frame time.
/// Frame build/raster times land in build/integration_response_data.json.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a 200-task thread scrolls within the frame budget', (
    tester,
  ) async {
    await tester.pumpWidget(_App(entries: _busyDay()));
    await tester.pumpAndSettle();
    final list = find.byType(Scrollable).first;
    await binding.watchPerformance(() async {
      for (var i = 0; i < 4; i++) {
        await tester.fling(list, const Offset(0, -2400), 4000);
        await tester.pumpAndSettle();
      }
      for (var i = 0; i < 4; i++) {
        await tester.fling(list, const Offset(0, 2400), 4000);
        await tester.pumpAndSettle();
      }
    }, reportKey: 'thread_200');
  });

  // The device's own floor: the same flings over 200 plain list tiles,
  // so emulator raster cost isn't mistaken for the thread's.
  testWidgets('baseline: 200 plain tiles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DotTheme.light(),
        home: Scaffold(
          body: ListView.builder(
            itemCount: 220,
            itemBuilder: (_, i) => ListTile(
              title: Text('Row $i'), // l10n-ignore: test data
              subtitle: const Text('9:00 – 9:05'), // l10n-ignore: test data
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final list = find.byType(Scrollable).first;
    await binding.watchPerformance(() async {
      for (final dy in const <double>[
        -2400,
        -2400,
        -2400,
        -2400,
        2400,
        2400,
        2400,
        2400,
      ]) {
        await tester.fling(list, Offset(0, dy), 4000);
        await tester.pumpAndSettle();
      }
    }, reportKey: 'baseline_tiles');
  });
}

/// Cap, 200 tasks of mixed states with a gap every tenth, cap.
List<ThreadEntry> _busyDay() => [
  const ThreadCap.wake('6:00 AM'), // l10n-ignore: test data
  for (var i = 0; i < 200; i++) ...[
    ThreadTaskEntry(
      ThreadTask(
        id: 't$i',
        title: 'Task number $i', // l10n-ignore: test data
        color: TaskColor.values[i % TaskColor.values.length],
        icon: TaskIcon.values[i % TaskIcon.values.length],
        state: i < 60
            ? DotState.done
            : i == 60
            ? DotState.live
            : DotState.upcoming,
        timeRange: '${i ~/ 12}:00 – ${i ~/ 12}:05', // l10n-ignore: test data
        duration: '5 min', // l10n-ignore: test data
        progress: 0.4,
        minutesLeft: 3,
      ),
    ),
    if (i % 10 == 9)
      const ThreadGap(minutes: 30, startLabel: '9:00', addable: true),
  ],
  const ThreadCap.bed('11:00 PM'), // l10n-ignore: test data
];

class _App extends StatelessWidget {
  const _App({required this.entries});

  final List<ThreadEntry> entries;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: DotTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DotSpace.page),
          child: DayCard(
            title: 'Wednesday', // l10n-ignore: test data
            isToday: true,
            summary: const DaySummary(
              done: 60,
              total: 200,
              plannedMinutes: 1000,
              freeMinutes: 60,
            ),
            entries: entries,
            actions: ThreadActions(
              onOpen: (_) {},
              onToggleDone: (_) {},
              drag: ThreadDrag(
                onDrop: (_, _, _, _) {},
                hintFor: (_, _, _) => null,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
