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
    /** Today's one thing (docs/15 §8): ringed, with the "one_thing" label. */
    val oneThing: Boolean = false,
    /** Dark mode's step of the task colour (E-R2-17-Dark). */
    val colorDark: Int = color,
)

/** The App colour in one appearance (lib/data/widgets/app_colour_tones.dart). */
data class AppTone(val dot: Int, val text: Int, val fill: Int, val on: Int)

/** The App colour, light and dark; teal (the default) before the app writes it. */
data class AppAccent(val light: AppTone, val dark: AppTone) {
    fun tone(dark: Boolean) = if (dark) this.dark else light

    companion object {
        val TEAL = AppAccent(
            AppTone(0xFF11615C.toInt(), 0xFF11615C.toInt(), 0xFF11615C.toInt(), 0xFFFFFFFF.toInt()),
            AppTone(0xFF5BC4B8.toInt(), 0xFF5BC4B8.toInt(), 0xFF5BC4B8.toInt(), 0xFF0C2523.toInt()),
        )

        /** `{light: {dot, text, fill, on}, dark: …}`, or teal. */
        fun parse(json: JSONObject?): AppAccent {
            if (json == null) return TEAL
            fun tone(o: JSONObject?, fallback: AppTone): AppTone {
                if (o == null) return fallback
                fun c(key: String, f: Int) = o.optString(key).takeIf { it.isNotEmpty() }
                    ?.let { runCatching { android.graphics.Color.parseColor(it) }.getOrNull() } ?: f
                return AppTone(c("dot", fallback.dot), c("text", fallback.text), c("fill", fallback.fill), c("on", fallback.on))
            }
            return AppAccent(tone(json.optJSONObject("light"), TEAL.light), tone(json.optJSONObject("dark"), TEAL.dark))
        }
    }
}

data class WidgetSnapshot(
    val blocks: List<WidgetBlock>,
    val inboxCount: Int,
    val labels: Map<String, String>,
    /** Today's Wake Up and Wind Down, and where the day ends on the day
     *  dot's ring (docs/15 W6; 1 = no night), from the app's snapshot. */
    val wakeMs: Long = 0,
    val bedMs: Long = 0,
    val nightStart: Double = 1.0,
    val accent: AppAccent = AppAccent.TEAL,
    /** Today's done and planned dots, Wake Up to Wind Down (past ones too). */
    val dayDone: Int = 0,
    val dayTotal: Int = 0,
    /** "{done} of {total} done" in the app's language. */
    val doneOfPattern: String = "",
) {
    /** Today's "3 of 10 done" (E-R2-17); empty when nothing is planned. */
    fun doneOf(): String = if (dayTotal <= 0 || doneOfPattern.isEmpty()) "" else
        doneOfPattern.replace("{done}", "$dayDone").replace("{total}", "$dayTotal")

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
                            oneThing = b.optBoolean("one_thing"),
                            colorDark = b.optString("color_dark").takeIf { it.isNotEmpty() }
                                ?.let { android.graphics.Color.parseColor(it) }
                                ?: android.graphics.Color.parseColor(b.getString("color")),
                        )
                    },
                    inboxCount = json.getInt("inbox_count"),
                    labels = labels.keys().asSequence().associateWith { labels.getString(it) },
                    wakeMs = json.optLong("wake_ms"),
                    bedMs = json.optLong("bed_ms"),
                    nightStart = json.optDouble("night_start", 1.0).coerceIn(0.0, 1.0),
                    accent = AppAccent.parse(json.optJSONObject("accent")),
                    dayDone = json.optInt("day_done"),
                    dayTotal = json.optInt("day_total"),
                    doneOfPattern = json.optJSONObject("format")?.optString("done_of").orEmpty(),
                )
            }
        } catch (e: Exception) {
            // A snapshot from a newer or broken app: show the empty state.
            null
        }
    }
}
