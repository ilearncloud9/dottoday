package app.dottoday.planner

import android.app.Application
import app.dottoday.engine_hooks.EngineHooksPlugin
import app.dottoday.planner.alarms.AlarmBridge

/**
 * Attaches `dottoday/alarm` ([AlarmBridge]) to every Flutter engine through
 * [EngineHooksPlugin] (ADR-0019), not only MainActivity's: the workmanager
 * background resync (lib/background_refresh.dart) must move or disarm the
 * Wake Up alarm when sync changes it, or the old alarm and the new
 * notification both ring (R-10).
 */
class DottodayApp : Application() {
    override fun onCreate() {
        super.onCreate()
        EngineHooksPlugin.install { context, messenger -> AlarmBridge.attach(context, messenger) }
    }
}
