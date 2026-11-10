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
    reset()
  }

  /// A fresh suite holding one live dot in the snapshot.
  private func reset() {
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
    // The app has run once: the queue's key is published (CR-160 I1).
    XCTAssertTrue(QueueSeal.ensureKey(defaults, suite: suite))
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
    XCTAssertNil(entry?["text"], "sealed at rest (CR-160 I1)")
    XCTAssertEqual(entry.map(QueueSeal.open)?["text"] as? String, "Call mum 3pm")
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
    queue.remove([settled])
    // The unreadable entry stays (CR-160 I7: never discarded unread).
    let left = try! JSONSerialization.jsonObject(
      with: defaults.string(forKey: DotStore.queueKey)!.data(using: .utf8)!) as! [Any]
    XCTAssertEqual(left.count, 2)
    XCTAssertEqual(queue.entries().map { $0["kind"] as? String }, ["start_focus"])
  }

  // CR-160 I7: every append carries the owner the app published.

  private let ownerA = "01928c3e-0000-7000-8000-00000000000a"

  func testAnAppendCarriesThePublishedOwnerAndGuestSession() {
    let queue = DotQueue(defaults: defaults)
    queue.publishOwner("{\"v\":1,\"owner\":\"\(ownerA)\",\"guest_session\":\"s1\"}")
    ShareQueue.entry(text: "Dentist", link: nil, subject: nil, now: now).map(queue.append)
    let entry = queue.entries()[0]
    XCTAssertEqual(entry["owner"] as? String, ownerA)
    XCTAssertEqual(entry["guest_session"] as? String, "s1")
    XCTAssertEqual(entry["shared"] as? Bool, true)
  }

  func testDuringAChangeOfOwnerOrBeforeAnyNobodyIsStamped() {
    let queue = DotQueue(defaults: defaults)
    queue.append(DotQueue.entry(.addTask, text: "before any", now: now))
    queue.publishOwner("{\"v\":1,\"owner\":\"\(ownerA)\"}")
    queue.publishOwner("{\"v\":1,\"switching\":true}")
    queue.append(DotQueue.entry(.addTask, text: "switching", now: now))
    XCTAssertEqual(queue.entries().compactMap { $0["owner"] as? String }, [])
    XCTAssertEqual(queue.entries().count, 2)
  }

  func testRefusedWhileAnAccountIsDeletedAndWhenFull() {
    let queue = DotQueue(defaults: defaults)
    queue.publishOwner("{\"v\":1,\"refuse\":true}")
    XCTAssertFalse(DotActions.perform(.markDone, occurrenceId: live, now: now, defaults: defaults))
    XCTAssertEqual(block()["done"] as? Bool, false, "nothing patched when refused")
    XCTAssertFalse(ShareQueue.notSaved("de").isEmpty)
    queue.publishOwner("{\"v\":1,\"owner\":\"\(ownerA)\"}")
    for i in 0..<DotQueue.capacity { XCTAssertTrue(queue.append(DotQueue.entry(.addTask, text: "t\(i)"))) }
    XCTAssertFalse(queue.append(DotQueue.entry(.addTask, text: "one more")))
    XCTAssertEqual(queue.entries().count, DotQueue.capacity, "nothing evicted")
  }

  func testAnUnreadableQueueIsNeverOverwritten() {
    defaults.set("{not json", forKey: DotStore.queueKey)
    let queue = DotQueue(defaults: defaults)
    XCTAssertFalse(queue.append(DotQueue.entry(.addTask, text: "x")))
    queue.remove(["x"])
    XCTAssertEqual(defaults.string(forKey: DotStore.queueKey), "{not json")
  }

  func testConcurrentAppendsAndRemovesLoseNothing() {
    let queue = DotQueue(defaults: defaults)
    queue.publishOwner("{\"v\":1,\"owner\":\"\(ownerA)\"}")
    let doomed = DotQueue.entry(.markDone, occurrenceId: live, now: now)
    queue.append(doomed)
    let id = doomed["id"] as! String
    DispatchQueue.concurrentPerform(iterations: 200) { i in
      if i % 10 == 0 {
        queue.remove([id])
      } else {
        queue.append(DotQueue.entry(.addTask, text: "t\(i)", now: now))
      }
    }
    let texts = queue.entries().map(QueueSeal.open).compactMap { $0["text"] as? String }
    XCTAssertEqual(texts.count, 180)
    XCTAssertTrue(queue.entries().allSatisfy { $0["owner"] as? String == ownerA })
    XCTAssertFalse(queue.entries().contains { $0["id"] as? String == id })
  }

  func testWhatsNextReadsTheSnapshotsOwnWords() {
    let snapshot = DotActions.storedSnapshot(defaults: defaults)!
    XCTAssertEqual(DotActions.whatsNext(snapshot, at: now), "Now: Deep work · until 12:20")
    XCTAssertEqual(DotActions.whatsNext(snapshot, at: now.addingTimeInterval(3600)), "Nothing next")
    XCTAssertEqual(
      DotActions.whatsNext(snapshot, at: now.addingTimeInterval(-3600)), "Next up: Deep work · 11:50")
  }

  // CR-160 I7: a Live Activity changes only when its action was queued.

  /// Each refusal the queue can give, set up on [defaults].
  private func refusals(_ queue: DotQueue) -> [(String, () -> Void)] {
    [
      ("deleting", { queue.publishOwner("{\"v\":1,\"refuse\":true}") }),
      ("full", {
        queue.publishOwner("{\"v\":1,\"owner\":\"\(self.ownerA)\"}")
        for i in 0..<DotQueue.capacity { queue.append(DotQueue.entry(.addTask, text: "t\(i)")) }
      }),
      ("unreadable", { self.defaults.set("{not json", forKey: DotStore.queueKey) }),
    ]
  }

  func testLiveDoneAndPlusFifteenChangeTheActivityOnlyWhenQueued() async {
    for kind in [DotActionKind.markDone, .addFifteen] {
      let queue = DotQueue(defaults: defaults)
      // Queued: the activity changes.
      queue.publishOwner("{\"v\":1,\"owner\":\"\(ownerA)\"}")
      var updated = false
      let queued = await DotActions.performLive(
        kind, occurrenceId: live, plannedEnd: now, defaults: defaults
      ) { updated = true }
      XCTAssertTrue(queued, "\(kind)")
      XCTAssertTrue(updated, "\(kind)")
      // Refused: nothing queued, nothing changed, no ticked dot.
      for index in 0..<3 {
        reset()  // a fresh suite and snapshot for each refusal
        let (reason, arrange) = refusals(DotQueue(defaults: defaults))[index]
        arrange()
        let before = defaults.string(forKey: DotStore.queueKey)
        var changed = false
        let ok = await DotActions.performLive(
          kind, occurrenceId: live, plannedEnd: now, defaults: defaults
        ) { changed = true }
        XCTAssertFalse(ok, "\(kind) \(reason)")
        XCTAssertFalse(changed, "\(kind) \(reason): no visual success")
        XCTAssertEqual(defaults.string(forKey: DotStore.queueKey), before, "\(kind) \(reason)")
        XCTAssertEqual(block()["done"] as? Bool, false, "\(kind) \(reason)")
      }
      reset()
    }
  }

  func testAnActionForAnOwnerNotShownIsQueuedAndCounts() async {
    // The marker names someone the app doesn't show right now: still queued
    // (it waits for its owner), so the activity changes as for any queued one.
    let other = "01928c3e-0000-7000-8000-00000000000b"
    DotQueue(defaults: defaults).publishOwner("{\"v\":1,\"owner\":\"\(other)\"}")
    var updated = false
    let queued = await DotActions.performLive(.markDone, occurrenceId: live, defaults: defaults) {
      updated = true
    }
    XCTAssertTrue(queued)
    XCTAssertTrue(updated)
    XCTAssertEqual(DotQueue(defaults: defaults).entries().last?["owner"] as? String, other)
  }

  // CR-160 I7: Siri and Shortcuts say a refused action wasn't saved, and
  // stay silent on success. These run the real intents on the test host's
  // App Group, restored afterwards.

  @available(iOS 16.0, *)
  func testIntentsSayNotSavedOnlyWhenRefused() async throws {
    guard let group = DotStore.shared else { throw XCTSkip("no App Group in this host") }
    let saved = (
      group.string(forKey: DotStore.queueKey), group.string(forKey: DotStore.queueOwnerKey)
    )
    defer {
      group.set(saved.0, forKey: DotStore.queueKey)
      group.set(saved.1, forKey: DotStore.queueOwnerKey)
    }
    let endMs = Int(now.timeIntervalSince1970 * 1000)
    let runs: [(String, () async throws -> Void)] = [
      ("done", { _ = try await MarkDoneIntent(occurrenceId: self.live).perform() }),
      ("plus15", {
        _ = try await AddFifteenIntent(occurrenceId: self.live, plannedEndMs: endMs).perform()
      }),
      ("start", { _ = try await StartFocusIntent(occurrenceId: self.live).perform() }),
    ]
    let queue = DotQueue(defaults: group)
    for (name, run) in runs {
      group.removeObject(forKey: DotStore.queueKey)
      queue.publishOwner("{\"v\":1,\"owner\":\"\(ownerA)\"}")
      try await run()  // queued: no error, no dialog (unchanged)
      XCTAssertEqual(queue.entries().count, 1, name)
      queue.publishOwner("{\"v\":1,\"refuse\":true}")
      do {
        try await run()
        XCTFail("\(name): a refused action must not look done")
      } catch let error as NotSavedError {
        let said = String(localized: error.localizedStringResource)
        XCTAssertFalse(said.isEmpty, name)
        XCTAssertFalse(said.contains(live), "\(name): no task id")
        XCTAssertFalse(said.contains(ownerA), "\(name): no account")
      }
      XCTAssertEqual(queue.entries().count, 1, "\(name): nothing queued when refused")
    }
  }

  // MARK: - Queued words sealed at rest (CR-160 I1, Q3)

  private func stored() -> String? {
    CFPreferencesAppSynchronize(suite as CFString)
    return defaults.string(forKey: DotStore.queueKey)
  }

  private func opened(_ queue: DotQueue) -> [[String: Any]] {
    let raw = queue.readForApp() ?? "[]"
    return (try! JSONSerialization.jsonObject(with: Data(raw.utf8)) as! [Any])
      .compactMap { $0 as? [String: Any] }
  }

  private func writeRaw(_ entries: [[String: Any]]) {
    let data = try! JSONSerialization.data(withJSONObject: entries)
    defaults.set(String(data: data, encoding: .utf8), forKey: DotStore.queueKey)
  }

  private let owner = "01928c3e-0000-7000-8000-00000000000a"

  func testAShareIsSealedAtRestOpenedForTheAppOwnerKept() {
    let queue = DotQueue(defaults: defaults, suite: suite)
    queue.publishOwner(#"{"v":1,"owner":"\#(owner)"}"#)
    let entry = ShareQueue.entry(text: "Secret plan", link: nil, subject: "Page title", now: now)!
    XCTAssertTrue(queue.append(entry))
    let raw = stored() ?? ""
    XCTAssertFalse(raw.contains("Secret plan"))
    XCTAssertFalse(raw.contains("Page title"))
    let app = opened(queue).single
    XCTAssertEqual(app?["text"] as? String, "Secret plan")
    XCTAssertEqual(app?["subject"] as? String, "Page title")
    XCTAssertEqual(app?["owner"] as? String, owner)
    XCTAssertNil(app?["sealed"])
  }

  func testEverySealIsFresh() {
    let queue = DotQueue(defaults: defaults, suite: suite)
    queue.append(DotQueue.entry(.addTask, text: "Same", now: now))
    queue.append(DotQueue.entry(.addTask, text: "Same", now: now))
    let seals = queue.entries().compactMap { ($0["sealed"] as? [String: Any])?["ct"] as? String }
    XCTAssertEqual(seals.count, 2)
    XCTAssertNotEqual(seals[0], seals[1])
  }

  func testAnExtensionSealsWithThePublicKeyOnly() {
    let (id, key) = QueueSeal.publishedKey(defaults)!
    let entry = DotQueue.entry(.addTask, text: "From the share sheet", now: now)
    let sealed = QueueSeal.seal(entry, keyId: id, publicKey: key)!
    XCTAssertNil(sealed["text"])
    XCTAssertEqual(QueueSeal.open(sealed)["text"] as? String, "From the share sheet")
  }

  func testWithNoPublishedKeyTextIsRefusedIdsStillQueue() {
    defaults.removeObject(forKey: QueueSeal.publicKeyKey)
    let queue = DotQueue(defaults: defaults, suite: suite)
    XCTAssertFalse(queue.append(DotQueue.entry(.addTask, text: "No key", now: now)))
    XCTAssertTrue(queue.append(DotQueue.entry(.markDone, occurrenceId: live, now: now)))
    XCTAssertFalse((stored() ?? "").contains("No key"))
  }

  func testAnEarlierVersionsPlaintextIsSealedInPlaceIdempotently() {
    let legacy: [[String: Any]] = [
      ["id": "01928c3e-0000-7000-8000-0000000009a1", "at_ms": 1, "kind": "add_task",
       "shared": true, "text": "Old share", "owner": owner],
      ["id": "01928c3e-0000-7000-8000-0000000009a2", "at_ms": 2, "kind": "add_task",
       "text": "No owner"],
      ["id": "01928c3e-0000-7000-8000-0000000009a3", "at_ms": 3, "kind": "mark_done",
       "occurrence_id": live],
    ]
    writeRaw(legacy)
    let queue = DotQueue(defaults: defaults, suite: suite)
    let app = opened(queue)
    let raw = stored() ?? ""
    XCTAssertFalse(raw.contains("Old share"))
    XCTAssertFalse(raw.contains("No owner"))
    let kept = queue.entries()
    XCTAssertEqual(kept.map { $0["id"] as? String }, legacy.map { $0["id"] as? String })
    XCTAssertEqual(kept.map { $0["owner"] as? String }, [owner, nil, nil])
    XCTAssertNil(kept[2]["sealed"], "ids only")
    XCTAssertEqual(app.map { $0["text"] as? String }, ["Old share", "No owner", nil])
    XCTAssertNil(app[1]["owner"], "never attributed")
    _ = opened(queue)
    XCTAssertEqual(stored(), raw, "idempotent")
  }

  func testAChangedOwnerStampNoLongerOpens() {
    let queue = DotQueue(defaults: defaults, suite: suite)
    queue.publishOwner(#"{"v":1,"owner":"\#(owner)"}"#)
    queue.append(DotQueue.entry(.addTask, text: "Secret", now: now))
    var entry = queue.entries().single!
    entry["owner"] = "01928c3e-0000-7000-8000-00000000000b"
    writeRaw([entry])
    let app = opened(queue).single
    XCTAssertEqual(app?["unreadable"] as? Bool, true)
    XCTAssertNil(app?["text"])
    XCTAssertEqual(queue.entries().count, 1, "never erased")
  }

  func testALostKeyKeepsEntriesUnreadableAndANewKeyIsMade() {
    let queue = DotQueue(defaults: defaults, suite: suite)
    queue.append(DotQueue.entry(.addTask, text: "Before", now: now))
    let (oldId, _) = QueueSeal.publishedKey(defaults)!
    QueueSeal.deleteKey(oldId)
    let app = opened(queue)
    XCTAssertEqual(app.single?["unreadable"] as? Bool, true)
    XCTAssertNotEqual(QueueSeal.publishedKey(defaults)?.id, oldId, "a new pair")
    XCTAssertTrue(queue.append(DotQueue.entry(.addTask, text: "After", now: now)))
    let now2 = opened(queue)
    XCTAssertEqual(now2.count, 2)
    XCTAssertEqual(now2[0]["unreadable"] as? Bool, true)
    XCTAssertEqual(now2[1]["text"] as? String, "After")
  }

  func testOldKeysKeepOpeningAfterANewKey() {
    let queue = DotQueue(defaults: defaults, suite: suite)
    queue.append(DotQueue.entry(.addTask, text: "Old key", now: now))
    defaults.removeObject(forKey: QueueSeal.publicKeyKey)
    XCTAssertTrue(QueueSeal.ensureKey(defaults, suite: suite))
    queue.append(DotQueue.entry(.addTask, text: "New key", now: now))
    XCTAssertEqual(opened(queue).map { $0["text"] as? String }, ["Old key", "New key"])
  }

  func testConcurrentSharesAndAppReadsLoseNothing() {
    let queue = DotQueue(defaults: defaults, suite: suite)
    DispatchQueue.concurrentPerform(iterations: 60) { i in
      if i % 3 == 0 { _ = queue.readForApp() }
      queue.append(DotQueue.entry(.addTask, text: "t\(i)", now: now))
    }
    let texts = opened(queue).compactMap { $0["text"] as? String }
    XCTAssertEqual(Set(texts).count, 60)
    XCTAssertFalse((stored() ?? "").contains("\"text\""))
  }
}

extension Array {
  fileprivate var single: Element? { count == 1 ? first : nil }
}
