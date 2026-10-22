import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/settings/state/settings_state.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings › Trash (R-11, M2.5): deleted tasks for 30 days, each with
/// Restore. The full page with selection arrives with M3f.7.
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final o in items)
          ListTile(
            minTileHeight: DotTouch.android,
            contentPadding: EdgeInsets.zero,
            leading: TaskDot(
              color: TaskColor.fromKey(o.colorKey),
              icon: TaskIcon.fromKey(o.iconKey),
              state: DotState.skipped,
              label: o.title,
              size: DotSize.macRowDot,
            ),
            title: Text(o.title, style: t.styles.rowTitle),
            trailing: TextButton(
              onPressed: () => unawaited(_restore(context, ref, o)),
              child: Text(l10n.settingsRestore),
            ),
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
}
