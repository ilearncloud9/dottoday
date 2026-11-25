package app.dottoday.planner.widgets

import android.content.Context
import android.content.Intent
import androidx.glance.appwidget.action.actionSendBroadcast
import androidx.glance.appwidget.cornerRadius
import androidx.glance.layout.Box
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.size
import app.dottoday.planner.intents.DotActionReceiver
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.semantics.contentDescription
import androidx.glance.semantics.semantics
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
    // E-R2-17 and the approved states (ED-471): the day dot and the caption;
    // the mark and the title; "until …" or the start, and Done while under way.
    Column(
        modifier = GlanceModifier.fillMaxSize().background(DotColors.surface).cornerRadius(28.dp)
            .padding(14.dp).clickable(open(context, link)),
        verticalAlignment = Alignment.Top,
    ) {
        WidgetHeader(context, snapshot, now, if (live != null) snapshot.label("now") else snapshot.label("next_up"))
        Spacer(GlanceModifier.height(8.dp))
        if (block == null) {
            Text(snapshot.label("nothing_next"), style = DotText.empty)
            return@Column
        }
        Row(verticalAlignment = Alignment.Top) {
            Box(modifier = GlanceModifier.size(22.dp), contentAlignment = Alignment.Center) {
                TaskMark(context, snapshot, block, now, size = if (live != null) 20f else 14f)
            }
            Spacer(GlanceModifier.width(8.dp))
            Column {
                Text(block.title, style = DotText.title, maxLines = 3)
                if (block.oneThing) Text(snapshot.label("one_thing"), style = DotText.meta)
            }
        }
        Spacer(GlanceModifier.defaultWeight())
        Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.Bottom) {
            Text(
                if (live != null) block.until else block.time,
                style = DotText.meta,
                modifier = GlanceModifier.defaultWeight(),
            )
            // Done only while it is under way (ED-471), in the App colour.
            if (live != null) DoneButton(context, snapshot, block, snapshot.label("done"))
        }
    }
}

/**
 * Next up's Done (docs/09 M9.5): a broadcast to [DotActionReceiver], the
 * same path as the ongoing notification's tick — queued for the app,
 * shown on the snapshot at once, with or without the app running.
 */
@Composable
private fun DoneButton(context: Context, snapshot: WidgetSnapshot, block: WidgetBlock, label: String) {
    val intent = Intent(context, DotActionReceiver::class.java)
        .setAction(DotActionReceiver.ACTION_MARK_DONE)
        .putExtra(DotActionReceiver.EXTRA_OCCURRENCE, block.id)
    Box(
        modifier = GlanceModifier.size(44.dp).clickable(actionSendBroadcast(intent))
            .semantics { contentDescription = label },
    ) { TickButton(context, snapshot, 44f) }
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
