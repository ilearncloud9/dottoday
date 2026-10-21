import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Subtasks · 1 of 3", each ticked on this occurrence only (R-09), and an
/// inline field to add one.
class SheetSubtasks extends ConsumerStatefulWidget {
  const SheetSubtasks({required this.task, super.key});

  final TaskView task;

  @override
  ConsumerState<SheetSubtasks> createState() => _SubtasksState();
}

class _SubtasksState extends ConsumerState<SheetSubtasks> {
  bool _adding = false;
  final _field = TextEditingController();

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final subtasks = widget.task.subtasks;
    final done = subtasks.where((s) => s.done).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  subtasks.isEmpty
                      ? l10n.sheetSubtasksNone
                      : l10n.sheetSubtasks(done, subtasks.length),
                  style: t.styles.rowTitle.copyWith(color: t.colors.muted),
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _adding = true),
              child: Text(
                l10n.sheetAddSubtask,
                style: t.styles.button.copyWith(color: t.colors.accentInk),
              ),
            ),
          ],
        ),
        for (final s in subtasks)
          CheckboxListTile(
            value: s.done,
            onChanged: (_) => unawaited(_write([s.copyWith(done: !s.done)])),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(
              s.title,
              style: t.styles.body.copyWith(
                color: s.done ? t.colors.muted : null,
                decoration: s.done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        if (_adding)
          TextField(
            controller: _field,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(hintText: l10n.sheetNewSubtask),
            onSubmitted: _add,
          ),
      ],
    );
  }

  Future<void> _add(String text) async {
    final title = text.trim();
    setState(() => _adding = false);
    _field.clear();
    if (title.isEmpty) return;
    final o = widget.task.occurrence;
    final now = ref.read(clockProvider).nowUtc();
    final last = widget.task.subtasks.lastOrNull?.sortOrder ?? 0;
    await _write([
      Subtask(
        id: const UuidV7Generator().newId(),
        userId: o.userId,
        occurrenceId: o.id,
        title: title,
        sortOrder: last + 1,
        createdAt: now,
        updatedAt: now,
      ),
    ]);
  }

  Future<void> _write(List<Subtask> subtasks) async {
    final now = ref.read(clockProvider).nowUtc();
    await ref
        .read(undoServiceProvider)
        .applyUndoable(
          WriteBatch(
            userId: widget.task.occurrence.userId,
            subtasks: [for (final s in subtasks) s.copyWith(updatedAt: now)],
          ),
        );
  }
}
