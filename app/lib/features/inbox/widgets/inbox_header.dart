import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// "Inbox" over "3 unscheduled · 1 h 20 of work" (E-R2-13, ED-295).
class InboxHeader extends StatelessWidget {
  const InboxHeader({required this.count, required this.minutes, super.key});

  final int count;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(l10n.navInbox, style: t.styles.pageTitle),
        ),
        Text(
          l10n.inboxSummary(count, formatDurationShort(l10n, minutes)),
          style: t.styles.body.copyWith(color: t.colors.muted),
        ),
      ],
    );
  }
}
