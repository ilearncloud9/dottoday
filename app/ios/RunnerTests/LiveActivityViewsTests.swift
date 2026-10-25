import SwiftUI
import XCTest

@testable import Runner

/// Snapshot tests of the Live Activity layouts (docs/09 M9.3,
/// B-ios-live-activity.png): lock screen, Dynamic Island expanded,
/// compact and minimal, light and dark, at the render's moment (10:22,
/// Deep work 9:00–11:00, 38 min left, 1 of 3). References live in
/// LiveActivitySnapshots/; a missing one is recorded (and the test fails
/// once so the recording is noticed). RECORD_SNAPSHOTS=1 re-records all.
@MainActor
final class LiveActivityViewsTests: XCTestCase {
  private let now = Date(timeIntervalSince1970: 1_792_570_920)  // 2026-10-21 08:22Z

  private var state: LiveDotState {
    let json = """
      {"id":"01928c3e-0000-7000-8000-0000000000b1","title":"Deep work: roadmap",
      "color":"#3B6CF6","icon":"code","start_ms":1792566000000,"end_ms":1792573200000,
      "ends_ms":1792575000000,"live":true,"range":"9:00 – 11:00",
      "range_pattern":"{start} – {end}","format":{"tz":"Europe/Berlin","locale":"en","hour24":true},
      "left_before":"","left_after":" left","starts_before":"starts in ","starts_after":"",
      "count":"1 of 3","count_label":"1 of 3 done today","done_share":0.3333,
      "done_label":"Done","plus_label":"+15 min","plus_short":"+15",
      "next":[{"id":"01928c3e-0000-7000-8000-0000000000b2","title":"Reply to email","color":"#E5674F","time":"11:00"}]}
      """
    return LiveDotState.decode(json)!
  }

  func testStateDecodesAndPlusFifteenMovesTheRange() {
    let plus = state.plusFifteen()
    XCTAssertEqual(plus.range, "09:00 – 11:15")
    XCTAssertEqual(plus.endMs - state.endMs, 15 * 60_000)
    XCTAssertEqual(plus.endsMs - state.endsMs, 15 * 60_000)
  }

  func testLockScreen() throws {
    try check("lock_screen", width: 360) {
      LiveLockScreenView(state: state, frozenAt: now).background(Dot.surface)
    }
  }

  func testIslandExpanded() throws {
    try check("island_expanded", width: 370) {
      LiveIslandExpandedPreview(state: state, frozenAt: now)
    }
  }

  func testIslandCompact() throws {
    try check("island_compact", width: 220) {
      LiveIslandCompactPreview(state: state, frozenAt: now)
    }
  }

  func testIslandMinimal() throws {
    try check("island_minimal", width: 40) {
      LiveRing(state: state, size: 22, now: now).padding(9).background(Circle().fill(.black))
    }
  }

  // MARK: - Golden support

  private func check<V: View>(_ name: String, width: CGFloat, view: () -> V) throws {
    for scheme in [ColorScheme.light, .dark] {
      let file = "\(name)_\(scheme == .light ? "light" : "dark").png"
      let renderer = ImageRenderer(
        content: view().frame(width: width).environment(\.colorScheme, scheme)
          .environment(\.locale, Locale(identifier: "en_GB"))
          .environment(\.timeZone, TimeZone(identifier: "Europe/Berlin")!))
      renderer.scale = 2
      let image = try XCTUnwrap(renderer.uiImage?.pngData(), "\(file) did not render")
      let reference = Self.snapshots.appendingPathComponent(file)
      let record = ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1"
      if record || !FileManager.default.fileExists(atPath: reference.path) {
        try FileManager.default.createDirectory(at: Self.snapshots, withIntermediateDirectories: true)
        try image.write(to: reference)
        if !record { XCTFail("Recorded \(file); run again to compare.") }
        continue
      }
      let diff = try Self.difference(image, try Data(contentsOf: reference))
      if diff > 0.005 {
        let actual = FileManager.default.temporaryDirectory.appendingPathComponent(file)
        try image.write(to: actual)
        XCTFail("\(file) differs in \(Int(diff * 100))% of pixels; actual at \(actual.path)")
      }
    }
  }

  private static let snapshots = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().appendingPathComponent("LiveActivitySnapshots")

  /// Share of pixels whose RGBA differ by more than 8 / 255 (anti-aliasing
  /// moves a little between Xcode versions); 1 when the sizes differ.
  private static func difference(_ a: Data, _ b: Data) throws -> Double {
    let (pa, wa, ha) = try rgba(a)
    let (pb, wb, hb) = try rgba(b)
    guard wa == wb, ha == hb else { return 1 }
    var differing = 0
    for i in stride(from: 0, to: pa.count, by: 4) {
      let delta = (0..<4).map { abs(Int(pa[i + $0]) - Int(pb[i + $0])) }.max() ?? 0
      if delta > 8 { differing += 1 }
    }
    return Double(differing) / Double(wa * ha)
  }

  private static func rgba(_ png: Data) throws -> ([UInt8], Int, Int) {
    let image = try XCTUnwrap(UIImage(data: png)?.cgImage)
    let (w, h) = (image.width, image.height)
    var pixels = [UInt8](repeating: 0, count: w * h * 4)
    let context = try XCTUnwrap(
      CGContext(
        data: &pixels, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
        space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
    context.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
    return (pixels, w, h)
  }
}
