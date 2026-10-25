package app.dottoday.planner.intents

import java.security.SecureRandom
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale

/**
 * The B6 action queue and the optimistic snapshot patch on Android
 * (docs/09 M9.2c), on plain maps so the rules stay the same as
 * `ios/Shared/SnapshotPatch.swift` and `lib/domain/intents/dot_intents.dart`.
 * JSON in and out lives in [DotActionReceiver].
 */
enum class DotActionKind(val wire: String) {
    ADD_TASK("add_task"),
    MARK_DONE("mark_done"),
    ADD_FIFTEEN("add_fifteen"),
    START_FOCUS("start_focus"),
}

object DotQueue {
    /** The `home_widget` prefs key the app drains (action_queue_json.dart). */
    const val KEY = "action_queue"
    const val SNAPSHOT_KEY = "snapshot"

    private val random = SecureRandom()

    /** One queue entry; ids are lowercase UUID v7 (the app requires UUIDs). */
    fun entry(
        kind: DotActionKind,
        nowMs: Long,
        occurrenceId: String? = null,
        plannedEndMs: Long? = null,
        text: String? = null,
        id: String = uuidV7(nowMs),
    ): Map<String, Any> = buildMap {
        put("id", id)
        put("at_ms", nowMs)
        put("kind", kind.wire)
        occurrenceId?.let { put("occurrence_id", it.lowercase()) }
        plannedEndMs?.let { put("planned_end_ms", it) }
        text?.let { put("text", it) }
    }

    /** RFC 9562 UUID v7: 48-bit Unix ms, version 7, variant 10, random rest. */
    fun uuidV7(nowMs: Long, bytes: ByteArray = ByteArray(16).also(random::nextBytes)): String {
        for (i in 0 until 6) bytes[i] = (nowMs ushr (8 * (5 - i))).toByte()
        bytes[6] = ((bytes[6].toInt() and 0x0F) or 0x70).toByte()
        bytes[8] = ((bytes[8].toInt() and 0x3F) or 0x80).toByte()
        val hex = bytes.joinToString("") { "%02x".format(it) }
        return listOf(0..7, 8..11, 12..15, 16..19, 20..31).joinToString("-") { hex.substring(it) }
    }

    /**
     * [snapshot] with [kind] applied to the dot [occurrenceId] at [nowMs]:
     * Done ticks it, Start records the first start, +15 moves its end and
     * rewrites "until …" from the snapshot's `format`. Unchanged when the
     * dot isn't in it or the action is already so.
     */
    @Suppress("UNCHECKED_CAST")
    fun patch(snapshot: Map<String, Any?>, kind: DotActionKind, occurrenceId: String, nowMs: Long): Map<String, Any?> {
        val blocks = snapshot["blocks"] as? List<Map<String, Any?>> ?: return snapshot
        val i = blocks.indexOfFirst { (it["id"] as? String)?.lowercase() == occurrenceId.lowercase() }
        if (i < 0) return snapshot
        val block = blocks[i].toMutableMap()
        val done = block["done"] == true
        when (kind) {
            DotActionKind.MARK_DONE -> {
                if (done) return snapshot
                block["done"] = true
                block["actual_end_ms"] = nowMs
            }
            DotActionKind.START_FOCUS -> {
                if (done || block["actual_start_ms"] != null) return snapshot
                block["actual_start_ms"] = nowMs
            }
            DotActionKind.ADD_FIFTEEN -> {
                val end = (block["end_ms"] as? Number)?.toLong() ?: return snapshot
                block["end_ms"] = end + FIFTEEN_MS
                block["duration_min"] = ((block["duration_min"] as? Number)?.toInt() ?: 0) + 15
                untilText(end + FIFTEEN_MS, snapshot["format"] as? Map<String, Any?>)?.let { block["until"] = it }
            }
            DotActionKind.ADD_TASK -> return snapshot
        }
        return snapshot.toMutableMap().apply { put("blocks", blocks.toMutableList().also { it[i] = block }) }
    }

    /** "until 10:45" in the app's zone, language and clock. */
    fun untilText(endMs: Long, format: Map<String, Any?>?): String? {
        val pattern = format?.get("until") as? String ?: return null
        val zone = runCatching { ZoneId.of(format["tz"] as? String) }.getOrNull() ?: return null
        val locale = Locale.forLanguageTag(format["locale"] as? String ?: "en")
        val clock = if (format["hour24"] == true) "HH:mm" else "h:mm a"
        val time = DateTimeFormatter.ofPattern(clock, locale).format(Instant.ofEpochMilli(endMs).atZone(zone))
        return pattern.replace("{time}", time)
    }

    private const val FIFTEEN_MS = 15 * 60_000L
}
