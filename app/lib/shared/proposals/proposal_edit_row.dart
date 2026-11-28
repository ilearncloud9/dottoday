import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/proposals/proposal_change_chip.dart';
import 'package:dottoday/shared/proposals/proposed_dot.dart';
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

/// One line of the change list (E-Phones-2, ED-150): the proposed dot,
/// times (old ones struck), title, tag, and × when [onRemove] is given.
/// [nowRing] adds the task's faded ring before it, the day as it is
/// (E-R2-35); [label] false drops the tag (Minimal's before and after).
class ProposalEditRow extends StatelessWidget {
  const ProposalEditRow({
    required this.edit,
    required this.times,
    required this.onRemove,
    this.nowRing = false,
    this.label = true,
    super.key,
  });

  final ProposalEdit edit;
  final ProposalTimes times;
  final VoidCallback? onRemove;
  final bool nowRing;
  final bool label;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final dot = edit.shown;
    if (dot == null) return const SizedBox.shrink();
    final inbox = edit.change == ProposalChange.toInbox;
    final leaves = edit.after == null && !inbox;
    final chip = _chipText(context);
    // E-Phones-2: a 64 pt row, the proposed dot, time, title, tag, and a
    // 32 pt outlined × in a 44 pt hit area.
    return MergeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _rowHeight),
        child: Row(
          spacing: DotSpace.m,
          children: [
            if (nowRing) NowRing(dot: dot),
            ProposedDot(dot: inbox ? dot : edit.after ?? dot, leaving: leaves),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: DotSpace.xxs,
                children: [
                  if (!inbox) _TimeLine(edit: edit, times: times),
                  Text(
                    dot.title,
                    style: t.styles.rowTitle.copyWith(
                      color: leaves ? t.colors.secondary : null,
                    ),
                  ),
                  if (label)
                    ProposalChangeChip(
                      text: chip,
                      change: edit.change,
                      color: TaskColor.fromKey(dot.colorKey),
                    ),
                ],
              ),
            ),
            if (onRemove case final remove?)
              IconButton(
                onPressed: remove,
                tooltip: context.l10n.proposalKeep(dot.title),
                constraints: BoxConstraints.tight(
                  const Size.square(DotTouch.min),
                ),
                padding: EdgeInsets.zero,
                icon: Container(
                  width: DotSize.sheetClose,
                  height: DotSize.sheetClose,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: t.colors.hairlineStrong),
                  ),
                  child: Center(
                    child: DotIcon(
                      DotGlyphs.close,
                      color: t.colors.ink2,
                      size: DotSize.sheetCloseGlyph,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static const double _rowHeight = 64;

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
      ProposalChange.toInbox => l10n.proposalToInbox,
      ProposalChange.untouched => l10n.proposalUntouched,
      ProposalChange.overlaps => l10n.proposalOverlaps,
      ProposalChange.steps => l10n.proposalSteps(
        edit.subtasks.where((s) => s.deletedAt == null).length,
      ),
    };
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
      color: t.colors.secondary,
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
      // A pinned task (or an event) the plan works around (E-R2-35).
      if (edit.change == ProposalChange.untouched) ...[
        const WidgetSpan(child: SizedBox(width: DotSpace.xs)),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: DotIcon(
            DotGlyphs.lock,
            color: t.colors.secondary,
            size: DotSize.lockGlyph,
          ),
        ),
      ],
    ];
    return Text.rich(TextSpan(children: spans));
  }
}

/// "☾ Wind Down · 22:00", where the thread ends.
class ProposalWindDownRow extends StatelessWidget {
  const ProposalWindDownRow({
    required this.label,
    this.moon = true,
    this.nowRing = false,
    super.key,
  });

  final String label;

  /// Lines up under a list whose lines lead with a [NowRing].
  final bool nowRing;

  /// The moon glyph; off for the "2 h 15 free" line above it.
  final bool moon;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      spacing: DotSpace.m,
      children: [
        if (nowRing) const SizedBox(width: DotSize.proposalNowRing),
        SizedBox(
          width: ProposedDot.extent,
          child: moon
              ? DotIcon(
                  DotGlyphs.moon,
                  color: t.colors.secondary,
                  size: DotSize.rowIcon,
                )
              : null,
        ),
        // Wraps at large text instead of overflowing (docs/10 §5.4).
        Expanded(
          child: Text(
            label,
            style: t.styles.rowMeta.copyWith(color: t.colors.secondary),
          ),
        ),
      ],
    );
  }
}
