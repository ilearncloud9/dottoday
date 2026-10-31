package app.dottoday.planner.system

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.database.ContentObserver
import android.os.Handler
import android.os.Looper
import android.provider.CalendarContract
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * What the OS announces while the app runs, on `dottoday/system_events`
 * (lib/data/system/system_events.dart, docs/04 §4 "Triggers"), so Dart acts on the
 * event instead of checking on a timer: `clock` when the time, date or
 * zone changes, `calendar` when the device's calendars change. Closed,
 * the app relies on [app.dottoday.planner.alarms.TimeChangeReceiver] and
 * the next start instead.
 */
object SystemEvents {
    @Volatile private var channel: MethodChannel? = null
    private var context: Context? = null
    private var clock: BroadcastReceiver? = null
    private var calendar: ContentObserver? = null

    fun attach(context: Context, messenger: BinaryMessenger) {
        detach()
        val app = context.applicationContext
        this.context = app
        channel = MethodChannel(messenger, "dottoday/system_events")
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) = send("clock")
        }
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_TIME_CHANGED)
            addAction(Intent.ACTION_TIMEZONE_CHANGED)
            addAction(Intent.ACTION_DATE_CHANGED)
        }
        // System broadcasts still reach a receiver that isn't exported.
        ContextCompat.registerReceiver(app, receiver, filter, ContextCompat.RECEIVER_NOT_EXPORTED)
        clock = receiver
        watchCalendars()
    }

    /**
     * Starts following the calendars once READ_CALENDAR is granted; called
     * on attach and on every resume, since the grant happens in a system
     * dialog or Settings while the app is paused.
     */
    fun watchCalendars() {
        val app = context ?: return
        if (calendar != null) return
        val granted = ContextCompat.checkSelfPermission(app, Manifest.permission.READ_CALENDAR) ==
            PackageManager.PERMISSION_GRANTED
        if (!granted) return
        val observer = object : ContentObserver(Handler(Looper.getMainLooper())) {
            override fun onChange(selfChange: Boolean) = send("calendar")
        }
        app.contentResolver.registerContentObserver(CalendarContract.CONTENT_URI, true, observer)
        calendar = observer
    }

    fun detach() {
        val app = context ?: return
        clock?.let { app.unregisterReceiver(it) }
        calendar?.let { app.contentResolver.unregisterContentObserver(it) }
        clock = null
        calendar = null
        channel = null
        context = null
    }

    private fun send(event: String) {
        Handler(Looper.getMainLooper()).post { channel?.invokeMethod(event, null) }
    }
}
