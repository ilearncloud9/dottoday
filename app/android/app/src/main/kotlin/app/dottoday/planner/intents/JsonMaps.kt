package app.dottoday.planner.intents

import org.json.JSONArray
import org.json.JSONObject

/** org.json ⇄ plain maps and lists, for [DotQueue]'s map-based rules. */
internal object JsonMaps {
    fun toMap(json: JSONObject): Map<String, Any?> =
        json.keys().asSequence().associateWith { toValue(json.opt(it)) }

    fun toList(json: JSONArray): List<Any?> = (0 until json.length()).map { toValue(json.opt(it)) }

    fun fromValue(value: Any?): Any? = when (value) {
        null -> JSONObject.NULL
        is Map<*, *> -> JSONObject().also { o -> value.forEach { (k, v) -> o.put(k as String, fromValue(v)) } }
        is List<*> -> JSONArray().also { a -> value.forEach { a.put(fromValue(it)) } }
        else -> value
    }

    private fun toValue(value: Any?): Any? = when (value) {
        JSONObject.NULL, null -> null
        is JSONObject -> toMap(value)
        is JSONArray -> toList(value)
        else -> value
    }
}
