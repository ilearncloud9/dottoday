import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/scheduling/slot_fit.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A caption with an optional trailing control ("TIME ⋯", "DURATION ⋯").
class AddCaption extends StatelessWidget {
  const AddCaption(this.text, {this.trailing, super.key});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(text.toUpperCase(), style: t.styles.caption),
          ),
        ),
        ?trailing,
      ],
    );
  }
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

/// "Lands on **Today** at 5:00 – 6:00 PM · the slot is free".
class LandsOn extends StatelessWidget {
  const LandsOn({
    required this.colour,
    required this.day,
    required this.range,
    required this.fit,
    super.key,
  });

  final TaskColor colour;
  final String day;
  final String range;
  final SlotFit fit;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final suffix = fit.isFree
        ? l10n.addSlotFree
        : l10n.addSlotBusy(fit.overlaps.first.title);
    final full = l10n.alertJoin(l10n.addLandsOn(day, range), suffix);
    final style = t.styles.body.copyWith(color: t.colors.muted);
    return Container(
      padding: const EdgeInsets.all(DotSpace.l),
      decoration: BoxDecoration(
        color: t.colors.surface,
        borderRadius: BorderRadius.circular(DotRadii.card),
        border: Border.all(color: t.colors.outline),
      ),
      child: Row(
        spacing: DotSpace.m,
        children: [
          Container(
            width: DotSize.segment,
            height: DotSpace.xl,
            decoration: BoxDecoration(
              color: t.tasks[colour].color,
              borderRadius: BorderRadius.circular(DotRadii.pill),
            ),
          ),
          Expanded(child: _sentence(t, full, style)),
        ],
      ),
    );
  }

  /// [full] with the day in bold.
  Widget _sentence(DotTheme t, String full, TextStyle style) {
    final at = full.indexOf(day);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          if (at < 0)
            TextSpan(text: full)
          else ...[
            TextSpan(text: full.substring(0, at)),
            TextSpan(
              text: day,
              style: TextStyle(
                color: t.colors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: full.substring(at + day.length)),
          ],
        ],
      ),
    );
  }
}
