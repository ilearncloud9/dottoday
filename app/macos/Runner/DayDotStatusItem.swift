import Cocoa

/// The day dot in the menu bar (docs/02 F9, docs/11 A1, docs/09 M9.6): a
/// ring that fills from Wake Up to Bedtime, then the task under way or the
/// next one. Click: What's next — the dot with Done and +15 min (B6, run
/// by the app in process), what is left of the day, Today. Text arrives
/// formatted and localised in the day snapshot
/// (lib/data/snapshot/snapshot_store_json.dart). ⌘-drag removes it.
final class DayDotStatusItem: NSObject {
  private let open: (String) -> Void
  private let act: ([String: Any]) -> Void
  private var item: NSStatusItem?
  private var snapshot: [String: Any] = [:]
  private var timer: Timer?

  /// The ring moves on at least this often (a 15 h day: under 1 % a step).
  static let tick: TimeInterval = 5 * 60

  init(open: @escaping (String) -> Void, act: @escaping ([String: Any]) -> Void) {
    self.open = open
    self.act = act
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

  /// Share of the waking day gone at [now] (ms): 0 before Wake Up, 1 after Bedtime.
  static func dayShare(_ snapshot: [String: Any], now: Double) -> Double {
    let wake = ms(snapshot, "wake_ms")
    let bed = ms(snapshot, "bed_ms")
    guard bed > wake else { return 0 }
    return min(1, max(0, (now - wake) / (bed - wake)))
  }

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
    button.image = DayDotImage.make(share: Self.dayShare(snapshot, now: now))
    button.imagePosition = .imageLeading
    button.attributedTitle = title(for: shown, live: live != nil)
    button.setAccessibilityLabel(
      shown.map { "\(label(live != nil ? "now" : "next_up")): \($0["title"] as? String ?? "")" }
        ?? label("nothing_next"))
    item.menu = menu(now: now, live: live, shown: shown)
    scheduleRedraw(after: now)
  }

  private func title(for block: [String: Any]?, live: Bool) -> NSAttributedString {
    let font = NSFont.menuBarFont(ofSize: 0)
    guard let block else { return NSAttributedString(string: "") }
    var name = block["title"] as? String ?? ""
    if name.count > 24 { name = String(name.prefix(23)) + "…" }
    let when = live ? (block["until"] as? String ?? "") : (block["time"] as? String ?? "")
    return NSAttributedString(string: " \(name) · \(when)", attributes: [.font: font])
  }

  private func menu(now: Double, live: [String: Any]?, shown: [String: Any]?) -> NSMenu {
    let menu = NSMenu()
    let header = NSMenuItem(
      title: live != nil ? label("now") : label("next_up"), action: nil, keyEquivalent: "")
    header.isEnabled = false
    menu.addItem(header)
    if let shown {
      menu.addItem(row(for: shown))
      menu.addItem(action(label("done"), kind: "mark_done", block: shown))
      menu.addItem(action(label("plus"), kind: "add_fifteen", block: shown))
      menu.addItem(.separator())
    }
    let ahead = blocks.filter { Self.ms($0, "end_ms") > now && $0["id"] as? String != shown?["id"] as? String }
      .prefix(8)
    if ahead.isEmpty && shown == nil {
      let empty = NSMenuItem(title: label("nothing_next"), action: nil, keyEquivalent: "")
      empty.isEnabled = false
      menu.addItem(empty)
    }
    for block in ahead { menu.addItem(row(for: block)) }
    if !ahead.isEmpty { menu.addItem(.separator()) }
    let openApp = NSMenuItem(title: label("today"), action: #selector(openToday), keyEquivalent: "")
    openApp.target = self
    menu.addItem(openApp)
    return menu
  }

  private func row(for block: [String: Any]) -> NSMenuItem {
    let row = NSMenuItem(title: "", action: #selector(openTask(_:)), keyEquivalent: "")
    row.target = self
    row.representedObject = block["id"] as? String
    let text = NSMutableAttributedString(
      string: "● ",
      attributes: [.foregroundColor: Self.done(block) ? NSColor.tertiaryLabelColor : Self.color(block["color"] as? String)])
    text.append(NSAttributedString(string: "\(block["time"] as? String ?? "")   \(block["title"] as? String ?? "")"))
    row.attributedTitle = text
    return row
  }

  /// Done / +15 min on the dot: the app runs the B6 intent (DotIntents).
  private func action(_ title: String, kind: String, block: [String: Any]) -> NSMenuItem {
    let item = NSMenuItem(title: title, action: #selector(runAction(_:)), keyEquivalent: "")
    item.target = self
    item.indentationLevel = 1
    item.representedObject = [
      "kind": kind, "id": block["id"] as? String ?? "", "planned_end_ms": Self.ms(block, "end_ms"),
    ]
    return item
  }

  @objc private func runAction(_ sender: NSMenuItem) {
    guard let action = sender.representedObject as? [String: Any] else { return }
    act(action)
  }

  /// Redraws at the next start or end, and every [tick] for the ring.
  private func scheduleRedraw(after now: Double) {
    timer?.invalidate()
    let boundary = blocks.flatMap { [Self.ms($0, "start_ms"), Self.ms($0, "end_ms")] }
      .filter { $0 > now }.min()
    let wait = min(Self.tick, boundary.map { ($0 - now) / 1000 + 1 } ?? Self.tick)
    timer = Timer.scheduledTimer(withTimeInterval: wait, repeats: false) { [weak self] _ in
      self?.render()
    }
  }

  @objc private func openTask(_ sender: NSMenuItem) {
    guard let id = sender.representedObject as? String else { return }
    open("dottoday://task/\(id)")
  }

  @objc private func openToday() { open("dottoday://today") }

  static func color(_ hex: String?) -> NSColor {
    guard let hex, hex.count == 7, let rgb = UInt32(hex.dropFirst(), radix: 16) else {
      return .secondaryLabelColor
    }
    return NSColor(
      red: CGFloat((rgb >> 16) & 0xFF) / 255, green: CGFloat((rgb >> 8) & 0xFF) / 255,
      blue: CGFloat(rgb & 0xFF) / 255, alpha: 1)
  }
}

/// The day dot as a menu-bar template image: a ring with the share of the
/// waking day filled clockwise from the top, a dot at the centre. A template
/// image, so the menu bar tints it for light and dark itself.
enum DayDotImage {
  static func make(share: Double, size: CGFloat = 16) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
      let center = NSPoint(x: rect.midX, y: rect.midY)
      let radius = size / 2 - 1.5
      NSColor.black.withAlphaComponent(0.35).setStroke()
      let track = NSBezierPath()
      track.appendArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360)
      track.lineWidth = 2
      track.stroke()
      if share > 0 {
        NSColor.black.setStroke()
        let fill = NSBezierPath()
        fill.appendArc(
          withCenter: center, radius: radius, startAngle: 90, endAngle: 90 - 360 * min(1, share),
          clockwise: true)
        fill.lineWidth = 2
        fill.lineCapStyle = .round
        fill.stroke()
      }
      NSColor.black.setFill()
      NSBezierPath(ovalIn: NSRect(x: center.x - 2.5, y: center.y - 2.5, width: 5, height: 5)).fill()
      return true
    }
    image.isTemplate = true
    image.accessibilityDescription = nil
    return image
  }
}
