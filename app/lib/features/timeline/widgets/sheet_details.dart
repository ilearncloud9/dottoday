import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/state/task_text.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/widgets/pin_row.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// Alerts, Repeat and Colour & icon rows (`A-ios-task-sheet`), plus
/// Travel time when the task has some (M7.5, R-17) and the Pinned switch
/// (F1.5) when [onPinned] is given.
class SheetDetails extends StatelessWidget {
  const SheetDetails({
    required this.task,
    this.onEdit,
    this.onPinned,
    super.key,
  });

  final TaskView task;
  final VoidCallback? onEdit;

  /// Pins or unpins the task; null hides the row (an Inbox task or an
  /// imported event, which shifts never move anyway, F1.12).
  final ValueChanged<bool>? onPinned;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = DotTheme.of(context).colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final o = task.occurrence;
    // Material, not a DecoratedBox: the rows' ink must paint on it.
    return Material(
      color: c.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DotRadii.card),
        side: BorderSide(color: c.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _DetailRow(
            glyph: DotGlyphs.bell,
            label: l10n.sheetAlerts,
            value: alertsText(l10n, task.alerts),
            onTap: onEdit,
          ),
          Divider(height: DotSpace.hairline, color: c.outline),
          _DetailRow(
            glyph: DotGlyphs.repeat,
            label: l10n.sheetRepeat,
            value: repeatText(l10n, locale, task.series?.rrule),
            onTap: onEdit,
          ),
          if (o.travelBufferMin > 0) ...[
            Divider(height: DotSpace.hairline, color: c.outline),
            _DetailRow(
              glyph: TaskIcon.car.glyph ?? DotGlyphs.clock,
              label: l10n.travelTitle,
              value: l10n.travelBefore(
                formatDurationShort(l10n, o.travelBufferMin),
              ),
              onTap: onEdit,
            ),
          ],
          if (onPinned case final onPinned?) ...[
            Divider(height: DotSpace.hairline, color: c.outline),
            PinRow(
              pinned: o.pinned,
              onChanged: onPinned,
              minHeight: DotTouch.android + DotSpace.s,
            ),
          ],
          Divider(height: DotSpace.hairline, color: c.outline),
          _DetailRow(
            glyph: TaskIcon.fromKey(o.iconKey).glyph ?? DotGlyphs.today,
            glyphColor: TaskColor.fromKey(o.colorKey).color,
            label: l10n.sheetLook,
            value: '',
            onTap: onEdit,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.glyph,
    required this.label,
    required this.value,
    this.glyphColor,
    this.onTap,
  });

  final DotGlyph glyph;
  final String label;
  final String value;
  final Color? glyphColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return ListTile(
      onTap: onTap,
      minTileHeight: DotTouch.android + DotSpace.s,
      leading: DotIcon(glyph, color: glyphColor ?? t.colors.muted),
      title: Text(label, style: t.styles.body),
      trailing: Text(
        value,
        style: t.styles.body.copyWith(color: t.colors.muted),
      ),
    );
  }
}
