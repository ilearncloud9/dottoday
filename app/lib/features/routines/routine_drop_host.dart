import 'dart:async';

import 'package:dottoday/core/editing/pending_routine_drop.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/features/routines/routine_flows.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the proposal for a routine another feature asked to drop (Add ›
/// Suggestions, 11 C2), once, then clears the request. Sits once in the
/// app shell, inside the proposal host.
class RoutineDropHost extends ConsumerWidget {
  const RoutineDropHost({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(pendingRoutineDropProvider, (_, next) {
      if (next == null) return;
      ref.read(pendingRoutineDropProvider.notifier).clear();
      unawaited(
        dropRoutine(
          context,
          next.routine,
          date: next.date,
          today: next.today,
          use24h: ref.read(currentProfileProvider).value?.settings.use24h,
        ),
      );
    });
    return child;
  }
}
