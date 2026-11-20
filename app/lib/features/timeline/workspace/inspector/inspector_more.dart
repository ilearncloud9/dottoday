import 'dart:async';

import 'package:dottoday/core/editing/inspected_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/features/timeline/editor/editor_energy.dart';
import 'package:dottoday/features/timeline/editor/editor_leave.dart';
import 'package:dottoday/features/timeline/editor/editor_series.dart';
import 'package:dottoday/features/timeline/editor/editor_sound.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/workspace/inspector/inspector_parts.dart';
import 'package:dottoday/features/timeline/workspace/inspector/inspector_write.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:dottoday/shared/pickers/energy_menu.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/anchored_popover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The inspector's More rows under Notes (E-R2-40 "Mac · inspector",
/// ED-346): Energy, Sound and Travel time as pop-up buttons like Repeat,
/// Pinned as the built switch, then Delete task. Energy and Travel time
/// are menus with the current choice ticked (the system menu on the Mac,
/// a listbox menu on the web); Sound opens the built picker with its
/// preview. Each change is written at once, with Undo (ED-086).
class InspectorMore extends ConsumerWidget {
  const InspectorMore({required this.task, super.key});

  final TaskView task;

  Occurrence get _o => task.occurrence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final energy = _o.energy;
    final travel = _o.travelBufferMin;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s + DotSpace.xxs,
      children: [
        InspectorRow(
          label: l10n.editorEnergy,
          child: _PopUp(
            text: energy == null
                ? l10n.formEnergyNone
                : energyLabel(l10n, energy),
            onTap: (at) => unawaited(_energy(context, ref, at)),
          ),
        ),
        InspectorRow(
          label: l10n.sheetSound,
          child: InspectorField(
            text: soundRowText(context, ref, task, _o),
            chevron: true,
            onTap: () => unawaited(
              pickSound(
                context,
                task: task,
                draft: _o,
                onOwn: (s) => unawaited(
                  writeInspected(context, ref, _o.copyWith(soundId: s)),
                ),
              ),
            ),
          ),
        ),
        // An Inbox task has no start to travel to (ED-346).
        if (_o.startUtc != null)
          InspectorRow(
            label: l10n.travelTitle,
            child: _PopUp(
              text: _travelText(l10n, travel),
              onTap: (at) => unawaited(_travel(context, ref, at)),
            ),
          ),
        if (pinnable(_o))
          InspectorRow(
            label: l10n.pinTitle,
            child: MergeSemantics(
              child: Row(
                spacing: DotSpace.s,
                children: [
                  DotSwitch(
                    value: _o.pinned,
                    onChanged: (v) => unawaited(
                      writeInspected(context, ref, _o.copyWith(pinned: v)),
                    ),
                  ),
                  Flexible(
                    child: Text(l10n.pinDetail, style: t.styles.rowMeta),
                  ),
                ],
              ),
            ),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () =>
                unawaited(_leave(context, ref).delete(context, ref)),
            // The board's quiet row (E-R2-40), not a large button.
            style: TextButton.styleFrom(
              foregroundColor: t.colors.text,
              textStyle: t.styles.inspectorValue.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: DotIcon(DotGlyphs.trash, color: t.colors.text),
            label: Text(l10n.editorDelete),
          ),
        ),
      ],
    );
  }

  /// Delete as the editor does: the scope for a repeating task, else the
  /// confirm; Trash with Undo; the inspector goes with the task.
  EditorLeave _leave(BuildContext context, WidgetRef ref) => EditorLeave(
    task: _o,
    onLeft: () => ref.read(inspectedTaskProvider.notifier).close(),
    beforeLeave: () {},
    scopedDelete: !task.repeats
        ? null
        : () => deleteScoped(context, task: task, target: _o),
  );

  /// Energy's menu; picking the ticked level clears it, as built.
  Future<void> _energy(BuildContext context, WidgetRef ref, Rect? at) async {
    final picked = await pickEnergy(context, at: at, current: _o.energy);
    if (picked == null || !context.mounted) return;
    await writeInspected(context, ref, _o.copyWith(energy: picked.energy));
  }

  /// None or a built choice (the current one too when it is another).
  Future<void> _travel(BuildContext context, WidgetRef ref, Rect? at) async {
    final l10n = context.l10n;
    final current = _o.travelBufferMin;
    final values = {
      0,
      ...Settings.travelChoices,
      if (current > 0) current,
    }.toList()..sort();
    final picked = await showContextMenu<int>(
      context,
      at: at?.bottomLeft ?? Offset.zero,
      entries: [
        for (final m in values)
          ContextMenuEntry(
            value: m,
            label: _travelText(l10n, m),
            checked: m == current,
          ),
      ],
    );
    if (picked == null || picked == current || !context.mounted) return;
    await writeInspected(context, ref, _o.copyWith(travelBufferMin: picked));
  }

  static String _travelText(AppLocalizations l10n, int minutes) => minutes == 0
      ? l10n.travelNone
      : l10n.travelBefore(formatDurationShort(l10n, minutes));
}

/// A field that opens its menu under itself.
class _PopUp extends StatelessWidget {
  const _PopUp({required this.text, required this.onTap});

  final String text;

  /// Tapped; the field is at this rectangle (its menu's anchor).
  final ValueChanged<Rect?> onTap;

  @override
  Widget build(BuildContext context) => Builder(
    builder: (field) => InspectorField(
      text: text,
      chevron: true,
      onTap: () => onTap(globalRectOf(field)),
    ),
  );
}
