import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// "Shift later tasks" — shown at the top of the screen while a task is
/// dragged (docs/03 §3.2, R-04). A second finger (or a click) toggles it;
/// on, the tasks after the dropped one move along. Selection reads as a
/// check mark, not colour alone.
class ShiftChip extends StatelessWidget {
  const ShiftChip({required this.on, super.key});

  final ValueNotifier<bool> on;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
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
            builder: (context, value, _) => DecoratedBox(
              decoration: const ShapeDecoration(
                shape: StadiumBorder(),
                shadows: DotElevation.floating,
              ),
              child: FilterChip(
                label: Text(context.l10n.shiftChipLabel),
                // Off is a choice, not disabled: full-contrast text.
                labelStyle: value
                    ? null
                    : TextStyle(color: DotTheme.of(context).colors.text),
                selected: value,
                onSelected: (v) => on.value = v,
                backgroundColor: DotTheme.of(context).colors.raised,
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
