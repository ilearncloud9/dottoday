import ActivityKit
import SwiftUI
import WidgetKit

/// The live dot on the lock screen and in the Dynamic Island (docs/09
/// M9.3, B-ios-live-activity.png). Layouts live in
/// ios/Shared/LiveActivityViews.swift; this places them.
@available(iOS 16.2, *)
struct DotLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: DotActivityAttributes.self) { context in
      LiveLockScreenView(state: context.state)
        .activityBackgroundTint(Dot.surface)
        .widgetURL(URL(string: "dottoday://task/\(context.state.id)"))
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          LiveRing(state: context.state, size: 44).padding(.leading, 4)
        }
        DynamicIslandExpandedRegion(.center) {
          LiveIslandText(state: context.state)
        }
        DynamicIslandExpandedRegion(.trailing) {
          LiveIslandButtons(state: context.state)
        }
      } compactLeading: {
        LiveRing(state: context.state, size: 22)
      } compactTrailing: {
        Text(
          timerInterval: Date()...max(Date(), context.state.live ? context.state.end : context.state.start),
          countsDown: true, showsHours: false
        )
        .monospacedDigit().font(.caption.weight(.semibold))
        .foregroundStyle(Color(hex: context.state.color)).frame(width: 44)
      } minimal: {
        LiveRing(state: context.state, size: 22)
      }
      .widgetURL(URL(string: "dottoday://task/\(context.state.id)"))
      .keylineTint(Color(hex: context.state.color))
    }
  }
}
