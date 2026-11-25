import Foundation
import SwiftUI

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
  /// Today's one thing (docs/15 §8): ringed, with the "one_thing" label.
  var oneThing: Bool? = nil
  /// Dark mode's step of the task colour (E-R2-17-Dark).
  var colorDark: String? = nil

  enum CodingKeys: String, CodingKey {
    case id, title, time, until, color, done
    case colorDark = "color_dark"
    case startMs = "start_ms"
    case endMs = "end_ms"
    case oneThing = "one_thing"
  }

  var isOneThing: Bool { oneThing ?? false }

  /// The task colour, light and dark.
  var tint: Color { Color(light: hexValue(color), dark: hexValue(colorDark ?? color)) }

  var start: Date { Date(timeIntervalSince1970: startMs / 1000) }
  var end: Date { Date(timeIntervalSince1970: endMs / 1000) }
}

struct Snapshot: Codable {
  let v: Int
  let inboxCount: Int
  let labels: [String: String]
  let blocks: [WidgetBlock]
  /// Today's Wake Up and Wind Down, and where the day ends on the day
  /// dot's ring (the night after it, docs/15 W6; 1 = no night). Computed
  /// once in the app (`dayDotGeometry`); the widgets only scale by it.
  var wakeMs: Double? = nil
  var bedMs: Double? = nil
  var nightStart: Double? = nil
  /// The App colour (ED-221): its dot colour and its word colour.
  var accent: Accent? = nil
  var format: Format? = nil
  /// Today's done and planned dots, Wake Up to Wind Down (past ones too).
  var dayDone: Int? = nil
  var dayTotal: Int? = nil

  struct Tone: Codable { let dot: String; let text: String }
  struct Accent: Codable { let light: Tone; let dark: Tone }
  struct Format: Codable {
    var doneOf: String? = nil
    enum CodingKeys: String, CodingKey { case doneOf = "done_of" }
  }

  enum CodingKeys: String, CodingKey {
    case v, labels, blocks, accent, format
    case dayDone = "day_done"
    case dayTotal = "day_total"
    case inboxCount = "inbox_count"
    case wakeMs = "wake_ms"
    case bedMs = "bed_ms"
    case nightStart = "night_start"
  }

  static let empty = Snapshot(v: 1, inboxCount: 0, labels: [:], blocks: [])

  /// Ring shares at [now]: the waking day ends at `day`, `filled` of it so
  /// far, and the night takes the rest.
  func dayDot(at now: Date) -> (day: Double, filled: Double) {
    let day = min(1, max(0, nightStart ?? 1))
    guard let wake = wakeMs, let bed = bedMs, bed > wake else { return (day, 0) }
    let t = now.timeIntervalSince1970 * 1000
    return (day, day * min(1, max(0, (t - wake) / (bed - wake))))
  }

  /// Shared with the app (Runner.entitlements, home_widget_sink.dart).
  static let appGroup = "group.app.dottoday.planner"

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

  /// The App colour's dot and words; teal (the default) before the app
  /// first writes it.
  var accentDot: Color {
    Color(light: hexValue(accent?.light.dot ?? "#11615C"), dark: hexValue(accent?.dark.dot ?? "#5BC4B8"))
  }
  var accentText: Color {
    Color(light: hexValue(accent?.light.text ?? "#11615C"), dark: hexValue(accent?.dark.text ?? "#5BC4B8"))
  }

  /// Today's "3 of 10 done" (a widget Done moves it, SnapshotPatch).
  var doneOf: String {
    guard let pattern = format?.doneOf, let total = dayTotal, total > 0 else { return "" }
    return pattern.replacingOccurrences(of: "{done}", with: "\(dayDone ?? 0)")
      .replacingOccurrences(of: "{total}", with: "\(total)")
  }

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
