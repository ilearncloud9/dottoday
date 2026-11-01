package app.dottoday.planner.widgets

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.action.Action
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.color.ColorProvider
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.text.FontWeight
import androidx.glance.text.TextDecoration
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider as FixedColor

/** Concept A tokens (lib/core/theme/tokens.dart), light / dark. */
object DotColors {
    val surface = ColorProvider(day = Color(0xFFFAFAF8), night = Color(0xFF121214))
    val ink = ColorProvider(day = Color(0xFF1A1A1C), night = Color(0xFFF2F2F0))
    val muted = ColorProvider(day = Color(0xFF6B6B70), night = Color(0xFF9A9AA0))
    val hairline = ColorProvider(day = Color(0xFFE2E2DE), night = Color(0xFF2C2C32))
    val accent = ColorProvider(day = Color(0xFF3B6CF6), night = Color(0xFF7FA0FF))
}

object DotText {
    val caption = TextStyle(color = DotColors.muted, fontSize = 12.sp, fontWeight = FontWeight.Medium)
    val title = TextStyle(color = DotColors.ink, fontSize = 15.sp, fontWeight = FontWeight.Medium)
    val meta = TextStyle(color = DotColors.muted, fontSize = 12.sp)
    val done = TextStyle(color = DotColors.muted, fontSize = 15.sp, textDecoration = TextDecoration.LineThrough)
    val big = TextStyle(color = DotColors.ink, fontSize = 34.sp, fontWeight = FontWeight.Bold)
}

/**
 * A task's dot: its colour, hollow-looking (muted) when done. Today's one
 * thing (docs/15 §8) wears one thin accent ring outside it: an accent
 * disc, a surface gap, then the dot (Glance draws no strokes).
 */
@Composable
fun TaskDot(color: Int, done: Boolean, size: Int = 12, oneThing: Boolean = false) {
    val dot = @Composable {
        Box(
            modifier = GlanceModifier
                .size(size.dp)
                .cornerRadius((size / 2).dp)
                .background(if (done) DotColors.hairline else FixedColor(Color(color))),
        ) {}
    }
    if (!oneThing) return dot()
    val ring = size + 8
    Box(
        modifier = GlanceModifier.size(ring.dp).cornerRadius((ring / 2).dp)
            .background(DotColors.accent).padding(1.5.dp),
        contentAlignment = Alignment.Center,
    ) {
        Box(
            modifier = GlanceModifier.fillMaxSize().cornerRadius((ring / 2).dp)
                .background(DotColors.surface),
            contentAlignment = Alignment.Center,
        ) { dot() }
    }
}

/** Opens [link] (a `dottoday://` deep link, M5.0) in the app. */
fun open(context: Context, link: String): Action = actionStartActivity(
    Intent(Intent.ACTION_VIEW, Uri.parse(link)).setPackage(context.packageName),
)
