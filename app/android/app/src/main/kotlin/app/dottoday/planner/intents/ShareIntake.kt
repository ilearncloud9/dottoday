package app.dottoday.planner.intents

import android.content.Context
import android.content.Intent
import android.net.Uri
import org.json.JSONArray

/**
 * "Share → Dottoday" (docs/11 B6, docs/09 M12.4): text or a link shared
 * from another app is queued as one `add_task` entry marked `shared`, the
 * same queue the widgets use; the app makes the Inbox task — title and the
 * source as its note — when it drains (lib/domain/quick_add/shared_capture.dart).
 * The intent then opens the Inbox (`dottoday://inbox`), where it lands.
 * Nothing leaves the device.
 */
object ShareIntake {
    /** A task note's limit (docs/05 "Validation"). */
    private const val MAX_TEXT = 10000
    private const val MAX_SUBJECT = 200

    /** Queues [intent]'s share and turns it into a link to the Inbox; false if it isn't one. */
    fun accept(context: Context, intent: Intent?): Boolean {
        if (intent?.action != Intent.ACTION_SEND) return false
        if (intent.type?.startsWith("text/") != true) return false
        val text = intent.getStringExtra(Intent.EXTRA_TEXT)?.trim().orEmpty()
        if (text.isEmpty()) return false
        val subject = intent.getStringExtra(Intent.EXTRA_SUBJECT)?.trim()
        append(DotActionReceiver.prefs(context.applicationContext), text, subject, System.currentTimeMillis())
        IntentQueueBridge.notifyQueued()
        intent.action = Intent.ACTION_VIEW
        intent.data = Uri.parse("dottoday://inbox")
        return true
    }

    /** One `shared` entry, appended under the queue's lock. */
    fun append(prefs: android.content.SharedPreferences, text: String, subject: String?, nowMs: Long) =
        synchronized(DotQueue) {
            val entry = DotQueue.entry(DotActionKind.ADD_TASK, nowMs, text = text.take(MAX_TEXT))
                .toMutableMap()
            entry["shared"] = true
            subject?.takeIf { it.isNotEmpty() }?.let { entry["subject"] = it.take(MAX_SUBJECT) }
            val queue = prefs.getString(DotQueue.KEY, null)
                ?.let { runCatching { JSONArray(it) }.getOrNull() } ?: JSONArray()
            queue.put(JsonMaps.fromValue(entry))
            prefs.edit().putString(DotQueue.KEY, queue.toString()).commit()
        }
}
