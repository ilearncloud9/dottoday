import XCTest

@testable import dottoday

/// The Now mini window's rule and actions (E-Minimal, ED-475): which moment
/// it shows, and what Done and +5 / +15 / +30 send back to the app.
final class NowMiniModelTests: XCTestCase {
  private let m = 60_000.0
  private var now: Double { Date().timeIntervalSince1970 * 1000 }

  private func block(_ id: String, from: Double, len: Double, done: Bool = false) -> [String: Any] {
    ["id": id, "title": id, "start_ms": now + from * m, "end_ms": now + (from + len) * m, "done": done]
  }

  private func model(_ blocks: [[String: Any]], sent: ((([String: Any]) -> Void))? = nil) -> NowMiniModel {
    let model = NowMiniModel(act: sent ?? { _ in })
    model.snapshot = ["v": 1, "blocks": blocks]
    return model
  }

  private func id(_ moment: NowMiniModel.Moment) -> String {
    switch moment {
    case let .running(b, _): return "running:\(b["id"]!)"
    case let .ended(b, _, _): return "ended:\(b["id"]!)"
    case let .upcoming(b): return "upcoming:\(b["id"]!)"
    case .nothing: return "nothing"
    }
  }

  func testUnderWayComesFirst() {
    let moment = model([block("a", from: -10, len: 30), block("b", from: 40, len: 10)]).moment
    XCTAssertEqual(id(moment), "running:a")
    if case let .running(_, next) = moment { XCTAssertEqual(next?["id"] as? String, "b") }
  }

  func testEndedUntickedWithinTheHour() {
    XCTAssertEqual(id(model([block("a", from: -40, len: 30), block("b", from: 20, len: 10)]).moment), "ended:a")
    // Over an hour ago, or ticked: the next task instead.
    XCTAssertEqual(id(model([block("a", from: -100, len: 30), block("b", from: 20, len: 10)]).moment), "upcoming:b")
    XCTAssertEqual(id(model([block("a", from: -40, len: 30, done: true), block("b", from: 20, len: 10)]).moment), "upcoming:b")
  }

  func testNothingLeft() {
    XCTAssertEqual(id(model([block("a", from: -300, len: 30, done: true)]).moment), "nothing")
  }

  func testButtonsSendTheIntents() {
    var sent: [[String: Any]] = []
    let a = block("a", from: -10, len: 30)
    let model = model([a]) { sent.append($0) }
    model.more(a, minutes: 30)
    model.done(a)
    XCTAssertEqual(sent[0]["kind"] as? String, "add_time")
    XCTAssertEqual(sent[0]["minutes"] as? Int, 30)
    XCTAssertEqual(sent[0]["planned_end_ms"] as? Double, a["end_ms"] as? Double)
    XCTAssertEqual(sent[1]["kind"] as? String, "mark_done")
    XCTAssertEqual(sent[1]["id"] as? String, "a")
  }
}
