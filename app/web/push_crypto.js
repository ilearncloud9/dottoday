'use strict';
// Web Push message encryption, RFC 8291 (aes128gcm, RFC 8188), with
// WebCrypto only (docs/09 M5.3b). The app encrypts each reminder to its own
// browser's push subscription before upload, so the server stores and
// forwards ciphertext and never sees task text (06 §1).
// Tested in Node against RFC 8291 Appendix A: tool/push_crypto_test.mjs.
(function (root) {
  const subtle = root.crypto.subtle;
  const enc = new TextEncoder();

  function b64uToBytes(s) {
    const b64 = s.replace(/-/g, '+').replace(/_/g, '/') + '==='.slice((s.length + 3) % 4);
    const bin = atob(b64);
    return Uint8Array.from(bin, (c) => c.charCodeAt(0));
  }

  function bytesToB64u(bytes) {
    let bin = '';
    for (const b of bytes) bin += String.fromCharCode(b);
    return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  }

  function concat(...parts) {
    const out = new Uint8Array(parts.reduce((n, p) => n + p.length, 0));
    let o = 0;
    for (const p of parts) { out.set(p, o); o += p.length; }
    return out;
  }

  async function hmac(key, data) {
    const k = await subtle.importKey('raw', key, { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
    return new Uint8Array(await subtle.sign('HMAC', k, data));
  }

  // The sender's ECDH key pair: a fresh one per message, or [fixed] for the
  // test vector ({ privateB64u, publicB64u }).
  async function senderKeys(fixed) {
    if (!fixed) {
      const pair = await subtle.generateKey({ name: 'ECDH', namedCurve: 'P-256' }, true, ['deriveBits']);
      const pub = new Uint8Array(await subtle.exportKey('raw', pair.publicKey));
      return { privateKey: pair.privateKey, publicRaw: pub };
    }
    const pub = b64uToBytes(fixed.publicB64u);
    const jwk = {
      kty: 'EC', crv: 'P-256', ext: true,
      d: fixed.privateB64u,
      x: bytesToB64u(pub.slice(1, 33)),
      y: bytesToB64u(pub.slice(33, 65)),
    };
    const privateKey = await subtle.importKey('jwk', jwk, { name: 'ECDH', namedCurve: 'P-256' }, false, ['deriveBits']);
    return { privateKey, publicRaw: pub };
  }

  /**
   * Encrypts [plaintext] (Uint8Array) for a subscription's p256dh and auth
   * keys (base64url). Returns the aes128gcm body (Uint8Array), one record.
   * [testOnly] fixes the salt and sender keys for the RFC vector.
   */
  async function encrypt(plaintext, p256dhB64u, authB64u, testOnly) {
    const uaPublic = b64uToBytes(p256dhB64u);
    const auth = b64uToBytes(authB64u);
    const salt = testOnly ? b64uToBytes(testOnly.salt) : root.crypto.getRandomValues(new Uint8Array(16));
    const sender = await senderKeys(testOnly && testOnly.sender);
    const uaKey = await subtle.importKey('raw', uaPublic, { name: 'ECDH', namedCurve: 'P-256' }, false, []);
    const ecdh = new Uint8Array(await subtle.deriveBits({ name: 'ECDH', public: uaKey }, sender.privateKey, 256));

    const prkKey = await hmac(auth, ecdh);
    const keyInfo = concat(enc.encode('WebPush: info\0'), uaPublic, sender.publicRaw, new Uint8Array([1]));
    const ikm = await hmac(prkKey, keyInfo);
    const prk = await hmac(salt, ikm);
    const cek = (await hmac(prk, concat(enc.encode('Content-Encoding: aes128gcm\0'), new Uint8Array([1])))).slice(0, 16);
    const nonce = (await hmac(prk, concat(enc.encode('Content-Encoding: nonce\0'), new Uint8Array([1])))).slice(0, 12);

    const aes = await subtle.importKey('raw', cek, { name: 'AES-GCM' }, false, ['encrypt']);
    // One record, so it ends with the last-record delimiter 0x02.
    const sealed = new Uint8Array(await subtle.encrypt({ name: 'AES-GCM', iv: nonce }, aes, concat(plaintext, new Uint8Array([2]))));
    const rs = 4096;
    const header = concat(salt, new Uint8Array([(rs >>> 24) & 255, (rs >>> 16) & 255, (rs >>> 8) & 255, rs & 255, 65]), sender.publicRaw);
    return concat(header, sealed);
  }

  root.dottodayPushCrypto = { encrypt, b64uToBytes, bytesToB64u };
})(typeof self !== 'undefined' ? self : globalThis);
