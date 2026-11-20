import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/editor/editor_writer.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/shared/dot/overlap_knot.dart';
import 'package:dottoday/shared/feedback/save_failure.dart';
import 'package:dottoday/shared/text/system_text_menu.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// "Subtasks  2 of 4" and a box per step, ticked on this occurrence only
/// (R-09); nothing when the task has none.
class InspectorSubtasks extends ConsumerWidget {
  const InspectorSubtasks({required this.task, super.key});

  final TaskView task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    final list = [...task.subtasks]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (list.isEmpty) return const SizedBox.shrink();
    final done = list.where((s) => s.done).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.xs + DotSpace.xxs,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.sheetSubtasksNone,
                  style: t.styles.inspectorHeading,
                ),
              ),
            ),
            Text(
              l10n.liveSubtasks(done, list.length),
              style: t.styles.inspectorLabel,
            ),
          ],
        ),
        for (final s in list)
          CheckboxListTile(
            value: s.done,
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: TaskColor.fromKey(task.occurrence.colorKey).color,
            title: Text(
              s.title,
              style: t.styles.inspectorValue.copyWith(
                color: s.done ? c.muted : null,
              ),
            ),
            onChanged: (v) =>
                unawaited(_tick(context, ref, s, done: v ?? false)),
          ),
      ],
    );
  }

  Future<void> _tick(
    BuildContext context,
    WidgetRef ref,
    Subtask s, {
    required bool done,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final now = ref.read(clockProvider).nowUtc();
    final row = tick(s, done: done, nowUtc: now).copyWith(updatedAt: now);
    final result = await ref
        .read(undoServiceProvider)
        .applyUndoable(
          WriteBatch(userId: task.occurrence.userId, subtasks: [row]),
        );
    if (result case Err(:final failure)) {
      showSaveFailureSnack(
        messenger,
        l10n,
        failure,
        onRetry: () => unawaited(_tick(context, ref, s, done: done)),
      );
    }
  }
}

/// "Overlaps Call with Sam 10:30–11:00" for the first task of the day
/// that shares time with this one (E-FullA-v2), with the knot.
class InspectorOverlap extends ConsumerWidget {
  const InspectorOverlap({required this.task, super.key});

  final Occurrence task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final other = _other(ref);
    if (other == null) return const SizedBox.shrink();
    final t = DotTheme.of(context);
    final zone = tz.getLocation(task.tzId);
    final use24h = use24hFor(
      context,
      ref.watch(currentProfileProvider).value?.settings.use24h,
    );
    String time(DateTime utc) => timeOfUtc(context, zone, utc, use24h: use24h);
    final range = context.l10n.blockTimeRange(
      time(other.startUtc!),
      time(other.endUtc!),
    );
    return Row(
      spacing: DotSpace.s,
      children: [
        Container(
          width: DotSize.inspectorKnot,
          height: DotSize.inspectorKnot,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: t.colors.raised,
            border: Border.all(color: t.colors.hairline),
          ),
          child: OverlapKnot(
            first: TaskColor.fromKey(task.colorKey).color,
            second: TaskColor.fromKey(other.colorKey).color,
          ),
        ),
        Expanded(
          child: Text(
            context.l10n.inspectorOverlaps(other.title, range),
            style: t.styles.inspectorValue,
          ),
        ),
      ],
    );
  }

  Occurrence? _other(WidgetRef ref) {
    final start = task.startUtc;
    if (start == null) return null;
    final l = tz.TZDateTime.from(start, tz.getLocation(task.tzId));
    final blocks = ref
        .watch(timelineDataProvider(DateTime(l.year, l.month, l.day)))
        .value
        ?.blocks;
    for (final o in blocks ?? const <Occurrence>[]) {
      if (o.id == task.id || o.startUtc == null) continue;
      if (o.startUtc!.isBefore(task.endUtc!) && start.isBefore(o.endUtc!)) {
        return o;
      }
    }
    return null;
  }
}

/// Notes, saved as you type (ED-086): a pause writes them, leaving the
/// inspector writes what is left.
class InspectorNotes extends ConsumerStatefulWidget {
  const InspectorNotes({required this.task, super.key});

  final Occurrence task;

  @override
  ConsumerState<InspectorNotes> createState() => _NotesState();
}

class _NotesState extends ConsumerState<InspectorNotes> {
  late final _text = TextEditingController(text: widget.task.notes);
  late final EditorWriter _writer;
  late final _autosave = DraftAutosave(
    () => _writer.write(
      widget.task.copyWith(notes: _text.text),
      keepTitle: widget.task.title,
      nowUtc: ref.read(clockProvider).nowUtc(),
      closed: () => !mounted,
    ),
  );

  @override
  void initState() {
    super.initState();
    _writer = EditorWriter(
      undo: ref.read(undoServiceProvider),
      logger: ref.read(loggerProvider),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _writer.attach(context);
  }

  // Another device or the editor changed the notes: show them, unless
  // typing here waits to be written.
  @override
  void didUpdateWidget(covariant InspectorNotes old) {
    super.didUpdateWidget(old);
    final notes = widget.task.notes ?? '';
    if (!_autosave.dirty && notes != _text.text) _text.text = notes;
  }

  @override
  void dispose() {
    unawaited(_autosave.flush());
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    final edge = OutlineInputBorder(
      borderRadius: BorderRadius.circular(DotRadii.inspectorButton),
      borderSide: BorderSide(color: c.hairlineStrong),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.xs,
      children: [
        Text(l10n.editorNotes, style: t.styles.inspectorHeading),
        TextField(
          contextMenuBuilder: systemTextMenu,
          controller: _text,
          minLines: 2,
          maxLines: null,
          style: t.styles.inspectorValue.copyWith(fontWeight: FontWeight.w400),
          onChanged: (_) => _autosave.touch(() => unawaited(_autosave.flush())),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: c.raised,
            hintText: l10n.editorNotesHint,
            labelText: null,
            border: edge,
            enabledBorder: edge,
            focusedBorder: edge.copyWith(
              borderSide: BorderSide(color: c.focus, width: DotSpace.xxs),
            ),
          ),
        ),
      ],
    );
  }
}
