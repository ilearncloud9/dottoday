import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

part 'block_palette.gen.dart';

/// One block colour in one mode (docs/03-ux-spec.md §1).
@immutable
final class BlockSwatch {
  const BlockSwatch({required this.base, required this.strong});

  /// Hue of the block fill; drawn at [BlockPalette.fillAlpha], never opaque.
  final Color base;

  /// Text and icons on the block; ≥ 3:1 against `surface` (tested).
  final Color strong;

  BlockSwatch lerp(BlockSwatch other, double t) => BlockSwatch(
    base: Color.lerp(base, other.base, t)!,
    strong: Color.lerp(strong, other.strong, t)!,
  );
}

/// The 12 user-selectable block colours for one brightness.
///
/// Values come from `assets/design/palette.json` via
/// `tool/gen_block_palette.dart`; edit the JSON, never the generated file.
///
/// ```dart
/// final blocks = AppTheme.of(context).blocks;
/// Container(color: blocks.fill(BlockColor.teal, colors.surface));
/// Text(title, style: TextStyle(color: blocks[BlockColor.teal].strong));
/// ```
@immutable
final class BlockPalette {
  const BlockPalette._(this._swatches, this.fillAlpha);

  static const light = BlockPalette._(_lightSwatches, _lightFillAlpha);
  static const dark = BlockPalette._(_darkSwatches, _darkFillAlpha);

  /// Indexed by [BlockColor.index]; the generator emits both in JSON order.
  final List<BlockSwatch> _swatches;

  /// Opacity of [BlockSwatch.base] when filling a block (18 % light, 28 % dark).
  final double fillAlpha;

  BlockSwatch operator [](BlockColor color) => _swatches[color.index];

  /// Opaque block fill: [color]'s base at [fillAlpha] composited on
  /// [surface]. Contrast checks must use this, not the raw base.
  Color fill(BlockColor color, Color surface) =>
      Color.alphaBlend(this[color].base.withValues(alpha: fillAlpha), surface);

  BlockPalette lerp(BlockPalette other, double t) => BlockPalette._([
    for (final c in BlockColor.values) this[c].lerp(other[c], t),
  ], fillAlpha + (other.fillAlpha - fillAlpha) * t);
}
