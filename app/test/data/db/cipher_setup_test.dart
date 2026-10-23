import 'dart:io';
import 'dart:isolate';

import 'package:dottoday/data/db/connection/cipher_setup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

final _key = 'ab' * 32;
final _otherKey = 'cd' * 32;

void main() {
  late Directory dir;
  late String path;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('cipher_test');
    path = '${dir.path}/t.db';
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Database open(String key) {
    final db = sqlite3.open(path);
    configureCipherConnection(db, key);
    return db;
  }

  // The app and the background refresh can open the file together (M5.2):
  // a second open while the first holds the lock waits instead of failing
  // with "database is locked" (CI, M5.4).
  test('a second open waits for a lock instead of failing', () async {
    // As on a first launch: the file is still in rollback-journal mode, so
    // an exclusive lock keeps every other connection out.
    final first = sqlite3.open(path)
      ..execute("PRAGMA key = \"x'$_key'\"")
      ..execute('CREATE TABLE t (v INTEGER)');
    addTearDown(first.close);
    first.execute('BEGIN EXCLUSIVE');
    final file = path;
    final key = _key;
    final second = Isolate.run(() {
      final db = sqlite3.open(file);
      configureCipherConnection(db, key);
      final n = db.select('SELECT count(*) AS n FROM t').single['n'] as int;
      db.close();
      return n;
    });
    await Future<void>.delayed(const Duration(milliseconds: 400));
    first
      ..execute('INSERT INTO t VALUES (1)')
      ..execute('COMMIT');
    expect(await second, 1);
  });

  test('file is encrypted and reopens with the same key', () {
    open(_key)
      ..execute('CREATE TABLE t (v TEXT)')
      ..execute("INSERT INTO t VALUES ('secret-title')")
      ..close();

    final bytes = File(path).readAsBytesSync();
    expect(String.fromCharCodes(bytes.take(15)), isNot('SQLite format 3'));
    expect(String.fromCharCodes(bytes), isNot(contains('secret-title')));

    final db = open(_key);
    addTearDown(db.close);
    expect(db.select('SELECT v FROM t').single['v'], 'secret-title');
  });

  test('wrong key fails at open, not on a later query', () {
    open(_key)
      ..execute('CREATE TABLE t (v TEXT)')
      ..close();
    expect(() => open(_otherKey), throwsA(isA<SqliteException>()));
  });

  test('rejects a key that is not 32 hex bytes', () {
    for (final bad in ['', 'ab' * 31, 'AB' * 32, "ab'; DROP TABLE t; --"]) {
      expect(() => open(bad), throwsStateError, reason: bad);
    }
  });

  test('connection pragmas are set', () {
    final db = open(_key);
    addTearDown(db.close);
    int pragma(String name) =>
        db.select('PRAGMA $name').single.values.first! as int;
    expect(pragma('foreign_keys'), 1);
    expect(pragma('synchronous'), 2); // FULL
    expect(db.select('PRAGMA journal_mode').single.values.first, 'wal');
  });
}
