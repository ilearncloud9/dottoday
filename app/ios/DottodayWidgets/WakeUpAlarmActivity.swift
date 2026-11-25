import SwiftUI
import WidgetKit

#if canImport(AlarmKit)
  import AlarmKit

  /// A snoozed Wake Up alarm as a Live Activity at dawn (E-R2-19-B
  /// "2 · Snoozed: the countdown, at dawn", E-R2-19-B-Dark; ED-314, ED-464):
  /// on the Lock Screen (and in StandBy, which enlarges it) the dawn card
  /// with the countdown inside the day dot, "Wake Up", Snooze and what the
  /// day starts with; in the Dynamic Island the sun and the time left. While
  /// it rings again the sun takes the countdown's place. Apple Watch's Smart
  /// Stack gets the small card. AlarmKit shows the ringing alert itself.
  @available(iOS 26.0, *)
  struct WakeUpAlarmActivity: Widget {
    var body: some WidgetConfiguration {
      ActivityConfiguration(for: AlarmAttributes<WakeUpMetadata>.self) { context in
        WakeUpCard(metadata: context.attributes.metadata, state: context.state)
          .activityBackgroundTint(Dawn.top)
          .activitySystemActionForegroundColor(Dawn.ink)
      } dynamicIsland: { context in
        let meta = context.attributes.metadata
        let state = context.state
        return DynamicIsland {
          DynamicIslandExpandedRegion(.leading) {
            DawnDot(arcs: meta?.arcs ?? [], size: 52) { DotCentre(state: state, size: 13) }
              .padding(.leading, 4)
          }
          DynamicIslandExpandedRegion(.center) {
            VStack(alignment: .leading, spacing: 1) {
              Text(meta?.title ?? "").font(Manrope.font(17, .heavy)).lineLimit(1)
              if !state.ringing, let snooze = meta?.snooze {
                Text(snooze).font(Manrope.font(13, .semibold)).opacity(0.7).lineLimit(1)
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
          DynamicIslandExpandedRegion(.trailing) {
            TimeLeft(state: state, large: true).padding(.trailing, 4)
          }
          DynamicIslandExpandedRegion(.bottom) {
            Text(meta?.body ?? "").font(Manrope.font(13, .semibold)).opacity(0.85)
              .lineLimit(1).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 4)
          }
        } compactLeading: {
          SunMark(size: 16)
        } compactTrailing: {
          TimeLeft(state: state, large: false)
        } minimal: {
          SunMark(size: 16)
        }
        .keylineTint(Dawn.sun)
      }
      .supplementalActivityFamilies([.small])
    }
  }

  /// The Lock Screen card, or Apple Watch's small one (ED-464).
  @available(iOS 26.0, *)
  private struct WakeUpCard: View {
    let metadata: WakeUpMetadata?
    let state: AlarmPresentationState
    @Environment(\.activityFamily) private var family

    var body: some View {
      let small = family == .small
      HStack(spacing: small ? 10 : 14) {
        DawnDot(arcs: metadata?.arcs ?? [], size: small ? 46 : 64) {
          DotCentre(state: state, size: small ? 12 : 15)
        }
        VStack(alignment: .leading, spacing: 2) {
          Text(metadata?.title ?? "").font(Manrope.font(small ? 15 : 17, .heavy)).lineLimit(1)
          if !state.ringing, let snooze = metadata?.snooze {
            Text(snooze).font(Manrope.font(small ? 12 : 13, .semibold)).opacity(0.85).lineLimit(1)
          }
          if !small || state.ringing {
            Text(metadata?.body ?? "").font(Manrope.font(small ? 12 : 13, .semibold)).opacity(0.85)
              .lineLimit(small ? 1 : 2)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .foregroundStyle(Dawn.ink)
      .padding(small ? 10 : 16)
      .background(Dawn.gradient)
    }
  }

  /// The countdown inside the day dot, or the sun while it rings again.
  @available(iOS 26.0, *)
  private struct DotCentre: View {
    let state: AlarmPresentationState
    let size: CGFloat

    var body: some View {
      if case .countdown(let countdown) = state.mode {
        Text(timerInterval: Date()...max(Date(), countdown.fireDate), countsDown: true, showsHours: false)
          .font(Manrope.font(size, .heavy)).monospacedDigit().foregroundStyle(Dawn.ink)
          .multilineTextAlignment(.center).frame(width: size * 3.4)
      } else {
        Image(systemName: "sun.max").font(.system(size: size * 1.4, weight: .semibold))
          .foregroundStyle(Dawn.ink)
      }
    }
  }

  /// The time left in sun-yellow (the board's compact view); while it rings
  /// again, the time it rang (ED-464).
  @available(iOS 26.0, *)
  private struct TimeLeft: View {
    let state: AlarmPresentationState
    let large: Bool

    var body: some View {
      Group {
        switch state.mode {
        case .countdown(let countdown):
          Text(timerInterval: Date()...max(Date(), countdown.fireDate), countsDown: true, showsHours: false)
            .font(.system(size: large ? 28 : 14, weight: .bold)).frame(width: large ? 84 : 44)
        case .alert(let alert):
          Text(rang(alert.time)).font(.system(size: 15, weight: .bold))
        default:
          EmptyView()
        }
      }
      .monospacedDigit().foregroundStyle(Dawn.sun)
    }

    private func rang(_ time: Alarm.Schedule.Relative.Time) -> String {
      let date = Calendar.current.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: Date()) ?? Date()
      return date.formatted(date: .omitted, time: .shortened)
    }
  }

  /// The day dot (E-R2-19-B): a faint track, the day's dots round the 24
  /// hours from Wake Up in their colours at 55 %, the sun at Wake Up at the
  /// top, and [centre] inside. No dots: the track and the sun (ED-459).
  struct DawnDot<Centre: View>: View {
    let arcs: [WakeUpArc]
    let size: CGFloat
    @ViewBuilder let centre: () -> Centre
    @Environment(\.colorScheme) private var scheme

    var body: some View {
      // The board's 64 box: radius 28, stroke 4, sun 5.6.
      let k = size / 64
      let line = 4 * k
      ZStack {
        Circle().inset(by: 4 * k).stroke(Dawn.track, lineWidth: line)
        ForEach(arcs, id: \.self) { arc in
          Circle().inset(by: 4 * k)
            .trim(from: arc.from + 0.8 / 360, to: max(arc.to - 0.8 / 360, arc.from + 1.3 / 360))
            .stroke(colour(arc).opacity(0.55), style: StrokeStyle(lineWidth: line, lineCap: .round))
            .rotationEffect(.degrees(-90))
        }
        Circle().fill(Dawn.sun).overlay(Circle().stroke(Dawn.ink, lineWidth: 2))
          .frame(width: 11.2 * k, height: 11.2 * k).offset(y: -28 * k)
        centre()
      }
      .frame(width: size, height: size)
    }

    private func colour(_ arc: WakeUpArc) -> Color {
      let rgb = scheme == .dark ? arc.dark : arc.light
      return Color(UIColor(rgb: rgb & 0xFF_FFFF))
    }
  }

  @available(iOS 26.0, *)
  extension AlarmPresentationState {
    /// Ringing again: AlarmKit's alert is up, so there is no time left.
    var ringing: Bool {
      if case .alert = mode { return true }
      return false
    }
  }
#endif

/// The sun at Wake Up (E-R2-19-B's island mark), in sun-yellow.
struct SunMark: View {
  let size: CGFloat

  var body: some View {
    Image(systemName: "sun.max").font(.system(size: size, weight: .semibold)).foregroundStyle(Dawn.sun)
  }
}
