// Goldens are baselined on macOS; CI runs them on a macOS runner (docs/09 M0.8).
@Tags(['golden'])
library;

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/timeline/state/rebalance_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/dot_golden.dart';
import '../../support/fake_clock.dart';
import '../../support/rebalance_fixtures.dart';
import '../../support/sample_proposal.dart';

// Rebalance as E-R2-35 draws it (ED-341), in the app's fonts: each line
// with its faded ring and proposed dot, shifted, pinned with its lock,
// shrunk and moved to tomorrow; the rules as filter chips; a sheet on
// phones (Android's M3 sheet), a centred panel on the Mac and the web,
// and Minimal's before and after only.

class _Opener extends ConsumerWidget {
  const _Opener();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
    child: TextButton(
      onPressed: () => ref
          .read(activeProposalProvider.notifier)
          .open(
            rebalanceRequest(
              context.l10n,
              subtitle: "Deep work ran over by 25 min · here's a plan",
              compute: (_) => sampleProposal(4),
            ),
          ),
      child: const Text('Propose'), // l10n-ignore: test trigger
    ),
  );
}

List<Override> _overrides({UiLayout layout = UiLayout.full}) => [
  clockProvider.overrideWithValue(FakeClock(rebalanceNow)),
  currentProfileProvider.overrideWith(
    (ref) => Stream.value(
      profileFixture().copyWith(
        settings: profileFixture().settings.copyWith(uiLayout: layout),
      ),
    ),
  ),
];

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Propose'));
  await tester.pumpAndSettle();
}

Widget _build(GoldenCell _) =>
    const Scaffold(body: ProposalHost(child: _Opener()));

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await loadAppFonts();
  });
  goldenMatrix(
    'rebalance_plan',
    height: 1000,
    widths: const {'compact', 'expanded'},
    overrides: _overrides(),
    build: _build,
    act: _open,
  );
  goldenMatrix(
    'rebalance_plan_android',
    height: 1000,
    widths: const {'compact'},
    platform: TargetPlatform.android,
    overrides: _overrides(),
    build: _build,
    act: _open,
  );
  goldenMatrix(
    'rebalance_plan_minimal',
    height: 1000,
    widths: const {'compact'},
    overrides: _overrides(layout: UiLayout.minimal),
    build: _build,
    act: _open,
  );
}
