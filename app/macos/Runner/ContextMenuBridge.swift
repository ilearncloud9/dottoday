import Cocoa
import FlutterMacOS

/// The Mac's right-click menus are the system's own (ED-239, CR-098):
/// Flutter sends the items over `dottoday/context_menu`
/// (lib/shared/menus/context_menu.dart), this pops an NSMenu at the click
/// point and answers with the chosen item's index, or nil when dismissed.
/// The system gives it its look, keyboard navigation, VoiceOver, Increase
/// Contrast and dark mode.
final class ContextMenuBridge: NSObject {
  private var channel: FlutterMethodChannel?
  private weak var view: NSView?
  private var chosen: Int?

  func attach(to controller: FlutterViewController) {
    view = controller.view
    let channel = FlutterMethodChannel(
      name: "dottoday/context_menu", binaryMessenger: controller.engine.binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self, call.method == "show", let args = call.arguments as? [String: Any] else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(self.show(args))
    }
    self.channel = channel
  }

  /// Runs the menu; NSMenu tracks it modally and returns once it closes.
  private func show(_ args: [String: Any]) -> Int? {
    guard let view else { return nil }
    let menu = NSMenu()
    menu.autoenablesItems = false
    let items = args["items"] as? [[String: Any]] ?? []
    for (index, entry) in items.enumerated() {
      menu.addItem(item(entry, index: index))
    }
    let x = args["x"] as? Double ?? 0
    let y = args["y"] as? Double ?? 0
    // Flutter measures from the top-left; an unflipped NSView from the
    // bottom-left.
    let point = NSPoint(x: x, y: view.isFlipped ? y : view.bounds.height - y)
    chosen = nil
    menu.popUp(positioning: nil, at: point, in: view)
    return chosen
  }

  private func item(_ entry: [String: Any], index: Int) -> NSMenuItem {
    let item = NSMenuItem(
      title: entry["label"] as? String ?? "", action: #selector(pick(_:)), keyEquivalent: "")
    item.target = self
    item.tag = index
    item.isEnabled = entry["enabled"] as? Bool ?? true
    if let symbol = entry["symbol"] as? String {
      item.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
    }
    if let key = entry["key"] as? String {
      // A hint only: the key itself is bound where the action lives.
      item.keyEquivalent = Self.keyEquivalent(key)
      var mask: NSEvent.ModifierFlags = []
      if entry["command"] as? Bool == true { mask.insert(.command) }
      if entry["shift"] as? Bool == true { mask.insert(.shift) }
      if entry["option"] as? Bool == true { mask.insert(.option) }
      if entry["control"] as? Bool == true { mask.insert(.control) }
      item.keyEquivalentModifierMask = mask
    }
    return item
  }

  private static func keyEquivalent(_ name: String) -> String {
    switch name {
    case "backspace": return "\u{8}"
    case "enter": return "\r"
    default: return name
    }
  }

  @objc private func pick(_ sender: NSMenuItem) {
    chosen = sender.tag
  }
}
