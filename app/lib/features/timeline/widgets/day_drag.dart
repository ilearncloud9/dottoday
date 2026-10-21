import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/drag_math.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/features/timeline/state/drag_actions.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Drag and resize for a day's [blocks] (docs/10 §6, R-05): drops snap to
/// [snapMinutes] on the wall clock in [zone]; each write has Undo.
ThreadDrag dayThreadDrag(
  BuildContext context,
  WidgetRef ref, {
  required List<Occurrence> blocks,
  required tz.Location zone,
  required int snapMinutes,
  required String Function(DateTime utc) timeText,
}) {
  final d = _DayDrag(
    ref: ref,
    messenger: ScaffoldMessenger.of(context),
    l10n: context.l10n,
    blocks: blocks,
    zone: zone,
    snapMinutes: snapMinutes,
    timeText: timeText,
  );
  return ThreadDrag(hintFor: d.hint, onDrop: d.drop, onResize: d.resize);
}

/// What [dayThreadDrag] needs, read once while the page is mounted.
final class _DayDrag {
  _DayDrag({
    required this.ref,
    required this.messenger,
    required this.l10n,
    required this.blocks,
    required this.zone,
    required this.snapMinutes,
    required this.timeText,
  }) : undo = ref.read(undoServiceProvider);

  final WidgetRef ref;
  final ScaffoldMessengerState messenger;
  final AppLocalizations l10n;
  final UndoService undo;
  final List<Occurrence> blocks;
  final tz.Location zone;
  final int snapMinutes;
  final String Function(DateTime utc) timeText;

  Occurrence? _find(String id) => blocks.where((o) => o.id == id).firstOrNull;

  DateTime? _start(String id, ThreadGap gap, double fraction) {
    final o = _find(id);
    final gapStart = gap.startUtc;
    if (o == null || gapStart == null) return null;
    return dropStart(
      zone: zone,
      gapStartUtc: gapStart,
      gapMinutes: gap.minutes,
      fraction: fraction,
      durationMin: o.durationMin,
      snapMinutes: snapMinutes,
    );
  }

  String? hint(String id, ThreadGap? gap, double fraction) {
    final start = gap == null ? null : _start(id, gap, fraction);
    return start == null ? null : l10n.dragDropAt(timeText(start));
  }

  Future<void> drop(String id, ThreadGap gap, double fraction) async {
    final o = _find(id);
    final start = _start(id, gap, fraction);
    if (o == null || start == null || start == o.startUtc) return;
    _report(
      await moveTask(ref, o, start),
      l10n.snackMoved(o.title, timeText(start)),
    );
  }

  Future<void> resize(String id, int steps) async {
    final o = _find(id);
    if (o == null) return;
    final minutes = resizedDuration(
      o.durationMin,
      steps: steps,
      snapMinutes: snapMinutes,
    );
    if (minutes == o.durationMin) return;
    final end = o.startUtc!.add(Duration(minutes: minutes));
    _report(
      await resizeTask(ref, o, minutes),
      l10n.snackResized(o.title, timeText(end)),
    );
  }

  void _report(Result<UndoToken, AppFailure> result, String message) =>
      reportUndoable(
        messenger,
        l10n,
        undo,
        result,
        message: (_) => message,
        tokenOf: (t) => t,
      );
}
