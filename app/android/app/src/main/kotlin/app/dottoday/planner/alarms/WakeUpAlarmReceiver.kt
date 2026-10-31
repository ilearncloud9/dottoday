package app.dottoday.planner.alarms

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * A Wake Up alarm's time came ([ACTION_RING]): the ringing service takes
 * over, in the foreground (docs/15 W1b). The notification's Snooze and
 * "I'm up" land here too ([WakeUpActions]). After a reboot or an app update,
 * the alarms still ahead are armed again: `setAlarmClock` alarms don't
 * survive a reboot.
 */
class WakeUpAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_RING -> intent.getStringExtra(EXTRA_ID)?.let { WakeUpRingService.ring(context, it) }
            WakeUpActions.SNOOZE -> intent.getStringExtra(EXTRA_ID)?.let { WakeUpActions.snooze(context, it) }
            WakeUpActions.STOP -> intent.getStringExtra(EXTRA_ID)?.let { WakeUpActions.dismiss(context, it) }
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED -> WakeUpAlarms.rearm(context)
        }
    }

    companion object {
        const val ACTION_RING = "app.dottoday.planner.WAKE_UP_RING"
        const val EXTRA_ID = "id"
    }
}
