// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window_material.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the Mac app's sidebar shows the system's vibrant material
/// (ED-130): false with Reduce Transparency or Increase Contrast on, on
/// every other target, in tests and if the native side is missing, and the
/// sidebar is painted solid then (macos/Runner `WindowMaterialBridge.swift`).

@ProviderFor(sidebarVibrancy)
final sidebarVibrancyProvider = SidebarVibrancyProvider._();

/// Whether the Mac app's sidebar shows the system's vibrant material
/// (ED-130): false with Reduce Transparency or Increase Contrast on, on
/// every other target, in tests and if the native side is missing, and the
/// sidebar is painted solid then (macos/Runner `WindowMaterialBridge.swift`).

final class SidebarVibrancyProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether the Mac app's sidebar shows the system's vibrant material
  /// (ED-130): false with Reduce Transparency or Increase Contrast on, on
  /// every other target, in tests and if the native side is missing, and the
  /// sidebar is painted solid then (macos/Runner `WindowMaterialBridge.swift`).
  SidebarVibrancyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sidebarVibrancyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sidebarVibrancyHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return sidebarVibrancy(ref);
  }
}

String _$sidebarVibrancyHash() => r'0c62cee69243bc6e9bacab6d7de2a45bc954d18d';

/// The height of the Mac window's transparent title bar, which the content
/// runs under (ED-377): the window buttons sit there and the system drags
/// the window by it, so the app keeps it free of controls. 0 in full
/// screen, on other targets and without the native side.

@ProviderFor(macTitlebar)
final macTitlebarProvider = MacTitlebarProvider._();

/// The height of the Mac window's transparent title bar, which the content
/// runs under (ED-377): the window buttons sit there and the system drags
/// the window by it, so the app keeps it free of controls. 0 in full
/// screen, on other targets and without the native side.

final class MacTitlebarProvider
    extends $FunctionalProvider<AsyncValue<double>, double, Stream<double>>
    with $FutureModifier<double>, $StreamProvider<double> {
  /// The height of the Mac window's transparent title bar, which the content
  /// runs under (ED-377): the window buttons sit there and the system drags
  /// the window by it, so the app keeps it free of controls. 0 in full
  /// screen, on other targets and without the native side.
  MacTitlebarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'macTitlebarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$macTitlebarHash();

  @$internal
  @override
  $StreamProviderElement<double> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<double> create(Ref ref) {
    return macTitlebar(ref);
  }
}

String _$macTitlebarHash() => r'16e05d999d0fa22e1a7088228cb782d00e6009c1';
