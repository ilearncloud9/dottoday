import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/layout/layout_providers.dart';
import 'package:dottoday/domain/layout/feature_id.dart';
import 'package:dottoday/domain/scheduling/rebalance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rebalance's three rules (E-R2-35): Shift followers, Allow shrinking
/// optional, Push past Wind Down, as filter chips: on is tinted with its
/// check, off is outlined. Each change hands the new rules up so the
/// plan is made again (dropped lines come back: it is a new plan).
/// Minimal has no rules (docs/14 §3 C1 Simplified).
class RebalanceRules extends ConsumerStatefulWidget {
  const RebalanceRules({required this.onChanged, super.key});

  final ValueChanged<RebalanceOptions> onChanged;

  @override
  ConsumerState<RebalanceRules> createState() => _RebalanceRulesState();
}

/// A leaf: only the switches' state.
class _RebalanceRulesState extends ConsumerState<RebalanceRules> {
  var _options = const RebalanceOptions();

  void _set(RebalanceOptions next) {
    setState(() => _options = next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    if (watchSimplified(ref, FeatureId.rebalance)) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final o = _options;
    return Wrap(
      spacing: DotSpace.s,
      runSpacing: DotSpace.s,
      children: [
        _Rule(
          label: l10n.rebalanceShiftFollowers,
          on: o.shiftFollowers,
          onChanged: (v) => _set(o.copyWith(shiftFollowers: v)),
        ),
        _Rule(
          label: l10n.rebalanceAllowShrink,
          on: o.allowShrink,
          onChanged: (v) => _set(o.copyWith(allowShrink: v)),
        ),
        _Rule(
          label: l10n.rebalancePastWindDown,
          on: o.pastWindDown,
          onChanged: (v) => _set(o.copyWith(pastWindDown: v)),
          glyph: DotGlyphs.moon,
        ),
      ],
    );
  }
}

/// One rule: Material's filter chip, tinted when on (E-R2-35; Android's
/// own filter chips, ED-340), the [glyph] leading while off.
class _Rule extends StatelessWidget {
  const _Rule({
    required this.label,
    required this.on,
    required this.onChanged,
    this.glyph,
  });

  final String label;
  final bool on;
  final ValueChanged<bool> onChanged;
  final DotGlyph? glyph;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return FilterChip(
      label: Text(label),
      selected: on,
      onSelected: onChanged,
      shape: const StadiumBorder(),
      side: BorderSide(color: on ? c.tonal : c.hairlineStrong),
      // The board's compact chips: two rules fit a phone's line.
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: DotSpace.xs),
      labelPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: DotSpace.xxs,
      ),
      color: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.tonal : c.card,
      ),
      labelStyle: t.styles.smallChip.copyWith(color: on ? c.accentText : c.ink),
      checkmarkColor: c.accentText,
      showCheckmark: true,
      iconTheme: const IconThemeData(size: DotSize.rowIcon),
      avatar: on || glyph == null
          ? null
          : DotIcon(glyph!, color: c.ink, size: DotSize.rowIcon),
    );
  }
}
