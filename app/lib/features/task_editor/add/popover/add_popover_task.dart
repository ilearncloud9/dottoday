import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:dottoday/domain/scheduling/slot_fit.dart';
import 'package:dottoday/features/task_editor/add/create/create_task_pickers.dart';
import 'package:dottoday/features/task_editor/add/popover/add_popover_parts.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_learned_lines.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_title_field.dart';
import 'package:dottoday/shared/dot/picker_caption.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// The Task tab of the Mac and web Add popover (E-R2-36, ED-342): the
/// title in its box with the dot (a click opens Colour and icon), the
/// words read as a day, time or length as chips with ×, then the summary
/// and "Free until … · no overlap" / "Overlaps … · you can still add it"
/// following the typing, the duration pills, Add to Inbox instead and
/// Add ↵. A pasted list asks "Add 3 tasks?" in place of the rest.
class AddPopoverTask extends ConsumerWidget {
  const AddPopoverTask({
    required this.request,
    required this.onAdd,
    required this.onInbox,
    required this.onAddMany,
    super.key,
  });

  final AddRequest request;
  final VoidCallback onAdd;
  final VoidCallback onInbox;
  final VoidCallback onAddMany;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addFlowProvider(request)).value;
    final profile = ref.watch(currentProfileProvider).value;
    if (state == null || profile == null) return const SizedBox.shrink();
    final flow = ref.read(addFlowProvider(request).notifier);
    final pick = CreateTaskPickers(context, ref, request);
    final many = QuickAddParser.lines(state.text).length > 1;
    final t = DotTheme.of(context);
    final draft = currentDraft(ref, request, state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: DotSpace.m,
      children: [
        AddTitleField(
          text: state.text,
          typed: state.draft.typed,
          onChanged: flow.type,
          onRemoveToken: flow.keepAsText,
          onSubmit: onAdd,
          onAddMany: onAddMany,
          style: t.styles.rowTitle.copyWith(fontWeight: FontWeight.w600),
          // Borderless in its box, but a full touch target (§12).
          decoration: InputDecoration(
            hintText: context.l10n.editorTitleHint,
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            constraints: const BoxConstraints(minHeight: DotTouch.min),
          ),
          frame: (field) => PopoverTitleBox(
            color: TaskColor.fromKey(draft.color),
            icon: TaskIcon.fromKey(draft.icon),
            title: draft.title,
            onLook: (at) => unawaited(pick.look(anchor: at)),
            field: field,
          ),
        ),
        if (!many) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Summary(request: request, settings: profile.settings),
              AddLearnedLines(request: request),
            ],
          ),
          PopoverLengths(
            value: draft.length,
            presets: profile.settings.durationPresets,
            onPick: (m) => flow.edit((d) => d.withDuration(m)),
            onMore: () => unawaited(pick.length()),
          ),
        ],
        PopoverFooter(
          onInbox: many ? null : onInbox,
          onAdd: many ? null : onAdd,
        ),
      ],
    );
  }
}

/// "Tue 3 Nov · 11:00 – 11:30 AM · 30 min" and its free / overlap line,
/// at the typed time, else the first free slot (docs/10 §6).
class _Summary extends ConsumerWidget {
  const _Summary({required this.request, required this.settings});

  final AddRequest request;
  final Settings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addFlowProvider(request)).value;
    final profile = ref.watch(currentProfileProvider).value;
    if (state == null || profile == null) return const SizedBox.shrink();
    final draft = currentDraft(ref, request, state);
    final room = ref.watch(dayRoomProvider(draft.day)).value;
    // "@inbox" typed: it goes to the Inbox, with no time to sum up.
    if (room == null || draft.inbox) return const SizedBox.shrink();
    final start = draft.startUtc ?? firstFreeStart(room, draft);
    final zone = tz.getLocation(profile.tzId);
    final text = DayTimeText(
      context,
      zone,
      draft.day,
      use24h: use24hFor(context, settings.use24h),
    );
    final l10n = context.l10n;
    final fit = fitAt(room.blocks, start, draft.length, dayEndUtc: room.endUtc);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final end = start.add(Duration(minutes: draft.length));
    return PopoverCard(
      title: l10n.addWhenSummary(
        DateFormat.MMMEd(locale).format(draft.day),
        l10n.threadTimeRange(text.utc(start), text.utc(end)),
        formatDurationShort(l10n, draft.length),
      ),
      caption: PickerCaption(
        freeUntil: text.utc(fit.freeUntilUtc),
        color: TaskColor.fromKey(draft.color),
        overlapTitle: fit.overlaps.firstOrNull?.title,
        overlapColor: switch (fit.overlaps.firstOrNull) {
          final o? => TaskColor.fromKey(o.colorKey),
          null => null,
        },
        overlapCount: fit.overlaps.length,
      ),
    );
  }
}
