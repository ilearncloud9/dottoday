import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/features/sync_status/conflict_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One conflict as E-G4-7 C2 and Q4 draw it (docs/04 §4, R-08; M20.10
/// part 5, ED-483): "Deep work: roadmap · Time", This device and Other
/// device with "in use now", and Keep mine / Keep theirs with equal
/// weight. Notes get Keep both too, with its hint (ED-195); when the two
/// together are over the notes limit it is off and says why, and each
/// version can be copied (Q4i). Never a silent loss: the other device's
/// value is in use until the person chooses. [onResolved] hears how to
/// take the choice back (Undo, ED-194).
class ConflictCard extends ConsumerWidget {
  const ConflictCard({
    required this.conflict,
    required this.onResolved,
    this.wide = false,
    super.key,
  });

  final SyncConflict conflict;
  final ValueChanged<ConflictUndo> onResolved;

  /// Mac and web: the three choices in a row (Q4c, Q4d).
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final c = conflict;
    final notes = c.field == ConflictField.notes;
    final combined = notes
        ? combinedNotes(c.mineNotes, c.theirsNotes, l10n.conflictFromOther)
        : null;
    final fits = combined != null && combined.length <= maxNotesLength;
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.colors.sunk,
          borderRadius: BorderRadius.circular(DotRadii.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DotSpace.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: DotSpace.s,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.syncConflictHeading(
                    c.title,
                    l10n.syncConflictField(conflictFieldKey(c.field)),
                  ),
                  style: t.styles.rowTitle,
                ),
              ),
              if (notes)
                ConflictNotes(conflict: c, copyable: !fits)
              else
                ConflictRows(conflict: c),
              _Choices(
                notes: notes,
                bothFits: fits,
                wide: wide,
                onChoose: (choice) => unawaited(
                  _resolve(context, ref, choice, combined: combined),
                ),
              ),
              if (notes && fits)
                Text(l10n.conflictKeepBothHint, style: t.styles.rowMeta),
              if (notes && !fits) ...[
                Text(
                  l10n.conflictBothUnavailable,
                  style: t.styles.rowMeta.copyWith(
                    color: t.colors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(l10n.conflictBothTooLong, style: t.styles.rowMeta),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resolve(
    BuildContext context,
    WidgetRef ref,
    ConflictChoice choice, {
    String? combined,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final result = await ref
        .read(syncServiceProvider)
        .resolve(conflict.id, choice, combined: combined);
    switch (result) {
      case Ok(:final value):
        onResolved(value);
      case Err(:final failure):
        messenger.showSnackBar(
          SnackBar(content: Text(failureMessage(l10n, failure))),
        );
    }
  }
}

/// Keep mine, Keep theirs and, for notes, Keep both: equal weight (pills
/// of one look), stacked on phones for notes, in a row on Mac and web or
/// for two choices; stacked whenever they don't fit (200 % text, Q4h).
class _Choices extends StatelessWidget {
  const _Choices({
    required this.notes,
    required this.bothFits,
    required this.wide,
    required this.onChoose,
  });

  final bool notes;
  final bool bothFits;
  final bool wide;
  final ValueChanged<ConflictChoice> onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final buttons = [
      OutlinedButton(
        onPressed: () => onChoose(ConflictChoice.mine),
        child: Text(l10n.syncKeepMine),
      ),
      OutlinedButton(
        onPressed: () => onChoose(ConflictChoice.theirs),
        child: Text(l10n.syncKeepTheirs),
      ),
      if (notes)
        OutlinedButton(
          onPressed: bothFits ? () => onChoose(ConflictChoice.both) : null,
          child: Text(l10n.syncKeepBoth),
        ),
    ];
    final large = MediaQuery.textScalerOf(context).scale(1) >= 1.3;
    if (notes && (!wide || large) || large) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.s,
        children: buttons,
      );
    }
    return Wrap(spacing: DotSpace.s, runSpacing: DotSpace.s, children: buttons);
  }
}
