import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  /// Links opened before Dart asked for them (a cold start), oldest first.
  private var pendingLinks: [String] = []
  private var linkChannel: FlutterMethodChannel?
  private var dartListening = false

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
  }

  override func application(_ application: NSApplication, open urls: [URL]) {
    super.application(application, open: urls)
    for url in urls where url.scheme == "dottoday" {
      if dartListening {
        linkChannel?.invokeMethod("open", arguments: url.absoluteString)
      } else {
        pendingLinks.append(url.absoluteString)
      }
    }
  }
}
