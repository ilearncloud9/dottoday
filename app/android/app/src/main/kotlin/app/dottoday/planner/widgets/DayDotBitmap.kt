package app.dottoday.planner.widgets

import android.content.Context
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
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
    Image(
        provider = ImageProvider(dayDotBitmap(context, day, filled)),
        contentDescription = null,
        modifier = GlanceModifier.size(14.dp),
    )
}

/** Concept A tokens, as DotWidgetUi's (docs/10 §2.1). */
private fun dayDotBitmap(context: Context, day: Double, filled: Double): Bitmap {
    val dark = context.resources.configuration.uiMode and
        Configuration.UI_MODE_NIGHT_MASK == Configuration.UI_MODE_NIGHT_YES
    val px = (14 * context.resources.displayMetrics.density).toInt().coerceAtLeast(14)
    val bitmap = Bitmap.createBitmap(px, px, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)
    val ring = px * 0.2f
    val rect = RectF(ring / 2, ring / 2, px - ring / 2, px - ring / 2)
    val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE; strokeWidth = ring }
    val accent = if (dark) 0xFF7FA0FF.toInt() else 0xFF3B6CF6.toInt()
    paint.color = if (dark) 0xFF2C2C32.toInt() else 0xFFE2E2DE.toInt()
    canvas.drawArc(rect, -90f, (360 * day).toFloat(), false, paint)
    if (day < 1) {
        // Ink at 12 % (light) or 18 % (dark) over the surface: the night.
        // Thinner, not just fainter: the night reads as night without colour.
        paint.color = if (dark) 0xFF3A3A3D.toInt() else 0xFFE3E3E2.toInt()
        paint.strokeWidth = ring * 0.45f
        canvas.drawArc(rect, (-90 + 360 * day).toFloat(), (360 * (1 - day)).toFloat(), false, paint)
        paint.strokeWidth = ring
    }
    if (filled > 0) {
        paint.color = accent
        canvas.drawArc(rect, -90f, (360 * filled).toFloat(), false, paint)
    }
    paint.style = Paint.Style.FILL
    canvas.drawCircle(px / 2f, px / 2f, px * 0.12f, paint)
    return bitmap
}
