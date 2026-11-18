// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frosted_chrome.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether Android's floating chrome may be frosted (ED-125, ED-128 D5):
/// Android 12 and later; older devices, a failed ask and every other
/// platform get the solid tonal fills.

@ProviderFor(frostedChrome)
final frostedChromeProvider = FrostedChromeProvider._();

/// Whether Android's floating chrome may be frosted (ED-125, ED-128 D5):
/// Android 12 and later; older devices, a failed ask and every other
/// platform get the solid tonal fills.

final class FrostedChromeProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether Android's floating chrome may be frosted (ED-125, ED-128 D5):
  /// Android 12 and later; older devices, a failed ask and every other
  /// platform get the solid tonal fills.
  FrostedChromeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'frostedChromeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$frostedChromeHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return frostedChrome(ref);
  }
}

String _$frostedChromeHash() => r'a964825b60d607c9855f760b00bd19099f2bc429';
