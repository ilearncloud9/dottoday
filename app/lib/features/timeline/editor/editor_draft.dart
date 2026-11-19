import 'dart:async';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/icon_guess/title_look.dart';
import 'package:dottoday/domain/scheduling/step_lengths.dart';
import 'package:dottoday/domain/scheduling/task_progress.dart' as progress;
import 'package:dottoday/features/timeline/editor/editor_series.dart';
import 'package:dottoday/features/timeline/editor/editor_writer.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/shared/pickers/travel_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A task editor's draft (the Mac/web panel's form and option D's sheet,
/// ED-086): changes save as you type (debounced) and the last one is
/// flushed when the editor closes, so dismissing never loses an edit (03
/// §3.4). Save asks which instances of a repeating task it applies to
/// (M3f.1); a failed write is kept with Try again (R-08).
mixin EditorDraft<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// The task as the editor shows it.
  TaskView get task;

  /// After Save: the panel closes itself; null pops the sheet's route.
  VoidCallback? get onClose;

  late Occurrence draft = task.occurrence;

  /// As opened: the scope question compares the draft with it (M3f.1),
  /// and the Saved bar's Undo goes back to it. Set in initState: a lazy
  /// read would see the autosaved row.
  late final Occurrence opened;
  late final title = TextEditingController(text: draft.title);
  late final look = TitleLook(task.occurrence);
  late final EditorWriter _writer;
  late final Clock _clock;
  late final _autosave = DraftAutosave(
    () => _writer.write(
      draft,
      keepTitle: task.occurrence.title,
      nowUtc: _clock.nowUtc(),
      closed: () => !mounted,
    ),
  );

  /// A failed write: shown with Try again; Save waits for one (R-08).
  AppFailure? failure;

  /// When the draft last landed ("Saved · 9:41"); null until a write.
  DateTime? savedAtUtc;

  @override
  void initState() {
    super.initState();
    opened = task.occurrence;
    _writer = EditorWriter(
      undo: ref.read(undoServiceProvider),
      logger: ref.read(loggerProvider),
    );
    _clock = ref.read(clockProvider);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _writer.attach(context);
  }

  @override
  void dispose() {
    flush();
    title.dispose();
    super.dispose();
  }

  /// The task changed outside the draft (Move, Need more time, a step's
  /// length): with nothing waiting to save, the draft takes the newer
  /// row, so a later save never puts the old one back. Call from
  /// didUpdateWidget, before [followStepLengths].
  void adoptLatest() {
    final row = task.occurrence;
    if (_autosave.dirty || row == draft) return;
    draft = row; // build follows didUpdateWidget
    if (title.text != row.title) title.text = row.title;
  }

  /// A step's length changed below: the task follows it (M10.3). Call
  /// from didUpdateWidget.
  void followStepLengths() {
    final next = followSteps(draft, task.subtasks);
    if (next.durationMin == draft.durationMin) return;
    draft = next; // build follows didUpdateWidget
    _autosave.touch(flush);
  }

  /// Applies [edit] to the draft and saves it once typing pauses.
  void change(Occurrence Function(Occurrence) edit) {
    setState(() => draft = edit(draft));
    _autosave.touch(flush);
  }

  void flush() => unawaited(flushNow());

  /// Writes the draft if it changed; whether everything typed is written.
  Future<bool> flushNow() async {
    if (!_autosave.dirty) return true;
    final failed = await _autosave.flush();
    if (mounted) {
      setState(() {
        failure = failed;
        if (failed == null) savedAtUtc = _clock.nowUtc();
      });
    }
    return failed == null;
  }

  /// Save (⏎, ⌘S, Done): write now, ask which instances of a repeating
  /// task it applies to (M3f.1), and leave — unless the write failed.
  void save() => unawaited(saveNow());

  Future<void> saveNow() async {
    if (!await flushNow() || !mounted) return;
    final saved = await saveScoped(
      context,
      task: task,
      opened: opened,
      draft: draft,
    );
    if (!saved || !mounted) return;
    final close = onClose;
    close == null ? Navigator.of(context).pop() : close();
  }

  /// The Saved bar's Undo: the task as it was when the editor opened.
  void undoEdits() {
    title.text = opened.title;
    change((_) => opened);
  }

  /// The Repeat row: what is typed is saved first.
  Future<void> repeat() async {
    if (!await flushNow() || !mounted) return;
    await pickRepeat(context, task: task, draft: draft);
  }

  /// The Travel time row (M7.5, R-17).
  Future<void> travel() async {
    final m = await pickTravelTime(context, current: draft.travelBufferMin);
    if (m != null && mounted) change((o) => o.copyWith(travelBufferMin: m));
  }

  /// ⌘D and the header's circle: done, or planned again, written with the
  /// other edits.
  void toggleDone() => change((o) => progress.toggleDone(o, _clock.nowUtc()));

  /// Stops the autosave putting the old row back on close (Delete, Move
  /// to inbox).
  void leaving() => _autosave.dirty = false;
}
