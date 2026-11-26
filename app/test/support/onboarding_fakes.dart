import 'package:dottoday/data/onboarding/first_today_store.dart';
import 'package:dottoday/data/onboarding/later_cards_store.dart';
import 'package:dottoday/data/onboarding/onboarding_store.dart';
import 'package:dottoday/domain/onboarding/onboarding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Onboarding at [progress], in memory (docs/09 M4).
final class FakeOnboarding extends Onboarding {
  FakeOnboarding([this.progress = OnboardingProgress.start]);

  final OnboardingProgress progress;

  @override
  Future<OnboardingProgress> build() async => progress;

  @override
  Future<void> go(OnboardingStep step, {bool account = false}) async =>
      state = AsyncData(OnboardingProgress(step: step, account: account));

  @override
  Future<void> finish() async =>
      state = const AsyncData(OnboardingProgress.done);
}

/// For app-level tests that start on Today: onboarding already done.
final Override onboarded = onboardingProvider.overrideWith(
  () => FakeOnboarding(OnboardingProgress.done),
);

/// The first Today's state in memory (M20.11 part 5), starting at
/// [initial].
final class MemoryFirstToday extends FirstToday {
  MemoryFirstToday([this.initial = const FirstTodayState()]);

  final FirstTodayState initial;

  @override
  Future<FirstTodayState> build() async => initial;

  FirstTodayState get _now => state.value ?? initial;

  @override
  Future<void> begin() async => state = const AsyncData(
    FirstTodayState(rise: true, hint: true, sync: true),
  );

  @override
  Future<void> risen() async => state = AsyncData(_now.copy(rise: false));

  @override
  Future<void> hintDone() async => state = AsyncData(_now.copy(hint: false));

  @override
  Future<void> syncDone() async => state = AsyncData(_now.copy(sync: false));
}

/// The later cards' state in memory (M20.11 part 6), starting at
/// [initial].
final class MemoryLaterCards extends LaterCards {
  MemoryLaterCards([this.initial = const LaterCardsState()]);

  final LaterCardsState initial;

  @override
  Future<LaterCardsState> build() async => initial;

  LaterCardsState get _now => state.value ?? initial;

  @override
  Future<void> begin(DateTime nowUtc) async => state = AsyncData(
    LaterCardsState(onboardedUtc: nowUtc, habits: _now.habits),
  );

  @override
  Future<void> addHabits(Iterable<String> ids) async =>
      state = AsyncData(_now.copy(habits: {..._now.habits, ...ids}.toList()));

  @override
  Future<void> habitDone(String id) async =>
      state = AsyncData(_now.copy(habitsOffered: {..._now.habitsOffered, id}));

  @override
  Future<void> simplerDone() async =>
      state = AsyncData(_now.copy(simpler: true));

  @override
  Future<void> closeDone() async => state = AsyncData(_now.copy(close: true));

  @override
  Future<void> syncDone() async => state = AsyncData(_now.copy(sync: true));
}
