import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One conflict (docs/04 §4, R-08): the task, which detail, both values,
/// Keep mine / Keep theirs. Never a silent loss: the server value is in
/// use until the user picks.
class ConflictCard extends ConsumerWidget {
  const ConflictCard({required this.conflict, super.key});

  final SyncConflict conflict;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final c = conflict;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.raised,
        borderRadius: BorderRadius.circular(DotRadii.card),
        border: Border.all(color: t.colors.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSpace.xs,
          children: [
            Text(
              l10n.syncConflictHeading(
                c.title,
                l10n.syncConflictField(_key(c.field)),
              ),
              style: t.styles.rowTitle,
            ),
            Text(l10n.syncMine(c.mine), style: t.styles.body),
            Text(l10n.syncTheirs(c.theirs), style: t.styles.body),
            _choices(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _choices(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Wrap(
      spacing: DotSpace.s,
      children: [
        OutlinedButton(
          onPressed: () =>
              unawaited(_resolve(context, ref, ConflictChoice.mine)),
          child: Text(l10n.syncKeepMine),
        ),
        OutlinedButton(
          onPressed: () =>
              unawaited(_resolve(context, ref, ConflictChoice.theirs)),
          child: Text(l10n.syncKeepTheirs),
        ),
      ],
    );
  }

  /// The ICU select key for [field] (`time` is reserved there).
  static String _key(ConflictField field) => switch (field) {
    ConflictField.time => 'start', // l10n-ignore: an ICU select key
    _ => field.name,
  };

  Future<void> _resolve(
    BuildContext context,
    WidgetRef ref,
    ConflictChoice choice,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final result = await ref
        .read(syncServiceProvider)
        .resolve(conflict.id, choice);
    if (result case Err(:final failure)) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    }
  }
}
