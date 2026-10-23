package com.yourcompany.dottoday.alarms

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.workDataOf
import dev.fluttercommunity.workmanager.BackgroundWorker

/**
 * Re-arms reminders when the clock or time zone changes while Dottoday
 * isn't open (docs/09 M6.5.5, 11 A0): runs the same Dart refresh as the
 * daily background job (`backgroundRefreshDispatcher`, ADR-0008), which
 * re-plans every pending notification. Boot is handled by
 * flutter_local_notifications' own receiver.
 */
class TimeChangeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action !in ACTIONS) return
        val request = OneTimeWorkRequestBuilder<BackgroundWorker>()
            .setInputData(workDataOf(BackgroundWorker.DART_TASK_KEY to TASK))
            .build()
        WorkManager.getInstance(context)
            .enqueueUniqueWork(TASK, ExistingWorkPolicy.REPLACE, request)
    }

    companion object {
        /** The Dart task name (background_refresh.dart `rearmTask`). */
        const val TASK = "dottoday.rearm"
        private val ACTIONS = setOf(
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_TIME_CHANGED,
        )
    }
}
