package app.dottoday.planner.intents

import org.json.JSONArray
import org.json.JSONObject
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

    /**
     * Whom new entries are stamped with, as the app publishes it
     * (lib/domain/intents/action_queue_store.dart `encodeQueueOwner`).
     */
    const val OWNER_KEY = "action_queue_owner"

    /**
     * Most entries the queue holds (lib/domain/intents/action_queue_store.dart
     * `queueCapacity`) and the most bytes; past either a new entry is
     * refused, never an older one evicted (CR-160 I7 retention).
     */
    const val CAPACITY = 500
    const val MAX_BYTES = 1_000_000

    /**
     * Whether a new entry may join [queue] under [marker]: not while the app
     * refuses (an account being deleted) and not past [CAPACITY] or
     * [MAX_BYTES] with [entry] added. Call under `synchronized(DotQueue)`.
     */
    fun accepts(queue: JSONArray, marker: String?, entry: Map<String, Any>): Boolean {
        val m = marker?.let { runCatching { JSONObject(it) }.getOrNull() }
        if (m?.optBoolean("refuse", false) == true) return false
        if (queue.length() >= CAPACITY) return false
        return queue.toString().length + JsonMaps.fromValue(entry).toString().length < MAX_BYTES
    }

    /**
     * [entry] stamped with the owner the app published in [marker] (CR-160
     * I7): its id and guest session, or nothing while a change of owner is
     * under way or before the app published one; the app then keeps the
     * entry and never applies it. Call under `synchronized(DotQueue)`, the
     * lock the app's publish and remove take.
     */
    /**
     * Seals the words of every plaintext entry in [prefs]'s queue in place,
     * under the queue's lock, ids, times and owner stamps unchanged (CR-160
     * I1). All or nothing in one commit: if any entry can't be sealed the
     * queue is left exactly as it was, to try again next time; a crash
     * before the commit leaves it as it was, after it sealed. Idempotent.
     */
    fun sealPlaintext(prefs: android.content.SharedPreferences) = synchronized(DotQueue) {
        val queue = parse(prefs.getString(KEY, null)) ?: return@synchronized
        var changed = false
        val out = JSONArray()
        for (i in 0 until queue.length()) {
            val entry = queue.optJSONObject(i)
            if (entry == null || !QueueCipher.hasPlainText(entry)) {
                out.put(queue.get(i))
                continue
            }
            out.put(QueueCipher.seal(entry) ?: return@synchronized)
            changed = true
        }
        if (changed) prefs.edit().putString(KEY, out.toString()).commit()
    }

    /**
     * The queue as the app reads it: sealed words opened, or the entry
     * marked unreadable (kept, never applied). The stored queue stays
     * sealed. Under the queue's lock.
     */
    fun readOpened(prefs: android.content.SharedPreferences): String? = synchronized(DotQueue) {
        val raw = prefs.getString(KEY, null) ?: return@synchronized null
        val queue = parse(raw) ?: return@synchronized raw
        val out = JSONArray()
        for (i in 0 until queue.length()) {
            val entry = queue.optJSONObject(i)
            out.put(if (entry == null) queue.get(i) else QueueCipher.open(entry))
        }
        out.toString()
    }

    /**
     * The queue in [raw]; an empty one when there is none, null when it
     * can't be read (then nothing is appended over it: an unreadable queue
     * is never replaced, CR-160 I7).
     */
    fun parse(raw: String?): JSONArray? =
        if (raw == null) JSONArray() else runCatching { JSONArray(raw) }.getOrNull()

    fun stamp(entry: Map<String, Any>, marker: String?): Map<String, Any> {
        val m = marker?.let { runCatching { JSONObject(it) }.getOrNull() } ?: return entry
        if (m.optBoolean("switching", false) || m.optBoolean("refuse", false)) return entry
        val owner = m.optString("owner", "").takeIf { it.isNotEmpty() } ?: return entry
        return entry.toMutableMap().apply {
            put("owner", owner)
            m.optString("guest_session", "").takeIf { it.isNotEmpty() }?.let { put("guest_session", it) }
        }
    }

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

    /**
     * The ongoing notification's content after +15 on it: end and timeout
     * move, the range is written again on the app's clock.
     */
    @Suppress("UNCHECKED_CAST")
    fun plusFifteenContent(content: Map<String, Any?>): Map<String, Any?> {
        val start = (content["start_ms"] as? Number)?.toLong() ?: return content
        val end = ((content["end_ms"] as? Number)?.toLong() ?: return content) + FIFTEEN_MS
        val out = content.toMutableMap()
        out["end_ms"] = end
        out["ends_ms"] = ((content["ends_ms"] as? Number)?.toLong() ?: end) + FIFTEEN_MS
        val format = content["format"] as? Map<String, Any?>
        val pattern = content["range_pattern"] as? String
        val a = clockText(start, format)
        val b = clockText(end, format)
        if (pattern != null && a != null && b != null) {
            out["range"] = pattern.replace("{start}", a).replace("{end}", b)
        }
        return out
    }

    /** "10:45" in the app's zone, language and clock. */
    fun clockText(ms: Long, format: Map<String, Any?>?): String? {
        format ?: return null
        val zone = runCatching { ZoneId.of(format["tz"] as? String) }.getOrNull() ?: return null
        val locale = Locale.forLanguageTag(format["locale"] as? String ?: "en")
        val clock = if (format["hour24"] == true) "HH:mm" else "h:mm a"
        return DateTimeFormatter.ofPattern(clock, locale).format(Instant.ofEpochMilli(ms).atZone(zone))
    }

    /** "until 10:45" in the app's zone, language and clock. */
    fun untilText(endMs: Long, format: Map<String, Any?>?): String? {
        val pattern = format?.get("until") as? String ?: return null
        return clockText(endMs, format)?.let { pattern.replace("{time}", it) }
    }

    private const val FIFTEEN_MS = 15 * 60_000L
}
