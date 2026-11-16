import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/backup/user_data_snapshot.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/export/part_stream.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:timezone/timezone.dart' as tz;

/// Builds the export files (docs/09 M8.1, R-11). A port so widget tests
/// run without a database.
abstract interface class ExportService {
  /// [format]'s files for [userId], named with today's local date (the
  /// profile's zone). Never throws: a read failure is a [StorageFailure].
  /// A JSON file over the import limit is an [ExportTooLargeFailure]: never
  /// made, since the app couldn't restore it (CR-160 Stage B0).
  /// [forAccountDeletion]: D1's export (CR-160), which keeps imported
  /// calendar events as ordinary tasks; every other export leaves them out.
  Future<Result<List<ExportFile>, AppFailure>> build(
    String userId,
    ExportFormat format, {
    bool forAccountDeletion = false,
  });

  /// The JSON export as a multipart set when it's over one part (CR-160
  /// B7, docs/cr-160-multipart-export.md §4): each file prepared (written
  /// and read back to its hash) before anything is handed over.
  /// [FitsOneFile] means [build] applies. [appVersion] is read for the
  /// manifest only when there is one. [forAccountDeletion]: D1's set
  /// (imported calendar events as tasks, every template), checked by
  /// [complete] in the same read.
  Future<Result<PreparedExport, AppFailure>> prepareSet(
    String userId, {
    required Future<String> Function() appVersion,
    bool forAccountDeletion = false,
    CompleteCheck? complete,
  });
}

/// [ExportService] reading one consistent snapshot of the database: the
/// same one a backup takes, so the JSON export is a backup the person
/// keeps.
final class DriftExportService implements ExportService {
  DriftExportService({
    required AppDatabase db,
    required Clock clock,
    required Logger logger,
    IdGenerator ids = const UuidV7Generator(),
    int partTarget = partTargetBytes,
  }) : _db = db,
       _clock = clock,
       _logger = logger,
       _ids = ids,
       _partTarget = partTarget;

  final AppDatabase _db;
  final Clock _clock;
  final Logger _logger;
  final IdGenerator _ids;
  final int _partTarget;

  @override
  Future<Result<List<ExportFile>, AppFailure>> build(
    String userId,
    ExportFormat format, {
    bool forAccountDeletion = false,
  }) async {
    final now = _clock.nowUtc();
    try {
      final bundle = await _db.transaction(
        () =>
            readUserData(_db, userId, now, importedAsTasks: forAccountDeletion),
      );
      if (bundle == null) return const Err(StorageFailure());
      final date = _localDate(now, bundle.profile.tzId);
      final files = exportFiles(format, bundle, date: date);
      if (format == ExportFormat.json &&
          files.any((f) => exceedsImportLimit(f.content))) {
        _logger.warn('export.too_large', fields: {'format': format});
        return const Err(ExportTooLargeFailure());
      }
      return Ok(files);
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

  @override
  Future<Result<PreparedExport, AppFailure>> prepareSet(
    String userId, {
    required Future<String> Function() appVersion,
    bool forAccountDeletion = false,
    CompleteCheck? complete,
  }) async {
    final now = _clock.nowUtc();
    final profile = await (_db.select(
      _db.profiles,
    )..where((p) => p.id.equals(userId))).getSingleOrNull();
    if (profile == null) return const Err(StorageFailure());
    return prepareMultipartExport(
      _db,
      userId,
      scope: forAccountDeletion ? RowScope.accountDeletion : RowScope.standard,
      store: platformPreparedFileStore(),
      logger: _logger,
      nowUtc: now,
      exportId: _ids.newId(),
      appVersion: appVersion,
      schemaVersion: AppDatabase.latestSchemaVersion,
      date: _localDate(now, profile.tzId),
      targetBytes: _partTarget,
      complete: complete,
    );
  }

  /// `yyyy-MM-dd` in [tzId] (UTC if the zone is unknown), ASCII digits.
  static String _localDate(DateTime nowUtc, String tzId) {
    final zone = tz.timeZoneDatabase.locations[tzId] ?? tz.UTC;
    final d = tz.TZDateTime.from(nowUtc, zone);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-${two(d.day)}';
  }
}
