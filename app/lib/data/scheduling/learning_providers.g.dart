// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's last [learningHistoryDays] days, live: what learning (11 C3)
/// and energy suggestions (11 C4) read. On this device's data only.

@ProviderFor(learningHistory)
final learningHistoryProvider = LearningHistoryProvider._();

/// The user's last [learningHistoryDays] days, live: what learning (11 C3)
/// and energy suggestions (11 C4) read. On this device's data only.

final class LearningHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Occurrence>>,
          List<Occurrence>,
          Stream<List<Occurrence>>
        >
    with $FutureModifier<List<Occurrence>>, $StreamProvider<List<Occurrence>> {
  /// The user's last [learningHistoryDays] days, live: what learning (11 C3)
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

String _$learningHistoryHash() => r'df54c12070e551635615e5cc6b4f0c46e287852d';

/// What the history says per task (11 C3, docs/09 M11.3).

@ProviderFor(learningIndex)
final learningIndexProvider = LearningIndexProvider._();

/// What the history says per task (11 C3, docs/09 M11.3).

final class LearningIndexProvider
    extends
        $FunctionalProvider<
          AsyncValue<LearningIndex>,
          LearningIndex,
          FutureOr<LearningIndex>
        >
    with $FutureModifier<LearningIndex>, $FutureProvider<LearningIndex> {
  /// What the history says per task (11 C3, docs/09 M11.3).
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

String _$learningIndexHash() => r'd9c16f137452e371419555decbd39d86e82ed04c';

/// When the user finishes high-energy work best, and how many such tasks
/// it is read from (11 C4, docs/09 M11.5); the window is null under
/// [energyMinCompletions].

@ProviderFor(energyWindow)
final energyWindowProvider = EnergyWindowProvider._();

/// When the user finishes high-energy work best, and how many such tasks
/// it is read from (11 C4, docs/09 M11.5); the window is null under
/// [energyMinCompletions].

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
  /// [energyMinCompletions].
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

String _$energyWindowHash() => r'8a6486f9b9d7b6a6892a155733d45e699a08385d';
