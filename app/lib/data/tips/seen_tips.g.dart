// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seen_tips.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The [Tip]s put away on this device. Each write is persisted before the
/// state is published, and awaited (as `LearningMeta`).

@ProviderFor(SeenTips)
final seenTipsProvider = SeenTipsProvider._();

/// The [Tip]s put away on this device. Each write is persisted before the
/// state is published, and awaited (as `LearningMeta`).
final class SeenTipsProvider
    extends $AsyncNotifierProvider<SeenTips, Set<Tip>> {
  /// The [Tip]s put away on this device. Each write is persisted before the
  /// state is published, and awaited (as `LearningMeta`).
  SeenTipsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seenTipsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seenTipsHash();

  @$internal
  @override
  SeenTips create() => SeenTips();
}

String _$seenTipsHash() => r'134dd4a559e5a307f86b1bf837c9b66d72ae3470';

/// The [Tip]s put away on this device. Each write is persisted before the
/// state is published, and awaited (as `LearningMeta`).

abstract class _$SeenTips extends $AsyncNotifier<Set<Tip>> {
  FutureOr<Set<Tip>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<Tip>>, Set<Tip>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<Tip>>, Set<Tip>>,
              AsyncValue<Set<Tip>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
