import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/features/task_editor/add/add_save.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/breakdown/breakdown_flow.dart';
import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:dottoday/shared/pickers/travel_picker.dart';
import 'package:dottoday/shared/sounds/sound_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _More { sound, travel, pinned, inbox, breakDown }

/// Create task's ⋯ (owner, M19.3): Sound, Travel time and Pinned, as on
/// the editor's More card (ED-346), then Add to Inbox instead and Break it
/// down. Each choice lands in the draft; only Inbox writes, as its own
/// save.
class CreateTaskMore extends ConsumerWidget {
  const CreateTaskMore({required this.request, super.key});

  final AddRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final draft = ref.watch(addFlowProvider(request)).value?.draft;
    final android = DotIdiom.of(context) == DotIdiom.material;
    final glyph = DotIcon(
      android ? DotGlyphs.moreVertical : DotGlyphs.more,
      color: t.colors.text,
    );
    return DotMenuButton<_More>(
      tooltip: l10n.createMore,
      // The iPhone's round ⋯ beside Create task (E-Phones ED-140).
      icon: android
          ? glyph
          : DecoratedBox(
              decoration: BoxDecoration(
                color: t.colors.raised,
                shape: BoxShape.circle,
                border: Border.all(color: t.colors.outline),
              ),
              child: Padding(
                padding: const EdgeInsets.all(DotSpace.s),
                child: glyph,
              ),
            ),
      onSelected: (m) => unawaited(_pick(context, ref, m)),
      entries: () => [
        ContextMenuEntry(value: _More.sound, label: l10n.sheetSound),
        ContextMenuEntry(value: _More.travel, label: l10n.travelTitle),
        ContextMenuEntry(
          value: _More.pinned,
          label: l10n.pinTitle,
          checked: draft?.details.pinned ?? false,
        ),
        ContextMenuEntry(
          value: _More.inbox,
          label: l10n.addToInbox,
          divided: true,
        ),
        if (draft?.title.isNotEmpty ?? false)
          ContextMenuEntry(value: _More.breakDown, label: l10n.breakdownAction),
      ],
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref, _More m) async {
    final flow = ref.read(addFlowProvider(request).notifier);
    final state = ref.read(addFlowProvider(request)).value;
    if (state == null) return;
    final draft = currentDraft(ref, request, state);
    final details = draft.details;
    switch (m) {
      case _More.sound:
        final picked = await showSoundPicker(context, initial: details.soundId);
        if (picked == null) return;
        flow.edit(
          (d) => d.withDetails(d.details.copyWith(soundId: () => picked.key)),
        );
      case _More.travel:
        final picked = await pickTravelTime(
          context,
          current: details.travelMin,
        );
        if (picked == null) return;
        flow.edit((d) => d.withDetails(d.details.copyWith(travelMin: picked)));
      case _More.pinned:
        flow.edit(
          (d) => d.withDetails(d.details.copyWith(pinned: !d.details.pinned)),
        );
      case _More.inbox:
        await saveFromSheet(context, request, draft, toInbox: true);
      case _More.breakDown:
        await breakDown(
          context,
          BreakdownTarget(
            title: draft.title,
            durationMin: draft.length,
            colorKey: draft.color,
            iconKey: draft.icon,
            // Accepted steps join the draft; its length follows their sum.
            onDraftAccepted: (steps) => flow.edit((d) {
              final next = d.withSteps(steps);
              final total = next.stepsTotal;
              return total == null
                  ? next
                  : next.withDuration(
                      total.clamp(minDurationMin, maxDurationMin),
                    );
            }),
          ),
        );
    }
  }
}
