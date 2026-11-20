import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_idiom.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Height of the wheel; the iOS picker's natural size.
const double _wheelHeight = 216;

/// Fixed date carried by the wheel. Only hour and minute are read back, so
/// scrolling past midnight can never change a task's day (R-20).
final _anchorDay = DateTime(2000);

/// Opens the platform's own time picker for [initial] (owner, native
/// pass): iOS's wheel on iPhone and iPad; Material 3's time picker on
/// Android and the web (E-R2-4 "M3 time picker"). The Mac types times and
/// offers no picker. Null when dismissed.
Future<ClockTime?> showTimeWheel({
  required BuildContext context,
  required ClockTime initial,
  required bool use24h,
}) async {
  if (!iosApp(context)) {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24h),
        child: child!,
      ),
    );
    return picked == null ? null : ClockTime(picked.hour, picked.minute);
  }
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
