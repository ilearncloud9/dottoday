import 'package:dottoday/core/theme/task_palette.dart';
import 'package:flutter/painting.dart';

/// App colour's warm suggestions (ED-161, E-G3-9b "app colour and theme"),
/// in the board's order; the current colour is always shown first.
enum AppColourSuggestion {
  blush(Color(0xFFE9958E)),
  peach(Color(0xFFF29E7C)),
  honey(Color(0xFFE2A72E)),
  sage(Color(0xFF8DBA6A)),
  duskBlue(Color(0xFF6A88A8)),
  pine(Color(0xFF2F7D5C)),
  plum(Color(0xFF934B6E)),
  inkNavy(Color(0xFF2E4A6B));

  const AppColourSuggestion(this.colour);

  final Color colour;
}

/// The built-in accent nearest to [colour], written beside a custom
/// `accent_hex` so an older app shows a close accent and still saves
/// settings (ED-221).
///
/// ```dart
/// nearestAccent(const Color(0xFF2F7D5C)) // DotAccent.teal
/// ```
DotAccent nearestAccent(Color colour) {
  double distance(Color a) {
    final dr = a.r - colour.r;
    final dg = a.g - colour.g;
    final db = a.b - colour.b;
    return dr * dr + dg * dg + db * db;
  }

  return DotAccent.values.reduce(
    (best, a) => distance(a.light) < distance(best.light) ? a : best,
  );
}
