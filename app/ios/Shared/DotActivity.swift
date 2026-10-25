import Foundation

#if canImport(ActivityKit)
  import ActivityKit
#endif

/// The Live Activity's content (docs/09 M9.3), decoded from the JSON
/// `lib/data/live_activity/live_activity_content.dart` sends: every word
/// localised and every colour resolved by the app.
struct LiveDotState: Codable, Hashable {
  struct Next: Codable, Hashable {
    let id: String
    let title: String
    let color: String
    let time: String
  }

  struct Format: Codable, Hashable {
    let tz: String
    let locale: String
    let hour24: Bool
  }

  var id: String
  var title: String
  var color: String
  var icon: String
  var startMs: Double
  var endMs: Double
  var endsMs: Double
  var live: Bool
  var range: String
  var rangePattern: String
  var format: Format
  var leftBefore: String
  var leftAfter: String
  var startsBefore: String
  var startsAfter: String
  var count: String
  var countLabel: String
  var doneShare: Double
  var doneLabel: String
  var plusLabel: String
  var plusShort: String
  var next: [Next]

  enum CodingKeys: String, CodingKey {
    case id, title, color, icon, live, range, format, count, next
    case startMs = "start_ms", endMs = "end_ms", endsMs = "ends_ms"
    case rangePattern = "range_pattern", leftBefore = "left_before", leftAfter = "left_after"
    case startsBefore = "starts_before", startsAfter = "starts_after"
    case countLabel = "count_label", doneShare = "done_share", doneLabel = "done_label"
    case plusLabel = "plus_label", plusShort = "plus_short"
  }

  var start: Date { Date(timeIntervalSince1970: startMs / 1000) }
  var end: Date { Date(timeIntervalSince1970: endMs / 1000) }
  var endsAt: Date { Date(timeIntervalSince1970: endsMs / 1000) }

  static func decode(_ json: String) -> LiveDotState? {
    guard let data = json.data(using: .utf8) else { return nil }
    return try? JSONDecoder().decode(LiveDotState.self, from: data)
  }

  /// This state after +15 on the activity itself: the end moves and the
  /// range is written again on the app's clock.
  func plusFifteen() -> LiveDotState {
    var next = self
    next.endMs += 15 * 60_000
    next.endsMs += 15 * 60_000
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: format.locale)
    formatter.timeZone = TimeZone(identifier: format.tz)
    formatter.dateFormat = format.hour24 ? "HH:mm" : "h:mm a"
    next.range = rangePattern
      .replacingOccurrences(of: "{start}", with: formatter.string(from: start))
      .replacingOccurrences(of: "{end}", with: formatter.string(from: next.end))
    return next
  }
}

#if canImport(ActivityKit)
  /// One activity at a time: the dot in [LiveDotState].
  @available(iOS 16.1, *)
  struct DotActivityAttributes: ActivityAttributes {
    typealias ContentState = LiveDotState
  }
#endif
