import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/one_thing/one_thing_picker.dart';
import 'package:dottoday/features/timeline/one_thing/one_thing_state.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:dottoday/shared/sheets/sheet_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Day menu › Pick today's one thing (docs/15 §8, E-R2-34, ED-339): the
/// same pick as the morning mission, any time of the day. Phones: a sheet
/// led by the question, closed by its handle or a tap outside. From medium
/// width: a 460 dialog titled "Pick today's one thing" with Close. A pick
/// closes it; a new one quietly replaces the old.
Future<void> showOneThingSheet(BuildContext context) => showAppSheet<void>(
  context: context,
  maxWidth: DotSize.pickDialog,
  builder: (sheet) => const _OneThingSheetBody(),
);

class _OneThingSheetBody extends ConsumerWidget {
  const _OneThingSheetBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offer = ref.watch(oneThingOfferProvider(mission: false)).value;
    if (offer == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Heading(),
        if (offer.isEmpty)
          Text(
            context.l10n.oneThingNothing,
            style: DotTheme.of(
              context,
            ).styles.body.copyWith(color: DotTheme.of(context).colors.muted),
          )
        else
          OneThingPicker(
            offer: offer,
            onPick: (o) => _pick(context, offer, o.id),
          ),
      ],
    );
  }

  void _pick(BuildContext context, OneThingOffer offer, String id) {
    final container = ProviderScope.containerOf(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    Navigator.of(context).pop();
    unawaited(
      pickOneThing(container, dateKey: offer.dateKey, occurrenceId: id).then((
        result,
      ) {
        if (result case Err(:final failure)) {
          messenger.showSnackBar(
            SnackBar(content: Text(failureMessage(l10n, failure))),
          );
        }
      }),
    );
  }
}

/// "What matters most today?": the sheet's title on phones (22 bold on
/// iPhone, the system's 22 on Android); in the dialog, under its own
/// "Pick today's one thing" and Close.
class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final ios = DotIdiom.of(context) == DotIdiom.cupertino;
    final wide = AppLayout.classOf(context) != WidthClass.compact;
    final question = Padding(
      padding: const EdgeInsets.only(bottom: DotSpace.xs),
      child: Semantics(
        header: !wide,
        child: Text(
          l10n.oneThingAsk,
          style: wide
              ? t.styles.choiceTitle
              : (ios ? t.styles.promptTitle : t.styles.sheetTitleAndroid),
        ),
      ),
    );
    if (!wide) return question;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(l10n.missionOneThing, style: t.styles.cardTitle),
              ),
            ),
            SheetCloseButton(onPressed: () => Navigator.of(context).pop()),
          ],
        ),
        question,
      ],
    );
  }
}
