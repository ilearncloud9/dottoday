import 'dart:async';

import 'package:dottoday/core/failures/failure_messages.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/dev/demo_day_loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debug-build-only header menu entries (M3.1a). Every reference sits
/// behind [kDebugMode], a compile-time constant, so release builds drop
/// this code and the demo data with it.
List<PopupMenuEntry<void>> debugMenuItems(BuildContext context) {
  if (!kDebugMode) return const [];
  return [
    PopupMenuItem<void>(
      onTap: () => unawaited(_loadDemoDay(context)),
      child: Text(context.l10n.debugLoadDemoDay),
    ),
  ];
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
