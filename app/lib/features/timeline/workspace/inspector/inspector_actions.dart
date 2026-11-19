import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/focus_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/rebalance_flow.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/workspace/inspector/inspector_write.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// "Need more time?" with +5 +15 +30 (ED-163), for the task running now:
/// each chip extends it once, in its own day, with Undo.
class InspectorExtend extends ConsumerWidget {
  const InspectorExtend({required this.task, super.key});

  final Occurrence task;

  static const _amounts = [5, 15, 30];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    final sizes = InspectorSizes.of(context, ref);
    return Container(
      constraints: BoxConstraints(minHeight: sizes.extend),
      padding: const EdgeInsetsDirectional.only(
        start: DotSpace.s + DotSpace.xxs,
        end: DotSpace.xs,
      ),
      decoration: ShapeDecoration(
        color: c.raised,
        shape: StadiumBorder(side: BorderSide(color: c.hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(l10n.lateNudgeTitle, style: t.styles.inspectorValue),
          ),
          for (final m in _amounts)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: DotSpace.xs),
              child: _Chip(
                text: l10n.inspectorExtendChip(m),
                label: l10n.inspectorExtendLabel(m),
                height: sizes.extendChip,
                onTap: () => unawaited(_extend(context, ref, m)),
              ),
            ),
        ],
      ),
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

/// Done, Focus and Shift rest, side by side (E-FullA-v2). Shift rest is
/// there only while the task runs into the next one (R-04).
class InspectorButtons extends ConsumerWidget {
  const InspectorButtons({required this.task, super.key});

  final Occurrence task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final l10n = context.l10n;
    final sizes = InspectorSizes.of(context, ref);
    final done = task.status == OccurrenceStatus.done;
    final shift = _shift(context, ref);
    Widget button(
      String text,
      Color fill,
      Color ink,
      VoidCallback? onTap, {
      bool edge = false,
    }) => Expanded(
      child: _Button(
        text: text,
        fill: fill,
        ink: ink,
        edge: edge,
        height: sizes.button,
        onTap: onTap,
      ),
    );
    return Row(
      spacing: DotSpace.xs + DotSpace.xxs,
      children: [
        button(
          done ? l10n.sheetUndone : l10n.sheetDone,
          c.accent,
          c.onAccent,
          () => unawaited(_toggleDone(context, ref)),
        ),
        button(
          l10n.focusTitle,
          c.accentTint,
          c.accentInk,
          task.startUtc == null ? null : () => openFocus(context, task.id),
        ),
        button(l10n.inspectorShiftRest, c.raised, c.text, shift, edge: true),
      ],
    );
  }

  Future<void> _toggleDone(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final undo = ref.read(undoServiceProvider);
    final done = task.status == OccurrenceStatus.done;
    reportUndoable(
      messenger,
      l10n,
      undo,
      await toggleDone(ref, task),
      message: (_) =>
          done ? l10n.snackNotDone(task.title) : l10n.snackDone(task.title),
      tokenOf: (token) => token,
    );
  }

  /// As the task sheet's Shift: the live task running into the next.
  VoidCallback? _shift(BuildContext context, WidgetRef ref) {
    final o = task;
    final start = o.startUtc;
    if (start == null) return null;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    if (now.isBefore(start) || !now.isBefore(o.endUtc!)) return null;
    final l = tz.TZDateTime.from(start, tz.getLocation(o.tzId));
    final day = ref
        .watch(timelineDataProvider(DateTime(l.year, l.month, l.day)))
        .value;
    if (day == null) return null;
    final overrun = overrunOf(o, day.blocks);
    if (overrun <= 0) return null;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final undo = ref.read(undoServiceProvider);
    return () async {
      if (rebalanceShiftRest(context, day.blocks, o, overrun)) return;
      reportUndoable(
        messenger,
        l10n,
        undo,
        await shiftRest(ref, day: day.blocks, live: o, overrunMinutes: overrun),
        message: (v) => l10n.snackShifted(v.$2.movedIds.length),
        tokenOf: (v) => v.$1,
      );
    };
  }
}

/// A teal "+15" chip.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.text,
    required this.label,
    required this.height,
    required this.onTap,
  });

  final String text;
  final String label;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: c.accentTint,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
            alignment: Alignment.center,
            child: Text(
              text,
              style: t.styles.inspectorButton.copyWith(color: c.accentInk),
            ),
          ),
        ),
      ),
    );
  }
}

/// One of Done, Focus, Shift rest: 32 tall, radius 10.
class _Button extends StatelessWidget {
  const _Button({
    required this.text,
    required this.fill,
    required this.ink,
    required this.edge,
    required this.height,
    required this.onTap,
  });

  final String text;
  final Color fill;
  final Color ink;
  final bool edge;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final off = onTap == null;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DotRadii.inspectorButton),
      side: edge ? BorderSide(color: c.hairlineStrong) : BorderSide.none,
    );
    return Semantics(
      button: true,
      enabled: !off,
      child: Material(
        color: off ? c.sunk : fill,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: Container(
            height: height,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: DotSpace.xs),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.styles.inspectorButton.copyWith(
                color: off ? c.tertiary : ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
