import Cocoa
import FlutterMacOS

/// The Mac's own alerts for the app's confirms and rename prompts (owner,
/// native pass): `choose` shows an NSAlert as a sheet on the window with
/// the buttons Flutter sends (lib/data/shell/native_alert.dart) and answers
/// the chosen one's index; `text` adds one text field and answers
/// `{ok, text}`. Return picks the preferred button, Esc the Cancel one.
final class AlertBridge: NSObject {
  private var channel: FlutterMethodChannel?
  private weak var window: NSWindow?

  func attach(to controller: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "dottoday/alert", binaryMessenger: controller.engine.binaryMessenger)
    channel.setMethodCallHandler { [weak self, weak controller] call, result in
      guard let self, let args = call.arguments as? [String: Any],
        let window = controller?.view.window ?? NSApp.keyWindow
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      switch call.method {
      case "choose": self.choose(args, in: window, result)
      case "text": self.text(args, in: window, result)
      default: result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
  }

  private func choose(_ args: [String: Any], in window: NSWindow, _ result: @escaping FlutterResult) {
    let alert = NSAlert()
    let title = args["title"] as? String
    let message = args["message"] as? String
    alert.messageText = title ?? message ?? ""
    if title != nil, let message { alert.informativeText = message }
    let buttons = args["buttons"] as? [[String: Any]] ?? []
    let preferred = args["preferred"] as? Int
    // NSAlert's first button is the default (Return): the preferred one
    // first, then the rest as sent, Cancel last.
    var order = Array(buttons.indices)
    if let preferred, order.contains(preferred) {
      order.removeAll { $0 == preferred }
      order.insert(preferred, at: 0)
    }
    let cancels = order.filter { buttons[$0]["style"] as? String == "cancel" }
    order.removeAll { cancels.contains($0) }
    order.append(contentsOf: cancels)
    for index in order {
      let button = alert.addButton(withTitle: buttons[index]["label"] as? String ?? "")
      switch buttons[index]["style"] as? String {
      case "cancel": button.keyEquivalent = "\u{1b}"
      case "destructive": button.hasDestructiveAction = true
      default: break
      }
    }
    alert.beginSheetModal(for: window) { response in
      let position = response.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
      result(order.indices.contains(position) ? order[position] : -1)
    }
  }

  private func text(_ args: [String: Any], in window: NSWindow, _ result: @escaping FlutterResult) {
    let alert = NSAlert()
    alert.messageText = args["title"] as? String ?? ""
    let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
    field.stringValue = args["initial"] as? String ?? ""
    alert.accessoryView = field
    alert.addButton(withTitle: args["action"] as? String ?? "")
    alert.addButton(withTitle: args["cancel"] as? String ?? "").keyEquivalent = "\u{1b}"
    alert.window.initialFirstResponder = field
    alert.beginSheetModal(for: window) { response in
      let ok = response == .alertFirstButtonReturn
      result(["ok": ok, "text": ok ? field.stringValue : ""])
    }
  }
}
