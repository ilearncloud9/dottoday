// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_health.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The database's health, checked with a first query; and the recovery
/// steps. The app shows its screens only while [DatabaseReady].

@ProviderFor(DatabaseStatus)
final databaseStatusProvider = DatabaseStatusProvider._();

/// The database's health, checked with a first query; and the recovery
/// steps. The app shows its screens only while [DatabaseReady].
final class DatabaseStatusProvider
    extends $AsyncNotifierProvider<DatabaseStatus, DatabaseHealth> {
  /// The database's health, checked with a first query; and the recovery
  /// steps. The app shows its screens only while [DatabaseReady].
  DatabaseStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseStatusHash();

  @$internal
  @override
  DatabaseStatus create() => DatabaseStatus();
}

String _$databaseStatusHash() => r'dee79538089b7632343832e29bacc4262af69ecc';

/// The database's health, checked with a first query; and the recovery
/// steps. The app shows its screens only while [DatabaseReady].

abstract class _$DatabaseStatus extends $AsyncNotifier<DatabaseHealth> {
  FutureOr<DatabaseHealth> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DatabaseHealth>, DatabaseHealth>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DatabaseHealth>, DatabaseHealth>,
              AsyncValue<DatabaseHealth>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
