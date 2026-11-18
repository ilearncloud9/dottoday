import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private let material = WindowMaterialBridge()

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    // The sidebar's vibrancy (ED-130): Flutter draws on a clear view over
    // the system material and paints everything but the sidebar opaque.
    flutterViewController.backgroundColor = .clear
    let root = NSViewController()
    root.view = WindowMaterialBridge.backdrop()
    root.addChild(flutterViewController)
    flutterViewController.view.frame = root.view.bounds
    flutterViewController.view.autoresizingMask = [.width, .height]
    root.view.addSubview(flutterViewController.view)
    self.contentViewController = root
    // Opens at 1280×800; never smaller than 840×640 (ED-169): 840 is the
    // expanded class, and 640 stays above the short-height rule's 480, so
    // the Mac never gets the phone layout.
    self.contentMinSize = NSSize(width: 840, height: 640)
    self.setContentSize(NSSize(width: 1280, height: 800))
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)
    (NSApp.delegate as? AppDelegate)?.attachDeepLinks(to: flutterViewController)
    material.attach(to: flutterViewController, in: self)

    super.awakeFromNib()
  }
}
