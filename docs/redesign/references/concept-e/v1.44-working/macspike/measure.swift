import Cocoa
func lin(_ c: Double) -> Double { c <= 0.03928 ? c/12.92 : pow((c+0.055)/1.055, 2.4) }
func L(_ r: Double,_ g: Double,_ b: Double) -> Double { 0.2126*lin(r)+0.7152*lin(g)+0.0722*lin(b) }
func cr(_ a: Double,_ b: Double) -> Double { let x = max(a,b), y = min(a,b); return (x+0.05)/(y+0.05) }
func hexL(_ h: UInt32) -> Double { L(Double((h>>16)&255)/255, Double((h>>8)&255)/255, Double(h&255)/255) }
let text = hexL(0xF3ECE4), text2 = hexL(0xC7BEC4), teal = hexL(0x5BC4B8)
for path in CommandLine.arguments.dropFirst() {
  guard let img = NSImage(contentsOfFile: path), let tiff = img.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff) else { print("fail", path); continue }
  let W = rep.pixelsWide, H = rep.pixelsHigh, s = Double(W) / 760.0
  // sidebar empty area: x 12..204 pt, y 215..420 pt (top-left)
  var cols: [(Double,Double,Double)] = []
  var sr = 0.0, sg = 0.0, sb = 0.0, n = 0.0, maxL = 0.0, minL = 1.0
  for xpt in stride(from: 12, through: 204, by: 4) {
    var cr_ = 0.0, cg = 0.0, cb = 0.0, cn = 0.0
    for ypt in stride(from: 215, through: 420, by: 5) {
      let c = rep.colorAt(x: Int(Double(xpt)*s), y: Int(Double(ypt)*s))!.usingColorSpace(.sRGB)!
      cr_ += Double(c.redComponent); cg += Double(c.greenComponent); cb += Double(c.blueComponent); cn += 1 }
    let a = (cr_/cn, cg/cn, cb/cn); cols.append(a); sr += a.0; sg += a.1; sb += a.2; n += 1
    let l = L(a.0,a.1,a.2); maxL = max(maxL,l); minL = min(minL,l) }
  let avg = (sr/n, sg/n, sb/n)
  let spread = (cols.map{$0.0}.max()! - cols.map{$0.0}.min()!, cols.map{$0.1}.max()! - cols.map{$0.1}.min()!, cols.map{$0.2}.max()! - cols.map{$0.2}.min()!)
  let name = (path as NSString).lastPathComponent
  print(String(format: "%@  avg %d,%d,%d  spread R/G/B %.1f/%.1f/%.1f  text %.2f (worst %.2f)  text2 %.2f (worst %.2f)  teal %.2f (worst %.2f)", name, Int(avg.0*255), Int(avg.1*255), Int(avg.2*255), spread.0*255, spread.1*255, spread.2*255, cr(text, L(avg.0,avg.1,avg.2)), cr(text, maxL), cr(text2, L(avg.0,avg.1,avg.2)), cr(text2, maxL), cr(teal, L(avg.0,avg.1,avg.2)), cr(teal, maxL)))
}
