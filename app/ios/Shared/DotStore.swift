import Foundation

/// The App Group store the Flutter app shares with the widgets, controls,
/// Live Activity and Siri (docs/04 §4, docs/09 M9.1, M9.2). The app writes
/// the day snapshot; these surfaces append to the action queue and patch
/// the snapshot optimistically until the app drains the queue. None of
/// them talks to the network (CLAUDE.md §11 surface rule).
enum DotStore {
  static let appGroup = "group.app.dottoday.planner"
  static let snapshotKey = "snapshot"
  static let queueKey = "action_queue"

  /// Posted after every append so a running app drains at once
  /// (AppDelegate.swift listens).
  static let queueChanged = "app.dottoday.planner.queueChanged"

  static var shared: UserDefaults? { UserDefaults(suiteName: appGroup) }
}

/// The four queued kinds, as `lib/domain/intents/dot_action.dart` reads them.
enum DotActionKind: String {
  case addTask = "add_task"
  case markDone = "mark_done"
  case addFifteen = "add_fifteen"
  case startFocus = "start_focus"
}

/// The action queue: a JSON array of entries under `action_queue`.
struct DotQueue {
  let defaults: UserDefaults

  /// Appends (any thread: intents, the Live Activity) and the drain's
  /// remove take turns within this process.
  private static let lock = NSLock()

  func entries() -> [[String: Any]] {
    guard let raw = defaults.string(forKey: DotStore.queueKey),
      let data = raw.data(using: .utf8),
      let list = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
    else { return [] }
    return list
  }

  func append(_ entry: [String: Any]) {
    Self.lock.lock()
    defer { Self.lock.unlock() }
    write(rawEntries() + [entry])
  }

  /// Drops the entries whose id is in [ids] (and, when [unreadable], those
  /// without a string id) in one read-modify-write, so nothing appended in
  /// between is lost (the app's drain, M9.2).
  func remove(_ ids: Set<String>, unreadable: Bool) {
    Self.lock.lock()
    defer { Self.lock.unlock() }
    write(rawEntries().filter { entry in
      guard let id = (entry as? [String: Any])?["id"] as? String else { return !unreadable }
      return !ids.contains(id)
    })
  }

  private func rawEntries() -> [Any] {
    guard let raw = defaults.string(forKey: DotStore.queueKey),
      let data = raw.data(using: .utf8),
      let list = try? JSONSerialization.jsonObject(with: data) as? [Any]
    else { return [] }
    return list
  }

  private func write(_ list: [Any]) {
    guard let data = try? JSONSerialization.data(withJSONObject: list),
      let raw = String(data: data, encoding: .utf8)
    else { return }
    defaults.set(raw, forKey: DotStore.queueKey)
  }

  /// One entry; ids are lowercase UUID v7 (the Dart side requires UUIDs).
  static func entry(
    _ kind: DotActionKind, occurrenceId: String? = nil, plannedEnd: Date? = nil,
    text: String? = nil, now: Date = Date()
  ) -> [String: Any] {
    var entry: [String: Any] = [
      "id": UUIDv7.make(now), "at_ms": Int64(now.timeIntervalSince1970 * 1000),
      "kind": kind.rawValue,
    ]
    if let occurrenceId { entry["occurrence_id"] = occurrenceId.lowercased() }
    if let plannedEnd { entry["planned_end_ms"] = Int64(plannedEnd.timeIntervalSince1970 * 1000) }
    if let text { entry["text"] = text }
    return entry
  }
}

/// RFC 9562 UUID version 7: 48-bit Unix ms, version, 74 random bits.
enum UUIDv7 {
  static func make(_ date: Date = Date()) -> String {
    var bytes = [UInt8](repeating: 0, count: 16)
    for i in 0..<16 { bytes[i] = UInt8.random(in: 0...255) }
    let ms = UInt64(max(0, date.timeIntervalSince1970 * 1000))
    for i in 0..<6 { bytes[i] = UInt8((ms >> (8 * UInt64(5 - i))) & 0xFF) }
    bytes[6] = (bytes[6] & 0x0F) | 0x70
    bytes[8] = (bytes[8] & 0x3F) | 0x80
    let hex = bytes.map { String(format: "%02x", $0) }.joined()
    let parts = [0..<8, 8..<12, 12..<16, 16..<20, 20..<32].map { range -> String in
      let start = hex.index(hex.startIndex, offsetBy: range.lowerBound)
      let end = hex.index(hex.startIndex, offsetBy: range.upperBound)
      return String(hex[start..<end])
    }
    return parts.joined(separator: "-")
  }
}
