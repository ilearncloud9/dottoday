package app.dottoday.planner.focus

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Deep work on Android (docs/09 M10.5, 11 A3): Do Not Disturb at the
 * alarms-only level while a dot is in Focus, turned off at its planned end
 * by [DeepWorkOff] or when Focus ends. Only ever alarms-only — never total
 * silence — so the dot-start alarm channel still rings. Never touches a
 * Do Not Disturb the user set themselves, and only turns off what it
 * turned on. Needs notification-policy access, which the user grants in
 * Settings (`openAccess`).
 */
object DeepWork {
    private const val PREFS = "dottoday_deep_work"
    private const val OURS = "ours"

    fun attach(context: Context, messenger: BinaryMessenger) {
        MethodChannel(messenger, "dottoday/deep_work").setMethodCallHandler { call, result ->
            when (call.method) {
                "status" -> result.success(
                    mapOf("granted" to granted(context), "on" to isOn(context)),
                )
                "turnOn" -> {
                    // The one level Dart may ask for (deep_work.dart).
                    if (call.argument<String>("level") != "alarms") {
                        return@setMethodCallHandler result.error("bad_level", null, null)
                    }
                    val until = call.argument<Number>("until_ms")?.toLong() ?: 0L
                    result.success(turnOn(context, until))
                }
                "turnOff" -> {
                    turnOff(context)
                    result.success(null)
                }
                "openAccess" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun notes(context: Context) =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    private fun granted(context: Context) = notes(context).isNotificationPolicyAccessGranted

    private fun ours(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean(OURS, false)

    private fun setOurs(context: Context, value: Boolean) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putBoolean(OURS, value).apply()

    private fun isOn(context: Context) = ours(context) &&
        notes(context).currentInterruptionFilter == NotificationManager.INTERRUPTION_FILTER_ALARMS

    private fun turnOn(context: Context, untilMs: Long): Boolean {
        if (!granted(context)) return false
        val nm = notes(context)
        // The user's own Do Not Disturb stays theirs.
        if (nm.currentInterruptionFilter != NotificationManager.INTERRUPTION_FILTER_ALL && !ours(context)) {
            return true
        }
        nm.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALARMS)
        setOurs(context, true)
        val alarms = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarms.cancel(offIntent(context))
        // Inexact is fine: a few minutes late, never early.
        alarms.set(AlarmManager.RTC, untilMs, offIntent(context))
        return true
    }

    fun turnOff(context: Context) {
        val alarms = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarms.cancel(offIntent(context))
        if (!ours(context)) return
        setOurs(context, false)
        val nm = notes(context)
        if (granted(context) &&
            nm.currentInterruptionFilter == NotificationManager.INTERRUPTION_FILTER_ALARMS
        ) {
            nm.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)
        }
    }

    private fun offIntent(context: Context): PendingIntent = PendingIntent.getBroadcast(
        context,
        3336,
        Intent(context, DeepWorkOff::class.java),
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
    )
}

/** The dot's planned end: deep work's Do Not Disturb goes off. */
class DeepWorkOff : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) = DeepWork.turnOff(context)
}
