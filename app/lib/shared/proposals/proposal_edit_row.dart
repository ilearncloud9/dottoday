import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// Clock texts a [ProposalEditRow] needs, in the user's zone and 12/24 h.
abstract interface class ProposalTimes {
  /// "11:25".
  String at(DateTime utc);

  /// "11:25 – 11:55".
  String range(SnapshotDot dot);

  /// "Tomorrow 9:00".
  String day(DateTime utc);
}

/// One line of the change list (`B-ios-rebalance`): ghost dot and proposed
/// dot, times, title, chip, and × when [onRemove] is given.
class ProposalEditRow extends StatelessWidget {
  const ProposalEditRow({
    required this.edit,
    required this.times,
    required this.onRemove,
    super.key,
  });

  final ProposalEdit edit;
  final ProposalTimes times;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final dot = edit.after ?? edit.before;
    if (dot == null) return const SizedBox.shrink();
    final leaves = edit.after == null;
    final chip = _chipText(context);
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.m,
        children: [
          _Lanes(before: edit.before, after: edit.after),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: DotSpace.xxs,
              children: [
                _TimeLine(edit: edit, times: times),
                Text(
                  dot.title,
                  style: t.styles.rowTitle.copyWith(
                    color: leaves ? t.colors.muted : null,
                  ),
                ),
                _ChangeChip(text: chip, change: edit.change),
              ],
            ),
          ),
          if (onRemove case final remove?)
            IconButton(
              onPressed: remove,
              tooltip: context.l10n.proposalKeep(dot.title),
              style: IconButton.styleFrom(
                side: BorderSide(color: t.colors.outline),
              ),
              icon: DotIcon(
                DotGlyphs.close,
                color: t.colors.muted,
                size: DotSize.rowIcon,
              ),
            ),
        ],
      ),
    );
  }

  String _chipText(BuildContext context) {
    final l10n = context.l10n;
    final delta = edit.deltaMin;
    final length = formatDurationShort(l10n, delta.abs());
    final after = edit.after;
    return switch (edit.change) {
      ProposalChange.shifted when delta >= 0 => l10n.proposalShiftedLater(
        length,
      ),
      ProposalChange.shifted => l10n.proposalShiftedEarlier(length),
      ProposalChange.resized when after != null && delta < 0 =>
        l10n.proposalShrunk(formatDurationShort(l10n, after.durationMin)),
      ProposalChange.resized => l10n.proposalGrown(
        formatDurationShort(l10n, after?.durationMin ?? 0),
      ),
      ProposalChange.movedToDay => switch (edit.movedToUtc) {
        final to? => l10n.proposalMovedTo(times.day(to)),
        null => l10n.proposalMovedToInbox,
      },
      ProposalChange.added => l10n.proposalAdded,
      ProposalChange.untouched => l10n.proposalUntouched,
      ProposalChange.steps => l10n.proposalSteps(
        edit.subtasks.where((s) => s.deletedAt == null).length,
      ),
    };
  }
}

/// The dot now (faded) and as proposed (accent-outlined), side by side.
class _Lanes extends StatelessWidget {
  const _Lanes({required this.before, required this.after});

  final SnapshotDot? before;
  final SnapshotDot? after;

  static const double _offset = DotSize.rowDot * 0.6;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    Widget dot(SnapshotDot d, DotState state) => TaskDot(
      color: TaskColor.fromKey(d.colorKey),
      icon: TaskIcon.fromKey(d.iconKey),
      state: state,
      label: d.title,
      size: DotSize.macRowDot,
    );
    final b = before;
    final a = after;
    return ExcludeSemantics(
      child: SizedBox(
        width: DotSize.macRowDot + _offset + DotSpace.xs,
        height: DotSize.macRowDot + DotSpace.xs,
        child: Stack(
          children: [
            if (b != null)
              Opacity(
                opacity: TaskAlpha.ghost,
                child: dot(b, DotState.upcoming),
              ),
            PositionedDirectional(
              start: _offset,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: t.colors.accent.withValues(alpha: TaskAlpha.ghost),
                    width: DotSize.smallDotOutline,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(DotSpace.xxs),
                  // Leaving the day: a dashed dot, as a skipped one.
                  child: dot(
                    a ?? b!,
                    a == null ? DotState.skipped : DotState.upcoming,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "~~11:00~~ 11:25 – 11:55", "2:00 – 2:45 ~~3:00~~", "~~4:00 – 4:15~~".
class _TimeLine extends StatelessWidget {
  const _TimeLine({required this.edit, required this.times});

  final ProposalEdit edit;
  final ProposalTimes times;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final style = t.styles.rowMeta;
    final struck = style.copyWith(
      color: t.colors.muted,
      decoration: TextDecoration.lineThrough,
    );
    final b = edit.before;
    final a = edit.after;
    final spans = <InlineSpan>[
      if (b != null && a == null) TextSpan(text: times.range(b), style: struck),
      if (b != null && a != null && edit.change == ProposalChange.shifted) ...[
        TextSpan(text: times.at(b.startUtc), style: struck),
        const WidgetSpan(child: SizedBox(width: DotSpace.xs)),
      ],
      if (a != null) TextSpan(text: times.range(a), style: style),
      if (b != null && a != null && edit.change == ProposalChange.resized) ...[
        const WidgetSpan(child: SizedBox(width: DotSpace.xs)),
        TextSpan(text: times.at(b.endUtc), style: struck),
      ],
    ];
    return Text.rich(TextSpan(children: spans));
  }
}

/// What changes, tinted by kind (`B-ios-rebalance`): moves in the accent,
/// length in amber, leaving the day in rose, untouched in grey. Colour is
/// never the only signal: the text says it.
class _ChangeChip extends StatelessWidget {
  const _ChangeChip({required this.text, required this.change});

  final String text;
  final ProposalChange change;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final (fill, ink) = switch (change) {
      ProposalChange.resized => (
        t.tasks[TaskColor.amber].tint,
        t.tasks[TaskColor.amber].ink,
      ),
      ProposalChange.movedToDay => (
        t.tasks[TaskColor.rose].tint,
        t.tasks[TaskColor.rose].ink,
      ),
      ProposalChange.untouched => (t.colors.hairline, t.colors.muted),
      _ => (t.colors.accentTint, t.colors.accentInk),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: const BorderRadius.all(Radius.circular(DotRadii.pill)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: DotSpace.m,
          vertical: DotSpace.xxs,
        ),
        child: Text(text, style: t.styles.rowMeta.copyWith(color: ink)),
      ),
    );
  }
}

/// "☾ Bedtime · 22:00", where the thread ends.
class ProposalBedtimeRow extends StatelessWidget {
  const ProposalBedtimeRow({required this.label, this.moon = true, super.key});

  final String label;

  /// The moon glyph; off for the "2 h 15 free" line above it.
  final bool moon;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      spacing: DotSpace.m,
      children: [
        SizedBox(
          width: DotSize.macRowDot,
          child: moon
              ? DotIcon(
                  DotGlyphs.moon,
                  color: t.colors.muted,
                  size: DotSize.rowIcon,
                )
              : null,
        ),
        Text(label, style: t.styles.rowMeta.copyWith(color: t.colors.muted)),
      ],
    );
  }
}
