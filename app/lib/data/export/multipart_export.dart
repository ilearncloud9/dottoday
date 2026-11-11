/// A multipart export (CR-160 Stage B6, docs/cr-160-multipart-export.md
/// §4, §10): the manifest and its parts, each prepared (written and read
/// back with a matching hash) before anything is handed over. Read from the
/// database in one read transaction through the part stream (shared with
/// backups), one part in memory at a time. Reachable from tests only
/// until B7 wires Settings and D1 to it (owner decision, B6 plan).
library;

import 'dart:async';
import 'dart:convert';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/export/part_stream.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/domain/export/multipart_format.dart';

/// What preparing a set gave.
sealed class PreparedExport {
  const PreparedExport();
}

/// The whole account fits one part: the caller makes today's single JSON
/// v1 file instead (§4).
final class FitsOneFile extends PreparedExport {
  const FitsOneFile();
}

/// A prepared set: its manifest (first) and parts, in order.
final class PreparedSet extends PreparedExport {
  const PreparedSet(this.manifest, this.manifestFile, this.parts);
  final ExportManifest manifest;
  final PreparedFile manifestFile;
  final List<PreparedFile> parts;

  /// Every file, the manifest first.
  List<PreparedFile> get files => [manifestFile, ...parts];
}

/// Checks the totals planned against the device, inside the same read
/// (D1: nothing left out); false fails the export.
typedef CompleteCheck = Future<bool> Function(TableCounts totals);

/// Prepares [owner]'s export of [scope] in [store].
///
/// Errors: [ExportTooLargeFailure] when one row is larger than any part
/// (§4, never left out); [StorageFailure] for a missing profile, a
/// [complete] check that failed, or a file that didn't read back.
Future<Result<PreparedExport, AppFailure>> prepareMultipartExport(
  AppDatabase db,
  String owner, {
  required RowScope scope,
  required PreparedFileStore store,
  required Logger logger,
  required DateTime nowUtc,
  required String exportId,
  required String appVersion,
  required int schemaVersion,
  required String date,
  int targetBytes = partTargetBytes,
  CompleteCheck? complete,
}) async {
  try {
    return await db.transaction(() async {
      final reads = Zone.current;
      final planned = await planParts(
        db,
        reads,
        owner,
        scope,
        exportId: exportId,
        targetBytes: targetBytes,
      );
      switch (planned) {
        case NoProfile():
          return const Err(StorageFailure());
        case RowOverTarget():
          logger.warn('export.row_too_large');
          return const Err(ExportTooLargeFailure());
        case PartPlan(:final sizes) when sizes.length == 1:
          return const Ok(FitsOneFile());
        case PartPlan():
      }
      if (complete != null && !await complete(planned.totals)) {
        logger.error('export.incomplete');
        return const Err(StorageFailure());
      }
      final stem = partFileStem(date, exportId);
      final parts = <PreparedFile>[];
      final entries = await writeParts(
        db,
        reads,
        owner,
        scope,
        planned,
        exportId: exportId,
        name: (index, total) => partFileName(stem, index, total),
        sink: (index, text, bytes, hash) async => parts.add(
          await store.put(
            partFileName(stem, index, planned.sizes.length),
            bytes,
            hash,
          ),
        ),
      );
      final manifest = ExportManifest(
        exportId: exportId,
        exportedAtMs: nowUtc.millisecondsSinceEpoch,
        appVersion: appVersion,
        schemaVersion: schemaVersion,
        purpose: scope == RowScope.accountDeletion
            ? ExportPurpose.accountDeletion
            : ExportPurpose.export,
        totals: planned.totals,
        parts: entries,
      );
      final text = canonicalJson(manifest.toJson());
      final file = await store.put(
        manifestFileName(stem),
        utf8.encode(text),
        sha256Hex(text),
      );
      return Ok(PreparedSet(manifest, file, parts));
    });
  } on PreparedMismatch {
    logger.error('export.prepare_mismatch');
    await store.discard();
    return const Err(StorageFailure());
  } on Exception catch (e, st) {
    logger.error('export.prepare_failed', error: e, stackTrace: st);
    await store.discard();
    return const Err(StorageFailure());
  }
}
