import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/features/timeline/widgets/copy_day_sheet.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// What to do with a free day (`A-ios-future-month`): add to it, pull from
/// the inbox, or copy another day onto it.
class EmptyDayActions extends ConsumerWidget {
  const EmptyDayActions({required this.date, super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final inbox = openItems(
      ref.watch(inboxItemsProvider).value ?? const [],
    ).length;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSize.liveDot + DotSpace.xl,
        DotSpace.s,
        DotSpace.l,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DotSpace.s,
        children: [
          _Action(
            dashed: true,
            glyph: DotGlyphs.add,
            label: l10n.emptyAddToDay,
            // Add opens on this day (M3c.5).
            onTap: () => Actions.maybeInvoke(context, AddTaskIntent(day: date)),
          ),
          if (inbox > 0)
            _Action(
              glyph: DotGlyphs.inbox,
              label: l10n.emptyPullInbox(inbox),
              onTap: () => context.go(AppRoutes.inbox),
            ),
          _Action(
            glyph: DotGlyphs.calendar,
            label: l10n.emptyCopyDay,
            onTap: () => unawaited(showCopyDaySheet(context, target: date)),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.glyph,
    required this.label,
    required this.onTap,
    this.dashed = false,
  });

  final DotGlyph glyph;
  final String label;
  final VoidCallback onTap;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: DotTouch.android),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DotSpace.l),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: DotSpace.s,
          children: [
            DotIcon(glyph, color: c.text, size: DotSize.rowIcon),
            Flexible(child: Text(label, style: t.styles.rowTitle)),
          ],
        ),
      ),
    );
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: dashed ? Colors.transparent : c.raised,
        shape: dashed
            ? const StadiumBorder()
            : StadiumBorder(side: BorderSide(color: c.outline)),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: dashed
              ? CustomPaint(
                  painter: DashedPillPainter(color: c.hairline),
                  child: content,
                )
              : content,
        ),
      ),
    );
  }
}
