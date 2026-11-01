package app.dottoday.planner.calendar

import android.Manifest
import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.content.pm.PackageManager
import android.provider.CalendarContract.Calendars
import android.provider.CalendarContract.Events
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * `dottoday/calendar_series` (lib/data/calendar/calendar_series_channel.dart,
 * docs/02 F5.7): a scope-All edit or delete of a repeating event, on its
 * `Events` row — the whole series, as the Calendar app's "All events"
 * does. device_calendar would rebuild the RRULE from its own model when it
 * saves, so only DTSTART (moved by `shiftMs`, its date kept), DURATION and
 * TITLE are written here; the rule, zone, exceptions and invitees stay as
 * they are. Titles are never logged (CLAUDE.md §4).
 */
object CalendarSeries {
    private var channel: MethodChannel? = null

    fun attach(context: Context, messenger: BinaryMessenger) {
        val app = context.applicationContext
        channel = MethodChannel(messenger, "dottoday/calendar_series").apply {
            setMethodCallHandler { call, result ->
                val args = call.arguments as? Map<*, *>
                try {
                    when (call.method) {
                        "update" -> result.success(update(app, args))
                        "delete" -> result.success(delete(app, args))
                        else -> result.notImplemented()
                    }
                } catch (e: SecurityException) {
                    result.error("denied", null, null)
                } catch (e: IllegalArgumentException) {
                    result.error("bad_args", null, null)
                }
            }
        }
    }

    /** "written" / "gone" / "notWritable", as Dart's `EventWriteResult`. */
    private fun update(context: Context, args: Map<*, *>?): String {
        val shift = (args?.get("shiftMs") as? Number)?.toLong()
            ?: throw IllegalArgumentException()
        val row = find(context, args) ?: return "gone"
        if (!row.writable) return "notWritable"
        val values = ContentValues().apply {
            put(Events.DTSTART, row.start + shift)
            (args["durationMs"] as? Number)?.let {
                put(Events.DURATION, "P${it.toLong() / 1000}S")
            }
            (args["title"] as? String)?.let { put(Events.TITLE, it) }
        }
        val uri = ContentUris.withAppendedId(Events.CONTENT_URI, row.id)
        return if (context.contentResolver.update(uri, values, null, null) > 0) "written" else "gone"
    }

    private fun delete(context: Context, args: Map<*, *>?): String {
        val row = find(context, args) ?: return "gone"
        if (!row.writable) return "notWritable"
        val uri = ContentUris.withAppendedId(Events.CONTENT_URI, row.id)
        return if (context.contentResolver.delete(uri, null, null) > 0) "written" else "gone"
    }

    private class Row(val id: Long, val start: Long, val writable: Boolean)

    /**
     * The series' row in its calendar, or null when gone. Writable only
     * when it repeats, is timed, its calendar takes changes and this
     * device's account organises it.
     */
    private fun find(context: Context, args: Map<*, *>?): Row? {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.WRITE_CALENDAR) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            throw SecurityException()
        }
        val calendarId = (args?.get("calendarId") as? String)?.toLongOrNull()
            ?: throw IllegalArgumentException()
        // Numeric ids only, as CalendarContract hands out (06 §7).
        val eventId = (args["eventId"] as? String)?.toLongOrNull()
            ?: throw IllegalArgumentException()
        val projection = arrayOf(
            Events.DTSTART,
            Events.RRULE,
            Events.ALL_DAY,
            Events.IS_ORGANIZER,
            Events.CALENDAR_ACCESS_LEVEL,
        )
        context.contentResolver.query(
            ContentUris.withAppendedId(Events.CONTENT_URI, eventId),
            projection,
            "${Events.CALENDAR_ID} = ? AND ${Events.DELETED} = 0",
            arrayOf(calendarId.toString()),
            null,
        )?.use { c ->
            if (!c.moveToFirst()) return null
            val repeats = !c.isNull(1) && c.getString(1).isNotEmpty()
            val timed = c.getInt(2) == 0
            // Null on older providers: the account owns its own events.
            val organizer = c.isNull(3) || c.getString(3) != "0"
            val access = c.getInt(4) >= Calendars.CAL_ACCESS_CONTRIBUTOR
            return Row(eventId, c.getLong(0), repeats && timed && organizer && access)
        }
        return null
    }
}
