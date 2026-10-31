package app.dottoday.planner.alarms

import android.app.Activity
import android.content.Intent
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextClock
import android.widget.TextView
import app.dottoday.planner.R
import java.lang.ref.WeakReference

/**
 * The Wake Up ringing screen over the lock screen (docs/15 W1b, §10),
 * opened by the ringing notification's full-screen intent: the time, what
 * the day starts with, Snooze (while it is offered) and "I'm up". Minimal
 * mode shows the time and one big "I'm up", with Snooze as a text link.
 * Native, so it shows at once with the app closed; its words come from the
 * app with the alarm. Text is in sp and every button is at least 56 dp
 * high, so it reads at 200 % font size and suits TalkBack.
 */
class WakeUpAlarmActivity : Activity() {
    private var id: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        overLockScreen()
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
        setContentView(if (alarm.minimal) minimal(alarm) else full(alarm))
    }

    private fun full(alarm: WakeUpAlarm): View = column().apply {
        addView(clock())
        addView(text(alarm.title, 28f, R.color.wake_up_ink, heading = true))
        addView(text(alarm.body, 18f, R.color.wake_up_muted))
        addView(gap())
        if (alarm.canSnooze) addView(button(alarm.snooze, filled = false) { snooze() })
        addView(button(alarm.stop, filled = true) { stop() })
    }

    private fun minimal(alarm: WakeUpAlarm): View = column().apply {
        addView(clock())
        addView(gap())
        addView(button(alarm.stop, filled = true, large = true) { stop() })
        if (alarm.canSnooze) addView(link(alarm.snooze) { snooze() })
    }

    private fun snooze() {
        id?.let { WakeUpActions.snooze(this, it) }
        finish()
    }

    private fun stop() {
        id?.let { WakeUpActions.dismiss(this, it) }
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

    private fun column() = LinearLayout(this).apply {
        orientation = LinearLayout.VERTICAL
        gravity = Gravity.CENTER
        setBackgroundColor(getColor(R.color.wake_up_surface))
        val pad = dp(24)
        setPadding(pad, pad, pad, pad)
    }

    private fun clock() = TextClock(this).apply {
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 64f)
        setTextColor(getColor(R.color.wake_up_ink))
        gravity = Gravity.CENTER
    }

    private fun text(value: String, sp: Float, color: Int, heading: Boolean = false) = TextView(this).apply {
        text = value
        setTextSize(TypedValue.COMPLEX_UNIT_SP, sp)
        setTextColor(getColor(color))
        gravity = Gravity.CENTER
        setPadding(0, dp(8), 0, 0)
        if (heading && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) isAccessibilityHeading = true
    }

    private fun gap() = View(this).apply {
        layoutParams = LinearLayout.LayoutParams(1, dp(48))
    }

    private fun button(label: String, filled: Boolean, large: Boolean = false, onTap: () -> Unit) =
        Button(this).apply {
            text = label
            isAllCaps = false
            setTextSize(TypedValue.COMPLEX_UNIT_SP, if (large) 24f else 20f)
            val accent = getColor(R.color.wake_up_accent)
            setTextColor(if (filled) getColor(R.color.wake_up_on_accent) else accent)
            background = GradientDrawable().apply {
                cornerRadius = dp(28).toFloat()
                if (filled) setColor(accent) else setStroke(dp(2), accent)
            }
            minHeight = dp(if (large) 96 else 56)
            layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)
                .apply { topMargin = dp(12) }
            setOnClickListener { onTap() }
        }

    private fun link(label: String, onTap: () -> Unit) = Button(this, null, android.R.attr.borderlessButtonStyle).apply {
        text = label
        isAllCaps = false
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
        setTextColor(getColor(R.color.wake_up_accent))
        minHeight = dp(56)
        setOnClickListener { onTap() }
    }

    private fun dp(value: Int) = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP, value.toFloat(), resources.displayMetrics,
    ).toInt()

    companion object {
        private var current: WeakReference<WakeUpAlarmActivity>? = null

        /** Closes the screen when the ring ends elsewhere (button, cap). */
        fun close() {
            current?.get()?.finish()
        }
    }
}
