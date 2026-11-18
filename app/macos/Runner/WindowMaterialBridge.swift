import Cocoa
import FlutterMacOS

/// The Mac sidebar's material (ED-130, ED-176): the window's content sits on
/// an `NSVisualEffectView` in the sidebar material, and Flutter paints every
/// part of the window opaque except the sidebar, which carries the warm tint
/// over it (lib/shared/navigation/sidebar_material.dart).
///
/// Over `dottoday/window_material`:
/// - `vibrant` answers whether the material may show: not with Reduce
///   Transparency or Increase Contrast on, where Flutter paints the sidebar
///   solid instead; `changed` tells Flutter when either setting changes.
/// - `appearance` (`light`, `dark`) gives the window the app's own theme,
///   so the material and the title bar match a theme chosen in Settings
///   rather than the system's.
final class WindowMaterialBridge: NSObject {
  private var channel: FlutterMethodChannel?
  private weak var window: NSWindow?
  private var observer: NSObjectProtocol?

  /// The view the Flutter view sits in, filling the window.
  static func backdrop() -> NSVisualEffectView {
    let view = NSVisualEffectView()
    view.material = .sidebar
    view.blendingMode = .behindWindow
    view.state = .followsWindowActiveState
    return view
  }

  func attach(to controller: FlutterViewController, in window: NSWindow) {
    self.window = window
    let channel = FlutterMethodChannel(
      name: "dottoday/window_material", binaryMessenger: controller.engine.binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return result(nil) }
      switch call.method {
      case "vibrant":
        result(Self.vibrant)
      case "appearance":
        self.setAppearance(call.arguments as? String)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
    observer = NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
      object: nil, queue: .main
    ) { [weak self] _ in
      self?.channel?.invokeMethod("changed", arguments: Self.vibrant)
    }
  }

  deinit {
    if let observer { NSWorkspace.shared.notificationCenter.removeObserver(observer) }
  }

  private static var vibrant: Bool {
    let workspace = NSWorkspace.shared
    return !workspace.accessibilityDisplayShouldReduceTransparency
      && !workspace.accessibilityDisplayShouldIncreaseContrast
  }

  private func setAppearance(_ name: String?) {
    switch name {
    case "light": window?.appearance = NSAppearance(named: .aqua)
    case "dark": window?.appearance = NSAppearance(named: .darkAqua)
    default: window?.appearance = nil
    }
  }
}
