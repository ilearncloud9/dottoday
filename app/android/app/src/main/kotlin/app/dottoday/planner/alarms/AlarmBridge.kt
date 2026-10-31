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
 * Whether Dottoday may still take over the lock screen for an alarm
 * (docs/15 §2, W1a). From Android 14 the user, or Play at install, can
 * revoke USE_FULL_SCREEN_INTENT; the alarm then posts as a heads-up
 * notification, and Settings and Notification health say so and open
 * the page where it is allowed again. Before 14 it can't be revoked.
 */
object FullScreenIntentBridge {
    fun attach(context: Context, messenger: BinaryMessenger) {
        MethodChannel(messenger, "dottoday/alarm").setMethodCallHandler { call, result ->
            when (call.method) {
                "canUseFullScreenIntent" -> result.success(allowed(context))
                "openFullScreenIntentSettings" -> {
                    open(context)
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
