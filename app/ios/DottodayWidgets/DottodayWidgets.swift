import SwiftUI
import WidgetKit

/// Home-screen and Lock Screen widgets (docs/02 F9, docs/07 iOS, M5.4).
@main
struct DottodayWidgets: WidgetBundle {
  var body: some Widget {
    NextUpWidget()
    TodayWidget()
    InboxWidget()
    if #available(iOS 16.2, *) {
      DotLiveActivity()
    }
    if #available(iOS 18.0, *) {
      AddTaskControl()
      StartFocusControl()
    }
    if #available(iOS 26.0, *) {
      WakeUpAlarmActivity()
    }
  }
}

struct SnapshotEntry: TimelineEntry {
  let date: Date
  let snapshot: Snapshot
}

/// One entry now and one at every task start/end, so "Next up" moves on
/// without the app; the app reloads the timelines after every change.
struct SnapshotProvider: TimelineProvider {
  func placeholder(in context: Context) -> SnapshotEntry {
    SnapshotEntry(date: Date(), snapshot: .empty)
  }

  func getSnapshot(in context: Context, completion: @escaping (SnapshotEntry) -> Void) {
    completion(SnapshotEntry(date: Date(), snapshot: Snapshot.load()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<SnapshotEntry>) -> Void) {
    let now = Date()
    let snapshot = Snapshot.load()
    let dates = [now] + snapshot.boundaries(after: now).prefix(40)
    let entries = dates.map { SnapshotEntry(date: $0, snapshot: snapshot) }
    // A backstop: the app's daily refresh reloads us anyway.
    let refresh = Calendar.current.date(byAdding: .hour, value: 6, to: now)!
    completion(Timeline(entries: entries, policy: .after(refresh)))
  }
}

struct NextUpWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "NextUpWidget", provider: SnapshotProvider()) { entry in
      NextUpView(entry: entry).dotBackground()
    }
    .configurationDisplayName("Next up")
    .description("The task under way, or the next one.")
    .supportedFamilies([.systemSmall, .accessoryRectangular])
  }
}

struct TodayWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "TodayWidget", provider: SnapshotProvider()) { entry in
      TodayView(entry: entry).dotBackground()
    }
    .configurationDisplayName("Today")
    .description("What is left of your day, as dots.")
    .supportedFamilies([.systemMedium, .systemLarge])
  }
}

struct InboxWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "InboxWidget", provider: SnapshotProvider()) { entry in
      InboxView(entry: entry).dotBackground()
    }
    .configurationDisplayName("Inbox")
    .description("How many tasks wait for a time.")
    .supportedFamilies([.systemSmall])
  }
}
