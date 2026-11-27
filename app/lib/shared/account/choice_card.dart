import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// One option of a single choice on a decision screen (CR-160 G1; board
/// `GuestWork`, its sizes on other platforms as B1's, ED-495): a card with
/// a radio mark beside [title] and [children]. The chosen card has an
/// accent outline as well as the filled mark, so the choice never rests on
/// colour alone. Screen readers hear a radio button in a group, checked or
/// not.
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    required this.look,
    required this.title,
    required this.selected,
    required this.onTap,
    this.children = const [],
    super.key,
  });

  final AccountDialogLook look;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  /// Under the title, beside the mark (details, a checkbox).
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    final radio = AccountDecisionSize.radio(look);
    return Semantics(
      container: true,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: ChoiceCardFrame(
        look: look,
        outline: selected ? c.accent : c.outline,
        onTap: onTap,
        mark: ExcludeSemantics(
          child: RadioMark(selected: selected, size: radio),
        ),
        title: title,
        children: children,
      ),
    );
  }
}

/// The card around a choice or a statement (G1, G1b): [mark] beside
/// [title] and [children], 16 in, the board's corners and a 2 [outline].
class ChoiceCardFrame extends StatelessWidget {
  const ChoiceCardFrame({
    required this.look,
    required this.outline,
    required this.mark,
    required this.title,
    required this.children,
    this.onTap,
    super.key,
  });

  final AccountDialogLook look;
  final Color outline;
  final Widget mark;
  final String title;
  final List<Widget> children;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AccountDecisionSize.radius(look)),
      side: BorderSide(color: outline, width: AccountDecisionSize.cardOutline),
    );
    final body = Padding(
      padding: const EdgeInsets.all(AccountDecisionSize.cardPad),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AccountDecisionSize.radioGap(look),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AccountDecisionSize.markTop),
            child: mark,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AccountDecisionSize.cardLines,
              children: [
                Text(
                  title,
                  style: AccountDecisionType.cardTitle(t.styles, look),
                ),
                ...children,
              ],
            ),
          ),
        ],
      ),
    );
    return Material(
      color: t.colors.raised,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? body : InkWell(onTap: onTap, child: body),
    );
  }
}

/// The radio circle: a ring, filled with a dot when [selected].
class RadioMark extends StatelessWidget {
  const RadioMark({
    required this.selected,
    this.size = DotSize.pickerDot,
    super.key,
  });

  final bool selected;

  /// Across (B1 draws 22, 20 or 18 by platform).
  final double size;

  /// The filled dot, in proportion to [size].
  double get _dot => (DotSize.tabDot - DotSpace.xs) * size / DotSize.pickerDot;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    return Container(
      width: size,
      height: size,
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
              width: _dot,
              height: _dot,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.accent,
              ),
            )
          : null,
    );
  }
}

/// A muted detail line inside a [ChoiceCard]: 14/20 (Mac/web 13.5/20).
class ChoiceDetail extends StatelessWidget {
  const ChoiceDetail(this.text, {required this.look, super.key});

  final String text;
  final AccountDialogLook look;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Text(
      text,
      style: AccountDecisionType.row(
        t.styles,
        look,
      ).copyWith(color: t.colors.muted),
    );
  }
}
