import AudioToolbox
import Cocoa
import EventKit
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  /// Links opened before Dart asked for them (a cold start), oldest first.
  private var pendingLinks: [String] = []
  private var linkChannel: FlutterMethodChannel?
  private var dartListening = false
  private var statusChannel: FlutterMethodChannel?
  private let calendars = CalendarBridge()
  private lazy var nextUp = DayDotStatusItem(
    open: { [weak self] link in
      NSApp.activate(ignoringOtherApps: true)
      self?.deliver(link)
    },
    act: { [weak self] action in self?.statusChannel?.invokeMethod("action", arguments: action) })

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  /// The macOS embedder doesn't pass opened URLs to the router the way iOS
  /// and Android do, so links go over `dottoday/deep_links`
  /// (lib/core/router/native_deep_links.dart, docs/09 M5.0).
  func attachDeepLinks(to controller: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "dottoday/deep_links", binaryMessenger: controller.engine.binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self, call.method == "takePending" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.dartListening = true
      result(self.pendingLinks)
      self.pendingLinks.removeAll()
    }
    linkChannel = channel

    // The day dot in the menu bar (docs/02 F9, M5.5, M9.6): the app sends
    // the day snapshot after every change; Done / +15 come back as
    // `action` (lib/data/widgets/mac_menu_actions.dart).
    let status = FlutterMethodChannel(
      name: "dottoday/status_item", binaryMessenger: controller.engine.binaryMessenger)
    status.setMethodCallHandler { [weak self] call, result in
      guard call.method == "update", let json = call.arguments as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.nextUp.update(json: json)
      result(nil)
    }
    statusChannel = status

    // Device calendars (docs/09 M7.1b): EventKit, read-only.
    calendars.attach(to: controller.engine.binaryMessenger)

    // Reminder sound previews (docs/09 M8.4d).
    SoundBridge.shared.attach(to: controller.engine.binaryMessenger)

    // On-device model, Foundation Models (docs/09 M10.1).
    ThinkingBridge.register(controller.engine.binaryMessenger)
    // Dictation, on the device only (M14.4, ADR-0014).
    SpeechBridge.register(controller.engine.binaryMessenger)

    // The share extension's queue (docs/09 M12.4).
    IntentQueueBridge.shared.attach(to: controller.engine.binaryMessenger)

    // Wake, clock and calendar changes (docs/04 §4 "Triggers").
    SystemEventsBridge.shared.attach(to: controller.engine.binaryMessenger)
  }

  /// Sends [link] to the router, or keeps it until Dart listens.
  private func deliver(_ link: String) {
    if dartListening {
      linkChannel?.invokeMethod("open", arguments: link)
    } else {
      pendingLinks.append(link)
    }
  }

  override func application(_ application: NSApplication, open urls: [URL]) {
    super.application(application, open: urls)
    for url in urls where url.scheme == "dottoday" {
      deliver(url.absoluteString)
    }
  }
}

/// What macOS announces while the app runs, on `dottoday/system_events`
/// (lib/data/system/system_events.dart, docs/04 §4 "Triggers"), so Dart acts on the
/// event instead of checking on a timer: `wake` after sleep (timers may
/// have slept through their moment), `clock` when the day turns over or
/// the time or zone changes, `calendar` when the calendars change.
final class SystemEventsBridge {
  static let shared = SystemEventsBridge()
  private var channel: FlutterMethodChannel?
  /// Only observed; reading goes through CalendarBridge.
  private var store: EKEventStore?
  private var observers: [NSObjectProtocol] = []

  func attach(to messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "dottoday/system_events", binaryMessenger: messenger)
    guard observers.isEmpty else { return }
    observers.append(
      NSWorkspace.shared.notificationCenter.addObserver(
        forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
      ) { [weak self] _ in self?.send("wake") })
    let center = NotificationCenter.default
    for name in [Notification.Name.NSCalendarDayChanged, .NSSystemClockDidChange, .NSSystemTimeZoneDidChange] {
      observers.append(
        center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
          self?.send("clock")
        })
    }
    // Access is granted in a system prompt or Settings while the app is
    // in the background; a store made before that never reports changes.
    observers.append(
      center.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main) {
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
      ) { [weak self] _ in self?.send("calendar") })
  }

  private static func calendarReadable() -> Bool {
    let status = EKEventStore.authorizationStatus(for: .event)
    if #available(macOS 14.0, *) { return status == .fullAccess }
    return status == .authorized
  }

  private func send(_ event: String) {
    channel?.invokeMethod(event, arguments: nil)
  }
}

/// Reminder sound previews on `dottoday/sound` (lib/data/notifications/sound/
/// sound_player.dart, docs/09 M8.4d): plays a sound from the app bundle's
/// Resources (tool/xcode_add_sounds.rb; the sandbox can't write the
/// container's Library/Sounds, M8.5) as a system sound. Only plain catalogue
/// file names are accepted (docs/12).
final class SoundBridge {
  static let shared = SoundBridge()
  private var channel: FlutterMethodChannel?

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "dottoday/sound", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      // A Mac has no silent switch to read (docs/12 §6): never claim
      // muted; system sounds obey the switch on their own.
      if call.method == "isMuted" {
        result(false)
        return
      }
      guard call.method == "play", let name = call.arguments as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(SoundBridge.play(name))
    }
    self.channel = channel
  }

  private static func play(_ name: String) -> FlutterError? {
    guard name.range(of: "^[a-z][a-z0-9_]{0,63}\\.(wav|caf)$", options: .regularExpression) != nil
    else { return FlutterError(code: "bad_sound", message: nil, details: nil) }
    guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
      return FlutterError(code: "no_sound", message: nil, details: nil)
    }
    var id: SystemSoundID = 0
    guard AudioServicesCreateSystemSoundID(url as CFURL, &id) == kAudioServicesNoError else {
      return FlutterError(code: "no_sound", message: nil, details: nil)
    }
    AudioServicesPlaySystemSoundWithCompletion(id) { AudioServicesDisposeSystemSoundID(id) }
    return nil
  }
}
