import Flutter
import UIKit

/// iOS's own alerts for the app's confirms and rename prompts (owner,
/// native pass): `choose` shows a UIAlertController with the buttons
/// Flutter sends (lib/data/shell/native_alert.dart) and answers the tapped
/// one's index; `text` adds one text field and answers `{ok, text}`.
final class AlertBridge {
  static let shared = AlertBridge()
  private var channel: FlutterMethodChannel?

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "dottoday/alert", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard let args = call.arguments as? [String: Any], let top = Self.topController() else {
        result(FlutterMethodNotImplemented)
        return
      }
      let alert: UIAlertController
      switch call.method {
      case "choose": alert = Self.choose(args, result)
      case "text": alert = Self.text(args, result)
      default:
        result(FlutterMethodNotImplemented)
        return
      }
      // Dottoday's ink for the buttons, never red (ED-336).
      if let tint = (args["tint"] as? String).flatMap(Self.colour) { alert.view.tintColor = tint }
      top.present(alert, animated: true)
    }
    self.channel = channel
  }

  private static func choose(_ args: [String: Any], _ result: @escaping FlutterResult)
    -> UIAlertController
  {
    let alert = UIAlertController(
      title: args["title"] as? String, message: args["message"] as? String,
      preferredStyle: .alert)
    let buttons = args["buttons"] as? [[String: Any]] ?? []
    let preferred = args["preferred"] as? Int
    for (index, button) in buttons.enumerated() {
      let style: UIAlertAction.Style =
        switch button["style"] as? String {
        case "cancel": .cancel
        case "destructive": .destructive
        default: .default
        }
      let action = UIAlertAction(title: button["label"] as? String, style: style) { _ in
        result(index)
      }
      alert.addAction(action)
      if index == preferred { alert.preferredAction = action }
    }
    return alert
  }

  private static func text(_ args: [String: Any], _ result: @escaping FlutterResult)
    -> UIAlertController
  {
    let alert = UIAlertController(
      title: args["title"] as? String, message: nil, preferredStyle: .alert)
    alert.addTextField { field in
      field.text = args["initial"] as? String
      field.clearButtonMode = .whileEditing
      field.returnKeyType = .done
    }
    alert.addAction(
      UIAlertAction(title: args["cancel"] as? String, style: .cancel) { _ in
        result(["ok": false, "text": ""])
      })
    let save = UIAlertAction(title: args["action"] as? String, style: .default) { [weak alert] _ in
      result(["ok": true, "text": alert?.textFields?.first?.text ?? ""])
    }
    alert.addAction(save)
    alert.preferredAction = save
    return alert
  }

  private static func colour(_ hex: String) -> UIColor? {
    guard hex.count == 7, let v = Int(hex.dropFirst(), radix: 16) else { return nil }
    return UIColor(
      red: CGFloat((v >> 16) & 0xFF) / 255, green: CGFloat((v >> 8) & 0xFF) / 255,
      blue: CGFloat(v & 0xFF) / 255, alpha: 1)
  }

  /// The view controller on top, so the alert shows over any sheet.
  private static func topController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let window = scenes.flatMap(\.windows).first { $0.isKeyWindow } ?? scenes.first?.windows.first
    var top = window?.rootViewController
    while let next = top?.presentedViewController { top = next }
    return top
  }
}
