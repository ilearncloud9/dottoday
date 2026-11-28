import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/features/sync_status/conflict_card.dart';
import 'package:dottoday/features/sync_status/conflict_values.dart';
import 'package:dottoday/shared/feedback/undo_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conflict_review.g.dart';

/// How long Undo stays offered after resolving (E-G4-7 C3, C5: "about
/// 10 s"; ED-194).
const conflictUndoWindow = Duration(seconds: 10);

/// The last choice on the Mac and the web, while its Undo is offered in
/// the popover (C5), else null. Clears itself after [conflictUndoWindow].
@riverpod
class LastConflictChoice extends _$LastConflictChoice {
  Timer? _expire;

  @override
  ConflictUndo? build() {
    ref.onDispose(() => _expire?.cancel());
    return null;
  }

  // A plain setter for the review; state is the notifier's own.
  // ignore: use_setters_to_change_properties
  void set(ConflictUndo? undo) {
    _expire?.cancel();
    state = undo;
    if (undo != null) _expire = Timer(conflictUndoWindow, () => state = null);
  }
}

/// What was kept, for the toast and the popover (C3, C5, Q4f).
String conflictKept(AppLocalizations l10n, ConflictUndo u) => switch (u.kept) {
  ConflictChoice.mine => l10n.conflictKeptMine(conflictFieldKey(u.field)),
  ConflictChoice.theirs => l10n.conflictKeptTheirs(conflictFieldKey(u.field)),
  ConflictChoice.both => l10n.conflictKeptBoth,
};

/// Changed on two devices (E-G4-7 C2, C4, Q4; M20.10 part 5, ED-483):
/// the hint, then a card per conflict. On a touch device the last choice
/// closes the sheet and a toast says what was kept, with Undo (C3); on
/// the Mac and the web the popover says it, with Undo and ⌘Z / Ctrl+Z
/// (C5), for [conflictUndoWindow]. Undo puts the replaced value back as a
/// new edit (ED-194).
class ConflictReview extends ConsumerStatefulWidget {
  const ConflictReview({required this.conflicts, super.key});

  final List<SyncConflict> conflicts;

  @override
  ConsumerState<ConflictReview> createState() => _ConflictReviewState();
}

class _ConflictReviewState extends ConsumerState<ConflictReview> {
  void _resolved(ConflictUndo undo) {
    if (!touchApp(context)) {
      ref.read(lastConflictChoiceProvider.notifier).set(undo);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final service = ref.read(syncServiceProvider);
    // The last one: the sheet closes and the toast speaks (C3).
    if (widget.conflicts.length <= 1) {
      unawaited(Navigator.of(context).maybePop());
    }
    showUndoSnackbarOn(
      messenger,
      l10n,
      message: conflictKept(l10n, undo),
      window: conflictUndoWindow,
      onUndo: () => unawaited(undoConflict(service, messenger, l10n, undo)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        Text(l10n.syncConflictHint, style: t.styles.rowMeta),
        for (final c in widget.conflicts)
          ConflictCard(
            key: ValueKey(c.id),
            conflict: c,
            wide: !touchApp(context),
            onResolved: _resolved,
          ),
      ],
    );
  }
}

/// Undo (ED-194): the replaced value back as a new edit; a failure is said.
Future<void> undoConflict(
  SyncService service,
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  ConflictUndo undo,
) async {
  final result = await service.undoResolve(undo);
  if (result case Err(:final failure)) {
    messenger.showSnackBar(
      SnackBar(content: Text(failureMessage(l10n, failure))),
    );
  }
}

/// The popover after a choice (C5, Q4f): what was kept, the task and
/// detail, and Undo with its key; ⌘Z / Ctrl+Z work while it shows.
class ConflictResolved extends ConsumerWidget {
  const ConflictResolved({required this.undo, super.key});

  final ConflictUndo undo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onUndo() {
      ref.read(lastConflictChoiceProvider.notifier).set(null);
      unawaited(
        undoConflict(
          ref.read(syncServiceProvider),
          ScaffoldMessenger.of(context),
          context.l10n,
          undo,
        ),
      );
    }

    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final platform = Theme.of(context).platform;
    final key = AppShortcuts.activator(platform, LogicalKeyboardKey.keyZ);
    return CallbackShortcuts(
      bindings: {key: onUndo},
      child: Focus(
        autofocus: true,
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: DotSpace.s,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: DotSpace.s,
                children: [
                  DotIcon(
                    DotGlyphs.check,
                    color: t.colors.ink,
                    size: DotSize.rowIcon,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conflictKept(l10n, undo),
                          style: t.styles.rowTitle,
                        ),
                        Text(
                          l10n.syncConflictHeading(
                            undo.title,
                            l10n.syncConflictField(
                              conflictFieldKey(undo.field),
                            ),
                          ),
                          style: t.styles.rowMeta,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: onUndo,
                child: Text(
                  '${l10n.undoAction}  ${AppShortcuts.label(platform, 'Z')}', // l10n-ignore: key hint
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
