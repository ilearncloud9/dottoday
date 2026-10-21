// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The encrypted backups file. Tests override with an in-memory database.

@ProviderFor(backupDatabase)
final backupDatabaseProvider = BackupDatabaseProvider._();

/// The encrypted backups file. Tests override with an in-memory database.

final class BackupDatabaseProvider
    extends $FunctionalProvider<BackupDatabase, BackupDatabase, BackupDatabase>
    with $Provider<BackupDatabase> {
  /// The encrypted backups file. Tests override with an in-memory database.
  BackupDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupDatabaseHash();

  @$internal
  @override
  $ProviderElement<BackupDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupDatabase create(Ref ref) {
    return backupDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupDatabase>(value),
    );
  }
}

String _$backupDatabaseHash() => r'940c7f8591bb3c33617149a930ba27200c067d58';

@ProviderFor(backupService)
final backupServiceProvider = BackupServiceProvider._();

final class BackupServiceProvider
    extends $FunctionalProvider<BackupService, BackupService, BackupService>
    with $Provider<BackupService> {
  BackupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupServiceHash();

  @$internal
  @override
  $ProviderElement<BackupService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupService create(Ref ref) {
    return backupService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupService>(value),
    );
  }
}

String _$backupServiceHash() => r'436a9c0e5bd4400998acee6deb2bd726c9e5d901';
