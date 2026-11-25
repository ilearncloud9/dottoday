import SwiftUI
import UIKit

/// Concept A tokens (lib/core/theme/tokens.dart).
enum Dot {
  static let surface = Color(light: 0xFAFAF8, dark: 0x121214)
  static let ink = Color(light: 0x1A1A1C, dark: 0xF2F2F0)
  static let muted = Color(light: 0x6B6B70, dark: 0x9A9AA0)
  static let hairline = Color(light: 0xE2E2DE, dark: 0x2C2C32)
  static let accent = Color(light: 0x3B6CF6, dark: 0x7FA0FF)
  /// The +15 button's fill (Concept A secondary button).
  static let secondary = Color(light: 0xE2E2DE, dark: 0x2C2C32)
}

extension Color {
  init(light: UInt32, dark: UInt32) {
    self.init(UIColor { traits in
      UIColor(rgb: traits.userInterfaceStyle == .dark ? dark : light)
    })
  }

  init(hex: String) {
    self.init(UIColor(rgb: UInt32(hex.dropFirst(), radix: 16) ?? 0x3B6CF6))
  }
}

extension UIColor {
  convenience init(rgb: UInt32) {
    self.init(
      red: CGFloat((rgb >> 16) & 0xFF) / 255,
      green: CGFloat((rgb >> 8) & 0xFF) / 255,
      blue: CGFloat(rgb & 0xFF) / 255,
      alpha: 1)
  }
}


/// The dawn of Wake Up's snooze Live Activity (E-R2-19-B, E-R2-19-B-Dark;
/// lib/core/theme/dot_dawn.dart `DawnSky`): night plum through rose to the
/// first light, deeper in dark mode, with white words and the sun-yellow
/// sun and time left.
enum Dawn {
  static let top = Color(light: 0x2E3A6B, dark: 0x121833)
  static let middle = Color(light: 0xB86B6B, dark: 0x5E3442)
  static let bottom = Color(light: 0xF2B27A, dark: 0x9A5A3A)
  static let ink = Color(light: 0xFEFEFE, dark: 0xFEFEFE)
  static let sun = Color(light: 0xFFD27A, dark: 0xFFD27A)
  static let track = Color.white.opacity(0.18)

  static var gradient: LinearGradient {
    LinearGradient(
      stops: [.init(color: top, location: 0), .init(color: middle, location: 0.55), .init(color: bottom, location: 1)],
      startPoint: .top, endPoint: .bottom)
  }
}

/// Manrope, Concept E's type (ED-110), bundled with the widgets as the
/// app's own variable font; its weight is set on the font's axis.
enum Manrope {
  static func font(_ size: CGFloat, _ weight: Font.Weight) -> Font {
    let value: CGFloat =
      switch weight {
      case .heavy: 800
      case .bold: 700
      default: 600
      }
    let base = UIFontDescriptor(fontAttributes: [.family: "Manrope"])
    let wght = 0x7767_6874  // 'wght'
    let descriptor = base.addingAttributes([
      UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): [wght: value]
    ])
    return Font(UIFont(descriptor: descriptor, size: size))
  }
}
