// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_prompts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Prompts put away with "Not now", per day, for this session only: a
/// prompt is a suggestion, so it is not worth syncing, and it comes back
/// on the next launch if the day still needs it.

@ProviderFor(DismissedPrompts)
final dismissedPromptsProvider = DismissedPromptsProvider._();

/// Prompts put away with "Not now", per day, for this session only: a
/// prompt is a suggestion, so it is not worth syncing, and it comes back
/// on the next launch if the day still needs it.
final class DismissedPromptsProvider
    extends
        $NotifierProvider<DismissedPrompts, Set<(TodayPromptKind, DateTime)>> {
  /// Prompts put away with "Not now", per day, for this session only: a
  /// prompt is a suggestion, so it is not worth syncing, and it comes back
  /// on the next launch if the day still needs it.
  DismissedPromptsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dismissedPromptsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dismissedPromptsHash();

  @$internal
  @override
  DismissedPrompts create() => DismissedPrompts();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<(TodayPromptKind, DateTime)> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<(TodayPromptKind, DateTime)>>(
        value,
      ),
    );
  }
}

String _$dismissedPromptsHash() => r'6e706c90043b85c8017bff8b2094e21714291b7b';

/// Prompts put away with "Not now", per day, for this session only: a
/// prompt is a suggestion, so it is not worth syncing, and it comes back
/// on the next launch if the day still needs it.

abstract class _$DismissedPrompts
    extends $Notifier<Set<(TodayPromptKind, DateTime)>> {
  Set<(TodayPromptKind, DateTime)> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Set<(TodayPromptKind, DateTime)>,
              Set<(TodayPromptKind, DateTime)>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Set<(TodayPromptKind, DateTime)>,
                Set<(TodayPromptKind, DateTime)>
              >,
              Set<(TodayPromptKind, DateTime)>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
