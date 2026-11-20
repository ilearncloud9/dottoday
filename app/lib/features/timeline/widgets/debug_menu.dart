import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/dev/demo_day_loader.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debug-build-only header menu entries (M3.1a). Every reference sits
/// behind [kDebugMode], a compile-time constant, so release builds drop
/// this code and the demo data with it.
List<ContextMenuEntry<VoidCallback>> debugMenuItems(BuildContext context) {
  if (!kDebugMode) return const [];
  return [
    ContextMenuEntry(
      value: () => unawaited(_loadDemoDay(context)),
      label: context.l10n.debugLoadDemoDay,
      divided: true,
    ),
    ContextMenuEntry(
      value: () => unawaited(_loadM11(context)),
      label: context.l10n.debugLoadM11Sample,
    ),
  ];
}

/// Real times and routines on top of the demo day (M11.6 sweeps).
Future<void> _loadM11(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final profile = await container.read(localProfileProvider.future);
  final result = await container
      .read(demoDayLoaderProvider)
      .loadM11(
        day: (from, to) => container
            .read(occurrenceRepositoryProvider)
            .watchRange(profile.id, from, to)
            .first,
      );
  final text = switch (result) {
    Ok() => l10n.debugM11Loaded,
    Err(:final failure) => failureMessage(l10n, failure),
  };
  messenger.showSnackBar(SnackBar(content: Text(text)));
}

Future<void> _loadDemoDay(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final result = await container.read(demoDayLoaderProvider).load();
  final text = switch (result) {
    Ok() => l10n.debugDemoDayLoaded,
    Err(:final failure) => failureMessage(l10n, failure),
  };
  messenger.showSnackBar(SnackBar(content: Text(text)));
}
