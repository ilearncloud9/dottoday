import Cocoa
import FlutterMacOS

/// The Mac's right-click menus are the system's own (ED-239, CR-098):
/// Flutter sends the items over `dottoday/context_menu`
/// (lib/shared/menus/context_menu.dart), this pops an NSMenu at the click
/// point and answers with the chosen item's index, or -1 when dismissed
/// (nil would read as "no bridge" on the Dart side).
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
      result(self.show(args) ?? -1)
    }
    self.channel = channel
  }

  /// Runs the menu; NSMenu tracks it modally and returns once it closes.
  private func show(_ args: [String: Any]) -> Int? {
    guard let view else { return nil }
    let menu = Self.menu(args["items"] as? [[String: Any]] ?? [], target: self)
    let x = args["x"] as? Double ?? 0
    let y = args["y"] as? Double ?? 0
    // Flutter measures from the top-left; an unflipped NSView from the
    // bottom-left.
    let point = NSPoint(x: x, y: view.isFlipped ? y : view.bounds.height - y)
    chosen = nil
    menu.popUp(positioning: nil, at: point, in: view)
    return chosen
  }

  /// The items as an NSMenu: a divided entry starts a group with a
  /// separator, a header one a titled group (the Day menu's Time · Plan ·
  /// Day · Layout, ED-093), and children make a submenu.
  private static func menu(_ entries: [[String: Any]], target: ContextMenuBridge) -> NSMenu {
    let menu = NSMenu()
    menu.autoenablesItems = false
    for (position, entry) in entries.enumerated() {
      if let header = entry["header"] as? String {
        if position > 0 { menu.addItem(.separator()) }
        menu.addItem(Self.header(header))
      } else if entry["divided"] as? Bool == true {
        menu.addItem(.separator())
      }
      menu.addItem(item(entry, target: target))
    }
    return menu
  }

  private static func header(_ title: String) -> NSMenuItem {
    if #available(macOS 14.0, *) { return .sectionHeader(title: title) }
    let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
    item.isEnabled = false
    return item
  }

  private static func item(_ entry: [String: Any], target: ContextMenuBridge) -> NSMenuItem {
    let item = NSMenuItem(
      title: entry["label"] as? String ?? "", action: #selector(ContextMenuBridge.pick(_:)), keyEquivalent: "")
    item.target = target
    item.tag = entry["index"] as? Int ?? -1
    item.isEnabled = entry["enabled"] as? Bool ?? true
    if let children = entry["children"] as? [[String: Any]], !children.isEmpty {
      // Need more time ▸: the system's submenu; the parent itself runs nothing.
      item.action = nil
      item.submenu = menu(children, target: target)
    }
    // A pop-up's current choice carries the system tick (R2-40).
    item.state = entry["checked"] as? Bool == true ? .on : .off
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

  @objc fileprivate func pick(_ sender: NSMenuItem) {
    chosen = sender.tag >= 0 ? sender.tag : nil
  }
}
