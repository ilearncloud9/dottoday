import ActivityKit
import AudioToolbox
import EventKit
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
      AlarmBridge.register(registry)
    }
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "dottoday.refresh", earliestBeginInSeconds: NSNumber(value: 12 * 60 * 60))
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// The Wake Up Check's tap (docs/15 W3) is Dottoday's own, not
  /// flutter_local_notifications': it opens its link (Focus on the first
  /// dot). Every other notification goes to the plugins as before.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let info = response.notification.request.content.userInfo
    if #available(iOS 26.0, *),
      response.notification.request.identifier.hasPrefix(WakeUpAlarms.checkPrefix),
      let link = (info[WakeUpAlarms.checkLinkKey] as? String).flatMap(URL.init(string:))
    {
      UIApplication.shared.open(link)
      completionHandler()
      return
    }
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
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
    // The Wake Up alarm on iOS 26+ (docs/15 W1b, ADR-0017).
    AlarmBridge.register(engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ThinkingBridge") {
      ThinkingBridge.register(registrar.messenger())
    }
    // Dictation, on the device only (M14.4, ADR-0014).
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SpeechBridge") {
      SpeechBridge.register(registrar.messenger())
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SystemEventsBridge") {
      SystemEventsBridge.shared.attach(to: registrar.messenger())
    }
  }
}

/// What iOS announces while the app runs, on `dottoday/system_events`
/// (lib/data/system/system_events.dart, docs/04 §4 "Triggers"), so Dart acts on the
/// event instead of checking on a timer: `clock` when the day turns over
/// or the time or zone changes, `calendar` when the device's calendars
/// change (another app, an account sync, Dottoday's own write-back).
final class SystemEventsBridge {
  static let shared = SystemEventsBridge()
  private var channel: FlutterMethodChannel?
  /// Only observed; reading goes through device_calendar.
  private var store: EKEventStore?
  private var observers: [NSObjectProtocol] = []

  func attach(to messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "dottoday/system_events", binaryMessenger: messenger)
    guard observers.isEmpty else { return }
    let center = NotificationCenter.default
    for name in [UIApplication.significantTimeChangeNotification, .NSSystemTimeZoneDidChange] {
      observers.append(
        center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
          self?.channel?.invokeMethod("clock", arguments: nil)
        })
    }
    // Access is granted in a system prompt or Settings while the app is
    // in the background; a store made before that never reports changes.
    observers.append(
      center.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) {
        [weak self] _ in self?.watchCalendars()
      })
    watchCalendars()
  }

  private func watchCalendars() {
    guard store == nil, Self.calendarReadable() else { return }
    let store = EKEventStore()
    self.store = store
    observers.append(
      NotificationCenter.default.addObserver(
        forName: .EKEventStoreChanged, object: store, queue: .main
      ) { [weak self] _ in self?.channel?.invokeMethod("calendar", arguments: nil) })
  }

  private static func calendarReadable() -> Bool {
    let status = EKEventStore.authorizationStatus(for: .event)
    if #available(iOS 17.0, *) { return status == .fullAccess }
    return status == .authorized
  }
}

/// `dottoday/live_activity` (lib/data/live_activity/live_activity_sink.dart,
/// docs/09 M9.3): `sync` with the content JSON shows or updates the Live
/// Activity, `sync` with null ends it. Also registered for the background
/// refresh's engine, so the daily job can refresh or end it.
enum LiveActivityBridge {
  /// The channel of every engine registered in this process.
  private static var channels: [FlutterMethodChannel] = []

  static func register(_ registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "LiveActivityBridge") else { return }
    let channel = FlutterMethodChannel(name: "dottoday/live_activity", binaryMessenger: registrar.messenger())
    // One event to Dart when the user dismisses the activity (M16: the
    // widget hint). Every engine that registers hears it; each records
    // the same flag.
    if #available(iOS 16.2, *) {
      channels.append(channel)
      LiveActivities.onUserDismiss = {
        for c in channels { c.invokeMethod("dismissedByUser", arguments: nil) }
      }
    }
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
/// sound_player.dart, docs/09 M8.4d, docs/12): plays a first-party tone the
/// app copied to Library/Sounds, or a catalogue `.caf` from the app bundle
/// (tool/xcode_add_sounds.rb), as a system sound, so the silent switch
/// applies. Only plain catalogue file names are accepted.
final class SoundBridge {
  static let shared = SoundBridge()
  private var channel: FlutterMethodChannel?
  /// The sound still playing: a new one or `stop` disposes it, which cuts
  /// it off, so a picker never stacks previews (docs/12 §6). The token
  /// tells a finished sound's completion from a reused id's. Main thread.
  private var playing: (id: SystemSoundID, token: Int)?
  private var nextToken = 0

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "dottoday/sound", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      // The ring/silent switch has no public API (docs/12 §6): never claim
      // muted; system sounds obey the switch on their own.
      if call.method == "isMuted" {
        result(false)
        return
      }
      if call.method == "stop" {
        self.stop()
        result(nil)
        return
      }
      guard call.method == "play", let name = call.arguments as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(self.play(name))
    }
    self.channel = channel
  }

  private func play(_ name: String) -> FlutterError? {
    guard name.range(of: "^[a-z][a-z0-9_]{0,63}\\.(wav|caf)$", options: .regularExpression) != nil
    else { return FlutterError(code: "bad_sound", message: nil, details: nil) }
    let installed = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?
      .appendingPathComponent("Sounds").appendingPathComponent(name)
    guard
      let url = [installed, Bundle.main.url(forResource: name, withExtension: nil)]
        .compactMap({ $0 }).first(where: { FileManager.default.fileExists(atPath: $0.path) })
    else { return FlutterError(code: "no_sound", message: nil, details: nil) }
    var id: SystemSoundID = 0
    guard AudioServicesCreateSystemSoundID(url as CFURL, &id) == kAudioServicesNoError else {
      return FlutterError(code: "no_sound", message: nil, details: nil)
    }
    stop()
    nextToken += 1
    let token = nextToken
    playing = (id, token)
    AudioServicesPlaySystemSoundWithCompletion(id) {
      DispatchQueue.main.async {
        guard self.playing?.token == token else { return }
        self.stop()
      }
    }
    return nil
  }

  private func stop() {
    guard let id = playing?.id else { return }
    playing = nil
    AudioServicesDisposeSystemSoundID(id)
  }
}
