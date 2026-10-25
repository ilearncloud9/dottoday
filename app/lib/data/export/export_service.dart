import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/backup/user_data_snapshot.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:timezone/timezone.dart' as tz;

/// Builds the export files (docs/09 M8.1, R-11). A port so widget tests
/// run without a database.
abstract interface class ExportService {
  /// [format]'s files for [userId], named with today's local date (the
  /// profile's zone). Never throws: a read failure is a [StorageFailure].
  Future<Result<List<ExportFile>, AppFailure>> build(
    String userId,
    ExportFormat format,
  );
}

/// [ExportService] reading one consistent snapshot of the database: the
/// same one a backup takes, so the JSON export is a backup the person
/// keeps.
final class DriftExportService implements ExportService {
  DriftExportService({
    required AppDatabase db,
    required Clock clock,
    required Logger logger,
  }) : _db = db,
       _clock = clock,
       _logger = logger;

  final AppDatabase _db;
  final Clock _clock;
  final Logger _logger;

  @override
  Future<Result<List<ExportFile>, AppFailure>> build(
    String userId,
    ExportFormat format,
  ) async {
    final now = _clock.nowUtc();
    try {
      final bundle = await _db.transaction(
        () => readUserData(_db, userId, now),
      );
      if (bundle == null) return const Err(StorageFailure());
      final date = _localDate(now, bundle.profile.tzId);
      return Ok(exportFiles(format, bundle, date: date));
    } on Exception catch (e, st) {
      _logger.error(
        'export.build_failed',
        fields: {'format': format},
        error: e,
        stackTrace: st,
      );
      return const Err(StorageFailure());
    }
  }

  /// `yyyy-MM-dd` in [tzId] (UTC if the zone is unknown), ASCII digits.
  static String _localDate(DateTime nowUtc, String tzId) {
    final zone = tz.timeZoneDatabase.locations[tzId] ?? tz.UTC;
    final d = tz.TZDateTime.from(nowUtc, zone);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-${two(d.day)}';
  }
}
