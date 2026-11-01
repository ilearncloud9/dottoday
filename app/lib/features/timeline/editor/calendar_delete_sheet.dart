import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/calendar/write_back_providers.dart';
import 'package:dottoday/domain/calendar/calendar_series_sender.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Before every repeat of a calendar event is deleted here (docs/02
/// F5.7): "Also delete it from Work?" — asked every time, never
/// remembered, since it can't be undone here and reaches every device.
/// Only when Send changes back is on for that calendar. Only in Dottoday
/// is first. The calendar's name when it should go there too, '' for
/// only here (or not asked), null when the person closed the sheet.
Future<String?> askDeleteFromCalendar(
  BuildContext context,
  ProviderContainer ref,
  Occurrence target,
) async {
  final linkId = target.calendarLinkId;
  if (linkId == null ||
      !await ref.read(calendarSeriesWriteBackProvider).sends(target)) {
    return '';
  }
  final status = await ref.read(calendarWriteStatusProvider(linkId).future);
  if (status == null || !context.mounted) return '';
  final calendar = status.calendar;
  final l10n = context.l10n;
  final there = await showAppSheet<bool>(
    context: context,
    title: l10n.seriesDeleteCalendarTitle(calendar),
    builder: (sheet) {
      final t = DotTheme.of(sheet);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: DotTouch.android,
            title: Text(l10n.seriesDeleteOnlyHere, style: t.styles.body),
            onTap: () => Navigator.of(sheet).pop(false),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: DotTouch.android,
            title: Text(
              l10n.seriesDeleteFromCalendar(calendar),
              style: t.styles.body,
            ),
            subtitle: Text(
              l10n.seriesDeleteFromCalendarDetail,
              style: t.styles.rowMeta,
            ),
            onTap: () => Navigator.of(sheet).pop(true),
          ),
        ],
      );
    },
  );
  return switch (there) {
    true => calendar,
    false => '',
    null => null,
  };
}

/// Deletes [target]'s series from [calendar]; the snackbar text for it.
Future<String> deleteFromCalendar(
  AppLocalizations l10n,
  ProviderContainer ref,
  Occurrence target,
  String calendar,
) async {
  final sent = await ref.read(calendarSeriesWriteBackProvider).delete(target);
  return sent == SeriesSend.failed
      ? l10n.snackSeriesNotDeletedThere(calendar)
      : l10n.snackSeriesDeletedThere(target.title, calendar);
}
