import Foundation

#if os(iOS)
  import Flutter
  import UIKit
#else
  import AppKit
  import FlutterMacOS
#endif

/// `dottoday/reduce_transparency` (lib/data/layout/reduce_transparency.dart,
/// ED-248 C): whether the system's Reduce Transparency is on, which Flutter
/// does not report. `get` answers now; `changed` is sent when it changes.
/// Compiled into the iOS and the macOS Runner (one file, R-13).
final class ReduceTransparencyBridge: NSObject {
  static let shared = ReduceTransparencyBridge()

  private var channel: FlutterMethodChannel?
  private var observer: NSObjectProtocol?

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "dottoday/reduce_transparency", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      call.method == "get" ? result(Self.on) : result(FlutterMethodNotImplemented)
    }
    self.channel = channel
    #if os(iOS)
      observer = NotificationCenter.default.addObserver(
        forName: UIAccessibility.reduceTransparencyStatusDidChangeNotification,
        object: nil, queue: .main
      ) { [weak self] _ in self?.channel?.invokeMethod("changed", arguments: Self.on) }
    #else
      observer = NSWorkspace.shared.notificationCenter.addObserver(
        forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
        object: nil, queue: .main
      ) { [weak self] _ in self?.channel?.invokeMethod("changed", arguments: Self.on) }
    #endif
  }

  static var on: Bool {
    #if os(iOS)
      UIAccessibility.isReduceTransparencyEnabled
    #else
      NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
    #endif
  }
}
