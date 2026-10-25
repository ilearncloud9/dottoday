import Foundation

/// What a queued action looks like on the day snapshot before the app
/// applies it (docs/09 M9.2 "updates the snapshot optimistically"): the
/// same rules as `DotIntents` in Dart, so the widget shows the tap at once
/// and the app's rewrite later agrees with it.
enum SnapshotPatch {
  /// [snapshot] with [kind] applied to the dot [occurrenceId] at [now];
  /// unchanged when the dot isn't in it.
  static func apply(
    _ kind: DotActionKind, occurrenceId: String, now: Date, to snapshot: [String: Any]
  ) -> [String: Any] {
    guard var blocks = snapshot["blocks"] as? [[String: Any]],
      let i = blocks.firstIndex(where: { ($0["id"] as? String)?.lowercased() == occurrenceId.lowercased() })
    else { return snapshot }
    var block = blocks[i]
    let nowMs = Int64(now.timeIntervalSince1970 * 1000)
    switch kind {
    case .markDone:
      if block["done"] as? Bool == true { return snapshot }
      block["done"] = true
      block["actual_end_ms"] = nowMs
    case .startFocus:
      let started = block["actual_start_ms"].map { !($0 is NSNull) } ?? false
      if block["done"] as? Bool == true || started { return snapshot }
      block["actual_start_ms"] = nowMs
    case .addFifteen:
      let end = (block["end_ms"] as? NSNumber)?.int64Value ?? 0
      block["end_ms"] = end + 15 * 60_000
      block["duration_min"] = ((block["duration_min"] as? NSNumber)?.intValue ?? 0) + 15
      if let until = untilText(endMs: end + 15 * 60_000, format: snapshot["format"] as? [String: Any]) {
        block["until"] = until
      }
    case .addTask:
      return snapshot
    }
    blocks[i] = block
    var patched = snapshot
    patched["blocks"] = blocks
    return patched
  }

  /// "until 10:45" in the app's language, zone and clock (`format` in the
  /// snapshot, lib/data/snapshot/snapshot_store_json.dart).
  static func untilText(endMs: Int64, format: [String: Any]?) -> String? {
    guard let format, let pattern = format["until"] as? String,
      let zone = TimeZone(identifier: format["tz"] as? String ?? "")
    else { return nil }
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: format["locale"] as? String ?? "en")
    formatter.timeZone = zone
    formatter.dateFormat = (format["hour24"] as? Bool ?? false) ? "HH:mm" : "h:mm a"
    let time = formatter.string(from: Date(timeIntervalSince1970: Double(endMs) / 1000))
    return pattern.replacingOccurrences(of: "{time}", with: time)
  }

  /// Reads, patches and writes the snapshot in [defaults].
  static func patchStored(
    _ kind: DotActionKind, occurrenceId: String, now: Date, in defaults: UserDefaults
  ) {
    guard let raw = defaults.string(forKey: DotStore.snapshotKey),
      let data = raw.data(using: .utf8),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let out = try? JSONSerialization.data(
        withJSONObject: apply(kind, occurrenceId: occurrenceId, now: now, to: json)),
      let text = String(data: out, encoding: .utf8)
    else { return }
    defaults.set(text, forKey: DotStore.snapshotKey)
  }
}
