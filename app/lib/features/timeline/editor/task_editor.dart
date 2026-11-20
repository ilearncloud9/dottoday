import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/editor/editor_draft.dart';
import 'package:dottoday/features/timeline/editor/editor_duration.dart';
import 'package:dottoday/features/timeline/editor/editor_energy.dart';
import 'package:dottoday/features/timeline/editor/editor_fields.dart';
import 'package:dottoday/features/timeline/editor/editor_footer.dart';
import 'package:dottoday/features/timeline/editor/editor_notes.dart';
import 'package:dottoday/features/timeline/editor/editor_series.dart';
import 'package:dottoday/features/timeline/editor/editor_sound.dart';
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

class _FormState extends ConsumerState<_Form> with EditorDraft<_Form> {
  @override
  TaskView get task => widget.task;

  @override
  VoidCallback? get onClose => widget.onClose;

  // A step's length changed below: follow it (M10.3).
  @override
  void didUpdateWidget(covariant _Form old) {
    super.didUpdateWidget(old);
    followStepLengths();
  }

  @override
  Widget build(BuildContext context) {
    final p = defaultTargetPlatform;
    return CallbackShortcuts(
      bindings: {
        AppShortcuts.activator(p, LogicalKeyboardKey.keyS): save,
        // ⌘D is the browser's bookmark key on the web (ED-095).
        if (!webChrome(context))
          AppShortcuts.activator(p, LogicalKeyboardKey.keyD): toggleDone,
      },
      child: SaveFailureFrame(
        failure: failure,
        onRetry: save,
        child: _fields(context),
      ),
    );
  }

  Widget _fields(BuildContext context) {
    final navigator = Navigator.of(context);
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final zone = tz.getLocation(draft.tzId);
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
          controller: title,
          autofocus: widget.autofocus,
          onSubmitted: save,
          onChanged: (v) =>
              change((o) => look.retitle(o, v, language: l10n.localeName)),
        ),
        const SizedBox(height: DotSpace.l),
        ColourIconBlock(
          color: TaskColor.fromKey(draft.colorKey),
          icon: TaskIcon.fromKey(draft.iconKey),
          title: draft.title,
          onColor: (c) => change((o) => look.pickColor(o, c.key)),
          onIcon: (i) => change((o) => look.pickIcon(o, i.key)),
        ),
        const SizedBox(height: DotSpace.l),
        if (draft.startUtc case final start?)
          WhenFields(
            startUtc: start,
            endUtc: draft.endUtc!,
            zone: zone,
            onWhen: (start, id) =>
                change((o) => o.copyWith(startUtc: start, tzId: id)),
          ),
        EditorDuration.withSteps(
          task: draft,
          steps: widget.task.subtasks,
          edit: change,
        ),
        const SizedBox(height: DotSpace.l),
        RepeatAlertRows(
          task: widget.task,
          onRepeat: draft.startUtc == null ? null : () => unawaited(repeat()),
          travelMin: draft.travelBufferMin,
          onTravel: draft.startUtc == null ? null : () => unawaited(travel()),
          pinned: draft.pinned,
          onPinned: (v) => change((o) => o.copyWith(pinned: v)),
          onAlerts: alertsRowTap(context, widget.task, draft, change),
          soundText: soundRowText(context, ref, widget.task, draft),
          onSound: soundRowTap(context, widget.task, draft, change),
        ),
        const SizedBox(height: DotSpace.l),
        SheetSubtasks(task: widget.task, editing: true),
        EditorEnergy(
          energy: draft.energy,
          onChanged: (e) => change((o) => o.copyWith(energy: e)),
        ),
        EditorNotes(
          notes: draft.notes,
          onChanged: (v) => change((o) => o.copyWith(notes: v)),
        ),
        CalendarWriteLine(linkId: draft.calendarLinkId),
        const SizedBox(height: DotSpace.xl),
        EditorFooter(
          task: draft,
          onSave: save,
          scopedDelete: !widget.task.repeats
              ? null
              : () => deleteScoped(context, task: widget.task, target: draft),
          // Back to the page: the sheet below would show a task now gone.
          // The navigator is taken now: a delete that reaches a calendar
          // can outlast the editor, which closes when its task goes.
          onLeft: widget.onClose ?? () => navigator.popUntil((r) => r.isFirst),
          beforeLeave: leaving,
        ),
      ],
    );
  }
}
