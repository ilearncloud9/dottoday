import EventKit
import Foundation

#if os(iOS)
  import Flutter
#else
  import FlutterMacOS
#endif

/// `dottoday/calendar_series` (lib/data/calendar/calendar_series_channel.dart,
/// docs/02 F5.7): a scope-All edit or delete of a repeating event, on the
/// whole series. Compiled into the iOS and the macOS Runner (one file, R-13).
/// `device_calendar` would rewrite the repeat rule and invitees from its own
/// model when it saves, so only the start, length and title are touched
/// here. EventKit hands back a series' first occurrence for its id; saving
/// or removing that with `.futureEvents` reaches the whole series, as the
/// Calendar app's "All events" does. Titles are never logged (CLAUDE.md §4).
final class CalendarSeriesBridge {
  static let shared = CalendarSeriesBridge()
  private let store = EKEventStore()
  private var channel: FlutterMethodChannel?

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "dottoday/calendar_series", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return result(FlutterMethodNotImplemented) }
      let args = call.arguments as? [String: Any]
      switch call.method {
      case "update": result(self.update(args))
      case "delete": result(self.delete(args))
      default: result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
  }

  /// "written" / "gone" / "notWritable", as Dart's `EventWriteResult`.
  /// The start moves by `shiftMs` (its date stays); `durationMs` and
  /// `title` replace the length and title when sent.
  private func update(_ args: [String: Any]?) -> Any {
    guard Self.granted() else { return Self.denied }
    guard let shift = (args?["shiftMs"] as? NSNumber)?.doubleValue else {
      return Self.badArgs
    }
    let series: EKEvent
    switch find(args) {
    case .failure(let outcome): return outcome
    case .success(let e): series = e
    }
    guard let start = series.startDate, let end = series.endDate else { return "notWritable" }
    let duration = (args?["durationMs"] as? NSNumber).map { $0.doubleValue / 1000 }
    let next = start.addingTimeInterval(shift / 1000)
    series.startDate = next
    series.endDate = next.addingTimeInterval(duration ?? end.timeIntervalSince(start))
    if let title = args?["title"] as? String { series.title = title }
    do {
      try store.save(series, span: .futureEvents, commit: true)
      return "written"
    } catch {
      store.reset()
      return FlutterError(code: "write_failed", message: nil, details: nil)
    }
  }

  /// "written" when the whole series is gone from the calendar.
  private func delete(_ args: [String: Any]?) -> Any {
    guard Self.granted() else { return Self.denied }
    switch find(args) {
    case .failure(let outcome): return outcome
    case .success(let series):
      do {
        try store.remove(series, span: .futureEvents, commit: true)
        return "written"
      } catch {
        store.reset()
        return FlutterError(code: "write_failed", message: nil, details: nil)
      }
    }
  }

  private enum Found {
    case success(EKEvent)
    case failure(Any)
  }

  /// The series' first occurrence, or why it can't change here: gone,
  /// not repeating (a one-off goes through write-back), all-day, a
  /// read-only calendar, or a meeting someone else organises.
  private func find(_ args: [String: Any]?) -> Found {
    guard let calendarId = args?["calendarId"] as? String,
      let eventId = args?["eventId"] as? String
    else { return .failure(Self.badArgs) }
    store.refreshSourcesIfNecessary()
    guard let e = store.event(withIdentifier: eventId),
      e.calendar?.calendarIdentifier == calendarId
    else { return .failure("gone") }
    let organizer = e.organizer.map { $0.isCurrentUser } ?? true
    guard e.hasRecurrenceRules, !e.isAllDay, e.calendar.allowsContentModifications, organizer
    else { return .failure("notWritable") }
    return .success(e)
  }

  private static func granted() -> Bool {
    let status = EKEventStore.authorizationStatus(for: .event)
    if #available(iOS 17.0, macOS 14.0, *) { return status == .fullAccess }
    return status == .authorized
  }

  private static let denied = FlutterError(code: "denied", message: nil, details: nil)
  private static let badArgs = FlutterError(code: "bad_args", message: nil, details: nil)
}
