import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Switches the layout at once (docs/14 §5): no confirmation, no tour, no
/// loss warning, because nothing is lost; the next frame redraws. Only a
/// refused write says why.
void setLayout(BuildContext context, {required bool minimal}) {
  final container = ProviderScope.containerOf(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final l10n = context.l10n;
  final layout = minimal ? UiLayout.minimal : UiLayout.full;
  unawaited(
    updateSettings(container, (s) => s.copyWith(uiLayout: layout)).then((r) {
      if (r case Err(:final failure)) {
        messenger?.showSnackBar(
          SnackBar(content: Text(failureMessage(l10n, failure))),
        );
      }
    }),
  );
}
