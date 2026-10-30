import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/features/timeline/widgets/shell_drops.dart';
import 'package:dottoday/shared/navigation/drag_targets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Minimal mode's Inbox (docs/14 §3 "Inbox"): one quiet row where the
/// thread ends, "Later · 3", that opens the Inbox. A dragged task let go
/// on it goes back to the Inbox, as on the full layout's Inbox tab.
class LaterRow extends ConsumerWidget {
  const LaterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final count = openItems(
      ref.watch(inboxItemsProvider).value ?? const [],
    ).length;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.page,
        DotSpace.m,
        DotSpace.page,
        0,
      ),
      child: TaskDropTab(
        onDropTask: ShellDrops(context, ref).toInbox,
        child: Semantics(
          button: true,
          label: l10n.laterRowLabel(count),
          excludeSemantics: true,
          child: InkWell(
            onTap: () => context.go(AppRoutes.inbox),
            borderRadius: BorderRadius.circular(DotRadii.card),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: DotTouch.android),
              child: Row(
                spacing: DotSpace.s,
                children: [
                  DotIcon(DotGlyphs.inbox, color: t.colors.muted),
                  Expanded(
                    child: Text(
                      l10n.laterRow(count),
                      style: t.styles.rowMeta.copyWith(color: t.colors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
