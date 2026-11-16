import 'dart:convert';
import 'dart:io';

import 'package:dottoday/data/db/app_database.dart';

// Encryption-at-rest checks for staged imports (CR-160 Stage B2,
// docs/cr-160-multipart-export.md §6): stage rows that carry a known
// marker, force a large sort over them (the kind of query that spills to a
// temp file when temp storage is on disk), then look for the marker's
// bytes in every file the database left behind.

/// Never written whole into source, so a compiled test binary can't hold it.
final stagingMarker = ['b2', 'staging', 'plaintext', 'marker'].join('-');

/// Stages [rows] rows carrying [stagingMarker] under one import of 'u', and
/// sorts them by their text. Returns the compile options naming temp
/// storage and the connection's temp_store.
Future<String> stageMarkedRows(AppDatabase db, {int rows = 3000}) async {
  await db.customStatement(
    'INSERT INTO import_sessions (import_id, owner, owner_generation, '
    "run_id, started_at, declared_bytes) VALUES ('${'1' * 36}', 'u', 0, "
    "'scan', 0, 104857600)",
  );
  await db.transaction(() async {
    for (var i = 0; i < rows; i++) {
      await db.customStatement(
        'INSERT INTO import_staging (import_id, owner, entity, row_id, '
        "part_index, json) VALUES ('${'1' * 36}', 'u', 'occurrences', ?, 1, "
        '?)',
        [
          'o$i',
          jsonEncode({'id': 'o$i', 'title': '$stagingMarker $i'}),
        ],
      );
    }
  });
  // A sort with no index to use: temp B-trees when temp storage is a file.
  await db
      .customSelect(
        'SELECT json FROM import_staging ORDER BY json DESC, length(json)',
      )
      .get();
  final options = [
    for (final r in await db.customSelect('PRAGMA compile_options').get())
      if ('${r.data.values.first}'.contains('TEMP_STORE'))
        '${r.data.values.first}',
  ];
  final temp = await db.customSelect('PRAGMA temp_store').getSingle();
  return '${options.join(',')} temp_store=${temp.data.values.first}';
}

/// Files under [dir] (recursively) whose bytes contain [stagingMarker].
List<String> filesHoldingMarker(Directory dir) {
  final needle = utf8.encode(stagingMarker);
  return [
    for (final f in dir.listSync(recursive: true).whereType<File>())
      if (_contains(f.readAsBytesSync(), needle)) f.path,
  ];
}

bool _contains(List<int> hay, List<int> needle) {
  outer:
  for (var i = 0; i + needle.length <= hay.length; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (hay[i + j] != needle[j]) continue outer;
    }
    return true;
  }
  return false;
}
