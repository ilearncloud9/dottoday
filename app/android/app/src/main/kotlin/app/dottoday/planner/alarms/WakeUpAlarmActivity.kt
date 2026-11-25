package app.dottoday.planner.alarms

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.WindowInsetsController
import android.view.WindowManager
import app.dottoday.planner.MainActivity
import java.lang.ref.WeakReference

/**
 * The Wake Up ringing screen over the lock screen (docs/15 W1b, §10),
 * opened by the ringing notification's full-screen intent: the dawn round
 * the day dot with the time inside, what the day starts with, I'm up and
 * Snooze (while it is offered); Minimal mode keeps the time and one big
 * I'm up, Snooze as a text link (E-R2-19-B, ED-314; [DawnRingLayout]).
 * Native, so it shows at once with the app closed; its words and the day's
 * dots come from the app with the alarm. It never animates (ED-312).
 */
class WakeUpAlarmActivity : Activity() {
    private var id: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        overLockScreen()
        edgeToEdge()
        current = WeakReference(this)
        show(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        show(intent)
    }

    override fun onDestroy() {
        if (current?.get() === this) current = null
        super.onDestroy()
    }

    private fun show(intent: Intent) {
        val alarm = intent.getStringExtra(WakeUpRingService.EXTRA_ID)
            ?.let { WakeUpAlarms.find(this, it) }
            ?: return finish()
        id = alarm.id
        if (intent.getBooleanExtra(EXTRA_UP, false)) return stop()
        setContentView(DawnRingLayout(this, alarm, onUp = ::stop, onSnooze = ::snooze).build())
    }

    private fun snooze() {
        id?.let { WakeUpActions.snooze(this, it) }
        finish()
    }

    /** "I'm up": stops the ring and opens the Wake Up card (docs/15 §5),
     *  or on a mission morning quiets it and opens the mission (15 §8);
     *  either shows once the phone is unlocked. Not for the test alarm. */
    private fun stop() {
        val id = id ?: return finish()
        val link = WakeUpActions.up(this, id)
        if (id != WakeUpAlarm.TEST_ID) {
            startActivity(
                Intent(Intent.ACTION_VIEW, Uri.parse(link), this, MainActivity::class.java)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
        }
        finish()
    }

    private fun overLockScreen() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON,
            )
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    /** The sky runs under the status and navigation bars, light icons on it. */
    private fun edgeToEdge() {
        // The insets controller lives on the decor view: make it first.
        window.decorView
        // NormalTheme is a pre-Material theme: without this the bars stay black.
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
        window.statusBarColor = Color.TRANSPARENT
        window.navigationBarColor = Color.TRANSPARENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
            window.insetsController?.setSystemBarsAppearance(
                0,
                WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS or WindowInsetsController.APPEARANCE_LIGHT_NAVIGATION_BARS,
            )
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            window.attributes = window.attributes.apply {
                layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            }
        }
    }

    companion object {
        private var current: WeakReference<WakeUpAlarmActivity>? = null

        /** Opened by the notification's "I'm up" on a mission morning. */
        const val EXTRA_UP = "up"

        /** Closes the screen when the ring ends elsewhere (button, cap). */
        fun close() {
            current?.get()?.finish()
        }
    }
}
