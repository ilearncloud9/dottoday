import Cocoa
import EventKit
import FlutterMacOS

/// Mac device calendars for the app over `dottoday/calendars`
/// (lib/data/calendar/channel_device_calendar_gateway.dart, docs/09 M7.1b):
/// `device_calendar` has no macOS implementation. Read-only for now; write
/// back is M7.3. Titles and notes are never logged (CLAUDE.md §4).
final class CalendarBridge {
  private let store = EKEventStore()
  private var channel: FlutterMethodChannel?

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "dottoday/calendars", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return result(FlutterMethodNotImplemented) }
      switch call.method {
      case "status": result(Self.permission())
      case "request": self.request(result)
      case "calendars": result(self.calendars())
      case "events": self.events(call.arguments as? [String: Any], result)
      default: result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
  }

  /// "granted" / "denied" / "notAsked", as Dart's `PermissionState`.
  /// Write-only access (macOS 14) can't read events, so it counts as denied.
  private static func permission() -> String {
    let status = EKEventStore.authorizationStatus(for: .event)
    if status == .notDetermined { return "notAsked" }
    if #available(macOS 14.0, *) {
      return status == .fullAccess ? "granted" : "denied"
    }
    return status == .authorized ? "granted" : "denied"
  }

  private func request(_ result: @escaping FlutterResult) {
    let done: (Bool, Error?) -> Void = { _, _ in
      DispatchQueue.main.async { result(Self.permission()) }
    }
    if #available(macOS 14.0, *) {
      store.requestFullAccessToEvents(completion: done)
    } else {
      store.requestAccess(to: .event, completion: done)
    }
  }

  private func calendars() -> Any {
    guard Self.permission() == "granted" else { return Self.denied }
    return store.calendars(for: .event).map { c -> [String: Any?] in
      [
        "id": c.calendarIdentifier,
        "name": c.title,
        "accountName": c.source?.title,
        "colorArgb": Self.argb(c.color),
        "readOnly": !c.allowsContentModifications,
      ]
    }
  }

  private func events(_ args: [String: Any]?, _ result: @escaping FlutterResult) {
    guard Self.permission() == "granted" else { return result(Self.denied) }
    guard let id = args?["calendarId"] as? String,
      let from = (args?["fromMs"] as? NSNumber)?.doubleValue,
      let to = (args?["toMs"] as? NSNumber)?.doubleValue, to > from
    else {
      return result(FlutterError(code: "bad_args", message: nil, details: nil))
    }
    guard let calendar = store.calendar(withIdentifier: id) else {
      return result(FlutterError(code: "no_calendar", message: nil, details: nil))
    }
    let predicate = store.predicateForEvents(
      withStart: Date(timeIntervalSince1970: from / 1000),
      end: Date(timeIntervalSince1970: to / 1000), calendars: [calendar])
    // Large ranges can take a moment; keep the UI thread free.
    DispatchQueue.global(qos: .userInitiated).async { [store] in
      let rows = store.events(matching: predicate).compactMap(Self.row)
      DispatchQueue.main.async { result(rows) }
    }
  }

  /// One event. All-day ones carry their dates in this Mac's calendar
  /// (EventKit keeps them as floating local days), timed ones instants.
  private static func row(_ e: EKEvent) -> [String: Any?]? {
    guard let id = e.eventIdentifier, let start = e.startDate, let end = e.endDate else {
      return nil
    }
    var row: [String: Any?] = [
      "id": id, "title": e.title, "allDay": e.isAllDay, "location": e.location,
      "notes": e.notes, "url": e.url?.absoluteString,
    ]
    if e.isAllDay {
      row["startDay"] = day(start)
      row["endDay"] = day(end)
    } else {
      row["startMs"] = Int64(start.timeIntervalSince1970 * 1000)
      row["endMs"] = Int64(end.timeIntervalSince1970 * 1000)
    }
    return row
  }

  private static func day(_ date: Date) -> String {
    let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
    return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
  }

  private static func argb(_ color: NSColor?) -> Int? {
    guard let rgb = color?.usingColorSpace(.sRGB) else { return nil }
    let byte = { (v: CGFloat) in Int((min(max(v, 0), 1) * 255).rounded()) }
    return 0xFF << 24 | byte(rgb.redComponent) << 16 | byte(rgb.greenComponent) << 8
      | byte(rgb.blueComponent)
  }

  private static let denied = FlutterError(code: "denied", message: nil, details: nil)
}
