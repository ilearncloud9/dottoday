package app.dottoday.planner.intents

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import app.dottoday.planner.MainActivity
import app.dottoday.planner.R
import org.json.JSONObject

/**
 * The live dot as an ongoing notification (docs/09 M9.4, docs/11 A1): the
 * Android twin of the iOS Live Activity, from the same content the app
 * sends (`lib/data/live_activity/live_activity_content.dart`) on
 * `dottoday/ongoing`. A count-down chronometer to the end (or the start,
 * when coming up), the title, "9:00 – 11:00 · 1 of 3", Done and +15 min
 * through [DotActionReceiver] so they work with the app killed. One at a
 * time, on the task-alerts channel, silent after the first post; it times
 * out by itself 30 min after the planned end.
 */
object OngoingDot {
    const val ID = 0x0D07
    private const val CHANNEL = "alerts"
    private const val KEY = "ongoing"

    /** Shows [json], or cancels when null. The content is kept for +15. */
    fun sync(context: Context, json: String?) {
        val prefs = DotActionReceiver.prefs(context)
        val manager = NotificationManagerCompat.from(context)
        if (json == null) {
            prefs.edit().remove(KEY).apply()
            manager.cancel(ID)
            return
        }
        prefs.edit().putString(KEY, json).apply()
        if (!manager.areNotificationsEnabled()) return
        val content = runCatching { JsonMaps.toMap(JSONObject(json)) }.getOrNull() ?: return
        @Suppress("MissingPermission") // checked by areNotificationsEnabled
        manager.notify(ID, build(context, content, System.currentTimeMillis()))
    }

    /** The posted notification's occurrence id, or null when none shows. */
    fun activeId(context: Context): String? {
        val manager = context.getSystemService(android.app.NotificationManager::class.java)
        if (manager.activeNotifications.none { it.id == ID }) return null
        val raw = DotActionReceiver.prefs(context).getString(KEY, null) ?: return null
        return runCatching { JSONObject(raw).getString("id") }.getOrNull()
    }

    /** The posted notification's content JSON, or null when none shows. */
    fun activeContent(context: Context): String? =
        if (activeId(context) == null) null else DotActionReceiver.prefs(context).getString(KEY, null)

    /** Fires the posted notification's action [label] ("done" / "plus"). */
    fun press(context: Context, label: String) {
        val manager = context.getSystemService(android.app.NotificationManager::class.java)
        val posted = manager.activeNotifications.firstOrNull { it.id == ID } ?: return
        val index = if (label == "plus") 1 else 0
        posted.notification.actions?.getOrNull(index)?.actionIntent?.send()
    }

    /** After Done / +15 from the notification: gone, or the end moved. */
    fun afterAction(context: Context, kind: DotActionKind, occurrenceId: String) {
        val raw = DotActionReceiver.prefs(context).getString(KEY, null) ?: return
        val content = runCatching { JsonMaps.toMap(JSONObject(raw)) }.getOrNull() ?: return
        if ((content["id"] as? String)?.lowercase() != occurrenceId.lowercase()) return
        when (kind) {
            DotActionKind.MARK_DONE -> sync(context, null)
            DotActionKind.ADD_FIFTEEN ->
                sync(context, JsonMaps.fromValue(DotQueue.plusFifteenContent(content)).toString())
            else -> Unit
        }
    }

    private fun build(context: Context, c: Map<String, Any?>, nowMs: Long): android.app.Notification {
        val id = c["id"] as String
        val live = c["live"] == true
        val endMs = (c["end_ms"] as Number).toLong()
        val target = if (live) endMs else (c["start_ms"] as Number).toLong()
        // Coming up: "starts in" beside the header's countdown. Live, the
        // countdown alone says it (a lone "left" in the header reads oddly).
        val words = if (live) "" else "${c["starts_before"]}${c["starts_after"]}"
        val count = (c["count"] as? String).orEmpty()
        return NotificationCompat.Builder(context, CHANNEL)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setColor(runCatching { Color.parseColor(c["color"] as String) }.getOrDefault(Color.BLUE))
            .setContentTitle(c["title"] as String)
            .setContentText(if (count.isEmpty()) "${c["range"]}" else "${c["range"]} · $count")
            .setSubText(words.trim().takeIf { it.isNotEmpty() })
            .setUsesChronometer(true)
            .setChronometerCountDown(true)
            .setWhen(target)
            .setShowWhen(true)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .setTimeoutAfter(maxOf(1L, (c["ends_ms"] as Number).toLong() - nowMs))
            .setContentIntent(open(context, id))
            .addAction(
                0, c["done_label"] as String,
                DotActionReceiver.pendingIntent(context, DotActionReceiver.ACTION_MARK_DONE, id),
            )
            .addAction(
                0, c["plus_label"] as String,
                DotActionReceiver.pendingIntent(context, DotActionReceiver.ACTION_ADD_FIFTEEN, id, endMs),
            )
            .build()
    }

    private fun open(context: Context, id: String): PendingIntent = PendingIntent.getActivity(
        context,
        ID,
        Intent(Intent.ACTION_VIEW, Uri.parse("dottoday://task/$id"), context, MainActivity::class.java),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
}
