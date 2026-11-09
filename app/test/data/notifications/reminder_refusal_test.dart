import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/data/notifications/reminder_refusal.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// CR-160 §4 (owner 2026-11-09): a refusal belongs to the owner session its
// tap began in; it never reaches the next one.
void main() {
  late ProviderContainer c;
  setUp(() => c = ProviderContainer());
  tearDown(() => c.dispose());

  ReminderRefusal refusals() => c.read(reminderRefusalProvider.notifier);
  void switchOwner() => c.read(ownerEpochProvider.notifier).next();

  test('within its session it is taken, tagged with that session', () {
    final epoch = c.read(ownerEpochProvider);
    refusals().report(const StorageFailure(), epoch: epoch);
    final r = c.read(reminderRefusalProvider)!;
    expect(r.failure, const StorageFailure());
    expect(r.epoch, epoch);
    expect(refusals().current(r), isTrue);
  });

  test('from an ended session (A → B, or A → B → A) it is never taken', () {
    final shown = <Refusal?>[];
    c.listen(reminderRefusalProvider, (_, r) => shown.add(r));
    final a = c.read(ownerEpochProvider);
    switchOwner();
    refusals().report(const StorageFailure(), epoch: a);
    switchOwner(); // A shown again: still a new session.
    refusals().report(const StorageFailure(), epoch: a);
    expect(c.read(reminderRefusalProvider), isNull);
    expect(shown.whereType<Refusal>(), isEmpty);
  });

  test('reported, not shown yet, then the owner changes: dropped, and no '
      'longer current', () {
    refusals().report(
      const StorageFailure(),
      epoch: c.read(ownerEpochProvider),
    );
    final r = c.read(reminderRefusalProvider)!;
    switchOwner();
    expect(c.read(reminderRefusalProvider), isNull);
    expect(refusals().current(r), isFalse);
  });
}
