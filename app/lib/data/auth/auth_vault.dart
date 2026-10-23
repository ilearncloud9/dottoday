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

/// A fresh install starts signed out on every platform (docs/09 M6.8):
/// the Keychain keeps items after the app is deleted, Android's store and
/// the browser's don't. A marker in app storage (gone with the app) tells.
Future<void> forgetSessionAfterReinstall(AuthVault vault, List<String> keys) =>
    platform.forgetAfterReinstall(vault, keys);
