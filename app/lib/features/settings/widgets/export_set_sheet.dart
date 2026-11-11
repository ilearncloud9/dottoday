import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/export/picked_set_check.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/features/settings/widgets/set_file_rows.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hands [set] over (share sheet or folder; the web downloads each file
/// from the sheet) and then shows what it is, with "Check my files…".
Future<void> handOverSet(
  BuildContext context,
  PreparedSet set,
  Rect? origin,
) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final browser = container.read(inBrowserProvider);
  if (!browser) {
    final DeliveryOutcome outcome;
    try {
      outcome = await container
          .read(fileGatewayProvider)
          .deliverPrepared(set.files, origin: origin);
    } on Exception catch (e, st) {
      container
          .read(loggerProvider)
          .error(
            'export.hand_off_failed', // l10n-ignore: log event, never shown
            error: e,
            stackTrace: st,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(context.l10n.exportHandOffFailed)),
          );
      }
      await set.discard();
      return;
    }
    if (outcome == DeliveryOutcome.cancelled || !context.mounted) {
      await set.discard();
      return;
    }
  }
  await showExportSetSheet(context, set, browser: browser);
}

/// After a JSON export saved as a set (CR-160 B7,
/// docs/cr-160-multipart-export.md §10): says it is several files to keep
/// together; on the web, one Download per file (the browser may block a
/// burst); and "Check my files…", which picks them back to confirm they are
/// complete. The prepared files are removed when the sheet closes.
Future<void> showExportSetSheet(
  BuildContext context,
  PreparedSet set, {
  required bool browser,
}) {
  final l10n = context.l10n;
  final count = set.files.length;
  return showAppSheet<void>(
    context: context,
    title: browser
        ? l10n.exportDownloadTitle(count)
        : l10n.exportSetDone(count),
    builder: (_) => ExportSetSheet(set: set, browser: browser),
  ).whenComplete(set.discard);
}

class ExportSetSheet extends StatefulWidget {
  const ExportSetSheet({required this.set, required this.browser, super.key});

  final PreparedSet set;
  final bool browser;

  @override
  State<ExportSetSheet> createState() => _ExportSetSheetState();
}

class _ExportSetSheetState extends State<ExportSetSheet> {
  final _asked = <String>{};

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final files = widget.set.files;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(context.l10n.exportSetIntro(files.length), style: t.styles.body),
        const SizedBox(height: DotSpace.s),
        if (widget.browser) ...[
          DownloadList(files: files, asked: _asked),
          const SizedBox(height: DotSpace.s),
        ],
        CheckFilesRow(
          count: files.length,
          check: (picked) => checkPickedSet(widget.set.manifest, picked),
        ),
      ],
    );
  }
}
