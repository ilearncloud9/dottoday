import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the shell's drag targets send a dropped task (ADR-0015, after
/// Structured): the Inbox tab unschedules it, the Trash target moves it to
/// Trash. Both say so with Undo; a pinned task stays put.
final class ShellDrops {
  const ShellDrops(this.context, this.ref);

  final BuildContext context;
  final WidgetRef ref;

  /// Task [id] back to the Inbox.
  void toInbox(String id) => unawaited(
    _apply(
      id,
      (o) => ref
          .read(undoServiceProvider)
          .applyUndoable(
            WriteBatch(
              userId: o.userId,
              occurrences: [
                o.copyWith(
                  startUtc: null,
                  updatedAt: ref.read(clockProvider).nowUtc(),
                ),
              ],
            ),
          ),
      (l10n, o) => l10n.snackMovedToInbox(o.title),
    ),
  );

  /// Task [id] to Trash.
  void toTrash(String id) => unawaited(
    _apply(
      id,
      (o) => ref.read(trashServiceProvider).trashOccurrences(o.userId, {o.id}),
      (l10n, o) => l10n.snackTrashed(o.title),
    ),
  );

  Future<void> _apply(
    String id,
    Future<Result<UndoToken, AppFailure>> Function(Occurrence o) write,
    String Function(AppLocalizations l10n, Occurrence o) message,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final undo = ref.read(undoServiceProvider);
    final profile = await ref.read(currentProfileProvider.future);
    final o = await ref
        .read(occurrenceRepositoryProvider)
        .findById(profile.id, id);
    if (o == null || o.pinned) return;
    reportUndoable(
      messenger,
      l10n,
      undo,
      await write(o),
      message: (_) => message(l10n, o),
      tokenOf: (t) => t,
    );
  }
}
