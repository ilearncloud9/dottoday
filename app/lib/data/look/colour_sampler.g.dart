// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'colour_sampler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The sampler for this platform (a fake in tests).

@ProviderFor(colourSampler)
final colourSamplerProvider = ColourSamplerProvider._();

/// The sampler for this platform (a fake in tests).

final class ColourSamplerProvider
    extends $FunctionalProvider<ColourSampler, ColourSampler, ColourSampler>
    with $Provider<ColourSampler> {
  /// The sampler for this platform (a fake in tests).
  ColourSamplerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'colourSamplerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$colourSamplerHash();

  @$internal
  @override
  $ProviderElement<ColourSampler> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ColourSampler create(Ref ref) {
    return colourSampler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ColourSampler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ColourSampler>(value),
    );
  }
}

String _$colourSamplerHash() => r'96002921ace9f0f184dca9f2fd3874c236cc4d6e';
