/// D1's prepared sets (CR-160 B7c, docs/cr-160-multipart-export.md §10):
/// the set handed over for each owner, kept so "Check my files" can
/// compare the files picked back with it; removed when D1 closes or
/// another export starts.
library;

import 'dart:ui' show Rect;

import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/data/owners/account_export_set.dart';
import 'package:dottoday/data/system/system_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Hands a D1 set over from the screen instead of the share sheet (the
/// web's per-file downloads, CR-160 B7c).
typedef SetHandOver =
    Future<DeliveryOutcome> Function(List<PreparedFile> files);

final class DeletionSets {
  final _sets = <String, PreparedSet>{};

  /// [owner]'s set handed over in this D1 session, if any.
  PreparedSet? of(String owner) => _sets[owner];

  /// How many files [owner]'s set is, the manifest counted.
  int? fileCount(String owner) => _sets[owner]?.files.length;

  /// Keeps [set] for [owner] (the earlier one's files removed).
  Future<void> keep(String owner, PreparedSet set) async {
    await clear(owner);
    _sets[owner] = set;
  }

  /// [owner]'s D1 export as a set when the account is too large for one
  /// file, handed over by [handOver] (else the share sheet or a folder):
  /// how it ended, the set kept when it was handed over. Null: it fits one
  /// file, and D1's single-file export applies.
  Future<OwnerExportOutcome?> export(
    Ref ref,
    String owner,
    Rect? origin,
    SetHandOver? handOver,
  ) async {
    final set = await exportOwnerSet(
      ref.read(appDatabaseProvider),
      owner,
      exports: ref.read(exportServiceProvider),
      logger: ref.read(loggerProvider),
      deliver: (files) =>
          handOver?.call(files) ??
          ref.read(fileGatewayProvider).deliverPrepared(files, origin: origin),
      appVersion: () => ref.read(appVersionProvider.future),
    );
    if (set == null) return null;
    if (set.set case final s?) await keep(owner, s);
    return set.outcome;
  }

  /// Removes [owner]'s set and its files.
  Future<void> clear(String owner) async => _sets.remove(owner)?.discard();
}
