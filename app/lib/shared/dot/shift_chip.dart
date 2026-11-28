import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "Shift later tasks" — shown at the top of the day, under the week
/// strip and at its start, while a task is dragged (docs/03 §3.2, R-04,
/// E-R2-25 §1). A second finger (or a click) toggles it;
/// on, the tasks after the dropped one move along. Selection reads as a
/// check mark, not colour alone.
///
/// With [calendar] given, a second chip, "Calendar events too", sits beside
/// it while the first is on: the calendar events among the later tasks move
/// along as well (Settings › Calendars sets where it starts, docs/09 M7.6).
class ShiftChip extends StatelessWidget {
  const ShiftChip({required this.on, this.calendar, this.area, super.key});

  final ValueNotifier<bool> on;

  /// The day's visible area, in the overlay's coordinates; null puts the
  /// chips at the top of the screen.
  final Rect? area;

  /// "Calendar events too"; null hides it (no event a shift could carry).
  final ValueNotifier<bool>? calendar;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final calendar = this.calendar;
    final area = this.area;
    return Positioned(
      top: (area?.top ?? padding.top) + DotSpace.s,
      left: (area?.left ?? 0) + DotSpace.page,
      width:
          (area?.width ?? MediaQuery.sizeOf(context).width) - 2 * DotSpace.page,
      // It sits on the root overlay, outside any page's Material.
      child: Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: area == null
              ? Alignment.center
              : AlignmentDirectional.centerStart,
          child: ValueListenableBuilder<bool>(
            valueListenable: on,
            // A Wrap: at large text sizes the second chip goes below.
            builder: (context, value, _) => Wrap(
              alignment: area == null
                  ? WrapAlignment.center
                  : WrapAlignment.start,
              spacing: DotSpace.s,
              runSpacing: DotSpace.s,
              children: [
                _Chip(
                  label: context.l10n.shiftChipLabel,
                  value: value,
                  onChanged: (v) => on.value = v,
                ),
                if (value && calendar != null)
                  ValueListenableBuilder<bool>(
                    valueListenable: calendar,
                    builder: (context, v, _) => _Chip(
                      label: context.l10n.shiftChipCalendar,
                      value: v,
                      onChanged: (v) => calendar.value = v,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One floating toggle chip.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = DotTheme.of(context).colors;
    // Off on the card colour, on in the accent tint with ✓ (E-R2-25 §1):
    // full-contrast words either way, so off reads as a choice.
    return DecoratedBox(
      decoration: const ShapeDecoration(
        shape: StadiumBorder(),
        shadows: DotElevation.floating,
      ),
      child: FilterChip(
        label: Text(label),
        labelStyle: TextStyle(color: value ? colors.accentText : colors.ink),
        selected: value,
        onSelected: onChanged,
        color: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Color.alphaBlend(colors.tonal, colors.card)
              : colors.card,
        ),
        checkmarkColor: colors.accentText,
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),
    );
  }
}
