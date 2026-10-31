package app.dottoday.planner.alarms

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import app.dottoday.planner.MainActivity
import org.json.JSONArray
import org.json.JSONObject

/**
 * One Wake Up alarm as the app hands it over (lib/data/notifications/
 * os_alarm_gateway.dart `_toChannel`), plus what happened to it here:
 * [state] and the snoozes so far. [fireAtMs] is the next ring, moved on
 * by each snooze.
 */
data class WakeUpAlarm(
    val id: String,
    val fireAtMs: Long,
    val sound: String,
    val title: String,
    val body: String,
    val stop: String,
    val snooze: String,
    val snoozeMin: Int,
    val snoozeLimit: Int,
    val rampSec: Int,
    val minimal: Boolean,
    val state: String = ARMED,
    val snoozes: Int = 0,
) {
    /** Snooze is offered: on, and under its limit (0 = no limit). */
    val canSnooze: Boolean get() = snoozeMin > 0 && (snoozeLimit == 0 || snoozes < snoozeLimit)

    fun toJson(): JSONObject = JSONObject()
        .put("id", id).put("fireAtMs", fireAtMs).put("sound", sound)
        .put("title", title).put("body", body).put("stop", stop).put("snooze", snooze)
        .put("snoozeMin", snoozeMin).put("snoozeLimit", snoozeLimit).put("rampSec", rampSec)
        .put("minimal", minimal).put("state", state).put("snoozes", snoozes)

    companion object {
        const val ARMED = "armed"
        const val RINGING = "ringing"
        const val SNOOZED = "snoozed"

        /** The test alarm (WakeUpAlarm.testId): `sync` never disarms it. */
        const val TEST_ID = "wakeup:test"

        fun fromMap(m: Map<*, *>): WakeUpAlarm = WakeUpAlarm(
            id = m["id"] as String,
            fireAtMs = (m["fireAtMs"] as Number).toLong(),
            sound = m["sound"] as String,
            title = m["title"] as String,
            body = m["body"] as String,
            stop = m["stop"] as String,
            snooze = m["snooze"] as String,
            snoozeMin = (m["snoozeMin"] as Number).toInt(),
            snoozeLimit = (m["snoozeLimit"] as Number).toInt(),
            rampSec = (m["rampSec"] as Number).toInt(),
            minimal = m["minimal"] == true,
        )

        fun fromJson(o: JSONObject): WakeUpAlarm = WakeUpAlarm(
            id = o.getString("id"),
            fireAtMs = o.getLong("fireAtMs"),
            sound = o.getString("sound"),
            title = o.getString("title"),
            body = o.getString("body"),
            stop = o.getString("stop"),
            snooze = o.getString("snooze"),
            snoozeMin = o.getInt("snoozeMin"),
            snoozeLimit = o.getInt("snoozeLimit"),
            rampSec = o.getInt("rampSec"),
            minimal = o.getBoolean("minimal"),
            state = o.getString("state"),
            snoozes = o.getInt("snoozes"),
        )
    }
}

/**
 * The armed Wake Up alarms (docs/15 W1b, ADR-0017): kept in this app's own
 * preferences so a reboot, or a ring with the app closed, finds them, and
 * scheduled with `setAlarmClock` (exact, the status-bar alarm icon, runs in
 * Doze). At most one alarm per day id is ever armed (15 §3).
 */
object WakeUpAlarms {
    private const val PREFS = "dottoday_wake_up"
    private const val KEY = "alarms"

    /**
     * Makes [incoming] the armed set and returns the instants armed. A
     * ringing or snoozed alarm, and the test alarm, stay as they are: only
     * "I'm up" or the 10-minute cap ends those. Without exact alarms nothing
     * is armed, so the app rings the Wake Up on the notification path.
     */
    fun sync(context: Context, incoming: List<WakeUpAlarm>): List<Long> {
        val stored = load(context)
        val (keep, armed) = stored.partition { it.state != WakeUpAlarm.ARMED || it.id == WakeUpAlarm.TEST_ID }
        val exact = exactAllowed(context)
        // An alarm armed exactly as wanted stays armed: no churn on each write.
        val unchanged = if (exact) armed.filter { it in incoming } else emptyList()
        (armed - unchanged.toSet()).forEach { alarms(context).cancel(ring(context, it.id)) }
        if (!exact) {
            save(context, keep)
            return emptyList()
        }
        val fresh = incoming.filter { a -> keep.none { it.id == a.id } && a !in unchanged }
        fresh.forEach { schedule(context, it) }
        save(context, keep + unchanged + fresh)
        return (unchanged + fresh).map { it.fireAtMs }
    }

    /** Arms [alarm] as the test alarm; false when exact alarms are off. */
    fun test(context: Context, alarm: WakeUpAlarm): Boolean {
        if (!exactAllowed(context)) return false
        val test = alarm.copy(id = WakeUpAlarm.TEST_ID)
        schedule(context, test)
        save(context, load(context).filter { it.id != test.id } + test)
        return true
    }

    /** Stops and forgets every alarm: the Wake Up switch went off. */
    fun disarmAll(context: Context) {
        load(context).forEach { alarms(context).cancel(ring(context, it.id)) }
        save(context, emptyList())
        context.getSystemService(android.app.NotificationManager::class.java)
            .cancel(WakeUpActions.SNOOZED_NOTE)
        WakeUpRingService.stop(context)
    }

    /** After a reboot or an update: arms again what is still ahead. */
    fun rearm(context: Context) {
        val now = System.currentTimeMillis()
        val ahead = load(context).filter { it.state != WakeUpAlarm.RINGING && it.fireAtMs > now }
        if (exactAllowed(context)) ahead.forEach { schedule(context, it) }
        save(context, ahead)
    }

    fun find(context: Context, id: String): WakeUpAlarm? = load(context).firstOrNull { it.id == id }

    fun all(context: Context): List<WakeUpAlarm> = load(context)

    /** Replaces the stored alarm with [alarm]'s id. */
    fun put(context: Context, alarm: WakeUpAlarm) {
        save(context, load(context).filter { it.id != alarm.id } + alarm)
    }

    fun remove(context: Context, id: String) {
        save(context, load(context).filter { it.id != id })
    }

    /** Forgets [id] and calls off its pending ring (a snooze's included). */
    fun disarm(context: Context, id: String) {
        alarms(context).cancel(ring(context, id))
        remove(context, id)
    }

    /** Arms [alarm] at its [WakeUpAlarm.fireAtMs] (a snooze re-arms through here). */
    fun schedule(context: Context, alarm: WakeUpAlarm) {
        val show = PendingIntent.getActivity(
            context, alarm.id.hashCode(),
            Intent(context, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        alarms(context).setAlarmClock(
            AlarmManager.AlarmClockInfo(alarm.fireAtMs, show),
            ring(context, alarm.id),
        )
    }

    private fun ring(context: Context, id: String): PendingIntent = PendingIntent.getBroadcast(
        context, id.hashCode(),
        Intent(context, WakeUpAlarmReceiver::class.java)
            .setAction(WakeUpAlarmReceiver.ACTION_RING)
            .putExtra(WakeUpAlarmReceiver.EXTRA_ID, id),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    private fun exactAllowed(context: Context): Boolean =
        android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.S ||
            alarms(context).canScheduleExactAlarms()

    private fun alarms(context: Context) = context.getSystemService(AlarmManager::class.java)

    private fun load(context: Context): List<WakeUpAlarm> {
        val raw = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null)
            ?: return emptyList()
        val array = runCatching { JSONArray(raw) }.getOrNull() ?: return emptyList()
        return (0 until array.length()).mapNotNull {
            runCatching { WakeUpAlarm.fromJson(array.getJSONObject(it)) }.getOrNull()
        }
    }

    private fun save(context: Context, alarms: List<WakeUpAlarm>) {
        val array = JSONArray().apply { alarms.forEach { put(it.toJson()) } }
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putString(KEY, array.toString()).apply()
    }
}
