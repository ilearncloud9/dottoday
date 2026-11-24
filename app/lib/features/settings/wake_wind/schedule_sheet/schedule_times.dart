import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/features/settings/widgets/day_shape_group.dart';
import 'package:dottoday/shared/dot/night_dial.dart';
import 'package:dottoday/shared/time_input/time_input_sheet.dart';
import 'package:dottoday/shared/time_input/time_wheel.dart';
import 'package:flutter/material.dart';

/// Wind Down and Wake Up as two fields under the dial (E-Phones Edit
/// Weekdays): on iPhone cards with the moon or sun and the time, the
/// selected one outlined; on Android outlined fields with the label
/// above. A tap selects it and opens the platform's time entry: typing on
/// Apple devices, Material's time picker on Android and the web
/// ("Tap a field for the M3 time picker"). Stacked at large text.
class ScheduleTimes extends StatelessWidget {
  const ScheduleTimes({
    required this.windDown,
    required this.wake,
    required this.selected,
    required this.use24h,
    required this.onSelect,
    required this.onChanged,
    super.key,
  });

  final int windDown;
  final int wake;
  final DialEnd selected;
  final bool? use24h;
  final ValueChanged<DialEnd> onSelect;
  final void Function(DialEnd end, int minute) onChanged;

  Future<void> _pick(BuildContext context, DialEnd end) async {
    onSelect(end);
    final l10n = context.l10n;
    final initial = ClockTime.fromMinutes(
      end == DialEnd.windDown ? windDown : wake,
    );
    final picked = appleChrome(context)
        ? await showTimeInputSheet(
            context,
            title: end == DialEnd.windDown
                ? l10n.settingsWindDown
                : l10n.settingsWakeUp,
            initial: initial,
            use24h: use24h,
          )
        : await showTimeWheel(
            context: context,
            initial: initial,
            use24h: use24h ?? MediaQuery.alwaysUse24HourFormatOf(context),
          );
    if (picked != null) onChanged(end, picked.hour * 60 + picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    final stacked =
        MediaQuery.textScalerOf(context).scale(1) >= DotDial.belowFromScale;
    final fields = [
      for (final end in DialEnd.values)
        _Field(
          end: end,
          time: clockText(
            context,
            end == DialEnd.windDown ? windDown : wake,
            use24h,
          ),
          selected: selected == end,
          onTap: () => unawaited(_pick(context, end)),
        ),
    ];
    if (stacked) {
      return Column(spacing: DotSpace.s, children: fields);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: DotSpace.s,
      children: [for (final f in fields) Expanded(child: f)],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.end,
    required this.time,
    required this.selected,
    required this.onTap,
  });

  final DialEnd end;
  final String time;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final label = end == DialEnd.windDown
        ? l10n.settingsWindDown
        : l10n.settingsWakeUp;
    final c =
        t.tasks[end == DialEnd.windDown ? TaskColor.violet : TaskColor.amber];
    final ios = DotIdiom.of(context) == DotIdiom.cupertino;
    final tile = Container(
      width: DotSize.rowDot,
      height: DotSize.rowDot,
      decoration: BoxDecoration(color: c.tint, shape: BoxShape.circle),
      child: Center(
        child: DotIcon(
          end == DialEnd.windDown ? DotGlyphs.moon : DotGlyphs.sun,
          color: c.ink,
          size: DotSize.rowIcon,
        ),
      ),
    );
    final border = BorderSide(
      color: selected ? t.colors.accentInk : t.colors.outline,
      width: selected ? DotSize.smallDotOutline : DotSpace.hairline,
    );
    final box = Material(
      color: ios && selected ? t.colors.tonal : t.colors.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ios ? DotRadii.card : DotRadii.field,
        ),
        side: border,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.m),
            child: Row(
              spacing: DotSpace.m,
              children: [
                tile,
                Expanded(
                  child: ios
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: t.styles.rowMeta),
                            Text(time, style: t.styles.promptTitle),
                          ],
                        )
                      : Text(time, style: t.styles.rowTitle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      value: time,
      onTap: onTap,
      excludeSemantics: true,
      child: ios
          ? box
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: DotSpace.xs,
              children: [
                Text(
                  label,
                  style: t.styles.rowMeta.copyWith(
                    color: selected ? t.colors.accentInk : t.colors.text,
                  ),
                ),
                box,
              ],
            ),
    );
  }
}
