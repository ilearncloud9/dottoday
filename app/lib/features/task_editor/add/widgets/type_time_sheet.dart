import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';

/// Time ⋯ › "Type a time" (R-20): the shared `TimeInput` and Done.
Future<ClockTime?> showTypeTimeSheet(
  BuildContext context, {
  required ClockTime initial,
  bool? use24h,
}) => showAppSheet<ClockTime>(
  context: context,
  title: context.l10n.timeMenuType,
  builder: (_) => _TypeTime(initial: initial, use24h: use24h),
);

class _TypeTime extends StatefulWidget {
  const _TypeTime({required this.initial, required this.use24h});

  final ClockTime initial;
  final bool? use24h;

  @override
  State<_TypeTime> createState() => _TypeTimeState();
}

/// A leaf: the time being typed.
class _TypeTimeState extends State<_TypeTime> {
  late ClockTime _time = widget.initial;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: DotSpace.l,
    children: [
      TimeInput(
        value: _time,
        use24h: widget.use24h,
        onChanged: (t) => setState(() => _time = t),
      ),
      FilledButton(
        onPressed: () => Navigator.of(context).pop(_time),
        child: Text(context.l10n.timeInputDone),
      ),
    ],
  );
}
