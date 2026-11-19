/// Sizes of the colour and icon pickers (E-Phones "Colour and icon,
/// compact", "All icons, pinned palette"; E-Phones-3 "All colours · half
/// sheet"; ED-086, ED-161).
abstract final class DotLook {
  /// Sheet top corners.
  static const double sheetRadius = 34;

  /// The header row: title, ⋯ and Done.
  static const double header = 50;

  /// The glass ⋯ and Done buttons.
  static const double headerButton = 40;

  /// A colour in the swipeable palette (also its touch target).
  static const double paletteDot = 44;

  /// The palette row's corners and its gap between colours.
  static const double paletteRadius = 30;
  static const double paletteGap = 14;

  /// The selected colour's ring: a gap in the ground, then the colour.
  static const double ringGap = 3;
  static const double ringWidth = 2.5;

  /// The current icon, and the suggested, recent and library icons.
  static const double current = 64;
  static const double icon = 56;

  /// The icon drawn inside [icon] and [current].
  static const double glyph = 24;

  /// All icons' header dot.
  static const double headerDot = 36;

  /// The All icons button and the search field.
  static const double allIcons = 50;
  static const double search = 40;

  /// A category chip in All icons.
  static const double chip = 32;

  /// Library columns on a phone.
  static const int columns = 5;

  /// All colours' small swatches (in a 44 pt target), six to a row.
  static const double swatch = 30;
  static const int swatchColumns = 6;

  /// The ahead / done preview dots and the in-progress ring.
  static const double previewDot = 34;
  static const double previewArc = 36;
  static const double previewRing = 4;
  static const double previewGlyph = 18;

  /// Colour and Shade: track height and thumb.
  static const double track = 28;
  static const double thumb = 24;
  static const double thumbRing = 3;

  /// Colour and Shade's label column.
  static const double sliderLabel = 44;

  /// How far All colours sits from the top: the task above stays in view
  /// (ED-156: iPhone 330 of 844).
  static const double coloursShare = 0.61;

  /// The compact sheet's share of the screen at most.
  static const double compactShare = 0.52;

  /// All icons leaves this much of the screen above it.
  static const double iconsTop = 56;

  /// How many recently used icons a device keeps (owner, 4c).
  static const int recentIcons = 8;

  /// A custom colour under this contrast with its surface gets a neutral
  /// outline (CR-155).
  static const double outlineBelow = 3;
  static const double outline = 1.5;

  /// Stops in the Colour slider's rainbow (every 30°).
  static const int hueStops = 13;
}
