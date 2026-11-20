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
    // A divided entry starts a new group: an inline section, as iOS draws.
    var groups: [[UIMenuElement]] = [[]]
    for (index, entry) in entries.enumerated() {
      if entry["divided"] as? Bool == true, !(groups.last?.isEmpty ?? true) { groups.append([]) }
      groups[groups.count - 1].append(Self.action(entry, index: index, answer: answer))
    }
    button.menu = UIMenu(children: groups.map { UIMenu(options: .displayInline, children: $0) })
    button.showsMenuAsPrimaryAction = true
    // A pick runs its action before the dismissal finishes; anything else
    // that ends the menu is a dismiss.
    button.onEnd = { DispatchQueue.main.async { answer(-1) } }
    button.isAccessibilityElement = false
    host.addSubview(button)
    anchor = button
    button.performPrimaryAction()
  }

  private static func action(
    _ entry: [String: Any], index: Int, answer: @escaping (Int) -> Void
  ) -> UIAction {
    let image = (entry["symbol"] as? String).flatMap { UIImage(systemName: $0) }
    let action = UIAction(title: entry["label"] as? String ?? "", image: image) { _ in
      answer(index)
    }
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
