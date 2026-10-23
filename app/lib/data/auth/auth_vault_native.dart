import 'dart:io';

import 'package:dottoday/data/auth/auth_vault.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Same keychain settings as the database key (database_providers.dart):
/// readable after first unlock, so a background refresh can sync.
const _storage = FlutterSecureStorage(
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  mOptions: MacOsOptions(
    accessibility: KeychainAccessibility.first_unlock,
    usesDataProtectionKeychain: false,
  ),
);

AuthVault authVault() => const _SecureVault();

final class _SecureVault implements AuthVault {
  const _SecureVault();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

Future<void> forgetAfterReinstall(AuthVault vault, List<String> keys) async {
  final marker = File(
    '${(await getApplicationSupportDirectory()).path}/auth_installed',
  );
  if (marker.existsSync()) return;
  for (final k in keys) {
    await vault.delete(k);
  }
  await marker.create(recursive: true);
}
