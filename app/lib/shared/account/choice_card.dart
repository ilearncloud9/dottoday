import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// One option of a single choice on a decision screen (CR-160 B1, G1): a
/// card with a radio mark, [title] and [children] under it. The chosen
/// card has an accent outline as well as the filled mark, so the choice
/// never rests on colour alone. Screen readers hear a radio button in a
/// group, checked or not.
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    required this.title,
    required this.selected,
    required this.onTap,
    this.children = const [],
    super.key,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  /// Under the title, indented to it (details, a checkbox).
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DotRadii.cardLarge),
      side: BorderSide(
        color: selected ? c.accent : c.outline,
        width: DotSize.smallDotOutline,
      ),
    );
    return Semantics(
      container: true,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: Material(
        color: c.raised,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.l),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: DotSpace.m,
              children: [
                ExcludeSemantics(child: RadioMark(selected: selected)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: DotSpace.xs,
                    children: [
                      Text(title, style: t.styles.choiceTitle),
                      ...children,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The radio circle: a ring, filled with a dot when [selected].
class RadioMark extends StatelessWidget {
  const RadioMark({required this.selected, super.key});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Container(
      width: DotSize.pickerDot,
      height: DotSize.pickerDot,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? c.accent : c.hairline,
          width: DotSize.smallDotOutline,
        ),
      ),
      child: selected
          ? Container(
              width: DotSize.tabDot - DotSpace.xs,
              height: DotSize.tabDot - DotSpace.xs,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.accent,
              ),
            )
          : null,
    );
  }
}

/// A muted detail line inside a [ChoiceCard] or a card.
class ChoiceDetail extends StatelessWidget {
  const ChoiceDetail(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Text(text, style: t.styles.body.copyWith(color: t.colors.muted));
  }
}
