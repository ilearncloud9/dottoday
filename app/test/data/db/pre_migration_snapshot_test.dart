import 'dart:io';

import 'package:dottoday/data/db/connection/cipher_setup.dart';
import 'package:dottoday/data/db/connection/pre_migration_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

final _key = 'ab' * 32;

void main() {
  late Directory dir;
  late String path;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('premig');
    path = '${dir.path}/app.db';
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Database open(String p) {
    final db = sqlite3.open(p);
    configureCipherConnection(db, _key);
    return db;
  }

  Database atVersion(int version) => open(path)
    ..execute('CREATE TABLE IF NOT EXISTS t (v TEXT)')
    ..execute("INSERT INTO t VALUES ('row-v$version')")
    ..execute('PRAGMA user_version = $version');

  test('snapshots an older schema, encrypted with the same key', () {
    final db = atVersion(1);
    addTearDown(db.close);
    final snapshot = snapshotBeforeMigration(db, path, 2)!;

    final bytes = File(snapshot).readAsBytesSync();
    expect(String.fromCharCodes(bytes.take(15)), isNot('SQLite format 3'));
    final copy = open(snapshot);
    addTearDown(copy.close);
    expect(copy.select('SELECT v FROM t').single['v'], 'row-v1');
  });

  test('no snapshot for a new or current database', () {
    final fresh = open(path);
    expect(snapshotBeforeMigration(fresh, path, 2), isNull);
    fresh.close();
    final current = atVersion(2);
    addTearDown(current.close);
    expect(snapshotBeforeMigration(current, path, 2), isNull);
  });

  test('keeps only the newest snapshots', () {
    for (var v = 1; v <= 4; v++) {
      final db = atVersion(v);
      snapshotBeforeMigration(db, path, v + 1);
      db.close();
    }
    final names = dir
        .listSync()
        .map((f) => f.uri.pathSegments.last)
        .where((n) => n.contains('.pre-v'))
        .toSet();
    expect(names, {'app.db.pre-v4', 'app.db.pre-v3'});
    expect(keptMigrationSnapshots, 2);
  });
}
