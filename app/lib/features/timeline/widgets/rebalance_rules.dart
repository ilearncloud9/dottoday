import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/scheduling/rebalance.dart';
import 'package:flutter/material.dart';

/// Rebalance's three rule chips (`B-ios-rebalance`): Shift followers,
/// Allow shrinking optional, Push past Wind Down. Each change hands the new
/// rules up so the proposal is worked out again (dropped lines come back:
/// it is a new plan).
class RebalanceRules extends StatefulWidget {
  const RebalanceRules({required this.onChanged, super.key});

  final ValueChanged<RebalanceOptions> onChanged;

  @override
  State<RebalanceRules> createState() => _RebalanceRulesState();
}

/// A leaf: only the switches' state.
class _RebalanceRulesState extends State<RebalanceRules> {
  var _options = const RebalanceOptions();

  void _set(RebalanceOptions next) {
    setState(() => _options = next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final o = _options;
    Widget chip(String label, bool on, ValueChanged<bool> set, [DotGlyph? g]) =>
        FilterChip(
          label: Text(label),
          selected: on,
          shape: dotChipShape(context),
          avatar: on || g == null
              ? null
              : DotIcon(g, color: t.colors.muted, size: DotSize.rowIcon),
          onSelected: set,
        );
    return Wrap(
      spacing: DotSpace.s,
      runSpacing: DotSpace.s,
      children: [
        chip(
          l10n.rebalanceShiftFollowers,
          o.shiftFollowers,
          (v) => _set(o.copyWith(shiftFollowers: v)),
        ),
        chip(
          l10n.rebalanceAllowShrink,
          o.allowShrink,
          (v) => _set(o.copyWith(allowShrink: v)),
        ),
        chip(
          l10n.rebalancePastBedtime,
          o.pastBedtime,
          (v) => _set(o.copyWith(pastBedtime: v)),
          DotGlyphs.moon,
        ),
      ],
    );
  }
}
