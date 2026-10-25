// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Deep work's quiet mode for this build (docs/09 M10.5).

@ProviderFor(deepWorkGateway)
final deepWorkGatewayProvider = DeepWorkGatewayProvider._();

/// Deep work's quiet mode for this build (docs/09 M10.5).

final class DeepWorkGatewayProvider
    extends
        $FunctionalProvider<DeepWorkGateway, DeepWorkGateway, DeepWorkGateway>
    with $Provider<DeepWorkGateway> {
  /// Deep work's quiet mode for this build (docs/09 M10.5).
  DeepWorkGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deepWorkGatewayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deepWorkGatewayHash();

  @$internal
  @override
  $ProviderElement<DeepWorkGateway> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeepWorkGateway create(Ref ref) {
    return deepWorkGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeepWorkGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeepWorkGateway>(value),
    );
  }
}

String _$deepWorkGatewayHash() => r'b54898f9f1d404292d4973ac09521d4580cc9922';

/// Deep work here now; re-read with `ref.invalidate` after Settings.

@ProviderFor(deepWorkStatus)
final deepWorkStatusProvider = DeepWorkStatusProvider._();

/// Deep work here now; re-read with `ref.invalidate` after Settings.

final class DeepWorkStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeepWorkStatus>,
          DeepWorkStatus,
          FutureOr<DeepWorkStatus>
        >
    with $FutureModifier<DeepWorkStatus>, $FutureProvider<DeepWorkStatus> {
  /// Deep work here now; re-read with `ref.invalidate` after Settings.
  DeepWorkStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deepWorkStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deepWorkStatusHash();

  @$internal
  @override
  $FutureProviderElement<DeepWorkStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeepWorkStatus> create(Ref ref) {
    return deepWorkStatus(ref);
  }
}

String _$deepWorkStatusHash() => r'e8a8f54756694bd7dba69c6d0db1a4781404047b';

/// Focus's "Chime every 15 min" (off by default, 11 A3): a sound on this
/// device, so remembered here only (`local_meta`), never synced.

@ProviderFor(FocusChime)
final focusChimeProvider = FocusChimeProvider._();

/// Focus's "Chime every 15 min" (off by default, 11 A3): a sound on this
/// device, so remembered here only (`local_meta`), never synced.
final class FocusChimeProvider
    extends $AsyncNotifierProvider<FocusChime, bool> {
  /// Focus's "Chime every 15 min" (off by default, 11 A3): a sound on this
  /// device, so remembered here only (`local_meta`), never synced.
  FocusChimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusChimeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusChimeHash();

  @$internal
  @override
  FocusChime create() => FocusChime();
}

String _$focusChimeHash() => r'3dfdec5c20ed172530f9f9ea330f82efc87849f7';

/// Focus's "Chime every 15 min" (off by default, 11 A3): a sound on this
/// device, so remembered here only (`local_meta`), never synced.

abstract class _$FocusChime extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
