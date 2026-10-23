// RFC 8291 Appendix A vector for web/push_crypto.js (docs/09 M5.3b).
// Run: node --test app/tool/push_crypto_test.mjs  (Node >= 20)
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';

const source = readFileSync(new URL('../web/push_crypto.js', import.meta.url), 'utf8');
vm.runInThisContext(source);
const { encrypt, b64uToBytes, bytesToB64u } = globalThis.dottodayPushCrypto;

const vector = {
  plaintext: 'V2hlbiBJIGdyb3cgdXAsIEkgd2FudCB0byBiZSBhIHdhdGVybWVsb24',
  asPrivate: 'yfWPiYE-n46HLnH0KqZOF1fJJU3MYrct3AELtAQ-oRw',
  asPublic: 'BP4z9KsN6nGRTbVYI_c7VJSPQTBtkgcy27mlmlMoZIIgDll6e3vCYLocInmYWAmS6TlzAC8wEqKK6PBru3jl7A8',
  uaPublic: 'BCVxsr7N_eNgVRqvHtD0zTZsEc6-VV-JvLexhqUzORcxaOzi6-AYWXvTBHm4bjyPjs7Vd8pZGH6SRpkNtoIAiw4',
  auth: 'BTBZMqHH6r4Tts7J_aSIgg',
  salt: 'DGv6ra1nlYgDCS1FRnbzlw',
  body:
    'DGv6ra1nlYgDCS1FRnbzlwAAEABBBP4z9KsN6nGRTbVYI_c7VJSPQTBtkgcy27mlmlMoZIIgDll6e3vCYLocInmYWAmS6Tlz' +
    'AC8wEqKK6PBru3jl7A_yl95bQpu6cVPTpK4Mqgkf1CXztLVBSt2Ks3oZwbuwXPXLWyouBWLVWGNWQexSgSxsj_Qulcy4a-fN',
};

test('matches RFC 8291 Appendix A', async () => {
  const body = await encrypt(b64uToBytes(vector.plaintext), vector.uaPublic, vector.auth, {
    salt: vector.salt,
    sender: { privateB64u: vector.asPrivate, publicB64u: vector.asPublic },
  });
  assert.equal(bytesToB64u(body), vector.body);
});

test('a real call uses a fresh salt and sender key every time', async () => {
  const msg = new TextEncoder().encode('{"title":"Gym"}');
  const a = await encrypt(msg, vector.uaPublic, vector.auth);
  const b = await encrypt(msg, vector.uaPublic, vector.auth);
  assert.notEqual(bytesToB64u(a), bytesToB64u(b));
  assert.equal(a.length, 16 + 5 + 65 + msg.length + 1 + 16);
  assert.ok(!Buffer.from(a).toString('latin1').includes('Gym'));
});
