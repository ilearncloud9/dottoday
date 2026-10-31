// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The stored layout (docs/14 §6), full until the profile has loaded.
/// Only the layout switch and [layoutPolicy] read it; Views ask the policy.

@ProviderFor(uiLayout)
final uiLayoutProvider = UiLayoutProvider._();

/// The stored layout (docs/14 §6), full until the profile has loaded.
/// Only the layout switch and [layoutPolicy] read it; Views ask the policy.

final class UiLayoutProvider
    extends $FunctionalProvider<UiLayout, UiLayout, UiLayout>
    with $Provider<UiLayout> {
  /// The stored layout (docs/14 §6), full until the profile has loaded.
  /// Only the layout switch and [layoutPolicy] read it; Views ask the policy.
  UiLayoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uiLayoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uiLayoutHash();

  @$internal
  @override
  $ProviderElement<UiLayout> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UiLayout create(Ref ref) {
    return uiLayout(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UiLayout value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UiLayout>(value),
    );
  }
}

String _$uiLayoutHash() => r'01f211a066ec576b7014090491ee1a76cbdbd030';

/// The visibility policy for the stored layout (ADR-0016).

@ProviderFor(layoutPolicy)
final layoutPolicyProvider = LayoutPolicyProvider._();

/// The visibility policy for the stored layout (ADR-0016).

final class LayoutPolicyProvider
    extends $FunctionalProvider<LayoutPolicy, LayoutPolicy, LayoutPolicy>
    with $Provider<LayoutPolicy> {
  /// The visibility policy for the stored layout (ADR-0016).
  LayoutPolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'layoutPolicyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$layoutPolicyHash();

  @$internal
  @override
  $ProviderElement<LayoutPolicy> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LayoutPolicy create(Ref ref) {
    return layoutPolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LayoutPolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LayoutPolicy>(value),
    );
  }
}

String _$layoutPolicyHash() => r'bbc6025a2ccd6c0f9f4ce29fa33407e32e2704c5';
