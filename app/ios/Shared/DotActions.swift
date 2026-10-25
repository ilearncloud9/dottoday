import Foundation

#if canImport(WidgetKit)
  import WidgetKit
#endif

/// Carries out a B6 action outside the Flutter app (docs/09 M9.2): queue
/// it for the app, show it on the snapshot at once, redraw the widgets and
/// nudge a running app to drain. The app applies it through its single
/// write path; this side never touches the database.
enum DotActions {
  static func perform(
    _ kind: DotActionKind, occurrenceId: String? = nil, plannedEnd: Date? = nil,
    text: String? = nil, now: Date = Date(), defaults: UserDefaults? = DotStore.shared
  ) {
    guard let defaults else { return }
    DotQueue(defaults: defaults).append(
      DotQueue.entry(kind, occurrenceId: occurrenceId, plannedEnd: plannedEnd, text: text, now: now))
    if let occurrenceId {
      SnapshotPatch.patchStored(kind, occurrenceId: occurrenceId, now: now, in: defaults)
    }
    #if canImport(WidgetKit)
      WidgetCenter.shared.reloadAllTimelines()
    #endif
    CFNotificationCenterPostNotification(
      CFNotificationCenterGetDarwinNotifyCenter(),
      CFNotificationName(DotStore.queueChanged as CFString), nil, nil, true)
  }

  /// The snapshot as stored, for `WhatsNext`.
  static func storedSnapshot(defaults: UserDefaults? = DotStore.shared) -> [String: Any]? {
    guard let raw = defaults?.string(forKey: DotStore.snapshotKey),
      let data = raw.data(using: .utf8),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      (json["v"] as? NSNumber)?.intValue == 1
    else { return nil }
    return json
  }

  /// "Now: Deep work · until 11:00" / "Next up: Gym · 18:00" / "Nothing
  /// else today" from the snapshot's own localised labels and times.
  static func whatsNext(_ snapshot: [String: Any], at now: Date) -> String? {
    let labels = snapshot["labels"] as? [String: String] ?? [:]
    let blocks = snapshot["blocks"] as? [[String: Any]] ?? []
    let nowMs = Int64(now.timeIntervalSince1970 * 1000)
    func ms(_ b: [String: Any], _ k: String) -> Int64 { (b[k] as? NSNumber)?.int64Value ?? 0 }
    let open = blocks.filter { $0["done"] as? Bool != true }
    if let live = open.first(where: { ms($0, "start_ms") <= nowMs && nowMs < ms($0, "end_ms") }) {
      return line(labels["now"], live["title"], live["until"])
    }
    if let next = open.first(where: { ms($0, "start_ms") > nowMs }) {
      return line(labels["next_up"], next["title"], next["time"])
    }
    return labels["nothing_next"]
  }

  private static func line(_ label: String?, _ title: Any?, _ when: Any?) -> String {
    "\(label ?? ""): \(title as? String ?? "") · \(when as? String ?? "")"
  }
}
