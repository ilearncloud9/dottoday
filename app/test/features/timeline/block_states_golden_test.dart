// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/app_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/layout/block_facts.dart';
import 'package:dottoday/features/timeline/widgets/block_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/fixtures.dart';

/// Every block state from docs/03 §3.1, tall and single-row.
final _states = <(String, Occurrence Function(Occurrence), BlockFacts)>[
  (
    'plain',
    (o) => o,
    const BlockFacts(
      done: false,
      overdue: false,
      pinned: false,
      recurring: false,
      calendar: false,
      alertCount: 0,
    ),
  ),
  (
    'done',
    (o) => o.copyWith(status: OccurrenceStatus.done),
    const BlockFacts(
      done: true,
      overdue: false,
      pinned: false,
      recurring: false,
      calendar: false,
      alertCount: 0,
    ),
  ),
  (
    'overdue',
    (o) => o,
    const BlockFacts(
      done: false,
      overdue: true,
      pinned: false,
      recurring: false,
      calendar: false,
      alertCount: 0,
    ),
  ),
  (
    'badges',
    (o) => o.copyWith(colorKey: 'teal', iconKey: 'gym'),
    const BlockFacts(
      done: false,
      overdue: false,
      pinned: true,
      recurring: true,
      calendar: true,
      alertCount: 3,
      subtasksDone: 2,
      subtasksTotal: 3,
    ),
  ),
];

class _Specimen extends StatelessWidget {
  const _Specimen();

  @override
  Widget build(BuildContext context) {
    final base = occurrenceFixture().copyWith(title: 'Gym session');
    final utc = tz.getLocation('UTC');
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (_, make, facts) in _states)
              for (final height in [110.0, 50.0])
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s),
                  child: SizedBox(
                    height: height * MediaQuery.textScalerOf(context).scale(1),
                    child: BlockTile(
                      block: make(base),
                      location: utc,
                      use24h: true,
                      facts: facts,
                      onToggleDone: () {},
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('block states ${mode.name} ${scale}x', (tester) async {
        await tester.binding.setSurfaceSize(Size(380, 720 * scale));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: mode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: const _Specimen(),
          ),
        );
        await expectLater(
          find.byType(_Specimen),
          matchesGoldenFile(
            'goldens/block_states_${mode.name}_${scale.toInt()}x.png',
          ),
        );
      });
    }
  }
}
