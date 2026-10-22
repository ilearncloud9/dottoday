import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/domain/entities/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Applies [change] at once (03 §3.7 "Changes apply immediately"); a
/// refused change (validation) says why.
void changeSettings(
  BuildContext context,
  Settings Function(Settings settings) change,
) {
  final container = ProviderScope.containerOf(context);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  unawaited(
    updateSettings(container, change).then((result) {
      if (result case Err(:final failure)) {
        messenger.showSnackBar(
          SnackBar(content: Text(failureMessage(l10n, failure))),
        );
      }
    }),
  );
}
