package app.dottoday.planner.alarms

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * `dottoday/alarm` (lib/data/notifications/os_alarm_gateway.dart, docs/15
 * W1, ADR-0017): arms and disarms the Wake Up alarms ([WakeUpAlarms]) and
 * says whether Dottoday may still take over the lock screen. From Android
 * 14 the user, or Play at install, can revoke USE_FULL_SCREEN_INTENT; the
 * alarm then rings as a heads-up notification, and Settings and
 * Notification health say so and open the page where it is allowed again.
 * Before 14 it can't be revoked.
 */
object AlarmBridge {
    fun attach(context: Context, messenger: BinaryMessenger) {
        MethodChannel(messenger, "dottoday/alarm").setMethodCallHandler { call, result ->
            when (call.method) {
                "canUseFullScreenIntent" -> result.success(allowed(context))
                "openFullScreenIntentSettings" -> {
                    open(context)
                    result.success(null)
                }
                "sync" -> {
                    val args = call.arguments as? Map<*, *>
                    val alarms = (args?.get("alarms") as? List<*>).orEmpty()
                        .mapNotNull { (it as? Map<*, *>)?.let(WakeUpAlarm::fromMap) }
                    // The day began: its Wake Up Check is called off (15 W3).
                    WakeUpChecks.cancel(context, (args?.get("started") as? List<*>).orEmpty().filterIsInstance<String>())
                    result.success(WakeUpAlarms.sync(context, alarms))
                }
                "test" -> {
                    val alarm = (call.arguments as? Map<*, *>)?.let(WakeUpAlarm::fromMap)
                    result.success(alarm != null && WakeUpAlarms.test(context, alarm))
                }
                "disarmAll" -> {
                    WakeUpAlarms.disarmAll(context)
                    result.success(null)
                }
                "drainEvents" -> result.success(WakeUpAlarms.drainEvents(context))
                // The device test (integration_test/wake_up_alarm_test.dart):
                // what rings, what is stored, and the ringing screen's buttons.
                "ringingId" -> result.success(WakeUpRingService.instance?.ringingId)
                "checkArmed" -> result.success(WakeUpChecks.armed(context, call.argument<String>("id").orEmpty()))
                "stored" -> result.success(
                    WakeUpAlarms.all(context).map { mapOf("id" to it.id, "state" to it.state, "snoozes" to it.snoozes) },
                )
                "perform" -> {
                    val id = call.argument<String>("id").orEmpty()
                    if (call.argument<String>("action") == "snooze") {
                        WakeUpActions.snooze(context, id)
                    } else {
                        WakeUpActions.dismiss(context, id)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun allowed(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) return true
        val notes = context.getSystemService(NotificationManager::class.java)
        return notes.canUseFullScreenIntent()
    }

    /** The app's own "full-screen notifications" page on 14+, else its notification settings. */
    private fun open(context: Context) {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            Intent(
                Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT,
                Uri.parse("package:${context.packageName}"),
            )
        } else {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
        }
        context.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
    }
}
