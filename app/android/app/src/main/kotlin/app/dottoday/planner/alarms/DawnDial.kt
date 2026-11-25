package app.dottoday.planner.alarms

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.view.View

/**
 * The day dot on the ringing screen (E-R2-19-B "It rings: dawn round the
 * day dot", ED-314): a faint track, the day's dots as arcs in their colours
 * at 55 % round the 24 hours from Wake Up, and the sun at Wake Up at the
 * top. Drawn in the board's 300 box and scaled to the view. With no arcs
 * it is the track and the sun only (ED-459). Decorative: the time and the
 * words beside it are what TalkBack reads.
 */
class DawnDial(context: Context, private val arcs: List<WakeUpArc>, private val dark: Boolean) : View(context) {
    private val stroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeCap = Paint.Cap.ROUND
    }
    private val fill = Paint(Paint.ANTI_ALIAS_FLAG)
    private val box = RectF()

    init {
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    override fun onDraw(canvas: Canvas) {
        val k = width / BOX
        val c = width / 2f
        val r = RADIUS * k
        box.set(c - r, c - r, c + r, c + r)
        stroke.strokeWidth = TRACK * k
        stroke.color = Color.argb(TRACK_ALPHA, 255, 255, 255)
        canvas.drawCircle(c, c, r, stroke)
        for (arc in arcs) {
            // The board leaves a hair of sky at each end of a dot.
            val start = arc.from * 360f + INSET
            val sweep = ((arc.to - arc.from) * 360f - 2 * INSET).coerceAtLeast(MIN_SWEEP)
            val colour = if (dark) arc.dark else arc.light
            stroke.color = Color.argb(DOT_ALPHA, Color.red(colour), Color.green(colour), Color.blue(colour))
            canvas.drawArc(box, start - 90f, sweep, false, stroke)
        }
        val top = c - r
        fill.style = Paint.Style.FILL
        fill.color = SUN
        canvas.drawCircle(c, top, SUN_R * k, fill)
        fill.style = Paint.Style.STROKE
        fill.strokeWidth = SUN_EDGE * resources.displayMetrics.density
        fill.color = INK
        canvas.drawCircle(c, top, SUN_R * k, fill)
    }

    companion object {
        /** The board's geometry, in its 300 box. */
        private const val BOX = 300f
        private const val RADIUS = 140f
        private const val TRACK = 10f
        private const val SUN_R = 14f
        private const val SUN_EDGE = 2f

        /** Track 18 % white (the light board's; ED-459), dots 55 %. */
        private const val TRACK_ALPHA = 46
        private const val DOT_ALPHA = 140

        /** Degrees left clear at each end of a dot, and the shortest dot. */
        private const val INSET = 0.8f
        private const val MIN_SWEEP = 0.5f

        /** The sun at Wake Up (#FFD27A) and its white edge (#FEFEFE). */
        private const val SUN = 0xFFFFD27A.toInt()
        const val INK = 0xFFFEFEFE.toInt()
    }
}
