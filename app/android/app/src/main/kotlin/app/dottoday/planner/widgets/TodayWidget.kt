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
import androidx.glance.layout.Box
import androidx.glance.layout.fillMaxWidth
import androidx.glance.appwidget.cornerRadius
import androidx.glance.text.FontWeight
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
    // E-R2-17: rows 24 dp in the medium, 30 + 6 in the large (by height).
    val height = LocalSize.current.height.value
    val large = height > 220
    val pitch = if (large) 36 else 24
    val rows = ((height - 52) / pitch).toInt().coerceIn(1, if (large) 6 else 4)
    val ahead = snapshot.ahead(now).take(rows)
    Column(
        modifier = GlanceModifier.fillMaxSize().background(DotColors.surface).cornerRadius(28.dp)
            .padding(14.dp).clickable(open(context, "dottoday://today")),
    ) {
        WidgetHeader(context, snapshot, now, snapshot.label("today"), snapshot.doneOf())
        Spacer(GlanceModifier.height(8.dp))
        if (ahead.isEmpty()) {
            Text(snapshot.label("nothing_next"), style = DotText.empty)
            return@Column
        }
        Box {
            // The thread behind the dots, from the first to the last.
            if (ahead.size > 1) {
                val top = (if (large) 30 else 24) / 2
                Box(
                    modifier = GlanceModifier.width(MARK_COLUMN.dp).height((top + pitch * (ahead.size - 1)).dp)
                        .padding(top = top.dp),
                    contentAlignment = Alignment.TopCenter,
                ) {
                    Box(
                        modifier = GlanceModifier.width(2.dp).height((pitch * (ahead.size - 1)).dp)
                            .background(DotColors.thread),
                    ) {}
                }
            }
            Column {
                for ((i, block) in ahead.withIndex()) {
                    if (large && i > 0) Spacer(GlanceModifier.height(6.dp))
                    TodayRow(context, snapshot, block, now, if (large) 30 else 24)
                }
            }
        }
    }
}

/** The marks' column: wide enough for your one thing's outer ring (21 dp). */
private const val MARK_COLUMN = 22

/** One row: the mark, "Now" or the time, the title (your one thing labelled). */
@Composable
private fun TodayRow(context: Context, snapshot: WidgetSnapshot, block: WidgetBlock, now: Long, rowDp: Int) {
    val live = !block.done && block.startMs <= now && now < block.endMs
    Row(
        modifier = GlanceModifier.height(rowDp.dp).fillMaxWidth()
            .clickable(open(context, "dottoday://task/${block.id}")),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(modifier = GlanceModifier.width(MARK_COLUMN.dp), contentAlignment = Alignment.Center) {
            TaskMark(context, snapshot, block, now)
        }
        Spacer(GlanceModifier.width(7.dp))
        Text(
            if (live) snapshot.label("now") else block.time,
            style = if (live) DotText.meta.copy(color = accentText(snapshot), fontWeight = FontWeight.Bold) else DotText.meta,
            modifier = GlanceModifier.width(62.dp),
        )
        Text(
            block.title,
            style = when { live -> DotText.rowNow; block.done -> DotText.rowDone; else -> DotText.row },
            maxLines = 1,
        )
        if (block.oneThing) {
            Spacer(GlanceModifier.width(6.dp))
            Text(snapshot.label("one_thing"), style = DotText.meta, maxLines = 1)
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
