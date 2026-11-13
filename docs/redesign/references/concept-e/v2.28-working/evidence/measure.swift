import AppKit
// args: png; prints per tab label: background (mode), text (darkest 4 % mean), contrast
func lin(_ c: Double) -> Double { let x = c / 255; return x <= 0.04045 ? x / 12.92 : pow((x + 0.055) / 1.055, 2.4) }
func L(_ r: Double, _ g: Double, _ b: Double) -> Double { 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b) }
let img = NSBitmapImageRep(data: try! Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1])))!
let regions: [(String, Int, Int)] = [("Today", 173, 265), ("Inbox", 432, 514), ("Calendar", 662, 795), ("Search", 934, 1038)]
var line = ""
for (name, x0, x1) in regions {
  var px: [(Double, Double, Double, Double)] = []
  var counts: [String: (Int, Double, Double, Double)] = [:]
  for y in 2488...2532 { for x in x0...x1 {
    let c = img.colorAt(x: x, y: y)!.usingColorSpace(.sRGB)!
    let r = Double(c.redComponent) * 255, g = Double(c.greenComponent) * 255, b = Double(c.blueComponent) * 255
    px.append((L(r, g, b), r, g, b))
    let k = "\(Int(r / 4)),\(Int(g / 4)),\(Int(b / 4))"; let e = counts[k] ?? (0, 0, 0, 0); counts[k] = (e.0 + 1, r, g, b)
  } }
  let bg = counts.values.max { $0.0 < $1.0 }!
  let lb = L(bg.1, bg.2, bg.3)
  let sorted = px.sorted { abs($0.0 - lb) > abs($1.0 - lb) }; let n = max(1, sorted.count * 4 / 100)
  let t = sorted.prefix(n); let tr = t.map { $0.1 }.reduce(0, +) / Double(n), tg = t.map { $0.2 }.reduce(0, +) / Double(n), tb = t.map { $0.3 }.reduce(0, +) / Double(n)
  let lt = L(tr, tg, tb); let cr = (max(lt, lb) + 0.05) / (min(lt, lb) + 0.05)
  line += String(format: "%@ text(%d,%d,%d) on bg(%d,%d,%d) %.2f | ", name, Int(tr), Int(tg), Int(tb), Int(bg.1), Int(bg.2), Int(bg.3), cr)
}
print(line)
