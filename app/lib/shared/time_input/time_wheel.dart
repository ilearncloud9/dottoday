import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Height of the wheel; the iOS picker's natural size.
const double _wheelHeight = 216;

/// Fixed date carried by the wheel. Only hour and minute are read back, so
/// scrolling past midnight can never change a task's day (R-20).
final _anchorDay = DateTime(2000);

/// Opens the optional wheel picker for [initial]; null when dismissed.
Future<ClockTime?> showTimeWheel({
  required BuildContext context,
  required ClockTime initial,
  required bool use24h,
}) {
  return showAppSheet<ClockTime>(
    context: context,
    title: context.l10n.timeInputLabel,
    builder: (_) => _TimeWheel(initial: initial, use24h: use24h),
  );
}

class _TimeWheel extends StatefulWidget {
  const _TimeWheel({required this.initial, required this.use24h});

  final ClockTime initial;
  final bool use24h;

  @override
  State<_TimeWheel> createState() => _TimeWheelState();
}

class _TimeWheelState extends State<_TimeWheel> {
  late ClockTime _picked = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _wheelHeight,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            use24hFormat: widget.use24h,
            initialDateTime: _anchorDay.add(
              Duration(minutes: widget.initial.minutesOfDay),
            ),
            onDateTimeChanged: (d) =>
                setState(() => _picked = ClockTime(d.hour, d.minute)),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_picked),
          child: Text(context.l10n.timeInputDone),
        ),
      ],
    );
  }
}
