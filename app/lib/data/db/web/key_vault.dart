import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dottoday/data/db/web/js_bindings.dart';

const _dbName = 'dottoday-keyvault';
const _store = 'keys';
const _entry = 'db-cipher-v1';

/// The web database key (ADR-0003, M2.9): 32 random bytes as hex, stored
/// in IndexedDB only in encrypted form, wrapped by a non-extractable
/// AES-GCM `CryptoKey` that script can use but never read out. XSS running
/// in the page can still use it; that residual risk is documented in
/// ADR-0003.
///
/// With [create] false (the drift worker) a missing key is an error: only
/// the page creates it, before opening any database.
Future<String> webDatabaseKey({required bool create}) async {
  final db = await _open();
  try {
    final existing = await _read(db);
    if (existing != null) return await _unwrap(existing);
    if (!create) throw StateError('Web database key missing.');
    await _add(db, await _wrapNew());
    // Re-read: another tab may have won the race to `add` first.
    return await _unwrap((await _read(db))!);
  } finally {
    db.close();
  }
}

Future<IdbDatabase> _open() async {
  final request = indexedDB.open(_dbName, 1);
  request.onupgradeneeded = ((JSAny _) {
    (request.result! as IdbDatabase).createObjectStore(_store);
  }).toJS;
  return (await idbResult(request))! as IdbDatabase;
}

Future<JSObject?> _read(IdbDatabase db) async =>
    (await idbResult(
          db.transaction(_store, 'readonly').objectStore(_store).get(_entry),
        ))
        as JSObject?;

Future<void> _add(IdbDatabase db, JSObject record) async {
  try {
    await idbResult(
      db
          .transaction(_store, 'readwrite')
          .objectStore(_store)
          .add(record, _entry),
    );
  } on StateError {
    // ConstraintError: a concurrent tab stored one first; theirs is used.
  }
}

JSObject _aesGcm([JSUint8Array? iv]) {
  final algorithm = JSObject()..['name'] = 'AES-GCM'.toJS;
  if (iv == null) {
    algorithm['length'] = 256.toJS;
  } else {
    algorithm['iv'] = iv;
  }
  return algorithm;
}

Future<JSObject> _wrapNew() async {
  final wrapKey = await crypto.subtle
      .generateKey(_aesGcm(), false, ['encrypt'.toJS, 'decrypt'.toJS].toJS)
      .toDart;
  final raw = crypto.getRandomValues(JSUint8Array.withLength(32));
  final iv = crypto.getRandomValues(JSUint8Array.withLength(12));
  final sealed = await crypto.subtle.encrypt(_aesGcm(iv), wrapKey, raw).toDart;
  return JSObject()
    ..['wrapKey'] = wrapKey
    ..['iv'] = iv
    ..['sealed'] = sealed;
}

Future<String> _unwrap(JSObject record) async {
  final raw = await crypto.subtle
      .decrypt(
        _aesGcm(record['iv']! as JSUint8Array),
        record['wrapKey']! as JSObject,
        record['sealed']! as JSArrayBuffer,
      )
      .toDart;
  return [
    for (final b in raw.toDart.asUint8List())
      b.toRadixString(16).padLeft(2, '0'),
  ].join();
}

const _sessionEntry = 'session-cipher-v1';

/// Seals [plain] (the auth session, ADR-0003) under its own non-extractable
/// AES-GCM key in the vault: base64 of iv + ciphertext. Script in the page
/// can still use the key; storage copied elsewhere can't be read.
Future<String> webSeal(String plain) async {
  final key = await _sessionKey();
  final iv = crypto.getRandomValues(JSUint8Array.withLength(12));
  final sealed = await crypto.subtle
      .encrypt(_aesGcm(iv), key, utf8.encode(plain).toJS)
      .toDart;
  return base64.encode([...iv.toDart, ...sealed.toDart.asUint8List()]);
}

/// Opens what [webSeal] made; null when it can't (another key, damaged).
Future<String?> webUnseal(String sealed) async {
  try {
    final bytes = base64.decode(sealed);
    final key = await _sessionKey();
    final plain = await crypto.subtle
        .decrypt(
          _aesGcm(bytes.sublist(0, 12).toJS),
          key,
          bytes.sublist(12).buffer.toJS,
        )
        .toDart;
    return utf8.decode(plain.toDart.asUint8List());
  } on Object {
    return null;
  }
}

Future<JSObject> _sessionKey() async {
  final db = await _open();
  try {
    final get = db
        .transaction(_store, 'readonly')
        .objectStore(_store)
        .get(_sessionEntry);
    final existing = await idbResult(get);
    if (existing != null) return existing as JSObject;
    final key = await crypto.subtle
        .generateKey(_aesGcm(), false, ['encrypt'.toJS, 'decrypt'.toJS].toJS)
        .toDart;
    try {
      await idbResult(
        db
            .transaction(_store, 'readwrite')
            .objectStore(_store)
            .add(key, _sessionEntry),
      );
    } on StateError {
      // Another tab stored one first: use theirs.
      return (await idbResult(
            db
                .transaction(_store, 'readonly')
                .objectStore(_store)
                .get(_sessionEntry),
          ))!
          as JSObject;
    }
    return key;
  } finally {
    db.close();
  }
}
