import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/widgets/debug_menu.dart';
import 'package:dottoday/shared/sync/sync_pill.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Today header (docs/03 §3.1): weekday and date, sync pill, overflow menu.
/// Month picker, "Today" chip and the full menu arrive in M3.6/M3.9.
class TimelineHeader extends StatelessWidget implements PreferredSizeWidget {
  const TimelineHeader({required this.date, this.textScale = 1, super.key});

  /// Year/month/day being shown.
  final DateTime date;

  /// Current text scale (1–2), so the bar grows with Dynamic Type and the
  /// two-line date never clips.
  final double textScale;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight * textScale);

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return AppBar(
      toolbarHeight: preferredSize.height,
      backgroundColor: t.colors.surface,
      surfaceTintColor: t.colors.surface,
      titleSpacing: DotSpace.l,
      title: _Title(date: date),
      actions: [
        SyncPill(
          state: SyncPillState.localOnly,
          // On a phone at large text the date needs the room.
          iconOnly:
              textScale > 1.3 &&
              MediaQuery.sizeOf(context).width < WidthClass.mediumFrom,
        ),
        // Only debug builds have items so far; the const false branch
        // compiles the menu (and the demo loader) out of release.
        if (kDebugMode)
          PopupMenuButton<void>(
            tooltip: context.l10n.timelineMenu,
            itemBuilder: debugMenuItems,
          ),
        const SizedBox(width: DotSpace.xs),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Semantics(
      header: true,
      child: Text.rich(
        maxLines: 2,
        TextSpan(
          text: DateFormat.MMMMd(locale).format(date),
          style: t.styles.cardTitle,
          children: [
            const TextSpan(text: '\n'), // l10n-ignore: line break
            TextSpan(
              text: DateFormat.EEEE(locale).format(date),
              style: t.styles.body.copyWith(color: t.colors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
