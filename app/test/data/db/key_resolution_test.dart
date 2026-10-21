import 'dart:io';

import 'package:dottoday/data/db/connection/cipher_setup.dart';
import 'package:dottoday/data/db/connection/key_resolution.dart';
import 'package:dottoday/data/db/database_key_store.dart';
import 'package:dottoday/data/db/database_unavailable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

final class _Keys implements DatabaseKeyStore {
  String? stored;
  var created = 0;

  @override
  Future<String> obtainHexKey() async {
    if (stored != null) return stored!;
    created++;
    return stored = 'ab' * 32;
  }

  @override
  Future<String?> readHexKey() async => stored;
}

Matcher _unavailable(DatabaseUnavailableReason reason) =>
    isA<DatabaseUnavailable>().having((e) => e.reason, 'reason', reason);

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('keys');
    file = File('${dir.path}/app.db');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('first launch creates the key', () async {
    final keys = _Keys();
    expect(isValidHexKey(await resolveDatabaseKey(file, keys)), isTrue);
    expect(keys.created, 1);
  });

  test('existing file without a key fails closed, mints nothing', () async {
    file.writeAsStringSync('encrypted bytes');
    final keys = _Keys();
    await expectLater(
      resolveDatabaseKey(file, keys),
      throwsA(_unavailable(DatabaseUnavailableReason.keyMissing)),
    );
    expect(keys.created, 0);
  });

  test('a key that does not decrypt the file is keyRejected', () {
    final db = sqlite3.open(file.path);
    configureCipherConnection(db, 'ab' * 32);
    db
      ..execute('CREATE TABLE t (v)')
      ..close();
    final reopened = sqlite3.open(file.path);
    addTearDown(reopened.close);
    expect(
      () => configureOrUnavailable(reopened, 'cd' * 32),
      throwsA(_unavailable(DatabaseUnavailableReason.keyRejected)),
    );
  });
}
