import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    // Opens at 1280×800; never smaller than 840×640 (ED-169): 840 is the
    // expanded class, and 640 stays above the short-height rule's 480, so
    // the Mac never gets the phone layout.
    self.contentMinSize = NSSize(width: 840, height: 640)
    self.setContentSize(NSSize(width: 1280, height: 800))
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)
    (NSApp.delegate as? AppDelegate)?.attachDeepLinks(to: flutterViewController)

    super.awakeFromNib()
  }
}
