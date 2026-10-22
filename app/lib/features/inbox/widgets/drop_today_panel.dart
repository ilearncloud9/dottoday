import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/drag_math.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';
import 'package:dottoday/domain/time/day_shape.dart';
import 'package:dottoday/features/inbox/widgets/inbox_commands.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

/// "Drop onto today" (`A-mac-inbox`): today's thread beside the Inbox,
/// each free gap naming the first task that fits it; drop a row on a gap
/// to place it there (M3e.2).
class DropTodayPanel extends StatelessWidget {
  const DropTodayPanel({
    required this.room,
    required this.items,
    required this.zone,
    required this.nowUtc,
    required this.format,
    required this.commands,
    super.key,
  });

  /// What is left of today; its blocks are today's tasks.
  final DayRoom room;

  /// Open inbox tasks in the shown order: the first that fits names a gap.
  final List<Occurrence> items;
  final tz.Location zone;
  final DateTime nowUtc;
  final ThreadFormat format;
  final InboxCommands commands;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final entries = _withFits(
      threadEntries(
        blocks: room.blocks,
        shape: DayShape(wakeUtc: room.startUtc, bedUtc: room.endUtc),
        nowUtc: nowUtc,
        format: format,
      ),
    );
    final free = entries.whereType<ThreadGap>().where((g) => g.addable);
    final freeMinutes = free.fold(0, (sum, g) => sum + g.minutes);
    final keys = AppShortcuts.label(
      defaultTargetPlatform,
      '↩', // l10n-ignore: a key cap, not words
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        border: Border.all(color: t.colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.m,
          children: [
            _Header(freeMinutes: freeMinutes),
            Expanded(
              child: SingleChildScrollView(
                child: Thread(entries: entries, actions: _actions(context)),
              ),
            ),
            Text(
              l10n.inboxDropHint(keys),
              style: t.styles.rowMeta.copyWith(color: t.colors.muted),
            ),
          ],
        ),
      ),
    );
  }

  /// Names, on each future gap, the first task in [items] that fits it.
  List<ThreadEntry> _withFits(List<ThreadEntry> entries) => [
    for (final e in entries)
      switch (e) {
        ThreadGap(addable: true) => switch (_fitting(e.minutes)) {
          final o? => e.fitting(o.title),
          null => e,
        },
        _ => e,
      },
  ];

  Occurrence? _fitting(int minutes) =>
      openItems(items).where((o) => o.durationMin <= minutes).firstOrNull;

  ThreadActions _actions(BuildContext context) {
    final l10n = context.l10n;
    Occurrence? find(String id) => items.where((o) => o.id == id).firstOrNull;
    Slot? slotFor(String id, ThreadGap? gap, double fraction) {
      final o = find(id);
      final start = gap?.startUtc;
      if (o == null || start == null || gap == null) return null;
      final at = dropStart(
        zone: zone,
        gapStartUtc: start,
        gapMinutes: gap.minutes,
        fraction: fraction,
        durationMin: o.durationMin,
        snapMinutes: room.snapMinutes,
      );
      return Slot(at, at.add(Duration(minutes: o.durationMin)));
    }

    return ThreadActions(
      drag: ThreadDrag(
        hintFor: (id, gap, fraction) => switch (slotFor(id, gap, fraction)) {
          final s? => l10n.dragDropAt(format.time(s.startUtc)),
          null => null,
        },
        onDrop: (id, gap, fraction, _) {
          final o = find(id);
          final slot = slotFor(id, gap, fraction);
          if (o == null || slot == null) return;
          unawaited(
            commands.place(o, (
              slot: slot,
              label: l10n.inboxScheduleToday(commands.rangeText(slot)),
            )),
          );
        },
      ),
    );
  }
}

/// "Drop onto today" and the free time left.
class _Header extends StatelessWidget {
  const _Header({required this.freeMinutes});

  final int freeMinutes;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Semantics(
      header: true,
      child: Row(
        children: [
          Expanded(child: Text(l10n.inboxDropToday, style: t.styles.cardTitle)),
          Text(
            l10n.inboxDropTodayFree(formatDurationShort(l10n, freeMinutes)),
            style: t.styles.rowMeta,
          ),
        ],
      ),
    );
  }
}
