// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_window.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(secureWindow)
final secureWindowProvider = SecureWindowProvider._();

final class SecureWindowProvider
    extends $FunctionalProvider<SecureWindow, SecureWindow, SecureWindow>
    with $Provider<SecureWindow> {
  SecureWindowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureWindowProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureWindowHash();

  @$internal
  @override
  $ProviderElement<SecureWindow> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SecureWindow create(Ref ref) {
    return secureWindow(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureWindow value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureWindow>(value),
    );
  }
}

String _$secureWindowHash() => r'3cc0e827c54c0d0bc35eac67c9bf4fe77b581f4e';
