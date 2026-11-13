import Cocoa
func lin(_ c: Double) -> Double { c <= 0.03928 ? c/12.92 : pow((c+0.055)/1.055, 2.4) }
func L(_ c: (Double,Double,Double)) -> Double { 0.2126*lin(c.0)+0.7152*lin(c.1)+0.0722*lin(c.2) }
func cr(_ a: Double,_ b: Double) -> Double { (max(a,b)+0.05)/(min(a,b)+0.05) }
func hx(_ h: UInt32) -> (Double,Double,Double) { (Double((h>>16)&255)/255, Double((h>>8)&255)/255, Double(h&255)/255) }
for path in CommandLine.arguments.dropFirst() {
  let rep = NSBitmapImageRep(data: NSImage(contentsOfFile: path)!.tiffRepresentation!)!
  let s = Double(rep.pixelsWide)/760
  func px(_ x: Double,_ y: Double) -> (Double,Double,Double) { let c = rep.colorAt(x: Int(x*s), y: Int(y*s))!.usingColorSpace(.sRGB)!; return (Double(c.redComponent),Double(c.greenComponent),Double(c.blueComponent)) }
  func avg(_ x0: Double,_ y0: Double,_ x1: Double,_ y1: Double) -> (Double,Double,Double) { var r=0.0,g=0.0,b=0.0,n=0.0; var x=x0; while x<=x1 { var y=y0; while y<=y1 { let p=px(x,y); r+=p.0; g+=p.1; b+=p.2; n+=1; y+=2 }; x+=2 }; return (r/n,g/n,b/n) }
  let side = avg(20, 220, 200, 400), pill = avg(120, 70, 190, 88)
  let badgeBG = avg(181, 111, 183, 113), ring = px(8.5, 150)
  let teal = hx(0x5BC4B8), focus = hx(0x7FD6CB), ink = hx(0x0C2523), text = hx(0xF3ECE4)
  func f(_ c: (Double,Double,Double)) -> String { "\(Int(c.0*255)),\(Int(c.1*255)),\(Int(c.2*255))" }
  print((path as NSString).lastPathComponent, "sidebar", f(side), "pill", f(pill), String(format: "| label on pill %.2f | icon (teal) on pill %.2f | badge bg %@ vs sidebar %.2f, digit on badge %.2f | focus ring px %@ (design #7FD6CB) vs sidebar %.2f",
    cr(L(text),L(pill)), cr(L(teal),L(pill)), f(badgeBG), cr(L(badgeBG),L(side)), cr(L(ink),L(badgeBG)), f(ring), cr(L(focus),L(side))))
}
