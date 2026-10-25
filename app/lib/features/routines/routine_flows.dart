import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/time/clock_time.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/features/routines/state/routine_drop.dart';
import 'package:dottoday/features/routines/state/routines_state.dart';
import 'package:dottoday/features/routines/widgets/routine_editor.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the editor for [routine], or a blank one for "New routine"; Save
/// and Delete write with Undo (11 C2, docs/09 M11.4).
Future<void> editRoutine(BuildContext context, {Routine? routine}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final profile = await container.read(currentProfileProvider.future);
  if (!context.mounted) return;
  final initial =
      routine ??
      blankRoutine(
        userId: profile.id,
        nowUtc: container.read(clockProvider).nowUtc(),
      );
  void report(Result<UndoToken, AppFailure> r, String message) =>
      _report(messenger, l10n, container, r, message);
  await showAppSheet<void>(
    context: context,
    title: routine == null ? l10n.routineNew : l10n.routineEditTitle,
    builder: (sheet) => RoutineEditor(
      initial: initial,
      use24h: profile.settings.use24h,
      onSave: (r) {
        Navigator.of(sheet).pop();
        unawaited(
          saveRoutine(
            container,
            r,
          ).then((res) => report(res, l10n.routineSaved(r.title.trim()))),
        );
      },
      onDelete: routine == null
          ? null
          : () {
              Navigator.of(sheet).pop();
              unawaited(
                deleteRoutine(container, routine).then(
                  (res) => report(res, l10n.routineDeleted(routine.title)),
                ),
              );
            },
    ),
  );
}

/// Proposes [routine]'s steps on [date] ("Drop on today", the week strip,
/// the Inbox, Add › Suggestions).
Future<void> dropRoutine(
  BuildContext context,
  Routine routine, {
  required DateTime date,
  DateTime? today,
  bool? use24h,
}) {
  final material = MaterialLocalizations.of(context);
  final always24h = use24hFor(context, use24h);
  return openRoutineDrop(
    ProviderScope.containerOf(context, listen: false),
    context.l10n,
    routine,
    date: date,
    dayName: relativeDayName(context, date, today),
    time: (zone, utc) {
      final t = ClockTime.ofUtc(zone, utc);
      return material.formatTimeOfDay(
        TimeOfDay(hour: t.hour, minute: t.minute),
        alwaysUse24HourFormat: always24h,
      );
    },
  );
}

void _report(
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  ProviderContainer container,
  Result<UndoToken, AppFailure> result,
  String message,
) {
  switch (result) {
    case Ok(:final value):
      showUndoSnackbarOn(
        messenger,
        l10n,
        message: message,
        onUndo: () =>
            unawaited(container.read(undoServiceProvider).undo(value)),
      );
    case Err(:final failure):
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
  }
}
