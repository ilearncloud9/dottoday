import AppIntents
import SwiftUI

// The Live Activity's layouts (docs/09 M9.3, B-ios-live-activity.png):
// lock screen card, Dynamic Island expanded, compact and minimal. Plain
// SwiftUI on [LiveDotState], compiled into the app too so RunnerTests can
// render them. `frozenAt` stops the clock for those renders; on a device
// it is nil and the system counts down without updates.

/// The dot's ring: elapsed share of its time, icon inside.
struct LiveRing: View {
  let state: LiveDotState
  var size: CGFloat = 44
  var now = Date()

  private var share: Double {
    guard state.live, state.end > state.start else { return 0 }
    return min(1, max(0, now.timeIntervalSince(state.start) / state.end.timeIntervalSince(state.start)))
  }

  var body: some View {
    let color = Color(hex: state.color)
    ZStack {
      Circle().stroke(color.opacity(0.25), lineWidth: size * 0.11)
      Circle().trim(from: 0, to: share)
        .stroke(color, style: StrokeStyle(lineWidth: size * 0.11, lineCap: .round))
        .rotationEffect(.degrees(-90))
      if let symbol = TaskSymbols.symbol(state.icon) {
        Image(systemName: symbol).font(.system(size: size * 0.32, weight: .semibold))
          .foregroundStyle(color)
      } else {
        Circle().fill(color).frame(width: size * 0.3, height: size * 0.3)
      }
    }
    .frame(width: size, height: size)
    .accessibilityHidden(true)
  }
}

/// "38:00 left" / "noch 38:00" / "starts in 12:00", counting down live.
struct LiveCountdown: View {
  let state: LiveDotState
  var frozenAt: Date?

  var body: some View {
    let now = frozenAt ?? Date()
    let target = state.live ? state.end : state.start
    let range = now...max(now, target)
    HStack(spacing: 0) {
      Text(state.live ? state.leftBefore : state.startsBefore)
      LiveTimer(range: range, frozen: frozenAt != nil)
      Text(state.live ? state.leftAfter : state.startsAfter)
    }
  }
}

/// A countdown the system draws; frozen (tests, previews) it is plain text,
/// because an offscreen render can't draw a live timer.
struct LiveTimer: View {
  let range: ClosedRange<Date>
  var frozen = false

  var body: some View {
    if frozen {
      let seconds = Int(range.upperBound.timeIntervalSince(range.lowerBound))
      Text(String(format: "%d:%02d", seconds / 60, seconds % 60)).monospacedDigit()
    } else {
      Text(timerInterval: range, countsDown: true, showsHours: false).monospacedDigit()
    }
  }
}

/// The mini thread: done part solid, the knob at now, the rest dotted
/// (B-ios-live-activity.png). Drawn for a frozen moment; live, the system's
/// own timer-driven progress bar moves on by itself.
struct ThreadBar: View {
  let share: Double
  let color: Color

  var body: some View {
    GeometryReader { geo in
      let x = geo.size.width * share
      ZStack(alignment: .leading) {
        Path { p in
          p.move(to: CGPoint(x: x, y: geo.size.height / 2))
          p.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height / 2))
        }
        .stroke(color.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [2, 3]))
        Capsule().fill(color).frame(width: x, height: 4)
        Circle().fill(color).frame(width: 14, height: 14)
          .overlay(Circle().stroke(color.opacity(0.35), lineWidth: 5))
          .offset(x: x - 7)
      }
      .frame(height: geo.size.height)
    }
    .frame(height: 16)
  }
}

/// The small pie and "1 of 3" (today's dots done).
struct LiveCount: View {
  let state: LiveDotState

  var body: some View {
    if !state.count.isEmpty { pieAndCount }
  }

  private var pieAndCount: some View {
    HStack(spacing: 6) {
      ZStack {
        Circle().fill(Dot.muted.opacity(0.3))
        PieSlice(share: state.doneShare).fill(Color(hex: state.color))
      }
      .frame(width: 14, height: 14)
      Text(state.count).foregroundStyle(Dot.muted)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(state.countLabel)
  }
}

struct PieSlice: Shape {
  let share: Double

  func path(in rect: CGRect) -> Path {
    var path = Path()
    let center = CGPoint(x: rect.midX, y: rect.midY)
    path.move(to: center)
    path.addArc(
      center: center, radius: rect.width / 2, startAngle: .degrees(-90),
      endAngle: .degrees(-90 + 360 * share), clockwise: false)
    path.closeSubpath()
    return path
  }
}

/// Done and +15: B6 intents on iOS 17+, else a link into the task.
struct LiveButton<Label: View>: View {
  enum Kind { case done, plus }
  let kind: Kind
  let state: LiveDotState
  @ViewBuilder let label: () -> Label

  var body: some View {
    if #available(iOS 17.0, *) {
      switch kind {
      case .done:
        Button(intent: LiveMarkDoneIntent(occurrenceId: state.id), label: label).buttonStyle(.plain)
      case .plus:
        Button(
          intent: LiveAddFifteenIntent(occurrenceId: state.id, plannedEndMs: Int(state.endMs)),
          label: label
        ).buttonStyle(.plain)
      }
    } else {
      Link(destination: URL(string: "dottoday://task/\(state.id)")!, label: label)
    }
  }
}

/// The lock-screen card: thread, dot, Done and +15.
struct LiveLockScreenView: View {
  let state: LiveDotState
  var frozenAt: Date?

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      thread
      HStack(spacing: 12) {
        LiveRing(state: state, size: 44, now: frozenAt ?? Date())
        VStack(alignment: .leading, spacing: 2) {
          Text(state.title).font(.headline).foregroundStyle(Dot.ink).lineLimit(1)
          HStack(spacing: 0) {
            Text(state.range + " · ").foregroundStyle(Dot.muted)
            LiveCountdown(state: state, frozenAt: frozenAt).foregroundStyle(Dot.ink)
          }
          .font(.subheadline)
        }
        Spacer(minLength: 4)
        LiveCount(state: state).font(.subheadline)
      }
      HStack(spacing: 12) {
        LiveButton(kind: .done, state: state) {
          Label(state.doneLabel, systemImage: "checkmark")
            .font(.headline).frame(maxWidth: .infinity, minHeight: 44)
            .background(Capsule().fill(Color(hex: state.color))).foregroundStyle(.white)
        }
        .accessibilityLabel(state.doneLabel)
        LiveButton(kind: .plus, state: state) {
          Text(state.plusLabel).font(.headline).frame(maxWidth: .infinity, minHeight: 44)
            .background(Capsule().fill(Dot.secondary)).foregroundStyle(Dot.ink)
        }
        .accessibilityLabel(state.plusLabel)
      }
    }
    .padding(16)
  }

  @ViewBuilder private var thread: some View {
    HStack(spacing: 8) {
      if let frozenAt {
        ThreadBar(share: share(at: frozenAt), color: Color(hex: state.color))
      } else {
        ProgressView(timerInterval: state.start...max(state.start, state.end), countsDown: false) {
          EmptyView()
        } currentValueLabel: {
          EmptyView()
        }
        .tint(Color(hex: state.color))
      }
      if let next = state.next.first {
        Circle().stroke(Dot.muted, lineWidth: 1.5).frame(width: 9, height: 9)
        Text("\(next.title) · \(next.time)").font(.caption).foregroundStyle(Dot.muted).lineLimit(1)
      }
    }
    .accessibilityHidden(true)
  }

  private func share(at now: Date) -> Double {
    guard state.live, state.end > state.start else { return 0 }
    return min(1, max(0, now.timeIntervalSince(state.start) / state.end.timeIntervalSince(state.start)))
  }
}

/// Dynamic Island, expanded: centre text.
struct LiveIslandText: View {
  let state: LiveDotState
  var frozenAt: Date?

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(state.title).font(.headline).foregroundStyle(.white).lineLimit(1)
        .minimumScaleFactor(0.8)
      HStack(spacing: 0) {
        LiveCountdown(state: state, frozenAt: frozenAt)
        if !state.count.isEmpty {
          Text(" · " + state.count).accessibilityLabel(state.countLabel)
        }
      }
      .font(.subheadline).foregroundStyle(Color(white: 0.65))
    }
  }
}

/// Dynamic Island, expanded: the round Done and +15 buttons.
struct LiveIslandButtons: View {
  let state: LiveDotState

  var body: some View {
    HStack(spacing: 8) {
      LiveButton(kind: .done, state: state) {
        Image(systemName: "checkmark").font(.headline).foregroundStyle(.white)
          .frame(width: 44, height: 44).background(Circle().fill(Color(hex: state.color)))
      }
      .accessibilityLabel(state.doneLabel)
      LiveButton(kind: .plus, state: state) {
        Text(state.plusShort).font(.subheadline.weight(.semibold)).foregroundStyle(.white)
          .frame(width: 44, height: 44).background(Circle().fill(Color(white: 0.2)))
      }
      .accessibilityLabel(state.plusLabel)
    }
  }
}

/// The expanded island as one row, for previews and RunnerTests (the
/// extension places the same parts in the island's regions).
struct LiveIslandExpandedPreview: View {
  let state: LiveDotState
  var frozenAt: Date?

  var body: some View {
    HStack(spacing: 12) {
      LiveRing(state: state, size: 44, now: frozenAt ?? Date())
      LiveIslandText(state: state, frozenAt: frozenAt)
      Spacer(minLength: 4)
      LiveIslandButtons(state: state)
    }
    .padding(18)
    .background(Capsule().fill(.black))
  }
}

/// Compact: ring on the left, countdown on the right; minimal: the ring.
struct LiveIslandCompactPreview: View {
  let state: LiveDotState
  var frozenAt: Date?

  var body: some View {
    HStack {
      LiveRing(state: state, size: 22, now: frozenAt ?? Date())
      Spacer(minLength: 40)
      LiveTimer(
        range: (frozenAt ?? Date())...max(frozenAt ?? Date(), state.live ? state.end : state.start),
        frozen: frozenAt != nil
      )
      .font(.caption.weight(.semibold)).foregroundStyle(Color(hex: state.color))
      .frame(width: 48, alignment: .trailing)
    }
    .padding(.horizontal, 14).padding(.vertical, 8)
    .background(Capsule().fill(.black))
  }
}
