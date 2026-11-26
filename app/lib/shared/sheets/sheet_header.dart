import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// A sheet's title row (E-Phones-2): the title, an optional [tag] beside
/// it, an optional [subtitle] under it, and Close; with [done], "Done" in
/// the accent instead, as E-G4-7 B4 draws the Sync sheet (ED-481).
///
/// iPhone: 800 24 Manrope and a 32 pt grey circle with the cross, in a
/// 44 pt hit area. Android: 400 22 in the system face and a plain cross in
/// a 48 dp hit area (rules §6.4).
class SheetHeader extends StatelessWidget {
  const SheetHeader({
    required this.title,
    required this.onClose,
    this.subtitle,
    this.tag,
    this.done = false,
    super.key,
  });

  /// "Done" in place of the cross.
  final bool done;

  final String title;
  final String? subtitle;
  final Widget? tag;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final ios = DotIdiom.of(context) == DotIdiom.cupertino;
    final subtitle = this.subtitle;
    return Row(
      spacing: DotSpace.s + DotSpace.xxs,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A Wrap, so the tag moves under the title rather than
              // overflowing at large text (docs/10 §5.4).
              Wrap(
                spacing: DotSpace.s,
                runSpacing: DotSpace.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: ios
                          ? t.styles.sheetTitle
                          : t.styles.sheetTitleAndroid,
                    ),
                  ),
                  ?tag,
                ],
              ),
              if (subtitle != null)
                Text(subtitle, style: t.styles.sheetSubtitle),
            ],
          ),
        ),
        if (done)
          TextButton(
            onPressed: onClose,
            style: TextButton.styleFrom(
              minimumSize: const Size(DotTouch.min, DotTouch.min),
            ),
            child: Text(context.l10n.sheetDone),
          )
        else
          SheetCloseButton(onPressed: onClose),
      ],
    );
  }
}

/// Close for a sheet: a 32 pt grey circle on iPhone, a plain cross on
/// Android; 44 / 48 hit area either way.
class SheetCloseButton extends StatelessWidget {
  const SheetCloseButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final ios = DotIdiom.of(context) == DotIdiom.cupertino;
    return IconButton(
      onPressed: onPressed,
      tooltip: context.l10n.sheetClose,
      constraints: BoxConstraints.tight(
        Size.square(ios ? DotTouch.min : DotTouch.android),
      ),
      padding: EdgeInsets.zero,
      icon: ios
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: c.control,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: DotSize.sheetClose,
                child: Center(
                  child: DotIcon(
                    DotGlyphs.close,
                    color: c.ink2,
                    size: DotSize.sheetCloseGlyph,
                  ),
                ),
              ),
            )
          : DotIcon(DotGlyphs.close, color: c.ink2),
    );
  }
}
