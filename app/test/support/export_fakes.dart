import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/export/export_service.dart';
import 'package:dottoday/data/export/file_gateway.dart';
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

  /// PNGs handed to [shareImage], by name.
  final images = <String, Uint8List>{};

  @override
  Future<DeliveryOutcome> deliver(
    List<ExportFile> files, {
    Rect? origin,
  }) async {
    if (throws case final e?) throw e;
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
}

/// One file per format, named after it.
final class FakeExportService implements ExportService {
  final built = <ExportFormat>[];
  AppFailure? failure;

  @override
  Future<Result<List<ExportFile>, AppFailure>> build(
    String userId,
    ExportFormat format,
  ) async {
    if (failure case final f?) return Err(f);
    built.add(format);
    return Ok([
      ExportFile(
        name: 'dottoday.${format.name}',
        mimeType: 'text/plain',
        content: format.name,
      ),
    ]);
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
