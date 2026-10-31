// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Wind Down write of the day snapshot (docs/09 M9.1).

@ProviderFor(windDownSnapshot)
final windDownSnapshotProvider = WindDownSnapshotProvider._();

/// The Wind Down write of the day snapshot (docs/09 M9.1).

final class WindDownSnapshotProvider
    extends
        $FunctionalProvider<
          WindDownSnapshot,
          WindDownSnapshot,
          WindDownSnapshot
        >
    with $Provider<WindDownSnapshot> {
  /// The Wind Down write of the day snapshot (docs/09 M9.1).
  WindDownSnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'windDownSnapshotProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$windDownSnapshotHash();

  @$internal
  @override
  $ProviderElement<WindDownSnapshot> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WindDownSnapshot create(Ref ref) {
    return windDownSnapshot(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WindDownSnapshot value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WindDownSnapshot>(value),
    );
  }
}

String _$windDownSnapshotHash() => r'33d8f320b2b8a1ce8ea3ba3f2383075e07457de3';
