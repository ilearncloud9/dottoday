// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Wind Down write of the day snapshot (docs/09 M9.1).

@ProviderFor(bedtimeSnapshot)
final bedtimeSnapshotProvider = BedtimeSnapshotProvider._();

/// The Wind Down write of the day snapshot (docs/09 M9.1).

final class BedtimeSnapshotProvider
    extends
        $FunctionalProvider<BedtimeSnapshot, BedtimeSnapshot, BedtimeSnapshot>
    with $Provider<BedtimeSnapshot> {
  /// The Wind Down write of the day snapshot (docs/09 M9.1).
  BedtimeSnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bedtimeSnapshotProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bedtimeSnapshotHash();

  @$internal
  @override
  $ProviderElement<BedtimeSnapshot> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BedtimeSnapshot create(Ref ref) {
    return bedtimeSnapshot(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BedtimeSnapshot value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BedtimeSnapshot>(value),
    );
  }
}

String _$bedtimeSnapshotHash() => r'96bafcaa05a226ae3072c462f45408aa31becdfe';
