import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/auth/account_providers.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/sync/account_adoption.dart';
import 'package:dottoday/data/sync/drift_conflict_store.dart';
import 'package:dottoday/data/sync/engine_sync_service.dart';
import 'package:dottoday/data/sync/supabase_sync_gateway.dart';
import 'package:dottoday/data/sync/sync_engine.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'sync_providers.g.dart';

/// No Supabase client (tests, or it couldn't start): always local only,
/// with nothing to sync or resolve.
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

  @override
  Stream<RestoreProgress> watchRestore() =>
      Stream.value(const RestoreProgress(done: 0, total: 0));
}

/// Sync for the signed-in account (docs/09 M6.2): the engine over
/// Supabase, idle while signed out.
@Riverpod(keepAlive: true)
SyncService syncService(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return const LocalOnlySyncService();
  final db = ref.watch(appDatabaseProvider);
  final clock = ref.watch(clockProvider);
  final gateway = SupabaseSyncGateway(client);
  final service = EngineSyncService(
    engine: SyncEngine(
      db: db,
      gateway: gateway,
      hlc: ref.watch(sharedHlcProvider),
      clock: clock,
    ),
    accounts: _accountIds(client),
    adopt: (id) async {
      // Rows now belong to the account: the profile is read again.
      if (await adoptAccount(db, id, ref.read(sharedHlcProvider)) != null) {
        ref.invalidate(localProfileProvider);
      }
    },
    conflicts: DriftConflictStore(
      db: db,
      writes: ref.watch(writeUseCaseProvider),
      clock: clock,
    ),
    remoteChanges: gateway.changes(),
    clock: clock,
    logger: ref.watch(loggerProvider),
    // Pulled tasks: reminders and widgets follow, as after a local write.
    onPulled: (id) => ref.read(afterWriteEffectsProvider).schedule(id),
  );
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
}

/// The signed-in account's id, or null; distinct.
Stream<String?> _accountIds(SupabaseClient client) async* {
  String? last = client.auth.currentUser?.id;
  yield last;
  await for (final s in client.auth.onAuthStateChange) {
    final id = s.session?.user.id;
    if (id == last) continue;
    last = id;
    yield id;
  }
}

/// Sync as it stands, live.
@Riverpod(keepAlive: true)
Stream<SyncStatus> syncStatus(Ref ref) =>
    ref.watch(syncServiceProvider).watch();
