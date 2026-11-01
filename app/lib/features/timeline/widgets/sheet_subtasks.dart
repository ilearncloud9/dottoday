import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/subtask.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/editor/editor_scope.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/subtask_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Subtasks · 1 of 3" (docs/09 M3f.3, R-09): each ticked on this day only;
/// tap a title to rename it, give it a length (M10.3), × to remove, drag
/// (or Move up / down) to reorder, a field to add one; a repeating task
/// can make this day's list its list for every time.
class SheetSubtasks extends ConsumerStatefulWidget {
  const SheetSubtasks({required this.task, this.editing = false, super.key});

  final TaskView task;

  /// The editor's list: rename, remove, reorder, every-time. The task
  /// sheet's list ticks on tap.
  final bool editing;

  @override
  ConsumerState<SheetSubtasks> createState() => _SubtasksState();
}

class _SubtasksState extends ConsumerState<SheetSubtasks> {
  bool _adding = false;

  /// The new subtask's write failed: the field keeps it (M8.5b, R-08).
  AppFailure? _addFailure;
  final _field = TextEditingController();

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  List<Subtask> get _list =>
      [...widget.task.subtasks]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  @override
  Widget build(BuildContext context) {
    final list = _list;
    final next = _running() ? list.where((s) => !s.done).firstOrNull : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          done: list.where((s) => s.done).length,
          total: list.length,
          onAdd: () => setState(() => _adding = true),
          onBreakDown: _offerBreakDown(context)
              ? () => Actions.maybeInvoke(
                  context,
                  BreakDownIntent(widget.task.occurrence.id),
                )
              : null,
        ),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: (from, to) => unawaited(_move(list, from, to)),
          children: [
            for (final (i, s) in list.indexed)
              SubtaskRow(
                key: ValueKey(s.id),
                subtask: s,
                index: i,
                now: s == next,
                editing: widget.editing,
                onTick: () => unawaited(
                  _write([
                    tick(
                      s,
                      done: !s.done,
                      nowUtc: ref.read(clockProvider).nowUtc(),
                    ),
                  ]),
                ),
                onRename: (t) => unawaited(_write([s.copyWith(title: t)])),
                onLength: widget.editing
                    ? (m) => unawaited(_write([s.copyWith(durationMin: m)]))
                    : null,
                onRemove: () => unawaited(_remove(s)),
                onUp: i == 0 ? null : () => unawaited(_move(list, i, i - 1)),
                onDown: i == list.length - 1
                    ? null
                    : () => unawaited(_move(list, i, i + 1)),
              ),
          ],
        ),
        if (_adding) _newField(context),
        if (widget.editing && widget.task.repeats && list.isNotEmpty)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => unawaited(_everyTime()),
              child: Text(context.l10n.subtaskEveryTime),
            ),
          ),
      ],
    );
  }

  Widget _newField(BuildContext context) => TextField(
    controller: _field,
    autofocus: true,
    textInputAction: TextInputAction.done,
    decoration: InputDecoration(
      hintText: context.l10n.sheetNewSubtask,
      errorText: switch (_addFailure) {
        final f? => failureMessage(context.l10n, f),
        null => null,
      },
    ),
    onSubmitted: _add,
  );

  /// "Break it down" (11 B1, M10.4) on the task sheet and in the Mac/web
  /// panel, which steps aside for the proposal and reopens fresh — not in
  /// the phone editor, whose open draft would miss the new length.
  bool _offerBreakDown(BuildContext context) =>
      !widget.editing ||
      WidthClass.of(MediaQuery.sizeOf(context).width) == WidthClass.expanded;

  /// Whether the task is running now (the "now" tag).
  bool _running() {
    final o = widget.task.occurrence;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final start = o.startUtc;
    return o.status == OccurrenceStatus.planned &&
        start != null &&
        !start.isAfter(now) &&
        o.endUtc!.isAfter(now);
  }

  /// Moves row [from] to position [to] of the list without it.
  Future<void> _move(List<Subtask> list, int from, int to) async {
    final rest = [...list]..removeAt(from);
    final at = to;
    final before = at == 0 ? null : rest[at - 1].sortOrder;
    final after = at >= rest.length ? null : rest[at].sortOrder;
    final order = switch ((before, after)) {
      (null, null) => 1.0,
      (null, final a?) => a - 1,
      (final b?, null) => b + 1,
      (final b?, final a?) => (a + b) / 2,
    };
    await _write([list[from].copyWith(sortOrder: order)]);
  }

  /// Writes the typed subtask; the field closes only once it landed.
  Future<void> _add(String text) async {
    final title = text.trim();
    if (title.isEmpty) return _closeField();
    final o = widget.task.occurrence;
    final now = ref.read(clockProvider).nowUtc();
    final last = _list.lastOrNull?.sortOrder ?? 0;
    final written = await _write([
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
    if (!mounted) return;
    switch (written) {
      case Ok():
        _closeField();
      case Err(:final failure):
        setState(() => _addFailure = failure);
    }
  }

  void _closeField() {
    setState(() {
      _adding = false;
      _addFailure = null;
    });
    _field.clear();
  }

  Future<void> _remove(Subtask s) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final now = ref.read(clockProvider).nowUtc();
    reportUndoable(
      messenger,
      l10n,
      ref.read(undoServiceProvider),
      await _write([s.copyWith(deletedAt: now)]),
      message: (_) => l10n.snackSubtaskRemoved(s.title),
      tokenOf: (t) => t,
    );
  }

  Future<void> _everyTime() async {
    final write = listEveryTime(
      ProviderScope.containerOf(context),
      task: widget.task,
      subtasks: _list,
    );
    if (write == null) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    reportUndoable(
      messenger,
      l10n,
      ref.read(undoServiceProvider),
      await write,
      message: (_) => l10n.snackListEveryTime(widget.task.occurrence.title),
      tokenOf: (t) => t,
    );
  }

  Future<Result<UndoToken, AppFailure>> _write(List<Subtask> subtasks) {
    final now = ref.read(clockProvider).nowUtc();
    return ref
        .read(undoServiceProvider)
        .applyUndoable(
          WriteBatch(
            userId: widget.task.occurrence.userId,
            subtasks: [for (final s in subtasks) s.copyWith(updatedAt: now)],
          ),
        );
  }
}

/// "Subtasks · 1 of 3" and "+ Add".
class _Header extends StatelessWidget {
  const _Header({
    required this.done,
    required this.total,
    required this.onAdd,
    required this.onBreakDown,
  });

  final int done;
  final int total;
  final VoidCallback onAdd;
  final VoidCallback? onBreakDown;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              total == 0
                  ? l10n.sheetSubtasksNone
                  : l10n.sheetSubtasks(done, total),
              style: t.styles.rowTitle.copyWith(color: t.colors.muted),
            ),
          ),
        ),
        if (onBreakDown case final breakDown?)
          TextButton(
            onPressed: breakDown,
            child: Text(
              l10n.breakdownAction,
              style: t.styles.button.copyWith(color: t.colors.accentInk),
            ),
          ),
        TextButton(
          onPressed: onAdd,
          child: Text(
            l10n.sheetAddSubtask,
            style: t.styles.button.copyWith(color: t.colors.accentInk),
          ),
        ),
      ],
    );
  }
}
