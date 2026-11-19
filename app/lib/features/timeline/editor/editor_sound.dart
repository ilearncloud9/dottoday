import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/recurrence/series_edit.dart';
import 'package:dottoday/features/timeline/editor/editor_scope.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/pickers/repeat/scope_sheet.dart';
import 'package:dottoday/shared/sounds/sound_picker_sheet.dart';
import 'package:dottoday/shared/sounds/sound_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The task's own sound (docs/12 §3): the row's, else its series'.
String? taskOwnSound(TaskView task, Occurrence draft) =>
    draft.soundId ?? task.series?.soundId;

/// The Sound row's value for [draft]: its sound, or "Default · Dot" with
/// the default read from Settings.
String soundRowText(
  BuildContext context,
  WidgetRef ref,
  TaskView task,
  Occurrence draft,
) => taskSoundText(
  context.l10n,
  own: taskOwnSound(task, draft),
  defaultSound: ref.watch(currentProfileProvider).value?.settings.reminderSound,
);

/// Opens [pickSound] for the editor's [draft]; [edit] keeps "this one".
VoidCallback soundRowTap(
  BuildContext context,
  TaskView task,
  Occurrence draft,
  void Function(Occurrence Function(Occurrence)) edit,
) =>
    () => unawaited(
      pickSound(
        context,
        task: task,
        draft: draft,
        onOwn: (s) => edit((o) => o.copyWith(soundId: s)),
      ),
    );

/// The Sound row (docs/12 §6): "Default · Dot", None, or a sound, picked
/// with a preview. Like Alerts: a one-off keeps it on the row ([onOwn]); a
/// repeating task asks which instances, and "all" puts it on the series.
Future<void> pickSound(
  BuildContext context, {
  required TaskView task,
  required Occurrence draft,
  required ValueChanged<String?> onOwn,
}) async {
  final container = ProviderScope.containerOf(context);
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final current = taskOwnSound(task, draft);
  final picked = await showSoundPicker(context, initial: current);
  if (picked == null || picked.key == current || !context.mounted) return;
  if (!task.repeats) return onOwn(picked.key);
  final scope = await showScopeSheet(
    context,
    delete: false,
    scopes: scopesFor(task),
  );
  if (scope == null) return;
  if (scope == EditScope.thisOne) return onOwn(picked.key);
  final write = writeScoped(
    container,
    task: task,
    target: draft,
    change: SeriesChange(soundId: (to: picked.key)),
    scope: scope,
  );
  if (write == null) return;
  reportUndoable(
    messenger,
    l10n,
    container.read(undoServiceProvider),
    (await write).result,
    message: (_) => l10n.snackSeriesChanged(draft.title),
    tokenOf: (t) => t,
  );
}
