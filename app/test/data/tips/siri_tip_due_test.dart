import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/intents/siri_providers.dart';
import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/data/tips/seen_tips.dart';
import 'package:dottoday/data/tips/siri_tip_due.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/fixtures.dart';
import '../../support/onboarding_fakes.dart';
import '../writes/write_harness.dart';

// docs/09 M14.3: the Siri card is due after the third task the person
// adds once onboarding is done on this device — counted from the rows,
// so any way of adding counts and onboarding's starter tasks don't.

final _now = DateTime.utc(2026, 10, 21, 9);

void main() {
  late WriteHarness h;
  setUp(() => h = WriteHarness(_now));
  tearDown(() => h.dispose());

  ProviderContainer container({
    bool siri = true,
    bool finished = true,
    Set<Tip> seen = const {},
  }) {
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(h.db),
        clockProvider.overrideWithValue(h.clock),
        siriAvailableProvider.overrideWithValue(siri),
        onboardingProvider.overrideWith(
          () => FakeOnboarding(
            OnboardingProgress(step: OnboardingStep.done, finished: finished),
          ),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  var next = 0;
  Future<void> add(int n, {required DateTime at}) => h.writes.apply(
    WriteBatch(
      userId: userId,
      profile: profileFixture(),
      occurrences: [
        for (var i = 0; i < n; i++)
          occurrenceFixture().copyWith(
            id: '01928c3e-0000-7000-8000-${'${next++}'.padLeft(12, '0')}',
            createdAt: at,
            updatedAt: at,
          ),
      ],
    ),
  );

  Future<bool> due(ProviderContainer c) async {
    final sub = c.listen(siriTipDueProvider, (_, _) {});
    addTearDown(sub.close);
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (c.read(siriTipDueProvider).hasValue) break;
    }
    return c.read(siriTipDueProvider).value!;
  }

  test('onboarding tasks before arming never count; three after do', () async {
    await add(4, at: _now.subtract(const Duration(hours: 1)));
    final c = container();
    expect(await due(c), isFalse, reason: 'arms now');
    h.clock.advance(const Duration(minutes: 5));
    await add(2, at: _now.add(const Duration(minutes: 5)));
    expect(await due(c), isFalse);
    await add(1, at: _now.add(const Duration(minutes: 6)));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(c.read(siriTipDueProvider).value, isTrue);
  });

  test(
    'never without Siri, before onboarding ends, or once put away',
    () async {
      for (final c in [container(siri: false), container(finished: false)]) {
        expect(await due(c), isFalse);
      }
      final c = container();
      await c.read(seenTipsProvider.notifier).putAway(Tip.siriToday);
      expect(await due(c), isFalse);
    },
  );
}
