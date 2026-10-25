package app.dottoday.planner.tiles

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import app.dottoday.planner.MainActivity
import app.dottoday.planner.intents.DotActionKind
import app.dottoday.planner.intents.DotActionReceiver
import app.dottoday.planner.widgets.WidgetSnapshot

// Quick Settings tiles (docs/09 M9.5, docs/11 A1): Add task and Start
// focus, the same two B6 actions as the iOS controls. They read the day
// snapshot and queue like every other surface; none talks to the network.

/** Opens [link] in the app and closes the shade. */
@SuppressLint("StartActivityAndCollapseDeprecated")
private fun TileService.openApp(link: String) {
    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(link), this, MainActivity::class.java)
        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
        startActivityAndCollapse(
            PendingIntent.getActivity(this, link.hashCode(), intent, PendingIntent.FLAG_IMMUTABLE),
        )
    } else {
        @Suppress("DEPRECATION")
        startActivityAndCollapse(intent)
    }
}

/** Add task: Quick Add over Today (`dottoday://add`). */
class AddTaskTileService : TileService() {
    override fun onStartListening() {
        qsTile?.apply { state = Tile.STATE_INACTIVE }?.updateTile()
    }

    override fun onClick() = openApp("dottoday://add")
}

/**
 * Start focus: starts the dot under way (else the next one) and opens it;
 * with nothing on, opens Today.
 */
class StartFocusTileService : TileService() {
    override fun onStartListening() {
        val now = System.currentTimeMillis()
        val snapshot = WidgetSnapshot.read(DotActionReceiver.prefs(this))
        qsTile?.apply {
            state = if (snapshot.live(now) ?: snapshot.next(now) != null) Tile.STATE_INACTIVE else Tile.STATE_UNAVAILABLE
        }?.updateTile()
    }

    override fun onClick() {
        val now = System.currentTimeMillis()
        val snapshot = WidgetSnapshot.read(DotActionReceiver.prefs(this))
        val dot = snapshot.live(now) ?: snapshot.next(now) ?: return openApp("dottoday://today")
        DotActionReceiver.perform(DotActionReceiver.prefs(this), DotActionKind.START_FOCUS, dot.id, null, now)
        // The app drains the Start focus and opens Focus on it (M10.5).
        openApp("dottoday://today")
    }
}
