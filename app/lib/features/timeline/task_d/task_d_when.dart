import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/features/timeline/editor/editor_duration.dart';
import 'package:dottoday/features/timeline/editor/editor_fields.dart';
import 'package:dottoday/features/timeline/editor/editor_series.dart';
import 'package:dottoday/features/timeline/state/task_text.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/pickers/day_pickers.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/task_form/task_form_rows.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Edits the draft: what the editor's [EditorDraft.change] takes.
typedef DraftEdit = void Function(Occurrence Function(Occurrence) edit);

/// Option D's When card (ED-086): the date, the time with its length, the
/// alerts. The date keeps the time on another day; the time and the
/// length open "Time and length", which also holds the time zone and
/// "Length = sum of steps" (kept from the old editor, owner M19.4).
class TaskDWhen extends ConsumerWidget {
  const TaskDWhen({
    required this.task,
    required this.draft,
    required this.change,
    super.key,
  });

  final TaskView task;
  final Occurrence draft;
  final DraftEdit change;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final start = draft.startUtc;
    if (start == null) return const SizedBox.shrink();
    final zone = tz.getLocation(draft.tzId);
    final local = tz.TZDateTime.from(start, zone);
    final day = DateTime(local.year, local.month, local.day);
    final today = ref.watch(todayDateProvider).value;
    final use24h = use24hFor(
      context,
      ref.watch(currentProfileProvider).value?.settings.use24h,
    );
    String time(DateTime utc) => timeOfUtc(context, zone, utc, use24h: use24h);
    final length = formatDurationShort(l10n, draft.durationMin);
    void times() => unawaited(_timeSheet(context));
    return TaskFormCard(
      rows: [
        TaskFormRow(
          glyph: DotGlyphs.calendar,
          value: DateFormat.MMMEd(l10n.localeName).format(day),
          trailing: relativeDayName(context, day, today),
          onTap: () => unawaited(_day(context, ref, day, zone)),
        ),
        TaskFormRow(
          glyph: DotGlyphs.clock,
          value: l10n.threadTimeRange(time(start), time(draft.endUtc!)),
          trailing: length,
          trailingLabel: l10n.listJoin(l10n.addDurationCaption, length),
          onTap: times,
          onTrailing: times,
        ),
        TaskFormRow(
          glyph: DotGlyphs.bell,
          value: alertsText(l10n, task.alerts),
          onTap: alertsRowTap(context, task, draft, change),
        ),
      ],
    );
  }

  /// Another day, the same time there (DST-aware).
  Future<void> _day(
    BuildContext context,
    WidgetRef ref,
    DateTime from,
    tz.Location zone,
  ) async {
    final picked = await showMonthDayPicker(
      context,
      initial: from,
      today: ref.read(todayDateProvider).value ?? from,
      firstDayOfWeek:
          ref.read(currentProfileProvider).value?.settings.firstDayOfWeek ?? 1,
    );
    if (picked == null || picked == from) return;
    final at = ClockTime.ofUtc(zone, draft.startUtc!);
    change((o) => o.copyWith(startUtc: at.onDate(zone, picked)));
  }

  /// "Time and length": the start and its zone, then the length chips and
  /// "Length = sum of steps" — the old editor's fields, as they were.
  Future<void> _timeSheet(BuildContext context) => showAppSheet<void>(
    context: context,
    title: context.l10n.editorTimeSheet,
    builder: (_) => _TimeAndLength(task: task, draft: draft, change: change),
  );
}

/// The sheet's own copy of the draft, so it redraws as it edits; every
/// change also goes to the editor's draft.
class _TimeAndLength extends StatefulWidget {
  const _TimeAndLength({
    required this.task,
    required this.draft,
    required this.change,
  });

  final TaskView task;
  final Occurrence draft;
  final DraftEdit change;

  @override
  State<_TimeAndLength> createState() => _TimeAndLengthState();
}

class _TimeAndLengthState extends State<_TimeAndLength> {
  late Occurrence _d = widget.draft;

  void _edit(Occurrence Function(Occurrence) edit) {
    setState(() => _d = edit(_d));
    widget.change(edit);
  }

  @override
  Widget build(BuildContext context) {
    final start = _d.startUtc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: DotSpace.l,
      children: [
        if (start != null)
          WhenFields(
            startUtc: start,
            endUtc: _d.endUtc!,
            zone: tz.getLocation(_d.tzId),
            onWhen: (s, id) => _edit((o) => o.copyWith(startUtc: s, tzId: id)),
          ),
        EditorDuration.withSteps(
          task: _d,
          steps: widget.task.subtasks,
          edit: _edit,
        ),
      ],
    );
  }
}
