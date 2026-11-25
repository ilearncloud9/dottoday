package app.dottoday.planner.widgets

import android.content.Context
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.Typeface

/**
 * The thread's marks as bitmaps (E-R2-17; Glance and notifications draw no
 * strokes or arcs): white masks the widgets tint per light / dark (the now
 * ring, discs and outlines, the tick), and the ongoing notification's
 * coloured ring, tick and +15.
 */
object DotMarks {
    fun isDark(context: Context) = context.resources.configuration.uiMode and
        Configuration.UI_MODE_NIGHT_MASK == Configuration.UI_MODE_NIGHT_YES

    private fun px(context: Context, dp: Float) = dp * context.resources.displayMetrics.density

    private fun canvas(context: Context, sizeDp: Float): Pair<Bitmap, Canvas> {
        val side = px(context, sizeDp).toInt().coerceAtLeast(8)
        val bitmap = Bitmap.createBitmap(side, side, Bitmap.Config.ARGB_8888)
        return bitmap to Canvas(bitmap)
    }

    /** White, for masks that Glance tints per light / dark (ColorFilter.tint). */
    const val MASK = 0xFFFFFFFF.toInt()

    /** A filled circle of [sizeDp] centred in [boxDp]: the tick's and dots' discs. */
    fun disc(context: Context, boxDp: Float, sizeDp: Float = boxDp): Bitmap {
        val (bitmap, c) = canvas(context, boxDp)
        c.drawCircle(bitmap.width / 2f, bitmap.height / 2f, px(context, sizeDp) / 2,
            Paint(Paint.ANTI_ALIAS_FLAG).apply { color = MASK })
        return bitmap
    }

    /** A circle's outline of [sizeDp] and [strokeDp], centred in [boxDp]. */
    fun outline(context: Context, boxDp: Float, sizeDp: Float, strokeDp: Float): Bitmap {
        val (bitmap, c) = canvas(context, boxDp)
        val stroke = px(context, strokeDp)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE; strokeWidth = stroke; color = MASK }
        c.drawCircle(bitmap.width / 2f, bitmap.height / 2f, px(context, sizeDp) / 2 - stroke / 2, paint)
        return bitmap
    }

    /** The tick alone, in white, for a [sizeDp] round button. */
    fun tickGlyph(context: Context, sizeDp: Float): Bitmap {
        val (bitmap, c) = canvas(context, sizeDp)
        val s = bitmap.width.toFloat()
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = MASK; style = Paint.Style.STROKE; strokeWidth = s * 0.075f
            strokeCap = Paint.Cap.ROUND; strokeJoin = Paint.Join.ROUND
        }
        c.drawPath(Path().apply { moveTo(s * 0.31f, s * 0.52f); lineTo(s * 0.44f, s * 0.65f); lineTo(s * 0.70f, s * 0.36f) }, paint)
        return bitmap
    }

    private fun withAlpha(color: Int, alpha: Float) =
        (color and 0x00FFFFFF) or ((255 * alpha).toInt() shl 24)

    /**
     * A ring of [sizeDp]: [frac] of it in [color] over its faint track; a
     * plain outline of the colour when [hollow] (before its start).
     */
    fun ring(
        context: Context, sizeDp: Float, color: Int, frac: Double,
        hollow: Boolean = false, strokeDp: Float = sizeDp * 0.11f, track: Float = 0.2f,
    ): Bitmap {
        val (bitmap, c) = canvas(context, sizeDp)
        val stroke = px(context, if (hollow) strokeDp * 0.6f else strokeDp)
        val inset = stroke / 2 + 0.5f
        val rect = RectF(inset, inset, bitmap.width - inset, bitmap.height - inset)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE; strokeWidth = stroke }
        if (hollow) {
            paint.color = color
            c.drawOval(rect, paint)
            return bitmap
        }
        paint.color = withAlpha(color, track)
        c.drawOval(rect, paint)
        paint.color = color
        paint.strokeCap = Paint.Cap.ROUND
        c.drawArc(rect, -90f, (360 * frac.coerceIn(0.03, 1.0)).toFloat(), false, paint)
        return bitmap
    }

    /** The round tick: [fill] with the tick in [on]. */
    fun tick(context: Context, sizeDp: Float, fill: Int, on: Int): Bitmap {
        val (bitmap, c) = canvas(context, sizeDp)
        val s = bitmap.width.toFloat()
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = fill }
        c.drawCircle(s / 2, s / 2, s / 2, paint)
        paint.apply {
            color = on; style = Paint.Style.STROKE; strokeWidth = s * 0.075f
            strokeCap = Paint.Cap.ROUND; strokeJoin = Paint.Join.ROUND
        }
        val path = Path().apply {
            moveTo(s * 0.31f, s * 0.52f); lineTo(s * 0.44f, s * 0.65f); lineTo(s * 0.70f, s * 0.36f)
        }
        c.drawPath(path, paint)
        return bitmap
    }

    /** The round +15: [label] in [ink] on [fill]. */
    fun plus(context: Context, sizeDp: Float, fill: Int, ink: Int, label: String): Bitmap {
        val (bitmap, c) = canvas(context, sizeDp)
        val s = bitmap.width.toFloat()
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = fill }
        c.drawCircle(s / 2, s / 2, s / 2, paint)
        paint.apply {
            color = ink; textSize = s * 0.32f; textAlign = Paint.Align.CENTER
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        }
        c.drawText(label, s / 2, s / 2 - (paint.descent() + paint.ascent()) / 2, paint)
        return bitmap
    }
}
