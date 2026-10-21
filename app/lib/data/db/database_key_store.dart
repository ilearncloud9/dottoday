import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Source of the 32-byte SQLCipher key (06 §4: random, Keychain/Keystore).
abstract interface class DatabaseKeyStore {
  /// Returns the key as 64 lowercase hex chars, creating and persisting it
  /// on first use.
  Future<String> obtainHexKey();
}

/// [DatabaseKeyStore] backed by `flutter_secure_storage`.
final class SecureDatabaseKeyStore implements DatabaseKeyStore {
  SecureDatabaseKeyStore(this._storage, {Random? random})
    : _random = random ?? Random.secure();

  /// Secure-storage entry name (a name, not a secret).
  static const entryName = 'db-cipher-v1';

  final FlutterSecureStorage _storage;
  final Random _random;

  @override
  Future<String> obtainHexKey() async {
    final existing = await _storage.read(key: entryName);
    if (existing != null) {
      // Never replace a stored key: a new one would orphan the encrypted
      // file. A corrupt key is surfaced so restore-from-backup can run.
      if (isValidHexKey(existing)) return existing;
      throw StateError('Stored database key is malformed.');
    }
    final created = _generate();
    await _storage.write(key: entryName, value: created);
    return created;
  }

  String _generate() => List.generate(
    32,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

final _hexKey = RegExp(r'^[0-9a-f]{64}$');

/// Whether [key] is exactly 32 bytes of lowercase hex. Only such keys are
/// ever interpolated into `PRAGMA key`, which cannot take bound parameters.
bool isValidHexKey(String key) => _hexKey.hasMatch(key);
