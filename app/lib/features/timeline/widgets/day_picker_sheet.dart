import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/widgets/today_month.dart';
import 'package:flutter/material.dart';

/// A month in a sheet to pick one day (docs/10 §5.3 "Change day picker";
/// also "Copy a day…"). Returns the picked local date, or null.
Future<DateTime?> showDayPicker(
  BuildContext context, {
  required String title,
  required DateTime today,
  required DateTime initial,
}) => showModalBottomSheet<DateTime>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _DayPicker(title: title, today: today, initial: initial),
);

class _DayPicker extends StatefulWidget {
  const _DayPicker({
    required this.title,
    required this.today,
    required this.initial,
  });

  final String title;
  final DateTime today;
  final DateTime initial;

  @override
  State<_DayPicker> createState() => _DayPickerState();
}

class _DayPickerState extends State<_DayPicker> {
  late DateTime _month = DateTime(widget.initial.year, widget.initial.month);

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: DotSpace.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: DotSpace.s,
          children: [
            Text(widget.title, style: t.styles.cardTitle),
            TodayMonth(
              month: _month,
              shown: widget.initial,
              today: widget.today,
              onMonth: (m) => setState(() => _month = m),
              onSelect: (d) => Navigator.of(context).pop(d),
            ),
          ],
        ),
      ),
    );
  }
}
