import XCTest

@testable import Runner

/// The widgets' timeline (docs/09 M5.4, M9.5): what Next up shows when,
/// where the timeline redraws, and the dot Siri's "Mark my task done" and
/// the Start focus control act on.
final class WidgetSnapshotTests: XCTestCase {
  private let base = Date(timeIntervalSince1970: 1_792_566_000)  // 07:00Z
  private var defaults: UserDefaults!

  private func block(_ id: String, _ startMin: Double, _ minutes: Double, done: Bool = false)
    -> [String: Any]
  {
    let start = (base.timeIntervalSince1970 + startMin * 60) * 1000
    return [
      "id": id, "title": id, "start_ms": start, "end_ms": start + minutes * 60_000,
      "time": "", "until": "", "color": "#3B6CF6", "done": done,
    ]
  }

  private func store(_ blocks: [[String: Any]]) -> Snapshot {
    let json: [String: Any] = ["v": 1, "inbox_count": 2, "labels": ["done": "Done"], "blocks": blocks]
    let data = try! JSONSerialization.data(withJSONObject: json)
    defaults.set(String(data: data, encoding: .utf8), forKey: DotStore.snapshotKey)
    return try! JSONDecoder().decode(Snapshot.self, from: data)
  }

  override func setUp() {
    super.setUp()
    defaults = UserDefaults(suiteName: "WidgetSnapshotTests")
    defaults.removePersistentDomain(forName: "WidgetSnapshotTests")
  }

  private func at(_ minutes: Double) -> Date { base.addingTimeInterval(minutes * 60) }

  func testLiveNextAndBoundaries() {
    let s = store([block("deep", 0, 120), block("done", 130, 10, done: true), block("reply", 150, 30)])
    XCTAssertEqual(s.live(at: at(30))?.id, "deep")
    XCTAssertEqual(s.next(at: at(30))?.id, "reply")
    XCTAssertNil(s.live(at: at(135)))
    XCTAssertEqual(s.boundaries(after: at(30)), [at(120), at(130), at(140), at(150), at(180)])
    XCTAssertEqual(s.label("done"), "Done")
  }

  func testCurrentBlockForSiriAndTheControl() {
    _ = store([block("deep", 0, 120), block("reply", 150, 30)])
    XCTAssertEqual(DotActions.currentBlock(at: at(30), defaults: defaults)?.id, "deep")
    XCTAssertEqual(
      DotActions.currentBlock(at: at(30), defaults: defaults)?.endMs,
      (base.timeIntervalSince1970 + 120 * 60) * 1000)
    XCTAssertNil(DotActions.currentBlock(at: at(130), defaults: defaults))
    XCTAssertEqual(DotActions.currentBlock(orNext: true, at: at(130), defaults: defaults)?.id, "reply")
  }
}
