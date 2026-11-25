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
      LiveLockScreenCard(state: context.state)
        .widgetURL(URL(string: "dottoday://task/\(context.state.id)"))
    } dynamicIsland: { context in
      DynamicIsland {
        // One full-width row under the camera, as E-R2-17 draws it: the
        // centre beside the camera is too narrow for the title.
        DynamicIslandExpandedRegion(.bottom) {
          HStack(spacing: 12) {
            LiveIslandRing(state: context.state, size: 40)
            LiveIslandText(state: context.state)
            Spacer(minLength: 0)
            LiveIslandButtons(state: context.state)
          }
          .padding(.horizontal, 6)
        }
      } compactLeading: {
        LiveIslandRing(state: context.state, size: 20)
      } compactTrailing: {
        Text(
          timerInterval: Date()...max(Date(), context.state.live ? context.state.end : context.state.start),
          countsDown: true, showsHours: false
        )
        .monospacedDigit().font(.system(size: 14, weight: .bold))
        .foregroundStyle(Color(hex: LivePalette.island(context.state).dot)).frame(width: 48)
      } minimal: {
        LiveIslandRing(state: context.state, size: 20)
      }
      .widgetURL(URL(string: "dottoday://task/\(context.state.id)"))
      .keylineTint(Color(hex: LivePalette.island(context.state).dot))
    }
  }
}

/// The Lock Screen card, with the card's own fill: the Lock Screen
/// can keep its light material under a dark scheme, so the card paints its
/// background in the colours its words were picked for (the old card's
/// white-on-white title, M20.9 part 4).
@available(iOS 16.2, *)
struct LiveLockScreenCard: View {
  let state: LiveDotState
  var frozenAt: Date?
  @Environment(\.colorScheme) private var scheme

  var body: some View {
    let p = LivePalette.of(state, dark: scheme == .dark)
    LiveLockScreenView(state: state, frozenAt: frozenAt)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(p.cardSolid)
      .activityBackgroundTint(p.cardSolid)
  }
}

