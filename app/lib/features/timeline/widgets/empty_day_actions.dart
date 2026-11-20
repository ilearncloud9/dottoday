import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/core/shortcuts/app_shortcuts.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/inbox/inbox_providers.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/features/timeline/widgets/copy_day_sheet.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// An empty day's free time in the thread (E-Phones, M19.1): "16 h free",
/// a line on what to do with it, then [EmptyDayActions].
class EmptyDayBody extends StatelessWidget {
  const EmptyDayBody({
    required this.date,
    required this.freeMinutes,
    super.key,
  });

  final DateTime date;
  final int freeMinutes;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.threadFree(formatDurationShort(l10n, freeMinutes)),
            style: t.styles.emptyTitle,
          ),
        ),
        const SizedBox(height: DotSpace.xs),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DotSize.emptyActionWidth),
          child: Text(
            l10n.emptyDayBody,
            style: t.styles.body.copyWith(color: t.colors.secondary),
          ),
        ),
        const SizedBox(height: DotSpace.l),
        EmptyDayActions(date: date),
      ],
    );
  }
}

/// What to do with a free day (E-Phones): Add a task, Drop a routine and
/// Pull from inbox · n as 46-tall pills, Add filled; "Copy a day…"
/// quieter under them (kept by the owner, M19.1). With [inset] they line
/// up with the thread's titles below its last row (a day of repeats only).
class EmptyDayActions extends ConsumerWidget {
  const EmptyDayActions({required this.date, this.inset = false, super.key});

  final DateTime date;
  final bool inset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final inbox = openItems(
      ref.watch(inboxItemsProvider).value ?? const [],
    ).length;
    final column = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: DotSize.emptyActionWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // The board's gap between the drawn pills; their touch padding
        // sits inside it.
        spacing: DotSpace.nowCard - (DotTouch.android - DotSize.emptyAction),
        children: [
          _Action(
            primary: true,
            label: l10n.emptyAddTask,
            // Add opens on this day (M3c.5).
            onTap: () => Actions.maybeInvoke(context, AddTaskIntent(day: date)),
          ),
          _Action(
            label: l10n.emptyDropRoutine,
            // Routines, dropping on this day (M11.4).
            onTap: () => unawaited(
              context.push(
                AppRoutes.settingsPage(SettingsPage.routines),
                extra: date,
              ),
            ),
          ),
          if (inbox > 0)
            _Action(
              label: l10n.emptyPullInbox(inbox),
              onTap: () => context.go(AppRoutes.inbox),
            ),
          _Quiet(
            label: l10n.emptyCopyDay,
            onTap: () => unawaited(showCopyDaySheet(context, target: date)),
          ),
        ],
      ),
    );
    final aligned = Align(
      alignment: AlignmentDirectional.centerStart,
      child: column,
    );
    if (!inset) return aligned;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSize.liveDot + DotSpace.xl,
        DotSpace.s,
        DotSpace.l,
        0,
      ),
      child: aligned,
    );
  }
}

/// One of the empty day's pills: filled teal for the main action, a card
/// with a hairline for the others.
class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      // Drawn 46 (E-Phones), touched 48: the padding takes the tap too.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: (DotTouch.android - DotSize.emptyAction) / 2,
          ),
          child: _pill(t),
        ),
      ),
    );
  }

  Widget _pill(DotTheme t) {
    final c = t.colors;
    return Material(
      color: primary ? c.accent : c.card,
      shape: primary
          ? const StadiumBorder()
          : StadiumBorder(side: BorderSide(color: c.hairline)),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotSize.emptyAction),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DotSpace.l),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: t.styles.button.copyWith(
                  color: primary ? c.onAccent : c.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Copy a day…": a text action under the pills.
class _Quiet extends StatelessWidget {
  const _Quiet({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotTouch.android),
          child: Center(
            child: Text(
              label,
              style: t.styles.button.copyWith(color: t.colors.accentText),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Nothing planned" on an empty day (`A-ios-future-month`).
class EmptyDayLine extends StatelessWidget {
  const EmptyDayLine({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.page,
        DotSpace.l,
        DotSpace.page,
        0,
      ),
      child: Text(
        context.l10n.todayEmpty,
        style: t.styles.body.copyWith(color: t.colors.muted),
      ),
    );
  }
}
