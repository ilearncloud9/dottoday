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

String _$sidebarVibrancyHash() => r'a0ed3082c9dd70e3f93136e1813737ab0f1761a3';
