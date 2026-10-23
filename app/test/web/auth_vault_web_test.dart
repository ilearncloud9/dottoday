@TestOn('browser')
@Tags(['web'])
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dottoday/data/auth/auth_vault.dart';
import 'package:dottoday/data/auth/session_storage.dart';
import 'package:flutter_test/flutter_test.dart';

// The web session store (docs/06 §2, ADR-0003, M6.1) in real Chrome:
// sealed in localStorage, opened again by the same browser.
void main() {
  test('a session written sealed reads back as written', () async {
    final storage = VaultSessionStorage(platformAuthVault());
    const session = '{"access_token":"a.b.c","refresh_token":"r"}';
    await storage.persistSession(session);
    expect(await storage.hasAccessToken(), isTrue);
    expect(await storage.accessToken(), session);
    await storage.removePersistedSession();
    expect(await storage.hasAccessToken(), isFalse);
  });

  test('localStorage holds it sealed, not as written', () async {
    final vault = platformAuthVault();
    await vault.write('probe', 'plain-text-session');
    final raw = (globalContext['localStorage']! as JSObject)
        .callMethod<JSString>('getItem'.toJS, 'probe'.toJS);
    expect(raw.toDart, isNot(contains('plain-text-session')));
    expect(await vault.read('probe'), 'plain-text-session');
    await vault.delete('probe');
  });
}
