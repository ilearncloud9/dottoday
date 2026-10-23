import 'package:dottoday/data/auth/auth_vault_native.dart'
    if (dart.library.js_interop) 'package:dottoday/data/auth/auth_vault_web.dart'
    as platform;

/// Where the auth session and the PKCE verifier live (docs/06 §2): the
/// Keychain / Keystore on devices, `localStorage` sealed with a
/// non-extractable WebCrypto key on the web (ADR-0003). Never
/// SharedPreferences.
abstract interface class AuthVault {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// This platform's vault.
AuthVault platformAuthVault() => platform.authVault();
