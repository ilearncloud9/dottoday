package app.dottoday.planner.alarms

import android.Manifest
import android.app.Activity
import android.app.UiModeManager
import android.content.Context
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.math.sqrt

/**
 * The missions' sensors (docs/15 §8; owner, 2026-11-01: an in-house
 * bridge, no plugin), for lib/data/wake_up/channel_mission_sensors.dart.
 * `dottoday/mission` answers whether a sensor is there and allowed, asks
 * for Walk's permission, and says whether Android Auto is on;
 * `dottoday/mission/readings` streams one sensor while the mission screen
 * listens. Raw values only: every threshold is in Dart. Nothing is kept.
 *
 * - steps: the step counter's delta since listening began
 *   (ACTIVITY_RECOGNITION on API 29+).
 * - light: ambient light in lux.
 * - motion: gravity along the long axis and user acceleration, in g.
 */
object MissionSensors {
    private const val REQUEST_CODE = 0x4d495353 // "MISS"
    private var pending: ((Boolean) -> Unit)? = null

    fun attach(activity: Activity, messenger: BinaryMessenger) {
        MethodChannel(messenger, "dottoday/mission").setMethodCallHandler { call, result ->
            val kind = call.argument<String>("kind").orEmpty()
            when (call.method) {
                "support" -> result.success(support(activity, kind))
                "request" -> request(activity, kind) { result.success(it) }
                "driving" -> result.success(driving(activity))
                else -> result.notImplemented()
            }
        }
        EventChannel(messenger, "dottoday/mission/readings").setStreamHandler(Readings(activity))
    }

    /** From MainActivity.onRequestPermissionsResult. */
    fun onPermissionResult(requestCode: Int, granted: Boolean) {
        if (requestCode != REQUEST_CODE) return
        pending?.invoke(granted)
        pending = null
    }

    private fun sensorType(kind: String) = when (kind) {
        "steps" -> Sensor.TYPE_STEP_COUNTER
        "light" -> Sensor.TYPE_LIGHT
        else -> Sensor.TYPE_GRAVITY
    }

    private fun support(context: Context, kind: String): String {
        val sensors = context.getSystemService(SensorManager::class.java)
        if (sensors.getDefaultSensor(sensorType(kind)) == null) return "missing"
        if (kind == "motion" && sensors.getDefaultSensor(Sensor.TYPE_LINEAR_ACCELERATION) == null) {
            return "missing"
        }
        if (kind != "steps" || allowed(context)) return "ready"
        val asked = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean(ASKED, false)
        return if (asked) "denied" else "needsPermission"
    }

    private fun allowed(context: Context) = Build.VERSION.SDK_INT < Build.VERSION_CODES.Q ||
        ContextCompat.checkSelfPermission(context, Manifest.permission.ACTIVITY_RECOGNITION) ==
        PackageManager.PERMISSION_GRANTED

    private fun request(activity: Activity, kind: String, done: (Boolean) -> Unit) {
        if (kind != "steps" || allowed(activity)) return done(support(activity, kind) == "ready")
        activity.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putBoolean(ASKED, true).apply()
        pending = done
        ActivityCompat.requestPermissions(
            activity,
            arrayOf(Manifest.permission.ACTIVITY_RECOGNITION),
            REQUEST_CODE,
        )
    }

    /** Android Auto (car UI mode): missions step aside (15 §8 rule 3). */
    private fun driving(context: Context) =
        context.getSystemService(UiModeManager::class.java).currentModeType ==
            Configuration.UI_MODE_TYPE_CAR

    private class Readings(private val context: Context) : EventChannel.StreamHandler, SensorEventListener {
        private val sensors = context.getSystemService(SensorManager::class.java)
        private var sink: EventChannel.EventSink? = null
        private var kind = ""
        private var startMs = 0L
        private var firstSteps = -1f
        private var gravity = 0f
        private var moving = 0f

        // The light sensor reports only on a change: a steady bright room
        // would never count its 3 s. The last lux repeats every half second.
        private val handler = Handler(Looper.getMainLooper())
        private var lux: Double? = null
        private val repeat = object : Runnable {
            override fun run() {
                lux?.let { sink?.success(mapOf("t" to SystemClock.elapsedRealtime() - startMs, "lux" to it)) }
                handler.postDelayed(this, REPEAT_MS)
            }
        }

        override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
            kind = (arguments as? Map<*, *>)?.get("kind") as? String ?: ""
            sink = events
            startMs = SystemClock.elapsedRealtime()
            firstSteps = -1f
            val main = sensors.getDefaultSensor(sensorType(kind))
                ?: return events.error("missing", kind, null)
            sensors.registerListener(this, main, SensorManager.SENSOR_DELAY_UI)
            if (kind == "light") handler.postDelayed(repeat, REPEAT_MS)
            if (kind == "motion") {
                sensors.getDefaultSensor(Sensor.TYPE_LINEAR_ACCELERATION)?.let {
                    sensors.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)
                }
            }
        }

        override fun onCancel(arguments: Any?) {
            sensors.unregisterListener(this)
            handler.removeCallbacks(repeat)
            lux = null
            sink = null
        }

        override fun onSensorChanged(event: SensorEvent) {
            val t = SystemClock.elapsedRealtime() - startMs
            val reading: Map<String, Any> = when (event.sensor.type) {
                Sensor.TYPE_STEP_COUNTER -> {
                    if (firstSteps < 0) firstSteps = event.values[0]
                    mapOf("t" to t, "steps" to (event.values[0] - firstSteps).toInt())
                }
                Sensor.TYPE_LIGHT -> {
                    lux = event.values[0].toDouble()
                    mapOf("t" to t, "lux" to event.values[0].toDouble())
                }
                Sensor.TYPE_GRAVITY -> {
                    // Upright: gravity along the phone's long (y) axis.
                    gravity = event.values[1] / SensorManager.GRAVITY_EARTH
                    motion(t)
                }
                Sensor.TYPE_LINEAR_ACCELERATION -> {
                    val (x, y, z) = Triple(event.values[0], event.values[1], event.values[2])
                    moving = sqrt(x * x + y * y + z * z) / SensorManager.GRAVITY_EARTH
                    return
                }
                else -> return
            }
            sink?.success(reading)
        }

        private fun motion(t: Long) = mapOf(
            "t" to t,
            "upright" to gravity.toDouble(),
            "moving" to moving.toDouble(),
        )

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit
    }

    private const val REPEAT_MS = 500L
    private const val PREFS = "dottoday_missions"
    private const val ASKED = "steps_asked"
}
