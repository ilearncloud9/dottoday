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
/// - `titlebar` answers the height of the transparent title bar the
///   content runs under (ED-377), and is sent again when it changes (full
///   screen hides it). Flutter keeps that strip free of controls: the
///   system drags the window there.
final class WindowMaterialBridge: NSObject {
  private var channel: FlutterMethodChannel?
  private weak var window: NSWindow?
  private var observer: NSObjectProtocol?
  private var windowObservers: [NSObjectProtocol] = []

  /// The view the Flutter view sits in, filling the window.
  static func backdrop() -> NSVisualEffectView {
    let view = NSVisualEffectView()
    view.material = .sidebar
    view.blendingMode = .behindWindow
    view.state = .followsWindowActiveState
    return view
  }

  /// The sidebar runs the window's full height, under the window buttons
  /// (E-v1.45 Mac Full Workspace, ED-377): the content fills the window
  /// and the title bar is transparent, with no title.
  static func unify(_ window: NSWindow, over flutter: NSView) {
    window.styleMask.insert(.fullSizeContentView)
    window.titlebarAppearsTransparent = true
    window.titleVisibility = .hidden
    guard let root = flutter.superview else { return }
    let strip = TitlebarDragStrip()
    root.addSubview(strip, positioned: .above, relativeTo: flutter)
    strip.fit()
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
      case "titlebar":
        result(self.titlebar)
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
    for name in [NSWindow.didEnterFullScreenNotification, NSWindow.didExitFullScreenNotification] {
      windowObservers.append(
        NotificationCenter.default.addObserver(forName: name, object: window, queue: .main) {
          [weak self] _ in
          guard let self else { return }
          self.window?.contentView?.subviews
            .compactMap { $0 as? TitlebarDragStrip }.forEach { $0.fit() }
          self.channel?.invokeMethod("titlebar", arguments: self.titlebar)
        })
    }
  }

  deinit {
    if let observer { NSWorkspace.shared.notificationCenter.removeObserver(observer) }
    windowObservers.forEach(NotificationCenter.default.removeObserver)
  }

  /// The strip above the window's layout area, in points; 0 in full screen.
  private var titlebar: Double {
    guard let window else { return 0 }
    return Double(TitlebarDragStrip.height(of: window))
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

/// The title bar's strip over the Flutter view (ED-377). Under a transparent
/// title bar the Flutter view would take the mouse there, so the window
/// couldn't be dragged; this strip gives drags to the window and a double
/// click to the system's choice (System Settings › Desktop & Dock). The
/// window buttons sit above it, in the title bar itself.
final class TitlebarDragStrip: NSView {
  static func height(of window: NSWindow) -> CGFloat {
    window.frame.height - window.contentLayoutRect.height
  }

  /// Spans the top of its superview at the title bar's height.
  func fit() {
    guard let window, let root = superview else { return }
    let h = Self.height(of: window)
    frame = NSRect(x: 0, y: root.bounds.height - h, width: root.bounds.width, height: h)
    autoresizingMask = [.width, .minYMargin]
    isHidden = h <= 0
  }

  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    fit()
  }

  override var mouseDownCanMoveWindow: Bool { true }

  override func mouseDown(with event: NSEvent) {
    guard let window else { return }
    if event.clickCount == 2 {
      switch UserDefaults.standard.string(forKey: "AppleActionOnDoubleClick") {
      case "Minimize": window.performMiniaturize(nil)
      case "None": break
      default: window.performZoom(nil)
      }
      return
    }
    window.performDrag(with: event)
  }
}
