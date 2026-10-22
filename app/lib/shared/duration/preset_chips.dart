import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/thread_pieces.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// "15m", "1h", "1h 30m": a preset as its chip reads.
String presetLabel(AppLocalizations l10n, int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return l10n.durationPresetMinutes(m);
  if (m == 0) return l10n.durationPresetHours(h);
  return l10n.durationPresetHoursMinutes(h, m);
}

/// "PRESETS · Reset" and the editable chips (`A-ios-add-duration`): tap to
/// use, × to remove, the dashed "+ preset" keeps the current length.
class PresetChips extends StatelessWidget {
  const PresetChips({
    required this.presets,
    required this.value,
    required this.onPick,
    required this.onRemove,
    required this.onAdd,
    required this.onReset,
    super.key,
  });

  final List<int> presets;
  final int value;
  final ValueChanged<int> onPick;
  final ValueChanged<int> onRemove;
  final VoidCallback onAdd;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.durationPresets.toUpperCase(),
                  style: t.styles.caption,
                ),
              ),
            ),
            TextButton(onPressed: onReset, child: Text(l10n.durationReset)),
          ],
        ),
        Wrap(
          spacing: DotSpace.s,
          runSpacing: DotSpace.s,
          children: [
            for (final m in presets) _chip(context, m),
            if (!presets.contains(value)) _AddPreset(onTap: onAdd),
          ],
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, int minutes) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final selected = minutes == value;
    final ink = selected ? t.colors.onAccent : t.colors.text;
    return InputChip(
      label: Text(
        presetLabel(l10n, minutes),
        style: t.styles.button.copyWith(color: ink),
      ),
      tooltip: formatDurationShort(l10n, minutes),
      selected: selected,
      showCheckmark: false,
      selectedColor: t.colors.accentFill,
      backgroundColor: t.colors.raised,
      side: selected ? BorderSide.none : BorderSide(color: t.colors.outline),
      shape: dotChipShape(context),
      onSelected: (_) => onPick(minutes),
      deleteIcon: DotIcon(
        DotGlyphs.close,
        color: ink,
        size: DotSize.rowIcon - DotSpace.xs,
      ),
      deleteButtonTooltipMessage: l10n.durationRemovePreset(
        formatDurationShort(l10n, minutes),
      ),
      onDeleted: presets.length > 1 ? () => onRemove(minutes) : null,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}

/// The dashed "+ preset" chip.
class _AddPreset extends StatelessWidget {
  const _AddPreset({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: l10n.durationAddPresetLabel,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: CustomPaint(
          painter: DashedPillPainter(color: t.colors.muted),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: DotTouch.android),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DotSpace.l),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: DotSpace.xs,
                children: [
                  DotIcon(
                    DotGlyphs.add,
                    color: t.colors.muted,
                    size: DotSize.rowIcon,
                  ),
                  Text(
                    l10n.durationAddPreset,
                    style: t.styles.button.copyWith(color: t.colors.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
