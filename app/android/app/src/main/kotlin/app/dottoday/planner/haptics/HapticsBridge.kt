package app.dottoday.planner.haptics

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * `dottoday/haptics` (lib/shared/haptics/app_haptics.dart, docs/12 §6):
 * the app's own taps through the [Vibrator], so Settings › Sounds ›
 * Haptics in app decides whether they play, not the system's Touch
 * feedback switch (that one governs `View.performHapticFeedback`). A
 * phone with vibration turned off altogether still stays silent.
 * `play` takes "selection", "light" or "medium" and answers whether a tap
 * was sent.
 */
object HapticsBridge {
    fun attach(context: Context, messenger: BinaryMessenger) {
        val vibrator = vibrator(context.applicationContext)
        MethodChannel(messenger, "dottoday/haptics").setMethodCallHandler { call, result ->
            val tick = call.arguments as? String
            if (call.method != "play" || tick == null) return@setMethodCallHandler result.notImplemented()
            result.success(play(vibrator, tick))
        }
    }

    private fun play(vibrator: Vibrator?, tick: String): Boolean {
        if (vibrator == null || !vibrator.hasVibrator()) return false
        vibrator.vibrate(effect(tick))
        return true
    }

    private fun effect(tick: String): VibrationEffect {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            return VibrationEffect.createPredefined(
                when (tick) {
                    "selection" -> VibrationEffect.EFFECT_TICK
                    "medium" -> VibrationEffect.EFFECT_HEAVY_CLICK
                    else -> VibrationEffect.EFFECT_CLICK
                },
            )
        }
        // API 26–28 have no predefined effects: a short pulse of the same weight.
        val (ms, amplitude) = when (tick) {
            "selection" -> 8L to 80
            "medium" -> 20L to 200
            else -> 12L to 140
        }
        return VibrationEffect.createOneShot(ms, amplitude)
    }

    private fun vibrator(context: Context): Vibrator? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            context.getSystemService(VibratorManager::class.java)?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Vibrator::class.java)
        }
}
