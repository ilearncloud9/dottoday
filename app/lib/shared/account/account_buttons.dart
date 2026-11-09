import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// The tonal pill of the CR-160 boards ("Export my data first", Android's
/// "Stay signed in"): the accent's tint as the fill, its ink as the text.
/// Same shape, size and focus ring as the theme's other pills.
ButtonStyle tonalPillStyle(BuildContext context) {
  final c = DotTheme.of(context).colors;
  return FilledButton.styleFrom(
    backgroundColor: Color.alphaBlend(c.accentTint, c.raised),
    foregroundColor: c.accentInk,
  );
}

/// A round tonal badge holding [glyph] (A2 on iPhone, the web's removal
/// retry): 44 pt, the accent's tint behind its ink.
class TonalBadge extends StatelessWidget {
  const TonalBadge(this.glyph, {super.key});

  final DotGlyph glyph;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        width: DotTouch.min,
        height: DotTouch.min,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.alphaBlend(c.accentTint, c.raised),
        ),
        child: DotIcon(glyph, color: c.accentInk),
      ),
    );
  }
}

/// A line that says how an action went, read out when it changes.
class StatusLine extends StatelessWidget {
  const StatusLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(liveRegion: true, child: Text(text, style: t.styles.body));
  }
}
