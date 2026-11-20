import Cocoa
import FlutterMacOS

/// Custom colour…'s eyedropper and Show Colours… on the Mac (ED-156,
/// M19.4 part 4c-3): the system's own screen sampler and Colours panel
/// over `dottoday/colour_sampler` (lib/data/look/colour_sampler.dart).
/// Colours travel as `#RRGGBB` in sRGB; the panel's picks come back as
/// `panel` while it is open.
final class ColourSamplerBridge: NSObject {
  private var channel: FlutterMethodChannel?
  private var sampler: NSColorSampler?

  func attach(to controller: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "dottoday/colour_sampler", binaryMessenger: controller.engine.binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return }
      switch call.method {
      case "sample": self.sample(result)
      case "openPanel":
        self.openPanel(hex: call.arguments as? String)
        result(nil)
      case "closePanel":
        self.closePanel()
        result(nil)
      default: result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
  }

  /// The loupe over the whole screen; nil when Esc cancels it.
  private func sample(_ result: @escaping FlutterResult) {
    let sampler = NSColorSampler()
    self.sampler = sampler
    sampler.show { [weak self] picked in
      self?.sampler = nil
      result(picked.flatMap(Self.hex))
    }
  }

  private func openPanel(hex: String?) {
    let panel = NSColorPanel.shared
    panel.showsAlpha = false
    if let hex, let colour = Self.colour(hex) { panel.color = colour }
    panel.setTarget(self)
    panel.setAction(#selector(panelChanged(_:)))
    panel.orderFront(nil)
  }

  private func closePanel() {
    let panel = NSColorPanel.shared
    panel.setTarget(nil)
    panel.setAction(nil)
    panel.orderOut(nil)
  }

  @objc private func panelChanged(_ panel: NSColorPanel) {
    guard let hex = Self.hex(panel.color) else { return }
    channel?.invokeMethod("panel", arguments: hex)
  }

  private static func hex(_ colour: NSColor) -> String? {
    guard let c = colour.usingColorSpace(.sRGB) else { return nil }
    let v = [c.redComponent, c.greenComponent, c.blueComponent].map {
      Int(($0 * 255).rounded()).clamped(0, 255)
    }
    return String(format: "#%02X%02X%02X", v[0], v[1], v[2])
  }

  private static func colour(_ hex: String) -> NSColor? {
    guard let v = Int(hex.dropFirst(), radix: 16), hex.count == 7 else { return nil }
    return NSColor(
      srgbRed: CGFloat((v >> 16) & 0xFF) / 255, green: CGFloat((v >> 8) & 0xFF) / 255,
      blue: CGFloat(v & 0xFF) / 255, alpha: 1)
  }
}

extension Int {
  fileprivate func clamped(_ low: Int, _ high: Int) -> Int { Swift.min(Swift.max(self, low), high) }
}
