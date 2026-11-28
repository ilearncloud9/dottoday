import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/time/day_boundaries.dart';
import 'package:dottoday/domain/time/schedule_edit.dart';
import 'package:dottoday/features/settings/wake_wind/schedule_sheet/schedule_text.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// What the sheet says about the draft (E-Phones "New schedule checks"
/// and Weekend): the blocking ones in one grey note ("… Add stays off
/// until both are set"), the short night and day as notes that still let
/// Save work, and Wind Down after midnight in violet.
class ScheduleCheckNotes extends StatelessWidget {
  const ScheduleCheckNotes({
    required this.draft,
    required this.action,
    required this.use24h,
    required this.firstDay,
    super.key,
  });

  final ScheduleDraft draft;

  /// "Save" or "Add": named in the blocking note.
  final String action;
  final bool? use24h;
  final int firstDay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final checks = scheduleChecks(draft);
    final night = nightMinutes(draft.window);
    final same = checks.contains(ScheduleCheck.sameTime);
    final none = checks.contains(ScheduleCheck.noDays);
    final notes = <Widget>[
      if (same || none)
        _Note(
          text: same && none
              ? l10n.schCheckBoth(action)
              : same
              ? l10n.schCheckSame(action)
              : l10n.schCheckNoDays(action),
        ),
      if (checks.contains(ScheduleCheck.shortNight))
        _Note(text: l10n.schShortNight(formatDurationShort(l10n, night))),
      if (checks.contains(ScheduleCheck.shortDay))
        _Note(
          text: l10n.schShortDay(
            formatDurationShort(l10n, Duration.minutesPerDay - night),
          ),
        ),
      if (checks.contains(ScheduleCheck.afterMidnight))
        _Note(
          violet: true,
          text: l10n.schAfterMidnight(
            clockText(
              context,
              windowMinutes(draft.window.end) % Duration.minutesPerDay,
              use24h,
            ),
            daysOwnText(context, weekOrder(draft.days, firstDay)),
          ),
        ),
    ];
    if (notes.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: notes,
    );
  }
}

/// One note with the info mark: grey, or violet for the night's own note.
class _Note extends StatelessWidget {
  const _Note({required this.text, this.violet = false});

  final String text;
  final bool violet;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.tasks[TaskColor.violet];
    final ink = violet ? c.ink : t.colors.ink;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(DotSpace.m),
        decoration: BoxDecoration(
          color: violet ? c.tint : t.colors.chip,
          borderRadius: BorderRadius.circular(DotRadii.choice),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSpace.s,
          children: [
            ExcludeSemantics(
              child: DotIcon(DotGlyphs.info, color: ink, size: DotSize.rowIcon),
            ),
            Expanded(
              child: Text(text, style: t.styles.body.copyWith(color: ink)),
            ),
          ],
        ),
      ),
    );
  }
}
