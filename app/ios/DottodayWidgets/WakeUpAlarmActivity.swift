import SwiftUI
import WidgetKit

#if canImport(AlarmKit)
  import AlarmKit

  /// A snoozed Wake Up alarm's countdown on the Lock Screen and in the
  /// Dynamic Island (docs/15 W1b; derived, no reference render): what the
  /// day starts with and the minutes left, the moon of the night still on.
  /// AlarmKit shows the ringing alert itself.
  @available(iOS 26.0, *)
  struct WakeUpAlarmActivity: Widget {
    var body: some WidgetConfiguration {
      ActivityConfiguration(for: AlarmAttributes<WakeUpMetadata>.self) { context in
        HStack(spacing: 12) {
          Image(systemName: "moon.zzz.fill").font(.title2).foregroundStyle(Dot.accent)
          VStack(alignment: .leading, spacing: 2) {
            Text(context.attributes.metadata?.title ?? "")
              .font(.headline).foregroundStyle(Dot.ink).lineLimit(1)
            WakeUpCountdown(state: context.state).font(.title2.weight(.semibold))
          }
          Spacer(minLength: 0)
        }
        .padding()
        .activityBackgroundTint(Dot.surface)
      } dynamicIsland: { context in
        DynamicIsland {
          DynamicIslandExpandedRegion(.leading) {
            Image(systemName: "moon.zzz.fill").foregroundStyle(Dot.accent)
          }
          DynamicIslandExpandedRegion(.center) {
            Text(context.attributes.metadata?.title ?? "").lineLimit(1)
          }
          DynamicIslandExpandedRegion(.trailing) {
            WakeUpCountdown(state: context.state).frame(width: 64)
          }
        } compactLeading: {
          Image(systemName: "moon.zzz.fill").foregroundStyle(Dot.accent)
        } compactTrailing: {
          WakeUpCountdown(state: context.state).frame(width: 44)
        } minimal: {
          Image(systemName: "moon.zzz.fill").foregroundStyle(Dot.accent)
        }
        .keylineTint(Dot.accent)
      }
    }
  }

  /// Minutes and seconds to the next ring, or nothing while it rings.
  @available(iOS 26.0, *)
  private struct WakeUpCountdown: View {
    let state: AlarmPresentationState

    var body: some View {
      if case .countdown(let countdown) = state.mode {
        Text(timerInterval: Date()...max(Date(), countdown.fireDate), countsDown: true, showsHours: false)
          .monospacedDigit()
      }
    }
  }
#endif
