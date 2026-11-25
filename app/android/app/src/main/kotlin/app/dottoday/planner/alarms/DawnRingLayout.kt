package app.dottoday.planner.alarms

import android.app.Activity
import android.content.res.ColorStateList
import android.content.res.Configuration
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.RippleDrawable
import android.os.Build
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextClock
import android.widget.TextView
import app.dottoday.planner.R

/**
 * The ringing screen's views at dawn (E-R2-19-B, E-R2-19-B-Dark; ED-314,
 * ED-459): the day dot with the time inside, Wake Up and what the day
 * starts with, then I'm up and Snooze in the thumb zone. A portrait window
 * stacks them as the phone frame; a landscape one puts them side by side
 * as the Android-tablet frame, at the tablet's sizes on a tablet and the
 * phone's on a phone turned sideways (ED-459). Minimal mode drops the words and makes Snooze a text link.
 *
 * Text is in sp, so it follows the font size up to 200 %, except the time,
 * which stays its display size as in Android's own Clock (ED-459 option
 * A); the buttons stay pinned at the foot in portrait so nobody scrolls
 * to stop the alarm.
 */
class DawnRingLayout(
    private val activity: Activity,
    private val alarm: WakeUpAlarm,
    private val onUp: () -> Unit,
    private val onSnooze: () -> Unit,
) {
    /** The board's sizes: the phone frame, or the tablet frame (dp / sp). */
    private class Sizes(
        val ring: Int, val time: Float, val title: Float, val line: Float,
        val up: Float, val upHeight: Int, val snooze: Float, val snoozeHeight: Int,
        val gap: Int, val column: Int, val above: Int, val between: Int,
    )

    private val res = activity.resources
    private val tablet = res.configuration.smallestScreenWidthDp >= TABLET_DP
    private val landscape = res.configuration.orientation == Configuration.ORIENTATION_LANDSCAPE
    private val dark = res.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK == Configuration.UI_MODE_NIGHT_YES
    private val size = if (tablet) TABLET else PHONE

    fun build(): View = FrameLayout(activity).apply {
        background = sky()
        val layout = when {
            landscape -> row()
            tablet -> group()
            else -> column()
        }
        addView(layout, FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT))
    }

    /** The phone frame: the dot and words centred above, the buttons at the foot. */
    private fun column(): View = LinearLayout(activity).apply {
        orientation = LinearLayout.VERTICAL
        clipChildren = false
        insets(this, side = dp(PHONE_SIDE))
        addView(LinearLayout(activity).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            clipChildren = false
            addView(dot())
            // Minimal keeps the words' room, unseen, so the dot stays where
            // the full screen has it (the board's two frames line up).
            addView(words(Gravity.CENTER).apply {
                if (alarm.minimal) visibility = View.INVISIBLE
            }, margins(top = dp(DOT_TO_WORDS)))
        }, LinearLayout.LayoutParams(MATCH_PARENT, 0, 1f))
        // Minimal's Snooze link is shorter than the outlined pill: the gap
        // makes up the difference, so I'm up sits where the full screen has it.
        val link = if (alarm.minimal) (PHONE.snoozeHeight + PHONE.between) - (MINIMAL_SNOOZE + MINIMAL_GAP) else 0
        addView(buttons(), margins(top = dp(WORDS_TO_BUTTONS), bottom = dp(FOOT + link)))
    }

    /**
     * A tablet held upright (ED-461, B): the tablet frame's sizes with the
     * dot, the words and the buttons as one group centred in the height, the
     * buttons the column's width; it scrolls if large text outgrows it.
     */
    private fun group(): View = ScrollView(activity).apply {
        isFillViewport = true
        clipChildren = false
        addView(LinearLayout(activity).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            clipChildren = false
            insets(this, side = 0)
            addView(dot())
            addView(words(Gravity.CENTER).apply {
                if (alarm.minimal) visibility = View.INVISIBLE
            }, LinearLayout.LayoutParams(dp(size.column), WRAP_CONTENT).apply { topMargin = dp(DOT_TO_WORDS) })
            addView(buttons(), LinearLayout.LayoutParams(dp(size.column), WRAP_CONTENT).apply { topMargin = dp(size.above) })
        }, FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT))
    }

    /** The Android-tablet frame's row, at phone sizes on a phone (ED-459). */
    private fun row(): View = ScrollView(activity).apply {
        isFillViewport = true
        addView(LinearLayout(activity).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            clipChildren = false
            insets(this, side = 0)
            addView(dot())
            addView(LinearLayout(activity).apply {
                orientation = LinearLayout.VERTICAL
                if (!alarm.minimal) addView(words(Gravity.START))
                addView(buttons(), margins(top = if (alarm.minimal) 0 else dp(size.above)))
            }, LinearLayout.LayoutParams(dp(size.column), WRAP_CONTENT).apply { marginStart = dp(size.gap) })
        }, FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT))
    }

    /** The day dot with the time inside (fixed size: ED-459 option A). */
    private fun dot(): View = FrameLayout(activity).apply {
        // The sun sits on the ring's edge and reaches past the dot's box, as
        // on the board (its SVG overflows); nothing up the tree may cut it.
        clipChildren = false
        addView(DawnDial(activity, alarm.arcs, dark), FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT))
        addView(TextClock(activity).apply {
            format12Hour = "h:mm"
            format24Hour = "H:mm"
            setTextSize(TypedValue.COMPLEX_UNIT_DIP, size.time)
            typeface = Typeface.create("sans-serif-light", Typeface.NORMAL)
            letterSpacing = TIME_TRACKING
            setTextColor(DawnDial.INK)
            includeFontPadding = false
        }, FrameLayout.LayoutParams(WRAP_CONTENT, WRAP_CONTENT, Gravity.CENTER))
        layoutParams = LinearLayout.LayoutParams(dp(size.ring), dp(size.ring))
    }

    /** "Wake Up" and "First: Morning run at 6:45 AM" (or "Good morning."). */
    private fun words(align: Int): View = LinearLayout(activity).apply {
        orientation = LinearLayout.VERTICAL
        addView(text(alarm.title, size.title, Manrope.EXTRA_BOLD, align).apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) isAccessibilityHeading = true
        })
        addView(text(alarm.body, size.line, Manrope.SEMI_BOLD, align).apply { alpha = LINE_ALPHA },
            margins(top = dp(if (tablet) TABLET_TITLE_TO_LINE else TITLE_TO_LINE)))
    }

    private fun buttons(): View = LinearLayout(activity).apply {
        orientation = LinearLayout.VERTICAL
        addView(up(), margins())
        if (!alarm.canSnooze) return@apply
        val gap = dp(if (alarm.minimal) MINIMAL_GAP else size.between)
        addView(if (alarm.minimal) snoozeLink() else snooze(), margins(top = gap))
    }

    /** I'm up: the big white pill in the thumb zone, with the board's shadow. */
    private fun up() = pill(alarm.stop, size.up, Manrope.EXTRA_BOLD, size.upHeight).apply {
        setTextColor(activity.getColor(R.color.wake_up_on_white))
        background = ripple(GradientDrawable().apply { cornerRadius = PILL; setColor(DawnDial.INK) })
        elevation = dp(UP_ELEVATION).toFloat()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) outlineSpotShadowColor = Color.BLACK
        setOnClickListener { onUp() }
    }

    /** Snooze: an outlined pill under I'm up. */
    private fun snooze() = pill(alarm.snooze, size.snooze, Manrope.BOLD, size.snoozeHeight).apply {
        setTextColor(DawnDial.INK)
        background = ripple(GradientDrawable().apply {
            cornerRadius = PILL
            setStroke(dp(1.5f), Color.argb(OUTLINE_ALPHA, 255, 255, 255))
        })
        setOnClickListener { onSnooze() }
    }

    /** Minimal mode's Snooze: a text link (the board's 48 high, 16). */
    private fun snoozeLink() = pill(alarm.snooze, size.snooze - 1f, Manrope.BOLD, MINIMAL_SNOOZE).apply {
        setTextColor(DawnDial.INK)
        background = ripple(null)
        setOnClickListener { onSnooze() }
    }

    private fun pill(label: String, sp: Float, weight: Int, height: Int) = Button(activity).apply {
        text = label
        isAllCaps = false
        stateListAnimator = null
        setTextSize(TypedValue.COMPLEX_UNIT_SP, sp)
        typeface = Manrope.of(activity, weight)
        minHeight = dp(height)
        minimumHeight = dp(height)
        val v = dp(PILL_PAD)
        setPadding(v, v, v, v)
    }

    private fun text(value: String, sp: Float, weight: Int, align: Int) = TextView(activity).apply {
        text = value
        setTextSize(TypedValue.COMPLEX_UNIT_SP, sp)
        typeface = Manrope.of(activity, weight)
        setTextColor(DawnDial.INK)
        gravity = align
    }

    /** The press ripple, kept to the pill's shape. */
    private fun ripple(shape: GradientDrawable?): RippleDrawable {
        val mask = GradientDrawable().apply { cornerRadius = PILL; setColor(Color.WHITE) }
        return RippleDrawable(ColorStateList.valueOf(Color.argb(RIPPLE_ALPHA, 0, 0, 0)), shape, mask)
    }

    /** The dawn: night plum at the top, rose at 55 %, first light at the foot. */
    private fun sky() = GradientDrawable().apply {
        orientation = GradientDrawable.Orientation.TOP_BOTTOM
        val colours = intArrayOf(
            activity.getColor(R.color.wake_up_sky_top),
            activity.getColor(R.color.wake_up_sky_middle),
            activity.getColor(R.color.wake_up_sky_bottom),
        )
        // Before Android 10 the middle colour sits at half way.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            setColors(colours, floatArrayOf(0f, SKY_MIDDLE, 1f))
        } else {
            setColors(colours)
        }
    }

    /** Pads [view] clear of the bars and the camera cutout, evenly side to side. */
    private fun insets(view: View, side: Int) {
        view.setOnApplyWindowInsetsListener { v, insets ->
            val bars = SystemInsets.of(insets)
            val sides = maxOf(bars.left, bars.right) + side
            v.setPadding(sides, bars.top, sides, bars.bottom)
            insets
        }
    }

    private fun margins(top: Int = 0, bottom: Int = 0) =
        LinearLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT).apply { topMargin = top; bottomMargin = bottom }

    private fun dp(value: Int) = dp(value.toFloat())

    private fun dp(value: Float) = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value, res.displayMetrics).toInt()

    private companion object {
        /** E-R2-19-B's phone frame and Android-tablet frame. */
        val PHONE = Sizes(300, 84f, 28f, 17f, 19f, 72, 17f, 56, 56, 356, 28, 12)
        val TABLET = Sizes(420, 118f, 40f, 22f, 21f, 76, 18f, 60, 90, 420, 40, 14)
        /** A tablet: its shortest side 600 or more, as the missions decide (ED-454). */
        const val TABLET_DP = 600

        /** Phone-frame spacing: 28 at the sides, 22 dot to words, 6 under the title. */
        const val PHONE_SIDE = 28
        const val DOT_TO_WORDS = 22
        const val TITLE_TO_LINE = 6

        /** The tablet frame's 14 between Wake Up and its line. */
        const val TABLET_TITLE_TO_LINE = 14
        const val WORDS_TO_BUTTONS = 28
        /** Under Snooze to the gesture area: the board's 104 less its 24. */
        const val FOOT = 80
        const val MINIMAL_GAP = 6
        const val MINIMAL_SNOOZE = 48
        const val PILL_PAD = 12
        const val UP_ELEVATION = 10
        const val PILL = 999f

        const val TIME_TRACKING = -0.024f
        const val LINE_ALPHA = 0.85f
        const val OUTLINE_ALPHA = 128
        const val RIPPLE_ALPHA = 31
        const val SKY_MIDDLE = 0.55f
    }
}
