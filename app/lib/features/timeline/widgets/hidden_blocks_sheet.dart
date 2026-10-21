import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/widgets/block_tile.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

/// Lists blocks hidden behind a "+n" overlap marker.
Future<void> showHiddenBlocks(
  BuildContext context,
  List<Occurrence> hidden, {
  required tz.Location location,
  required bool use24h,
}) {
  return showAppSheet<void>(
    context: context,
    title: context.l10n.timelineMoreBlocksLabel(hidden.length),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final o in hidden)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: DotSpace.s),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: DotTouch.min),
              child: BlockTile(block: o, location: location, use24h: use24h),
            ),
          ),
      ],
    ),
  );
}
