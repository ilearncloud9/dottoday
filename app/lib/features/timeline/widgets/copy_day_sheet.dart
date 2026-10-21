import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/features/timeline/state/day_actions.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/today_month.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Picks the day to copy onto [target] from a month sheet, then copies it
/// with Undo ("Copy a day…", `A-ios-future-month`; 03 §3.1 Duplicate day).
Future<void> showCopyDaySheet(
  BuildContext context, {
  required DateTime target,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final container = ProviderScope.containerOf(context, listen: false);
  final undo = container.read(undoServiceProvider);
  final today = await container.read(todayDateProvider.future);
  if (!context.mounted) return;
  final source = await showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    builder: (sheet) => _Picker(today: today, target: target),
  );
  if (source == null) return;
  final result = await copyDay(
    container,
    source: await occurrencesOn(container, source),
    target: target,
  );
  switch (result) {
    case Ok(value: null):
      messenger.showSnackBar(SnackBar(content: Text(l10n.copyDayNothing)));
    case Ok(value: (:final count, :final token)?):
      showUndoSnackbarOn(
        messenger,
        l10n,
        message: l10n.copyDayDone(count),
        onUndo: () => undo.undo(token),
      );
    case Err(:final failure):
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
  }
}

class _Picker extends StatefulWidget {
  const _Picker({required this.today, required this.target});

  final DateTime today;
  final DateTime target;

  @override
  State<_Picker> createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  late DateTime _month = DateTime(widget.today.year, widget.today.month);

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
            Text(context.l10n.copyDayTitle, style: t.styles.cardTitle),
            TodayMonth(
              month: _month,
              shown: widget.target,
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
