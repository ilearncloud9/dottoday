import 'dart:async';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/editor/editor_duration.dart';
import 'package:dottoday/features/timeline/editor/editor_fields.dart';
import 'package:dottoday/features/timeline/editor/editor_footer.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/widgets/sheet_subtasks.dart';
import 'package:dottoday/shared/dot/colour_icon_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Opens the phone editor for [id] (docs/10 §5.2 E1: "on phones the task
/// sheet's Edit opens the same fields as a full sheet").
void showTaskEditor(BuildContext context, String id) => unawaited(
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) =>
        FractionallySizedBox(heightFactor: 0.94, child: TaskEditor(id: id)),
  ),
);

/// The E1 fields for task [id]. Changes save as you type (debounced) and
/// the last one is flushed when the editor closes, so dismissing never
/// loses an edit (03 §3.4 "nothing lost on dismiss").
class TaskEditor extends ConsumerWidget {
  const TaskEditor({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(taskViewProvider(id));
    return switch (view) {
      AsyncData(value: final task?) => _Form(task: task),
      AsyncData(value: null) ||
      AsyncError() => Center(child: Text(context.l10n.sheetNotFound)),
      _ => const SizedBox.shrink(),
    };
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.task});

  final TaskView task;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  /// How long typing pauses before a save. Behaviour, not motion, so it is
  /// not a DotMotion token.
  static const _debounce = Duration(milliseconds: 600); // style-ignore: save

  late Occurrence _draft = widget.task.occurrence;
  late final _title = TextEditingController(text: _draft.title);
  late final _notes = TextEditingController(text: _draft.notes ?? '');
  // Read up front: the last flush runs in dispose, where ref is off limits.
  late final UndoService _undo;
  late final Clock _clock;
  Timer? _timer;
  var _dirty = false;

  @override
  void initState() {
    super.initState();
    _undo = ref.read(undoServiceProvider);
    _clock = ref.read(clockProvider);
  }

  @override
  void dispose() {
    _flush();
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _change(Occurrence Function(Occurrence) edit) {
    setState(() => _draft = edit(_draft));
    _dirty = true;
    _timer?.cancel();
    _timer = Timer(_debounce, _flush);
  }

  /// Writes the draft if it changed. An empty title keeps the old one.
  void _flush() {
    _timer?.cancel();
    if (!_dirty) return;
    _dirty = false;
    final title = _draft.title.trim();
    final row = _draft.copyWith(
      title: title.isEmpty ? widget.task.occurrence.title : title,
      updatedAt: _clock.nowUtc(),
    );
    unawaited(
      _undo.applyUndoable(WriteBatch(userId: row.userId, occurrences: [row])),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final zone = tz.getLocation(_draft.tzId);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        DotSpace.page,
        DotSpace.s,
        DotSpace.page,
        DotSpace.xl,
      ),
      children: [
        Text(l10n.editorCaption.toUpperCase(), style: t.styles.caption),
        TextField(
          controller: _title,
          style: t.styles.topBarTitle,
          decoration: InputDecoration(hintText: l10n.editorTitleHint),
          textCapitalization: TextCapitalization.sentences,
          onChanged: (v) => _change((o) => o.copyWith(title: v)),
        ),
        const SizedBox(height: DotSpace.l),
        ColourIconBlock(
          color: TaskColor.fromKey(_draft.colorKey),
          icon: TaskIcon.fromKey(_draft.iconKey),
          onColor: (c) => _change((o) => o.copyWith(colorKey: c.key)),
          onIcon: (i) => _change((o) => o.copyWith(iconKey: i.key)),
        ),
        const SizedBox(height: DotSpace.l),
        if (_draft.startUtc case final start?)
          WhenFields(
            startUtc: start,
            endUtc: _draft.endUtc!,
            zone: zone,
            onDay: (day) => _change(
              (o) => o.copyWith(
                startUtc: ClockTime.ofUtc(zone, start).onDate(zone, day),
              ),
            ),
            onTime: (time) => _change(
              (o) => o.copyWith(
                startUtc: time.onDate(zone, tz.TZDateTime.from(start, zone)),
              ),
            ),
          ),
        EditorDuration(
          task: _draft,
          onChanged: (m) => _change((o) => o.copyWith(durationMin: m)),
        ),
        const SizedBox(height: DotSpace.l),
        RepeatAlertRows(task: widget.task),
        const SizedBox(height: DotSpace.l),
        SheetSubtasks(task: widget.task),
        EditorCaption(l10n.editorNotes),
        TextField(
          controller: _notes,
          minLines: 3,
          maxLines: 8,
          decoration: InputDecoration(hintText: l10n.editorNotesHint),
          onChanged: (v) =>
              _change((o) => o.copyWith(notes: v.isEmpty ? null : v)),
        ),
        const SizedBox(height: DotSpace.xl),
        EditorFooter(
          task: _draft,
          onSave: () {
            _flush();
            Navigator.of(context).pop();
          },
          beforeLeave: () => _dirty = false,
        ),
      ],
    );
  }
}
