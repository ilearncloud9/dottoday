import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:flutter/material.dart';

/// Lengths a step can be given (11 B2): short ones first — a step is
/// meant to be small (Smallest step asks for the first one at 2 min).
const stepLengthChoices = [2, 5, 10, 15, 20, 30, 45, 60, 90, 120];

/// A step's length as a chip: "10 min", or "+ time" when it has none
/// (`B-ios-break-it-down`; docs/09 M10.3). Pill on iPhone, 8 px corners
/// elsewhere (docs/10 §4). A tap picks a length.
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

  /// The picked length; null for "No time".
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final m = minutes;
    return Semantics(
      onTapHint: l10n.stepLengthHint(title),
      child: OutlinedButton(
        onPressed: () => unawaited(_pick(context)),
        style: OutlinedButton.styleFrom(
          shape: dotChipShape(context),
          side: BorderSide(color: t.colors.outline),
          foregroundColor: m == null ? t.colors.muted : t.colors.text,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: DotSpace.m,
          ),
        ),
        child: Text(
          m == null ? l10n.stepLengthAdd : formatDurationShort(l10n, m),
          style: t.styles.rowMeta.copyWith(
            color: m == null ? t.colors.muted : t.colors.text,
          ),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final l10n = context.l10n;
    // 0 is "No time": null from the sheet means it was dismissed.
    final picked = await showChoiceSheet<int>(
      context,
      title: l10n.stepLengthTitle,
      selected: minutes ?? 0,
      options: [
        (value: 0, label: l10n.stepLengthNone, detail: null),
        for (final m in stepLengthChoices)
          (value: m, label: formatDuration(l10n, m), detail: null),
      ],
    );
    if (picked == null || picked == (minutes ?? 0)) return;
    onChanged(picked == 0 ? null : picked);
  }
}
