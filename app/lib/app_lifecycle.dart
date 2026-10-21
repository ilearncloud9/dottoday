import 'dart:async';

import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/backup/backup_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Housekeeping on app start and on every resume (docs/09 M3.2, M2.3–M2.5):
/// ensure the local profile, take the daily backup if due, purge expired
/// Trash and re-sync OS notifications. Each step is idempotent and runs
/// after the first frame, so it never delays the UI; failures are logged
/// and the next start/resume repairs them.
Future<void> runHousekeeping(WidgetRef ref) async {
  final logger = ref.read(loggerProvider);
  try {
    final profile = await ref.read(localProfileProvider.future);
    final backup = await ref
        .read(backupServiceProvider)
        .runDailyIfDue(profile.id);
    if (backup case Err(:final failure)) {
      logger.warn('housekeeping.backup_failed', error: failure);
    }
    final purge = await ref.read(trashServiceProvider).purgeExpired(profile.id);
    if (purge case Err(:final failure)) {
      logger.warn('housekeeping.purge_failed', error: failure);
    }
    await ref.read(notificationSyncProvider).resync(profile.id);
  } on Object catch (e, st) {
    logger.error('housekeeping.failed', error: e, stackTrace: st);
  }
}

/// Runs [runHousekeeping] once after the first frame and on each resume.
class AppLifecycleScope extends ConsumerStatefulWidget {
  const AppLifecycleScope({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLifecycleScope> createState() => _AppLifecycleScopeState();
}

class _AppLifecycleScopeState extends ConsumerState<AppLifecycleScope>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(runHousekeeping(ref)),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(runHousekeeping(ref));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
