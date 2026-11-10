package app.dottoday.planner.intents

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Tells Dart on `dottoday/intents` that an action was queued while the app
 * runs (lib/data/intents/intent_queue_channel.dart), so it is applied at
 * once instead of on the next resume (docs/09 M9.2c).
 */
object IntentQueueBridge {
    @Volatile private var channel: MethodChannel? = null

    /** Also serves the drain's read and atomic remove (native_action_queue_store.dart). */
    fun attach(context: Context, messenger: BinaryMessenger) {
        val prefs = DotActionReceiver.prefs(context.applicationContext)
        channel = MethodChannel(messenger, "dottoday/intents").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "readQueue" -> {
                        // Any plaintext left by an earlier version is sealed
                        // first; the app gets the words opened (CR-160 I1).
                        DotQueue.sealPlaintext(prefs)
                        result.success(DotQueue.readOpened(prefs))
                    }
                    "removeQueued" -> {
                        val ids = call.argument<List<String>>("ids")?.toSet() ?: emptySet()
                        DotActionReceiver.remove(prefs, ids)
                        result.success(null)
                    }
                    "publishOwner" -> {
                        call.argument<String>("owner")?.let { DotActionReceiver.publishOwner(prefs, it) }
                        result.success(null)
                    }
                    else -> if (debugHooks?.invoke(call, result, prefs) != true) result.notImplemented()
                }
            }
        }
    }

    /**
     * Debug builds only (CR-160 I1): set by `QueueDebugHooks` from the debug
     * source set (android/app/src/debug), which profile and release builds
     * don't compile, so nothing ever sets it there. Lets
     * integration_test/queue_cipher_test.dart drive the real queue code.
     */
    @Volatile
    var debugHooks: (
        (io.flutter.plugin.common.MethodCall, MethodChannel.Result, android.content.SharedPreferences) -> Boolean
    )? = null

    fun detach() {
        channel = null
    }

    fun notifyQueued() {
        val target = channel ?: return
        Handler(Looper.getMainLooper()).post { target.invokeMethod("queueChanged", null) }
    }
}
