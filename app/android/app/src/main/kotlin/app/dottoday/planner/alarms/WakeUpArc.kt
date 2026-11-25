package app.dottoday.planner.alarms

import org.json.JSONObject

/**
 * One of the day's dots on the ringing screen's day dot (E-R2-19-B, ED-314):
 * [from] and [to] are shares of the 24 hours from Wake Up, clockwise from
 * the top; [light] and [dark] are its colour in each theme (ARGB), as the
 * app's palette resolves it (lib/data/notifications/os_alarm_gateway.dart).
 */
data class WakeUpArc(val from: Float, val to: Float, val light: Int, val dark: Int) {
    fun toJson(): JSONObject = JSONObject()
        .put("from", from.toDouble()).put("to", to.toDouble()).put("light", light).put("dark", dark)

    companion object {
        fun fromMap(m: Map<*, *>) = WakeUpArc(
            from = (m["from"] as Number).toFloat(),
            to = (m["to"] as Number).toFloat(),
            light = (m["light"] as Number).toLong().toInt(),
            dark = (m["dark"] as Number).toLong().toInt(),
        )

        fun fromJson(o: JSONObject) = WakeUpArc(
            from = o.getDouble("from").toFloat(),
            to = o.getDouble("to").toFloat(),
            light = o.getInt("light"),
            dark = o.getInt("dark"),
        )
    }
}
