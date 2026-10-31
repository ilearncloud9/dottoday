import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/task_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today's keys (docs/09 M3e.6, R-12): ⌘← / ⌘→ step a day, ⌘T comes back
/// to today, ⌘D marks the task running now done (Ctrl elsewhere), and the
/// task keys of [TaskKeys]. Every width: a keyboard on a tablet works too.
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
      // The Mac Go menu sends the same moves as intents (M5.5).
      child: Actions(
        actions: {
          ShowDayIntent: CallbackAction<ShowDayIntent>(
            onInvoke: (i) => onSelect(plus(i.days)),
          ),
          ShowTodayIntent: CallbackAction<ShowTodayIntent>(
            onInvoke: (_) => onSelect(today),
          ),
        },
        // ↑↓ / ⌘↑↓ / Delete / ↩ / Space on the shown day's tasks (F1.17).
        child: TaskKeys(
          day: shown,
          child: Focus(
            // Never from a sheet above: on a slow web load Today mounts
            // under an open Add sheet and took its title's keys (CI
            // a11y-web). It takes the keys on a build once on top.
            autofocus: _onTop(context),
            // Catches keys only; adds nothing for screen readers.
            includeSemantics: false,
            // No Tab stop: Tab from here starts at Skip to content (SkipLink).
            skipTraversal: true,
            child: child,
          ),
        ),
      ),
    );
  }

  /// Whether Today's route is on top in every navigator above it: Add and
  /// the other sheets open on the root navigator, over the tab shell.
  static bool _onTop(BuildContext context) {
    for (
      var route = ModalRoute.of(context);
      route != null;
      route = switch (route.navigator) {
        final nav? => ModalRoute.of(nav.context),
        null => null,
      }
    ) {
      if (!route.isCurrent) return false;
    }
    return true;
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
