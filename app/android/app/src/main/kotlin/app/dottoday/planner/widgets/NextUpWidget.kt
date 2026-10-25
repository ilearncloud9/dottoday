package app.dottoday.planner.widgets

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.action.clickable
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.text.Text
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition

/** "Next up" (small): the task under way, else the next one (02 F9). */
class NextUpWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val snapshot = WidgetSnapshot.read(currentState<HomeWidgetGlanceState>().preferences)
            NextUp(context, snapshot, System.currentTimeMillis())
        }
    }
}

@Composable
private fun NextUp(context: Context, snapshot: WidgetSnapshot, now: Long) {
    val live = snapshot.live(now)
    val block = live ?: snapshot.next(now)
    val link = block?.let { "dottoday://task/${it.id}" } ?: "dottoday://today"
    Column(
        modifier = GlanceModifier.fillMaxSize().background(DotColors.surface)
            .padding(14.dp).clickable(open(context, link)),
        verticalAlignment = Alignment.Top,
    ) {
        Text(
            text = (if (live != null) snapshot.label("now") else snapshot.label("next_up")).uppercase(),
            style = DotText.caption,
        )
        Spacer(GlanceModifier.height(10.dp))
        if (block == null) {
            Text(snapshot.label("nothing_next"), style = DotText.meta)
            return@Column
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            TaskDot(block.color, done = false, size = 14)
            Spacer(GlanceModifier.width(8.dp))
            Text(block.title, style = DotText.title, maxLines = 2)
        }
        Spacer(GlanceModifier.height(6.dp))
        Text(if (live != null) block.until else block.time, style = DotText.meta)
    }
}

/**
 * Glance's own receiver, not home_widget's: that one runs `runBlocking` on
 * the main thread in onUpdate, which deadlocks with Glance on a cold
 * process (an ANR found in M5.5). The snapshot is still read live from
 * home_widget's prefs in composition.
 */
class NextUpWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = NextUpWidget()
}
