import ActivityKit
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
      LiveActivityBridge.register(registry)
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
    LiveActivityBridge.register(engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ThinkingBridge") {
      ThinkingBridge.register(registrar.messenger())
    }
  }
}

/// `dottoday/live_activity` (lib/data/live_activity/live_activity_sink.dart,
/// docs/09 M9.3): `sync` with the content JSON shows or updates the Live
/// Activity, `sync` with null ends it. Also registered for the background
/// refresh's engine, so the daily job can refresh or end it.
enum LiveActivityBridge {
  static func register(_ registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "LiveActivityBridge") else { return }
    let channel = FlutterMethodChannel(name: "dottoday/live_activity", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      guard #available(iOS 16.2, *) else { return result(nil) }
      switch call.method {
      case "sync":
        let state = (call.arguments as? String).flatMap(LiveDotState.decode)
        Task {
          await LiveActivities.sync(state)
          result(nil)
        }
      // The device test (integration_test/live_activity_test.dart): which
      // dots have an activity, and the activity's own Done / +15 path.
      case "activeIds":
        result(Activity<DotActivityAttributes>.activities.map { $0.content.state.id })
      // The consistency gate (M9.8): what each activity shows.
      case "activeStates":
        result(
          Activity<DotActivityAttributes>.activities.compactMap { activity in
            (try? JSONEncoder().encode(activity.content.state)).flatMap { String(data: $0, encoding: .utf8) }
          })
      case "perform":
        guard let args = call.arguments as? [String: Any], let id = args["id"] as? String else {
          return result(FlutterError(code: "bad_args", message: nil, details: nil))
        }
        Task {
          if args["kind"] as? String == "add_fifteen" {
            let end = args["planned_end_ms"] as? Double ?? 0
            DotActions.perform(
              .addFifteen, occurrenceId: id, plannedEnd: Date(timeIntervalSince1970: end / 1000))
            await LiveActivities.plusFifteen(occurrenceId: id, plannedEndMs: end)
          } else {
            DotActions.perform(.markDone, occurrenceId: id)
            await LiveActivities.end(occurrenceId: id)
          }
          result(nil)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
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
    let channel = FlutterMethodChannel(name: "dottoday/intents", binaryMessenger: messenger)
    // The drain's read and its atomic remove (lib/data/intents/
    // native_action_queue_store.dart): on the main thread, like every
    // in-app append, so none falls between a read and a write.
    channel.setMethodCallHandler { call, result in
      guard let defaults = DotStore.shared else { return result(nil) }
      let queue = DotQueue(defaults: defaults)
      switch call.method {
      case "readQueue":
        result(defaults.string(forKey: DotStore.queueKey))
      case "removeQueued":
        let args = call.arguments as? [String: Any]
        queue.remove(Set(args?["ids"] as? [String] ?? []), unreadable: args?["unreadable"] as? Bool ?? false)
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
