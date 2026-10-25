import FlutterMacOS
import Foundation

/// `dottoday/intents` on the Mac (docs/09 M12.4): the drain's read and
/// atomic remove of the App Group queue the share extension appends to,
/// and `queueChanged` when it does (a Darwin notification reaches this
/// process from the extension), as ios/Runner/AppDelegate.swift.
final class IntentQueueBridge {
  static let shared = IntentQueueBridge()
  private var channel: FlutterMethodChannel?

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "dottoday/intents", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard let defaults = DotStore.shared else { return result(nil) }
      let queue = DotQueue(defaults: defaults)
      switch call.method {
      case "readQueue":
        result(defaults.string(forKey: DotStore.queueKey))
      case "removeQueued":
        let args = call.arguments as? [String: Any]
        queue.remove(
          Set(args?["ids"] as? [String] ?? []), unreadable: args?["unreadable"] as? Bool ?? false)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
    let observer = Unmanaged.passUnretained(self).toOpaque()
    CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(), observer,
      { _, observer, _, _, _ in
        guard let observer else { return }
        let bridge = Unmanaged<IntentQueueBridge>.fromOpaque(observer).takeUnretainedValue()
        DispatchQueue.main.async { bridge.channel?.invokeMethod("queueChanged", arguments: nil) }
      },
      DotStore.queueChanged as CFString, nil, .deliverImmediately)
  }
}
