import Cocoa
import Combine
import SwiftUI

/// What the Now mini window shows (ED-475): the task under way; else one
/// that ended unticked within the hour (the in-app Need more time? nudge's
/// window, `domain/scheduling/running_late.dart`) while nothing has started
/// since; else the next task; else nothing left. Times are read from the
/// snapshot's blocks, words from its `labels` and `now_window`.
final class NowMiniModel: ObservableObject {
  static let width: CGFloat = 380
  static let lateWindow: Double = 60 * 60_000

  enum Moment {
    case running([String: Any], next: [String: Any]?)
    case ended([String: Any], minutes: Int, next: [String: Any]?)
    case upcoming([String: Any])
    case nothing
  }

  let act: ([String: Any]) -> Void
  @Published var snapshot: [String: Any] = [:]
  @Published private(set) var now = Date()
  private var timer: Timer?

  /// Ticks every 15 s only while the window shows.
  var visible = false {
    didSet {
      timer?.invalidate()
      timer = nil
      guard visible else { return }
      now = Date()
      timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
        self?.now = Date()
      }
    }
  }

  init(act: @escaping ([String: Any]) -> Void) { self.act = act }

  func label(_ key: String) -> String { (snapshot["labels"] as? [String: String])?[key] ?? "" }

  func word(_ key: String, n: Int? = nil, title: String? = nil) -> String {
    var text = (snapshot["now_window"] as? [String: String])?[key] ?? ""
    if let n { text = text.replacingOccurrences(of: "{n}", with: "\(n)") }
    if let title { text = text.replacingOccurrences(of: "{title}", with: title) }
    return text
  }

  /// The App colour's tone for light or dark (`appColourTones`).
  func accent(_ key: String, dark: Bool) -> Color {
    let tones = snapshot["accent"] as? [String: [String: String]]
    let fallback = dark ? (key == "on" ? "#0C2523" : "#5BC4B8") : (key == "on" ? "#FFFFFF" : "#11615C")
    return Color(nsColor: DayDotStatusItem.color(tones?[dark ? "dark" : "light"]?[key] ?? fallback))
  }

  static func ms(_ block: [String: Any], _ key: String) -> Double {
    (block[key] as? NSNumber)?.doubleValue ?? 0
  }

  var moment: Moment {
    let t = now.timeIntervalSince1970 * 1000
    let open = ((snapshot["blocks"] as? [[String: Any]]) ?? []).filter { !($0["done"] as? Bool ?? false) }
    let ahead = open.filter { Self.ms($0, "start_ms") > t }
    if let live = open.first(where: { Self.ms($0, "start_ms") <= t && t < Self.ms($0, "end_ms") }) {
      return .running(live, next: ahead.first)
    }
    let startedSince = { (end: Double) in open.contains { Self.ms($0, "start_ms") >= end && Self.ms($0, "start_ms") <= t } }
    if let ended = open.filter({ Self.ms($0, "end_ms") <= t && t - Self.ms($0, "end_ms") <= Self.lateWindow })
      .max(by: { Self.ms($0, "end_ms") < Self.ms($1, "end_ms") }), !startedSince(Self.ms(ended, "end_ms"))
    {
      let minutes = Int((t - Self.ms(ended, "end_ms")) / 60_000)
      return .ended(ended, minutes: minutes, next: ahead.first)
    }
    if let next = ahead.first { return .upcoming(next) }
    return .nothing
  }

  func done(_ block: [String: Any]) { act(["kind": "mark_done", "id": block["id"] as? String ?? ""]) }

  func more(_ block: [String: Any], minutes: Int) {
    act([
      "kind": "add_time", "id": block["id"] as? String ?? "", "minutes": minutes,
      "planned_end_ms": Self.ms(block, "end_ms"),
    ])
  }
}

/// The window's content (E-Minimal inset; option B, ED-475): the ring in
/// the task's colour with the minutes left, the title and what is left,
/// then round +5, +15 and +30 and the round tick in the App colour.
struct NowMiniView: View {
  @ObservedObject var model: NowMiniModel
  @Environment(\.colorScheme) private var scheme

  private var dark: Bool { scheme == .dark }
  private var ink: Color { Color(nsColor: NSColor(rgb: dark ? 0xF3ECE4 : 0x241F2B)) }
  private var muted: Color { Color(nsColor: NSColor(rgb: dark ? 0xC7BEC4 : 0x6A6273)) }
  private var chip: Color { Color(nsColor: NSColor(rgb: dark ? 0x3A3439 : 0xECE5DC)) }
  private var card: Color { Color(nsColor: NSColor(rgb: dark ? 0x2B262A : 0xFFFDF9)) }

  var body: some View {
    let parts = content
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 14) {
        NowMiniRing(color: parts.color, share: parts.share, hollow: parts.hollow, numeral: parts.numeral, ink: ink)
        VStack(alignment: .leading, spacing: 3) {
          Text(parts.title).font(ManropeMac.font(16, 800)).foregroundStyle(ink)
            .lineLimit(2).fixedSize(horizontal: false, vertical: true)
          Text(parts.meta).font(ManropeMac.font(13, 600)).foregroundStyle(muted)
            .lineLimit(2).fixedSize(horizontal: false, vertical: true)
        }
        Spacer(minLength: 0)
      }
      if parts.more || parts.block != nil {
        HStack(spacing: 8) {
          if let block = parts.block, parts.more {
            ForEach([5, 15, 30], id: \.self) { m in
              Button { model.more(block, minutes: m) } label: {
                Text(model.word("plus", n: m)).font(ManropeMac.font(12, 800)).foregroundStyle(ink)
                  .frame(width: 36, height: 36).background(Circle().fill(chip))
              }
              .buttonStyle(.plain)
              .accessibilityLabel(model.word("plus_label", n: m))
            }
          }
          if let block = parts.block {
            Button { model.done(block) } label: {
              Image(systemName: "checkmark").font(.system(size: 15, weight: .bold))
                .foregroundStyle(model.accent("on", dark: dark))
                .frame(width: 36, height: 36).background(Circle().fill(model.accent("fill", dark: dark)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(model.label("done"))
          }
        }
        .padding(.leading, 72)
      }
    }
    .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 16)
    .frame(width: NowMiniModel.width, alignment: .leading)
    .background(card)
  }

  private struct Parts {
    var title: String
    var meta: String
    var color: Color
    var share: Double = 0
    var hollow = false
    var numeral: String?
    var block: [String: Any]?
    var more = false
  }

  private var content: Parts {
    let t = model.now.timeIntervalSince1970 * 1000
    switch model.moment {
    case let .running(block, next):
      let start = NowMiniModel.ms(block, "start_ms")
      let end = NowMiniModel.ms(block, "end_ms")
      let left = max(1, Int(ceil((end - t) / 60_000)))
      return Parts(
        title: title(block), meta: meta(model.word("left", n: left), next: next), color: color(block),
        share: end > start ? (t - start) / (end - start) : 1, numeral: numeral(left), block: block, more: true)
    case let .ended(block, minutes, next):
      return Parts(
        title: title(block), meta: meta(model.word("ended", n: minutes), next: next), color: color(block),
        share: 1, block: block, more: true)
    case let .upcoming(block):
      let until = max(1, Int(ceil((NowMiniModel.ms(block, "start_ms") - t) / 60_000)))
      let when = "\(model.word("starts_in", n: until)) · \(block["time"] as? String ?? "")"
      return Parts(
        title: title(block), meta: when, color: color(block), hollow: true, numeral: numeral(until), block: block)
    case .nothing:
      return Parts(title: model.label("nothing_next"), meta: model.word("wind_down"), color: muted, hollow: true)
    }
  }

  private func title(_ block: [String: Any]) -> String { block["title"] as? String ?? "" }

  private func meta(_ first: String, next: [String: Any]?) -> String {
    guard let next else { return first }
    return "\(first) · \(model.word("next", title: title(next)))"
  }

  private func color(_ block: [String: Any]) -> Color {
    Color(nsColor: DayDotStatusItem.color(block[dark ? "color_dark" : "color"] as? String))
  }

  /// Minutes up to 99, then hours, as the Now orb counts.
  private func numeral(_ minutes: Int) -> String {
    minutes < 100 ? "\(minutes)" : model.word("hours", n: Int((Double(minutes) / 60).rounded()))
  }
}

/// The ring: [share] of it in [color] over a faint track, the numeral
/// inside; hollow before the task starts (ahead) and when nothing is left.
struct NowMiniRing: View {
  let color: Color
  let share: Double
  let hollow: Bool
  let numeral: String?
  let ink: Color

  var body: some View {
    let line: CGFloat = 6
    ZStack {
      if hollow {
        Circle().stroke(color, lineWidth: line * 0.6)
      } else {
        Circle().stroke(color.opacity(0.22), lineWidth: line)
        Circle().trim(from: 0, to: min(1, max(0.03, share)))
          .stroke(color, style: StrokeStyle(lineWidth: line, lineCap: .round))
          .rotationEffect(.degrees(-90))
      }
      if let numeral {
        Text(numeral).font(ManropeMac.font(numeral.count > 2 ? 15 : 20, 800)).foregroundStyle(ink)
      }
    }
    .padding(line / 2)
    .frame(width: 58, height: 58)
    .accessibilityHidden(true)
  }
}

extension NSColor {
  convenience init(rgb: UInt32) {
    self.init(
      red: CGFloat((rgb >> 16) & 0xFF) / 255, green: CGFloat((rgb >> 8) & 0xFF) / 255,
      blue: CGFloat(rgb & 0xFF) / 255, alpha: 1)
  }
}
