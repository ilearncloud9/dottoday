// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native_tab_bar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The native navigation when this device has one: the iPhone's row
/// (ED-128 N3) or the iPad's tabs and sidebar (iPadOS 18+); null
/// elsewhere, in tests and if the native side is missing, and the shell
/// keeps its Flutter bars.

@ProviderFor(nativeBar)
final nativeBarProvider = NativeBarProvider._();

/// The native navigation when this device has one: the iPhone's row
/// (ED-128 N3) or the iPad's tabs and sidebar (iPadOS 18+); null
/// elsewhere, in tests and if the native side is missing, and the shell
/// keeps its Flutter bars.

final class NativeBarProvider
    extends
        $FunctionalProvider<
          AsyncValue<NativeBar?>,
          NativeBar?,
          FutureOr<NativeBar?>
        >
    with $FutureModifier<NativeBar?>, $FutureProvider<NativeBar?> {
  /// The native navigation when this device has one: the iPhone's row
  /// (ED-128 N3) or the iPad's tabs and sidebar (iPadOS 18+); null
  /// elsewhere, in tests and if the native side is missing, and the shell
  /// keeps its Flutter bars.
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

String _$nativeBarHash() => r'c097952d224f20a025b503962a6ae7f91af8b3ea';
