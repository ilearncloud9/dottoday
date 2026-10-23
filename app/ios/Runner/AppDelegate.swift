import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Alerts show while Dottoday is open, and their actions reach
    // flutter_local_notifications (docs/09 M5.1).
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DeepLinkBridge") {
      DeepLinkBridge.shared.attach(to: registrar.messenger())
    }
  }
}

/// Launch links waiting for Dart on `dottoday/deep_links`
/// (lib/core/router/native_deep_links.dart, docs/09 M5.0).
final class DeepLinkBridge {
  static let shared = DeepLinkBridge()
  private var pending: [String] = []
  private var channel: FlutterMethodChannel?

  func queue(_ url: URL) {
    pending.append(url.absoluteString)
  }

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "dottoday/deep_links", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self, call.method == "takePending" else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(self.pending)
      self.pending.removeAll()
    }
    self.channel = channel
  }
}
