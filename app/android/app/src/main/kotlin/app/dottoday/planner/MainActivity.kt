package app.dottoday.planner

import android.app.NotificationManager
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import app.dottoday.planner.intents.IntentQueueBridge
import app.dottoday.planner.intents.ShareIntake
import app.dottoday.planner.intents.OngoingDot
import app.dottoday.planner.focus.DeepWork
import app.dottoday.planner.speech.SpeechBridge
import app.dottoday.planner.system.SystemEvents
import app.dottoday.planner.thinking.ThinkingBridge
import io.flutter.plugin.common.MethodChannel

/**
 * A FragmentActivity because local_auth's biometric prompt needs one (app
 * lock, docs/09 M5.8). `dottoday/secure` turns FLAG_SECURE on while the
 * lock is on: no screenshots, and a blank card in Recents. `dottoday/power`
 * reads and opens the battery-optimisation setting for the notification
 * health panel (docs/09 M6.5.5); it never asks for the restricted
 * REQUEST_IGNORE_BATTERY_OPTIMIZATIONS permission. `dottoday/sound` plays
 * a bundled reminder sound once for the Sound picker's preview (M8.4d).
 * `dottoday/intents` says when a widget or notification queued an action
 * (M9.2c, [IntentQueueBridge]); `dottoday/ongoing` shows the live dot as an
 * ongoing notification (M9.4, [OngoingDot]); `dottoday/thinking` reaches
 * Gemini Nano on the device (M10.1, [ThinkingBridge]); `dottoday/deep_work`
 * is Focus's Do Not Disturb, alarms only (M10.5, [DeepWork]). A shared
 * text or link is queued as an Inbox task (M12.4, [ShareIntake]).
 * `dottoday/speech` is dictation with the on-device recognizer only
 * (M14.4, [SpeechBridge]); it stops when the activity pauses.
 * `dottoday/system_events` says when the clock, zone or calendars change
 * ([SystemEvents], docs/04 §4 "Triggers").
 */
class MainActivity : FlutterFragmentActivity() {
    // Share → Dottoday (M12.4): queued before Flutter reads the intent,
    // which then opens the Inbox.
    override fun onCreate(savedInstanceState: Bundle?) {
        ShareIntake.accept(this, intent)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        ShareIntake.accept(this, intent)
        super.onNewIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        // Calendar access may have just been granted.
        SystemEvents.watchCalendars()
    }

    override fun onPause() {
        SpeechBridge.stop()
        super.onPause()
    }

    @Deprecated("Still the FragmentActivity callback for requestPermissions")
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        @Suppress("DEPRECATION")
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        SpeechBridge.onPermissionResult(requestCode)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        IntentQueueBridge.detach()
        SystemEvents.detach()
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        IntentQueueBridge.attach(this, flutterEngine.dartExecutor.binaryMessenger)
        SystemEvents.attach(this, flutterEngine.dartExecutor.binaryMessenger)
        ThinkingBridge.attach(this, flutterEngine.dartExecutor.binaryMessenger)
        SpeechBridge.attach(this, flutterEngine.dartExecutor.binaryMessenger)
        DeepWork.attach(this, flutterEngine.dartExecutor.binaryMessenger)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dottoday/ongoing")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "sync" -> {
                        OngoingDot.sync(this, call.arguments as? String)
                        result.success(null)
                    }
                    // The device test (integration_test/ongoing_dot_test.dart):
                    // what is posted, and the notification's own action intents.
                    "activeId" -> result.success(OngoingDot.activeId(this))
                    // The consistency gate (M9.8): what the notification shows.
                    "activeContent" -> result.success(OngoingDot.activeContent(this))
                    "perform" -> {
                        OngoingDot.press(this, call.argument<String>("action") ?: "")
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
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
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dottoday/sound")
            .setMethodCallHandler { call, result ->
                // Silent or vibrate: the preview banner says so (docs/12 §6).
                if (call.method == "isMuted") {
                    val audio = getSystemService(AUDIO_SERVICE) as AudioManager
                    return@setMethodCallHandler result.success(
                        audio.ringerMode != AudioManager.RINGER_MODE_NORMAL,
                    )
                }
                val name = call.arguments as? String
                if (call.method != "play" || name == null) {
                    return@setMethodCallHandler result.notImplemented()
                }
                if (!soundName.matches(name)) {
                    return@setMethodCallHandler result.error("bad_sound", null, null)
                }
                playSound(name.substringBefore('.'))
                result.success(null)
            }
    }

    /** Plays raw resource [resource] once as a notification sound (DND applies). */
    private fun playSound(resource: String) {
        // keep.xml keeps every sound prefix: they are only named at run time.
        @Suppress("DiscouragedApi")
        val id = resources.getIdentifier(resource, "raw", packageName)
        if (id == 0) return
        val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        val audio = getSystemService(AUDIO_SERVICE) as AudioManager
        val player = MediaPlayer.create(this, id, attributes, audio.generateAudioSessionId())
            ?: return
        player.setOnCompletionListener { it.release() }
        player.start()
    }

    private companion object {
        // A catalogue file name (docs/12 §5): the sender's Apple name; the
        // raw resource is its base name. Nothing else reaches getIdentifier.
        val soundName = Regex("^[a-z][a-z0-9_]{0,63}\\.(wav|caf|m4a)$")
    }
}
