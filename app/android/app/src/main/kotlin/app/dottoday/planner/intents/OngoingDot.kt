package app.dottoday.planner.intents

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import app.dottoday.planner.MainActivity
import app.dottoday.planner.R
import app.dottoday.planner.widgets.AppAccent
import app.dottoday.planner.widgets.DotMarks
import org.json.JSONObject

/**
 * The live dot as an ongoing notification (docs/09 M9.4, docs/11 A1): the
 * Android twin of the iOS Live Activity, from the same content the app
 * sends (`lib/data/live_activity/live_activity_content.dart`) on
 * `dottoday/ongoing`. In Concept E (E-R2-17, the owner's option A, ED-473):
 * Android's header with the count-down chronometer to the end (or the
 * start, when coming up); Dottoday's own body: the ring in the App colour,
 * the title, "9:00 – 11:00 · 1 of 3", and the round ✓ and +15 at the
 * right, through [DotActionReceiver] so they work with the app killed. The
 * ring is drawn at post time, so a quiet alarm posts it again each minute
 * while it shows ([OngoingRefreshReceiver]). One at a
 * time, on the task-alerts channel, silent after the first post; it times
 * out by itself 30 min after the planned end. Android 14+ lets the user
 * swipe it away: [OngoingDismissReceiver] remembers that, the trigger of
 * minimal mode's widget hint as on iOS (docs/14 §5, R-13).
 */
object OngoingDot {
    const val ID = 0x0D07
    private const val CHANNEL = "alerts"
    private const val KEY = "ongoing"
    private const val DISMISSED = "ongoing_dismissed"

    /** Shows [json], or cancels when null. The content is kept for +15. */
    fun sync(context: Context, json: String?) {
        val prefs = DotActionReceiver.prefs(context)
        val manager = NotificationManagerCompat.from(context)
        if (json == null) {
            prefs.edit().remove(KEY).apply()
            manager.cancel(ID)
            OngoingRefreshReceiver.cancel(context)
            return
        }
        prefs.edit().putString(KEY, json).apply()
        if (!manager.areNotificationsEnabled()) return
        val content = runCatching { JsonMaps.toMap(JSONObject(json)) }.getOrNull() ?: return
        post(context, content)
    }

    /** Posts [content] as it is at this minute and times the next refresh. */
    private fun post(context: Context, content: Map<String, Any?>) {
        val now = System.currentTimeMillis()
        @Suppress("MissingPermission") // checked by areNotificationsEnabled
        NotificationManagerCompat.from(context).notify(ID, build(context, content, now))
        OngoingRefreshReceiver.schedule(context, content, now)
    }

    /** The minute's refresh: the stored content posted again, if it still shows. */
    fun refresh(context: Context) {
        val raw = DotActionReceiver.prefs(context).getString(KEY, null) ?: return
        if (activeId(context) == null) return
        if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) return
        val content = runCatching { JsonMaps.toMap(JSONObject(raw)) }.getOrNull() ?: return
        post(context, content)
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

    /**
     * The user swiped the notification away before its own timeout
     * ([nowMs] before the content's `ends_ms`): remembered until the app
     * reads it with [takeDismissed]. A timeout or the app's own cancel
     * never counts.
     */
    fun recordDismissed(context: Context, nowMs: Long) {
        val prefs = DotActionReceiver.prefs(context)
        val raw = prefs.getString(KEY, null) ?: return
        val endsMs = runCatching { JSONObject(raw).getLong("ends_ms") }.getOrNull() ?: return
        if (nowMs >= endsMs) return
        prefs.edit().putBoolean(DISMISSED, true).remove(KEY).apply()
    }

    /** Whether the user swiped one away since the last read; clears it. */
    fun takeDismissed(context: Context): Boolean {
        val prefs = DotActionReceiver.prefs(context)
        val dismissed = prefs.getBoolean(DISMISSED, false)
        if (dismissed) prefs.edit().remove(DISMISSED).apply()
        return dismissed
    }

    /**
     * Fires the posted notification's action [label] ("done" / "plus"), or
     * with "swipe" what a swipe does: its own delete intent, then gone.
     */
    fun press(context: Context, label: String) {
        val manager = context.getSystemService(android.app.NotificationManager::class.java)
        val posted = manager.activeNotifications.firstOrNull { it.id == ID } ?: return
        if (label == "swipe") {
            posted.notification.deleteIntent?.send()
            manager.cancel(ID)
            return
        }
        val raw = DotActionReceiver.prefs(context).getString(KEY, null) ?: return
        val content = runCatching { JsonMaps.toMap(JSONObject(raw)) }.getOrNull() ?: return
        val id = content["id"] as? String ?: return
        // The body's own buttons (no standard actions since ED-473).
        if (label == "plus") {
            plusIntent(context, id, (content["end_ms"] as Number).toLong()).send()
        } else {
            doneIntent(context, id).send()
        }
    }

    private fun doneIntent(context: Context, id: String) =
        DotActionReceiver.pendingIntent(context, DotActionReceiver.ACTION_MARK_DONE, id)

    private fun plusIntent(context: Context, id: String, endMs: Long) =
        DotActionReceiver.pendingIntent(context, DotActionReceiver.ACTION_ADD_FIFTEEN, id, endMs)

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
        val startMs = (c["start_ms"] as Number).toLong()
        val endMs = (c["end_ms"] as Number).toLong()
        // Live by the clock, not only as posted: the minute's refresh turns
        // "starts in" into the countdown at the start.
        val live = nowMs >= startMs
        val target = if (live) endMs else startMs
        val words = if (live) "" else "${c["starts_before"]}${c["starts_after"]}"
        val count = (c["count"] as? String).orEmpty()
        val tone = AppAccent.parse((c["accent"] as? Map<*, *>)?.let { JSONObject(it) })
            .tone(DotMarks.isDark(context))
        val body = body(context, c, id, live, nowMs, startMs, endMs, count, tone)
        return NotificationCompat.Builder(context, CHANNEL)
            .setSmallIcon(R.drawable.ic_stat_dottoday)
            .setColor(tone.dot)
            .setContentTitle(c["title"] as String)
            .setContentText(if (count.isEmpty()) "${c["range"]}" else "${c["range"]} · $count")
            .setSubText(words.trim().takeIf { it.isNotEmpty() })
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(body)
            .setCustomBigContentView(body)
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
            .setDeleteIntent(OngoingDismissReceiver.pendingIntent(context))
            .build()
    }

    /** The body: the ring, the title, its time and count, ✓ and +15. */
    private fun body(
        context: Context, c: Map<String, Any?>, id: String, live: Boolean, nowMs: Long,
        startMs: Long, endMs: Long, count: String, tone: app.dottoday.planner.widgets.AppTone,
    ): RemoteViews {
        val share = if (endMs > startMs) (nowMs - startMs).toDouble() / (endMs - startMs) else 0.0
        val dark = DotMarks.isDark(context)
        val plusFill = if (dark) 0xFF3B383E.toInt() else 0xFFE7E0EC.toInt()
        val plusInk = if (dark) 0xFFE6E0E9.toInt() else 0xFF1D1B20.toInt()
        return RemoteViews(context.packageName, R.layout.ongoing_dot).apply {
            setImageViewBitmap(R.id.ongoing_ring, DotMarks.ring(context, 36f, tone.dot, share, hollow = !live, strokeDp = 4f))
            setTextViewText(R.id.ongoing_title, c["title"] as String)
            setTextViewText(R.id.ongoing_meta, "${c["range"]}")
            // The count on its own line: beside the range it wrapped mid-phrase.
            setTextViewText(R.id.ongoing_count, count)
            setViewVisibility(R.id.ongoing_count, if (count.isEmpty()) android.view.View.GONE else android.view.View.VISIBLE)
            setImageViewBitmap(R.id.ongoing_done, DotMarks.tick(context, 44f, tone.fill, tone.on))
            setContentDescription(R.id.ongoing_done, c["done_label"] as String)
            setOnClickPendingIntent(R.id.ongoing_done, doneIntent(context, id))
            setImageViewBitmap(
                R.id.ongoing_plus,
                DotMarks.plus(context, 44f, plusFill, plusInk, (c["plus_short"] as? String) ?: "+15"),
            )
            setContentDescription(R.id.ongoing_plus, c["plus_label"] as String)
            setOnClickPendingIntent(R.id.ongoing_plus, plusIntent(context, id, endMs))
        }
    }

    private fun open(context: Context, id: String): PendingIntent = PendingIntent.getActivity(
        context,
        ID,
        Intent(Intent.ACTION_VIEW, Uri.parse("dottoday://task/$id"), context, MainActivity::class.java),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
}
