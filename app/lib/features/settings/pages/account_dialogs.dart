import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/profile/settings_actions.dart';
import 'package:dottoday/shared/sheets/dot_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Your name": the greeting's and the avatar's name (Settings › Account).
/// An empty name clears it.
Future<void> renameProfile(BuildContext context, String current) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final name = await showTextAlert(
    context,
    title: l10n.accountNameTitle,
    initial: current,
    action: l10n.accountNameSave,
    cancel: l10n.editorCancel,
  );
  if (name == null || name.trim() == current) return;
  final trimmed = name.trim();
  final result = await updateProfile(
    container,
    (p) => p.copyWith(displayName: trimmed.isEmpty ? null : trimmed),
  );
  if (result case Err(:final failure)) {
    messenger.showSnackBar(
      SnackBar(content: Text(failureMessage(l10n, failure))),
    );
  }
}
