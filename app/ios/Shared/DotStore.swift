import Foundation

/// The App Group store the Flutter app shares with the widgets, controls,
/// Live Activity and Siri (docs/04 §4, docs/09 M9.1, M9.2). The app writes
/// the day snapshot; these surfaces append to the action queue and patch
/// the snapshot optimistically until the app drains the queue. None of
/// them talks to the network (CLAUDE.md §11 surface rule).
enum DotStore {
  #if os(macOS)
    /// The Mac's group is team-prefixed, which needs no provisioning
    /// profile; Info.plist's `DotAppGroup` names it (docs/09 M12.4).
    static let appGroup =
      Bundle.main.object(forInfoDictionaryKey: "DotAppGroup") as? String ?? "app.dottoday.planner"
  #else
    static let appGroup = "group.app.dottoday.planner"
  #endif
  static let snapshotKey = "snapshot"
  static let queueKey = "action_queue"
  /// Whom new entries are stamped with, as the app publishes it
  /// (lib/domain/intents/action_queue_store.dart `encodeQueueOwner`).
  static let queueOwnerKey = "action_queue_owner"

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
///
/// Every append is stamped with the owner the app published (CR-160 I7),
/// and the app's remove and publish take the same lock: a lock file in the
/// App Group container, so the share extension, the widget extension and
/// the app (separate processes) take turns, and an append is never lost to
/// a read-modify-write in another process.
struct DotQueue {
  let defaults: UserDefaults

  /// The preferences domain [defaults] reads (the App Group's), synced
  /// before every read so another process's write is seen.
  var suite: String = DotStore.appGroup

  /// The readable entries (maps); an unreadable one is skipped, not the lot.
  func entries() -> [[String: Any]] {
    rawEntries().compactMap { $0 as? [String: Any] }
  }

  /// Most entries the queue holds (lib/domain/intents/action_queue_store.dart
  /// `queueCapacity`); past it, or past [maxBytes], a new entry is refused,
  /// never an older one evicted (CR-160 I7 retention).
  static let capacity = 500
  static let maxBytes = 1_000_000

  /// Appends [entry] stamped with the published owner: its id and guest
  /// session, or none while a change of owner is under way or before the
  /// app published one (the app then keeps the entry and never applies it).
  /// False, and nothing queued, while the app refuses new entries (an
  /// account being deleted) or the queue is full: the caller says so.
  @discardableResult
  func append(_ entry: [String: Any]) -> Bool {
    QueueLock.run {
      reload()
      let marker = Self.marker(defaults.string(forKey: DotStore.queueOwnerKey))
      if marker?["refuse"] as? Bool == true { return false }
      guard let list = storedEntries(), list.count < Self.capacity else { return false }
      return write(list + [Self.stamped(entry, marker: marker)])
    }
  }

  /// Drops the entries whose id is in [ids] in one read-modify-write;
  /// entries without a string id stay (CR-160 I7: never discarded unread).
  func remove(_ ids: Set<String>) {
    QueueLock.run {
      reload()
      guard let list = storedEntries() else { return }
      write(list.filter { entry in
        guard let id = (entry as? [String: Any])?["id"] as? String else { return true }
        return !ids.contains(id)
      })
    }
  }

  /// The app's published owner (`{"v":1,"owner":…}` or `{"v":1,"switching":true}`).
  func publishOwner(_ raw: String) {
    QueueLock.run {
      defaults.set(raw, forKey: DotStore.queueOwnerKey)
      CFPreferencesAppSynchronize(suite as CFString)
    }
  }

  /// The published marker, or nil when there is none or it can't be read.
  static func marker(_ raw: String?) -> [String: Any]? {
    guard let raw, let data = raw.data(using: .utf8) else { return nil }
    return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
  }

  /// [entry] with the owner [marker] names, if it names one.
  static func stamped(_ entry: [String: Any], marker: [String: Any]?) -> [String: Any] {
    guard let marker, marker["switching"] as? Bool != true,
      marker["refuse"] as? Bool != true,
      let owner = marker["owner"] as? String, !owner.isEmpty
    else { return entry }
    var out = entry
    out["owner"] = owner
    if let session = marker["guest_session"] as? String { out["guest_session"] = session }
    return out
  }

  /// What another process wrote since this one last read.
  private func reload() {
    CFPreferencesAppSynchronize(suite as CFString)
  }

  /// The stored array; empty when there is none, nil when it can't be read
  /// (then nothing is written over it: an unreadable queue is never
  /// replaced, CR-160 I7).
  private func storedEntries() -> [Any]? {
    guard let raw = defaults.string(forKey: DotStore.queueKey) else { return [] }
    guard let data = raw.data(using: .utf8) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data)) as? [Any]
  }

  private func rawEntries() -> [Any] { storedEntries() ?? [] }

  /// Writes [list]; false when it can't be encoded, is over [maxBytes], or
  /// didn't read back (storage full).
  @discardableResult
  private func write(_ list: [Any]) -> Bool {
    guard let data = try? JSONSerialization.data(withJSONObject: list),
      data.count <= Self.maxBytes,
      let raw = String(data: data, encoding: .utf8)
    else { return false }
    defaults.set(raw, forKey: DotStore.queueKey)
    CFPreferencesAppSynchronize(suite as CFString)
    return defaults.string(forKey: DotStore.queueKey) == raw
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

/// "Share → Dottoday" (docs/11 B6, docs/09 M12.4): what a share extension
/// queues — the raw text (with the shared link appended when the text
/// doesn't hold it) and the sharing app's subject, marked `shared`; the app
/// makes the Inbox task's title and note (lib/domain/quick_add/
/// shared_capture.dart). Posts `queueChanged` so a running app drains.
enum ShareQueue {
  /// A task note's and a title's limits (docs/05 "Validation").
  static let maxText = 10000
  static let maxSubject = 200

  /// The entry, or nil when there is nothing to add.
  static func entry(text: String, link: String?, subject: String?, now: Date = Date())
    -> [String: Any]?
  {
    var body = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if let link, !link.isEmpty, !body.contains(link) {
      body = body.isEmpty ? link : body + "\n" + link
    }
    guard !body.isEmpty else { return nil }
    var entry = DotQueue.entry(.addTask, text: String(body.prefix(maxText)), now: now)
    entry["shared"] = true
    let named = subject?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    if !named.isEmpty { entry["subject"] = String(named.prefix(maxSubject)) }
    return entry
  }

  /// Queues the share; false when Dottoday refused it (an account being
  /// deleted, or the queue full): the extension says so (CR-160 I7).
  @discardableResult
  static func append(text: String, link: String?, subject: String?) -> Bool {
    guard let entry = entry(text: text, link: link, subject: subject) else { return true }
    guard let defaults = DotStore.shared, DotQueue(defaults: defaults).append(entry) else {
      return false
    }
    CFNotificationCenterPostNotification(
      CFNotificationCenterGetDarwinNotifyCenter(),
      CFNotificationName(DotStore.queueChanged as CFString), nil, nil, true)
    return true
  }

  /// What the share sheet says when [append] refused: the extensions carry
  /// no strings bundle, so the four app languages are here (docs/08 §4).
  static func notSaved(_ language: String? = Locale.preferredLanguages.first) -> String {
    switch String((language ?? "en").prefix(2)) {
    case "de": return "Dottoday konnte das gerade nicht speichern. Öffne Dottoday und versuche es erneut."
    case "fr": return "Dottoday n’a pas pu l’enregistrer pour le moment. Ouvrez Dottoday et réessayez."
    case "es": return "Dottoday no ha podido guardarlo ahora. Abre Dottoday y vuelve a intentarlo."
    default: return "Dottoday couldn’t save this right now. Open Dottoday and try again."
    }
  }
}

/// The queue's lock across processes (CR-160 I7): `flock` on a file in the
/// App Group container, which the app and its extensions share. Each call
/// opens its own descriptor, so threads of one process take turns too.
/// Without a container (tests, a missing entitlement) an in-process lock.
enum QueueLock {
  private static let local = NSLock()

  /// Where the lock file lives instead of the container: only for
  /// tool/cr160/queue_lock_check.sh, which runs outside any App Group.
  static var directoryOverride: URL?

  static func run<T>(_ body: () -> T) -> T {
    guard
      let dir = directoryOverride
        ?? FileManager.default.containerURL(
          forSecurityApplicationGroupIdentifier: DotStore.appGroup)
    else {
      local.lock()
      defer { local.unlock() }
      return body()
    }
    let fd = open(dir.appendingPathComponent("action_queue.lock").path, O_CREAT | O_RDWR, 0o600)
    guard fd >= 0 else {
      local.lock()
      defer { local.unlock() }
      return body()
    }
    defer { close(fd) }
    while flock(fd, LOCK_EX) != 0 && errno == EINTR {}
    defer { flock(fd, LOCK_UN) }
    return body()
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
