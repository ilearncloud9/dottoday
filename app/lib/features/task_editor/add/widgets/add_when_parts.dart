import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/scheduling/slot_fit.dart';
import 'package:dottoday/shared/dot/overlap_knot.dart';
import 'package:flutter/material.dart';

/// A caption with an optional trailing control ("TIME ⋯", "DURATION ⋯").
class AddCaption extends StatelessWidget {
  const AddCaption(this.text, {this.trailing, super.key});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(text.toUpperCase(), style: t.styles.caption),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// "Lands on **Today** at 5:00 – 6:00 PM · the slot is free".
class LandsOn extends StatelessWidget {
  const LandsOn({
    required this.colour,
    required this.day,
    required this.range,
    required this.fit,
    this.onEdit,
    this.allDay = false,
    super.key,
  });

  /// "Lands on Today · all day": no time, no slot.
  final bool allDay;

  final TaskColor colour;
  final VoidCallback? onEdit;
  final String day;
  final String range;
  final SlotFit fit;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final suffix = fit.isFree
        ? l10n.addSlotFree
        : l10n.addSlotBusy(fit.overlaps.first.title);
    final full = allDay
        ? l10n.addLandsOnAllDay(day)
        : l10n.alertJoin(l10n.addLandsOn(day, range), suffix);
    final style = t.styles.body.copyWith(color: t.colors.muted);
    return Container(
      padding: const EdgeInsets.all(DotSpace.l),
      decoration: BoxDecoration(
        color: t.colors.surface,
        borderRadius: BorderRadius.circular(DotRadii.card),
        border: Border.all(color: t.colors.outline),
      ),
      child: Row(
        spacing: DotSpace.m,
        children: [
          // The task's colour bar; on a busy slot, the knot with the
          // task it would share time with (ADR-0015).
          if (fit.overlaps.firstOrNull case final busy?)
            OverlapKnot(
              first: t.tasks[colour].color,
              second: t.tasks[TaskColor.fromKey(busy.colorKey)].color,
            )
          else
            Container(
              width: DotSize.segment,
              height: DotSpace.xl,
              decoration: BoxDecoration(
                color: t.tasks[colour].color,
                borderRadius: BorderRadius.circular(DotRadii.pill),
              ),
            ),
          Expanded(child: _sentence(t, full, style)),
          if (onEdit case final edit?)
            TextButton(onPressed: edit, child: Text(l10n.addLandsOnEdit)),
        ],
      ),
    );
  }

  /// [full] with the day in bold.
  Widget _sentence(DotTheme t, String full, TextStyle style) {
    final at = full.indexOf(day);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          if (at < 0)
            TextSpan(text: full)
          else ...[
            TextSpan(text: full.substring(0, at)),
            TextSpan(
              text: day,
              style: TextStyle(
                color: t.colors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: full.substring(at + day.length)),
          ],
        ],
      ),
    );
  }
}
