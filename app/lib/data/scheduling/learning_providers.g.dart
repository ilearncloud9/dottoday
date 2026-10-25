// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the user's last [learningHistoryDays] days of actual timestamps
/// say per task (11 C3, docs/09 M11.3), live. On this device's data only.

@ProviderFor(learningIndex)
final learningIndexProvider = LearningIndexProvider._();

/// What the user's last [learningHistoryDays] days of actual timestamps
/// say per task (11 C3, docs/09 M11.3), live. On this device's data only.

final class LearningIndexProvider
    extends
        $FunctionalProvider<
          AsyncValue<LearningIndex>,
          LearningIndex,
          Stream<LearningIndex>
        >
    with $FutureModifier<LearningIndex>, $StreamProvider<LearningIndex> {
  /// What the user's last [learningHistoryDays] days of actual timestamps
  /// say per task (11 C3, docs/09 M11.3), live. On this device's data only.
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
  $StreamProviderElement<LearningIndex> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<LearningIndex> create(Ref ref) {
    return learningIndex(ref);
  }
}

String _$learningIndexHash() => r'0adb884c8bd919b01fb6ecee3e6473c97e1cbae2';
