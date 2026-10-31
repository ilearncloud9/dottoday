import 'dart:async';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/icon_guess/title_look.dart';
import 'package:dottoday/domain/scheduling/step_lengths.dart';
import 'package:dottoday/domain/scheduling/task_progress.dart' as progress;
import 'package:dottoday/features/timeline/editor/editor_duration.dart';
import 'package:dottoday/features/timeline/editor/editor_energy.dart';
import 'package:dottoday/features/timeline/editor/editor_fields.dart';
import 'package:dottoday/features/timeline/editor/editor_footer.dart';
import 'package:dottoday/features/timeline/editor/editor_notes.dart';
import 'package:dottoday/features/timeline/editor/editor_series.dart';
import 'package:dottoday/features/timeline/editor/editor_sound.dart';
import 'package:dottoday/features/timeline/editor/editor_travel.dart';
import 'package:dottoday/features/timeline/editor/editor_writer.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/widgets/calendar_write_line.dart';
import 'package:dottoday/features/timeline/widgets/sheet_subtasks.dart';
import 'package:dottoday/shared/dot/colour_icon_block.dart';
import 'package:dottoday/shared/feedback/save_failure.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// The E1 fields for task [id]. Changes save as you type (debounced) and
/// the last one is flushed when the editor closes, so dismissing never
/// loses an edit (03 §3.4 "nothing lost on dismiss").
class TaskEditor extends ConsumerWidget {
  const TaskEditor({
    required this.id,
    this.onClose,
    this.caption = true,
    this.autofocus = false,
    super.key,
  });

  final String id;

  /// Focus the title on open (the panel, `A-mac-editor`), so the keys
  /// (⏎, ⌘S, ⌘D) work at once.
  final bool autofocus;

  /// Leaves the editor after Save, Delete or Move to inbox: the phone
  /// sheet pops (the default); the Mac/web panel closes itself.
  final VoidCallback? onClose;

  /// "EDIT TASK" above the title; the panel shows it in its own header.
  final bool caption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(taskViewProvider(id));
    // A reload (a dependency changed) keeps the previous task: matching
    // AsyncData alone would unmount the form mid-edit, losing focus and
    // the "as opened" row Save compares with (found by CI, M5.5).
    return switch (view) {
      AsyncValue(hasValue: true, value: final TaskView task) => _Form(
        task: task,
        onClose: onClose,
        caption: caption,
        autofocus: autofocus,
      ),
      AsyncData(value: null) ||
      AsyncError() => Center(child: Text(context.l10n.sheetNotFound)),
      _ => const SizedBox.shrink(),
    };
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({
    required this.task,
    required this.onClose,
    required this.caption,
    required this.autofocus,
  });

  final TaskView task;
  final bool autofocus;

  /// Null: the phone sheet, which pops.
  final VoidCallback? onClose;
  final bool caption;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  late Occurrence _draft = widget.task.occurrence;

  /// As opened: the scope question compares the draft with it (M3f.1).
  /// Set in initState: a lazy read would see the autosaved row.
  late final Occurrence _opened;
  late final _title = TextEditingController(text: _draft.title);
  late final _look = TitleLook(widget.task.occurrence);
  late final EditorWriter _writer;
  late final Clock _clock;
  late final _autosave = DraftAutosave(
    () => _writer.write(
      _draft,
      keepTitle: widget.task.occurrence.title,
      nowUtc: _clock.nowUtc(),
      closed: () => !mounted,
    ),
  );

  /// A failed write: shown with Try again; Save waits for one (R-08).
  AppFailure? _failure;

  @override
  void initState() {
    super.initState();
    _opened = widget.task.occurrence;
    _writer = EditorWriter(
      undo: ref.read(undoServiceProvider),
      logger: ref.read(loggerProvider),
    );
    _clock = ref.read(clockProvider);
  }

  // A step's length changed below: follow it (M10.3).
  @override
  void didUpdateWidget(covariant _Form old) {
    super.didUpdateWidget(old);
    final next = followSteps(_draft, widget.task.subtasks);
    if (next.durationMin == _draft.durationMin) return;
    _draft = next; // build follows didUpdateWidget
    _autosave.touch(_flush);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _writer.attach(context);
  }

  @override
  void dispose() {
    _flush();
    _title.dispose();
    super.dispose();
  }

  void _change(Occurrence Function(Occurrence) edit) {
    setState(() => _draft = edit(_draft));
    _autosave.touch(_flush);
  }

  void _flush() => unawaited(_flushNow());

  /// Writes the draft if it changed; whether everything typed is written.
  Future<bool> _flushNow() async {
    if (!_autosave.dirty) return true;
    final failure = await _autosave.flush();
    if (mounted) setState(() => _failure = failure);
    return failure == null;
  }

  /// Save (⏎, ⌘S): write now, ask which instances of a repeating task it
  /// applies to (M3f.1), and leave — unless the write failed.
  void _save() => unawaited(_saveNow());

  Future<void> _saveNow() async {
    if (!await _flushNow() || !mounted) return;
    final saved = await saveScoped(
      context,
      task: widget.task,
      opened: _opened,
      draft: _draft,
    );
    if (!saved || !mounted) return;
    final close = widget.onClose;
    close == null ? Navigator.of(context).pop() : close();
  }

  /// The Repeat row: what is typed is saved first.
  Future<void> _repeat() async {
    if (!await _flushNow() || !mounted) return;
    await pickRepeat(context, task: widget.task, draft: _draft);
  }

  /// The Travel time row (M7.5, R-17).
  Future<void> _travel() async {
    final m = await pickTravelTime(context, current: _draft.travelBufferMin);
    if (m != null && mounted) _change((o) => o.copyWith(travelBufferMin: m));
  }

  /// ⌘D: done, or planned again, written with the other edits.
  void _toggleDone() => _change((o) => progress.toggleDone(o, _clock.nowUtc()));

  @override
  Widget build(BuildContext context) {
    final p = defaultTargetPlatform;
    return CallbackShortcuts(
      bindings: {
        AppShortcuts.activator(p, LogicalKeyboardKey.keyS): _save,
        AppShortcuts.activator(p, LogicalKeyboardKey.keyD): _toggleDone,
      },
      child: SaveFailureFrame(
        failure: _failure,
        onRetry: _save,
        child: _fields(context),
      ),
    );
  }

  Widget _fields(BuildContext context) {
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
        if (widget.caption)
          Text(l10n.editorCaption.toUpperCase(), style: t.styles.caption),
        EditorTitleField(
          controller: _title,
          autofocus: widget.autofocus,
          onSubmitted: _save,
          onChanged: (v) =>
              _change((o) => _look.retitle(o, v, language: l10n.localeName)),
        ),
        const SizedBox(height: DotSpace.l),
        ColourIconBlock(
          color: TaskColor.fromKey(_draft.colorKey),
          icon: TaskIcon.fromKey(_draft.iconKey),
          onColor: (c) => _change((o) => _look.pickColor(o, c.key)),
          onIcon: (i) => _change((o) => _look.pickIcon(o, i.key)),
        ),
        const SizedBox(height: DotSpace.l),
        if (_draft.startUtc case final start?)
          WhenFields(
            startUtc: start,
            endUtc: _draft.endUtc!,
            zone: zone,
            onWhen: (start, id) =>
                _change((o) => o.copyWith(startUtc: start, tzId: id)),
          ),
        EditorDuration.withSteps(
          task: _draft,
          steps: widget.task.subtasks,
          edit: _change,
        ),
        const SizedBox(height: DotSpace.l),
        RepeatAlertRows(
          task: widget.task,
          onRepeat: _draft.startUtc == null ? null : () => unawaited(_repeat()),
          travelMin: _draft.travelBufferMin,
          onTravel: _draft.startUtc == null ? null : () => unawaited(_travel()),
          pinned: _draft.pinned,
          onPinned: (v) => _change((o) => o.copyWith(pinned: v)),
          onAlerts: alertsRowTap(context, widget.task, _draft, _change),
          soundText: soundRowText(context, ref, widget.task, _draft),
          onSound: soundRowTap(context, widget.task, _draft, _change),
        ),
        const SizedBox(height: DotSpace.l),
        SheetSubtasks(task: widget.task, editing: true),
        EditorEnergy(
          energy: _draft.energy,
          onChanged: (e) => _change((o) => o.copyWith(energy: e)),
        ),
        EditorNotes(
          notes: _draft.notes,
          onChanged: (v) => _change((o) => o.copyWith(notes: v)),
        ),
        CalendarWriteLine(linkId: _draft.calendarLinkId),
        const SizedBox(height: DotSpace.xl),
        EditorFooter(
          task: _draft,
          onSave: _save,
          scopedDelete: widget.task.series == null
              ? null
              : () => deleteScoped(context, task: widget.task, target: _draft),
          // Back to the page: the sheet below would show a task now gone.
          onLeft:
              widget.onClose ??
              () => Navigator.of(context).popUntil((r) => r.isFirst),
          beforeLeave: () => _autosave.dirty = false,
        ),
      ],
    );
  }
}
