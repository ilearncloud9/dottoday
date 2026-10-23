import Foundation

/// The display snapshot the app writes after every change (docs/09 M5.4,
/// lib/data/widgets/widget_display.dart): strings localised and formatted,
/// colours resolved. The widgets only lay it out.
struct WidgetBlock: Codable, Identifiable {
  let id: String
  let title: String
  let startMs: Double
  let endMs: Double
  let time: String
  let until: String
  let color: String
  let done: Bool

  enum CodingKeys: String, CodingKey {
    case id, title, time, until, color, done
    case startMs = "start_ms"
    case endMs = "end_ms"
  }

  var start: Date { Date(timeIntervalSince1970: startMs / 1000) }
  var end: Date { Date(timeIntervalSince1970: endMs / 1000) }
}

struct Snapshot: Codable {
  let v: Int
  let inboxCount: Int
  let labels: [String: String]
  let blocks: [WidgetBlock]

  enum CodingKeys: String, CodingKey {
    case v, labels, blocks
    case inboxCount = "inbox_count"
  }

  static let empty = Snapshot(v: 1, inboxCount: 0, labels: [:], blocks: [])

  /// Shared with the app (Runner.entitlements, home_widget_sink.dart).
  static let appGroup = "group.com.yourcompany.dottoday"

  static func load() -> Snapshot {
    guard
      let raw = UserDefaults(suiteName: appGroup)?.string(forKey: "snapshot"),
      let data = raw.data(using: .utf8),
      let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data),
      snapshot.v == 1
    else { return .empty }
    return snapshot
  }

  func label(_ key: String) -> String { labels[key] ?? "" }

  func live(at now: Date) -> WidgetBlock? {
    blocks.first { !$0.done && $0.start <= now && now < $0.end }
  }

  func next(at now: Date) -> WidgetBlock? {
    blocks.first { !$0.done && $0.start > now }
  }

  func ahead(at now: Date) -> [WidgetBlock] {
    blocks.filter { $0.end > now }
  }

  /// Every start and end still ahead: the widgets redraw at each one.
  func boundaries(after now: Date) -> [Date] {
    Array(Set(blocks.flatMap { [$0.start, $0.end] }).filter { $0 > now }).sorted()
  }
}
