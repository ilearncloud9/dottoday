import AudioToolbox
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
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SoundBridge") {
      SoundBridge.shared.attach(to: registrar.messenger())
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "IntentQueueBridge") {
      IntentQueueBridge.shared.attach(to: registrar.messenger())
    }
  }
}

/// Tells Dart on `dottoday/intents` that a widget, control, Live Activity
/// or Siri queued an action (ios/Shared/DotActions.swift posts a Darwin
/// notification, which reaches this process from the extension too), so a
/// running app applies it at once instead of on the next resume (M9.2).
final class IntentQueueBridge {
  static let shared = IntentQueueBridge()
  private var channel: FlutterMethodChannel?

  func attach(to messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "dottoday/intents", binaryMessenger: messenger)
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

/// Reminder sound previews on `dottoday/sound` (lib/data/notifications/sound/
/// sound_player.dart, docs/09 M8.4d): plays a bundled sound the app copied
/// to Library/Sounds, as a system sound, so the silent switch applies.
/// Only the generated reminder file names are accepted.
final class SoundBridge {
  static let shared = SoundBridge()
  private var channel: FlutterMethodChannel?

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "dottoday/sound", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "play", let name = call.arguments as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(SoundBridge.play(name))
    }
    self.channel = channel
  }

  private static func play(_ name: String) -> FlutterError? {
    guard name.range(of: "^reminder_[a-z]+\\.wav$", options: .regularExpression) != nil,
      let library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
    else { return FlutterError(code: "bad_sound", message: nil, details: nil) }
    let url = library.appendingPathComponent("Sounds").appendingPathComponent(name)
    var id: SystemSoundID = 0
    guard AudioServicesCreateSystemSoundID(url as CFURL, &id) == kAudioServicesNoError else {
      return FlutterError(code: "no_sound", message: nil, details: nil)
    }
    AudioServicesPlaySystemSoundWithCompletion(id) { AudioServicesDisposeSystemSoundID(id) }
    return nil
  }
}
