package app.dottoday.planner.intents

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

    fun attach(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, "dottoday/intents")
    }

    fun detach() {
        channel = null
    }

    fun notifyQueued() {
        val target = channel ?: return
        Handler(Looper.getMainLooper()).post { target.invokeMethod("queueChanged", null) }
    }
}
