import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:dottoday/features/timeline/widgets/selection_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [child] with multi-select around it (docs/03 §3.2, R-05; E-R2-6): the
/// selection bar at the bottom while tasks are picked, centred; Back ends
/// selecting before it leaves the screen; the count is announced as it
/// changes (R-12). Today and Week each wear one.
class SelectionLayer extends ConsumerWidget {
  const SelectionLayer({required this.today, required this.child, super.key});

  final DateTime today;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      taskSelectionProvider,
      (before, now) => announceSelection(context, before, now),
    );
    final selecting = ref.watch(
      taskSelectionProvider.select((p) => !p.isEmpty),
    );
    return PopScope(
      canPop: !selecting,
      onPopInvokedWithResult: (popped, _) {
        if (!popped) ref.read(taskSelectionProvider.notifier).clear();
      },
      child: Stack(
        children: [
          child,
          if (selecting)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(top: false, child: SelectionBar(today: today)),
            ),
        ],
      ),
    );
  }
}
