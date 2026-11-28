import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A strip above every screen (docs/10 §5.4): a glyph, one line of text
/// and up to two text actions. Used by the sync banner (M3f.8); the
/// in-app reminder (M5.3, [bell]) and E-R2-24's strips (the update, the
/// install, the calendar's, ED-497) take the [card] form.
class BannerStrip extends StatelessWidget {
  const BannerStrip({
    required this.text,
    this.glyph,
    this.actions = const [],
    this.emphasis = false,
    this.card = false,
    this.bell = false,
    this.lead,
    super.key,
  });

  /// The card's glyph in a raised circle (the in-app reminder, E-R2-20);
  /// otherwise it stands bare in the accent's ink (E-R2-24's install),
  /// and a card with no [glyph] has none.
  final bool bell;

  /// The in-app reminder's form (E-R2-20, ED-467): a rounded teal-tinted
  /// card 12 from the sides, the glyph in a circle, the actions as pills
  /// (the first filled); on a phone the actions sit under the text.
  final bool card;

  /// The part of [text] set in the title's weight (the reminder's title).
  final String? lead;

  final DotGlyph? glyph;
  final String text;

  /// (label, onPressed), at most two.
  final List<(String, VoidCallback)> actions;

  /// The reminder's title weight instead of meta text.
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    if (card) return _card(context, t);
    return Semantics(
      container: true,
      liveRegion: true,
      child: ColoredBox(
        color: t.colors.card,
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
      if (glyph case final g?)
        DotIcon(g, color: t.colors.secondary, size: DotSize.rowIcon),
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

  Widget _card(BuildContext context, DotTheme t) {
    final c = t.colors;
    // On a phone two actions go under the words; one stays beside them,
    // as E-R2-24 draws the strips (ED-497).
    final compact =
        WidthClass.of(MediaQuery.sizeOf(context).width) == WidthClass.compact &&
        actions.length > 1;
    final g = glyph;
    final mark = g == null
        ? null
        : bell
        ? Container(
            width: DotSize.alertBell,
            height: DotSize.alertBell,
            decoration: BoxDecoration(color: c.card, shape: BoxShape.circle),
            child: Center(
              child: DotIcon(g, color: c.accentText, size: DotSize.rowIcon),
            ),
          )
        : DotIcon(g, color: c.accentText, size: DotSize.rowIcon);
    final line = Text.rich(_spans(t));
    final pills = Wrap(
      spacing: DotSpace.xs,
      runSpacing: DotSpace.xs,
      alignment: WrapAlignment.end,
      children: [
        for (final (i, (label, onPressed)) in actions.indexed)
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              backgroundColor: i == 0 ? c.card : null,
              foregroundColor: c.accentText,
              textStyle: t.styles.alertAction,
              minimumSize: const Size(0, DotSize.alertAction),
              padding: const EdgeInsets.symmetric(horizontal: DotSpace.m),
              shape: const StadiumBorder(),
            ),
            child: Text(label),
          ),
      ],
    );
    final body = compact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DotSpace.xs + DotSpace.xxs,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: DotSpace.m,
                children: [
                  ?mark,
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: bell ? DotSpace.xs : 0),
                      child: line,
                    ),
                  ),
                ],
              ),
              Align(alignment: AlignmentDirectional.centerEnd, child: pills),
            ],
          )
        : Row(
            spacing: DotSpace.m,
            children: [
              ?mark,
              Expanded(child: line),
              pills,
            ],
          );
    return Semantics(
      container: true,
      liveRegion: true,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DotSpace.m,
            DotSpace.xs,
            DotSpace.m,
            DotSpace.xs,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.tonal,
              borderRadius: BorderRadius.circular(DotRadii.alertStrip),
            ),
            child: Padding(
              // The board's 10 · 10 · 10 · 14; 8 under the phone's actions.
              padding: EdgeInsetsDirectional.fromSTEB(
                DotSpace.m + DotSpace.xxs,
                DotSpace.s + DotSpace.xxs,
                DotSpace.s + DotSpace.xxs,
                compact ? DotSpace.s : DotSpace.s + DotSpace.xxs,
              ),
              child: body,
            ),
          ),
        ),
      ),
    );
  }

  /// [text] with [lead] in the title's weight, wherever the language puts it.
  TextSpan _spans(DotTheme t) {
    final at = lead == null ? -1 : text.indexOf(lead!);
    // E-R2-24's strips set their one line in 600 14.5/19 (ED-497).
    final plain = bell
        ? t.styles.alertText
        : t.styles.alertText.copyWith(
            fontSize: 14.5,
            height: 19 / 14.5,
            fontWeight: FontWeight.w600,
            fontVariations: const [FontVariation.weight(600)],
          );
    if (at < 0) return TextSpan(text: text, style: plain);
    final end = at + lead!.length;
    return TextSpan(
      style: plain,
      children: [
        TextSpan(text: text.substring(0, at)),
        TextSpan(text: lead, style: t.styles.alertTitle),
        TextSpan(text: text.substring(end)),
      ],
    );
  }
}
