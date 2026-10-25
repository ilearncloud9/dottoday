import SwiftUI
import WidgetKit

extension View {
  /// The widget background on iOS 17+ (containerBackground), else a fill.
  @ViewBuilder func dotBackground() -> some View {
    if #available(iOS 17.0, *) {
      containerBackground(Dot.surface, for: .widget)
    } else {
      padding().background(Dot.surface)
    }
  }
}

struct TaskDot: View {
  let block: WidgetBlock
  var size: CGFloat = 10
  var body: some View {
    Circle()
      .fill(block.done ? Dot.hairline : Color(hex: block.color))
      .frame(width: size, height: size)
      .accessibilityHidden(true)
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
        Image(systemName: "checkmark").font(.subheadline.weight(.bold)).foregroundStyle(.white)
          .frame(width: 36, height: 36).background(Circle().fill(Color(hex: block.color)))
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
    VStack(alignment: .leading, spacing: 6) {
      Text((live != nil ? s.label("now") : s.label("next_up")).uppercased())
        .font(.caption2.weight(.semibold)).foregroundStyle(Dot.muted)
      if let block {
        HStack(spacing: 6) {
          TaskDot(block: block, size: 12)
          Text(block.title).font(.headline).foregroundStyle(Dot.ink).lineLimit(2)
        }
        HStack(alignment: .bottom) {
          Text(live != nil ? block.until : block.time)
            .font(.caption).foregroundStyle(Dot.muted)
          Spacer(minLength: 4)
          if family == .systemSmall { DoneButton(block: block, label: s.label("done")) }
        }
      } else {
        Text(s.label("nothing_next")).font(.caption).foregroundStyle(Dot.muted)
      }
      if family != .accessoryRectangular { Spacer(minLength: 0) }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .widgetURL(block.map { link("task/\($0.id)") } ?? link("today"))
  }
}

struct TodayView: View {
  let entry: SnapshotEntry
  @Environment(\.widgetFamily) private var family

  var body: some View {
    let s = entry.snapshot
    let rows = family == .systemLarge ? 9 : 4
    let ahead = Array(s.ahead(at: entry.date).prefix(rows))
    VStack(alignment: .leading, spacing: 6) {
      Text(s.label("today").uppercased())
        .font(.caption2.weight(.semibold)).foregroundStyle(Dot.muted)
      if ahead.isEmpty {
        Text(s.label("nothing_next")).font(.caption).foregroundStyle(Dot.muted)
      }
      ForEach(ahead) { block in
        Link(destination: link("task/\(block.id)")) {
          HStack(spacing: 8) {
            TaskDot(block: block)
            Text(block.start <= entry.date && !block.done ? s.label("now") : block.time)
              .font(.caption).foregroundStyle(Dot.muted).frame(width: 64, alignment: .leading)
            Text(block.title).font(.subheadline.weight(.medium))
              .foregroundStyle(block.done ? Dot.muted : Dot.ink)
              .strikethrough(block.done).lineLimit(1)
          }
        }
      }
      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .widgetURL(link("today"))
  }
}

struct InboxView: View {
  let entry: SnapshotEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("\(entry.snapshot.inboxCount)")
        .font(.system(size: 34, weight: .bold)).foregroundStyle(Dot.ink)
      Text(entry.snapshot.label("inbox")).font(.caption).foregroundStyle(Dot.muted)
      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .widgetURL(link("inbox"))
  }
}
