package app.dottoday.planner.widgets

import android.content.Context
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Column
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.text.Text
import androidx.compose.ui.graphics.Color
import androidx.glance.ColorFilter
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.appwidget.cornerRadius
import androidx.glance.color.ColorProvider
import androidx.glance.layout.Alignment
import androidx.glance.layout.Row
import androidx.glance.layout.size
import androidx.glance.layout.width
import app.dottoday.planner.R
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition

/** "Inbox count" (small): how many tasks wait for a time (02 F9). */
class InboxWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val snapshot = WidgetSnapshot.read(currentState<HomeWidgetGlanceState>().preferences)
            Column(
                modifier = GlanceModifier.fillMaxSize().background(DotColors.surface).cornerRadius(28.dp)
                    .padding(14.dp).clickable(open(context, "dottoday://inbox")),
            ) {
                // E-R2-17: the tray in the App colour and INBOX, the count, its words.
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Image(
                        provider = ImageProvider(R.drawable.ic_widget_inbox),
                        contentDescription = null,
                        colorFilter = ColorFilter.tint(
                            ColorProvider(day = Color(snapshot.accent.light.dot), night = Color(snapshot.accent.dark.dot)),
                        ),
                        modifier = GlanceModifier.size(16.dp),
                    )
                    Spacer(GlanceModifier.width(6.dp))
                    Text(snapshot.label("inbox_title").uppercase(), style = DotText.caption)
                }
                Spacer(GlanceModifier.defaultWeight())
                Text("${snapshot.inboxCount}", style = DotText.big)
                Text(snapshot.label("inbox"), style = DotText.meta)
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
class InboxWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = InboxWidget()
}
