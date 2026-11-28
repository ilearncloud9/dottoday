import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// An error at a field (E-G4-7-States D): a warning glyph and the words
/// in 600 13 ink, kept under the input and announced when it appears. For
/// `InputDecoration.error`; the field's border turns ink from the theme.
class FieldError extends StatelessWidget {
  const FieldError(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      liveRegion: true,
      child: Row(
        spacing: DotSpace.xs + DotSpace.xxs,
        children: [
          DotIcon(
            DotGlyphs.warning,
            color: t.colors.ink,
            size: DotSize.fieldErrorGlyph,
          ),
          Flexible(child: Text(message, style: t.styles.fieldError)),
        ],
      ),
    );
  }
}
