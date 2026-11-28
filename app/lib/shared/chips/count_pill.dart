import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "4 results", "2 routines": a count on the accent's tint beside a page
/// title on the Mac and the web (E-R2-30). A live region, so a screen
/// reader hears the new count as it changes.
class CountPill extends StatelessWidget {
  const CountPill(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.colors.tonal,
          borderRadius: BorderRadius.circular(DotRadii.pill),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DotSpace.s + DotSpace.xxs,
            vertical: DotSpace.xxs,
          ),
          child: Text(
            text,
            style: t.styles.rowMeta.copyWith(
              color: t.colors.accentText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
