// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// This device's clock against the server's, from fresh access tokens
/// (M6.5.7); null without a Supabase client.

@ProviderFor(serverClock)
final serverClockProvider = ServerClockProvider._();

/// This device's clock against the server's, from fresh access tokens
/// (M6.5.7); null without a Supabase client.

final class ServerClockProvider
    extends $FunctionalProvider<ServerClock?, ServerClock?, ServerClock?>
    with $Provider<ServerClock?> {
  /// This device's clock against the server's, from fresh access tokens
  /// (M6.5.7); null without a Supabase client.
  ServerClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverClockHash();

  @$internal
  @override
  $ProviderElement<ServerClock?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ServerClock? create(Ref ref) {
    return serverClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerClock? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerClock?>(value),
    );
  }
}

String _$serverClockHash() => r'8ba246abcc7e2197cdb7cc27ba069a1a90505aae';

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

String _$syncServiceHash() => r'f01cfaac8065643abb648834fcfed123965ffafc';

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
