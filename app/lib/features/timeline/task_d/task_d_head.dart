import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/shared/dot/done_circle.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/pickers/look/look_sheet.dart';
import 'package:dottoday/shared/task_form/task_form_header.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Option D's header (ED-086): tinted in the task's colour; the dot opens
/// Colour and icon; "9:00 – 11:00 AM · 2 h · 18 min left" (another day
/// first names it) over the title, edited in place; the done circle at
/// its end. Android draws it as a card (E-Phones "Android · Task editor").
class TaskDHead extends ConsumerWidget {
  const TaskDHead({
    required this.task,
    required this.draft,
    required this.title,
    required this.onTitle,
    required this.onLook,
    required this.onDone,
    required this.onSubmitted,
    super.key,
  });

  final TaskView task;
  final Occurrence draft;
  final TextEditingController title;
  final ValueChanged<String> onTitle;

  /// The colour and icon picked (keys).
  final void Function(String color, String icon) onLook;
  final VoidCallback onDone;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final color = TaskColor.fromKey(draft.colorKey);
    final icon = TaskIcon.fromKey(draft.iconKey);
    final android = DotIdiom.of(context) == DotIdiom.material;
    return TaskFormHeader(
      color: color,
      icon: icon,
      card: android,
      done: draft.status == OccurrenceStatus.done,
      summary: _summary(context, ref),
      onLook: (at) => unawaited(_look(context, color, icon, at)),
      title: TaskFormTitleField(
        controller: title,
        hint: l10n.editorTitleHint,
        onChanged: onTitle,
        onSubmitted: (_) => onSubmitted(),
        action: android ? TextInputAction.done : TextInputAction.unspecified,
      ),
      trailing: DoneCircle(
        color: color,
        done: draft.status == OccurrenceStatus.done,
        title: draft.title,
        onTap: onDone,
      ),
    );
  }

  Future<void> _look(
    BuildContext context,
    TaskColor colour,
    TaskIcon icon,
    Rect? anchor,
  ) async {
    // Each pick lands at once, so the header recolours live (ED-161).
    await showTaskLook(
      context,
      colour: colour,
      icon: icon,
      title: draft.title,
      anchor: anchor,
      onChanged: (l) => onLook(l.color.key, l.icon.key),
    );
  }

  /// "Wed, Nov 4 · 2:00 – 2:20 PM · 20 min"; today's "9:00 – 11:00 AM",
  /// with "· 18 min left" while it runs; "Inbox" without a time.
  String _summary(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final start = draft.startUtc;
    if (start == null) return l10n.sheetInbox;
    final zone = tz.getLocation(draft.tzId);
    final use24h = use24hFor(
      context,
      ref.watch(currentProfileProvider).value?.settings.use24h,
    );
    String time(DateTime utc) => timeOfUtc(context, zone, utc, use24h: use24h);
    final local = tz.TZDateTime.from(start, zone);
    final day = DateTime(local.year, local.month, local.day);
    final today = ref.watch(todayDateProvider).value;
    final range = l10n.threadTimeRange(time(start), time(draft.endUtc!));
    final length = formatDurationShort(l10n, draft.durationMin);
    // Today's is the range alone (E-Phones F3); another day names it.
    final base = day == today
        ? range
        : l10n.addWhenSummary(
            relativeDayName(context, day, today),
            range,
            length,
          );
    final now = ref.watch(minuteTickProvider).value;
    final end = draft.endUtc!;
    if (now == null || now.isBefore(start) || !now.isBefore(end)) return base;
    final left = end.difference(now).inMinutes;
    return base + l10n.sheetLeftSuffix(l10n.liveMinutesLeft(left));
  }
}

/// "● Saved · 9:41  Undo" (ED-086): once an edit has landed, Undo puts
/// the task back as it was when the sheet opened.
class TaskDSavedBar extends StatelessWidget {
  const TaskDSavedBar({
    required this.savedAtUtc,
    required this.onUndo,
    super.key,
  });

  final DateTime? savedAtUtc;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final at = savedAtUtc;
    if (at == null) return const SizedBox.shrink();
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(at.toLocal()),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return SafeArea(
      top: false,
      child: Semantics(
        liveRegion: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: DotSpace.s,
          children: [
            DotIcon(DotGlyphs.check, color: t.colors.accentInk),
            Text(
              l10n.editorSavedAt(time),
              style: t.styles.rowMeta.copyWith(color: t.colors.muted),
            ),
            TextButton(onPressed: onUndo, child: Text(l10n.undoAction)),
          ],
        ),
      ),
    );
  }
}
