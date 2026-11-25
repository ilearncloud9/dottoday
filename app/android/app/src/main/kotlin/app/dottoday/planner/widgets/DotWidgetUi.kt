package app.dottoday.planner.widgets

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.ColorFilter
import androidx.glance.GlanceModifier
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.Action
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.color.ColorProvider
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.TextStyle

/** Concept E's widget tokens (E-R2-17, E-R2-17-Dark), light / dark. */
object DotColors {
    const val CARD_DAY = 0xFFFFFDF9.toInt()
    const val CARD_NIGHT = 0xFF28232A.toInt()
    val surface = ColorProvider(day = Color(CARD_DAY), night = Color(CARD_NIGHT))
    val ink = ColorProvider(day = Color(0xFF241F2B), night = Color(0xFFF3ECE4))
    val muted = ColorProvider(day = Color(0xFF6A6273), night = Color(0xFFC7BEC4))
    val thread = ColorProvider(day = Color(0xFFDDD7E0), night = Color(0xFF4A4348))
}

/** The App colour's words (the "Now" label), light / dark. */
fun accentText(snapshot: WidgetSnapshot) =
    ColorProvider(day = Color(snapshot.accent.light.text), night = Color(snapshot.accent.dark.text))

object DotText {
    val caption = TextStyle(color = DotColors.muted, fontSize = 11.sp, fontWeight = FontWeight.Bold)
    val count = TextStyle(color = DotColors.muted, fontSize = 12.sp, fontWeight = FontWeight.Medium)
    val title = TextStyle(color = DotColors.ink, fontSize = 15.sp, fontWeight = FontWeight.Bold)
    val meta = TextStyle(color = DotColors.muted, fontSize = 12.sp, fontWeight = FontWeight.Medium)
    val empty = TextStyle(color = DotColors.muted, fontSize = 15.sp, fontWeight = FontWeight.Bold)
    val row = TextStyle(color = DotColors.ink, fontSize = 14.sp, fontWeight = FontWeight.Medium)
    val rowNow = TextStyle(color = DotColors.ink, fontSize = 14.sp, fontWeight = FontWeight.Bold)
    val rowDone = TextStyle(color = DotColors.muted, fontSize = 14.sp, fontWeight = FontWeight.Medium)
    val big = TextStyle(color = DotColors.ink, fontSize = 40.sp, fontWeight = FontWeight.Bold)
}

/** [color] in light and its dark step in dark. */
fun dayNight(day: Int, night: Int) = ColorProvider(day = Color(day), night = Color(night))

/** [bitmap] (a white mask) tinted with [tint], light and dark alike. */
@Composable
fun Mask(bitmap: android.graphics.Bitmap, tint: androidx.glance.unit.ColorProvider, sizeDp: Float) {
    Image(
        provider = ImageProvider(bitmap),
        contentDescription = null,
        colorFilter = ColorFilter.tint(tint),
        modifier = GlanceModifier.size(sizeDp.dp),
    )
}

/**
 * A task's mark (E-R2-17): the now ring filling with time used, an ahead
 * dot hollow, a done dot filled; your one thing ringed in the App colour.
 * White masks tinted per light / dark, so the marks follow the system's
 * dark mode as the text does.
 */
@Composable
fun TaskMark(context: Context, snapshot: WidgetSnapshot, block: WidgetBlock, now: Long, size: Float = 14f) {
    val task = dayNight(block.color, block.colorDark)
    val live = !block.done && block.startMs <= now && now < block.endMs
    if (live) {
        val span = (block.endMs - block.startMs).coerceAtLeast(1)
        val ring = DotMarks.ring(context, size + 2, DotMarks.MASK, (now - block.startMs).toDouble() / span, strokeDp = 3f)
        Mask(ring, task, size + 2)
        return
    }
    val box = if (block.oneThing) size + 7 else size
    Box(modifier = GlanceModifier.size(box.dp), contentAlignment = Alignment.Center) {
        if (block.oneThing) {
            Mask(DotMarks.outline(context, box, box, 1.5f), dayNight(snapshot.accent.light.dot, snapshot.accent.dark.dot), box)
        }
        if (block.done) {
            Mask(DotMarks.disc(context, box, size), task, box)
        } else {
            Mask(DotMarks.disc(context, box, size), DotColors.surface, box)
            Mask(DotMarks.outline(context, box, size, 2.5f), task, box)
        }
    }
}

/** The round tick in the App colour (Next up's Done). */
@Composable
fun TickButton(context: Context, snapshot: WidgetSnapshot, sizeDp: Float) {
    val a = snapshot.accent
    Box(modifier = GlanceModifier.size(sizeDp.dp), contentAlignment = Alignment.Center) {
        Mask(DotMarks.disc(context, sizeDp), dayNight(a.light.fill, a.dark.fill), sizeDp)
        Mask(DotMarks.tickGlyph(context, sizeDp), dayNight(a.light.on, a.dark.on), sizeDp)
    }
}

/** Opens [link] (a `dottoday://` deep link, M5.0) in the app. */
fun open(context: Context, link: String): Action = actionStartActivity(
    Intent(Intent.ACTION_VIEW, Uri.parse(link)).setPackage(context.packageName),
)

/** A widget's header: the day dot (or [glyph]), the caption, [trailing] at the end. */
@Composable
fun WidgetHeader(context: Context, snapshot: WidgetSnapshot, now: Long, title: String, trailing: String = "") {
    androidx.glance.layout.Row(
        modifier = GlanceModifier.fillMaxWidth(),
        verticalAlignment = androidx.glance.layout.Alignment.CenterVertically,
    ) {
        DayDot(context, snapshot, now)
        androidx.glance.layout.Spacer(GlanceModifier.width(6.dp))
        androidx.glance.text.Text(title.uppercase(), style = DotText.caption, modifier = GlanceModifier.defaultWeight())
        if (trailing.isNotEmpty()) androidx.glance.text.Text(trailing, style = DotText.count)
    }
}
