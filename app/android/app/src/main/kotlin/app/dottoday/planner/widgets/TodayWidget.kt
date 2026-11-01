package app.dottoday.planner.widgets

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.LocalSize
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.provideContent
import androidx.glance.background
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

/** "Today timeline" (medium/large): what is left of the day as dots (02 F9). */
class TodayWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()
    override val sizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val snapshot = WidgetSnapshot.read(currentState<HomeWidgetGlanceState>().preferences)
            Today(context, snapshot, System.currentTimeMillis())
        }
    }
}

@Composable
private fun Today(context: Context, snapshot: WidgetSnapshot, now: Long) {
    // Rows of ~28 dp under a ~30 dp header: as many as the size holds.
    val rows = ((LocalSize.current.height.value - 44) / 28).toInt().coerceIn(1, 8)
    val ahead = snapshot.ahead(now).take(rows)
    Column(
        modifier = GlanceModifier.fillMaxSize().background(DotColors.surface)
            .padding(14.dp).clickable(open(context, "dottoday://today")),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            DayDot(context, snapshot, now)
            Spacer(GlanceModifier.width(6.dp))
            Text(snapshot.label("today").uppercase(), style = DotText.caption)
        }
        Spacer(GlanceModifier.height(8.dp))
        if (ahead.isEmpty()) {
            Text(snapshot.label("nothing_next"), style = DotText.meta)
            return@Column
        }
        for (block in ahead) {
            val live = block.startMs <= now && !block.done
            Row(
                modifier = GlanceModifier.height(28.dp)
                    .clickable(open(context, "dottoday://task/${block.id}")),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                TaskDot(block.color, block.done)
                Spacer(GlanceModifier.width(10.dp))
                Text(
                    if (live) snapshot.label("now") else block.time,
                    style = DotText.meta,
                    modifier = GlanceModifier.width(64.dp),
                )
                Text(block.title, style = if (block.done) DotText.done else DotText.title, maxLines = 1)
            }
        }
    }
}

/**
 * Glance's own receiver, not home_widget's: that one runs `runBlocking` on
 * the main thread in onUpdate, which deadlocks with Glance on a cold
 * process (an ANR found in M5.5). The snapshot is still read live from
 * home_widget's prefs in composition.
 */
class TodayWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = TodayWidget()
}
