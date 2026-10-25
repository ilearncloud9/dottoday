import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/calendar/write_back_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// For an imported event, one line saying where its edits go (docs/03
/// §3.4 "calendar write-back status", R-02: "otherwise creates a local
/// override and says so"): back to its calendar, or only here. Nothing
/// for a task of the person's own.
class CalendarWriteLine extends ConsumerWidget {
  const CalendarWriteLine({required this.linkId, super.key});

  /// `occurrences.calendar_link_id`; null for an own task.
  final String? linkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = linkId;
    if (id == null) return const SizedBox.shrink();
    final status = ref.watch(calendarWriteStatusProvider(id)).value;
    if (status == null) return const SizedBox.shrink();
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: DotSpace.s),
      child: Row(
        spacing: DotSpace.s,
        children: [
          DotIcon(
            DotGlyphs.calendar,
            color: t.colors.muted,
            size: DotSize.rowIcon,
          ),
          Expanded(
            child: Text(
              status.sends
                  ? l10n.taskCalendarSends(status.calendar)
                  : l10n.taskCalendarStays(status.calendar),
              style: t.styles.rowMeta,
            ),
          ),
        ],
      ),
    );
  }
}
