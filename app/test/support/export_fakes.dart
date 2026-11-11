import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/export/export_service.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/export/export_files.dart';

/// Records what was handed over and returns a scripted pick.
final class FakeFileGateway implements FileGateway {
  FakeFileGateway({this.picked = const PickCancelled()});

  PickedBackup picked;
  DeliveryOutcome outcome = DeliveryOutcome.delivered;
  Exception? throws;
  final delivered = <List<ExportFile>>[];
  final pickLimits = <int>[];

  /// Runs once while the share sheet or save dialog is open (then cleared).
  void Function()? whileOpen;

  /// PNGs handed to [shareImage], by name.
  final images = <String, Uint8List>{};

  @override
  Future<DeliveryOutcome> deliver(
    List<ExportFile> files, {
    Rect? origin,
  }) async {
    if (throws case final e?) throw e;
    final hook = whileOpen;
    whileOpen = null;
    hook?.call();
    delivered.add(files);
    return outcome;
  }

  @override
  Future<DeliveryOutcome> shareImage(
    Uint8List png, {
    required String name,
    Rect? origin,
  }) async {
    if (throws case final e?) throw e;
    images[name] = png;
    return outcome;
  }

  @override
  Future<PickedBackup> pickBackup({required int maxBytes}) async {
    pickLimits.add(maxBytes);
    return picked;
  }

  /// What [pickJsonFiles] returns next (then cleared); empty: closed.
  List<PickedFile> pickedFiles = const [];

  /// Prepared sets handed to [deliverPrepared].
  final deliveredSets = <List<PreparedFile>>[];

  /// Files [downloadPrepared] was asked for, by name.
  final downloads = <String>[];

  @override
  Future<List<PickedFile>> pickJsonFiles() async {
    final files = pickedFiles;
    pickedFiles = const [];
    return files;
  }

  @override
  Future<DeliveryOutcome> deliverPrepared(
    List<PreparedFile> files, {
    Rect? origin,
  }) async {
    if (throws case final e?) throw e;
    deliveredSets.add(files);
    return outcome;
  }

  @override
  Future<void> downloadPrepared(PreparedFile file) async {
    if (throws case final e?) throw e;
    downloads.add(file.name);
  }
}

/// [files] as picked files read from their bytes.
List<PickedFile> pickedFrom(List<PreparedFile> files) => [
  for (final f in files) PickedFile(f.name, f.size, () async => f.bytes!),
];

/// One file per format, named after it.
final class FakeExportService implements ExportService {
  final built = <ExportFormat>[];

  /// Whether each build was D1's (CR-160), in order.
  final forDeletion = <bool>[];
  AppFailure? failure;

  @override
  Future<Result<List<ExportFile>, AppFailure>> build(
    String userId,
    ExportFormat format, {
    bool forAccountDeletion = false,
  }) async {
    if (failure case final f?) return Err(f);
    built.add(format);
    forDeletion.add(forAccountDeletion);
    return Ok([
      ExportFile(
        name: 'dottoday.${format.name}',
        mimeType: 'text/plain',
        content: format.name,
      ),
    ]);
  }

  /// What [prepareSet] gives (default: the account fits one file).
  Result<PreparedExport, AppFailure> set = const Ok(FitsOneFile());
  final setVersions = <String>[];

  @override
  Future<Result<PreparedExport, AppFailure>> prepareSet(
    String userId, {
    required String appVersion,
  }) async {
    setVersions.add(appVersion);
    return set;
  }
}

/// Backups in memory; import/restore record their calls.
final class FakeBackupService implements BackupService {
  FakeBackupService([List<BackupInfo>? backups]) : backups = backups ?? [];

  final List<BackupInfo> backups;
  final imported = <String>[];
  final restored = <int>[];
  AppFailure? failure;

  void _take(BackupReason reason) => backups.insert(
    0,
    BackupInfo(
      id: backups.length + 100,
      createdAtUtc: DateTime.utc(2026, 10, 21, 9),
      reason: reason,
      sizeBytes: 1,
    ),
  );

  @override
  Future<Result<bool, AppFailure>> runDailyIfDue(String userId) async =>
      const Ok(false);

  @override
  Future<DateTime> nextDailyDueUtc(String userId) async =>
      DateTime.utc(2026, 10, 22, 9);

  @override
  Future<Result<BackupInfo, AppFailure>> create(
    String userId,
    BackupReason reason,
  ) async {
    _take(reason);
    return Ok(backups.first);
  }

  @override
  Future<List<BackupInfo>> list() async => [...backups];

  @override
  Future<Result<void, AppFailure>> restore(String userId, int backupId) async {
    if (failure case final f?) return Err(f);
    _take(BackupReason.preRestore);
    restored.add(backupId);
    return const Ok(null);
  }

  @override
  Future<Result<void, AppFailure>> importJson(
    String userId,
    String json,
  ) async {
    if (failure case final f?) return Err(f);
    _take(BackupReason.preImport);
    imported.add(json);
    return const Ok(null);
  }
}
