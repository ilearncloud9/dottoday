import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_routine_drop.g.dart';

/// A routine to propose on [date] (11 C2, docs/09 M11.4), asked for by a
/// feature that doesn't own routines (Add › Suggestions).
@immutable
final class RoutineDropRequest {
  const RoutineDropRequest({
    required this.routine,
    required this.date,
    this.today,
  });

  final Routine routine;

  /// The local day (y/m/d) the steps land on.
  final DateTime date;
  final DateTime? today;
}

/// The routine drop waiting for the host in the app shell, which opens
/// its proposal and clears it (as `ActiveProposal`).
@Riverpod(keepAlive: true)
class PendingRoutineDrop extends _$PendingRoutineDrop {
  // The routine is the previous owner's after a switch (CR-160 I5).
  @override
  RoutineDropRequest? build() {
    ref.watch(ownerEpochProvider);
    return null;
  }

  void request(RoutineDropRequest value) => state = value;

  void clear() => state = null;
}
