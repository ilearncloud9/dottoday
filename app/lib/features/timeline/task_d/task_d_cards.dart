import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/editor/editor_energy.dart';
import 'package:dottoday/features/timeline/editor/editor_leave.dart';
import 'package:dottoday/features/timeline/editor/editor_notes.dart';
import 'package:dottoday/features/timeline/editor/editor_sound.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/task_text.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/task_d/task_d_when.dart';
import 'package:dottoday/features/timeline/widgets/pin_row.dart';
import 'package:dottoday/features/timeline/widgets/sheet_subtasks.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/sheets/choice_sheet.dart';
import 'package:dottoday/shared/task_form/task_form_rows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repeat and Energy as pills (ED-086). Repeat opens the built repeat
/// editor (its scope asked first, M3f.1); Energy a short list.
class TaskDPills extends StatelessWidget {
  const TaskDPills({
    required this.task,
    required this.draft,
    required this.change,
    required this.onRepeat,
    super.key,
  });

  final TaskView task;
  final Occurrence draft;
  final DraftEdit change;
  final VoidCallback? onRepeat;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final energy = draft.energy;
    return TaskFormPills(
      pills: [
        TaskFormPill(
          glyph: DotGlyphs.repeat,
          caption: l10n.sheetRepeat,
          value: repeatText(l10n, locale, task.series?.rrule),
          onTap: onRepeat ?? () {},
        ),
        TaskFormPill(
          glyph: DotGlyphs.bolt,
          caption: l10n.editorEnergy,
          value: energy == null
              ? l10n.formEnergyNone
              : energyLabel(l10n, energy),
          onTap: () => unawaited(_energy(context)),
        ),
      ],
    );
  }

  /// None, Low, Medium, High; picked by index so a dismiss keeps it.
  Future<void> _energy(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await showChoiceSheet<int>(
      context,
      title: l10n.editorEnergy,
      selected: draft.energy?.index ?? -1,
      options: [
        (value: -1, label: l10n.formEnergyNone, detail: null),
        for (final e in Energy.values)
          (value: e.index, label: energyLabel(l10n, e), detail: null),
      ],
    );
    if (picked == null) return;
    change(
      (o) => o.copyWith(energy: picked < 0 ? null : Energy.values[picked]),
    );
  }
}

/// Steps and Notes in one card (ED-137): this task's steps, quiet (Set a
/// time and Delete in each ⋯, a long press reorders, owner M19.4), "Add a
/// step", then the notes with their links.
class TaskDStepsNotes extends StatelessWidget {
  const TaskDStepsNotes({
    required this.task,
    required this.draft,
    required this.change,
    super.key,
  });

  final TaskView task;
  final Occurrence draft;
  final DraftEdit change;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final steps = task.subtasks.where((s) => s.deletedAt == null).toList();
    final done = steps.where((s) => s.done).length;
    Widget caption(String text, [String? end]) => Row(
      children: [
        Expanded(child: Text(text, style: t.styles.rowMeta)),
        if (end != null)
          Text(end, style: t.styles.rowMeta.copyWith(color: t.colors.muted)),
      ],
    );
    return _Card(
      children: [
        caption(
          l10n.formSteps,
          steps.isEmpty ? null : l10n.liveSubtasks(done, steps.length),
        ),
        SheetSubtasks(task: task, editing: true, quiet: true),
        Divider(height: DotSpace.l, color: t.colors.outline),
        caption(l10n.editorNotes),
        EditorNotes(
          notes: draft.notes,
          caption: false,
          onChanged: (v) => change((o) => o.copyWith(notes: v)),
        ),
      ],
    );
  }
}

/// The More card (R2-40, ED-346): Sound, Travel time, Pinned ("Stays put
/// when other tasks shift"), Delete task.
class TaskDMore extends ConsumerWidget {
  const TaskDMore({
    required this.task,
    required this.draft,
    required this.change,
    required this.leave,
    required this.onTravel,
    super.key,
  });

  final TaskView task;
  final Occurrence draft;
  final DraftEdit change;
  final EditorLeave leave;
  final VoidCallback? onTravel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final travel = draft.travelBufferMin;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        TaskFormCard(
          rows: [
            TaskFormRow(
              glyph: DotGlyphs.sound,
              label: l10n.sheetSound,
              value: l10n.sheetSound,
              detail: soundRowText(context, ref, task, draft),
              onTap: soundRowTap(context, task, draft, change),
            ),
            if (onTravel case final tap?)
              TaskFormRow(
                glyph: TaskIcon.car.glyph ?? DotGlyphs.clock,
                label: l10n.travelTitle,
                value: l10n.travelTitle,
                detail: travel == 0
                    ? l10n.travelNone
                    : l10n.travelBefore(formatDurationShort(l10n, travel)),
                onTap: tap,
              ),
          ],
        ),
        if (pinnable(task.occurrence))
          _Card(
            children: [
              PinRow(
                pinned: draft.pinned,
                onChanged: (v) => change((o) => o.copyWith(pinned: v)),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        TextButton.icon(
          onPressed: () => unawaited(leave.delete(context, ref)),
          style: TextButton.styleFrom(foregroundColor: t.colors.text),
          icon: DotIcon(DotGlyphs.trash, color: t.colors.text),
          label: Text(l10n.editorDelete),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final android = DotIdiom.of(context) == DotIdiom.material;
    // A Material: the Pinned row's ListTile paints its ink on it.
    return Material(
      color: t.colors.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          android ? DotRadii.sheetCardAndroid : DotRadii.sheetCard,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DotSpace.l,
          DotSpace.m,
          DotSpace.l,
          DotSpace.s,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
