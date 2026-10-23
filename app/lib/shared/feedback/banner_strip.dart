import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A strip above every screen (docs/10 §5.4): a glyph, one line of text
/// and up to two text actions. Used by the sync banner (M3f.8) and the
/// in-app reminder (M5.3).
class BannerStrip extends StatelessWidget {
  const BannerStrip({
    required this.glyph,
    required this.text,
    this.actions = const [],
    this.emphasis = false,
    super.key,
  });

  final DotGlyph glyph;
  final String text;

  /// (label, onPressed), at most two.
  final List<(String, VoidCallback)> actions;

  /// The reminder's title weight instead of meta text.
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      child: ColoredBox(
        color: t.colors.raised,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              DotSpace.page,
              DotSpace.xs,
              DotSpace.s,
              DotSpace.xs,
            ),
            // The window's width class, like every other layout choice.
            child: _layout(t, MediaQuery.sizeOf(context).width),
          ),
        ),
      ),
    );
  }

  /// One row; on a phone two actions go under the text, which would
  /// otherwise wrap into a narrow column beside them (M5.9).
  Widget _layout(DotTheme t, double width) {
    final glyphAndText = [
      DotIcon(glyph, color: t.colors.muted, size: DotSize.rowIcon),
      Expanded(
        child: Text(
          text,
          style: emphasis ? t.styles.rowTitle : t.styles.rowMeta,
        ),
      ),
    ];
    final buttons = [
      for (final (label, onPressed) in actions)
        TextButton(onPressed: onPressed, child: Text(label)),
    ];
    if (actions.length < 2 || WidthClass.of(width) != WidthClass.compact) {
      return Row(spacing: DotSpace.s, children: [...glyphAndText, ...buttons]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: DotSpace.xs),
          child: Row(spacing: DotSpace.s, children: glyphAndText),
        ),
        Wrap(alignment: WrapAlignment.end, children: buttons),
      ],
    );
  }
}
