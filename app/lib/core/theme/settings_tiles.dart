import 'package:dottoday/core/theme/dot_colors.dart';
import 'package:dottoday/core/theme/task_palette.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A Settings icon's solid tile and glyph, as the boards draw them
/// (ED-332, ED-498): one pair per colour family, in light and dark.
typedef SettingsTile = ({Color tile, Color glyph});

/// The boards' tile pairs. A row names its colour as before (a task
/// colour's ink, the accent's ink or secondary); [of] turns it into the
/// drawn pair, so every setting reads the same wherever it appears.
abstract final class SettingsTiles {
  // Rose and mint have no palette role yet: E-R2-11's rose (#F6E2EA /
  // #9C3D63, dark #523342 / #F2A7C1) and E-R2-21's mint (#E3F1E7 /
  // #1D6436). No dark board draws mint; its dark pair is built as the
  // others are, the hue at 25 % over the dark page with a lifted glyph.
  static const _roseLight = (tile: Color(0xFFF6E2EA), glyph: Color(0xFF9C3D63));
  static const _roseDark = (tile: Color(0xFF523342), glyph: Color(0xFFF2A7C1));
  static const _mintLight = (tile: Color(0xFFE3F1E7), glyph: Color(0xFF1D6436));
  static const _mintDark = (tile: Color(0xFF24382B), glyph: Color(0xFF8ED3A5));

  /// The drawn pair for a row whose colour is [ink]:
  /// - the accent's ink and the teal task colour: the accent's tint and
  ///   ink (the boards draw one teal);
  /// - amber, violet, indigo, rose, mint: their board pairs;
  /// - secondary and slate: the neutral pair (the chip colour, ink 2);
  /// - any other colour no board draws (sky, coral): its own wash, as
  ///   before.
  static SettingsTile of(DotColors c, TaskPalette tasks, Color ink) {
    final dark = c.brightness == Brightness.dark;
    if (ink == c.accentText || ink == tasks[TaskColor.teal].ink) {
      return (tile: c.tonal, glyph: c.accentText);
    }
    if (ink == tasks[TaskColor.amber].ink) {
      return (tile: c.wakeCap, glyph: c.wakeIcon);
    }
    if (ink == tasks[TaskColor.violet].ink) {
      return (tile: c.windCap, glyph: c.windIcon);
    }
    if (ink == tasks[TaskColor.indigo].ink) {
      return (tile: c.orbTrack, glyph: c.windIcon);
    }
    if (ink == tasks[TaskColor.rose].ink) return dark ? _roseDark : _roseLight;
    if (ink == tasks[TaskColor.mint].ink) return dark ? _mintDark : _mintLight;
    if (ink == c.secondary || ink == tasks[TaskColor.slate].ink) {
      return (tile: c.chip, glyph: c.ink2);
    }
    return (
      tile: ink.withValues(
        alpha: dark ? TaskAlpha.tintDark : TaskAlpha.tintLight,
      ),
      glyph: ink,
    );
  }
}
