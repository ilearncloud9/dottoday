// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'first_today_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// This device's first Today (see [FirstTodayState]).

@ProviderFor(FirstToday)
final firstTodayProvider = FirstTodayProvider._();

/// This device's first Today (see [FirstTodayState]).
final class FirstTodayProvider
    extends $AsyncNotifierProvider<FirstToday, FirstTodayState> {
  /// This device's first Today (see [FirstTodayState]).
  FirstTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firstTodayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firstTodayHash();

  @$internal
  @override
  FirstToday create() => FirstToday();
}

String _$firstTodayHash() => r'1b76b4f4b2a572cdfdeec3b7528f3a5680c962f8';

/// This device's first Today (see [FirstTodayState]).

abstract class _$FirstToday extends $AsyncNotifier<FirstTodayState> {
  FutureOr<FirstTodayState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FirstTodayState>, FirstTodayState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FirstTodayState>, FirstTodayState>,
              AsyncValue<FirstTodayState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The link between the hinted task's done circle and the hint.

@ProviderFor(firstTodayLink)
final firstTodayLinkProvider = FirstTodayLinkProvider._();

/// The link between the hinted task's done circle and the hint.

final class FirstTodayLinkProvider
    extends $FunctionalProvider<LayerLink, LayerLink, LayerLink>
    with $Provider<LayerLink> {
  /// The link between the hinted task's done circle and the hint.
  FirstTodayLinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firstTodayLinkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firstTodayLinkHash();

  @$internal
  @override
  $ProviderElement<LayerLink> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LayerLink create(Ref ref) {
    return firstTodayLink(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LayerLink value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LayerLink>(value),
    );
  }
}

String _$firstTodayLinkHash() => r'0e618ce1cbc6a88a6f739a7ff57d98447fa263ab';
