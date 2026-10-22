import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/time_input/time_input.dart';
import 'package:flutter/material.dart';

/// The shared `TimeInput` in a sheet with Done (R-20): Add's "Type a
/// time", Settings › Wake Up / Bedtime. Returns the time, or null.
Future<ClockTime?> showTimeInputSheet(
  BuildContext context, {
  required String title,
  required ClockTime initial,
  bool? use24h,
}) => showAppSheet<ClockTime>(
  context: context,
  title: title,
  builder: (_) => _TimeSheet(initial: initial, use24h: use24h),
);

class _TimeSheet extends StatefulWidget {
  const _TimeSheet({required this.initial, required this.use24h});

  final ClockTime initial;
  final bool? use24h;

  @override
  State<_TimeSheet> createState() => _TimeSheetState();
}

/// A leaf: the time being typed.
class _TimeSheetState extends State<_TimeSheet> {
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
