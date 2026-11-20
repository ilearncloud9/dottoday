import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/sync/sync_providers.dart';
import 'package:dottoday/domain/sync/sync_status.dart';
import 'package:dottoday/features/timeline/now/now_inputs.dart';
import 'package:dottoday/features/timeline/workspace/workspace_controls.dart';
import 'package:dottoday/features/timeline/workspace/workspace_search_field.dart';
import 'package:dottoday/shared/sync/sync_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// The Mac's Minimal toolbar over Now and the Day column (E-Minimal frame
/// 1): "Tuesday, 3 November", "Now 10:42 · Wind Down at 11:00 PM", then
/// sync, Search or run ⌘K and +. The web draws the date in the pane
/// instead (frame 2): only the chrome differs (ED-232).
class NowToolbar extends ConsumerWidget {
  const NowToolbar({required this.inputs, super.key});

  final NowInputs inputs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final n = inputs;
    final locale = Localizations.localeOf(context).toLanguageTag();
    // Narrow (ED-170): no status text (the pane says "Now · 10:42"), and
    // Search or run is its icon, with its name and ⌘K.
    final narrow = MediaQuery.sizeOf(context).width < DotSize.narrowToolbar;
    return Material(
      color: t.colors.sunk,
      shape: Border(bottom: BorderSide(color: t.colors.hairline)),
      child: Container(
        constraints: const BoxConstraints(minHeight: DotSize.workspaceToolbar),
        padding: const EdgeInsets.symmetric(
          horizontal: DotSpace.l,
          vertical: DotSpace.s,
        ),
        child: Row(
          spacing: DotSpace.m,
          children: [
            Flexible(
              child: Wrap(
                spacing: DotSpace.m,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      DateFormat.MMMMEEEEd(locale).format(n.today),
                      style: t.styles.rowTitle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!narrow)
                    Text(
                      l10n.nowSummary(n.time(n.nowUtc), n.time(n.shape.bedUtc)),
                      style: t.styles.rowMeta.copyWith(color: t.colors.muted),
                    ),
                ],
              ),
            ),
            const Spacer(),
            SyncButton(
              status:
                  ref.watch(syncStatusProvider).value ?? SyncStatus.localOnly,
              now: n.nowUtc,
            ),
            SearchField(
              label: l10n.workspaceSearchOrRun,
              hint: '⌘K', // l10n-ignore: a key cap
              compact: narrow,
              onTap: () => context.go(AppRoutes.search),
            ),
            ToolbarAdd(
              label: l10n.quickAddTooltip,
              text: l10n.addAdd,
              onTap: () => Actions.maybeInvoke(
                context,
                const AppCommandIntent(AppCommand.quickAdd),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
