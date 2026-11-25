package app.dottoday.planner.widgets

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceModifier
import androidx.glance.layout.Box
import androidx.glance.layout.size

/**
 * The day dot on the widgets (docs/10 §3, docs/15 W6): the waking day as a
 * ring from the top, filled so far in the accent, then the night round to
 * the next Wake Up in a faint tint. Glance can't draw arcs, so it is a
 * bitmap; the shares come from the app's snapshot (`night_start`).
 */
@Composable
fun DayDot(context: Context, snapshot: WidgetSnapshot, now: Long) {
    val (day, filled) = snapshot.dayDot(now)
    val accent = dayNight(snapshot.accent.light.dot, snapshot.accent.dark.dot)
    // White masks tinted per light / dark: the day in the App colour, the
    // night in the thread's colour.
    Box(modifier = GlanceModifier.size(14.dp)) {
        if (day < 1) Mask(nightMask(context, day), DotColors.thread, 14f)
        Mask(dayMask(context, day, filled), accent, 14f)
    }
}

private fun ringCanvas(context: Context): Triple<Bitmap, Canvas, Float> {
    val px = (14 * context.resources.displayMetrics.density).toInt().coerceAtLeast(14)
    val bitmap = Bitmap.createBitmap(px, px, Bitmap.Config.ARGB_8888)
    return Triple(bitmap, Canvas(bitmap), px * 0.2f)
}

/** The waking day: a faint track, the part so far, the centre dot. */
private fun dayMask(context: Context, day: Double, filled: Double): Bitmap {
    val (bitmap, canvas, ring) = ringCanvas(context)
    val px = bitmap.width
    val rect = RectF(ring / 2, ring / 2, px - ring / 2, px - ring / 2)
    val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE; strokeWidth = ring }
    paint.color = 0x26FFFFFF
    canvas.drawArc(rect, -90f, (360 * day).toFloat(), false, paint)
    paint.color = DotMarks.MASK
    if (filled > 0) canvas.drawArc(rect, -90f, (360 * filled).toFloat(), false, paint)
    paint.style = Paint.Style.FILL
    canvas.drawCircle(px / 2f, px / 2f, px * 0.145f, paint)
    return bitmap
}

/** The night round to the next Wake Up: thinner, so it reads as night. */
private fun nightMask(context: Context, day: Double): Bitmap {
    val (bitmap, canvas, ring) = ringCanvas(context)
    val px = bitmap.width
    val rect = RectF(ring / 2, ring / 2, px - ring / 2, px - ring / 2)
    val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE; strokeWidth = ring * 0.45f; color = DotMarks.MASK
    }
    canvas.drawArc(rect, (-90 + 360 * day).toFloat(), (360 * (1 - day)).toFloat(), false, paint)
    return bitmap
}
