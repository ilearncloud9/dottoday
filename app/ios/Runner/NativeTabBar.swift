import Flutter
import UIKit

/// The iPhone's native bottom row (ED-124, ED-128 N3): a genuine UIKit tab
/// bar with the teal + on its line, over the Flutter content. Flutter says
/// what it shows (`configure`) and when it hides under a Flutter sheet or
/// dialog (`visible`); taps go back as `select` and `add`.
///
/// iOS 26 and later draw the system's Liquid Glass capsule and a teal
/// prominent-glass +; iOS 16–25 get F2: the system material bar rounded to
/// a capsule and a solid teal + (ED-128 D2). Geometry: the bar 21 from the
/// left and bottom, the + 21 from the right and bottom, 6 apart, the + as
/// tall as the bar (ED-124).
final class NativeTabBar: NSObject, UITabBarDelegate {
  static let shared = NativeTabBar()

  private var channel: FlutterMethodChannel?
  private var bar: CapsuleTabBar?
  private var addHeight: NSLayoutConstraint?
  private var add: UIButton?
  private var addLabel = ""

  /// The board's insets (ED-124).
  private let edge: CGFloat = 21
  private let gap: CGFloat = 6

  /// The capsule's height before iOS reports its own (ED-124: 63).
  private let capsule: CGFloat = 63

  /// Dottoday teal, light and dark (ED-262: trait-resolving).
  private let teal = UIColor { traits in
    traits.userInterfaceStyle == .dark
      ? UIColor(red: 0x5B / 255, green: 0xC4 / 255, blue: 0xB8 / 255, alpha: 1)
      : UIColor(red: 0x11 / 255, green: 0x61 / 255, blue: 0x5C / 255, alpha: 1)
  }

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "dottoday/native_tab_bar", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return result(nil) }
      switch call.method {
      case "available":
        // Phones only: iPad gets its own top tabs and sidebar (R2-1).
        result(UIDevice.current.userInterfaceIdiom == .phone)
      case "configure":
        self.configure(call.arguments as? [String: Any] ?? [:])
        result(nil)
      case "visible":
        self.setVisible(call.arguments as? Bool ?? true)
        result(nil)
      case "remove":
        self.remove()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
  }

  // MARK: Building

  private var host: UIView? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let window = scenes.flatMap(\.windows).first { $0.isKeyWindow } ?? scenes.first?.windows.first
    return (window?.rootViewController as? FlutterViewController)?.view
  }

  private func install() -> (CapsuleTabBar, UIButton)? {
    if let bar, let add { return (bar, add) }
    guard let host else { return nil }
    let bar = CapsuleTabBar()
    bar.onCapsule = { [weak self] capsule in self?.align(to: capsule) }
    bar.delegate = self
    bar.tintColor = teal
    bar.translatesAutoresizingMaskIntoConstraints = false
    let add = makeAdd()
    add.translatesAutoresizingMaskIntoConstraints = false
    host.addSubview(bar)
    host.addSubview(add)
    let addHeight = add.heightAnchor.constraint(equalToConstant: capsule)
    NSLayoutConstraint.activate([
      bar.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: edge),
      bar.bottomAnchor.constraint(equalTo: host.bottomAnchor, constant: -edge),
      add.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: -edge),
      add.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: gap),
      add.bottomAnchor.constraint(equalTo: host.bottomAnchor, constant: -edge),
      addHeight,
      add.widthAnchor.constraint(equalTo: add.heightAnchor),
    ])
    self.addHeight = addHeight
    if #unavailable(iOS 26.0) {
      styleCompat(bar)
      bar.heightAnchor.constraint(equalToConstant: capsule).isActive = true
    }
    self.bar = bar
    self.add = add
    return (bar, add)
  }

  /// The + : teal prominent glass on iOS 26, a solid teal circle before.
  private func makeAdd() -> UIButton {
    let plus = UIImage(
      systemName: "plus",
      withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold))
    let button: UIButton
    if #available(iOS 26.0, *) {
      var config = UIButton.Configuration.prominentGlass()
      config.image = plus
      config.baseForegroundColor = .white
      config.cornerStyle = .capsule
      button = UIButton(configuration: config)
      button.tintColor = teal
    } else {
      var config = UIButton.Configuration.filled()
      config.image = plus
      config.baseBackgroundColor = teal
      config.baseForegroundColor = .white
      config.cornerStyle = .capsule
      button = UIButton(configuration: config)
    }
    button.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    return button
  }

  /// F2 (iOS 16–25): the system material bar, rounded to a capsule.
  private func styleCompat(_ bar: UITabBar) {
    let look = UITabBarAppearance()
    look.configureWithDefaultBackground()
    bar.standardAppearance = look
    if #available(iOS 15.0, *) { bar.scrollEdgeAppearance = look }
    bar.layer.cornerCurve = .continuous
    bar.clipsToBounds = true
    bar.layer.cornerRadius = 31.5
  }

  /// iOS 26 sizes the glass capsule to its tabs, centres it at the top
  /// of the bar and leaves room below for the home indicator. Move the bar
  /// so the capsule's right edge sits 6 from the + and its bottom 21 from
  /// the screen's, and size the + to the capsule (ED-124, ED-132: from the
  /// rendered capsule, on every layout pass).
  private func align(to capsule: CGRect) {
    guard let bar else { return }
    let shift = CGAffineTransform(
      translationX: bar.bounds.width - capsule.maxX,
      y: bar.bounds.height - capsule.maxY)
    if bar.transform != shift { bar.transform = shift }
    if addHeight?.constant != capsule.height { addHeight?.constant = capsule.height }
  }

  // MARK: Updating

  private func configure(_ args: [String: Any]) {
    guard let (bar, add) = install() else { return }
    let items = (args["items"] as? [[String: Any]] ?? []).enumerated().map { index, item in
      tabItem(item, index: index)
    }
    bar.setItems(items, animated: false)
    let selected = args["selected"] as? Int ?? -1
    bar.selectedItem = items.indices.contains(selected) ? items[selected] : nil
    addLabel = args["addLabel"] as? String ?? ""
    add.accessibilityLabel = addLabel
    add.isHidden = !(args["showAdd"] as? Bool ?? true)
    bar.isHidden = items.isEmpty
  }

  private func tabItem(_ item: [String: Any], index: Int) -> UITabBarItem {
    let title = item["label"] as? String
    let symbol = item["symbol"] as? String ?? ""
    let selected = item["selectedSymbol"] as? String ?? symbol
    let tab = UITabBarItem(title: title, image: image(symbol), selectedImage: image(selected))
    tab.tag = index
    if let badge = item["badge"] as? Int, badge > 0 {
      tab.badgeValue = badge > 99 ? "99+" : String(badge)
      tab.badgeColor = teal
    }
    tab.accessibilityLabel = item["semanticLabel"] as? String ?? title
    return tab
  }

  /// An SF Symbol, or "dot": the app's Today dot as a template image
  /// (ED-260, CR-014: no SF Symbol is that glyph).
  private func image(_ name: String) -> UIImage? {
    if name == "dot" {
      let size = CGSize(width: 24, height: 24)
      return UIGraphicsImageRenderer(size: size).image { _ in
        UIBezierPath(ovalIn: CGRect(x: 5, y: 5, width: 14, height: 14)).fill()
      }.withRenderingMode(.alwaysTemplate)
    }
    return UIImage(systemName: name)
  }

  /// Fades the row out while a Flutter sheet or dialog is open over it,
  /// and back when it closes.
  private func setVisible(_ visible: Bool) {
    let views = [bar, add].compactMap { $0 }
    let reduce = UIAccessibility.isReduceMotionEnabled
    UIView.animate(withDuration: reduce ? 0 : 0.2) {
      for view in views { view.alpha = visible ? 1 : 0 }
    }
    for view in views {
      view.isUserInteractionEnabled = visible
      view.accessibilityElementsHidden = !visible
    }
  }

  private func remove() {
    bar?.removeFromSuperview()
    add?.removeFromSuperview()
    bar = nil
    add = nil
  }

  // MARK: Taps

  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    channel?.invokeMethod("select", arguments: item.tag)
  }

  @objc private func addTapped() {
    channel?.invokeMethod("add", arguments: nil)
  }
}


/// A tab bar that reports where iOS 26 drew its glass capsule after each
/// layout; earlier systems have none and report nothing.
final class CapsuleTabBar: UITabBar {
  var onCapsule: ((CGRect) -> Void)?

  override func layoutSubviews() {
    super.layoutSubviews()
    let platter = subviews.first { String(describing: type(of: $0)).contains("Platter") }
    if let platter { onCapsule?(platter.frame) }
  }
}
