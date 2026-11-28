// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reduce_transparency.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the system's Reduce Transparency is on (ED-248 C), which
/// Flutter does not report: asked of iOS and macOS
/// (`ReduceTransparencyBridge.swift`) and of the browser; false on Android
/// (it has no such setting; its blur switch is `frostedChrome`), in tests
/// and when the native side is missing.

@ProviderFor(reduceTransparency)
final reduceTransparencyProvider = ReduceTransparencyProvider._();

/// Whether the system's Reduce Transparency is on (ED-248 C), which
/// Flutter does not report: asked of iOS and macOS
/// (`ReduceTransparencyBridge.swift`) and of the browser; false on Android
/// (it has no such setting; its blur switch is `frostedChrome`), in tests
/// and when the native side is missing.

final class ReduceTransparencyProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether the system's Reduce Transparency is on (ED-248 C), which
  /// Flutter does not report: asked of iOS and macOS
  /// (`ReduceTransparencyBridge.swift`) and of the browser; false on Android
  /// (it has no such setting; its blur switch is `frostedChrome`), in tests
  /// and when the native side is missing.
  ReduceTransparencyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reduceTransparencyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reduceTransparencyHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return reduceTransparency(ref);
  }
}

String _$reduceTransparencyHash() =>
    r'591b1c9bb14795a4a0ca6c284909244df1211bec';
