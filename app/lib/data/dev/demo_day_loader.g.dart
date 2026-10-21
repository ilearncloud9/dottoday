// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demo_day_loader.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(demoDayLoader)
final demoDayLoaderProvider = DemoDayLoaderProvider._();

final class DemoDayLoaderProvider
    extends $FunctionalProvider<DemoDayLoader, DemoDayLoader, DemoDayLoader>
    with $Provider<DemoDayLoader> {
  DemoDayLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'demoDayLoaderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$demoDayLoaderHash();

  @$internal
  @override
  $ProviderElement<DemoDayLoader> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DemoDayLoader create(Ref ref) {
    return demoDayLoader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DemoDayLoader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DemoDayLoader>(value),
    );
  }
}

String _$demoDayLoaderHash() => r'a92b4eb1907877d1c3a4165b3d5b1786da0e9ecc';
