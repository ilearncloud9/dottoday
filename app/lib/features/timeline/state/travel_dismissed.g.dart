// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_dismissed.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Occurrence ids whose travel time suggestion was put away with "Not
/// now" (docs/09 M7.5), for this session only, as Today's prompts are: a
/// suggestion is not worth syncing, and it comes back on the next launch.

@ProviderFor(DismissedTravel)
final dismissedTravelProvider = DismissedTravelProvider._();

/// Occurrence ids whose travel time suggestion was put away with "Not
/// now" (docs/09 M7.5), for this session only, as Today's prompts are: a
/// suggestion is not worth syncing, and it comes back on the next launch.
final class DismissedTravelProvider
    extends $NotifierProvider<DismissedTravel, Set<String>> {
  /// Occurrence ids whose travel time suggestion was put away with "Not
  /// now" (docs/09 M7.5), for this session only, as Today's prompts are: a
  /// suggestion is not worth syncing, and it comes back on the next launch.
  DismissedTravelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dismissedTravelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dismissedTravelHash();

  @$internal
  @override
  DismissedTravel create() => DismissedTravel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$dismissedTravelHash() => r'45ff823c5dabfd508dcac41f2045da2cd3f4401a';

/// Occurrence ids whose travel time suggestion was put away with "Not
/// now" (docs/09 M7.5), for this session only, as Today's prompts are: a
/// suggestion is not worth syncing, and it comes back on the next launch.

abstract class _$DismissedTravel extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
