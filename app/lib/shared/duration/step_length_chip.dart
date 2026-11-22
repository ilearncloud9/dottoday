import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';

/// Lengths a step can be given (11 B2): short ones first — a step is
/// meant to be small (Smallest step asks for the first one at 2 min).
const stepLengthChoices = [2, 5, 10, 15, 20, 30, 45, 60, 90, 120];

/// A step's length as a chip: "10 min", or "+ time" when it has none
/// (E-R2-23; docs/09 M10.3): a small grey pill. A tap picks a length.
class StepLengthChip extends StatelessWidget {
  const StepLengthChip({
    required this.minutes,
    required this.title,
    required this.onChanged,
    super.key,
  });

  final int? minutes;

  /// The step's title, for the screen reader's hint.
  final String title;

  /// The picked length; null for "No time". Null itself: read-only (a
  /// step whose length is its sub-steps' sum).
  final ValueChanged<int?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final m = minutes;
    return Semantics(
      onTapHint: l10n.stepLengthHint(title),
      // A small grey pill (E-R2-23); the hit area stays 44.
      child: TextButton(
        onPressed: switch (onChanged) {
          final change? => () => unawaited(
            pickStepLength(context, minutes: minutes, onChanged: change),
          ),
          null => null,
        },
        style: TextButton.styleFrom(
          backgroundColor: t.colors.tile,
          disabledBackgroundColor: t.colors.tile,
          shape: const StadiumBorder(),
          // Small to look at, 48 to tap (44 pt / 48 dp floors).
          minimumSize: const Size(0, DotSize.smallChipHeight),
          tapTargetSize: MaterialTapTargetSize.padded,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: DotSpace.s + DotSpace.xxs,
          ),
        ),
        child: Text(
          m == null ? l10n.stepLengthAdd : formatDurationShort(l10n, m),
          style: t.styles.smallChip.copyWith(
            color: m == null ? t.colors.muted : t.colors.text,
          ),
        ),
      ),
    );
  }
}

/// Picks a step's length (11 B2, E-R2-23 "How long is this step?"): the
/// lengths as chips, the current one filled, and No time; [onChanged]
/// gets the pick (null for No time), and nothing on dismiss or the same
/// length. The chip's tap and the quiet step row's ⋯ use it.
Future<void> pickStepLength(
  BuildContext context, {
  required int? minutes,
  required ValueChanged<int?> onChanged,
}) async {
  // 0 is "No time": null from the sheet means it was dismissed.
  final picked = await showAppSheet<int>(
    context: context,
    title: context.l10n.stepLengthTitle,
    maxWidth: DotSize.pickDialog,
    builder: (sheet) => _LengthChoices(
      selected: minutes,
      onPick: (m) => Navigator.of(sheet).pop(m),
    ),
  );
  if (picked == null || picked == (minutes ?? 0)) return;
  onChanged(picked == 0 ? null : picked);
}

/// The lengths as chips, then No time (0).
class _LengthChoices extends StatelessWidget {
  const _LengthChoices({required this.selected, required this.onPick});

  final int? selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.m,
      children: [
        Wrap(
          spacing: DotSpace.s,
          runSpacing: DotSpace.s,
          children: [
            for (final m in stepLengthChoices)
              ChoiceChip(
                label: Text(formatDurationShort(l10n, m)),
                selected: m == selected,
                showCheckmark: false,
                onSelected: (_) => onPick(m),
                color: WidgetStateProperty.resolveWith(
                  (s) => s.contains(WidgetState.selected)
                      ? t.colors.accent
                      : t.colors.tile,
                ),
                side: BorderSide.none,
                shape: const StadiumBorder(),
                labelStyle: t.styles.chip.copyWith(
                  color: m == selected ? t.colors.onAccent : t.colors.text,
                ),
              ),
          ],
        ),
        TextButton(
          onPressed: () => onPick(0),
          child: Text(l10n.stepLengthNone),
        ),
      ],
    );
  }
}
