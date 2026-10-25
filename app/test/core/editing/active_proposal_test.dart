import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/sample_proposal.dart';

// The open proposal (docs/09 M10.2): editing it keeps everything the flow
// asked for — found in M10.4, when an update dropped the lead, the total
// and the draft-only flag.

void main() {
  test('update, removeEdit, failed and busy keep every other field', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    Widget part(BuildContext _, Object _) => const SizedBox();
    final request = ProposalRequest(
      proposal: sampleProposal(3),
      title: 't',
      subtitle: 's',
      originLabel: 'o',
      acceptLabel: 'a',
      acceptedMessage: 'm',
      body: (_, _, _) => const SizedBox(),
      lead: part,
      below: part,
      onAccepted: (_) {},
      draftOnly: true,
      overSheet: true,
    );
    final active = c.read(activeProposalProvider.notifier)..open(request);
    void same() {
      final r = c.read(activeProposalProvider)!;
      expect(
        (r.title, r.subtitle, r.originLabel, r.acceptLabel, r.acceptedMessage),
        ('t', 's', 'o', 'a', 'm'),
      );
      expect([r.body, r.lead, r.below, r.onAccepted], everyElement(isNotNull));
      expect((r.draftOnly, r.overSheet), (true, true));
    }

    active.update(sampleProposal(2));
    same();
    active.removeEdit('e0');
    same();
    expect(active.beginAccept(), isTrue);
    expect(active.beginAccept(), isFalse, reason: 'already writing');
    same();
    active.failed(const StorageFailure());
    same();
    expect(c.read(activeProposalProvider)!.failure, isA<StorageFailure>());
    expect(c.read(activeProposalProvider)!.busy, isFalse);
    active.close();
    expect(c.read(activeProposalProvider), isNull);
  });
}
