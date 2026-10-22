import 'package:dottoday/data/db/connection/connection.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/db/database_unavailable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_health.g.dart';

/// Whether the app can use its database (docs/09 M3f.9; 06 §4, M2.4).
sealed class DatabaseHealth {
  const DatabaseHealth();
}

final class DatabaseReady extends DatabaseHealth {
  const DatabaseReady();
}

/// The file can't be opened ([reason]); recovery offers Start fresh, or
/// on the web, Use it here.
final class DatabaseBlocked extends DatabaseHealth {
  const DatabaseBlocked(this.reason);

  final DatabaseUnavailableReason reason;
}

/// This tab handed the database to another one ("Use it here" there).
final class DatabaseHandedOff extends DatabaseHealth {
  const DatabaseHandedOff();
}

/// The database's health, checked with a first query; and the recovery
/// steps. The app shows its screens only while [DatabaseReady].
@Riverpod(keepAlive: true)
class DatabaseStatus extends _$DatabaseStatus {
  @override
  Future<DatabaseHealth> build() async {
    final db = ref.watch(appDatabaseProvider);
    try {
      await db.customSelect('SELECT 1').get();
    } on Object catch (e) {
      final reason = unavailableReason(e);
      if (reason == null) rethrow;
      return DatabaseBlocked(reason);
    }
    // Web: another tab's "Use it here" — close (flushing to IndexedDB),
    // then let go.
    onHandOffRequest(() async {
      await db.close();
      state = const AsyncData(DatabaseHandedOff());
    });
    return const DatabaseReady();
  }

  /// "Start fresh": closes, moves the unreadable file aside (never
  /// deletes it) and opens a new one. Returns where the old one was kept.
  Future<String?> startFresh() async {
    await _close();
    final kept = await moveDatabaseAside();
    ref.invalidate(appDatabaseProvider);
    return kept;
  }

  /// "Use it here" (web): the other tab closes and lets go, then this one
  /// opens. False when it didn't answer in time.
  Future<bool> useHere() async {
    if (!await askOtherTabToLetGo()) return false;
    ref.invalidate(appDatabaseProvider);
    return true;
  }

  Future<void> _close() async {
    try {
      await ref.read(appDatabaseProvider).close();
    } on Object {
      // It never opened; nothing to close.
    }
  }
}

/// The reason in [error], also when drift's background isolate forwarded
/// it as text; null for any other error.
DatabaseUnavailableReason? unavailableReason(Object error) {
  if (error is DatabaseUnavailable) return error.reason;
  final text = error.toString();
  for (final r in DatabaseUnavailableReason.values) {
    if (text.contains('DatabaseUnavailable(${r.name})')) return r;
  }
  return null;
}
