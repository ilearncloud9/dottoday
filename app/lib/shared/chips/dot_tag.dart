import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// What a [DotTag] says by its colour, never by colour alone: the words
/// carry the meaning.
enum DotTagTone {
  /// The accent's tonal pair: "new", "simple rules", "on-device".
  accent,

  /// The quiet control grey: "no room · to the Inbox".
  neutral,
}

/// A small fully round label beside a title or under a row (E-Phones-2
/// proposal: 700 12 in a 20 or 24 tall pill). Not a control: it has no
/// hit area and reads as part of its row.
class DotTag extends StatelessWidget {
  const DotTag(
    this.label, {
    this.tone = DotTagTone.accent,
    this.large = false,
    super.key,
  });

  final String label;
  final DotTagTone tone;

  /// 24 tall beside a sheet title; 20 under a row.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final (fill, ink) = switch (tone) {
      DotTagTone.accent => (c.accentTint, c.accentInk),
      DotTagTone.neutral => (c.control, c.ink2),
    };
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: large ? DotSize.tagLarge : DotSize.tag,
      ),
      child: DecoratedBox(
        decoration: ShapeDecoration(color: fill, shape: const StadiumBorder()),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: large ? DotSpace.s + DotSpace.xxs : DotSpace.s,
          ),
          child: Align(
            widthFactor: 1,
            heightFactor: 1,
            child: Text(label, style: t.styles.tag.copyWith(color: ink)),
          ),
        ),
      ),
    );
  }
}
