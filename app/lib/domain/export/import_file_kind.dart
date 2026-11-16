/// What kind of file the person picked to import (CR-160 Stage B1,
/// docs/cr-160-multipart-export.md §2): recognised by content, never by
/// name. Today's import (`decodeExportJson`) reads only [ImportFileKind.legacy]
/// and refuses a manifest or a part as not a backup; this lets a later
/// stage say which files are still needed (B5/B7) without changing how a
/// JSON v1 file imports.
library;

import 'dart:convert';

import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/multipart_format.dart';

enum ImportFileKind {
  /// Over the read limit: not read at all.
  tooLarge,

  /// A JSON v1 file (`version: 1`).
  legacy,

  /// A multipart manifest.
  manifest,

  /// One part of a multipart export.
  part,

  /// Anything else.
  unknown,
}

/// The kind of [text], from its top-level keys only; total, never throws.
ImportFileKind importFileKind(String text) {
  if (exceedsImportLimit(text)) return ImportFileKind.tooLarge;
  final Object? json;
  try {
    json = jsonDecode(text);
  } on FormatException {
    return ImportFileKind.unknown;
  }
  if (json is! Map<String, Object?>) return ImportFileKind.unknown;
  if (json['version'] == ExportBundle.version) return ImportFileKind.legacy;
  if (json.containsKey('version')) return ImportFileKind.unknown;
  return switch (json['format']) {
    multipartFormat => ImportFileKind.manifest,
    partFormat => ImportFileKind.part,
    _ => ImportFileKind.unknown,
  };
}
