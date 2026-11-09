import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/editing/focus_task.dart';
import 'package:dottoday/core/editing/pending_brain_dump.dart';
import 'package:dottoday/core/editing/pending_routine_drop.dart';
import 'package:dottoday/data/notifications/in_app_alerts.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../../support/sample_proposal.dart';

// App-wide state that holds one owner's task ids or text is empty again
// after every change of owner (CR-160 I5): open editor, Focus, a queued
// Focus request, the proposal sheet, queued brain dump and routine drop,
// in-app reminder banners.

void main() {
  late ProviderContainer c;

  setUp(() => c = ProviderContainer());
  tearDown(() => c.dispose());

  void fillAsPreviousOwner() {
    c.read(editingTaskProvider.notifier).open('a-task');
    c.read(focusTaskProvider.notifier).open('a-task');
    c.read(focusRequestProvider.notifier).request('a-task');
    c
        .read(activeProposalProvider.notifier)
        .open(
          ProposalRequest(
            proposal: sampleProposal(2),
            title: 'A plan',
            acceptedMessage: 'done',
          ),
        );
    c.read(pendingBrainDumpProvider.notifier).request('A private lines');
    c
        .read(pendingRoutineDropProvider.notifier)
        .request(RoutineDropRequest(routine: routineFixture(), date: t0));
    c
        .read(inAppAlertsProvider.notifier)
        .add(
          OsNotification(
            id: 1,
            title: 'A task title',
            body: 'now',
            fireAtUtc: t0,
            payload: '{}',
            channel: NotificationChannelKind.alerts,
          ),
        );
  }

  List<Object?> everything() => [
    c.read(editingTaskProvider),
    c.read(focusTaskProvider),
    c.read(focusRequestProvider),
    c.read(activeProposalProvider),
    c.read(pendingBrainDumpProvider),
    c.read(pendingRoutineDropProvider),
    if (c.read(inAppAlertsProvider).isNotEmpty) c.read(inAppAlertsProvider),
  ];

  test('a change of owner leaves nothing of the previous one', () {
    fillAsPreviousOwner();
    expect(everything(), everyElement(isNotNull));
    c.read(ownerEpochProvider.notifier).next();
    expect(everything(), everyElement(isNull));
  });

  test('a listener sees the reset; repeated switches stay empty', () {
    final seen = <String?>[];
    c.listen(editingTaskProvider, (_, next) => seen.add(next));
    for (var i = 0; i < 3; i++) {
      fillAsPreviousOwner();
      c.read(ownerEpochProvider.notifier).next();
      expect(everything(), everyElement(isNull));
    }
    expect(seen, ['a-task', null, 'a-task', null, 'a-task', null]);
  });

  test('state survives while the owner stays the same', () {
    fillAsPreviousOwner();
    expect(everything(), everyElement(isNotNull));
    expect(c.read(editingTaskProvider), 'a-task');
  });
}
