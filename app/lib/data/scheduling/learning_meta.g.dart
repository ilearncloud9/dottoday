// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_meta.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [LearningMetaState] in `local_meta` (as `InboxNudgeSeen`): each write
/// is persisted before the state is published, and awaited. Kept under
/// `<key>:<ownerId>` for the owner shown and rebuilt at every change of
/// owner (CR-160); the keys below are the kinds.

@ProviderFor(LearningMeta)
final learningMetaProvider = LearningMetaProvider._();

/// [LearningMetaState] in `local_meta` (as `InboxNudgeSeen`): each write
/// is persisted before the state is published, and awaited. Kept under
/// `<key>:<ownerId>` for the owner shown and rebuilt at every change of
/// owner (CR-160); the keys below are the kinds.
final class LearningMetaProvider
    extends $AsyncNotifierProvider<LearningMeta, LearningMetaState> {
  /// [LearningMetaState] in `local_meta` (as `InboxNudgeSeen`): each write
  /// is persisted before the state is published, and awaited. Kept under
  /// `<key>:<ownerId>` for the owner shown and rebuilt at every change of
  /// owner (CR-160); the keys below are the kinds.
  LearningMetaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'learningMetaProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$learningMetaHash();

  @$internal
  @override
  LearningMeta create() => LearningMeta();
}

String _$learningMetaHash() => r'b13e6bcf5eda8d8f753c6e84d0e1400277ed9063';

/// [LearningMetaState] in `local_meta` (as `InboxNudgeSeen`): each write
/// is persisted before the state is published, and awaited. Kept under
/// `<key>:<ownerId>` for the owner shown and rebuilt at every change of
/// owner (CR-160); the keys below are the kinds.

abstract class _$LearningMeta extends $AsyncNotifier<LearningMetaState> {
  FutureOr<LearningMetaState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<LearningMetaState>, LearningMetaState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LearningMetaState>, LearningMetaState>,
              AsyncValue<LearningMetaState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
