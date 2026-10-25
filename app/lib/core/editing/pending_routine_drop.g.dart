// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_routine_drop.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The routine drop waiting for the host in the app shell, which opens
/// its proposal and clears it (as `ActiveProposal`).

@ProviderFor(PendingRoutineDrop)
final pendingRoutineDropProvider = PendingRoutineDropProvider._();

/// The routine drop waiting for the host in the app shell, which opens
/// its proposal and clears it (as `ActiveProposal`).
final class PendingRoutineDropProvider
    extends $NotifierProvider<PendingRoutineDrop, RoutineDropRequest?> {
  /// The routine drop waiting for the host in the app shell, which opens
  /// its proposal and clears it (as `ActiveProposal`).
  PendingRoutineDropProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingRoutineDropProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingRoutineDropHash();

  @$internal
  @override
  PendingRoutineDrop create() => PendingRoutineDrop();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoutineDropRequest? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoutineDropRequest?>(value),
    );
  }
}

String _$pendingRoutineDropHash() =>
    r'88fa21bf0108c077877abde20498bf4e630caa87';

/// The routine drop waiting for the host in the app shell, which opens
/// its proposal and clears it (as `ActiveProposal`).

abstract class _$PendingRoutineDrop extends $Notifier<RoutineDropRequest?> {
  RoutineDropRequest? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RoutineDropRequest?, RoutineDropRequest?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RoutineDropRequest?, RoutineDropRequest?>,
              RoutineDropRequest?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
