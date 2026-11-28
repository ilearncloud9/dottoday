import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/proposals/proposal_edit_row.dart';
import 'package:dottoday/shared/proposals/proposed_dot.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

/// The proposal's change list (E-Phones-2, ED-150): "○ now ◌ proposed",
/// then each proposed dot in its dashed ring, the times (old ones
/// struck), the title, a tag saying what changes, and × to keep that dot
/// as it is. Ends at
/// Wind Down. The default body of `ProposalSheet`.
class ProposalThreadList extends StatelessWidget {
  const ProposalThreadList({
    required this.proposal,
    required this.location,
    required this.use24h,
    required this.today,
    required this.onRemove,
    this.nowRings = false,
    this.labels = true,
    super.key,
  });

  final Proposal proposal;
  final tz.Location location;
  final bool use24h;

  /// Today's local date (y/m/d), for "moved to tomorrow 9:00".
  final DateTime today;

  /// × on a removable line, with its [ProposalEdit.id]; null: no ×.
  final ValueChanged<String>? onRemove;

  /// Each line's faded ring for the day as it is (E-R2-35).
  final bool nowRings;

  /// False drops the tags: before and after only (Minimal, docs/14 C1).
  final bool labels;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final edits = proposal.edits;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        const _Legend(),
        if (edits.isEmpty)
          Text(l10n.proposalNothing, style: t.styles.body)
        else
          for (final e in edits)
            ProposalEditRow(
              key: ValueKey(e.id),
              edit: e,
              times: _Times(context, location, use24h, today),
              onRemove: switch (onRemove) {
                final remove? when e.removable => () => remove(e.id),
                _ => null,
              },
              nowRing: nowRings,
              label: labels,
            ),
        if (_freeMinutes(proposal) case final free when free > 0)
          ProposalWindDownRow(
            label: l10n.threadFree(formatDurationShort(l10n, free)),
            moon: false,
            nowRing: nowRings,
          ),
        ProposalWindDownRow(
          nowRing: nowRings,
          label: l10n.threadBed(
            timeOfUtc(
              context,
              location,
              proposal.before.bedUtc,
              use24h: use24h,
            ),
          ),
        ),
      ],
    );
  }
}

/// What the proposed day leaves free from its last dot (or from now) to
/// Wind Down ("2 h 15 free", `B-ios-rebalance`); 0 for a proposal about one
/// task (Break it down), whose snapshot has no day around it.
int _freeMinutes(Proposal proposal) {
  final after = proposal.after;
  var from = after.generatedAtUtc;
  for (final d in after.dots) {
    if (d.endUtc.isAfter(from) && d.startUtc.isBefore(after.bedUtc)) {
      from = d.endUtc;
    }
  }
  return after.bedUtc.difference(from).inMinutes;
}

/// Clock and day texts for the rows.
final class _Times implements ProposalTimes {
  const _Times(this.context, this.location, this.use24h, this.today);

  final BuildContext context;
  final tz.Location location;
  final bool use24h;
  final DateTime today;

  @override
  String at(DateTime utc) => timeOfUtc(context, location, utc, use24h: use24h);

  @override
  String range(SnapshotDot d) =>
      context.l10n.threadTimeRange(at(d.startUtc), at(d.endUtc));

  /// "Tomorrow 9:00".
  @override
  String day(DateTime utc) {
    final date = tz.TZDateTime.from(utc, location);
    final name = relativeDayName(
      context,
      DateTime(date.year, date.month, date.day),
      today,
    );
    return context.l10n.proposalDayTime(name, at(utc));
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final style = t.styles.rowMeta.copyWith(color: t.colors.secondary);
    Widget ring(Color color, double width) => Container(
      width: DotSize.weekDot + DotSpace.xs,
      height: DotSize.weekDot + DotSpace.xs,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: width),
      ),
    );
    return ExcludeSemantics(
      child: Wrap(
        spacing: DotSpace.m,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: DotSpace.xs,
            children: [
              ring(t.colors.secondary, DotSize.smallDotOutline),
              Text(l10n.proposalLegendNow, style: style),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: DotSpace.xs,
            children: [
              SizedBox.square(
                dimension: DotSize.weekDot + DotSpace.xs,
                child: CustomPaint(painter: DashedRingPainter(t.colors.accent)),
              ),
              Text(l10n.proposalLegendProposed, style: style),
            ],
          ),
        ],
      ),
    );
  }
}
