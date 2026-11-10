package app.dottoday.planner.intents

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri

/**
 * Debug builds only (CR-160 I1, Q2): this file is in the debug source set,
 * so profile and release builds don't contain it. Registered by
 * android/app/src/debug/AndroidManifest.xml as a provider, it installs
 * [IntentQueueBridge.debugHooks] at start so
 * integration_test/queue_cipher_test.dart can drive the real Keystore
 * through the real queue code.
 */
class QueueDebugHooks : ContentProvider() {
    override fun onCreate(): Boolean {
        IntentQueueBridge.debugHooks = { call, result, prefs ->
            when (call.method) {
                "debugShare" -> {
                    result.success(
                        ShareIntake.append(
                            prefs,
                            call.argument<String>("text") ?: "",
                            call.argument<String>("subject"),
                            System.currentTimeMillis(),
                            call.argument<String>("alias") ?: QueueCipher.CURRENT_ALIAS,
                        ),
                    )
                    true
                }
                "debugRawQueue" -> {
                    result.success(synchronized(DotQueue) { prefs.getString(DotQueue.KEY, null) })
                    true
                }
                "debugWriteRawQueue" -> {
                    synchronized(DotQueue) {
                        prefs.edit().putString(DotQueue.KEY, call.argument<String>("raw")).commit()
                    }
                    result.success(null)
                    true
                }
                "debugDeleteKey" -> {
                    QueueCipher.deleteKey(call.argument<String>("alias") ?: QueueCipher.CURRENT_ALIAS)
                    result.success(null)
                    true
                }
                else -> false
            }
        }
        return true
    }

    override fun query(u: Uri, p: Array<String>?, s: String?, a: Array<String>?, o: String?): Cursor? = null
    override fun getType(uri: Uri): String? = null
    override fun insert(uri: Uri, values: ContentValues?): Uri? = null
    override fun delete(uri: Uri, s: String?, a: Array<String>?): Int = 0
    override fun update(uri: Uri, v: ContentValues?, s: String?, a: Array<String>?): Int = 0
}
