// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The numbers learning answers by (docs/13 §2); tests override it.

@ProviderFor(learningThresholds)
final learningThresholdsProvider = LearningThresholdsProvider._();

/// The numbers learning answers by (docs/13 §2); tests override it.

final class LearningThresholdsProvider
    extends
        $FunctionalProvider<
          LearningThresholds,
          LearningThresholds,
          LearningThresholds
        >
    with $Provider<LearningThresholds> {
  /// The numbers learning answers by (docs/13 §2); tests override it.
  LearningThresholdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'learningThresholdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$learningThresholdsHash();

  @$internal
  @override
  $ProviderElement<LearningThresholds> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LearningThresholds create(Ref ref) {
    return learningThresholds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LearningThresholds value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LearningThresholds>(value),
    );
  }
}

String _$learningThresholdsHash() =>
    r'78734d50509a34e2da5297ce440c34f6416001d2';

/// The user's last [LearningThresholds.historyDays] days, live: what learning (11 C3)
/// and energy suggestions (11 C4) read. On this device's data only.

@ProviderFor(learningHistory)
final learningHistoryProvider = LearningHistoryProvider._();

/// The user's last [LearningThresholds.historyDays] days, live: what learning (11 C3)
/// and energy suggestions (11 C4) read. On this device's data only.

final class LearningHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Occurrence>>,
          List<Occurrence>,
          Stream<List<Occurrence>>
        >
    with $FutureModifier<List<Occurrence>>, $StreamProvider<List<Occurrence>> {
  /// The user's last [LearningThresholds.historyDays] days, live: what learning (11 C3)
  /// and energy suggestions (11 C4) read. On this device's data only.
  LearningHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'learningHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$learningHistoryHash();

  @$internal
  @override
  $StreamProviderElement<List<Occurrence>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Occurrence>> create(Ref ref) {
    return learningHistory(ref);
  }
}

String _$learningHistoryHash() => r'f1baac2ada3b56eaace5c0be6334b13f856f3a73';

/// The steps of the history's tasks that really started: what step
/// lengths are learned from (docs/13 §5). Live, on this device's data.

@ProviderFor(learningSteps)
final learningStepsProvider = LearningStepsProvider._();

/// The steps of the history's tasks that really started: what step
/// lengths are learned from (docs/13 §5). Live, on this device's data.

final class LearningStepsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Subtask>>,
          List<Subtask>,
          Stream<List<Subtask>>
        >
    with $FutureModifier<List<Subtask>>, $StreamProvider<List<Subtask>> {
  /// The steps of the history's tasks that really started: what step
  /// lengths are learned from (docs/13 §5). Live, on this device's data.
  LearningStepsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'learningStepsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$learningStepsHash();

  @$internal
  @override
  $StreamProviderElement<List<Subtask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Subtask>> create(Ref ref) {
    return learningSteps(ref);
  }
}

String _$learningStepsHash() => r'd21d4435651f0bd4431b0fcbb8e2de8e39b1b849';

/// What the history says per task and per step (11 C3, docs/13 §5).

@ProviderFor(learningIndex)
final learningIndexProvider = LearningIndexProvider._();

/// What the history says per task and per step (11 C3, docs/13 §5).

final class LearningIndexProvider
    extends
        $FunctionalProvider<
          AsyncValue<LearningIndex>,
          LearningIndex,
          FutureOr<LearningIndex>
        >
    with $FutureModifier<LearningIndex>, $FutureProvider<LearningIndex> {
  /// What the history says per task and per step (11 C3, docs/13 §5).
  LearningIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'learningIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$learningIndexHash();

  @$internal
  @override
  $FutureProviderElement<LearningIndex> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LearningIndex> create(Ref ref) {
    return learningIndex(ref);
  }
}

String _$learningIndexHash() => r'1869dc2cd7154fd1ad6324709348c19044ae5b74';

@ProviderFor(learningProgress)
final learningProgressProvider = LearningProgressProvider._();

final class LearningProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<LearningProgress>,
          LearningProgress,
          FutureOr<LearningProgress>
        >
    with $FutureModifier<LearningProgress>, $FutureProvider<LearningProgress> {
  LearningProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'learningProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$learningProgressHash();

  @$internal
  @override
  $FutureProviderElement<LearningProgress> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LearningProgress> create(Ref ref) {
    return learningProgress(ref);
  }
}

String _$learningProgressHash() => r'1c5629941497337f9d30c29be51865695f8d99bf';

/// When the user finishes high-energy work best, and how many such tasks
/// it is read from (11 C4, docs/09 M11.5); the window is null under
/// [LearningThresholds.energyMinCompletions].

@ProviderFor(energyWindow)
final energyWindowProvider = EnergyWindowProvider._();

/// When the user finishes high-energy work best, and how many such tasks
/// it is read from (11 C4, docs/09 M11.5); the window is null under
/// [LearningThresholds.energyMinCompletions].

final class EnergyWindowProvider
    extends
        $FunctionalProvider<
          AsyncValue<({int completions, EnergyWindow? window})>,
          ({int completions, EnergyWindow? window}),
          FutureOr<({int completions, EnergyWindow? window})>
        >
    with
        $FutureModifier<({int completions, EnergyWindow? window})>,
        $FutureProvider<({int completions, EnergyWindow? window})> {
  /// When the user finishes high-energy work best, and how many such tasks
  /// it is read from (11 C4, docs/09 M11.5); the window is null under
  /// [LearningThresholds.energyMinCompletions].
  EnergyWindowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'energyWindowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$energyWindowHash();

  @$internal
  @override
  $FutureProviderElement<({int completions, EnergyWindow? window})>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<({int completions, EnergyWindow? window})> create(Ref ref) {
    return energyWindow(ref);
  }
}

String _$energyWindowHash() => r'f752fbeb7aa62bf3c351bf5b5981004fe22cb9e8';
