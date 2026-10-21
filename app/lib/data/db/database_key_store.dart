import 'dart:math';

import 'package:dottoday/data/db/hex_key.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

export 'package:dottoday/data/db/hex_key.dart';

/// Source of the 32-byte SQLCipher key (06 §4: random, Keychain/Keystore).
abstract interface class DatabaseKeyStore {
  /// Returns the key as 64 lowercase hex chars, creating and persisting it
  /// on first use. Call only when no encrypted file exists yet.
  Future<String> obtainHexKey();

  /// The stored key, or null if none exists. Never creates one: a new key
  /// would silently orphan an existing encrypted file.
  Future<String?> readHexKey();
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
    final existing = await readHexKey();
    if (existing != null) return existing;
    final created = _generate();
    await _storage.write(key: entryName, value: created);
    return created;
  }

  @override
  Future<String?> readHexKey() async {
    final stored = await _storage.read(key: entryName);
    // Never replace a stored key, even a corrupt one: a new key would orphan
    // the encrypted file. Surface it instead (DatabaseUnavailable).
    if (stored != null && !isValidHexKey(stored)) {
      throw StateError('Stored database key is malformed.');
    }
    return stored;
  }

  String _generate() => List.generate(
    32,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
