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
  private lazy var nextUp = NextUpStatusItem { [weak self] link in
    NSApp.activate(ignoringOtherApps: true)
    self?.deliver(link)
  }

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

    // "Next up" in the menu bar (docs/02 F9, M5.5): the app sends the same
    // snapshot as the iOS/Android widgets after every change.
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

/// "Next up" as a menu-bar item (docs/02 F9, docs/07 macOS, M5.5): the task
/// under way or the next one, with its colour; the menu lists what is left
/// of the day. Text arrives formatted and localised in the app's widget
/// snapshot (lib/data/widgets/widget_display.dart). ⌘-drag removes it.
final class NextUpStatusItem: NSObject {
  private let open: (String) -> Void
  private var item: NSStatusItem?
  private var snapshot: [String: Any] = [:]
  private var timer: Timer?

  init(open: @escaping (String) -> Void) {
    self.open = open
  }

  func update(json: String) {
    guard let data = json.data(using: .utf8),
      let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      (object["v"] as? NSNumber)?.intValue == 1
    else { return }
    snapshot = object
    render()
  }

  private var blocks: [[String: Any]] { snapshot["blocks"] as? [[String: Any]] ?? [] }

  private func label(_ key: String) -> String {
    (snapshot["labels"] as? [String: String])?[key] ?? ""
  }

  private static func ms(_ block: [String: Any], _ key: String) -> Double {
    (block[key] as? NSNumber)?.doubleValue ?? 0
  }

  private static func done(_ block: [String: Any]) -> Bool { block["done"] as? Bool ?? false }

  private func render() {
    let now = Date().timeIntervalSince1970 * 1000
    let open = blocks.filter { !Self.done($0) }
    let live = open.first { Self.ms($0, "start_ms") <= now && now < Self.ms($0, "end_ms") }
    let shown = live ?? open.first { Self.ms($0, "start_ms") > now }
    if item == nil {
      let created = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
      created.autosaveName = "dottoday.nextup"
      created.behavior = .removalAllowed
      item = created
    }
    guard let item, let button = item.button else { return }
    button.attributedTitle = title(for: shown, live: live != nil)
    button.setAccessibilityLabel(
      shown.map { "\(label(live != nil ? "now" : "next_up")): \($0["title"] as? String ?? "")" }
        ?? label("nothing_next"))
    item.menu = menu(now: now, live: live)
    scheduleRedraw(after: now)
  }

  private func title(for block: [String: Any]?, live: Bool) -> NSAttributedString {
    let font = NSFont.menuBarFont(ofSize: 0)
    let out = NSMutableAttributedString(
      string: "● ",
      attributes: [.foregroundColor: Self.color(block?["color"] as? String), .font: font])
    guard let block else { return out }
    var name = block["title"] as? String ?? ""
    if name.count > 24 { name = String(name.prefix(23)) + "…" }
    let when = live ? (block["until"] as? String ?? "") : (block["time"] as? String ?? "")
    out.append(NSAttributedString(string: "\(name) · \(when)", attributes: [.font: font]))
    return out
  }

  private func menu(now: Double, live: [String: Any]?) -> NSMenu {
    let menu = NSMenu()
    let header = NSMenuItem(
      title: live != nil ? label("now") : label("next_up"), action: nil, keyEquivalent: "")
    header.isEnabled = false
    menu.addItem(header)
    let ahead = blocks.filter { Self.ms($0, "end_ms") > now }.prefix(8)
    if ahead.isEmpty {
      let empty = NSMenuItem(title: label("nothing_next"), action: nil, keyEquivalent: "")
      empty.isEnabled = false
      menu.addItem(empty)
    }
    for block in ahead {
      let row = NSMenuItem(title: "", action: #selector(openTask(_:)), keyEquivalent: "")
      row.target = self
      row.representedObject = block["id"] as? String
      let text = NSMutableAttributedString(
        string: "● ",
        attributes: [.foregroundColor: Self.done(block) ? NSColor.tertiaryLabelColor : Self.color(block["color"] as? String)])
      text.append(NSAttributedString(string: "\(block["time"] as? String ?? "")   \(block["title"] as? String ?? "")"))
      row.attributedTitle = text
      menu.addItem(row)
    }
    menu.addItem(.separator())
    let openApp = NSMenuItem(title: label("today"), action: #selector(openToday), keyEquivalent: "")
    openApp.target = self
    menu.addItem(openApp)
    return menu
  }

  /// Redraws at the next start or end, so the title moves on by itself.
  private func scheduleRedraw(after now: Double) {
    timer?.invalidate()
    let next = blocks.flatMap { [Self.ms($0, "start_ms"), Self.ms($0, "end_ms")] }
      .filter { $0 > now }.min()
    guard let next else { return }
    timer = Timer.scheduledTimer(withTimeInterval: (next - now) / 1000 + 1, repeats: false) {
      [weak self] _ in self?.render()
    }
  }

  @objc private func openTask(_ sender: NSMenuItem) {
    guard let id = sender.representedObject as? String else { return }
    open("dottoday://task/\(id)")
  }

  @objc private func openToday() { open("dottoday://today") }

  private static func color(_ hex: String?) -> NSColor {
    guard let hex, hex.count == 7, let rgb = UInt32(hex.dropFirst(), radix: 16) else {
      return .secondaryLabelColor
    }
    return NSColor(
      red: CGFloat((rgb >> 16) & 0xFF) / 255, green: CGFloat((rgb >> 8) & 0xFF) / 255,
      blue: CGFloat(rgb & 0xFF) / 255, alpha: 1)
  }
}
