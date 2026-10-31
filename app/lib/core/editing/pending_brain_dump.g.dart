// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_brain_dump.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Lines typed into minimal Add (docs/14 §3 B4 "The Add field accepts
/// several lines and opens the proposal"), waiting for the host in the
/// app shell to open Brain dump with them and clear it (as
/// `PendingRoutineDrop`).

@ProviderFor(PendingBrainDump)
final pendingBrainDumpProvider = PendingBrainDumpProvider._();

/// Lines typed into minimal Add (docs/14 §3 B4 "The Add field accepts
/// several lines and opens the proposal"), waiting for the host in the
/// app shell to open Brain dump with them and clear it (as
/// `PendingRoutineDrop`).
final class PendingBrainDumpProvider
    extends $NotifierProvider<PendingBrainDump, String?> {
  /// Lines typed into minimal Add (docs/14 §3 B4 "The Add field accepts
  /// several lines and opens the proposal"), waiting for the host in the
  /// app shell to open Brain dump with them and clear it (as
  /// `PendingRoutineDrop`).
  PendingBrainDumpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingBrainDumpProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingBrainDumpHash();

  @$internal
  @override
  PendingBrainDump create() => PendingBrainDump();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pendingBrainDumpHash() => r'b282e61e15b35e38114410037b8b1ece40e041c8';

/// Lines typed into minimal Add (docs/14 §3 B4 "The Add field accepts
/// several lines and opens the proposal"), waiting for the host in the
/// app shell to open Brain dump with them and clear it (as
/// `PendingRoutineDrop`).

abstract class _$PendingBrainDump extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
