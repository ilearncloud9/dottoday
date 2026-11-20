import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/foundation.dart';

/// One task on the [DayHorizon]: where it starts and ends, its colour and
/// its state (done filled, under way and ahead as rings).
@immutable
final class HorizonDot {
  const HorizonDot({
    required this.startUtc,
    required this.endUtc,
    required this.color,
    required this.state,
  });

  final DateTime startUtc;
  final DateTime endUtc;
  final TaskColor color;
  final DotState state;
}

/// The horizon's four labels, as shown.
typedef HorizonLabels = ({
  String wake,
  String now,
  String mid,
  DateTime midUtc,
  String windDown,
});
