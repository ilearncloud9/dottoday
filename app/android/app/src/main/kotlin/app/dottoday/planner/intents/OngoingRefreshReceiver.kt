package app.dottoday.planner.intents

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Posts the ongoing notification again once a minute while it shows (the
 * owner's option A, ED-473): Android moves a notification's countdown by
 * itself, not its ring. At the start too, so "starts in" turns into the
 * countdown. Silent (only alerts once); stops when the notification goes.
 */
class OngoingRefreshReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) = OngoingDot.refresh(context)

    companion object {
        private const val REQUEST = 0x0D08
        private const val MINUTE = 60_000L

        private fun pending(context: Context) = PendingIntent.getBroadcast(
            context, REQUEST, Intent(context, OngoingRefreshReceiver::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        /** The next minute boundary, or the start if that comes first; none after the end. */
        fun schedule(context: Context, content: Map<String, Any?>, nowMs: Long) {
            val start = (content["start_ms"] as? Number)?.toLong() ?: return
            val ends = (content["ends_ms"] as? Number)?.toLong() ?: return
            var next = (nowMs / MINUTE + 1) * MINUTE
            if (nowMs < start && start < next) next = start
            if (next >= ends) return cancel(context)
            val alarms = context.getSystemService(AlarmManager::class.java)
            val exact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarms.canScheduleExactAlarms()
            if (exact) {
                alarms.setExactAndAllowWhileIdle(AlarmManager.RTC, next, pending(context))
            } else {
                alarms.setAndAllowWhileIdle(AlarmManager.RTC, next, pending(context))
            }
        }

        fun cancel(context: Context) {
            context.getSystemService(AlarmManager::class.java).cancel(pending(context))
        }
    }
}
