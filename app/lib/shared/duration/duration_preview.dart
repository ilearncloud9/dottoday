import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/scheduling/slot_fit.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';

/// What the Duration sheet shows about a length, in display values:
/// "5:00 PM", "6:30 PM", "Still fits before Spanish review at 7:30", and
/// how much of the free room the task fills (0–1; 1 when it runs over).
typedef DurationPreview = ({
  String start,
  String end,
  String note,
  double fill,
});

/// The preview of [minutes] from [startUtc] in [room]: where it ends and
/// whether it fits before the next task or Bedtime ([ignoreId] is the task
/// itself, when it is already on the day).
DurationPreview durationPreview(
  BuildContext context,
  DayRoom room,
  DateTime startUtc,
  int minutes,
  DayTimeText text, {
  String? ignoreId,
}) {
  final l10n = context.l10n;
  final fit = fitAt(
    room.blocks,
    startUtc,
    minutes,
    dayEndUtc: room.endUtc,
    ignoreId: ignoreId,
  );
  final end = startUtc.add(Duration(minutes: minutes));
  final room0 = fit.freeUntilUtc.difference(startUtc).inMinutes;
  final next = fit.next;
  final busy = fit.overlaps.firstOrNull;
  final note = switch ((busy, next)) {
    (final b?, _) => l10n.durationRunsInto(b.title, text.utc(b.startUtc!)),
    (null, final n?) => l10n.durationFitsBefore(n.title, text.utc(n.startUtc!)),
    _ when end.isAfter(room.endUtc) => l10n.durationPastBedtime(
      text.utc(room.endUtc),
    ),
    _ => l10n.durationFitsBedtime(text.utc(room.endUtc)),
  };
  return (
    start: text.utc(startUtc),
    end: text.utc(end),
    note: note,
    fill: busy != null || room0 <= 0 ? 1 : minutes / room0,
  );
}

/// The live segment preview (`A-ios-add-duration`): the task's dot and
/// segment across its share of the free room, the rest dotted; start,
/// "ends …" in the task's colour, and the note.
class DurationPreviewBar extends StatelessWidget {
  const DurationPreviewBar({
    required this.preview,
    required this.color,
    required this.icon,
    super.key,
  });

  final DurationPreview preview;
  final TaskColor color;
  final TaskIcon icon;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final swatch = t.tasks[color];
    final ends = context.l10n.durationEnds(preview.end);
    return Semantics(
      liveRegion: true,
      label: context.l10n.alertJoin(ends, preview.note),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.xs,
        children: [
          _bar(t, swatch),
          Row(
            children: [
              Expanded(
                child: Text(
                  preview.start,
                  style: t.styles.rowMeta.copyWith(
                    color: t.colors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                ends,
                style: t.styles.rowMeta.copyWith(
                  color: swatch.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(preview.note, style: t.styles.body),
        ],
      ),
    );
  }

  Widget _bar(DotTheme t, TaskSwatch swatch) => SizedBox(
    height: DotSize.macRowDot,
    child: LayoutBuilder(
      builder: (context, box) {
        final span = box.maxWidth - DotSize.macRowDot / 2;
        final fill = preview.fill.clamp(0.0, 1.0);
        return Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            // Spans the row; otherwise the stack shrinks to the dot.
            const SizedBox.expand(),
            PositionedDirectional(
              start: DotSize.macRowDot / 2,
              end: 0,
              child: CustomPaint(
                size: const Size.fromHeight(DotSize.freeLine),
                painter: _DottedLine(t.colors.hairline),
              ),
            ),
            PositionedDirectional(
              start: DotSize.macRowDot / 2,
              width: span * fill,
              child: Container(
                height: DotSize.segment,
                decoration: BoxDecoration(
                  color: swatch.color,
                  borderRadius: BorderRadius.circular(DotRadii.pill),
                ),
              ),
            ),
            // Solid with its icon (`A-ios-add-duration`), not the done
            // check: this is the task to be, not a finished one.
            Container(
              width: DotSize.macRowDot,
              height: DotSize.macRowDot,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: swatch.color,
              ),
              child: icon.glyph == null
                  ? null
                  : Center(
                      child: DotIcon(
                        icon.glyph!,
                        color: t.colors.raised,
                        size: DotSize.rowIcon - DotSpace.xs,
                      ),
                    ),
            ),
          ],
        );
      },
    ),
  );
}

/// The 2 px dotted free line, horizontal.
final class _DottedLine extends CustomPainter {
  const _DottedLine(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const step = DotSize.freeLine * 2.5;
    for (var x = step / 2; x < size.width; x += step) {
      canvas.drawCircle(
        Offset(x, size.height / 2),
        DotSize.freeLine / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DottedLine old) => old.color != color;
}
