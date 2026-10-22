import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today's keys (docs/09 M3e.6, R-12): ⌘← / ⌘→ step a day, ⌘T comes back
/// to today, ⌘D marks the task running now done (Ctrl elsewhere). Every
/// width: a keyboard on a tablet works too.
class TodayKeys extends ConsumerWidget {
  const TodayKeys({
    required this.shown,
    required this.today,
    required this.onSelect,
    required this.child,
    super.key,
  });

  final DateTime shown;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = defaultTargetPlatform;
    DateTime plus(int days) =>
        DateTime(shown.year, shown.month, shown.day + days);
    return CallbackShortcuts(
      bindings: {
        AppShortcuts.activator(p, LogicalKeyboardKey.arrowLeft): () =>
            onSelect(plus(-1)),
        AppShortcuts.activator(p, LogicalKeyboardKey.arrowRight): () =>
            onSelect(plus(1)),
        AppShortcuts.activator(p, LogicalKeyboardKey.keyT): () =>
            onSelect(today),
        AppShortcuts.activator(p, LogicalKeyboardKey.keyD): () =>
            unawaited(_doneLive(context, ref)),
      },
      child: Focus(
        autofocus: true,
        // Catches keys only; adds nothing for screen readers.
        includeSemantics: false,
        child: child,
      ),
    );
  }

  /// Marks today's live task done, with Undo; nothing when none runs.
  Future<void> _doneLive(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final now = ref.read(clockProvider).nowUtc();
    final blocks = ref.read(timelineDataProvider(today)).value?.blocks;
    final live = blocks
        ?.where(
          (o) =>
              o.status == OccurrenceStatus.planned &&
              o.startUtc != null &&
              !o.startUtc!.isAfter(now) &&
              o.endUtc!.isAfter(now),
        )
        .firstOrNull;
    if (live == null) return;
    final undo = ref.read(undoServiceProvider);
    reportUndoable(
      messenger,
      l10n,
      undo,
      await toggleDone(ref, live),
      message: (_) => l10n.snackDone(live.title),
      tokenOf: (t) => t,
    );
  }
}
