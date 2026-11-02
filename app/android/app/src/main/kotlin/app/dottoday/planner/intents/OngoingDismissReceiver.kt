package app.dottoday.planner.intents

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * The ongoing notification's delete intent (docs/14 §5, R-13): the user
 * swiped the live dot away, which [OngoingDot.recordDismissed] keeps for
 * the app's widget hint. Not exported: only this app's PendingIntent
 * reaches it.
 */
class OngoingDismissReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        OngoingDot.recordDismissed(context, System.currentTimeMillis())
    }

    companion object {
        fun pendingIntent(context: Context): PendingIntent = PendingIntent.getBroadcast(
            context,
            OngoingDot.ID,
            Intent(context, OngoingDismissReceiver::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
