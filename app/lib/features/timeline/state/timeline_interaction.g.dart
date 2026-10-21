// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_interaction.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TimelineInteraction)
final timelineInteractionProvider = TimelineInteractionProvider._();

final class TimelineInteractionProvider
    extends $NotifierProvider<TimelineInteraction, InteractionState> {
  TimelineInteractionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timelineInteractionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timelineInteractionHash();

  @$internal
  @override
  TimelineInteraction create() => TimelineInteraction();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InteractionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InteractionState>(value),
    );
  }
}

String _$timelineInteractionHash() =>
    r'767c43093b94193af5d5f662cea2a8b8c4e1adee';

abstract class _$TimelineInteraction extends $Notifier<InteractionState> {
  InteractionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<InteractionState, InteractionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InteractionState, InteractionState>,
              InteractionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
