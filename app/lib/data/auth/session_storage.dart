import 'package:dottoday/data/auth/auth_vault.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _sessionKey = 'dottoday.auth.session';

/// The persisted Supabase session, kept in the [AuthVault] (docs/06 §2).
final class VaultSessionStorage extends LocalStorage {
  const VaultSessionStorage(this._vault);

  final AuthVault _vault;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async => await _vault.read(_sessionKey) != null;

  /// The whole persisted session string (what supabase_flutter expects).
  @override
  Future<String?> accessToken() => _vault.read(_sessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _vault.write(_sessionKey, persistSessionString);

  @override
  Future<void> removePersistedSession() => _vault.delete(_sessionKey);
}

/// The PKCE code verifier between "open the sign-in page" and the callback.
final class VaultPkceStorage extends GotrueAsyncStorage {
  const VaultPkceStorage(this._vault);

  final AuthVault _vault;

  @override
  Future<String?> getItem({required String key}) => _vault.read('pkce.$key');

  @override
  Future<void> setItem({required String key, required String value}) =>
      _vault.write('pkce.$key', value);

  @override
  Future<void> removeItem({required String key}) => _vault.delete('pkce.$key');
}
