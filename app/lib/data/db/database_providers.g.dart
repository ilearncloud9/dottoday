// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where the SQLCipher key comes from. Tests override with a fixed key.

@ProviderFor(databaseKeyStore)
final databaseKeyStoreProvider = DatabaseKeyStoreProvider._();

/// Where the SQLCipher key comes from. Tests override with a fixed key.

final class DatabaseKeyStoreProvider
    extends
        $FunctionalProvider<
          DatabaseKeyStore,
          DatabaseKeyStore,
          DatabaseKeyStore
        >
    with $Provider<DatabaseKeyStore> {
  /// Where the SQLCipher key comes from. Tests override with a fixed key.
  DatabaseKeyStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseKeyStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseKeyStoreHash();

  @$internal
  @override
  $ProviderElement<DatabaseKeyStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DatabaseKeyStore create(Ref ref) {
    return databaseKeyStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DatabaseKeyStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DatabaseKeyStore>(value),
    );
  }
}

String _$databaseKeyStoreHash() => r'44b3265631d505e8ef2cc444ca92e8ba00395dfe';

/// The single [AppDatabase] connection. Opens lazily on the first query;
/// tests override it with `AppDatabase(NativeDatabase.memory())`.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// The single [AppDatabase] connection. Opens lazily on the first query;
/// tests override it with `AppDatabase(NativeDatabase.memory())`.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// The single [AppDatabase] connection. Opens lazily on the first query;
  /// tests override it with `AppDatabase(NativeDatabase.memory())`.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'ea11200f22bd2c689abaa2d56f05d15c6c46d863';
