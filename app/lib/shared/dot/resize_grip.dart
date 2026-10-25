import 'dart:async';

import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The grip at the end of a task's segment: drag down for longer, up for
/// shorter, one [DotTouch.resizeStep] per snap step (R-05).
class ResizeGrip extends StatefulWidget {
  const ResizeGrip({required this.onSteps, required this.label, super.key});

  final ValueChanged<int> onSteps;

  /// Screen-reader name ("Change length").
  final String label;

  @override
  State<ResizeGrip> createState() => _ResizeGripState();
}

class _ResizeGripState extends State<ResizeGrip> {
  double _dy = 0;
  int _steps = 0;

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    // Screen readers adjust the length with increase / decrease (R-12).
    return Semantics(
      label: widget.label,
      onIncrease: () => widget.onSteps(1),
      onDecrease: () => widget.onSteps(-1),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // Count from touch-down, so the slop isn't lost from the length.
          dragStartBehavior: DragStartBehavior.down,
          onVerticalDragStart: (_) => setState(() => _dy = 0),
          onVerticalDragUpdate: (d) {
            _dy += d.delta.dy;
            final steps = (_dy / DotTouch.resizeStep).round();
            if (steps != _steps) {
              unawaited(HapticFeedback.selectionClick());
              setState(() => _steps = steps);
            }
          },
          onVerticalDragEnd: (_) {
            if (_steps != 0) widget.onSteps(_steps);
            setState(() => _steps = 0);
          },
          child: SizedBox(
            width: DotTouch.min,
            height: DotTouch.min / 2,
            child: Center(
              child: Container(
                width: DotSize.weekDot * 2,
                height: DotSize.freeLine * 2,
                decoration: BoxDecoration(
                  color: _steps == 0 ? c.hairline : c.accent,
                  borderRadius: BorderRadius.circular(DotRadii.pill),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
