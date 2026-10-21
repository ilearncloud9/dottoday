import 'dart:math';

import 'package:dottoday/data/db/database_key_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockStorage storage;
  late Map<String, String> saved;

  setUp(() {
    storage = _MockStorage();
    saved = {};
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((i) async => saved[i.namedArguments[#key]]);
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((i) async {
      saved[i.namedArguments[#key] as String] =
          i.namedArguments[#value] as String;
    });
  });

  test('creates a 32-byte hex key once and reuses it', () async {
    final store = SecureDatabaseKeyStore(storage, random: Random(1));
    final first = await store.obtainHexKey();
    expect(isValidHexKey(first), isTrue);
    expect(await store.obtainHexKey(), first);
    verify(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).called(1);
  });

  test('never overwrites a malformed stored key', () async {
    saved[SecureDatabaseKeyStore.storageKey] = 'garbage';
    final store = SecureDatabaseKeyStore(storage);
    await expectLater(store.obtainHexKey(), throwsStateError);
    expect(saved[SecureDatabaseKeyStore.storageKey], 'garbage');
  });
}
