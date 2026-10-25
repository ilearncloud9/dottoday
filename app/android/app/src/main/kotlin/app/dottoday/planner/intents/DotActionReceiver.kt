package app.dottoday.planner.intents

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import androidx.glance.appwidget.updateAll
import app.dottoday.planner.widgets.InboxWidget
import app.dottoday.planner.widgets.NextUpWidget
import app.dottoday.planner.widgets.TodayWidget
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject

/**
 * Done / +15 / Start from a widget or a notification while the app may not
 * be running (docs/09 M9.2c): queues the action for the app, shows it on
 * the snapshot at once, redraws the widgets and tells a running app to
 * drain. Not exported: only this app's own PendingIntents reach it.
 */
class DotActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val kind = KINDS[intent.action] ?: return
        val occurrenceId = intent.getStringExtra(EXTRA_OCCURRENCE) ?: return
        val plannedEnd = intent.getLongExtra(EXTRA_PLANNED_END, -1).takeIf { it >= 0 }
        val pending = goAsync()
        CoroutineScope(Dispatchers.IO).launch {
            try {
                perform(prefs(context), kind, occurrenceId, plannedEnd, System.currentTimeMillis())
                OngoingDot.afterAction(context, kind, occurrenceId)
                redraw(context)
                IntentQueueBridge.notifyQueued()
            } finally {
                pending.finish()
            }
        }
    }

    companion object {
        const val ACTION_MARK_DONE = "app.dottoday.planner.action.MARK_DONE"
        const val ACTION_ADD_FIFTEEN = "app.dottoday.planner.action.ADD_FIFTEEN"
        const val ACTION_START_FOCUS = "app.dottoday.planner.action.START_FOCUS"
        const val EXTRA_OCCURRENCE = "occurrence_id"
        const val EXTRA_PLANNED_END = "planned_end_ms"

        private val KINDS = mapOf(
            ACTION_MARK_DONE to DotActionKind.MARK_DONE,
            ACTION_ADD_FIFTEEN to DotActionKind.ADD_FIFTEEN,
            ACTION_START_FOCUS to DotActionKind.START_FOCUS,
        )

        /** The `home_widget` prefs the app reads the queue and snapshot from. */
        fun prefs(context: Context): SharedPreferences =
            context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

        /** A broadcast for a widget button or a notification action. */
        fun pendingIntent(context: Context, action: String, occurrenceId: String, plannedEndMs: Long? = null): PendingIntent {
            val intent = Intent(context, DotActionReceiver::class.java)
                .setAction(action)
                .putExtra(EXTRA_OCCURRENCE, occurrenceId)
            plannedEndMs?.let { intent.putExtra(EXTRA_PLANNED_END, it) }
            return PendingIntent.getBroadcast(
                context,
                (action + occurrenceId).hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }

        /** Appends to the queue and patches the snapshot, in one commit. */
        fun perform(
            prefs: SharedPreferences,
            kind: DotActionKind,
            occurrenceId: String,
            plannedEndMs: Long?,
            nowMs: Long,
        ) = synchronized(DotQueue) {
            val queue = prefs.getString(DotQueue.KEY, null)
                ?.let { runCatching { JSONArray(it) }.getOrNull() } ?: JSONArray()
            queue.put(JsonMaps.fromValue(DotQueue.entry(kind, nowMs, occurrenceId, plannedEndMs)))
            val edit = prefs.edit().putString(DotQueue.KEY, queue.toString())
            prefs.getString(DotQueue.SNAPSHOT_KEY, null)
                ?.let { runCatching { JsonMaps.toMap(JSONObject(it)) }.getOrNull() }
                ?.let { DotQueue.patch(it, kind, occurrenceId, nowMs) }
                ?.let { edit.putString(DotQueue.SNAPSHOT_KEY, JsonMaps.fromValue(it).toString()) }
            edit.commit()
        }

        /**
         * The app's drain removes what it settled (and, with [unreadable],
         * entries without an id) in one step under the same lock as
         * [perform], so an action queued meanwhile is never lost.
         */
        fun remove(prefs: SharedPreferences, ids: Set<String>, unreadable: Boolean) = synchronized(DotQueue) {
            val queue = prefs.getString(DotQueue.KEY, null)
                ?.let { runCatching { JSONArray(it) }.getOrNull() } ?: return@synchronized
            val kept = JSONArray()
            for (i in 0 until queue.length()) {
                val id = (queue.opt(i) as? JSONObject)?.optString("id", "")?.takeIf { it.isNotEmpty() }
                val drop = if (id == null) unreadable else id in ids
                if (!drop) kept.put(queue.opt(i))
            }
            prefs.edit().putString(DotQueue.KEY, kept.toString()).commit()
        }

        private suspend fun redraw(context: Context) {
            NextUpWidget().updateAll(context)
            TodayWidget().updateAll(context)
            InboxWidget().updateAll(context)
        }
    }
}
