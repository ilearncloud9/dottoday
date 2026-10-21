import 'package:dottoday/data/db/web/cipher_sqlite3.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/common.dart';

class _Sqlite3 extends Mock implements CommonSqlite3 {}

class _Db extends Mock implements CommonDatabase {}

void main() {
  setUpAll(() => registerFallbackValue(OpenMode.readWriteCreate));

  test('every open goes through the encrypting VFS (M2.9)', () {
    final inner = _Sqlite3();
    when(
      () => inner.open(
        any(),
        vfs: any(named: 'vfs'),
        mode: any(named: 'mode'),
        uri: any(named: 'uri'),
        mutex: any(named: 'mutex'),
      ),
    ).thenReturn(_Db());
    final sqlite3 = CipherVfsSqlite3(inner, 'indexeddb');

    sqlite3
      ..open('/database')
      ..open('/other', vfs: 'indexeddb');

    for (final path in ['/database', '/other']) {
      verify(
        () => inner.open(
          path,
          vfs: 'multipleciphers-indexeddb',
          mode: OpenMode.readWriteCreate,
          uri: false,
          mutex: any(named: 'mutex'),
        ),
      ).called(1);
    }
  });
}
