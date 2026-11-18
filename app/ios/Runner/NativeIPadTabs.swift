import Flutter
import UIKit

/// The iPad's native navigation (ED-171, R2-1 ED-267, iPadOS 18+): a
/// `UITabBarController` in tab-and-sidebar mode, so iPadOS draws the top
/// tabs, the sidebar and its toggle, and a bottom bar in narrow windows.
/// The one Flutter view moves into whichever tab is selected; Flutter
/// draws only the content. Older iPads keep Flutter's own shells.
@available(iOS 18.0, *)
final class NativeIPadTabs: NSObject, UITabBarControllerDelegate {
  private let onSelect: (Int) -> Void
  private let onAdd: () -> Void
  private var controller: PadTabsController?
  private var add: UIButton?
  private weak var flutter: FlutterViewController?
  private var hosts: [String: UIViewController] = [:]
  private var made: [String: UITab] = [:]
  private var blocked = false

  /// The board's inset from the window's edge, as on iPhone (ED-124).
  private let edge: CGFloat = 21
  /// The +'s size: the height of iPadOS's top bar, and the touch minimum.
  private let size: CGFloat = 44
  private let gap: CGFloat = 6

  init(onSelect: @escaping (Int) -> Void, onAdd: @escaping () -> Void) {
    self.onSelect = onSelect
    self.onAdd = onAdd
  }

  /// Shows [items] with [selected] current, installing the controller as
  /// the window's root the first time.
  func configure(_ args: [String: Any], teal: UIColor) {
    let items = args["items"] as? [[String: Any]] ?? []
    let selected = args["selected"] as? Int ?? -1
    guard let tabs = install(teal: teal) else { return }
    tabs.view.tintColor = teal
    add?.accessibilityLabel = args["addLabel"] as? String
    add?.isHidden = !(args["showAdd"] as? Bool ?? true)
    // One UITab per place for the controller's life: a tab owns its
    // container, and UIKit refuses a container shared by two tabs (the
    // set changes with width: Week is not a phone place).
    let wanted = items.enumerated().map { index, item in tab(item, index: index) }
    if tabs.tabs.map(\.identifier) != wanted.map(\.identifier) {
      tabs.setTabs(wanted, animated: false)
    }
    let target = tabs.tabs.first { ($0.userInfo as? NSNumber)?.intValue == selected }
    if let target, tabs.selectedTab !== target { tabs.selectedTab = target }
    // Always: the first tab is selected before anything moves the Flutter
    // view into it, and a view outside the window stops drawing.
    if let current = tabs.selectedTab { adopt(into: current) }
    placeAdd()
  }

  /// While a Flutter sheet, dialog or menu is open the tabs stay put but
  /// refuse taps, so the page can't change under it. Not hidden: hiding
  /// gives back the bar's safe area and the page would jump under the
  /// open menu.
  func setVisible(_ visible: Bool) {
    blocked = !visible
    guard let add else { return }
    // The + is ours and changes no layout: it fades as on iPhone.
    UIView.animate(withDuration: UIAccessibility.isReduceMotionEnabled ? 0 : 0.2) {
      add.alpha = visible ? 1 : 0
    }
    add.isUserInteractionEnabled = visible
    add.accessibilityElementsHidden = !visible
  }

  // MARK: Building

  private func install(teal: UIColor) -> PadTabsController? {
    if let controller { return controller }
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    guard let window = scenes.flatMap(\.windows).first(where: \.isKeyWindow)
      ?? scenes.first?.windows.first,
      let flutter = window.rootViewController as? FlutterViewController
    else { return nil }
    let tabs = PadTabsController()
    tabs.mode = .tabSidebar
    tabs.delegate = self
    tabs.onLayout = { [weak self] in self?.placeAdd() }
    let add = NativeAddButton.make(teal: teal)
    add.addAction(UIAction { [weak self] _ in self?.onAdd() }, for: .touchUpInside)
    tabs.view.addSubview(add)
    self.add = add
    self.flutter = flutter
    window.rootViewController = tabs
    controller = tabs
    return tabs
  }

  /// The place's tab, made once and updated in place.
  private func tab(_ item: [String: Any], index: Int) -> UITab {
    let id = item["id"] as? String ?? String(index)
    let tab =
      made[id]
      ?? UITab(title: "", image: nil, identifier: id) { [weak self] _ in
        self?.host(for: id) ?? UIViewController()
      }
    made[id] = tab
    tab.title = item["label"] as? String ?? ""
    tab.image = NativeSymbols.image(item["symbol"] as? String ?? "")
    let badge = item["badge"] as? Int ?? 0
    tab.badgeValue = badge > 0 ? (badge > 99 ? "99+" : String(badge)) : nil
    // Settings is never a tab: the sidebar only, last (ED-265, ED-238).
    // The places are fixed, so there is nothing to rearrange.
    tab.preferredPlacement = item["foot"] as? Bool == true ? .sidebarOnly : .fixed
    tab.userInfo = index as NSNumber
    return tab
  }

  /// One plain container per tab; the Flutter view lives in the current one.
  private func host(for id: String) -> UIViewController {
    if let host = hosts[id] { return host }
    let host = UIViewController()
    hosts[id] = host
    return host
  }

  /// Moves the Flutter view into [tab]'s container.
  private func adopt(into tab: UITab) {
    guard let flutter else { return }
    let host = host(for: tab.identifier)
    if flutter.parent === host { return }
    flutter.willMove(toParent: nil)
    flutter.view.removeFromSuperview()
    flutter.removeFromParent()
    host.addChild(flutter)
    flutter.view.frame = host.view.bounds
    flutter.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    host.view.addSubview(flutter.view)
    flutter.didMove(toParent: host)
    // Leaving the window (the root swap, a move) tells Flutter its view
    // disappeared, and the engine stops drawing until it hears the view
    // appear again: say so once any disappear in progress has ended.
    let appear = { [weak flutter] in
      flutter?.beginAppearanceTransition(true, animated: false)
      flutter?.endAppearanceTransition()
    }
    if let root = flutter as? DotFlutterViewController {
      root.afterDisappearing(appear)
    } else {
      appear()
    }
  }

  // MARK: The +

  /// The teal + at the window's trailing edge, level with iPadOS's top
  /// bar (E-R2-1 1b). With the sidebar docked there is no top bar: the +
  /// keeps the same band and the content starts below it, so the + never
  /// covers the page's own header. In a compact window it sits beside
  /// the bottom tab bar, as on iPhone.
  private func placeAdd() {
    guard let tabs = controller, let add else { return }
    let view = tabs.view!
    let x = view.bounds.maxX - view.safeAreaInsets.right - edge - size
    var reserve: CGFloat = 0
    if let bar = Self.topBar(in: view) {
      let band = bar.convert(bar.bounds, to: view)
      add.frame = CGRect(x: x, y: band.midY - size / 2, width: size, height: size)
    } else if tabs.traitCollection.horizontalSizeClass == .compact, !tabs.tabBar.isHidden {
      placeCompact(tabs, add)
    } else {
      add.frame = CGRect(x: x, y: view.safeAreaInsets.top, width: size, height: size)
      reserve = add.isHidden ? 0 : size
    }
    view.bringSubviewToFront(add)
    for host in hosts.values where host.additionalSafeAreaInsets.top != reserve {
      host.additionalSafeAreaInsets.top = reserve
    }
  }

  /// A compact window is the phone (ED-104): the bar from the leading
  /// inset to 6 short of the +, the + as tall as the capsule (ED-124).
  private func placeCompact(_ tabs: PadTabsController, _ add: UIButton) {
    let view = tabs.view!
    let bar = tabs.tabBar
    let inset = view.safeAreaInsets
    var frame = bar.frame
    frame.origin.x = inset.left + edge
    frame.size.width = view.bounds.width - inset.left - inset.right - 2 * edge - size - gap
    if !add.isHidden, bar.frame != frame {
      bar.frame = frame
      bar.layoutIfNeeded()
    }
    let platter = bar.subviews.first { String(describing: type(of: $0)).contains("Platter") }
    let capsule = (platter ?? bar).convert((platter ?? bar).bounds, to: view)
    add.frame = CGRect(
      x: capsule.maxX + gap, y: capsule.midY - capsule.height / 2,
      width: capsule.height, height: capsule.height)
  }

  /// iPadOS's floating top bar, when it shows. No public API reports its
  /// frame (as with the iPhone's capsule, ED-132), so find it by type.
  private static func topBar(in view: UIView) -> UIView? {
    var queue = [view]
    while !queue.isEmpty {
      let next = queue.removeFirst()
      if String(describing: type(of: next)).contains("FloatingTabBar"), next !== view {
        let shown = !next.isHidden && next.alpha > 0.01 && next.bounds.height > 0
        return shown ? next : nil
      }
      queue.append(contentsOf: next.subviews)
    }
    return nil
  }

  // MARK: UITabBarControllerDelegate

  func tabBarController(_ tabBarController: UITabBarController, shouldSelectTab tab: UITab) -> Bool {
    !blocked
  }

  func tabBarController(
    _ tabBarController: UITabBarController, didSelectTab selectedTab: UITab,
    previousTab: UITab?
  ) {
    adopt(into: selectedTab)
    if let index = (selectedTab.userInfo as? NSNumber)?.intValue { onSelect(index) }
  }
}

/// The tab controller, reporting each layout so the + can follow the bar.
@available(iOS 18.0, *)
final class PadTabsController: UITabBarController {
  var onLayout: (() -> Void)?

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    onLayout?()
  }
}

/// The teal + (ED-124): prominent glass on iOS 26, a solid teal circle
/// before (ED-128 D2). The iPhone row and the iPad share it.
enum NativeAddButton {
  static func make(teal: UIColor) -> UIButton {
    let plus = UIImage(
      systemName: "plus",
      withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold))
    if #available(iOS 26.0, *) {
      var config = UIButton.Configuration.prominentGlass()
      config.image = plus
      config.baseForegroundColor = .white
      config.cornerStyle = .capsule
      let button = UIButton(configuration: config)
      button.tintColor = teal
      return button
    }
    var config = UIButton.Configuration.filled()
    config.image = plus
    config.baseBackgroundColor = teal
    config.baseForegroundColor = .white
    config.cornerStyle = .capsule
    return UIButton(configuration: config)
  }
}

/// SF Symbols for native chrome (ED-260), and the app's Today dot.
enum NativeSymbols {
  static func image(_ name: String) -> UIImage? {
    if name == "dot" {
      let size = CGSize(width: 24, height: 24)
      return UIGraphicsImageRenderer(size: size).image { _ in
        UIBezierPath(ovalIn: CGRect(x: 5, y: 5, width: 14, height: 14)).fill()
      }.withRenderingMode(.alwaysTemplate)
    }
    return UIImage(systemName: name)
  }
}



