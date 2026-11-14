package app.dottoday.planner.intents

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import org.json.JSONObject
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/**
 * Queued text at rest (CR-160 I1, Q2): an `add_task` entry's `text`,
 * `subject` and `note` are sealed with AES-256-GCM under a non-exportable
 * Android Keystore key before the entry reaches the shared preferences,
 * and opened only in this app's process when the app reads the queue.
 *
 * - The Keystore makes a fresh random nonce for every encryption
 *   (`setRandomizedEncryptionRequired`), never chosen here.
 * - The entry's immutable metadata (id, time, kind, owner, guest session,
 *   shared) is authenticated as associated data: an entry whose owner stamp
 *   was changed afterwards no longer opens, so nothing can be re-attributed.
 * - Each sealed entry names its key alias, so old keys keep opening old
 *   entries after a rotation.
 * - A missing key, a wrong key or changed metadata leaves the entry sealed
 *   and marked unreadable when read: kept, never applied, never erased.
 * - Sealing failure is reported to the caller, which refuses the action:
 *   there is no plaintext fallback.
 * Nothing here logs text, ciphertext or keys.
 */
object QueueCipher {
    /** The alias new entries are sealed with. */
    const val CURRENT_ALIAS = "dottoday_queue_v1"

    /** The fields that hold a person's words. */
    val TEXT_FIELDS = listOf("text", "subject", "note")

    const val SEALED = "sealed"
    const val UNREADABLE = "unreadable"
    private const val KEYSTORE = "AndroidKeyStore"
    private const val TRANSFORMATION = "AES/GCM/NoPadding"
    private const val TAG_BITS = 128

    /** Whether [entry] holds plaintext words that should be sealed. */
    fun hasPlainText(entry: JSONObject): Boolean =
        TEXT_FIELDS.any { entry.has(it) } && !entry.has(SEALED)

    /**
     * [entry] with its words sealed under [alias], everything else as it
     * was; null when sealing failed (the caller refuses or keeps the
     * plaintext entry as it is, never writes a half-sealed one).
     */
    fun seal(entry: JSONObject, alias: String = CURRENT_ALIAS): JSONObject? = runCatching {
        val words = JSONObject()
        for (field in TEXT_FIELDS) if (entry.has(field)) words.put(field, entry.get(field))
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, key(alias, create = true))
        cipher.updateAAD(associated(entry))
        val ciphertext = cipher.doFinal(words.toString().toByteArray(Charsets.UTF_8))
        val out = JSONObject(entry.toString())
        for (field in TEXT_FIELDS) out.remove(field)
        out.put(
            SEALED,
            JSONObject()
                .put("v", 1)
                .put("key", alias)
                .put("iv", b64(cipher.iv))
                .put("ct", b64(ciphertext)),
        )
        out
    }.getOrNull()

    /**
     * [entry] opened for the app: its words back and `sealed` gone; or, when
     * it can't be opened (key missing, wrong key, changed metadata, bad
     * data), still sealed and marked [UNREADABLE], so the app keeps it and
     * never applies it. Entries without `sealed` come back unchanged.
     */
    fun open(entry: JSONObject): JSONObject {
        val sealed = entry.optJSONObject(SEALED) ?: return entry
        return runCatching {
            val alias = sealed.getString("key")
            val key = key(alias, create = false) ?: error("no key")
            val cipher = Cipher.getInstance(TRANSFORMATION)
            cipher.init(Cipher.DECRYPT_MODE, key, GCMParameterSpec(TAG_BITS, unb64(sealed.getString("iv"))))
            cipher.updateAAD(associated(entry))
            val words = JSONObject(String(cipher.doFinal(unb64(sealed.getString("ct"))), Charsets.UTF_8))
            val out = JSONObject(entry.toString())
            out.remove(SEALED)
            for (field in TEXT_FIELDS) if (words.has(field)) out.put(field, words.get(field))
            out
        }.getOrElse { JSONObject(entry.toString()).put(UNREADABLE, true) }
    }

    /**
     * The authenticated metadata: a fixed, canonical encoding of the fields
     * that must never change after sealing.
     */
    fun associated(entry: JSONObject): ByteArray = JSONObject()
        .put("id", entry.opt("id") ?: JSONObject.NULL)
        .put("at_ms", entry.opt("at_ms") ?: JSONObject.NULL)
        .put("kind", entry.opt("kind") ?: JSONObject.NULL)
        .put("owner", entry.opt("owner") ?: JSONObject.NULL)
        .put("guest_session", entry.opt("guest_session") ?: JSONObject.NULL)
        .put("shared", entry.optBoolean("shared", false))
        .toString()
        .toByteArray(Charsets.UTF_8)

    /** Removes key [alias] (tests, and a future rotation's last step). */
    fun deleteKey(alias: String) {
        runCatching { keyStore().deleteEntry(alias) }
    }

    private fun key(alias: String, create: Boolean): SecretKey? {
        val store = keyStore()
        (store.getKey(alias, null) as? SecretKey)?.let { return it }
        if (!create) return null
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, KEYSTORE)
        generator.init(
            KeyGenParameterSpec.Builder(alias, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setKeySize(256)
                .setRandomizedEncryptionRequired(true)
                .build(),
        )
        return generator.generateKey()
    }

    private fun keyStore(): KeyStore = KeyStore.getInstance(KEYSTORE).apply { load(null) }

    private fun b64(bytes: ByteArray): String = Base64.encodeToString(bytes, Base64.NO_WRAP)

    private fun unb64(text: String): ByteArray = Base64.decode(text, Base64.NO_WRAP)
}
