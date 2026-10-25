import AudioToolbox
import Cocoa
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

    // The share extension's queue (docs/09 M12.4).
    IntentQueueBridge.shared.attach(to: controller.engine.binaryMessenger)
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

/// Reminder sound previews on `dottoday/sound` (lib/data/notifications/sound/
/// sound_player.dart, docs/09 M8.4d): plays a sound from the app bundle's
/// Resources (tool/xcode_add_sounds.rb; the sandbox can't write the
/// container's Library/Sounds, M8.5) as a system sound. Only the generated
/// reminder file names are accepted.
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
    guard name.range(of: "^reminder_[a-z]+\\.wav$", options: .regularExpression) != nil
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
