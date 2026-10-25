import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/schedule/planned_colors.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/state/selection_actions.dart';
import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/pickers/day_pickers.dart';
import 'package:dottoday/shared/selection/selection_bar_frame.dart';
import 'package:dottoday/shared/sheets/text_prompt_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// What the selection bar's buttons do: ask what is needed, write one
/// undoable batch, end selecting and confirm with Undo (R-05, R-11).
final class SelectionCommands {
  SelectionCommands({
    required BuildContext context,
    required this.container,
    required this.rows,
    required this.today,
    required this.day,
  }) : _context = context,
       _messenger = ScaffoldMessenger.of(context),
       _l10n = context.l10n;

  final BuildContext _context;
  final ScaffoldMessengerState _messenger;
  final AppLocalizations _l10n;
  final ProviderContainer container;
  final List<Occurrence> rows;
  final DateTime today;
  final DateTime day;

  UndoService get _undo => container.read(undoServiceProvider);

  void _finish(Future<Result<UndoToken, AppFailure>> write, String message) {
    container.read(taskSelectionProvider.notifier).clear();
    final undo = _undo;
    unawaited(
      write.then(
        (result) => reportUndoable(
          _messenger,
          _l10n,
          undo,
          result,
          message: (_) => message,
          tokenOf: (t) => t,
        ),
      ),
    );
  }

  VoidCallback? get move => rows.isEmpty
      ? null
      : () => unawaited(() async {
          final to = await showMonthDayPicker(
            _context,
            plannedFor: (m) => plannedColors(container, m),
            firstDayOfWeek:
                container
                    .read(currentProfileProvider)
                    .value
                    ?.settings
                    .firstDayOfWeek ??
                1,
            title: _l10n.selectionMoveTitle,
            today: today,
            initial: day,
          );
          if (to == null || !_context.mounted) return;
          final name = DateFormat.MMMMEEEEd(
            Localizations.localeOf(_context).toLanguageTag(),
          ).format(to);
          _finish(
            moveAllToDay(container, rows, to),
            _l10n.snackManyMoved(rows.length, name),
          );
        }());

  VoidCallback? get duplicate => rows.isEmpty
      ? null
      : () => _finish(
          duplicateAll(container, rows),
          _l10n.snackManyDuplicated(rows.length),
        );

  VoidCallback? get recolour => rows.isEmpty
      ? null
      : () => unawaited(() async {
          final colour = await showColourChoice(_context);
          if (colour == null) return;
          _finish(
            recolourAll(container, rows, colour.key),
            _l10n.snackManyRecoloured(rows.length),
          );
        }());

  /// Save as routine (11 C2, M11.4): the picked tasks' order, lengths and
  /// gaps, named here; one undoable write.
  VoidCallback? get saveAsRoutine => rows.isEmpty
      ? null
      : () => unawaited(() async {
          final name = await showTextPrompt(
            _context,
            title: _l10n.routineSaveSelection,
            label: _l10n.routineName,
            action: _l10n.routineSave,
          );
          if (name == null) return;
          final routine = await routineFromPicked(container, rows, day, name);
          _finish(
            _undo.applyUndoable(
              WriteBatch(userId: routine.userId, routines: [routine]),
            ),
            _l10n.routineSaved(name),
          );
        }());

  VoidCallback? get delete => rows.isEmpty
      ? null
      : () => unawaited(() async {
          final sure = await confirmDeleteMany(_context, rows.length);
          if (!sure) return;
          _finish(
            trashAll(container, rows),
            _l10n.snackManyDeleted(rows.length),
          );
        }());
}
