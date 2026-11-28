import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// One way to catch up in the Running late form: what it does and what it
/// will change; null [enabled] when it can't (nothing to shift, too short).
typedef LateOption = ({String title, String detail, bool enabled});

/// The Running late form's choices (E-R2-26 §1, ED-329): a radio list in a
/// raised card, rows split by a hairline. Picking one only marks it; the
/// form's Done acts (owner, M20.6 part 2).
class LateOptionGroup extends StatelessWidget {
  const LateOptionGroup({
    required this.options,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<LateOption> options;
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    // A Material, so the rows' ink shows on the card.
    return Material(
      color: t.colors.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DotRadii.card),
        side: BorderSide(color: t.colors.hairline),
      ),
      child: RadioGroup<int>(
        groupValue: selected,
        onChanged: (i) {
          if (i != null) onSelect(i);
        },
        child: Column(
          children: [
            for (final (i, o) in options.indexed) ...[
              if (i > 0)
                Divider(height: DotSpace.hairline, color: t.colors.hairline),
              _Row(index: i, option: o),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.index, required this.option});

  final int index;
  final LateOption option;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final (:title, :detail, :enabled) = option;
    final ink = enabled ? t.colors.ink : t.colors.secondary;
    return RadioListTile<int>.adaptive(
      value: index,
      enabled: enabled,
      activeColor: t.colors.accentFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: DotSpace.m),
      title: Text(title, style: t.styles.choiceTitle.copyWith(color: ink)),
      subtitle: Text(detail, style: t.styles.rowMeta),
    );
  }
}
