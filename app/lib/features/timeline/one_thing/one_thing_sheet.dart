import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/one_thing/one_thing_picker.dart';
import 'package:dottoday/features/timeline/one_thing/one_thing_state.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today ⋯ › Pick today's one thing (docs/15 §8, owner 2026-11-01): the
/// same pick as the morning mission, any time of the day. A pick closes
/// the sheet; a new one quietly replaces the old.
Future<void> showOneThingSheet(BuildContext context) => showAppSheet<void>(
  context: context,
  title: context.l10n.oneThingAsk,
  builder: (sheet) => const _OneThingSheetBody(),
);

class _OneThingSheetBody extends ConsumerWidget {
  const _OneThingSheetBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offer = ref.watch(oneThingOfferProvider(mission: false)).value;
    if (offer == null) return const SizedBox.shrink();
    if (offer.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: DotSpace.l),
        child: Text(
          context.l10n.oneThingNothing,
          style: DotTheme.of(context).styles.body,
        ),
      );
    }
    return OneThingPicker(
      offer: offer,
      header: false,
      onPick: (o) {
        final container = ProviderScope.containerOf(context, listen: false);
        final messenger = ScaffoldMessenger.of(context);
        final l10n = context.l10n;
        Navigator.of(context).pop();
        unawaited(
          pickOneThing(
            container,
            dateKey: offer.dateKey,
            occurrenceId: o.id,
          ).then((result) {
            if (result case Err(:final failure)) {
              messenger.showSnackBar(
                SnackBar(content: Text(failureMessage(l10n, failure))),
              );
            }
          }),
        );
      },
    );
  }
}
