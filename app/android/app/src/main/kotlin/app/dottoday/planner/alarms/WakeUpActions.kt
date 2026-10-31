package app.dottoday.planner.alarms

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import app.dottoday.planner.R
import java.text.DateFormat
import java.util.Date

/**
 * Snooze and "I'm up" (docs/15 W1b), from the ringing screen or the
 * notification's buttons. Snooze re-arms the same day's alarm
 * `snoozeMin` later and shows a countdown until then, with "I'm up" to
 * call it off; past the limit only "I'm up" is offered (15 §4).
 */
object WakeUpActions {
    const val SNOOZE = "app.dottoday.planner.WAKE_UP_SNOOZE"
    const val STOP = "app.dottoday.planner.WAKE_UP_STOP"
    const val SNOOZED_NOTE = 0x534e5a45 // "SNZE"

    fun snooze(context: Context, id: String) {
        val alarm = WakeUpAlarms.find(context, id) ?: return WakeUpRingService.stop(context)
        if (!alarm.canSnooze) return dismiss(context, id)
        val next = alarm.copy(
            state = WakeUpAlarm.SNOOZED,
            snoozes = alarm.snoozes + 1,
            fireAtMs = System.currentTimeMillis() + alarm.snoozeMin * 60_000L,
        )
        WakeUpAlarms.put(context, next)
        WakeUpAlarms.schedule(context, next)
        WakeUpRingService.stop(context)
        notes(context).notify(SNOOZED_NOTE, snoozedNote(context, next))
    }

    fun dismiss(context: Context, id: String) {
        WakeUpAlarms.disarm(context, id)
        WakeUpRingService.stop(context)
        notes(context).cancel(SNOOZED_NOTE)
    }

    /** A notification button's intent, handled by [WakeUpAlarmReceiver]. */
    fun pending(context: Context, action: String, id: String): PendingIntent = PendingIntent.getBroadcast(
        context, (action + id).hashCode(),
        Intent(context, WakeUpAlarmReceiver::class.java)
            .setAction(action)
            .putExtra(WakeUpAlarmReceiver.EXTRA_ID, id),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    private fun snoozedNote(context: Context, alarm: WakeUpAlarm) =
        NotificationCompat.Builder(context, WakeUpRingService.CHANNEL)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(alarm.title)
            .setContentText(
                context.getString(
                    R.string.wake_up_snoozed,
                    DateFormat.getTimeInstance(DateFormat.SHORT).format(Date(alarm.fireAtMs)),
                ),
            )
            .setUsesChronometer(true)
            .setChronometerCountDown(true)
            .setWhen(alarm.fireAtMs)
            .setShowWhen(true)
            .setOngoing(true)
            .setSilent(true)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .addAction(0, alarm.stop, pending(context, STOP, alarm.id))
            .build()

    private fun notes(context: Context) = context.getSystemService(NotificationManager::class.java)
}
