import AppKit
let img = NSBitmapImageRep(data: try! Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1])))!
// menu panel sits at x 170-910, y 740-2290 when open: sample the "Plan" header area for non-ground pixels
var dark = 0
for y in stride(from: 1300, to: 1550, by: 2) { for x in stride(from: 350, to: 700, by: 2) { let c = img.colorAt(x: x, y: y)!; if c.brightnessComponent < 0.4 { dark += 1 } } }
print(dark > 50 ? "MENU OPEN" : "MENU CLOSED", dark)
