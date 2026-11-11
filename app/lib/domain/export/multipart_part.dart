/// One part of a multipart export and its integrity check (CR-160 Stage B1,
/// docs/cr-160-multipart-export.md §2–§3). A part is checked on its own,
/// against its manifest, so an importer holds one part at a time (B3).
///
/// The check is integrity only: size before reading, the exact bytes'
/// SHA-256 against the manifest, then export id, index, total, profile
/// placement and per-table counts. Rows themselves are validated by the
/// importer's entity validators (B3), never here.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/multipart_format.dart';

/// One slice of the rows, in v1's storage form.
final class ExportPart {
  const ExportPart({
    required this.exportId,
    required this.index,
    required this.total,
    required this.rows,
    this.profile,
  });

  final String exportId;

  /// 1-based.
  final int index;
  final int total;

  /// Part 1 only.
  final Map<String, Object?>? profile;

  /// Per table in [partTables], the rows in written order.
  final Map<String, List<Map<String, Object?>>> rows;

  TableCounts get counts => {for (final t in partTables) t: rows[t]!.length};

  Map<String, Object?> toJson() => {
    'format': partFormat,
    'formatVersion': multipartFormatVersion,
    'exportId': exportId,
    'index': index,
    'total': total,
    'profile': ?profile,
    for (final t in partTables) t: rows[t],
  };
}

/// Why a part was refused. Every refusal refuses the whole import.
enum PartProblem {
  /// Over the read limit: refused before reading.
  tooLarge,

  /// Its bytes match no part of this manifest (corrupt, truncated, edited,
  /// or from another export).
  hashMismatch,

  /// Not a part this app reads.
  notAPart,

  /// Its fields disagree with the manifest entry its bytes matched.
  inconsistent,
}

/// The outcome of checking one part.
sealed class PartCheck {
  const PartCheck();
}

final class PartAccepted extends PartCheck {
  const PartAccepted(this.part, {this.duplicate = false});
  final ExportPart part;

  /// The same part was already accepted (a repeated download): identical
  /// bytes, nothing new to stage.
  final bool duplicate;
}

final class PartRefused extends PartCheck {
  const PartRefused(this.problem);
  final PartProblem problem;
}

/// Checks [text] as a part of [manifest].
PartCheck checkPart(ExportManifest manifest, String text) {
  // Encoded once for the limit, the hash and the size (peak memory, §7).
  if (text.length > maxImportBytes) {
    return const PartRefused(PartProblem.tooLarge);
  }
  final encoded = utf8.encode(text);
  if (encoded.length > maxImportBytes) {
    return const PartRefused(PartProblem.tooLarge);
  }
  final hash = sha256.convert(encoded).toString();
  final entry = manifest.parts.where((p) => p.sha256 == hash).firstOrNull;
  if (entry == null) return const PartRefused(PartProblem.hashMismatch);
  final part = _decode(text);
  if (part == null) return const PartRefused(PartProblem.notAPart);
  final consistent =
      part.exportId == manifest.exportId &&
      part.index == entry.index &&
      part.total == manifest.parts.length &&
      (part.profile != null) == (part.index == 1) &&
      encoded.length == entry.bytes &&
      partTables.every((t) => part.counts[t] == entry.counts[t]);
  return consistent
      ? PartAccepted(part)
      : const PartRefused(PartProblem.inconsistent);
}

ExportPart? _decode(String text) {
  final Object? json;
  try {
    json = jsonDecode(text);
  } on FormatException {
    return null;
  }
  if (json is! Map<String, Object?> || json.containsKey('version')) {
    return null;
  }
  if (json['format'] != partFormat) return null;
  if (json['formatVersion'] != multipartFormatVersion) return null;
  final exportId = json['exportId'];
  final index = json['index'];
  final total = json['total'];
  final profile = json['profile'];
  if (exportId is! String || index is! int || total is! int) return null;
  if (profile != null && profile is! Map<String, Object?>) return null;
  final rows = <String, List<Map<String, Object?>>>{};
  for (final t in partTables) {
    final list = json[t];
    if (list is! List<Object?>) return null;
    if (list.any((r) => r is! Map<String, Object?>)) return null;
    rows[t] = list.cast<Map<String, Object?>>();
  }
  return ExportPart(
    exportId: exportId,
    index: index,
    total: total,
    profile: profile as Map<String, Object?>?,
    rows: rows,
  );
}

/// The parts of one manifest picked so far: each checked as it arrives,
/// a repeated part accepted only as the identical file.
final class PartSet {
  PartSet(this.manifest);

  final ExportManifest manifest;
  final _accepted = <int>{};

  /// Checks [text]; a part already accepted comes back as a duplicate.
  PartCheck add(String text) {
    final check = checkPart(manifest, text);
    if (check is! PartAccepted) return check;
    final fresh = _accepted.add(check.part.index);
    return fresh ? check : PartAccepted(check.part, duplicate: true);
  }

  /// The 1-based indexes still missing.
  List<int> get missing => [
    for (final p in manifest.parts)
      if (!_accepted.contains(p.index)) p.index,
  ];

  bool get complete => missing.isEmpty;
}
