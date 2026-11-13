import AppKit
let names = CommandLine.arguments.dropFirst()
for n in names {
  print(NSImage(systemSymbolName: n, accessibilityDescription: nil) != nil ? "OK  \(n)" : "MISSING  \(n)")
}
