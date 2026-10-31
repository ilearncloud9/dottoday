import Flutter
import UIKit

#if canImport(AlarmKit)
  import AlarmKit
#endif

/// `dottoday/alarm` (lib/data/notifications/os_alarm_gateway.dart, docs/15
/// W1b, ADR-0017): the Wake Up alarm through AlarmKit on iOS 26+, behind an
/// availability check. Below 26 it arms nothing, so the app rings the Wake
/// Up as a time-sensitive notification exactly as before (W1a), and says
/// whether an update would bring alarms. Also registered for the background
/// refresh's engine, so the daily job keeps the week armed.
enum AlarmBridge {
  /// Apple's "Update your iPhone" page: there is no public link into
  /// Software Update.
  private static let updateHelp = URL(string: "https://support.apple.com/118575")!

  static func register(_ registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "AlarmBridge") else { return }
    let channel = FlutterMethodChannel(name: "dottoday/alarm", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "alarmKitStatus":
        result(status())
      case "allowAlarms":
        Task { @MainActor in
          await allow()
          result(nil)
        }
      case "openSoftwareUpdate":
        UIApplication.shared.open(updateHelp)
        result(nil)
      case "sync":
        let args = call.arguments as? [String: Any]
        let specs = (args?["alarms"] as? [[String: Any]] ?? []).compactMap(WakeUpAlarmSpec.init)
        guard #available(iOS 26.0, *) else { return result([Int64]()) }
        // The day began: its Wake Up Check is called off (15 W3).
        WakeUpAlarms.cancelChecks(args?["started"] as? [String] ?? [])
        Task { result(await WakeUpAlarms.sync(specs)) }
      case "test":
        guard #available(iOS 26.0, *), let spec = (call.arguments as? [String: Any]).flatMap(WakeUpAlarmSpec.init)
        else { return result(false) }
        Task { result(await WakeUpAlarms.test(spec)) }
      case "drainEvents":
        guard #available(iOS 26.0, *) else { return result([[String: Any]]()) }
        result(WakeUpAlarms.drainEvents())
      case "disarmAll":
        if #available(iOS 26.0, *) { WakeUpAlarms.disarmAll() }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// `AlarmKitStatus` by name (lib/domain/notifications/alarm_capabilities.dart).
  private static func status() -> String {
    if #available(iOS 26.0, *) {
      switch AlarmManager.shared.authorizationState {
      case .authorized: return "authorized"
      case .denied: return "denied"
      default: return "notAsked"
      }
    }
    return canRunIOS26() ? "needsUpdate" : "unsupported"
  }

  /// The prompt where it was never shown; Settings › Dottoday after a no.
  @MainActor
  private static func allow() async {
    if #available(iOS 26.0, *), AlarmManager.shared.authorizationState == .notDetermined {
      _ = try? await AlarmManager.shared.requestAuthorization()
      return
    }
    if let settings = URL(string: UIApplication.openSettingsURLString) {
      await UIApplication.shared.open(settings)
    }
  }

  /// iOS 26 runs on iPhone XS / XR (iPhone11,x) and later (15 §2 item 5,
  /// best effort): older iPhones are never offered an update.
  private static func canRunIOS26() -> Bool {
    var info = utsname()
    uname(&info)
    let machine = withUnsafeBytes(of: &info.machine) { String(decoding: $0.prefix { $0 != 0 }, as: UTF8.self) }
    let model = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? machine
    guard model.hasPrefix("iPhone"), let major = Int(model.dropFirst(6).prefix { $0 != "," }) else {
      return false
    }
    return major >= 11
  }
}
