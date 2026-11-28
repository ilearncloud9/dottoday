import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:flutter/material.dart';

/// The first sync on a new device (E-G4-7 A2, ED-482): a line filling with
/// the server's rows, "12 of 40" and "Tasks appear as they arrive", under
/// Today's week strip while the day fills in below it. The real count,
/// never a guess; no spinner.
class FirstSyncRow extends StatelessWidget {
  const FirstSyncRow({required this.progress, super.key});

  final RestoreProgress progress;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final count = l10n.accountRestoreCount(progress.done, progress.total);
    return Semantics(
      container: true,
      liveRegion: true,
      label: '${l10n.accountRestoring} $count', // l10n-ignore: two strings
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DotSpace.page,
          DotSpace.m,
          DotSpace.page,
          DotSpace.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DotSpace.s,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(DotSize.progressBar),
              child: LinearProgressIndicator(
                value: progress.total == 0 ? 0 : progress.done / progress.total,
                minHeight: DotSize.progressBar,
                color: t.colors.accent,
                backgroundColor: t.colors.sunk,
              ),
            ),
            Row(
              children: [
                Text(
                  count,
                  style: t.styles.rowMeta.copyWith(
                    color: t.colors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    l10n.syncArriving,
                    textAlign: TextAlign.end,
                    style: t.styles.rowMeta.copyWith(color: t.colors.ink),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
