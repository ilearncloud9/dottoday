import Cocoa
import XCTest

@testable import dottoday

/// Goldens of the menu-bar day dot (docs/09 M9.6): empty, half and full,
/// on a light and a dark menu bar (a template image: the bar tints it
/// black or white). References in DayDotSnapshots/; a missing one fails
/// and is recorded in the test host's temporary folder.
final class DayDotImageTests: XCTestCase {
  private static let bars: [(name: String, background: NSColor, tint: NSColor)] = [
    ("light", NSColor(white: 0.93, alpha: 1), .black),
    ("dark", NSColor(white: 0.16, alpha: 1), .white),
  ]

  func testDayDotAt0And50And100Percent() throws {
    for share in [0.0, 0.5, 1.0] {
      for bar in Self.bars {
        try check("day_dot_\(Int(share * 100))_\(bar.name).png", share: share, bar: bar)
      }
    }
  }

  func testDayShareFollowsWakeUpToBedtime() {
    let snapshot: [String: Any] = ["wake_ms": 1000.0, "bed_ms": 3000.0]
    XCTAssertEqual(DayDotStatusItem.dayShare(snapshot, now: 500), 0)
    XCTAssertEqual(DayDotStatusItem.dayShare(snapshot, now: 2000), 0.5)
    XCTAssertEqual(DayDotStatusItem.dayShare(snapshot, now: 9000), 1)
    XCTAssertEqual(DayDotStatusItem.dayShare([:], now: 2000), 0)
  }

  func testTheImageIsATemplate() {
    XCTAssertTrue(DayDotImage.make(share: 0.3).isTemplate)
  }

  private func check(
    _ file: String, share: Double, bar: (name: String, background: NSColor, tint: NSColor)
  ) throws {
    let png = try render(share: share, background: bar.background, tint: bar.tint)
    let reference = Self.snapshots.appendingPathComponent(file)
    guard FileManager.default.fileExists(atPath: reference.path) else {
      // The sandboxed test host can't write the source tree: the recording
      // goes to its temporary folder, to copy into DayDotSnapshots/.
      let recorded = FileManager.default.temporaryDirectory.appendingPathComponent(file)
      try png.write(to: recorded)
      return XCTFail("No reference for \(file); recorded at \(recorded.path)")
    }
    let diff = try Self.difference(png, try Data(contentsOf: reference))
    XCTAssertLessThanOrEqual(diff, 0.01, "\(file) differs in \(Int(diff * 100))% of pixels")
  }

  /// The template drawn as the menu bar draws it: tinted, on the bar, at 2x.
  private func render(share: Double, background: NSColor, tint: NSColor) throws -> Data {
    let size = 22
    let rep = try XCTUnwrap(
      NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: size * 2, pixelsHigh: size * 2, bitsPerSample: 8,
        samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
        bytesPerRow: 0, bitsPerPixel: 0))
    rep.size = NSSize(width: size, height: size)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    background.setFill()
    NSRect(x: 0, y: 0, width: size, height: size).fill()
    let image = DayDotImage.make(share: share)
    let tinted = NSImage(size: image.size, flipped: false) { rect in
      image.draw(in: rect)
      tint.set()
      rect.fill(using: .sourceAtop)
      return true
    }
    tinted.draw(in: NSRect(x: 3, y: 3, width: 16, height: 16))
    NSGraphicsContext.restoreGraphicsState()
    return try XCTUnwrap(rep.representation(using: .png, properties: [:]))
  }

  /// Share of pixels off by more than 8 / 255 in any channel; 1 when the
  /// sizes differ (anti-aliasing may move a little between macOS versions).
  private static func difference(_ a: Data, _ b: Data) throws -> Double {
    let ra = try XCTUnwrap(NSBitmapImageRep(data: a))
    let rb = try XCTUnwrap(NSBitmapImageRep(data: b))
    guard ra.pixelsWide == rb.pixelsWide, ra.pixelsHigh == rb.pixelsHigh else { return 1 }
    var off = 0
    for x in 0..<ra.pixelsWide {
      for y in 0..<ra.pixelsHigh {
        guard let ca = ra.colorAt(x: x, y: y), let cb = rb.colorAt(x: x, y: y) else { continue }
        let delta = max(
          abs(ca.redComponent - cb.redComponent), abs(ca.greenComponent - cb.greenComponent),
          abs(ca.blueComponent - cb.blueComponent), abs(ca.alphaComponent - cb.alphaComponent))
        if delta > 8.0 / 255 { off += 1 }
      }
    }
    return Double(off) / Double(ra.pixelsWide * ra.pixelsHigh)
  }

  private static let snapshots = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().appendingPathComponent("DayDotSnapshots")
}
