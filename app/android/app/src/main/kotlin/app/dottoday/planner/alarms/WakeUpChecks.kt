package app.dottoday.planner.alarms

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.core.app.NotificationCompat
import app.dottoday.planner.MainActivity
import app.dottoday.planner.R

/**
 * The Wake Up Check (docs/15 W3, M17.4). It is armed when "I'm up" stops a
 * Wake Up alarm, so it reaches a phone put back down with the app closed:
 * [WakeUpAlarm.checkMin] later, one nudge to start the day's first dot.
 * By default it is a gentle notification; when set to ring, it is the same
 * alarm once more, with no snooze. The app calls it off when the day
 * starts (`AlarmGateway.sync`'s started days). There is never more than
 * one per day.
 */
object WakeUpChecks {
    const val ACTION = "app.dottoday.planner.WAKE_UP_CHECK"
    private const val CHANNEL = "wake_up_check"

    /** Arms [alarm]'s check, if it has one; never for a check itself. */
    fun arm(context: Context, alarm: WakeUpAlarm) {
        if (alarm.checkMin <= 0 || isCheck(alarm.id) || alarm.id == WakeUpAlarm.TEST_ID) return
        val at = System.currentTimeMillis() + alarm.checkMin * 60_000L
        if (alarm.checkLoud) {
            val ring = alarm.copy(
                id = checkId(alarm.id), fireAtMs = at, title = alarm.checkTitle,
                body = alarm.checkBody, snoozeMin = 0, state = WakeUpAlarm.ARMED,
                snoozes = 0, checkMin = 0,
            )
            WakeUpAlarms.put(context, ring)
            WakeUpAlarms.schedule(context, ring)
            return
        }
        alarms(context).setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pending(context, alarm))
    }

    /** Calls off the checks of [days] (`yyyy-MM-dd`): those days began. */
    fun cancel(context: Context, days: Collection<String>) {
        for (day in days) {
            val id = "wakeup:$day"
            val pending = pending(context, WakeUpAlarm.blank(id))
            alarms(context).cancel(pending)
            pending.cancel()
            WakeUpAlarms.disarm(context, checkId(id))
            notes(context).cancel(id.hashCode())
        }
    }

    /** Whether [id]'s gentle check is armed (the device test). */
    fun armed(context: Context, id: String): Boolean = PendingIntent.getBroadcast(
        context, ("check:" + id).hashCode(),
        Intent(context, WakeUpAlarmReceiver::class.java).setAction(ACTION),
        PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
    ) != null

    /** The gentle check's time came: one notification, Start opens Focus. */
    fun post(context: Context, intent: Intent) {
        val id = intent.getStringExtra(WakeUpAlarmReceiver.EXTRA_ID) ?: return
        val target = intent.getStringExtra(EXTRA_TARGET).orEmpty()
        val link = if (target.isEmpty()) "dottoday://today" else "dottoday://focus/$target"
        val open = PendingIntent.getActivity(
            context, id.hashCode(),
            Intent(Intent.ACTION_VIEW, Uri.parse(link), context, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        ensureChannel(context)
        val note = NotificationCompat.Builder(context, CHANNEL)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(intent.getStringExtra(EXTRA_TITLE))
            .setContentText(intent.getStringExtra(EXTRA_BODY))
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .setContentIntent(open)
            .addAction(0, intent.getStringExtra(EXTRA_START), open)
            .build()
        notes(context).notify(id.hashCode(), note)
    }

    private fun pending(context: Context, alarm: WakeUpAlarm): PendingIntent = PendingIntent.getBroadcast(
        context, ("check:" + alarm.id).hashCode(),
        Intent(context, WakeUpAlarmReceiver::class.java)
            .setAction(ACTION)
            .putExtra(WakeUpAlarmReceiver.EXTRA_ID, alarm.id)
            .putExtra(EXTRA_TITLE, alarm.checkTitle)
            .putExtra(EXTRA_BODY, alarm.checkBody)
            .putExtra(EXTRA_START, alarm.checkStart)
            .putExtra(EXTRA_TARGET, alarm.checkTarget),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    private fun ensureChannel(context: Context) {
        notes(context).createNotificationChannel(
            NotificationChannel(
                CHANNEL,
                context.getString(R.string.wake_up_check_channel),
                NotificationManager.IMPORTANCE_HIGH,
            ),
        )
    }

    private fun checkId(id: String) = "$id:check"

    fun isCheck(id: String) = id.endsWith(":check")

    private fun alarms(context: Context) = context.getSystemService(AlarmManager::class.java)

    private fun notes(context: Context) = context.getSystemService(NotificationManager::class.java)

    private const val EXTRA_TITLE = "title"
    private const val EXTRA_BODY = "body"
    private const val EXTRA_START = "start"
    private const val EXTRA_TARGET = "target"
}
