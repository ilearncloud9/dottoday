import XCTest

@testable import Runner

/// The Swift half of the B6 intents (docs/09 M9.2): what an intent queues
/// and how it patches the snapshot until the app drains the queue.
final class DotIntentsTests: XCTestCase {
  private var defaults: UserDefaults!
  private let suite = "DotIntentsTests"
  private let now = Date(timeIntervalSince1970: 1_792_584_000)  // 2026-10-21 12:00Z
  private let live = "01928c3e-0000-7000-8000-0000000000b1"

  override func setUp() {
    super.setUp()
    defaults = UserDefaults(suiteName: suite)
    defaults.removePersistentDomain(forName: suite)
    let startMs = Int64(now.timeIntervalSince1970 * 1000) - 10 * 60_000
    let snapshot: [String: Any] = [
      "v": 1,
      "labels": ["now": "Now", "next_up": "Next up", "nothing_next": "Nothing next"],
      "format": ["tz": "UTC", "locale": "en", "hour24": true, "until": "until {time}"],
      "blocks": [
        [
          "id": live, "title": "Deep work", "start_ms": startMs,
          "end_ms": startMs + 30 * 60_000, "duration_min": 30, "done": false,
          "until": "until 12:20", "time": "11:50", "actual_start_ms": NSNull(),
        ]
      ],
    ]
    let data = try! JSONSerialization.data(withJSONObject: snapshot)
    defaults.set(String(data: data, encoding: .utf8), forKey: DotStore.snapshotKey)
  }

  private func block() -> [String: Any] {
    let snapshot = DotActions.storedSnapshot(defaults: defaults)!
    return (snapshot["blocks"] as! [[String: Any]])[0]
  }

  func testUUIDv7IsLowercaseVersion7AndTimeOrdered() {
    let a = UUIDv7.make(now)
    let b = UUIDv7.make(now.addingTimeInterval(1))
    XCTAssertNotNil(
      a.range(
        of: "^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
        options: .regularExpression))
    XCTAssertLessThan(a, b)
  }

  func testMarkDoneQueuesAndTicksTheDot() {
    DotActions.perform(.markDone, occurrenceId: live.uppercased(), now: now, defaults: defaults)
    let entry = DotQueue(defaults: defaults).entries().single
    XCTAssertEqual(entry?["kind"] as? String, "mark_done")
    XCTAssertEqual(entry?["occurrence_id"] as? String, live)
    XCTAssertEqual((entry?["at_ms"] as? NSNumber)?.int64Value, Int64(now.timeIntervalSince1970 * 1000))
    XCTAssertEqual(block()["done"] as? Bool, true)
    XCTAssertEqual((block()["actual_end_ms"] as? NSNumber)?.int64Value, Int64(now.timeIntervalSince1970 * 1000))
  }

  func testAddFifteenCarriesThePlannedEndAndMovesUntil() {
    let end = Date(timeIntervalSince1970: Double((block()["end_ms"] as! NSNumber).int64Value) / 1000)
    DotActions.perform(.addFifteen, occurrenceId: live, plannedEnd: end, now: now, defaults: defaults)
    let entry = DotQueue(defaults: defaults).entries().single
    XCTAssertEqual((entry?["planned_end_ms"] as? NSNumber)?.int64Value, Int64(end.timeIntervalSince1970 * 1000))
    XCTAssertEqual(block()["duration_min"] as? Int, 45)
    XCTAssertEqual(block()["until"] as? String, "until 12:35")
  }

  func testStartFocusRecordsTheFirstStartOnly() {
    DotActions.perform(.startFocus, occurrenceId: live, now: now, defaults: defaults)
    DotActions.perform(.startFocus, occurrenceId: live, now: now.addingTimeInterval(60), defaults: defaults)
    XCTAssertEqual((block()["actual_start_ms"] as? NSNumber)?.int64Value, Int64(now.timeIntervalSince1970 * 1000))
    XCTAssertEqual(DotQueue(defaults: defaults).entries().count, 2)
  }

  func testAddTaskQueuesTheTextAndLeavesTheSnapshot() {
    DotActions.perform(.addTask, text: "Call mum 3pm", now: now, defaults: defaults)
    let entry = DotQueue(defaults: defaults).entries().single
    XCTAssertEqual(entry?["kind"] as? String, "add_task")
    XCTAssertEqual(entry?["text"] as? String, "Call mum 3pm")
    XCTAssertEqual(block()["done"] as? Bool, false)
  }

  func testAnUnknownDotQueuesButPatchesNothing() {
    DotActions.perform(.markDone, occurrenceId: "01928c3e-0000-7000-8000-0000000000ff", now: now, defaults: defaults)
    XCTAssertEqual(DotQueue(defaults: defaults).entries().count, 1)
    XCTAssertEqual(block()["done"] as? Bool, false)
  }

  func testRemoveDropsOnlyTheSettledAndKeepsTheRest() {
    let queue = DotQueue(defaults: defaults)
    queue.append(DotQueue.entry(.markDone, occurrenceId: live, now: now))
    queue.append(DotQueue.entry(.startFocus, occurrenceId: live, now: now))
    let settled = queue.entries()[0]["id"] as! String
    defaults.set(
      (defaults.string(forKey: DotStore.queueKey)!.dropLast()) + ",\"junk\"]", forKey: DotStore.queueKey)
    queue.remove([settled], unreadable: true)
    XCTAssertEqual(queue.entries().map { $0["kind"] as? String }, ["start_focus"])
  }

  func testWhatsNextReadsTheSnapshotsOwnWords() {
    let snapshot = DotActions.storedSnapshot(defaults: defaults)!
    XCTAssertEqual(DotActions.whatsNext(snapshot, at: now), "Now: Deep work · until 12:20")
    XCTAssertEqual(DotActions.whatsNext(snapshot, at: now.addingTimeInterval(3600)), "Nothing next")
    XCTAssertEqual(
      DotActions.whatsNext(snapshot, at: now.addingTimeInterval(-3600)), "Next up: Deep work · 11:50")
  }
}

extension Array {
  fileprivate var single: Element? { count == 1 ? first : nil }
}
