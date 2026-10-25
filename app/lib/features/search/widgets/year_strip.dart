import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/domain/review/journal.dart';
import 'package:dottoday/shared/dot/week_strip.dart';
import 'package:dottoday/shared/share/capture_image.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// The year strip (11 D3, docs/09 M12.3): twelve rows, one per month, of
/// the month grid's completion dots. Drawn at its own width and shown
/// scaled down where the screen is narrower; the shared PNG is the
/// full-size card.
class YearStripCard extends StatelessWidget {
  const YearStripCard({
    required this.months,
    required this.boundary,
    super.key,
  });

  final List<StripMonth> months;
  final GlobalKey boundary;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final planned = months.fold(
      0,
      (n, m) => n + m.shares.where((s) => s != null).length,
    );
    return Semantics(
      image: true,
      label: context.l10n.journalStripLabel(planned),
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.topStart,
        child: RepaintBoundary(
          key: boundary,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.colors.surface,
              borderRadius: BorderRadius.circular(DotRadii.card),
              border: Border.all(color: t.colors.outline),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DotSpace.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: DotSpace.xs,
                children: [
                  for (final m in months)
                    Row(
                      spacing: DotSpace.xxs,
                      children: [
                        SizedBox(
                          width: DotSize.yearStripLabel,
                          child: Text(
                            DateFormat.MMM(locale).format(m.month),
                            style: t.styles.rowMeta,
                          ),
                        ),
                        for (final s in m.shares)
                          CompletionDot(
                            completion: s == null
                                ? const Completion.none()
                                : Completion.of(s),
                          ),
                      ],
                    ),
                  const SizedBox(height: DotSpace.xs),
                  Text(
                    context.l10n.appTitle.toLowerCase(),
                    style: t.styles.rowMeta,
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

/// "Year strip": the strip in a sheet with Share image (the OS sheet; a
/// download on the web without Web Share).
Future<void> showYearStrip(BuildContext context, List<StripMonth> months) {
  final boundary = GlobalKey();
  return showAppSheet<void>(
    context: context,
    title: context.l10n.journalStripTitle,
    builder: (sheet) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.l,
      children: [
        YearStripCard(months: months, boundary: boundary),
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
