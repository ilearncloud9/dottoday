import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "Shift later tasks" — shown at the top of the screen while a task is
/// dragged (docs/03 §3.2, R-04). A second finger (or a click) toggles it;
/// on, the tasks after the dropped one move along. Selection reads as a
/// check mark, not colour alone.
///
/// With [calendar] given, a second chip, "Calendar events too", sits beside
/// it while the first is on: the calendar events among the later tasks move
/// along as well (Settings › Calendars sets where it starts, docs/09 M7.6).
class ShiftChip extends StatelessWidget {
  const ShiftChip({required this.on, this.calendar, super.key});

  final ValueNotifier<bool> on;

  /// "Calendar events too"; null hides it (no event a shift could carry).
  final ValueNotifier<bool>? calendar;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final calendar = this.calendar;
    return Positioned(
      top: padding.top + DotSpace.s,
      left: DotSpace.page,
      right: DotSpace.page,
      // It sits on the root overlay, outside any page's Material.
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: ValueListenableBuilder<bool>(
            valueListenable: on,
            // A Wrap: at large text sizes the second chip goes below.
            builder: (context, value, _) => Wrap(
              alignment: WrapAlignment.center,
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
    return DecoratedBox(
      decoration: const ShapeDecoration(
        shape: StadiumBorder(),
        shadows: DotElevation.floating,
      ),
      child: FilterChip(
        label: Text(label),
        // Off is a choice, not disabled: full-contrast text.
        labelStyle: value ? null : TextStyle(color: colors.text),
        selected: value,
        onSelected: onChanged,
        backgroundColor: colors.raised,
        shape: const StadiumBorder(),
      ),
    );
  }
}
