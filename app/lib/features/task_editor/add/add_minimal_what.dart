import 'dart:async';

import 'package:dottoday/core/editing/pending_brain_dump.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/scheduling/day_room_providers.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/scheduling/slot_fit.dart';
import 'package:dottoday/features/task_editor/add/add_save.dart';
import 'package:dottoday/features/task_editor/add/create/create_task_sheet.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_minimal_parts.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_what_step.dart';
import 'package:dottoday/shared/dot/landing_strip.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Minimal Add's first step (E-PhonesMinimal frames 3 and 6): where the
/// task would land ("Today 6:00 PM", "Lands at 6:00–7:00 PM · free, no
/// overlap" on the mini horizon), the typed time or the day's first free
/// slot. Add puts it there; the chips open When; More opens the detailed
/// Create task with this draft; several lines go to Brain dump's plan.
class AddMinimalWhat extends ConsumerWidget {
  const AddMinimalWhat({required this.request, required this.state, super.key});

  final AddRequest request;
  final AddFlowState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notifier = ref.read(addFlowProvider(request).notifier);
    final profile = ref.watch(currentProfileProvider).value;
    final draft = currentDraft(ref, request, state);
    // Warm and alive for the first-free-slot lookup.
    final room = ref.watch(dayRoomProvider(draft.day)).value;
    final start =
        draft.startUtc ?? (room == null ? null : firstFreeStart(room, draft));
    final zone = tz.getLocation(draft.tzId);
    final use24h = use24hFor(context, profile?.settings.use24h);
    String time(DateTime utc) => timeOfUtc(context, zone, utc, use24h: use24h);
    final when = start == null
        ? null
        : l10n.addWhenDay(
            relativeDayName(context, draft.day, draft.today),
            time(start),
          );
    return AddWhatStep(
      state: state,
      whenLabel: when,
      lengthLabel: formatDurationShort(l10n, draft.length),
      landsAt: start == null || room == null || draft.allDay
          ? null
          : _landsAt(context, room, start, draft.length, draft.color, time),
      onType: notifier.type,
      onRemoveToken: notifier.keepAsText,
      // Enter or Add puts the dot on the thread, in the next free slot
      // when no time was typed (docs/14 §4).
      onSubmit: () => unawaited(_saveOnThread(context, ref)),
      onAnother: () => unawaited(
        addAnother(context, request, currentDraft(ref, request, state)),
      ),
      onAddMany: () => _toBrainDump(context, ref),
      onWhen: () => unawaited(_when(ref)),
      onMore: () => _more(context, ref),
      onCancel: () => unawaited(Navigator.of(context).maybePop()),
    );
  }

  AddLandsAt _landsAt(
    BuildContext context,
    DayRoom room,
    DateTime start,
    int length,
    String color,
    String Function(DateTime) time,
  ) {
    final l10n = context.l10n;
    final end = start.add(Duration(minutes: length));
    final fit = fitAt(room.blocks, start, length, dayEndUtc: room.endUtc);
    final zone = tz.getLocation(state.draft.tzId);
    final hour = DateFormat.j(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(tz.TZDateTime.from(start, zone));
    return AddLandsAt(
      range: l10n.threadTimeRange(time(start), time(end)),
      fit: switch (fit.overlaps.firstOrNull) {
        final o? => l10n.addSlotBusy(o.title),
        null => l10n.addFreeNoOverlap,
      },
      strip: LandingStrip(
        fromUtc: room.startUtc,
        toUtc: room.endUtc,
        others: [
          for (final o in room.blocks)
            if (o.startUtc != null)
              (startUtc: o.startUtc!, color: TaskColor.fromKey(o.colorKey)),
        ],
        landingUtc: start,
        color: TaskColor.fromKey(color),
        label: hour,
      ),
    );
  }

  /// The When step; with no time yet, from the first free slot of the day
  /// (docs/10 §6 "Add never asks for what it can infer").
  Future<void> _when(WidgetRef ref) async {
    final notifier = ref.read(addFlowProvider(request).notifier);
    final draft = currentDraft(ref, request, state);
    if (draft.startMinute == null) {
      final room = await ref.read(dayRoomProvider(draft.day).future);
      final from = firstFreeStart(room, draft);
      notifier.edit((d) => d.withStartUtc(from, snap: room.snapMinutes));
    }
    notifier.goTo(AddStep.when);
  }

  /// More: the detailed Create task (colour, icon, repeat, alerts,
  /// notes), with what was typed so far.
  void _more(BuildContext context, WidgetRef ref) {
    final text = ref.read(addFlowProvider(request)).value?.text ?? state.text;
    final navigator = Navigator.of(context);
    final root = Navigator.of(context, rootNavigator: true).context;
    // The same providers wherever the root navigator sits.
    final container = ProviderScope.containerOf(context, listen: false);
    navigator.pop();
    final next = AddRequest(
      languageCode: request.languageCode,
      text: text,
      startUtc: request.startUtc,
      day: request.day,
    );
    unawaited(
      showAppSheet<void>(
        context: root,
        fullHeight: true,
        builder: (_) => UncontrolledProviderScope(
          container: container,
          child: CreateTaskSheet(request: next),
        ),
      ),
    );
  }

  /// The save: the typed time, else the first free slot, on the thread
  /// (never the Inbox: that is what Later is for).
  Future<void> _saveOnThread(BuildContext context, WidgetRef ref) async {
    var draft = currentDraft(ref, request, state);
    if (draft.startMinute == null) {
      final room = await ref.read(dayRoomProvider(draft.day).future);
      draft = draft.withStartUtc(
        firstFreeStart(room, draft),
        snap: room.snapMinutes,
      );
    }
    if (!context.mounted) return;
    await saveFromSheet(context, request, draft);
  }

  /// Several lines: Brain dump plans them, and nothing is written before
  /// Accept (docs/14 §3 B4, CLAUDE.md §11).
  void _toBrainDump(BuildContext context, WidgetRef ref) {
    final text = ref.read(addFlowProvider(request)).value?.text ?? state.text;
    ref.read(pendingBrainDumpProvider.notifier).request(text);
    unawaited(Navigator.of(context).maybePop());
  }
}
