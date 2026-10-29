@Tags(['golden'])
library;

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/thinking/thinking_providers.dart';
import 'package:dottoday/data/tips/seen_tips.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_status.dart';
import 'package:dottoday/features/proposals/proposal_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/dot_golden.dart';
import '../../support/fake_clock.dart';
import '../../support/fake_seen_tips.dart';
import '../../support/sample_proposal.dart';

// The "simple rules" proposal state (docs/09 M14.2, derived — 10 §5,
// 11 §B4 AI status): the origin label and, with Apple Intelligence off,
// the StatusHint under the subtitle. Light/dark × three widths, 1×/2×,
// the largest text and RTL.

class _Opener extends ConsumerWidget {
  const _Opener();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
    child: TextButton(
      onPressed: () => ref
          .read(activeProposalProvider.notifier)
          .open(
            ProposalRequest(
              proposal: sampleProposal(1),
              title: 'Brain dump',
              subtitle: '1 task on Today, in the first free time',
              originLabel: 'simple rules',
              rulesAnswered: true,
              acceptLabel: 'Add to day',
              acceptedMessage: 'Added from your brain dump',
            ),
          ),
      child: const Text('Propose'),
    ),
  );
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  goldenMatrix(
    'proposal_rules_hint',
    height: 1000,
    a11yVariants: true,
    overrides: [
      clockProvider.overrideWithValue(
        FakeClock(DateTime.utc(2026, 10, 21, 15, 25)),
      ),
      currentProfileProvider.overrideWith(
        (ref) => Stream.value(profileFixture()),
      ),
      thinkingStatusProvider.overrideWith(
        (ref) async => const ThinkingStatus(
          availability: ThinkingAvailability.notEnabled,
          vendor: ThinkingVendor.appleIos,
        ),
      ),
      seenTipsProvider.overrideWith(FakeSeenTips.new),
    ],
    build: (_) => const Scaffold(body: ProposalHost(child: _Opener())),
    act: (tester) => tester.tap(find.text('Propose')),
  );
}
