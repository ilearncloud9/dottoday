import 'dart:async';

import 'package:dottoday/core/clock/clock.dart';
import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/task_progress.dart' as progress;
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/editor/editor_duration.dart';
import 'package:dottoday/features/timeline/editor/editor_energy.dart';
import 'package:dottoday/features/timeline/editor/editor_fields.dart';
import 'package:dottoday/features/timeline/editor/editor_footer.dart';
import 'package:dottoday/features/timeline/editor/editor_notes.dart';
import 'package:dottoday/features/timeline/editor/editor_series.dart';
import 'package:dottoday/features/timeline/editor/editor_travel.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/widgets/calendar_write_line.dart';
import 'package:dottoday/features/timeline/widgets/sheet_subtasks.dart';
import 'package:dottoday/shared/dot/colour_icon_block.dart';
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
  /// How long typing pauses before a save. Behaviour, not motion, so it is
  /// not a DotMotion token.
  static const _debounce = Duration(milliseconds: 600); // style-ignore: save

  late Occurrence _draft = widget.task.occurrence;

  /// As opened: the scope question compares the draft with it (M3f.1).
  /// Set in initState: a lazy read would see the autosaved row.
  late final Occurrence _opened;
  late final _title = TextEditingController(text: _draft.title);
  // Read up front: the last flush runs in dispose, where ref is off limits.
  late final UndoService _undo;
  late final Clock _clock;
  late final Logger _logger;
  Timer? _timer;
  var _dirty = false;

  @override
  void initState() {
    super.initState();
    _opened = widget.task.occurrence;
    _undo = ref.read(undoServiceProvider);
    _clock = ref.read(clockProvider);
    _logger = ref.read(loggerProvider);
  }

  @override
  void dispose() {
    _flush();
    _title.dispose();
    super.dispose();
  }

  void _change(Occurrence Function(Occurrence) edit) {
    setState(() => _draft = edit(_draft));
    _dirty = true;
    _timer?.cancel();
    _timer = Timer(_debounce, _flush);
  }

  /// Writes the draft if it changed. An empty title keeps the old one.
  void _flush() => unawaited(_flushNow());

  Future<void> _flushNow() async {
    _timer?.cancel();
    if (!_dirty) return;
    _dirty = false;
    final title = _draft.title.trim();
    final row = _draft.copyWith(
      title: title.isEmpty ? widget.task.occurrence.title : title,
      updatedAt: _clock.nowUtc(),
    );
    final written = await _undo.applyUndoable(
      WriteBatch(userId: row.userId, occurrences: [row]),
    );
    // Not silent: a refused autosave is why Save finds nothing to ask.
    if (written case Err(:final failure)) {
      _logger.warn(
        'editor.autosave_failed', // l10n-ignore: a log event
        fields: {'id': row.id}, // l10n-ignore: a log field
        error: failure,
      );
    }
  }

  /// Save (⏎ in the title, ⌘S): write now, ask which instances of a
  /// repeating task it applies to, and leave (M3f.1).
  void _save() => unawaited(_saveNow());

  Future<void> _saveNow() async {
    await _flushNow();
    if (!mounted) return;
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
    await _flushNow();
    if (!mounted) return;
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
      child: _fields(context),
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
        TextField(
          controller: _title,
          autofocus: widget.autofocus,
          style: t.styles.topBarTitle,
          decoration: InputDecoration(hintText: l10n.editorTitleHint),
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _save(),
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
            onWhen: (start, id) =>
                _change((o) => o.copyWith(startUtc: start, tzId: id)),
          ),
        EditorDuration(
          task: _draft,
          onChanged: (m) => _change((o) => o.copyWith(durationMin: m)),
        ),
        const SizedBox(height: DotSpace.l),
        RepeatAlertRows(
          task: widget.task,
          onRepeat: _draft.startUtc == null ? null : () => unawaited(_repeat()),
          travelMin: _draft.travelBufferMin,
          onTravel: _draft.startUtc == null ? null : () => unawaited(_travel()),
          pinned: _draft.pinned,
          onPinned: (v) => _change((o) => o.copyWith(pinned: v)),
          onAlerts: () => unawaited(
            pickAlerts(
              context,
              task: widget.task,
              draft: _draft,
              onOwn: (a) => _change((o) => o.copyWith(alerts: a)),
            ),
          ),
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
          beforeLeave: () => _dirty = false,
        ),
      ],
    );
  }
}
