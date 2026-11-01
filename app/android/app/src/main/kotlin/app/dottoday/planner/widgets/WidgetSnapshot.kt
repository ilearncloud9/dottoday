package app.dottoday.planner.widgets

import android.content.SharedPreferences
import org.json.JSONObject

/**
 * The display snapshot the app writes after every change (docs/09 M5.4,
 * lib/data/widgets/widget_display.dart): strings already localised and
 * formatted, colours resolved. The widgets only lay it out.
 */
data class WidgetBlock(
    val id: String,
    val title: String,
    val startMs: Long,
    val endMs: Long,
    val time: String,
    val until: String,
    val color: Int,
    val done: Boolean,
)

data class WidgetSnapshot(
    val blocks: List<WidgetBlock>,
    val inboxCount: Int,
    val labels: Map<String, String>,
    /** Today's Wake Up and Wind Down, and where the day ends on the day
     *  dot's ring (docs/15 W6; 1 = no night), from the app's snapshot. */
    val wakeMs: Long = 0,
    val bedMs: Long = 0,
    val nightStart: Double = 1.0,
) {
    /** Ring shares at [now]: the day ends at `first`, `second` of it filled. */
    fun dayDot(now: Long): Pair<Double, Double> {
        if (bedMs <= wakeMs) return nightStart to 0.0
        val share = ((now - wakeMs).toDouble() / (bedMs - wakeMs)).coerceIn(0.0, 1.0)
        return nightStart to share * nightStart
    }

    fun label(key: String) = labels[key] ?: ""

    /** The task under way at [nowMs], if any. */
    fun live(nowMs: Long) = blocks.firstOrNull { !it.done && it.startMs <= nowMs && nowMs < it.endMs }

    /** The next task that hasn't started at [nowMs]. */
    fun next(nowMs: Long) = blocks.firstOrNull { !it.done && it.startMs > nowMs }

    /** What is left of the next 24 h at [nowMs], earliest first. */
    fun ahead(nowMs: Long) = blocks.filter { it.endMs > nowMs }

    companion object {
        const val KEY = "snapshot"
        val EMPTY = WidgetSnapshot(emptyList(), 0, emptyMap())

        fun read(prefs: SharedPreferences): WidgetSnapshot =
            prefs.getString(KEY, null)?.let(::parse) ?: EMPTY

        fun parse(raw: String): WidgetSnapshot? = try {
            val json = JSONObject(raw)
            if (json.optInt("v") != 1) null else {
                val labels = json.getJSONObject("labels")
                val blocks = json.getJSONArray("blocks")
                WidgetSnapshot(
                    blocks = (0 until blocks.length()).map { i ->
                        val b = blocks.getJSONObject(i)
                        WidgetBlock(
                            id = b.getString("id"),
                            title = b.getString("title"),
                            startMs = b.getLong("start_ms"),
                            endMs = b.getLong("end_ms"),
                            time = b.getString("time"),
                            until = b.getString("until"),
                            color = android.graphics.Color.parseColor(b.getString("color")),
                            done = b.getBoolean("done"),
                        )
                    },
                    inboxCount = json.getInt("inbox_count"),
                    labels = labels.keys().asSequence().associateWith { labels.getString(it) },
                    wakeMs = json.optLong("wake_ms"),
                    bedMs = json.optLong("bed_ms"),
                    nightStart = json.optDouble("night_start", 1.0).coerceIn(0.0, 1.0),
                )
            }
        } catch (e: Exception) {
            // A snapshot from a newer or broken app: show the empty state.
            null
        }
    }
}
