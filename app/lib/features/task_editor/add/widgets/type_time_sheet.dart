import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/shared/time_input/time_input_sheet.dart';
import 'package:flutter/widgets.dart';

/// Time ⋯ › "Type a time" (R-20): the shared time sheet.
Future<ClockTime?> showTypeTimeSheet(
  BuildContext context, {
  required ClockTime initial,
  bool? use24h,
}) => showTimeInputSheet(
  context,
  title: context.l10n.timeMenuType,
  initial: initial,
  use24h: use24h,
);
