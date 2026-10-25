@Tags(['golden'])
library;

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/dot_golden.dart';
import '../../support/fake_clock.dart';
import '../../support/sample_proposal.dart';

// B3 ProposalSheet (docs/09 M10.2; chrome from `B-ios-rebalance`, shared
// with `B-ios-break-it-down`): empty, one and seven lines, as a sheet on
// phones, a popover at the medium width and the right-hand panel at the
// expanded width (docs/10 §4).

class _Opener extends ConsumerWidget {
  const _Opener(this.proposal);

  final Proposal proposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
    child: TextButton(
      onPressed: () => ref
          .read(activeProposalProvider.notifier)
          .open(
            ProposalRequest(
              proposal: proposal,
              title: 'Running late',
              subtitle: "Deep work ran over by 25 min · here's a plan",
              acceptLabel: 'Accept plan',
              acceptedMessage: 'Plan applied',
            ),
          ),
      child: const Text('Propose'),
    ),
  );
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  for (final (name, edits) in [('empty', 0), ('1', 1), ('7', 7)]) {
    goldenMatrix(
      'proposal_sheet_$name',
      height: 1000,
      overrides: [
        clockProvider.overrideWithValue(
          FakeClock(DateTime.utc(2026, 10, 21, 15, 25)),
        ),
        currentProfileProvider.overrideWith(
          (ref) => Stream.value(profileFixture()),
        ),
      ],
      build: (_) =>
          Scaffold(body: ProposalHost(child: _Opener(sampleProposal(edits)))),
      act: (tester) => tester.tap(find.text('Propose')),
    );
  }
}
