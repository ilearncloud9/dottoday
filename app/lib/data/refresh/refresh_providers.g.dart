// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dailyRefresh)
final dailyRefreshProvider = DailyRefreshProvider._();

final class DailyRefreshProvider
    extends $FunctionalProvider<DailyRefresh, DailyRefresh, DailyRefresh>
    with $Provider<DailyRefresh> {
  DailyRefreshProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyRefreshProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyRefreshHash();

  @$internal
  @override
  $ProviderElement<DailyRefresh> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DailyRefresh create(Ref ref) {
    return dailyRefresh(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DailyRefresh value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DailyRefresh>(value),
    );
  }
}

String _$dailyRefreshHash() => r'd10e92f82a6c35a2e7efbffcfe214b582799d523';

/// The background job's one-shot sync (M6.5.6). Null in the app, which
/// syncs through `EngineSyncService`; `backgroundRefreshDispatcher`
/// overrides it.

@ProviderFor(backgroundSync)
final backgroundSyncProvider = BackgroundSyncProvider._();

/// The background job's one-shot sync (M6.5.6). Null in the app, which
/// syncs through `EngineSyncService`; `backgroundRefreshDispatcher`
/// overrides it.

final class BackgroundSyncProvider
    extends
        $FunctionalProvider<BackgroundSync?, BackgroundSync?, BackgroundSync?>
    with $Provider<BackgroundSync?> {
  /// The background job's one-shot sync (M6.5.6). Null in the app, which
  /// syncs through `EngineSyncService`; `backgroundRefreshDispatcher`
  /// overrides it.
  BackgroundSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backgroundSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backgroundSyncHash();

  @$internal
  @override
  $ProviderElement<BackgroundSync?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackgroundSync? create(Ref ref) {
    return backgroundSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackgroundSync? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackgroundSync?>(value),
    );
  }
}

String _$backgroundSyncHash() => r'aaaa19fa9bc5916501688a1e90b67f3164f571eb';
