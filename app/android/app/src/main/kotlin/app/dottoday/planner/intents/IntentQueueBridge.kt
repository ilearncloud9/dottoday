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
                    "readQueue" -> result.success(prefs.getString(DotQueue.KEY, null))
                    "removeQueued" -> {
                        val ids = call.argument<List<String>>("ids")?.toSet() ?: emptySet()
                        DotActionReceiver.remove(prefs, ids, call.argument<Boolean>("unreadable") == true)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    fun detach() {
        channel = null
    }

    fun notifyQueued() {
        val target = channel ?: return
        Handler(Looper.getMainLooper()).post { target.invokeMethod("queueChanged", null) }
    }
}
