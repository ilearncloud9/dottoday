import Flutter
import UIKit

/// More colours… on iPhone and iPad (owner, native pass): iOS's own
/// colour picker (grid, spectrum, sliders and its eyedropper) over
/// `dottoday/colour_sampler` (lib/data/look/colour_sampler_channel.dart).
/// `system` starts at the `#RRGGBB` sent and answers the picked colour
/// when it closes, or nil when it didn't change.
final class ColourPickerBridge: NSObject, UIColorPickerViewControllerDelegate {
  static let shared = ColourPickerBridge()
  private var channel: FlutterMethodChannel?
  private var pending: FlutterResult?
  private var start: UIColor?

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "dottoday/colour_sampler", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self, call.method == "system", let top = Self.topController() else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.pending?(nil)
      self.pending = result
      let picker = UIColorPickerViewController()
      picker.supportsAlpha = false
      if let hex = call.arguments as? String, let colour = Self.colour(hex) {
        picker.selectedColor = colour
        self.start = colour
      }
      picker.delegate = self
      top.present(picker, animated: true)
    }
    self.channel = channel
  }

  func colorPickerViewControllerDidFinish(_ picker: UIColorPickerViewController) {
    let hex = Self.hex(picker.selectedColor)
    pending?(hex == start.flatMap(Self.hex) ? nil : hex)
    pending = nil
  }

  private static func hex(_ colour: UIColor) -> String? {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    guard colour.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
    let v = [r, g, b].map { Swift.min(Swift.max(Int(($0 * 255).rounded()), 0), 255) }
    return String(format: "#%02X%02X%02X", v[0], v[1], v[2])
  }

  private static func colour(_ hex: String) -> UIColor? {
    guard hex.count == 7, let v = Int(hex.dropFirst(), radix: 16) else { return nil }
    return UIColor(
      red: CGFloat((v >> 16) & 0xFF) / 255, green: CGFloat((v >> 8) & 0xFF) / 255,
      blue: CGFloat(v & 0xFF) / 255, alpha: 1)
  }

  private static func topController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let window = scenes.flatMap(\.windows).first { $0.isKeyWindow } ?? scenes.first?.windows.first
    var top = window?.rootViewController
    while let next = top?.presentedViewController { top = next }
    return top
  }
}
