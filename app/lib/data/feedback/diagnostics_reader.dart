import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/feedback/feedback_diagnostics.dart';

/// What the database adds to feedback diagnostics: counts and the random
/// sync node id. A port so widget tests need no database.
abstract interface class DiagnosticsReader {
  /// Counts of what is on this device and its node id (null before the
  /// first write).
  Future<({DiagnosticCounts counts, String? deviceId})> read();
}

/// [DiagnosticsReader] over Drift. One aggregate query: it selects
/// `count(*)` and the node id only, never a title or note column, so no
/// task text can reach a report (CLAUDE.md §4, docs/04 §9).
final class DriftDiagnosticsReader implements DiagnosticsReader {
  const DriftDiagnosticsReader(this._db);

  final AppDatabase _db;

  static const _sql = '''
SELECT
  (SELECT count(*) FROM occurrences
     WHERE deleted_at IS NULL AND source = 'user') AS tasks,
  (SELECT count(*) FROM occurrences
     WHERE deleted_at IS NULL AND source = 'user' AND start_utc IS NULL)
     AS inbox,
  (SELECT count(*) FROM occurrences
     WHERE deleted_at IS NULL AND source = 'user' AND status = 'done')
     AS done,
  (SELECT count(*) FROM series WHERE deleted_at IS NULL) AS repeats,
  (SELECT count(*) FROM occurrences WHERE deleted_at IS NOT NULL) AS trash,
  (SELECT count(*) FROM occurrences
     WHERE deleted_at IS NULL AND source = 'calendar') AS calendar_events,
  (SELECT value FROM local_meta WHERE key = 'hlc_node') AS device''';

  @override
  Future<({DiagnosticCounts counts, String? deviceId})> read() async {
    final row = await _db
        .customSelect(
          _sql,
          readsFrom: {_db.occurrences, _db.seriesTable, _db.localMeta},
        )
        .getSingle();
    return (
      counts: DiagnosticCounts(
        tasks: row.read<int>('tasks'),
        inbox: row.read<int>('inbox'),
        done: row.read<int>('done'),
        repeats: row.read<int>('repeats'),
        trash: row.read<int>('trash'),
        calendarEvents: row.read<int>('calendar_events'),
      ),
      deviceId: row.readNullable<String>('device'),
    );
  }
}
