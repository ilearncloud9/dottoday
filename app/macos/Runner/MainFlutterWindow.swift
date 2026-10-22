import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    // Owner-approved after the M4 sweep: opens at 1280×800, the expanded width
    // class the Mac renders are drawn at (docs/10 §4), and never shrinks below
    // 960×640 so the rail plus three-day Today stay usable.
    self.contentMinSize = NSSize(width: 960, height: 640)
    self.setContentSize(NSSize(width: 1280, height: 800))
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)
    (NSApp.delegate as? AppDelegate)?.attachDeepLinks(to: flutterViewController)

    super.awakeFromNib()
  }
}
