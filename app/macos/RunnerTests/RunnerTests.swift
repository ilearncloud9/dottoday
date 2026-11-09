import Cocoa
import FlutterMacOS
import XCTest

@testable import dottoday

/// The Mac share extension's queue (docs/09 M12.4) and its owner (CR-160
/// I7): what `ShareQueue.append` writes carries the owner the app
/// published, through the App Group lock the extension and the app share.
final class RunnerTests: XCTestCase {
  private var defaults: UserDefaults!
  private let suite = "RunnerTests.queue"
  private let ownerA = "01928c3e-0000-7000-8000-00000000000a"

  override func setUp() {
    super.setUp()
    defaults = UserDefaults(suiteName: suite)
    defaults.removePersistentDomain(forName: suite)
  }

  func testAShareCarriesThePublishedOwner() {
    let queue = DotQueue(defaults: defaults)
    queue.publishOwner("{\"v\":1,\"owner\":\"\(ownerA)\"}")
    ShareQueue.entry(text: "Dentist", link: "https://dentist.example", subject: nil)
      .map(queue.append)
    let entry = queue.entries()[0]
    XCTAssertEqual(entry["owner"] as? String, ownerA)
    XCTAssertEqual(entry["shared"] as? Bool, true)
  }

  func testDuringAChangeOfOwnerTheShareNamesNobody() {
    let queue = DotQueue(defaults: defaults)
    queue.publishOwner("{\"v\":1,\"switching\":true}")
    ShareQueue.entry(text: "Dentist", link: nil, subject: nil).map(queue.append)
    XCTAssertNil(queue.entries()[0]["owner"])
  }

  func testAppendsFromManyThreadsAndRemovesLoseNothing() {
    let queue = DotQueue(defaults: defaults)
    queue.publishOwner("{\"v\":1,\"owner\":\"\(ownerA)\"}")
    let seeded = (0..<25).map { DotQueue.entry(.addTask, text: "old\($0)") }
    seeded.forEach { queue.append($0) }
    let ids = seeded.map { $0["id"] as! String }
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      queue.append(DotQueue.entry(.addTask, text: "t\(i)"))
      if i % 4 == 0 { queue.remove([ids[i / 4]]) }
    }
    // 25 seeded, all removed; 100 appended meanwhile, none lost.
    let texts = queue.entries().compactMap { $0["text"] as? String }
    XCTAssertEqual(texts.count, 100)
    XCTAssertFalse(texts.contains { $0.hasPrefix("old") })
  }
}
