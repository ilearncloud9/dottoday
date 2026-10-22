import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// "45 min", "1 h", "1 h 30 min" (docs/03 §3.1 shows end time separately).
String formatDuration(AppLocalizations l10n, int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return l10n.durationMinutes(m);
  if (m == 0) return l10n.durationHours(h);
  return l10n.durationHoursMinutes(h, m);
}

/// Concept A's compact form: "45 min", "1 h", "5 h 45" (`Main`, docs/10 §7.5).
String formatDurationShort(AppLocalizations l10n, int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return l10n.durationMinutes(m);
  if (m == 0) return l10n.durationHours(h);
  return l10n.durationHoursMinutesShort(h, m);
}

/// Text scale from which the duration chips wrap instead of sharing one
/// row (§5.4: nothing truncates at 200 %).
const double _chipRowMaxScale = 1.3;

/// The duration chips "15 30 45 1h 1.5h 2h" (`A-ios-add-when`): one row of
/// equal chips, pills on iPhone and 8 px corners elsewhere (§4); they wrap
/// at large text.
class DurationRow extends StatelessWidget {
  const DurationRow({
    required this.presets,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<int> presets;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final hours = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 0,
    )..maximumFractionDigits = 2;
    String label(int m) => m < 60
        ? l10n.durationChipMinutes(m)
        : l10n.durationChipHours(hours.format(m / 60));
    final chips = [
      for (final m in presets)
        DurationChip(
          label: label(m),
          semantics: formatDurationShort(l10n, m),
          selected: m == value,
          onTap: () => onChanged(m),
        ),
    ];
    final scale = MediaQuery.textScalerOf(context).scale(1);
    if (scale > _chipRowMaxScale) {
      return Wrap(spacing: DotSpace.s, runSpacing: DotSpace.s, children: chips);
    }
    return Row(
      spacing: DotSpace.s,
      children: [for (final c in chips) Expanded(child: c)],
    );
  }
}

/// One duration choice: outlined, or filled with the accent when picked.
class DurationChip extends StatelessWidget {
  const DurationChip({
    required this.label,
    required this.semantics,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;

  /// The full length read out ("1 h 30").
  final String semantics;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final shape = dotChipShape(context).copyWith(
      side: selected ? BorderSide.none : BorderSide(color: t.colors.outline),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: semantics,
      excludeSemantics: true,
      child: Material(
        color: selected ? t.colors.accentFill : t.colors.raised,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: DotTouch.android,
              minWidth: DotTouch.android,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
                child: Text(
                  label,
                  style: t.styles.button.copyWith(
                    color: selected ? t.colors.onAccent : t.colors.text,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
