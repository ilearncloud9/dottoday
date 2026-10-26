import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/calendar/calendar_shift_providers.dart';
import 'package:dottoday/data/scheduling/learning_meta.dart';
import 'package:dottoday/data/scheduling/learning_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_scheduler_service.dart';
import 'package:dottoday/domain/scheduling/learning.dart';
import 'package:dottoday/domain/scheduling/running_late.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/features/timeline/state/late_actions.dart';
import 'package:dottoday/features/timeline/state/rebalance_flow.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/learning/learned_line.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// What the sheet was closed with.
enum _Late { shift, skip, shorten }

/// "Running late" (docs/09 M3f.5, R-04): how late (+5 / +15 / +30), then
/// shift the rest of today — as a Rebalance proposal, written only on
/// Accept (M11.1) — skip the task at hand, or shorten it so nothing after
/// it moves. Skip and Shorten write one batch with Undo; a pinned task
/// stops the shift and the preview says so (R-17).
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
      // A proposal first; nothing moves until Accept (11 C1, M11.1).
      await openRebalance(
        container,
        l10n,
        today: today,
        fromUtc: now,
        deltaMin: minutes,
        subtitle: l10n.rebalanceLate(formatDurationShort(l10n, minutes)),
      );
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

  /// Set once the user picks an amount; until then the history may.
  bool _picked = false;

  void _close(_Late choice) => Navigator.of(context).pop((choice, _minutes));

  /// How much longer [target] usually takes, as the default amount and its
  /// reason, explained on tap (M11.3, docs/13 §6); null keeps the default.
  Widget? _learnedAmount(BuildContext context, Occurrence? target) {
    if (target == null) return null;
    final learned =
        ref
            .watch(learningIndexProvider)
            .value
            ?.forTask(title: target.title, seriesId: target.seriesId) ??
        Learned.none;
    final amount = lateAmountFor(target.durationMin, learned, _choices);
    if (amount == null) return null;
    if (!_picked) _minutes = amount;
    final l10n = context.l10n;
    final t = DotTheme.of(context);
    return LearnedLine(
      text: l10n.lateUsually(
        target.title,
        formatDurationShort(l10n, learned.usualMinutes!),
      ),
      explanation: LearnedExplanation.perTitle(
        l10n,
        samples: learned.samples,
        title: target.title,
        reset: () => ref
            .read(learningMetaProvider.notifier)
            .resetUndoable(target.title, ref.read(clockProvider).nowUtc()),
      ),
      style: t.styles.rowMeta.copyWith(color: t.colors.muted),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(timelineDataProvider(widget.today)).value;
    if (data == null) return const SizedBox.shrink();
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final target = lateTarget(data.blocks, now);
    final why = _learnedAmount(context, target);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _amounts(context),
        if (why != null)
          Padding(
            padding: const EdgeInsets.only(top: DotSpace.xs),
            child: why,
          ),
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
              onSelected: (_) => setState(() {
                _minutes = m;
                _picked = true;
              }),
            ),
        ],
      ),
    );
  }

  Widget _shiftTile(BuildContext context, TimelineData data, DateTime now) {
    final l10n = context.l10n;
    final fixed = ref.watch(readOnlyCalendarIdsProvider).value;
    final report = const DaySchedulerService()
        .runningLate(
          data.blocks,
          now,
          _minutes,
          includeCalendar:
              fixed != null && data.settings.includeCalendarInShift,
          readOnlyIds: fixed ?? const {},
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
