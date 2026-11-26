import Cocoa
import SwiftUI

/// The floating Now mini window (E-Minimal, Window › Show Now ⌥⌘0; ED-066,
/// CR-042, CR-097, ED-260; M20.9 part 7, ED-475): a native non-activating
/// panel, not a second Flutter window (Flutter's multi-window API is still
/// experimental). It floats over other apps without taking focus, keeps
/// where it was put, and reads the same day snapshot as the menu bar's day
/// dot; Done and +5 / +15 / +30 go back on `dottoday/status_item` as
/// `action`, and the app runs the B6 intent in process.
final class NowMiniWindow: NSObject, NSWindowDelegate {
  private let open: (String) -> Void
  private let model: NowMiniModel
  private var panel: NSPanel?

  init(open: @escaping (String) -> Void, act: @escaping ([String: Any]) -> Void) {
    self.open = open
    model = NowMiniModel(act: act)
  }

  func update(json: String) {
    guard let data = json.data(using: .utf8),
      let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      (object["v"] as? NSNumber)?.intValue == 1
    else { return }
    model.snapshot = object
    fit()
  }

  /// Window › Show Now: shows the window, or hides it when it shows.
  func toggle() {
    if let panel, panel.isVisible {
      panel.orderOut(nil)
      model.visible = false
      return
    }
    let panel = self.panel ?? makePanel()
    self.panel = panel
    model.visible = true
    fit()
    panel.orderFrontRegardless()
  }

  func windowWillClose(_ notification: Notification) { model.visible = false }

  private func makePanel() -> NSPanel {
    ManropeMac.register()
    let panel = NSPanel(
      contentRect: NSRect(x: 0, y: 0, width: NowMiniModel.width, height: 120),
      styleMask: [.titled, .closable, .miniaturizable, .nonactivatingPanel],
      backing: .buffered, defer: true)
    panel.title = model.label("now")
    panel.isFloatingPanel = true
    panel.level = .floating
    panel.hidesOnDeactivate = false
    panel.becomesKeyOnlyIfNeeded = true
    panel.isReleasedWhenClosed = false
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    panel.delegate = self
    panel.contentView = FirstClickHostingView(rootView: NowMiniView(model: model))
    // Where it was put last; top right of the screen the first time.
    if !panel.setFrameUsingName("dottoday.now"), let screen = NSScreen.main?.visibleFrame {
      panel.setFrameTopLeftPoint(NSPoint(x: screen.maxX - NowMiniModel.width - 24, y: screen.maxY - 24))
    }
    panel.setFrameAutosaveName("dottoday.now")
    return panel
  }

  /// The window's height follows its content (one or two rows of buttons).
  private func fit() {
    guard let panel, let view = panel.contentView else { return }
    panel.title = model.label("now")
    let size = NSSize(width: NowMiniModel.width, height: view.fittingSize.height)
    guard panel.contentRect(forFrameRect: panel.frame).size != size else { return }
    let top = panel.frame.maxY
    panel.setContentSize(size)
    panel.setFrameTopLeftPoint(NSPoint(x: panel.frame.minX, y: top))
  }
}

/// Buttons answer the first click, so a click in the panel never has to
/// bring Dottoday forward first.
private final class FirstClickHostingView<Content: View>: NSHostingView<Content> {
  override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

/// Manrope (ED-110), the app's own variable font from Flutter's assets,
/// registered for the process once.
enum ManropeMac {
  private static var done = false

  static func register() {
    guard !done else { return }
    done = true
    let path = "Frameworks/App.framework/Resources/flutter_assets/assets/fonts/Manrope-Variable.ttf"
    let url = Bundle.main.bundleURL.appendingPathComponent("Contents").appendingPathComponent(path)
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  static func font(_ size: CGFloat, _ weight: CGFloat) -> Font {
    let wght = 0x7767_6874  // 'wght'
    let descriptor = NSFontDescriptor(fontAttributes: [.family: "Manrope"]).addingAttributes([
      NSFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): [wght: weight]
    ])
    return Font(NSFont(descriptor: descriptor, size: size) ?? .systemFont(ofSize: size, weight: .bold))
  }
}
