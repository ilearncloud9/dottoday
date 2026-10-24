import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:flutter/material.dart';

/// Rows Settings › Calendars shares between device calendars and
/// connected Google/Microsoft accounts (docs/09 M7.1, M7.4).

/// Stores a switch at once; a failure says so (never swallowed).
void saveCalendarChange(
  BuildContext context,
  Future<Result<void, AppFailure>> saving,
) {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  unawaited(
    saving.then((result) {
      if (result case Err(:final failure)) {
        messenger.showSnackBar(
          SnackBar(content: Text(failureMessage(l10n, failure))),
        );
      }
    }),
  );
}

/// One calendar: its name in its inherited colour, and a switch (shown
/// in, by default; [toggle] for another one, like write-back).
class CalendarChoiceRow extends StatelessWidget {
  const CalendarChoiceRow({
    required this.choice,
    required this.onToggle,
    this.toggle,
    super.key,
  });

  final CalendarChoice choice;
  final ValueChanged<bool> onToggle;
  final bool? toggle;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final calendar = choice.calendar;
    return SettingsRow(
      glyph: DotGlyphs.calendar,
      tint: t.tasks[TaskColor.fromKey(choice.colorKey)].ink,
      title: calendar.name,
      subtitle: calendar.readOnly ? context.l10n.calendarsReadOnly : null,
      toggle: toggle ?? choice.enabled,
      onToggle: onToggle,
    );
  }
}

/// A muted calendar row with no action ("No calendars connected yet").
class CalendarEmptyRow extends StatelessWidget {
  const CalendarEmptyRow({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => SettingsRow(
    glyph: DotGlyphs.calendar,
    tint: DotTheme.of(context).colors.muted,
    title: title,
  );
}
