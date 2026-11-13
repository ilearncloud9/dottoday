// Throwaway spike (ED-262): native UITabBar label contrast over task colours (CR-106)
// and + / Day menu order on iOS 26.5 (CR-121). Synthetic data only; not Dottoday.
import UIKit

func hex(_ s: String) -> UIColor {
  var v: UInt64 = 0; Scanner(string: s).scanHexInt64(&v)
  return UIColor(red: CGFloat((v >> 16) & 255) / 255, green: CGFloat((v >> 8) & 255) / 255, blue: CGFloat(v & 255) / 255, alpha: 1)
}
let args = ProcessInfo.processInfo.arguments
func arg(_ k: String) -> String? { if let i = args.firstIndex(of: k), i + 1 < args.count { return args[i + 1] }; return nil }
let dyn = args.contains("-dyn")
let ground = hex("FBF7F1"), inactive = hex("6E6E73")
// -dyn: the accent resolves per trait (light #11615C, dark #5BC4B8, ED-174) so adaptive glass can pick the dark one
let teal: UIColor = dyn ? UIColor { $0.userInterfaceStyle == .dark ? hex("5BC4B8") : hex("11615C") } : hex("11615C")

final class DayVC: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = hex(arg("-bg") ?? "FBF7F1")   // content colour under the bar
    let top = UIView(); top.backgroundColor = ground; top.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(top)
    NSLayoutConstraint.activate([top.topAnchor.constraint(equalTo: view.topAnchor), top.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                 top.trailingAnchor.constraint(equalTo: view.trailingAnchor), top.heightAnchor.constraint(equalToConstant: 300)])
    let other = args.contains("-otherday")
    let plus = UIButton(type: .system)
    var pc: UIButton.Configuration
    if #available(iOS 26.0, *) { pc = .prominentGlass() } else { pc = .filled() }
    pc.image = UIImage(systemName: "plus"); pc.baseBackgroundColor = teal; pc.cornerStyle = .capsule
    plus.configuration = pc
    plus.accessibilityLabel = "Add a task. Hold for Brain dump, Routine, Paste a list"
    plus.addAction(UIAction { _ in NSLog("SPIKE tap + : Add") }, for: .primaryActionTriggered)
    plus.menu = UIMenu(children: [
      UIAction(title: "Brain dump", image: UIImage(systemName: "brain.head.profile")) { _ in NSLog("SPIKE brain dump") },
      UIAction(title: "Routine", image: UIImage(systemName: "repeat")) { _ in NSLog("SPIKE routine") },
      UIAction(title: "Paste a list", image: UIImage(systemName: "list.clipboard")) { _ in NSLog("SPIKE paste") },
    ])
    plus.preferredMenuElementOrder = .fixed
    plus.showsMenuAsPrimaryAction = false
    let day = UIButton(type: .system)
    var dc: UIButton.Configuration
    if #available(iOS 26.0, *) { dc = .glass() } else { dc = .gray() }
    dc.title = "Day"; dc.image = UIImage(systemName: "chevron.down"); dc.imagePlacement = .trailing; dc.imagePadding = 4; dc.cornerStyle = .capsule
    if !dyn { dc.baseForegroundColor = hex("241F2B") }
    day.configuration = dc
    func item(_ t: String, _ s: String, _ off: Bool = false) -> UIAction {
      UIAction(title: t, image: UIImage(systemName: s), attributes: off ? [.disabled] : []) { _ in NSLog("SPIKE \(t)") }
    }
    day.menu = UIMenu(children: [
      UIMenu(title: "Time", options: .displayInline, children: [item("Need more time", "plus.circle", other), item("Shift the rest from here", "arrow.right.to.line", other)]),
      UIMenu(title: "Plan", options: .displayInline, children: [item("Brain dump", "brain.head.profile"), item("Drop a routine", "repeat")]),
      UIMenu(title: "Day", options: .displayInline, children: [item("Duplicate day", "plus.square.on.square"), item("Copy day as text", "doc.on.doc"), item("Review the day", "checklist")]),
      UIMenu(title: "Layout", options: .displayInline, children: [item("Low-energy mode", "leaf"), item("Show everything", "arrow.up.left.and.arrow.down.right")]),
    ])
    day.preferredMenuElementOrder = .fixed
    day.showsMenuAsPrimaryAction = true
    for b in [plus, day] { b.translatesAutoresizingMaskIntoConstraints = false; view.addSubview(b) }
    let g = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      plus.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -21), plus.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -16),
      plus.widthAnchor.constraint(equalToConstant: 63), plus.heightAnchor.constraint(equalToConstant: 63),
      day.trailingAnchor.constraint(equalTo: plus.leadingAnchor, constant: -12), day.centerYAnchor.constraint(equalTo: plus.centerYAnchor),
      day.heightAnchor.constraint(equalToConstant: 44),
    ])
  }
}

final class App: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  func application(_ a: UIApplication, didFinishLaunchingWithOptions o: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    let tabs = UITabBarController()
    func vc(_ t: String, _ s: String, _ c: UIViewController = UIViewController()) -> UIViewController {
      c.tabBarItem = UITabBarItem(title: t, image: UIImage(systemName: s), selectedImage: nil); if c.view.backgroundColor == nil { c.view.backgroundColor = ground }; return c
    }
    tabs.viewControllers = [vc("Today", "smallcircle.filled.circle", DayVC()), vc("Inbox", "tray"), vc("Calendar", "calendar"), vc("Search", "magnifyingglass")]
    tabs.tabBar.tintColor = teal
    tabs.tabBar.unselectedItemTintColor = inactive        // ED-154 asks for #6E6E73
    let ap = UITabBarAppearance(); ap.configureWithDefaultBackground()
    for l in [ap.stackedLayoutAppearance, ap.inlineLayoutAppearance, ap.compactInlineLayoutAppearance] {
      l.normal.iconColor = inactive; l.normal.titleTextAttributes = [.foregroundColor: inactive]
      l.selected.iconColor = teal; l.selected.titleTextAttributes = [.foregroundColor: teal]
    }
    tabs.tabBar.standardAppearance = ap; tabs.tabBar.scrollEdgeAppearance = ap
    window = UIWindow(frame: UIScreen.main.bounds); window?.rootViewController = tabs; window?.makeKeyAndVisible()
    return true
  }
}
UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(App.self))
