/// Where parts end, decided a row at a time (CR-160 Stage B1/B4,
/// docs/cr-160-multipart-export.md §4): the first pass of writing a
/// multipart export or backup. Rows are given in written order (table
/// order, then id); a new part starts before a row would push the current
/// one past the target. The plan is an upper bound on each part's bytes.
library;

import 'dart:convert';

import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_part.dart';

final class PartPlanner {
  PartPlanner({
    required String exportId,
    required Map<String, Object?> profile,
    this.targetBytes = partTargetBytes,
  }) : assert(targetBytes <= maxImportBytes, 'parts stay readable'),
       _header = _headerBytes(exportId, null),
       _used = _headerBytes(exportId, profile);

  final int targetBytes;
  final int _header;
  int _used;
  int _count = 0;
  final _plan = <int>[];

  /// The table of the first row too large for any part; null while none.
  String? tooLarge;

  /// Counts [row] of [table] in; false (and [tooLarge] set) when no part
  /// could hold it.
  bool add(String table, Map<String, Object?> row) {
    // +1: the comma before it (an upper bound for an array's first row).
    final size = utf8.encode(canonicalJson(row)).length + 1;
    if (_header + size > targetBytes) {
      tooLarge ??= table;
      return false;
    }
    if (_used + size > targetBytes) {
      _plan.add(_count);
      _used = _header;
      _count = 0;
    }
    _used += size;
    _count++;
    return true;
  }

  /// Rows per part, in order (part 1 may hold the profile alone).
  List<int> finish() => [..._plan, _count];
}

/// Bytes of an empty part, with the widest index and total a plan can need.
int _headerBytes(String exportId, Map<String, Object?>? profile) => utf8
    .encode(
      canonicalJson(
        ExportPart(
          exportId: exportId,
          index: 999999,
          total: 999999,
          profile: profile,
          rows: {for (final t in partTables) t: const []},
        ).toJson(),
      ),
    )
    .length;
