import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dottoday/data/auth/auth_vault.dart';
import 'package:dottoday/data/db/web/key_vault.dart';

AuthVault authVault() => const _SealedVault();

JSObject get _storage => globalContext['localStorage']! as JSObject;

/// `localStorage`, every value sealed (ADR-0003): a copied profile or a
/// storage dump doesn't carry a usable session.
final class _SealedVault implements AuthVault {
  const _SealedVault();

  @override
  Future<String?> read(String key) async {
    final raw = _storage.callMethod('getItem'.toJS, key.toJS);
    if (!raw.isA<JSString>()) return null;
    return webUnseal((raw! as JSString).toDart);
  }

  @override
  Future<void> write(String key, String value) async {
    final sealed = await webSeal(value);
    _storage.callMethod('setItem'.toJS, key.toJS, sealed.toJS);
  }

  @override
  Future<void> delete(String key) async =>
      _storage.callMethod('removeItem'.toJS, key.toJS);
}

/// The browser's storage goes with the site's data: nothing to forget.
Future<void> forgetAfterReinstall(AuthVault vault, List<String> keys) async {}
