// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'install_prompt.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the web app may offer to install itself (docs/07 Web "install
/// prompt after 2nd visit", M5.7); always false off the web.

@ProviderFor(installAvailable)
final installAvailableProvider = InstallAvailableProvider._();

/// Whether the web app may offer to install itself (docs/07 Web "install
/// prompt after 2nd visit", M5.7); always false off the web.

final class InstallAvailableProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether the web app may offer to install itself (docs/07 Web "install
  /// prompt after 2nd visit", M5.7); always false off the web.
  InstallAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'installAvailableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$installAvailableHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return installAvailable(ref);
  }
}

String _$installAvailableHash() => r'7e51c38797e78ac371f711e210d8430242210739';

@ProviderFor(installPrompt)
final installPromptProvider = InstallPromptProvider._();

final class InstallPromptProvider
    extends $FunctionalProvider<InstallPrompt, InstallPrompt, InstallPrompt>
    with $Provider<InstallPrompt> {
  InstallPromptProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'installPromptProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$installPromptHash();

  @$internal
  @override
  $ProviderElement<InstallPrompt> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InstallPrompt create(Ref ref) {
    return installPrompt(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InstallPrompt value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InstallPrompt>(value),
    );
  }
}

String _$installPromptHash() => r'ed6996a4d2d023952e10d13db9dd2c91007417c2';
