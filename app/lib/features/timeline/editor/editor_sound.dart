import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/notifications/notification_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/recurrence/series_actions.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/notifications/sound_resolution.dart';
import 'package:dottoday/domain/recurrence/series_edit.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/pickers/repeat/scope_sheet.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/sounds/sound_options.dart';
import 'package:dottoday/shared/sounds/sound_preview.dart';
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
  final picked = await showAppSheet<({String? key})>(
    context: context,
    // The list is long: it scrolls between a fixed title and Done.
    fullHeight: true,
    builder: (_) => _SoundSheet(initial: current),
  );
  if (picked == null || picked.key == current || !context.mounted) return;
  final series = task.series;
  if (series == null) return onOwn(picked.key);
  final scope = await showScopeSheet(context, delete: false);
  if (scope == null) return;
  if (scope == EditScope.thisOne) return onOwn(picked.key);
  final result = await editSeries(
    container,
    series: series,
    target: draft,
    change: SeriesChange(soundId: (to: picked.key)),
    scope: scope,
  );
  reportUndoable(
    messenger,
    l10n,
    container.read(undoServiceProvider),
    result,
    message: (_) => l10n.snackSeriesChanged(draft.title),
    tokenOf: (t) => t,
  );
}

/// The picker: Default, None, then the sound sections. A tap marks and
/// plays; Done returns the mark.
class _SoundSheet extends ConsumerStatefulWidget {
  const _SoundSheet({required this.initial});

  final String? initial;

  @override
  ConsumerState<_SoundSheet> createState() => _SoundSheetState();
}

class _SoundSheetState extends ConsumerState<_SoundSheet> {
  late String? _picked = widget.initial;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final fallback = ref
        .watch(currentProfileProvider)
        .value
        ?.settings
        .reminderSound;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: DotSpace.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.s,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(l10n.sheetSound, style: t.styles.cardTitle),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: l10n.sheetClose,
                icon: DotIcon(DotGlyphs.close, color: t.colors.muted),
              ),
            ],
          ),
          if (ref.watch(deviceMutedProvider).value ?? false)
            const SoundMutedBanner(),
          Expanded(
            child: SingleChildScrollView(
              child: SoundOptionList(
                sections: taskSoundSections(
                  l10n,
                  defaultName: reminderSoundName(l10n, fallback),
                ),
                selected: _picked,
                onPick: (key) {
                  setState(() => _picked = key);
                  // Default plays what the task will then play.
                  previewSound(ref, key ?? fallback ?? defaultReminderSoundId);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: DotSpace.l),
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop((key: _picked)),
              child: Text(l10n.alertsDone),
            ),
          ),
        ],
      ),
    );
  }
}
