import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/when_move.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/duration/duration_sheet.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Starts and Duration on the minimal task screen (ED-089): side by side
/// on phones; as rows with − and + on the Mac and web ([column]). Starts
/// opens the When picker (ED-099); Duration the Duration sheet, or ±15
/// min in the column. Each change has Undo.
class TaskMWhen extends ConsumerWidget {
  const TaskMWhen({required this.task, this.column = false, super.key});

  final Occurrence task;
  final bool column;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final o = task;
    final start = o.startUtc;
    if (start == null) return const SizedBox.shrink();
    final use24h = use24hFor(
      context,
      ref.watch(currentProfileProvider).value?.settings.use24h,
    );
    final starts = timeOfUtc(
      context,
      tz.getLocation(o.tzId),
      start,
      use24h: use24h,
    );
    final length = formatDurationShort(l10n, o.durationMin);
    Future<void> lengthTo(int minutes) => _length(context, ref, o, minutes);
    void move() => unawaited(pickMoveTask(context, ref, o));
    void sheet() => unawaited(_sheet(context, ref, o));
    if (!column) {
      return Row(
        spacing: DotSpace.s,
        children: [
          Expanded(
            child: _Box(label: l10n.taskMStarts, value: starts, onTap: move),
          ),
          Expanded(
            child: _Box(label: l10n.durationLabel, value: length, onTap: sheet),
          ),
        ],
      );
    }
    final t = DotTheme.of(context);
    Widget caption(String s) => SizedBox(
      width: DotSize.nowRowLabel,
      child: Text(s, style: t.styles.rowMeta),
    );
    return Column(
      spacing: DotSpace.s,
      children: [
        Row(
          children: [
            caption(l10n.taskMStarts),
            Flexible(
              child: _Pill(value: starts, label: l10n.taskMStarts, onTap: move),
            ),
          ],
        ),
        Row(
          children: [
            caption(l10n.durationLabel),
            Flexible(
              child: _Pill(
                value: length,
                label: l10n.durationLabel,
                onTap: sheet,
              ),
            ),
            IconButton(
              tooltip: l10n.taskMShorter,
              onPressed: o.durationMin <= _step
                  ? null
                  : () => unawaited(lengthTo(o.durationMin - _step)),
              icon: DotIcon(DotGlyphs.minus, color: t.colors.text),
            ),
            IconButton(
              tooltip: l10n.taskMLonger,
              onPressed: () => unawaited(lengthTo(o.durationMin + _step)),
              icon: DotIcon(DotGlyphs.add, color: t.colors.text),
            ),
          ],
        ),
      ],
    );
  }

  /// The column's − and + step (E-Minimal: 15 min).
  static const _step = 15;

  Future<void> _sheet(BuildContext context, WidgetRef ref, Occurrence o) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final presets =
        ref.read(currentProfileProvider).value?.settings.durationPresets ??
        const [15, 30, 45, 60];
    final minutes = await showDurationSheet(
      context,
      initial: o.durationMin,
      color: TaskColor.fromKey(o.colorKey),
      icon: TaskIcon.fromKey(o.iconKey),
      presets: presets,
      onPresets: (p) => unawaited(
        updateSettings(container, (s) => s.copyWith(durationPresets: p)),
      ),
    );
    if (minutes == null || !context.mounted) return;
    await _length(context, ref, o, minutes);
  }

  /// [o] at [minutes] long, with Undo ("Duration · 45 min").
  Future<void> _length(
    BuildContext context,
    WidgetRef ref,
    Occurrence o,
    int minutes,
  ) async {
    if (minutes == o.durationMin) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final undo = ref.read(undoServiceProvider);
    reportUndoable(
      messenger,
      l10n,
      undo,
      await extendTask(ref, o, minutes: minutes - o.durationMin),
      message: (_) =>
          l10n.listJoin(l10n.durationLabel, formatDurationShort(l10n, minutes)),
      tokenOf: (t) => t,
    );
  }
}

/// A phone's labelled box: "Starts / 9:00 AM" (E-PhonesMinimal).
class _Box extends StatelessWidget {
  const _Box({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    // One stop for a screen reader: "Starts, 9:00 AM", a button.
    return MergeSemantics(
      child: Material(
        color: t.colors.raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DotRadii.sheetCardAndroid),
          side: BorderSide(color: t.colors.outline),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DotRadii.sheetCardAndroid),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DotSpace.m,
              vertical: DotSpace.s,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: t.styles.rowMeta),
                Text(value, style: t.styles.body),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The column's value pill: "9:00 AM", "2 h" (E-Minimal).
class _Pill extends StatelessWidget {
  const _Pill({required this.value, required this.label, required this.onTap});

  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      label: label,
      child: Material(
        color: t.colors.raised,
        shape: StadiumBorder(side: BorderSide(color: t.colors.outline)),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: DotTouch.min),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DotSpace.l),
              child: Center(
                widthFactor: 1,
                child: Text(value, style: t.styles.body),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
