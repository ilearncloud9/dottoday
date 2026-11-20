import 'package:dottoday/core/editing/editing_task.dart';
import 'package:dottoday/core/theme/dot_idiom.dart';
import 'package:dottoday/data/layout/day_column_prefs.dart';
import 'package:dottoday/features/timeline/now/now_inputs.dart';
import 'package:dottoday/features/timeline/now/wide/day_column.dart';
import 'package:dottoday/features/timeline/now/wide/now_pane.dart';
import 'package:dottoday/features/timeline/now/wide/now_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal's Now on the Mac and the web (E-Minimal frames 1 and 2,
/// ED-068, ED-232; M19.6 part 6c): the Now pane takes the room the
/// sidebar and the 290 Day column leave. The Mac adds its toolbar over
/// both; the web puts the date in the pane. Only the chrome differs.
class NowWide extends ConsumerWidget {
  const NowWide({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = NowInputs.watch(context, ref);
    if (n == null) return const Scaffold();
    final mac = macApp(context);
    // A task opened from the pane (Open on a dot) brings the column out
    // for it, even when the person put the Day away (ED-089).
    final hidden =
        (ref.watch(dayColumnHiddenProvider).value ?? false) &&
        ref.watch(editingTaskProvider) == null;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mac) NowToolbar(inputs: n),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: NowPane(inputs: n, mac: mac, dayHidden: hidden),
                ),
                if (!hidden) DayColumn(today: n.today),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
