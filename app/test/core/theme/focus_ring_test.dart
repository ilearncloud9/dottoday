import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// A visible focus ring (docs/09 M3e.6, R-12): buttons get a 2 px ring in
// the text colour while focused, in both themes; ink gets an accent wash.
void main() {
  for (final (name, theme) in [
    ('light', DotTheme.light()),
    ('dark', DotTheme.dark()),
  ]) {
    test('$name: focused buttons are ringed, resting ones are not', () {
      final text = theme.extension<DotTheme>()!.colors.text;
      for (final style in [
        theme.filledButtonTheme.style!,
        theme.outlinedButtonTheme.style!,
        theme.iconButtonTheme.style!,
      ]) {
        final focused = style.side!.resolve({WidgetState.focused})!;
        expect(focused.color, text);
        expect(focused.width, 2);
        expect(style.side!.resolve({})?.color, isNot(text));
      }
      expect(theme.focusColor.a, greaterThan(.2));
    });
  }
}
