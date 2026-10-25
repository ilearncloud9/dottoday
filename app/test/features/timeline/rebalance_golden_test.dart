@Tags(['golden'])
library;

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:dottoday/features/timeline/state/rebalance_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/dot_golden.dart';
import '../../support/fake_clock.dart';
import '../../support/rebalance_fixtures.dart';

// Rebalance (docs/09 M11.1, `B-ios-rebalance`): Deep work ran 25 min
// over; the plan with shifted lines, the pinned lunch untouched, the
// three rule chips, "Accept plan" and its footnote — a sheet on phones,
// a popover at the medium width, the right-hand panel when expanded.

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
              compute: rebalanceSample,
            ),
          ),
      child: const Text('Propose'),
    ),
  );
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  goldenMatrix(
    'rebalance_sheet',
    height: 1300,
    overrides: [
      clockProvider.overrideWithValue(FakeClock(rebalanceNow)),
      currentProfileProvider.overrideWith(
        (ref) => Stream.value(profileFixture()),
      ),
    ],
    build: (_) => const Scaffold(body: ProposalHost(child: _Opener())),
    act: (tester) => tester.tap(find.text('Propose')),
  );
}
