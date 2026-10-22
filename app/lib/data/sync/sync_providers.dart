import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_providers.g.dart';

/// Until accounts and the sync engine arrive (M6.1 / M6.3): always local
/// only, with nothing to sync or resolve.
final class LocalOnlySyncService implements SyncService {
  const LocalOnlySyncService();

  @override
  Stream<SyncStatus> watch() => Stream.value(SyncStatus.localOnly);

  @override
  Future<Result<void, AppFailure>> syncNow() async => const Ok(null);

  @override
  Future<Result<void, AppFailure>> resolve(
    String id,
    ConflictChoice choice,
  ) async => const Err(AuthFailure());
}

@Riverpod(keepAlive: true)
SyncService syncService(Ref ref) => const LocalOnlySyncService();

/// Sync as it stands, live.
@Riverpod(keepAlive: true)
Stream<SyncStatus> syncStatus(Ref ref) =>
    ref.watch(syncServiceProvider).watch();
