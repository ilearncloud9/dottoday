import AppIntents
import SwiftUI

// The Live Activity in Concept E (E-R2-17, E-R2-17-Dark; ED-309, M20.9
// part 4, the approved drawing ED-472): the Lock Screen card and the
// Dynamic Island, expanded, compact and minimal. The ring, bar, countdown
// and tick follow the App colour; the tick and +15 sit beside the title.
// Plain SwiftUI on [LiveDotState], compiled into the app too so
// RunnerTests can render them. `frozenAt` stops the clock for those
// renders; on a device it is nil and the system counts down by itself.

/// The colours of one appearance, picked once from the colour scheme, so
/// the card and its words never resolve light and dark apart (the old
/// card's white-on-white title).
struct LivePalette {
  let card: Color
  let ink: Color
  let muted: Color
  let plus: Color
  let tone: AppTone

  static func of(_ state: LiveDotState, dark: Bool) -> LivePalette {
    LivePalette(
      card: Color(UIColor(rgb: dark ? 0x2B262A : 0xFFFDF9)),
      ink: Color(UIColor(rgb: dark ? 0xF3ECE4 : 0x241F2B)),
      muted: Color(UIColor(rgb: dark ? 0xC7BEC4 : 0x6A6273)),
      plus: Color(UIColor(rgb: dark ? 0x37313A : 0xECE5DC)),
      tone: (state.accent ?? .teal).tone(dark))
  }

  /// The island is always black: the App colour's bright (dark) tones.
  static func island(_ state: LiveDotState) -> AppTone { (state.accent ?? .teal).tone(true) }

  /// The card without the board's see-through, for the Lock Screen.
  var cardSolid: Color { card }

  var dot: Color { Color(hex: tone.dot) }
  var fill: Color { Color(hex: tone.fill ?? tone.dot) }
  var on: Color { Color(hex: tone.on ?? "#FFFFFF") }
}

/// The ring: the time used of the task in [color]; before it starts, the
/// task's hollow dot (ahead).
struct LiveRing: View {
  let state: LiveDotState
  let color: Color
  var size: CGFloat = 44
  var now = Date()
  var track = 0.2

  private var share: Double {
    guard state.live, state.end > state.start else { return 0 }
    return min(1, max(0, now.timeIntervalSince(state.start) / state.end.timeIntervalSince(state.start)))
  }

  var body: some View {
    let line = size * 0.11
    Group {
      if state.live {
        ZStack {
          Circle().stroke(color.opacity(track), lineWidth: line)
          Circle().trim(from: 0, to: max(0.03, share))
            .stroke(color, style: StrokeStyle(lineWidth: line, lineCap: .round))
            .rotationEffect(.degrees(-90))
        }
      } else {
        Circle().stroke(color, lineWidth: line * 0.6)
      }
    }
    .padding(line / 2)
    .frame(width: size, height: size)
    .accessibilityHidden(true)
  }
}

/// "18:00 left" / "noch 18:00" / "starts in 12:00", counting down live, as
/// one Text: a timer on its own stretches and pushes "left" away.
enum LiveCountdown {
  static func text(_ state: LiveDotState, frozenAt: Date?) -> Text {
    let now = frozenAt ?? Date()
    let target = state.live ? state.end : state.start
    return Text(state.live ? state.leftBefore : state.startsBefore)
      + LiveTimer.text(range: now...max(now, target), frozen: frozenAt != nil)
      + Text(state.live ? state.leftAfter : state.startsAfter)
  }
}

/// A countdown the system draws; frozen (tests, previews) it is plain text,
/// because an offscreen render can't draw a live timer.
enum LiveTimer {
  static func text(range: ClosedRange<Date>, frozen: Bool) -> Text {
    if frozen {
      let seconds = Int(range.upperBound.timeIntervalSince(range.lowerBound))
      return Text(String(format: "%d:%02d", seconds / 60, seconds % 60)).monospacedDigit()
    }
    return Text(timerInterval: range, countsDown: true, showsHours: false).monospacedDigit()
  }
}

/// The bar: the task's time used, plain (E-R2-17). Drawn for a frozen
/// moment; live, the system's timer-driven bar moves on by itself.
struct ThreadBar: View {
  let share: Double
  let color: Color

  var body: some View {
    GeometryReader { geo in
      ZStack(alignment: .leading) {
        Capsule().fill(color.opacity(0.2))
        Capsule().fill(color).frame(width: geo.size.width * share)
      }
    }
    .frame(height: 6)
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

/// The round tick and +15 (44 pt), in [fill] and [plus].
struct LiveRoundButtons: View {
  let state: LiveDotState
  let fill: Color
  let on: Color
  let plus: Color
  let plusInk: Color

  var body: some View {
    HStack(spacing: 6) {
      LiveButton(kind: .done, state: state) {
        Image(systemName: "checkmark").font(.system(size: 17, weight: .bold)).foregroundStyle(on)
          .frame(width: 44, height: 44).background(Circle().fill(fill))
      }
      .accessibilityLabel(state.doneLabel)
      LiveButton(kind: .plus, state: state) {
        Text(state.plusShort).font(Manrope.font(14, .heavy)).foregroundStyle(plusInk)
          .frame(width: 44, height: 44).background(Circle().fill(plus))
      }
      .accessibilityLabel(state.plusLabel)
    }
  }
}

/// The Lock Screen card: the bar and the next task, then the ring, the
/// title, its time and what is left, and the tick and +15.
struct LiveLockScreenView: View {
  let state: LiveDotState
  var frozenAt: Date?
  @Environment(\.colorScheme) private var scheme

  private var palette: LivePalette { .of(state, dark: scheme == .dark) }

  var body: some View {
    let p = palette
    VStack(alignment: .leading, spacing: 14) {
      thread
      HStack(spacing: 10) {
        LiveRing(state: state, color: p.dot, size: 44, now: frozenAt ?? Date())
        VStack(alignment: .leading, spacing: 1) {
          Text(state.title).font(Manrope.font(17, .heavy)).foregroundStyle(p.ink).lineLimit(3).fixedSize(horizontal: false, vertical: true)
          Text(state.range).font(Manrope.font(13, .semibold)).foregroundStyle(p.muted).lineLimit(1)
          (LiveCountdown.text(state, frozenAt: frozenAt).font(Manrope.font(13, .heavy)).foregroundColor(p.ink)
            + Text(state.count.isEmpty ? "" : " · " + state.count).font(Manrope.font(13, .semibold))
            .foregroundColor(p.muted))
            .lineLimit(1)
        }
        Spacer(minLength: 0)
        LiveRoundButtons(state: state, fill: p.fill, on: p.on, plus: p.plus, plusInk: p.ink)
      }
    }
    .padding(16)
  }

  @ViewBuilder private var thread: some View {
    HStack(spacing: 8) {
      if let frozenAt {
        ThreadBar(share: share(at: frozenAt), color: palette.dot)
      } else {
        ProgressView(timerInterval: state.start...max(state.start, state.end), countsDown: false) {
          EmptyView()
        } currentValueLabel: {
          EmptyView()
        }
        .tint(palette.dot)
      }
      if let next = state.next.first {
        Circle().stroke(palette.muted, lineWidth: 1.5).frame(width: 9, height: 9)
        Text("\(next.title) · \(next.time)").font(Manrope.font(12, .semibold))
          .foregroundStyle(palette.muted).lineLimit(1)
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
      Text(state.title).font(.system(size: 16, weight: .bold)).foregroundStyle(.white).lineLimit(3).fixedSize(horizontal: false, vertical: true)
      (LiveCountdown.text(state, frozenAt: frozenAt) + Text(state.count.isEmpty ? "" : " · " + state.count))
        .font(.system(size: 13, weight: .medium)).foregroundStyle(.white.opacity(0.75)).lineLimit(1)
    }
  }
}

/// Dynamic Island, expanded: the round tick and +15.
struct LiveIslandButtons: View {
  let state: LiveDotState

  var body: some View {
    let tone = LivePalette.island(state)
    LiveRoundButtons(
      state: state, fill: Color(hex: tone.fill ?? tone.dot), on: Color(hex: tone.on ?? "#FFFFFF"),
      plus: .white.opacity(0.15), plusInk: .white)
  }
}

/// The island's ring, in the App colour's bright tone.
struct LiveIslandRing: View {
  let state: LiveDotState
  var size: CGFloat
  var now = Date()

  var body: some View {
    LiveRing(state: state, color: Color(hex: LivePalette.island(state).dot), size: size, now: now)
  }
}

/// The expanded island as one row, for previews and RunnerTests (the
/// extension places the same parts in the island's regions).
struct LiveIslandExpandedPreview: View {
  let state: LiveDotState
  var frozenAt: Date?

  var body: some View {
    HStack(spacing: 12) {
      LiveIslandRing(state: state, size: 40, now: frozenAt ?? Date())
      LiveIslandText(state: state, frozenAt: frozenAt)
      Spacer(minLength: 4)
      LiveIslandButtons(state: state)
    }
    .padding(.horizontal, 18).padding(.vertical, 16)
    .background(Capsule().fill(.black))
  }
}

/// Compact: the ring on the left, the countdown on the right, both in the
/// App colour; minimal: the ring.
struct LiveIslandCompactPreview: View {
  let state: LiveDotState
  var frozenAt: Date?

  var body: some View {
    HStack {
      LiveIslandRing(state: state, size: 20, now: frozenAt ?? Date())
      Spacer(minLength: 40)
      LiveTimer.text(
        range: (frozenAt ?? Date())...max(frozenAt ?? Date(), state.live ? state.end : state.start),
        frozen: frozenAt != nil
      )
      .font(.system(size: 14, weight: .bold)).foregroundStyle(Color(hex: LivePalette.island(state).dot))
      .frame(width: 48, alignment: .trailing)
    }
    .padding(.horizontal, 12).padding(.vertical, 8)
    .background(Capsule().fill(.black))
  }
}
