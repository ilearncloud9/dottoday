import Cocoa
func C(_ h: UInt32, _ a: CGFloat = 1) -> NSColor { NSColor(srgbRed: CGFloat((h>>16)&255)/255, green: CGFloat((h>>8)&255)/255, blue: CGFloat(h&255)/255, alpha: a) }
let outDir = CommandLine.arguments[1]
class Stripes: NSView {
  var base: NSColor = .black; var alt: NSColor = .white
  override func draw(_ r: NSRect) { var x: CGFloat = 0; var i = 0
    while x < bounds.width { (i % 2 == 0 ? base : alt).setFill(); NSRect(x: x, y: 0, width: 40, height: bounds.height).fill(); x += 40; i += 1 } }
}
func label(_ s: String, _ c: NSColor, _ size: CGFloat, _ w: NSFont.Weight, _ f: NSRect) -> NSTextField {
  let t = NSTextField(labelWithString: s); t.textColor = c; t.font = .systemFont(ofSize: size, weight: w); t.frame = f; return t }
let app = NSApplication.shared; app.setActivationPolicy(.regular)
let screenH = NSScreen.main!.frame.height
func topLeft(_ x: CGFloat, _ top: CGFloat, _ w: CGFloat, _ h: CGFloat) -> NSRect { NSRect(x: x, y: screenH - top - h, width: w, height: h) }
let bdRect = topLeft(100, 120, 980, 640)
let backdrop = NSWindow(contentRect: bdRect, styleMask: [.borderless], backing: .buffered, defer: false)
let stripes = Stripes(frame: NSRect(origin: .zero, size: bdRect.size)); backdrop.contentView = stripes
backdrop.isOpaque = true; backdrop.hasShadow = false
let wRect = topLeft(210, 200, 760, 480)
let win = NSWindow(contentRect: wRect, styleMask: [.titled, .fullSizeContentView, .closable], backing: .buffered, defer: false)
win.level = .floating
win.appearance = NSAppearance(named: .darkAqua); win.titlebarAppearsTransparent = true; win.titleVisibility = .hidden
win.isOpaque = false; win.backgroundColor = .clear
let root = NSView(frame: NSRect(origin: .zero, size: wRect.size)); win.contentView = root
let side = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 216, height: 480))
side.material = .sidebar; side.blendingMode = .behindWindow; side.state = .active
root.addSubview(side)
let tint = NSView(frame: side.bounds); tint.wantsLayer = true; side.addSubview(tint)
let main = NSView(frame: NSRect(x: 216, y: 0, width: 544, height: 480)); main.wantsLayer = true; main.layer?.backgroundColor = C(0x1F1B1E).cgColor; root.addSubview(main)
main.addSubview(label("Tuesday, 3 November", C(0xF3ECE4), 20, .bold, NSRect(x: 24, y: 400, width: 400, height: 28)))
main.addSubview(label("Dark P1 surface #1F1B1E", C(0xC7BEC4), 13, .regular, NSRect(x: 24, y: 376, width: 400, height: 20)))
let sel = NSView(frame: NSRect(x: 10, y: 386, width: 196, height: 30)); sel.wantsLayer = true; sel.layer?.cornerRadius = 7; sel.layer?.backgroundColor = C(0x5BC4B8, 0.18).cgColor; side.addSubview(sel)
let icon = NSView(frame: NSRect(x: 20, y: 393, width: 16, height: 16)); icon.wantsLayer = true; icon.layer?.cornerRadius = 8; icon.layer?.borderWidth = 2.5; icon.layer?.borderColor = C(0x5BC4B8).cgColor; side.addSubview(icon)
side.addSubview(label("Now", C(0xF3ECE4), 14, .semibold, NSRect(x: 44, y: 391, width: 150, height: 20)))
var y: CGFloat = 356
for s in ["Inbox", "Calendar", "Search"] { side.addSubview(label(s, C(0xF3ECE4), 14, .regular, NSRect(x: 44, y: y, width: 140, height: 20))); y -= 32 }
let badge = NSView(frame: NSRect(x: 176, y: 357, width: 22, height: 18)); badge.wantsLayer = true; badge.layer?.cornerRadius = 9; badge.layer?.backgroundColor = C(0x5BC4B8).cgColor; side.addSubview(badge)
let bt = label("3", C(0x0C2523), 11, .bold, NSRect(x: 0, y: 1, width: 22, height: 15)); bt.alignment = .center; badge.addSubview(bt)
let focus = NSView(frame: NSRect(x: 7, y: 316, width: 202, height: 34)); focus.wantsLayer = true; focus.layer?.cornerRadius = 9; focus.layer?.borderWidth = 3; focus.layer?.borderColor = C(0x7FD6CB).cgColor; side.addSubview(focus)
side.addSubview(label("Settings ⌘,", C(0xC7BEC4), 12, .regular, NSRect(x: 22, y: 24, width: 170, height: 18)))
let backdrops: [(String, UInt32)] = [("blue", 0x1E2A3A), ("light", 0xD8D4CC), ("red", 0x6A3A2A)]
let tints: [(String, NSColor?)] = [("D1v2", C(0x3B2F2A, 0.30))]
var jobs: [(String, UInt32, String, NSColor?)] = []
for b in backdrops { for t in tints { jobs.append((b.0, b.1, t.0, t.1)) } }
backdrop.orderFront(nil); win.makeKeyAndOrderFront(nil); app.activate(ignoringOtherApps: true)
func run(_ i: Int) {
  if i >= jobs.count { NSApp.terminate(nil); return }
  let j = jobs[i]
  stripes.base = C(j.1); stripes.alt = C(j.1).blended(withFraction: 0.5, of: .white)!; stripes.needsDisplay = true
  tint.layer?.backgroundColor = j.3?.cgColor ?? NSColor.clear.cgColor
  backdrop.orderFront(nil); win.orderFrontRegardless()
  DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
    var r = "0,0,760,480"
    if let info = CGWindowListCopyWindowInfo([.optionIncludingWindow], CGWindowID(win.windowNumber)) as? [[String: Any]], let b = info.first?["kCGWindowBounds"] as? [String: CGFloat] {
      r = "\(Int(b["X"]!)),\(Int(b["Y"]!)),\(Int(b["Width"]!)),\(Int(b["Height"]!))" }
    let p = Process(); p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
    p.arguments = ["-x", "-R", r, "\(outDir)/\(j.0)-\(j.2).png"]
    try? p.run(); p.waitUntilExit()
    run(i + 1)
  }
}
DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { run(0) }
app.run()
