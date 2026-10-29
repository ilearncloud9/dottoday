// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siri_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether Siri can run Dottoday's five App Intents here (docs/09 M14.3,
/// D3: iPhone only — the Mac has the same intents for Shortcuts, but the
/// owner scoped Siri discoverability to the iPhone). Read in the data
/// layer so widgets never branch on the platform.

@ProviderFor(siriAvailable)
final siriAvailableProvider = SiriAvailableProvider._();

/// Whether Siri can run Dottoday's five App Intents here (docs/09 M14.3,
/// D3: iPhone only — the Mac has the same intents for Shortcuts, but the
/// owner scoped Siri discoverability to the iPhone). Read in the data
/// layer so widgets never branch on the platform.

final class SiriAvailableProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether Siri can run Dottoday's five App Intents here (docs/09 M14.3,
  /// D3: iPhone only — the Mac has the same intents for Shortcuts, but the
  /// owner scoped Siri discoverability to the iPhone). Read in the data
  /// layer so widgets never branch on the platform.
  SiriAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'siriAvailableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$siriAvailableHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return siriAvailable(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$siriAvailableHash() => r'a613bbebed6c9187e12a7dba336ffe2af5d1ccaf';
