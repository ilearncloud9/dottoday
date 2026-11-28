import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/core/utils/text_fit.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/trash/trash_age.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/settings/settings_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// One Trash row (E-R2-32, ED-337; Mac and web E-R2-30, ED-478): the task's
/// skipped dot, the title and "Deleted today · 30 days left", then Delete
/// now and Restore. Phones: Delete now in ink, Restore in the accent; Mac
/// and web ([push]): two push buttons, as E-R2-30 draws Restore.
class TrashRow extends StatelessWidget {
  const TrashRow({
    required this.task,
    required this.nowUtc,
    required this.zone,
    required this.push,
    required this.onDeleteNow,
    required this.onRestore,
    super.key,
  });

  final Occurrence task;
  final DateTime nowUtc;
  final tz.Location zone;
  final bool push;
  final VoidCallback onDeleteNow;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final actions = push
        ? <Widget>[
            FormButton(label: l10n.trashDeleteNow, onPressed: onDeleteNow),
            FormButton(label: l10n.settingsRestore, onPressed: onRestore),
          ]
        : <Widget>[
            _TextAction(
              label: l10n.trashDeleteNow,
              color: t.colors.ink,
              onPressed: onDeleteNow,
            ),
            _TextAction(
              label: l10n.settingsRestore,
              color: t.colors.accentText,
              onPressed: onRestore,
            ),
          ];
    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(task.title, style: t.styles.rowTitle),
        Text(_detail(context), style: t.styles.rowMeta),
      ],
    );
    final dot = TaskDot(
      color: TaskColor.fromKey(task.colorKey),
      icon: TaskIcon.fromKey(task.iconKey),
      state: DotState.skipped,
      label: task.title,
      size: DotSize.macRowDot,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.l,
        vertical: DotSpace.s,
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          // Beside the title while its longest word still fits; under it
          // otherwise (a narrow sheet, 200 % text), never cut.
          final room =
              box.maxWidth -
              DotSize.macRowDot -
              2 * DotSpace.m -
              _actionsWidth(context, t, l10n);
          final beside = longestWordFits(
            context,
            task.title,
            t.styles.rowTitle,
            room,
          );
          return Row(
            spacing: DotSpace.m,
            crossAxisAlignment: beside
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              dot,
              Expanded(
                child: beside
                    ? texts
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: DotSpace.xs,
                        children: [
                          texts,
                          Wrap(spacing: DotSpace.s, children: actions),
                        ],
                      ),
              ),
              if (beside) ...actions,
            ],
          );
        },
      ),
    );
  }

  /// The two actions' width beside the title.
  double _actionsWidth(
    BuildContext context,
    DotTheme t,
    AppLocalizations l10n,
  ) {
    final style = push ? t.styles.body : _actionStyle(context);
    return textWidth(context, l10n.trashDeleteNow, style) +
        textWidth(context, l10n.settingsRestore, style) +
        (push ? 4 * DotSpace.m : 4 * DotSpace.s);
  }

  /// "Deleted today · 30 days left" (E-R2-30, E-R2-32).
  String _detail(BuildContext context) {
    final l10n = context.l10n;
    final deletedAt = task.deletedAt;
    if (deletedAt == null) return '';
    final age = trashAge(deletedAt, nowUtc, zone);
    final deleted = switch (age.daysAgo) {
      0 => l10n.trashDeletedToday,
      1 => l10n.trashDeletedYesterday,
      _ => l10n.trashDeletedOn(
        DateFormat.MMMd(
          l10n.localeName,
        ).format(tz.TZDateTime.from(deletedAt, zone)),
      ),
    };
    return l10n.trashRowDetail(deleted, l10n.trashDaysLeft(age.daysLeft));
  }
}

/// A phone action: a text button with a 44 pt target and little padding,
/// so two fit beside a title (E-R2-32).
class _TextAction extends StatelessWidget {
  const _TextAction({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: color,
      minimumSize: const Size(DotTouch.min, DotTouch.min),
      padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
      textStyle: _actionStyle(context),
    ),
    child: Text(label),
  );
}

/// The phone actions' type: the button role (Manrope 700) at the meta
/// line's 13, smaller than the title, as E-R2-32 draws them.
TextStyle _actionStyle(BuildContext context) {
  final styles = DotTheme.of(context).styles;
  return styles.button.copyWith(
    fontSize: styles.rowMeta.fontSize,
    height: styles.rowMeta.height,
  );
}
