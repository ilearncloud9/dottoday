import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// "Inbox", "5 unscheduled · 5 h 15 of work" and the dotted ring holding
/// the count (docs/10 §1 "the Inbox is a dotted ring holding loose dots",
/// `A-ios-inbox`).
class InboxHeader extends StatelessWidget {
  const InboxHeader({required this.count, required this.minutes, super.key});

  final int count;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
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
          ),
        ),
        Semantics(
          container: true,
          label: l10n.inboxRingLabel(count),
          excludeSemantics: true,
          child: CustomPaint(
            painter: DashedPillPainter(color: t.colors.outline),
            child: SizedBox.square(
              dimension: DotSize.liveDot + DotSpace.m,
              child: Center(
                child: Text(
                  NumberFormat.decimalPattern(
                    Localizations.localeOf(context).toLanguageTag(),
                  ).format(count),
                  style: t.styles.cardTitle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
