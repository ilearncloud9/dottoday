/// The task icons as SF Symbols for the Live Activity and widgets (docs/09
/// M9.3). The app draws its own glyphs (lib/core/theme/task_icons.dart);
/// outside Flutter the nearest system symbol stands in, one per key.
enum TaskSymbols {
  static let byKey: [String: String] = [
    "code": "chevron.left.forwardslash.chevron.right", "run": "figure.run",
    "mail": "envelope", "call": "phone", "meal": "fork.knife", "book": "book",
    "list": "list.bullet", "language": "character.bubble", "heart": "heart",
    "travel": "airplane", "cart": "cart", "home": "house", "tv": "tv", "bag": "bag",
    "music": "music.note", "meds": "pills", "water": "drop", "pet": "pawprint",
    "gym": "dumbbell", "car": "car", "money": "banknote", "gift": "gift",
    "camera": "camera", "star": "star", "people": "person.2", "document": "doc",
  ]

  /// The symbol for [key], or nil for `circle` and unknown keys (a plain dot).
  static func symbol(_ key: String) -> String? { byKey[key] }
}
