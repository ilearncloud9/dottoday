// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'touch_content.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the browser's primary pointer is coarse, kept current while
/// the page is open; never on a native build (ED-261).

@ProviderFor(coarsePointer)
final coarsePointerProvider = CoarsePointerProvider._();

/// Whether the browser's primary pointer is coarse, kept current while
/// the page is open; never on a native build (ED-261).

final class CoarsePointerProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether the browser's primary pointer is coarse, kept current while
  /// the page is open; never on a native build (ED-261).
  CoarsePointerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coarsePointerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coarsePointerHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return coarsePointer(ref);
  }
}

String _$coarsePointerHash() => r'b471e538d91e85f1f69dd0229176df8c92e69352';
