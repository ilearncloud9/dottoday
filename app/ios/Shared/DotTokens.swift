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

