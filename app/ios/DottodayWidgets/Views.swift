import SwiftUI
import WidgetKit

// The widgets in Concept E (E-R2-17, E-R2-17-Dark; ED-309, M20.9 part 3):
// now is a ring in the task colour that fills with time used, ahead a
// hollow dot on the thread, done filled; the day dot in each header. The
// states the board doesn't draw follow the approved drawing (ED-471).

extension View {
  /// The widget card on iOS 17+ (containerBackground), else a fill.
  @ViewBuilder func dotBackground() -> some View {
    if #available(iOS 17.0, *) {
      containerBackground(DotE.card, for: .widget)
    } else {
      padding().background(DotE.card)
    }
  }
}

/// A ring: [frac] of it in [color] over a faint track of the same colour.
struct Ring: View {
  let color: Color
  var frac: Double = 1
  var size: CGFloat
  var line: CGFloat
  var track: Double = 0.2

  var body: some View {
    ZStack {
      Circle().stroke(color.opacity(track), lineWidth: line)
      Circle().trim(from: 0, to: max(0.04, min(1, frac)))
        .stroke(color, style: StrokeStyle(lineWidth: line, lineCap: .round))
        .rotationEffect(.degrees(-90))
    }
    .padding(line / 2)
    .frame(width: size, height: size)
    .accessibilityHidden(true)
  }
}

/// The day dot in a header (docs/15 W6): the day so far in the App colour
/// round a faint ring, its centre dot.
struct DayDotView: View {
  let snapshot: Snapshot
  let date: Date
  var size: CGFloat = 14

  var body: some View {
    let dot = snapshot.dayDot(at: date)
    ZStack {
      Ring(color: snapshot.accentDot, frac: dot.filled, size: size, line: size * 0.2, track: 0.15)
      Circle().fill(snapshot.accentDot).frame(width: size * 0.29, height: size * 0.29)
    }
    .accessibilityHidden(true)
  }
}

/// A task's mark: the now ring, a hollow dot ahead, a filled one when
/// done; your one thing gets a thin ring in the App colour round it.
struct TaskMark: View {
  let block: WidgetBlock
  let snapshot: Snapshot
  let date: Date
  var size: CGFloat = 14

  var body: some View {
    let live = !block.done && block.start <= date && date < block.end
    Group {
      if live {
        Ring(color: block.tint, frac: used, size: size + 2, line: 3)
      } else if block.done {
        Circle().fill(block.tint).frame(width: size, height: size)
      } else {
        Circle().fill(DotE.card).frame(width: size, height: size)
          .overlay(Circle().strokeBorder(block.tint, lineWidth: 2.5))
      }
    }
    .overlay {
      if block.isOneThing {
        Circle().stroke(snapshot.accentDot, lineWidth: 1.5).padding(-3.5)
      }
    }
    .accessibilityHidden(true)
  }

  private var used: Double {
    let span = block.end.timeIntervalSince(block.start)
    return span > 0 ? date.timeIntervalSince(block.start) / span : 0
  }
}

/// A header: the day dot (or [glyph]) and the caption, [trailing] at the end.
struct WidgetHeader: View {
  let snapshot: Snapshot
  let date: Date
  let title: String
  var glyph: String? = nil
  var trailing: String = ""

  var body: some View {
    HStack(spacing: 6) {
      if let glyph {
        Image(systemName: glyph).font(.system(size: 13, weight: .semibold))
          .foregroundStyle(snapshot.accentDot).accessibilityHidden(true)
      } else {
        DayDotView(snapshot: snapshot, date: date)
      }
      Text(title.uppercased()).font(Manrope.font(11, .heavy)).tracking(0.8)
        .foregroundStyle(DotE.muted)
      Spacer(minLength: 4)
      Text(trailing).font(Manrope.font(12, .semibold)).foregroundStyle(DotE.muted)
    }
  }
}

/// Next up's Done (iOS 17+, docs/09 M9.5): the B6 MarkDone intent, which
/// queues for the app and ticks the dot on the snapshot at once.
struct DoneButton: View {
  let block: WidgetBlock
  let label: String

  var body: some View {
    if #available(iOS 17.0, *) {
      Button(intent: MarkDoneIntent(occurrenceId: block.id)) {
        Image(systemName: "checkmark").font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
          .frame(width: 38, height: 38).background(Circle().fill(block.tint))
      }
      .buttonStyle(.plain)
      .accessibilityLabel(label)
    }
  }
}

func link(_ path: String) -> URL { URL(string: "dottoday://\(path)")! }

struct NextUpView: View {
  let entry: SnapshotEntry
  @Environment(\.widgetFamily) private var family

  var body: some View {
    let s = entry.snapshot
    let live = s.live(at: entry.date)
    let block = live ?? s.next(at: entry.date)
    let label = live != nil ? s.label("now") : s.label("next_up")
    Group {
      if family == .accessoryRectangular {
        LockNextUp(snapshot: s, date: entry.date, label: label, block: block, live: live != nil)
      } else {
        VStack(alignment: .leading, spacing: 8) {
          WidgetHeader(snapshot: s, date: entry.date, title: label)
          if let block {
            HStack(alignment: .top, spacing: 8) {
              TaskMark(block: block, snapshot: s, date: entry.date, size: live != nil ? 20 : 14)
                .frame(width: 22, height: 22)
              VStack(alignment: .leading, spacing: 2) {
                Text(block.title).font(Manrope.font(15, .heavy)).foregroundStyle(DotE.ink).lineLimit(3)
                if block.isOneThing {
                  Text(s.label("one_thing")).font(Manrope.font(12, .semibold)).foregroundStyle(DotE.muted)
                }
              }
            }
            Spacer(minLength: 0)
            HStack(alignment: .bottom) {
              Text(live != nil ? block.until : block.time)
                .font(Manrope.font(12, .semibold)).foregroundStyle(DotE.muted)
              Spacer(minLength: 4)
              // Done only while it is under way (ED-471).
              if live != nil { DoneButton(block: block, label: s.label("done")) }
            }
          } else {
            Text(s.label("nothing_next")).font(Manrope.font(15, .bold)).foregroundStyle(DotE.muted)
            Spacer(minLength: 0)
          }
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .widgetURL(block.map { link("task/\($0.id)") } ?? link("today"))
  }
}

/// Next up on the Lock Screen (E-R2-17): the system's type, tinted by iOS;
/// a small ring, the caption, the title and when.
struct LockNextUp: View {
  let snapshot: Snapshot
  let date: Date
  let label: String
  let block: WidgetBlock?
  let live: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack(spacing: 5) {
        Ring(color: .primary, frac: snapshot.dayDot(at: date).filled, size: 13, line: 2.6, track: 0.35)
        Text(label.uppercased()).font(.system(size: 11, weight: .semibold))
      }
      .opacity(0.8)
      Text(block?.title ?? snapshot.label("nothing_next")).font(.system(size: 15, weight: .bold)).lineLimit(1)
      if let block {
        Text(live ? block.until : block.time).font(.system(size: 13, weight: .medium)).opacity(0.8)
      }
    }
  }
}

struct TodayView: View {
  let entry: SnapshotEntry
  @Environment(\.widgetFamily) private var family

  var body: some View {
    let s = entry.snapshot
    let large = family == .systemLarge
    let ahead = Array(s.ahead(at: entry.date).prefix(large ? 6 : 4))
    VStack(alignment: .leading, spacing: 8) {
      WidgetHeader(snapshot: s, date: entry.date, title: s.label("today"), trailing: s.doneOf)
      if ahead.isEmpty {
        Text(s.label("nothing_next")).font(Manrope.font(15, .bold)).foregroundStyle(DotE.muted)
      } else {
        VStack(alignment: .leading, spacing: large ? 6 : 0) {
          ForEach(ahead) { block in
            TodayRow(block: block, snapshot: s, date: entry.date).frame(height: large ? 30 : 24)
          }
        }
        // The thread behind the dots, from the first to the last.
        .background(alignment: .topLeading) {
          GeometryReader { box in
            let inset: CGFloat = large ? 15 : 12
            Capsule().fill(DotE.thread)
              .frame(width: 2, height: max(0, box.size.height - inset * 2))
              .offset(x: 7, y: inset)
          }
        }
      }
      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .widgetURL(link("today"))
  }
}

/// One row of Today: the mark, "Now" or the time, the title.
struct TodayRow: View {
  let block: WidgetBlock
  let snapshot: Snapshot
  let date: Date

  var body: some View {
    let now = !block.done && block.start <= date && date < block.end
    Link(destination: link("task/\(block.id)")) {
      HStack(spacing: 10) {
        TaskMark(block: block, snapshot: snapshot, date: date).frame(width: 16)
        Text(now ? snapshot.label("now") : block.time)
          .font(Manrope.font(12, now ? .heavy : .semibold))
          .foregroundStyle(now ? snapshot.accentText : DotE.muted)
          .frame(width: 62, alignment: .leading)
        Text(block.title).font(Manrope.font(14, now ? .heavy : .semibold))
          .foregroundStyle(block.done ? DotE.muted : DotE.ink).lineLimit(1)
        if block.isOneThing {
          Text(snapshot.label("one_thing")).font(Manrope.font(12, .semibold))
            .foregroundStyle(DotE.muted).lineLimit(1).layoutPriority(-1)
        }
        Spacer(minLength: 0)
      }
    }
  }
}

struct InboxView: View {
  let entry: SnapshotEntry

  var body: some View {
    let s = entry.snapshot
    VStack(alignment: .leading, spacing: 4) {
      WidgetHeader(snapshot: s, date: entry.date, title: s.label("inbox_title"), glyph: "tray")
      Spacer(minLength: 0)
      Text("\(s.inboxCount)").font(Manrope.font(40, .heavy)).foregroundStyle(DotE.ink)
      Text(s.label("inbox")).font(Manrope.font(13, .semibold)).foregroundStyle(DotE.muted)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .widgetURL(link("inbox"))
  }
}
