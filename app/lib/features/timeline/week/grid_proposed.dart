import 'package:dottoday/core/editing/active_proposal.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/week/grid_scale.dart';
import 'package:dottoday/shared/dot/thread_pieces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// A task the open proposal would put on a day: where, how long, what.
typedef GridProposed = ({
  DateTime startUtc,
  int minutes,
  String title,
  bool added,
});

/// The open proposal's tasks that would land on [date] in [zone] (R2-3
/// 1c, 2c; owner, M19.3 part 3d: on every Workspace): drawn dashed on the
/// hour grid while the proposal shows beside it. Nothing is written; they
/// go with the proposal.
List<GridProposed> gridProposedOn(
  WidgetRef ref,
  DateTime date,
  tz.Location zone,
) {
  final request = ref.watch(activeProposalProvider);
  if (request == null) return const [];
  return [
    for (final (:row, :added) in request.proposal.placements)
      if (tz.TZDateTime.from(row.startUtc!, zone) case final local
          when DateTime(local.year, local.month, local.day) == date)
        (
          startUtc: row.startUtc!,
          minutes: row.durationMin,
          title: row.title,
          added: added,
        ),
  ];
}

/// [proposed] as dashed blocks in a day column (E-R2-3): the accent's
/// dashed edge over the drop tint, an empty dashed ring where the dot
/// would be, the title, and "new" on an added one. Not tappable: the
/// proposal beside the grid is where they are changed.
List<Widget> gridProposedBlocks(
  BuildContext context, {
  required List<GridProposed> proposed,
  required double Function(DateTime utc) y,
}) {
  final t = DotTheme.of(context);
  final c = t.colors;
  final scale = GridScale.of(context);
  return [
    for (final p in proposed)
      Positioned(
        left: DotSize.gridInset,
        right: DotSize.gridInset,
        top: y(p.startUtc),
        height: (p.minutes * scale.pxPerMinute).clamp(
          scale.minCard,
          double.infinity,
        ),
        child: IgnorePointer(
          child: CustomPaint(
            foregroundPainter: DashedPillPainter(
              color: c.accent,
              radius: DotRadii.block,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.gridDrop,
                borderRadius: BorderRadius.circular(DotRadii.block),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: scale.blockPad,
                  vertical: DotSpace.xxs,
                ),
                child: Row(
                  spacing: DotSpace.s,
                  children: [
                    SizedBox.square(
                      dimension: DotSize.gridProposedRing,
                      child: CustomPaint(
                        painter: DashedPillPainter(color: c.accent),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        p.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: scale.pill(t.styles).copyWith(color: c.text),
                      ),
                    ),
                    if (p.added) _NewTag(scale: scale),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
  ];
}

class _NewTag extends StatelessWidget {
  const _NewTag({required this.scale});

  final GridScale scale;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.accentTint,
        borderRadius: BorderRadius.circular(DotRadii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
        child: Text(
          context.l10n.proposalAdded,
          style: scale.pill(t.styles).copyWith(color: t.colors.accentText),
        ),
      ),
    );
  }
}
