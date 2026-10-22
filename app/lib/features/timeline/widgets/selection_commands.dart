import 'dart:async';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/schedule/planned_colors.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/features/timeline/state/selection_actions.dart';
import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/dot/colour_icon_block.dart';
import 'package:dottoday/shared/pickers/day_pickers.dart';
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
          final colour = await showModalBottomSheet<TaskColor>(
            context: _context,
            builder: (_) => const _ColourSheet(),
          );
          if (colour == null) return;
          _finish(
            recolourAll(container, rows, colour.key),
            _l10n.snackManyRecoloured(rows.length),
          );
        }());

  VoidCallback? get delete => rows.isEmpty
      ? null
      : () => unawaited(() async {
          final sure = await showDialog<bool>(
            context: _context,
            builder: (dialog) => AlertDialog(
              title: Text(_l10n.selectionDeleteConfirm(rows.length)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialog).pop(false),
                  child: Text(_l10n.editorCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialog).pop(true),
                  child: Text(_l10n.selectionDelete),
                ),
              ],
            ),
          );
          if (sure != true) return;
          _finish(
            trashAll(container, rows),
            _l10n.snackManyDeleted(rows.length),
          );
        }());
}

/// The nine task colours in a sheet; returns the one tapped.
class _ColourSheet extends StatelessWidget {
  const _ColourSheet();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: DotSpace.m,
          children: [
            Text(context.l10n.selectionColour, style: t.styles.cardTitle),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                for (final c in TaskColor.values)
                  ColourDot(
                    colour: c,
                    selected: false,
                    onTap: () => Navigator.of(context).pop(c),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
