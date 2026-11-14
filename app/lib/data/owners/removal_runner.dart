import 'dart:async';

import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/data/owners/owner_switch.dart';
import 'package:dottoday/data/sync/account_owners.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'removal_runner.g.dart';

/// On iPhone, Android and the Mac, a deleted account's removal that an
/// interruption left pending finishes by itself at launch (CR-160 policy
/// §4); a failure retries later, waiting twice as long each time up to
/// [_retryMax], and the copy stays hidden meanwhile. The web asks instead
/// ("Finish removing", the account gate). Watched by the account gate.
@Riverpod(keepAlive: true)
Future<void> pendingRemovalRunner(Ref ref) async {
  if (ref.watch(inBrowserProvider)) return;
  final db = ref.watch(appDatabaseProvider);
  final logger = ref.watch(loggerProvider);
  Timer? retry;
  ref.onDispose(() => retry?.cancel());
  var wait = _retryFirst;
  Future<void> run() async {
    try {
      for (final id in await pendingRemovals(db)) {
        await ref.read(ownerSwitchProvider).finishRemoval(id);
      }
    } on Exception catch (e, s) {
      logger.warn('account.removal_retry', error: e, stackTrace: s);
      retry = Timer(wait, () => unawaited(run()));
      wait = wait * 2 > _retryMax ? _retryMax : wait * 2;
    }
  }

  await run();
}

const _retryFirst = Duration(seconds: 30);
const _retryMax = Duration(minutes: 10);
