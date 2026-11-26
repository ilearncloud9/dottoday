import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/settings/state/settings_state.dart';
import 'package:dottoday/features/settings/widgets/trash_confirm.dart';
import 'package:dottoday/features/settings/widgets/trash_row.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:dottoday/shared/settings/settings_group.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Settings › Trash (R-11, M2.5; E-R2-21 §5, E-R2-32, E-R2-30): deleted
/// tasks for 30 days in one list, each with "Deleted today · 30 days left",
/// Delete now and Restore; Empty Trash centred under it, then "Deleted
/// tasks stay 30 days" (F7.6, ED-336, ED-337, ED-478). A sheet on phones,
/// a centred dialog on Mac and web, with push buttons there.
Future<void> showTrashSheet(BuildContext context) => showAppSheet<void>(
  context: context,
  title: context.l10n.settingsTrash,
  builder: (_) => const _Trash(),
);

class _Trash extends ConsumerWidget {
  const _Trash();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final profile = ref.watch(currentProfileProvider).value;
    if (profile == null) return const SizedBox.shrink();
    final items = ref.watch(trashItemsProvider(profile.id)).value;
    if (items == null) return const SizedBox.shrink();
    if (items.isEmpty) {
      return Text(
        l10n.settingsTrashEmpty,
        style: t.styles.body.copyWith(color: t.colors.muted),
      );
    }
    final push = settingsFormFits(context);
    final zone = tz.getLocation(profile.tzId);
    final now = ref.watch(clockProvider).nowUtc();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        // One list, as E-R2-32 and E-R2-30 draw it (ED-478).
        SettingsGroup(
          caption: '',
          children: [
            for (final o in items)
              TrashRow(
                task: o,
                nowUtc: now,
                zone: zone,
                push: push,
                onDeleteNow: () => unawaited(_deleteNow(context, ref, o)),
                onRestore: () => unawaited(_restore(context, ref, o)),
              ),
          ],
        ),
        Center(
          child: push
              ? FormButton(
                  label: l10n.trashEmptyAction,
                  onPressed: () => unawaited(_empty(context, ref, items)),
                )
              : OutlinedButton(
                  onPressed: () => unawaited(_empty(context, ref, items)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.colors.text,
                  ),
                  child: Text(l10n.trashEmptyAction),
                ),
        ),
        Text(
          l10n.settingsTrashDetail,
          textAlign: TextAlign.center,
          style: t.styles.rowMeta,
        ),
      ],
    );
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    Occurrence o,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final result = await ref.read(trashServiceProvider).restoreOccurrences(
      o.userId,
      {o.id},
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (result) {
          Ok() => l10n.settingsRestored(o.title),
          Err(:final failure) => failureMessage(l10n, failure),
        }),
      ),
    );
  }

  /// Nothing is deleted before the confirm (F7.6). The row leaving the
  /// list is the feedback; only a failure speaks.
  Future<void> _deleteNow(
    BuildContext context,
    WidgetRef ref,
    Occurrence o,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final trash = ref.read(trashServiceProvider);
    if (!await confirmDeleteNow(context, o.title)) return;
    final result = await trash.deleteNow(o.userId, {o.id});
    if (result case Err(:final failure)) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    }
  }

  /// "Trash emptied", no Undo (ED-337): the confirm was the chance.
  Future<void> _empty(
    BuildContext context,
    WidgetRef ref,
    List<Occurrence> items,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final trash = ref.read(trashServiceProvider);
    if (!await confirmEmptyTrash(context, items.length)) return;
    final result = await trash.emptyTrash(items.first.userId);
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (result) {
          Ok() => l10n.trashEmptied,
          Err(:final failure) => failureMessage(l10n, failure),
        }),
      ),
    );
  }
}
