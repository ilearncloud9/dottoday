// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native_tab_bar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The iPhone's native row (ED-128 N3) when this is an iPhone that has
/// it; null elsewhere, in tests and if the native side is missing, and
/// the shell keeps its Flutter bar.

@ProviderFor(nativeBar)
final nativeBarProvider = NativeBarProvider._();

/// The iPhone's native row (ED-128 N3) when this is an iPhone that has
/// it; null elsewhere, in tests and if the native side is missing, and
/// the shell keeps its Flutter bar.

final class NativeBarProvider
    extends
        $FunctionalProvider<
          AsyncValue<NativeBar?>,
          NativeBar?,
          FutureOr<NativeBar?>
        >
    with $FutureModifier<NativeBar?>, $FutureProvider<NativeBar?> {
  /// The iPhone's native row (ED-128 N3) when this is an iPhone that has
  /// it; null elsewhere, in tests and if the native side is missing, and
  /// the shell keeps its Flutter bar.
  NativeBarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nativeBarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nativeBarHash();

  @$internal
  @override
  $FutureProviderElement<NativeBar?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<NativeBar?> create(Ref ref) {
    return nativeBar(ref);
  }
}

String _$nativeBarHash() => r'b813eb2504cbf42c3969d7008fa8854b1794fde8';
