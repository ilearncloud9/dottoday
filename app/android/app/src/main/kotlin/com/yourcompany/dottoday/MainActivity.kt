package com.yourcompany.dottoday

import android.app.NotificationManager
import android.content.Intent
import android.os.PowerManager
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * A FragmentActivity because local_auth's biometric prompt needs one (app
 * lock, docs/09 M5.8). `dottoday/secure` turns FLAG_SECURE on while the
 * lock is on: no screenshots, and a blank card in Recents. `dottoday/power`
 * reads and opens the battery-optimisation setting for the notification
 * health panel (docs/09 M6.5.5); it never asks for the restricted
 * REQUEST_IGNORE_BATTERY_OPTIMIZATIONS permission.
 */
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dottoday/secure")
            .setMethodCallHandler { call, result ->
                if (call.method != "set") return@setMethodCallHandler result.notImplemented()
                if (call.arguments == true) {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
                result.success(null)
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dottoday/power")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isRestricted" -> {
                        val power = getSystemService(POWER_SERVICE) as PowerManager
                        result.success(!power.isIgnoringBatteryOptimizations(packageName))
                    }
                    "openSettings" -> {
                        startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                        result.success(null)
                    }
                    // Do Not Disturb (M6.5.8): needs no permission to read.
                    "isDndOn" -> {
                        val notes = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
                        result.success(
                            notes.currentInterruptionFilter != NotificationManager.INTERRUPTION_FILTER_ALL,
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
