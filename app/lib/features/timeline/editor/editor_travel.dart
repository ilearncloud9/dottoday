import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:flutter/widgets.dart';

/// The editor's Travel time picker (docs/02 F4 "travel-time buffer
/// 0–180 min", M7.5, R-17): None or one of [Settings.travelChoices] (the
/// current value too when it is another one, so it stays pickable).
/// Returns the minutes, or null when dismissed.
Future<int?> pickTravelTime(BuildContext context, {required int current}) {
  final l10n = context.l10n;
  final values = {
    0,
    ...Settings.travelChoices,
    if (current > 0) current,
  }.toList()..sort();
  return showChoiceSheet<int>(
    context,
    title: l10n.travelTitle,
    selected: current,
    options: [
      for (final m in values)
        (
          value: m,
          label: m == 0
              ? l10n.travelNone
              : l10n.travelBefore(formatDurationShort(l10n, m)),
          detail: null,
        ),
    ],
  );
}
