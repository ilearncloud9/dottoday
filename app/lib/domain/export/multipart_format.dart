/// The multipart export format (CR-160 Stage B1, docs/cr-160-multipart-export.md
/// §2–§3, ADR-0019): a manifest plus parts, for an export larger than one
/// part. Neither file carries `version: 1`, so every importer that reads
/// only JSON v1 (all shipped builds) refuses both before writing anything.
///
/// Encoding is canonical: compact JSON, keys in a fixed order, rows in the
/// order they were given (the readers order every table by id), so the same
/// data always gives the same bytes and the same hashes. A hash is
/// integrity, never authenticity (ADR-0019 D3).
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dottoday/domain/export/export_json.dart';

const multipartFormat = 'dottoday-multipart';
const partFormat = 'dottoday-part';
const multipartFormatVersion = 1;

/// Written part target (provisional, spec §7); reads stay capped at
/// [maxImportBytes] per file.
const partTargetBytes = 10 * 1024 * 1024;

/// The row tables a part carries, in the order they are written (spec §4).
const partTables = [
  'series',
  'occurrences',
  'subtasks',
  'routines',
  'calendarSeries',
];

/// Why an export was made; recorded, never used to decide ownership.
enum ExportPurpose {
  accountDeletion('account-deletion'),
  export('export'),
  backup('backup');

  const ExportPurpose(this.wire);
  final String wire;

  static ExportPurpose? fromWire(Object? wire) => [
    for (final p in values)
      if (p.wire == wire) p,
  ].firstOrNull;
}

/// Rows per table, every table in [partTables] present.
typedef TableCounts = Map<String, int>;

/// One part as the manifest lists it.
final class PartEntry {
  const PartEntry({
    required this.index,
    required this.name,
    required this.bytes,
    required this.sha256,
    required this.counts,
  });

  /// 1-based.
  final int index;

  /// Informative only: files are recognised by content, never by name.
  final String name;

  /// UTF-8 bytes of the part file.
  final int bytes;

  /// Lowercase hex SHA-256 of the part file's exact bytes.
  final String sha256;
  final TableCounts counts;

  Map<String, Object?> toJson() => {
    'index': index,
    'name': name,
    'bytes': bytes,
    'sha256': sha256,
    'counts': {for (final t in partTables) t: counts[t]},
  };
}

/// What one multipart export holds (spec §2).
final class ExportManifest {
  const ExportManifest({
    required this.exportId,
    required this.exportedAtMs,
    required this.appVersion,
    required this.schemaVersion,
    required this.purpose,
    required this.totals,
    required this.parts,
  });

  final String exportId;
  final int exportedAtMs;
  final String appVersion;
  final int schemaVersion;
  final ExportPurpose purpose;
  final TableCounts totals;
  final List<PartEntry> parts;

  Map<String, Object?> toJson() => {
    'format': multipartFormat,
    'formatVersion': multipartFormatVersion,
    'exportId': exportId,
    'exportedAt': exportedAtMs,
    'appVersion': appVersion,
    'schemaVersion': schemaVersion,
    'purpose': purpose.wire,
    'totals': {for (final t in partTables) t: totals[t]},
    'parts': [for (final p in parts) p.toJson()],
  };

  /// The manifest in [text], or null when it is not a complete, consistent
  /// manifest this app reads (over the read limit, another format or
  /// version, a v1 key, parts out of order, totals that don't add up).
  static ExportManifest? decode(String text) {
    if (exceedsImportLimit(text)) return null;
    try {
      return _fromJson(jsonDecode(text));
    } on FormatException {
      return null;
    }
  }

  static ExportManifest? _fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    if (json.containsKey('version')) return null;
    if (json['format'] != multipartFormat) return null;
    if (json['formatVersion'] != multipartFormatVersion) return null;
    final exportId = json['exportId'];
    final at = json['exportedAt'];
    final app = json['appVersion'];
    final schema = json['schemaVersion'];
    final purpose = ExportPurpose.fromWire(json['purpose']);
    final totals = tableCountsOf(json['totals']);
    final rawParts = json['parts'];
    if (exportId is! String || !isExportId(exportId)) return null;
    if (at is! int || at < 0 || app is! String || schema is! int) return null;
    if (purpose == null || totals == null) return null;
    if (rawParts is! List<Object?> || rawParts.isEmpty) return null;
    final parts = <PartEntry>[];
    for (final raw in rawParts) {
      final p = _entry(raw, parts.length + 1);
      if (p == null) return null;
      parts.add(p);
    }
    for (final t in partTables) {
      if (parts.fold(0, (n, p) => n + p.counts[t]!) != totals[t]) return null;
    }
    return ExportManifest(
      exportId: exportId,
      exportedAtMs: at,
      appVersion: app,
      schemaVersion: schema,
      purpose: purpose,
      totals: totals,
      parts: parts,
    );
  }

  static PartEntry? _entry(Object? raw, int expectedIndex) {
    if (raw is! Map<String, Object?>) return null;
    final name = raw['name'];
    final bytes = raw['bytes'];
    final hash = raw['sha256'];
    final counts = tableCountsOf(raw['counts']);
    if (raw['index'] != expectedIndex || name is! String) return null;
    if (bytes is! int || bytes <= 0 || bytes > maxImportBytes) return null;
    if (hash is! String || !_sha256Hex.hasMatch(hash) || counts == null) {
      return null;
    }
    return PartEntry(
      index: expectedIndex,
      name: name,
      bytes: bytes,
      sha256: hash,
      counts: counts,
    );
  }
}

final _sha256Hex = RegExp(r'^[0-9a-f]{64}$');
final _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
);

/// Whether [id] is a lowercase UUID, as export ids are written.
bool isExportId(String id) => _uuid.hasMatch(id);

/// [json] as counts for every table in [partTables], or null.
TableCounts? tableCountsOf(Object? json) {
  if (json is! Map<String, Object?>) return null;
  final out = <String, int>{};
  for (final t in partTables) {
    final n = json[t];
    if (n is! int || n < 0) return null;
    out[t] = n;
  }
  return out;
}

/// Canonical text of [json]: compact, keys in insertion order.
String canonicalJson(Object? json) => jsonEncode(json);

/// Lowercase hex SHA-256 of [text]'s UTF-8 bytes.
String sha256Hex(String text) => sha256.convert(utf8.encode(text)).toString();
