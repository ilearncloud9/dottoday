import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/sheet_actions.dart';
import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Now's two actions (E-PhonesMinimal frames 1 and 5): Done, filled, with
/// Undo; and Need more time? ▾, whose menu is each platform's own (owner,
/// native first): +5, +15, +30 min, then Shift the rest while the task
/// runs into the next one.
class NowActions extends ConsumerWidget {
  const NowActions({required this.task, super.key});

  final Occurrence task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final android = DotIdiom.of(context) == DotIdiom.material;
    final view = ref.watch(taskViewProvider(task.id)).value;
    final shift = view == null ? null : shiftRestAction(context, ref, view);
    final more = DotMenuButton<VoidCallback>(
      tooltip: l10n.lateNudgeTitle,
      onSelected: (run) => run(),
      entries: () => [
        for (final m in const [5, 15, 30])
          ContextMenuEntry(
            value: () => unawaited(_extend(context, ref, m)),
            label: l10n.runningLateBy(m),
          ),
        if (shift case final s?)
          ContextMenuEntry(value: s, label: l10n.liveShiftRest, divided: true),
      ],
      child: Container(
        constraints: const BoxConstraints(minHeight: DotTouch.android),
        padding: const EdgeInsets.symmetric(horizontal: DotSpace.l),
        decoration: BoxDecoration(
          // Android: tonal; the iPhone: outlined (E-PhonesMinimal).
          color: android ? t.colors.accentTint : null,
          border: android
              ? null
              : Border.all(color: t.colors.outline, width: DotSpace.hairline),
          borderRadius: BorderRadius.circular(DotRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: DotSpace.xs,
          children: [
            Flexible(
              child: Text(
                l10n.lateNudgeTitle,
                style: t.styles.button.copyWith(color: t.colors.text),
              ),
            ),
            if (!android)
              DotIcon(
                DotGlyphs.chevronDown,
                color: t.colors.text,
                size: DotSize.rowIcon,
              ),
          ],
        ),
      ),
    );
    // Done the shorter, as the boards draw it, so "Need more time?" keeps
    // to one line.
    return Row(
      spacing: DotSpace.s,
      children: [
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: () => unawaited(markDone(context, ref, task)),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(DotTouch.android),
            ),
            icon: DotIcon(DotGlyphs.check, color: t.colors.onAccent),
            label: Text(l10n.sheetDone),
          ),
        ),
        Expanded(flex: 3, child: more),
      ],
    );
  }

  Future<void> _extend(BuildContext context, WidgetRef ref, int m) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final undo = ref.read(undoServiceProvider);
    reportUndoable(
      messenger,
      l10n,
      undo,
      await extendTask(ref, task, minutes: m),
      message: (_) => l10n.runningLateBy(m),
      tokenOf: (token) => token,
    );
  }
}
