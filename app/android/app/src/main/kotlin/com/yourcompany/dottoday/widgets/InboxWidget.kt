package com.yourcompany.dottoday.widgets

import android.content.Context
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Column
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.text.Text
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

/** "Inbox count" (small): how many tasks wait for a time (02 F9). */
class InboxWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val snapshot = WidgetSnapshot.read(currentState<HomeWidgetGlanceState>().preferences)
            Column(
                modifier = GlanceModifier.fillMaxSize().background(DotColors.surface)
                    .padding(14.dp).clickable(open(context, "dottoday://inbox")),
            ) {
                Text("${snapshot.inboxCount}", style = DotText.big)
                Spacer(GlanceModifier.height(4.dp))
                Text(snapshot.label("inbox"), style = DotText.meta)
            }
        }
    }
}

class InboxWidgetReceiver : HomeWidgetGlanceWidgetReceiver<InboxWidget>() {
    override val glanceAppWidget = InboxWidget()
}
