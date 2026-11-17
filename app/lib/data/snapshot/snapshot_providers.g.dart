// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Wind Down write of the day snapshot (docs/09 M9.1). One per owner
/// shown: a change of owner disposes it, cancelling the armed timer, which
/// was armed at the old owner's Wind Down (CR-160 I7); the switch arms the
/// new one.

@ProviderFor(windDownSnapshot)
final windDownSnapshotProvider = WindDownSnapshotProvider._();

/// The Wind Down write of the day snapshot (docs/09 M9.1). One per owner
/// shown: a change of owner disposes it, cancelling the armed timer, which
/// was armed at the old owner's Wind Down (CR-160 I7); the switch arms the
/// new one.

final class WindDownSnapshotProvider
    extends
        $FunctionalProvider<
          WindDownSnapshot,
          WindDownSnapshot,
          WindDownSnapshot
        >
    with $Provider<WindDownSnapshot> {
  /// The Wind Down write of the day snapshot (docs/09 M9.1). One per owner
  /// shown: a change of owner disposes it, cancelling the armed timer, which
  /// was armed at the old owner's Wind Down (CR-160 I7); the switch arms the
  /// new one.
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

String _$windDownSnapshotHash() => r'9f959219c861f841e153459729abb0392dd7b4ad';
