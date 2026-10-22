import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_scheduler_service.dart';
import 'package:dottoday/domain/scheduling/running_late.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/late_actions.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// What the sheet was closed with.
enum _Late { shift, skip, shorten }

/// "Running late" (docs/09 M3f.5, R-04): how late (+5 / +15 / +30), then
/// shift the rest of today, skip the task at hand, or shorten it so
/// nothing after it moves. Each writes one batch with Undo; a pinned task
/// stops the shift and the preview says so before anything moves (R-17).
Future<void> showRunningLateSheet(BuildContext context, DateTime today) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final picked = await showAppSheet<(_Late, int)>(
    context: context,
    title: l10n.runningLate,
    builder: (_) => _LateSheet(today: today),
  );
  final data = container.read(timelineDataProvider(today)).value;
  if (picked == null || data == null) return;
  final (choice, minutes) = picked;
  final now = container.read(clockProvider).nowUtc();
  final target = lateTarget(data.blocks, now);
  final report = _Report(messenger, l10n, container.read(undoServiceProvider));
  switch (choice) {
    case _Late.shift:
      final run = runLate(
        container,
        day: data.blocks,
        nowUtc: now,
        minutes: minutes,
        includeCalendar: data.settings.includeCalendarInShift,
      );
      if (run != null) report.shift(await run, data.blocks, minutes);
    case _Late.skip:
      if (target == null) return;
      report(
        await skipTask(container, target),
        l10n.snackSkippedTask(target.title),
      );
    case _Late.shorten:
      final shorter = target == null ? null : shortenStart(target, minutes);
      if (shorter == null) return;
      report(
        await shortenTask(container, shorter),
        l10n.snackShortened(shorter.title, minutes),
      );
  }
}

/// The Undo snackbars of the three choices.
final class _Report {
  const _Report(this.messenger, this.l10n, this.undo);

  final ScaffoldMessengerState messenger;
  final AppLocalizations l10n;
  final UndoService undo;

  void call(Result<UndoToken, AppFailure> result, String message) =>
      reportUndoable(
        messenger,
        l10n,
        undo,
        result,
        message: (_) => message,
        tokenOf: (t) => t,
      );

  void shift(
    Result<(UndoToken, ShiftReport), AppFailure> result,
    List<Occurrence> day,
    int minutes,
  ) => reportUndoable(
    messenger,
    l10n,
    undo,
    result,
    message: (v) => switch (v.$2.blockedById) {
      final pin? => l10n.snackRunningLatePartial(
        v.$2.movedIds.length,
        minutes,
        _title(day, pin),
      ),
      null => l10n.snackRunningLate(v.$2.movedIds.length, minutes),
    },
    tokenOf: (v) => v.$1,
  );
}

String _title(List<Occurrence> day, String id) =>
    day.where((o) => o.id == id).firstOrNull?.title ?? '';

class _LateSheet extends ConsumerStatefulWidget {
  const _LateSheet({required this.today});

  final DateTime today;

  @override
  ConsumerState<_LateSheet> createState() => _LateSheetState();
}

/// A leaf: only the chosen amount.
class _LateSheetState extends ConsumerState<_LateSheet> {
  static const _choices = [5, 15, 30];

  int _minutes = 15;

  void _close(_Late choice) => Navigator.of(context).pop((choice, _minutes));

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(timelineDataProvider(widget.today)).value;
    if (data == null) return const SizedBox.shrink();
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final target = lateTarget(data.blocks, now);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _amounts(context),
        _shiftTile(context, data, now),
        if (target == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DotSpace.m),
            child: Text(
              context.l10n.lateNothingLeft,
              style: DotTheme.of(context).styles.rowMeta,
            ),
          )
        else ...[
          _skipTile(context, target),
          _shortenTile(context, target, data),
        ],
      ],
    );
  }

  Widget _amounts(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      container: true,
      label: l10n.lateAmount,
      child: Wrap(
        spacing: DotSpace.s,
        children: [
          for (final m in _choices)
            ChoiceChip(
              label: Text(l10n.runningLateBy(m)),
              shape: dotChipShape(context),
              selected: m == _minutes,
              onSelected: (_) => setState(() => _minutes = m),
            ),
        ],
      ),
    );
  }

  Widget _shiftTile(BuildContext context, TimelineData data, DateTime now) {
    final l10n = context.l10n;
    final report = const DaySchedulerService()
        .runningLate(
          data.blocks,
          now,
          _minutes,
          includeCalendar: data.settings.includeCalendarInShift,
        )
        .report;
    final moved = report.movedIds.length;
    return _Option(
      glyph: DotGlyphs.rollForward,
      title: l10n.lateShiftRest,
      detail: switch (report.blockedById) {
        final pin? when moved > 0 => l10n.lateShiftPreviewPartial(
          moved,
          _minutes,
          _title(data.blocks, pin),
        ),
        _ => l10n.lateShiftPreview(moved, _minutes),
      },
      onTap: moved == 0 ? null : () => _close(_Late.shift),
    );
  }

  Widget _skipTile(BuildContext context, Occurrence target) => _Option(
    glyph: DotGlyphs.arrowRight,
    title: context.l10n.lateSkip(target.title),
    detail: context.l10n.lateSkipDetail,
    onTap: () => _close(_Late.skip),
  );

  Widget _shortenTile(
    BuildContext context,
    Occurrence target,
    TimelineData data,
  ) {
    final l10n = context.l10n;
    final shorter = shortenStart(target, _minutes);
    final end = timeOfUtc(
      context,
      tz.getLocation(target.tzId),
      target.endUtc!,
      use24h: use24hFor(context, data.settings.use24h),
    );
    return _Option(
      glyph: DotGlyphs.clock,
      title: l10n.lateShorten(target.title),
      detail: shorter == null
          ? l10n.lateShortenTooShort(_minutes)
          : l10n.lateShortenDetail(_minutes, end),
      onTap: shorter == null ? null : () => _close(_Late.shorten),
    );
  }
}

/// One way to catch up: icon, what it does, and what it will change.
class _Option extends StatelessWidget {
  const _Option({
    required this.glyph,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final DotGlyph glyph;
  final String title;
  final String detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final color = onTap == null ? t.colors.muted : t.colors.text;
    return ListTile(
      onTap: onTap,
      enabled: onTap != null,
      contentPadding: EdgeInsets.zero,
      minTileHeight: DotTouch.android,
      leading: DotIcon(glyph, color: color),
      title: Text(title, style: t.styles.body.copyWith(color: color)),
      subtitle: Text(detail, style: t.styles.rowMeta),
    );
  }
}
