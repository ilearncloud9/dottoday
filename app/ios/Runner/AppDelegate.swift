import Flutter
import UIKit
import UserNotifications
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Alerts show while Dottoday is open, and their actions reach
    // flutter_local_notifications (docs/09 M5.1).
    UNUserNotificationCenter.current().delegate = self
    // The daily refresh (docs/09 M5.2): BGTaskScheduler needs the handler
    // registered before launch ends; its background engine gets the same
    // plugins as the app. The id is in Info.plist and background_refresh.dart.
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "dottoday.refresh", earliestBeginInSeconds: NSNumber(value: 12 * 60 * 60))
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
