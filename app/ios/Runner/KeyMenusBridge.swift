import Flutter
import UIKit

/// The app's menus in the iPad's menu bar, shown while ⌘ is held (R2-10,
/// ED-095), from the same list as the Mac's (lib/app_menus.dart, sent by
/// lib/app_native_menus.dart over `dottoday/key_menus`). Each command with
/// a key is a `UIKeyCommand`, so a hardware keyboard runs it on iPhone too;
/// choosing one sends `select` with its id and Flutter runs the same
/// handler as the Mac menu. Undo, Redo and Delete stay the system's.
final class KeyMenusBridge {
  static let shared = KeyMenusBridge()
  private var channel: FlutterMethodChannel?
  private var menus: [[String: Any]] = []

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "dottoday/key_menus", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "set", let menus = call.arguments as? [[String: Any]] else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.menus = menus
      UIMenuSystem.main.setNeedsRebuild()
      result(nil)
    }
    self.channel = channel
  }

  func select(_ id: String) {
    channel?.invokeMethod("select", arguments: id)
  }

  /// Puts the menus among the system's: Settings in the app menu, File,
  /// Edit and View items first in theirs, Go as its own menu after View.
  func build(_ builder: UIMenuBuilder) {
    guard builder.system == .main, !menus.isEmpty else { return }
    // ⌘F is Search (ED-095). The system's Find works on UIKit text views,
    // which Flutter doesn't use, and UIKit drops a menu whose key repeats
    // another's.
    builder.remove(menu: .find)
    for menu in menus {
      guard let kind = menu["kind"] as? String else { continue }
      let groups = (menu["groups"] as? [[[String: Any]]] ?? []).map(Self.group)
      switch kind {
      case "app":
        builder.replace(menu: .preferences, with: UIMenu(options: .displayInline, children: groups))
      case "file":
        builder.insertChild(UIMenu(options: .displayInline, children: groups), atStartOfMenu: .file)
      case "edit":
        builder.insertChild(UIMenu(options: .displayInline, children: groups), atEndOfMenu: .edit)
      case "view":
        builder.insertChild(UIMenu(options: .displayInline, children: groups), atStartOfMenu: .view)
      case "go":
        let go = UIMenu(
          title: menu["label"] as? String ?? "",
          identifier: UIMenu.Identifier("app.dottoday.go"), children: groups)
        builder.insertSibling(go, afterMenu: .view)
      default:
        break  // Window: the system's own.
      }
    }
  }

  private static func group(_ items: [[String: Any]]) -> UIMenu {
    UIMenu(options: .displayInline, children: items.compactMap(command))
  }

  private static func command(_ item: [String: Any]) -> UIMenuElement? {
    guard let id = item["id"] as? String, let label = item["label"] as? String else { return nil }
    let action = #selector(AppDelegate.dottodayMenuCommand(_:))
    guard let key = item["key"] as? String else {
      return UICommand(title: label, action: action, propertyList: id)
    }
    var flags: UIKeyModifierFlags = .command
    if item["shift"] as? Bool == true { flags.insert(.shift) }
    let command = UIKeyCommand(
      title: label, action: action, input: key, modifierFlags: flags, propertyList: id)
    // Before the system's own use of the same key (⌘F's Find, ⌘[).
    command.wantsPriorityOverSystemBehavior = true
    return command
  }
}
