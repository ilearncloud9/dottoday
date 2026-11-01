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

    /** A mission morning re-rings a minute after the screen is left alone,
     *  and stops for good 10 minutes after the mission first opened (15 §8). */
    private const val RE_RING_MS = 60_000L
    const val MISSION_CAP_MS = 10 * 60_000L

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
        WakeUpAlarms.record(context, id, "snoozed")
        WakeUpRingService.stop(context)
        notes(context).notify(SNOOZED_NOTE, snoozedNote(context, next))
    }

    /**
     * "I'm up". On a mission morning (docs/15 §8) the ring goes quiet, the
     * mission opens and the alarm re-rings in a minute until the app ends
     * it (done or skipped) or the 10-minute cap does; else [dismiss].
     * Returns the link to open: the mission, or the Wake Up card.
     */
    fun up(context: Context, id: String): String {
        val alarm = WakeUpAlarms.find(context, id)
        if (alarm == null || !alarm.missionDue) {
            dismiss(context, id)
            return "dottoday://wake-up"
        }
        val now = System.currentTimeMillis()
        val since = alarm.missionSinceMs.takeIf { it > 0 } ?: now
        reRing(context, alarm.copy(state = WakeUpAlarm.MISSION, missionSinceMs = since), now)
        WakeUpRingService.stop(context)
        notes(context).cancel(SNOOZED_NOTE)
        return alarm.missionLink
    }

    /** The mission screen is in use: its re-ring moves a minute out. */
    fun keepMission(context: Context, id: String) {
        val alarm = WakeUpAlarms.find(context, id) ?: return
        if (alarm.state == WakeUpAlarm.MISSION) reRing(context, alarm, System.currentTimeMillis())
    }

    /** Whether a mission's 10 minutes are up: the alarm then just stops. */
    fun missionOver(alarm: WakeUpAlarm, now: Long): Boolean =
        alarm.state == WakeUpAlarm.MISSION && now >= alarm.missionSinceMs + MISSION_CAP_MS

    private fun reRing(context: Context, alarm: WakeUpAlarm, now: Long) {
        val next = alarm.copy(fireAtMs = minOf(now + RE_RING_MS, alarm.missionSinceMs + MISSION_CAP_MS))
        WakeUpAlarms.put(context, next)
        WakeUpAlarms.schedule(context, next)
    }

    fun dismiss(context: Context, id: String) {
        val alarm = WakeUpAlarms.find(context, id)
        if (alarm != null) {
            WakeUpAlarms.record(context, id, "stopped")
            // Up, but has the day started? One check later (15 W3).
            WakeUpChecks.arm(context, alarm)
        }
        WakeUpAlarms.disarm(context, id)
        WakeUpRingService.stop(context)
        notes(context).cancel(SNOOZED_NOTE)
    }

    /**
     * A notification's "I'm up". A mission must open the app, and Android
     * 12+ won't let a broadcast do that: on a mission morning the button
     * opens the ringing screen, which does [up]; else it is [STOP].
     */
    fun upIntent(context: Context, alarm: WakeUpAlarm): PendingIntent {
        if (!alarm.missionDue) return pending(context, STOP, alarm.id)
        return PendingIntent.getActivity(
            context, (alarm.id + "up").hashCode(),
            Intent(context, WakeUpAlarmActivity::class.java)
                .putExtra(WakeUpRingService.EXTRA_ID, alarm.id)
                .putExtra(WakeUpAlarmActivity.EXTRA_UP, true)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
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
            .addAction(0, alarm.stop, upIntent(context, alarm))
            .build()

    private fun notes(context: Context) = context.getSystemService(NotificationManager::class.java)
}
