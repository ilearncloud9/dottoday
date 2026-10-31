import AppIntents
import CryptoKit
import Foundation

#if os(iOS) && canImport(AlarmKit)
  import AlarmKit
  import SwiftUI

  /// What a Wake Up alarm's countdown view shows (DottodayWidgets
  /// `WakeUpAlarmActivity`, docs/15 W1b).
  @available(iOS 26.0, *)
  struct WakeUpMetadata: AlarmMetadata {
    var title: String
  }

  /// One Wake Up alarm as the app hands it over (lib/data/notifications/
  /// os_alarm_gateway.dart `_toChannel`), plus the snoozes so far. Kept in
  /// the App Group by AlarmKit id, so Snooze can arm it again with the app
  /// closed.
  struct WakeUpAlarmSpec: Codable, Equatable {
    var id: String
    var fireAtMs: Int64
    var sound: String
    var title: String
    var body: String
    var stop: String
    var snooze: String
    var snoozeMin: Int
    var snoozeLimit: Int
    var snoozes = 0

    /// Snooze is offered: on, and under its limit (0 = no limit).
    var canSnooze: Bool { snoozeMin > 0 && (snoozeLimit == 0 || snoozes < snoozeLimit) }

    init?(_ map: [String: Any]) {
      guard let id = map["id"] as? String, let fireAt = map["fireAtMs"] as? NSNumber,
        let sound = map["sound"] as? String, let title = map["title"] as? String,
        let body = map["body"] as? String, let stop = map["stop"] as? String,
        let snooze = map["snooze"] as? String
      else { return nil }
      self.id = id
      fireAtMs = fireAt.int64Value
      self.sound = sound
      self.title = title
      self.body = body
      self.stop = stop
      self.snooze = snooze
      snoozeMin = (map["snoozeMin"] as? NSNumber)?.intValue ?? 0
      snoozeLimit = (map["snoozeLimit"] as? NSNumber)?.intValue ?? 0
    }
  }

  /// The Wake Up alarms in AlarmKit (docs/15 W1b, ADR-0017): iOS 26+ only,
  /// with alarms allowed; below that the app rings the Wake Up as a
  /// time-sensitive notification (W1a). AlarmKit rings through Silent and
  /// every Focus, with the app closed, and shows the snooze countdown on the
  /// Lock Screen and in the Dynamic Island.
  @available(iOS 26.0, *)
  enum WakeUpAlarms {
    static let testId = "wakeup:test"
    private static let storeKey = "wake_up_alarms"
    private static var manager: AlarmManager { .shared }

    /// AlarmKit's id for [id]: a stable UUID from its hash, so the same day
    /// is always the same alarm and never armed twice (15 §3).
    static func uuid(_ id: String) -> UUID {
      var bytes = Array(SHA256.hash(data: Data(id.utf8)).prefix(16))
      bytes[6] = (bytes[6] & 0x0F) | 0x50
      bytes[8] = (bytes[8] & 0x3F) | 0x80
      return NSUUID(uuidBytes: bytes) as UUID
    }

    /// Makes [specs] the armed set; returns the instants armed (ms). An
    /// alarm ringing or counting down a snooze stays, as does the test
    /// alarm. Without permission nothing is armed.
    static func sync(_ specs: [WakeUpAlarmSpec]) async -> [Int64] {
      let stored = load()
      let live = (try? manager.alarms) ?? []
      let wanted = manager.authorizationState == .authorized ? specs : []
      var next: [String: WakeUpAlarmSpec] = [:]
      for alarm in live where alarm.state != .scheduled || alarm.id == uuid(testId) {
        next[alarm.id.uuidString] = stored[alarm.id.uuidString]
      }
      // A scheduled alarm stays only while it is wanted unchanged.
      for alarm in live where alarm.state == .scheduled && alarm.id != uuid(testId) {
        let same = wanted.contains { uuid($0.id) == alarm.id && $0 == stored[alarm.id.uuidString] }
        if !same { try? manager.cancel(id: alarm.id) }
      }
      var armed: [Int64] = []
      for spec in wanted {
        let id = uuid(spec.id)
        guard next[id.uuidString] == nil else { continue }
        let same = live.contains { $0.id == id && $0.state == .scheduled } && stored[id.uuidString] == spec
        if !same {
          guard (try? await arm(spec)) != nil else { continue }
        }
        next[id.uuidString] = spec
        armed.append(spec.fireAtMs)
      }
      save(next)
      return armed
    }

    /// Arms [spec] as the test alarm; false without permission.
    static func test(_ spec: WakeUpAlarmSpec) async -> Bool {
      guard manager.authorizationState == .authorized else { return false }
      var test = spec
      test.id = testId
      try? manager.cancel(id: uuid(testId))
      guard (try? await arm(test)) != nil else { return false }
      var stored = load()
      stored[uuid(testId).uuidString] = test
      save(stored)
      return true
    }

    /// Stops and forgets every Wake Up alarm: the switch went off.
    static func disarmAll() {
      for alarm in (try? manager.alarms) ?? [] {
        try? manager.cancel(id: alarm.id)
      }
      save([:])
    }

    /// Snooze from the alert (`SnoozeWakeUpIntent`): stops this ring and arms
    /// a countdown of `snoozeMin` with one more snooze counted, so the next
    /// alert drops Snooze once the limit is reached (15 §4).
    static func snooze(_ key: String) async {
      guard let id = UUID(uuidString: key) else { return }
      try? manager.stop(id: id)
      var stored = load()
      guard var spec = stored[key], spec.canSnooze else { return }
      spec.snoozes += 1
      let wait = TimeInterval(spec.snoozeMin * 60)
      spec.fireAtMs = Int64((Date().timeIntervalSince1970 + wait) * 1000)
      stored[key] = spec
      save(stored)
      _ = try? await arm(spec, countdown: wait)
    }

    /// Schedules [spec] at its time, or after [countdown] seconds with the
    /// countdown on the Lock Screen (a snooze).
    @discardableResult
    private static func arm(_ spec: WakeUpAlarmSpec, countdown: TimeInterval? = nil) async throws -> Alarm {
      let id = uuid(spec.id)
      let attributes = AlarmAttributes(
        presentation: presentation(spec),
        metadata: WakeUpMetadata(title: spec.title),
        tintColor: Dot.accent)
      let config = AlarmManager.AlarmConfiguration(
        countdownDuration: countdown.map { .init(preAlert: $0, postAlert: nil) },
        schedule: countdown == nil ? .fixed(Date(timeIntervalSince1970: Double(spec.fireAtMs) / 1000)) : nil,
        attributes: attributes,
        secondaryIntent: spec.canSnooze ? SnoozeWakeUpIntent(alarm: id.uuidString) : nil,
        sound: .named(spec.sound))
      return try await manager.schedule(id: id, configuration: config)
    }

    private static func presentation(_ spec: WakeUpAlarmSpec) -> AlarmPresentation {
      let snooze =
        spec.canSnooze
        ? AlarmButton(text: words(spec.snooze), textColor: .white, systemImageName: "moon.zzz.fill") : nil
      let behavior: AlarmPresentation.Alert.SecondaryButtonBehavior? = snooze == nil ? nil : .custom
      let alert: AlarmPresentation.Alert
      if #available(iOS 26.1, *) {
        alert = .init(title: words(spec.title), secondaryButton: snooze, secondaryButtonBehavior: behavior)
      } else {
        alert = .init(
          title: words(spec.title),
          stopButton: AlarmButton(text: words(spec.stop), textColor: .white, systemImageName: "sun.max.fill"),
          secondaryButton: snooze, secondaryButtonBehavior: behavior)
      }
      return AlarmPresentation(alert: alert, countdown: .init(title: words(spec.snooze)))
    }

    /// The app's own (already translated) words, shown as they are.
    private static func words(_ text: String) -> LocalizedStringResource { "\(text)" }

    private static func load() -> [String: WakeUpAlarmSpec] {
      guard let data = DotStore.shared?.data(forKey: storeKey) else { return [:] }
      return (try? JSONDecoder().decode([String: WakeUpAlarmSpec].self, from: data)) ?? [:]
    }

    private static func save(_ specs: [String: WakeUpAlarmSpec]) {
      DotStore.shared?.set(try? JSONEncoder().encode(specs), forKey: storeKey)
    }
  }

  /// The alert's Snooze (docs/15 W1b): runs in the app's process, even with
  /// the app closed, and arms the snooze countdown.
  @available(iOS 26.0, *)
  struct SnoozeWakeUpIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Snooze"
    static let isDiscoverable = false

    @Parameter(title: "Alarm")
    var alarm: String

    init() {}

    init(alarm: String) {
      self.alarm = alarm
    }

    func perform() async throws -> some IntentResult {
      await WakeUpAlarms.snooze(alarm)
      return .result()
    }
  }
#endif
