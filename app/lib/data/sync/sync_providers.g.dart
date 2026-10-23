// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sync for the signed-in account (docs/09 M6.2): the engine over
/// Supabase, idle while signed out.

@ProviderFor(syncService)
final syncServiceProvider = SyncServiceProvider._();

/// Sync for the signed-in account (docs/09 M6.2): the engine over
/// Supabase, idle while signed out.

final class SyncServiceProvider
    extends $FunctionalProvider<SyncService, SyncService, SyncService>
    with $Provider<SyncService> {
  /// Sync for the signed-in account (docs/09 M6.2): the engine over
  /// Supabase, idle while signed out.
  SyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncServiceHash();

  @$internal
  @override
  $ProviderElement<SyncService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncService create(Ref ref) {
    return syncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncService>(value),
    );
  }
}

String _$syncServiceHash() => r'6cb9fe2b617b9b22321814619474267d5dc0d691';

/// Sync as it stands, live.

@ProviderFor(syncStatus)
final syncStatusProvider = SyncStatusProvider._();

/// Sync as it stands, live.

final class SyncStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<SyncStatus>,
          SyncStatus,
          Stream<SyncStatus>
        >
    with $FutureModifier<SyncStatus>, $StreamProvider<SyncStatus> {
  /// Sync as it stands, live.
  SyncStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStatusHash();

  @$internal
  @override
  $StreamProviderElement<SyncStatus> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<SyncStatus> create(Ref ref) {
    return syncStatus(ref);
  }
}

String _$syncStatusHash() => r'87d27c3e882aaea1032a622f6a20b8f5aafcd275';
