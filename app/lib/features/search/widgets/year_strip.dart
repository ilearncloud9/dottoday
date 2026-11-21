import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/domain/review/journal.dart';
import 'package:dottoday/features/search/widgets/year_strip_months.dart';
import 'package:dottoday/shared/share/capture_image.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// "Year strip", option B (E-R2-34, E-R2-42; ED-348, ED-349): the last
/// twelve months as dots that fill with the days planned, a month's days
/// under them, and Share image (the OS sheet; a download on the web
/// without Web Share). A sheet on phones; from medium width the built
/// centred dialog, Esc or a click outside closing it.
Future<void> showYearStrip(
  BuildContext context,
  List<StripMonth> months, {
  int firstDayOfWeek = DateTime.monday,
}) {
  final boundary = GlobalKey();
  return showAppSheet<void>(
    context: context,
    builder: (sheet) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.l,
      children: [
        _Header(months: months),
        YearStripMonths(
          months: months,
          boundary: boundary,
          firstDayOfWeek: firstDayOfWeek,
        ),
        Builder(
          builder: (button) => FilledButton.icon(
            onPressed: () => unawaited(_share(button, boundary, months)),
            icon: DotIcon(
              DotGlyphs.share,
              color: DotTheme.of(button).colors.onAccent,
              size: DotSize.rowIcon,
            ),
            label: Text(context.l10n.weekShareImage),
          ),
        ),
      ],
    ),
  );
}

/// "Year strip" over "214 days in the last 12 months", and Done.
class _Header extends StatelessWidget {
  const _Header({required this.months});

  final List<StripMonth> months;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final planned = months.fold(
      0,
      (n, m) => n + m.shares.where((s) => s != null).length,
    );
    final done = TextButton(
      onPressed: () => Navigator.of(context).maybePop(),
      child: Text(l10n.sheetDone),
    );
    // The iPhone's sheet; the Mac, the web and tablets get the dialog
    // with the title at the start (E-R2-42).
    final ios =
        DotIdiom.of(context) == DotIdiom.cupertino &&
        AppLayout.classOf(context) == WidthClass.compact;
    final title = Column(
      crossAxisAlignment: ios
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(l10n.journalStripTitle, style: t.styles.cardTitle),
        ),
        Text(
          l10n.journalDays(planned),
          style: t.styles.rowMeta.copyWith(color: t.colors.muted),
        ),
      ],
    );
    // The iPhone centres the title with Done at the end (E-R2-34 option
    // B); Material and the dialog start it.
    if (!ios) {
      return Row(
        children: [
          Expanded(child: title),
          done,
        ],
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DotTouch.android),
          child: title,
        ),
        Align(alignment: AlignmentDirectional.centerEnd, child: done),
      ],
    );
  }
}

Future<void> _share(
  BuildContext context,
  GlobalKey boundary,
  List<StripMonth> months,
) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final box = context.findRenderObject();
  final origin = box is RenderBox
      ? box.localToGlobal(Offset.zero) & box.size
      : null;
  final png = await captureImage(boundary);
  if (png == null) return;
  const fileDate = 'yyyy-MM'; // l10n-ignore: a file name's date
  final last = DateFormat(fileDate).format(months.last.month);
  try {
    await container
        .read(fileGatewayProvider)
        .shareImage(
          png,
          name: 'dottoday-year-$last.png', // l10n-ignore: a file name
          origin: origin,
        );
  } on Exception catch (e, st) {
    container
        .read(loggerProvider)
        .error(
          'journal.share_failed', // l10n-ignore: log event, never shown
          error: e,
          stackTrace: st,
        );
    messenger.showSnackBar(SnackBar(content: Text(l10n.exportHandOffFailed)));
  }
}
