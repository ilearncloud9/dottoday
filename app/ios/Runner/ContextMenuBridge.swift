import Flutter
import UIKit

/// iOS's own pull-down menus for the app's menus (owner, M19.4 part 4d:
/// each platform's own): Flutter sends the items over
/// `dottoday/context_menu` (lib/shared/menus/context_menu.dart), this
/// puts a 1-point button at the point and opens its UIMenu, and answers
/// the chosen item's index, or -1 when dismissed. The system gives it its
/// look, ticks, VoiceOver, Dynamic Type and dark mode. Opening a button's
/// menu from code needs iOS 17.4; below that the method isn't there and
/// Flutter draws its own menu.
final class ContextMenuBridge {
  static let shared = ContextMenuBridge()
  private var channel: FlutterMethodChannel?
  private var anchor: UIView?

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "dottoday/context_menu", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self, call.method == "show", let args = call.arguments as? [String: Any] else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard #available(iOS 17.4, *) else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.show(args, result)
    }
    self.channel = channel
  }

  @available(iOS 17.4, *)
  private func show(_ args: [String: Any], _ result: @escaping FlutterResult) {
    guard let host = Self.flutterView() else {
      result(FlutterMethodNotImplemented)
      return
    }
    anchor?.removeFromSuperview()
    let x = args["x"] as? Double ?? 0
    let y = args["y"] as? Double ?? 0
    let button = MenuAnchorButton(frame: CGRect(x: x, y: y, width: 1, height: 1))
    var answered = false
    let answer: (Int) -> Void = { [weak button] index in
      guard !answered else { return }
      answered = true
      result(index)
      button?.removeFromSuperview()
    }
    let entries = args["items"] as? [[String: Any]] ?? []
    button.menu = UIMenu(children: Self.groups(entries, answer: answer))
    button.showsMenuAsPrimaryAction = true
    // A pick runs its action before the dismissal finishes; anything else
    // that ends the menu is a dismiss.
    button.onEnd = { DispatchQueue.main.async { answer(-1) } }
    button.isAccessibilityElement = false
    host.addSubview(button)
    anchor = button
    button.performPrimaryAction()
  }

  /// The entries as iOS draws groups: a divided entry starts an inline
  /// section, a header one a titled inline section (the Day menu's Time ·
  /// Plan · Day · Layout, ED-093), and children make a submenu.
  private static func groups(
    _ entries: [[String: Any]], answer: @escaping (Int) -> Void
  ) -> [UIMenuElement] {
    var groups: [(title: String, items: [UIMenuElement])] = [("", [])]
    for entry in entries {
      if let header = entry["header"] as? String {
        if groups.last?.items.isEmpty == true {
          groups[groups.count - 1].title = header
        } else {
          groups.append((header, []))
        }
      } else if entry["divided"] as? Bool == true, !(groups.last?.items.isEmpty ?? true) {
        groups.append(("", []))
      }
      groups[groups.count - 1].items.append(element(entry, answer: answer))
    }
    return groups.map { UIMenu(title: $0.title, options: .displayInline, children: $0.items) }
  }

  private static func element(
    _ entry: [String: Any], answer: @escaping (Int) -> Void
  ) -> UIMenuElement {
    let image = (entry["symbol"] as? String).flatMap { UIImage(systemName: $0) }
    let title = entry["label"] as? String ?? ""
    if let children = entry["children"] as? [[String: Any]], !children.isEmpty {
      // Need more time ▸: the system's submenu.
      let menu = UIMenu(title: title, image: image, children: groups(children, answer: answer))
      if entry["enabled"] as? Bool == false {
        return UIAction(title: title, image: image, attributes: .disabled) { _ in }
      }
      return menu
    }
    let index = entry["index"] as? Int ?? -1
    let action = UIAction(title: title, image: image) { _ in answer(index) }
    if entry["enabled"] as? Bool == false { action.attributes.insert(.disabled) }
    if entry["checked"] as? Bool == true { action.state = .on }
    return action
  }

  /// The Flutter view in the key window, under the iPad's tab controller
  /// too: its points are Flutter's logical pixels.
  private static func flutterView() -> UIView? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let window = scenes.flatMap(\.windows).first { $0.isKeyWindow } ?? scenes.first?.windows.first
    var queue: [UIViewController] = window?.rootViewController.map { [$0] } ?? []
    while !queue.isEmpty {
      let next = queue.removeFirst()
      if let flutter = next as? FlutterViewController { return flutter.view }
      queue.append(contentsOf: next.children)
    }
    return nil
  }
}

/// A button that says when its menu has ended (picked or dismissed).
private final class MenuAnchorButton: UIButton {
  var onEnd: (() -> Void)?

  override func contextMenuInteraction(
    _ interaction: UIContextMenuInteraction,
    willEndFor configuration: UIContextMenuConfiguration,
    animator: UIContextMenuInteractionAnimating?
  ) {
    super.contextMenuInteraction(interaction, willEndFor: configuration, animator: animator)
    guard let animator else {
      onEnd?()
      return
    }
    animator.addCompletion { [weak self] in self?.onEnd?() }
  }
}
