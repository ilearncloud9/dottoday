import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/connection/connection.dart';
import 'package:dottoday/data/db/database_key_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_providers.g.dart';

/// Keychain/Keystore settings for the database key (06 §4).
///
/// Apple: `first_unlock` so background refresh (M5.2) can open the DB while
/// the device is locked, and so encrypted device backups carry the key to a
/// new phone (R-08). macOS: legacy keychain, because the data-protection
/// keychain needs the Keychain Sharing entitlement and a provisioning
/// profile (revisit with the macOS widget app group, M5.4).
const databaseKeyStorage = FlutterSecureStorage(
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  mOptions: MacOsOptions(
    accessibility: KeychainAccessibility.first_unlock,
    usesDataProtectionKeychain: false,
  ),
);

/// Where the SQLCipher key comes from. Tests override with a fixed key.
@Riverpod(keepAlive: true)
DatabaseKeyStore databaseKeyStore(Ref ref) =>
    SecureDatabaseKeyStore(databaseKeyStorage);

/// The single [AppDatabase] connection. Opens lazily on the first query;
/// tests override it with `AppDatabase(NativeDatabase.memory())`.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = openAppDatabase(ref.watch(databaseKeyStoreProvider));
  ref.onDispose(db.close);
  return db;
}
