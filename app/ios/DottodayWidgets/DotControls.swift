import AppIntents
import SwiftUI
import WidgetKit

// Control Center, Lock Screen and Action button controls (iOS 18, docs/09
// M9.5, docs/11 A1): Add task and Start focus, both B6 intents.

@available(iOS 18.0, *)
struct AddTaskControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "app.dottoday.planner.control.add") {
      ControlWidgetButton(action: OpenQuickAddIntent()) {
        Label("intentAddTaskTitle", systemImage: "plus.circle")
      }
    }
    .displayName("intentAddTaskTitle")
  }
}

@available(iOS 18.0, *)
struct StartFocusControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "app.dottoday.planner.control.focus") {
      ControlWidgetButton(action: StartFocusIntent()) {
        Label("intentStartFocusTitle", systemImage: "smallcircle.filled.circle")
      }
    }
    .displayName("intentStartFocusTitle")
  }
}
