import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:flutter/material.dart';

/// One row of the When card (option D, ED-086; Create task, ED-140): an
/// accent icon, the value with an optional detail under it, the trailing
/// note ("Today", "30 min") and a chevron. The whole row is one button.
@immutable
final class TaskFormRow {
  const TaskFormRow({
    required this.glyph,
    required this.value,
    required this.onTap,
    this.detail,
    this.trailing,
    this.onTrailing,
    this.trailingLabel,
    this.label,
  });

  final DotGlyph glyph;
  final String value;
  final String? detail;
  final String? trailing;
  final VoidCallback onTap;

  /// Makes [trailing] its own button ("30 min" opens the length).
  final VoidCallback? onTrailing;

  /// That button's name ("Length, 30 min").
  final String? trailingLabel;

  /// What a screen reader hears, when it differs from the text.
  final String? label;
}

/// The When card: date, time and length, alerts (in that order).
class TaskFormCard extends StatelessWidget {
  const TaskFormCard({required this.rows, super.key});

  final List<TaskFormRow> rows;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Material(
      color: t.colors.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DotRadii.cardLarge),
        side: BorderSide(color: t.colors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, row) in rows.indexed) ...[
            if (i > 0) Divider(height: 1, color: t.colors.outline),
            _Row(row: row),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row});

  final TaskFormRow row;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final split = row.onTrailing != null;
    final spoken = [
      row.label ?? row.value,
      ?row.detail,
      if (!split) ?row.trailing,
    ].reduce((a, b) => context.l10n.listJoin(a, b));
    final trailing = row.trailing == null
        ? null
        : Text(
            row.trailing!,
            style: t.styles.body.copyWith(color: t.colors.muted),
          );
    final chevron = DotIcon(
      DotGlyphs.chevronRight,
      color: t.colors.muted,
      size: DotSize.sidebarGlyph,
    );
    final main = Semantics(
      button: true,
      label: spoken,
      excludeSemantics: true,
      onTap: row.onTap,
      child: InkWell(
        onTap: row.onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DotSize.formRow),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              DotSpace.m,
              DotSpace.s,
              DotSpace.s,
              DotSpace.s,
            ),
            child: Row(
              spacing: DotSpace.m,
              children: [
                DotIcon(row.glyph, color: t.colors.accent),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(row.value, style: t.styles.choiceTitle),
                      if (row.detail case final d?)
                        Text(d, style: t.styles.rowMeta),
                    ],
                  ),
                ),
                if (!split) ?trailing,
                if (!split) chevron,
              ],
            ),
          ),
        ),
      ),
    );
    if (!split) return main;
    return Row(
      children: [
        Expanded(child: main),
        Semantics(
          button: true,
          label: row.trailingLabel ?? row.trailing,
          excludeSemantics: true,
          onTap: row.onTrailing,
          child: InkWell(
            onTap: row.onTrailing,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: DotSize.formRow,
                minWidth: DotTouch.android,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: DotSpace.m),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: DotSpace.s,
                  children: [?trailing, chevron],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A pill of the Repeat · Energy row: icon, caption over the value.
@immutable
final class TaskFormPill {
  const TaskFormPill({
    required this.glyph,
    required this.caption,
    required this.value,
    required this.onTap,
  });

  final DotGlyph glyph;
  final String caption;
  final String value;
  final VoidCallback onTap;
}

/// Repeat and Energy side by side; at large text they stack.
class TaskFormPills extends StatelessWidget {
  const TaskFormPills({required this.pills, super.key});

  final List<TaskFormPill> pills;

  @override
  Widget build(BuildContext context) {
    final big = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final items = [for (final p in pills) _Pill(pill: p)];
    if (big) {
      return Column(spacing: DotSpace.s, children: items);
    }
    return Row(
      spacing: DotSpace.s,
      children: [for (final i in items) Expanded(child: i)],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.pill});

  final TaskFormPill pill;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DotRadii.pill),
      side: BorderSide(color: t.colors.outline),
    );
    return Semantics(
      button: true,
      label: context.l10n.listJoin(pill.caption, pill.value),
      excludeSemantics: true,
      onTap: pill.onTap,
      child: Material(
        color: t.colors.raised,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: pill.onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: DotSize.formRow),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DotSpace.m,
                vertical: DotSpace.s,
              ),
              child: Row(
                spacing: DotSpace.m,
                children: [
                  DotIcon(pill.glyph, color: t.colors.accent),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(pill.caption, style: t.styles.rowMeta),
                        Text(pill.value, style: t.styles.cardTitle),
                      ],
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
