import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// Minimal Add's two chips under the title (docs/14 §4): when (the next
/// free slot, or the typed time) and how long (learned, else the default).
/// Either opens the full step 2, so neither is a dead end.
class AddQuickChips extends StatelessWidget {
  const AddQuickChips({
    required this.when,
    required this.length,
    required this.onMore,
    super.key,
  });

  /// "At 11:30 AM"; null until the day's free time is known.
  final String? when;

  /// "30 min".
  final String length;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: DotSize.addDot + DotSpace.l,
        top: DotSpace.s,
      ),
      child: Wrap(
        spacing: DotSpace.s,
        runSpacing: DotSpace.s,
        children: [
          if (when case final w?) ActionChip(label: Text(w), onPressed: onMore),
          ActionChip(label: Text(length), onPressed: onMore),
        ],
      ),
    );
  }
}

/// Minimal Add's footer: Add (the dot goes on the thread) and More (the
/// full step 2, docs/14 §4).
class AddMinimalFooter extends StatelessWidget {
  const AddMinimalFooter({
    required this.onAdd,
    required this.onMore,
    super.key,
  });

  final VoidCallback? onAdd;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DotSpace.page,
        DotSpace.s,
        DotSpace.page,
        DotSpace.l,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.s,
        children: [
          FilledButton(onPressed: onAdd, child: Text(l10n.addAdd)),
          TextButton(onPressed: onMore, child: Text(l10n.moreOptions)),
        ],
      ),
    );
  }
}
