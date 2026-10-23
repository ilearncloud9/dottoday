import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/data/sync/sync_engine.dart';
import 'package:dottoday/data/sync/sync_gateway.dart';

/// One sync round trip from the OS background job (docs/09 M6.5.6,
/// 11 A0, ADR-0008), so a day planned on the Mac is on the phone before
/// Wake Up. The foreground keeps `EngineSyncService` (resume, Realtime,
/// timers); this is only the job's single pull/push.
///
/// Signed out, or signed in but not yet adopted on this device (the
/// account id isn't the local profile yet), it does nothing: adoption and
/// the first sync's progress belong to the app (M6.4). A failure never
/// touches local rows (the engine keeps the outbox) and is only logged.
final class BackgroundSync {
  BackgroundSync({
    required SyncEngine engine,
    required String? Function() accountId,
    required Logger logger,
  }) : _engine = engine,
       _accountId = accountId,
       _logger = logger;

  final SyncEngine _engine;
  final String? Function() _accountId;
  final Logger _logger;

  /// Syncs [profileId]'s rows; true unless a round trip failed.
  Future<bool> run(String profileId) async {
    final account = _accountId();
    if (account == null || account != profileId) return true;
    try {
      final run = await _engine.run(account);
      _logger.info(
        'sync.background_done',
        fields: {'pulled': run.pulled, 'pushed': run.pushed},
      );
      return true;
    } on SyncGatewayException catch (e, s) {
      if (e.trouble == SyncTrouble.offline) {
        _logger.info('sync.background_offline');
      } else {
        _logger.warn('sync.background_refused', error: e.cause, stackTrace: s);
      }
      return false;
    } on Object catch (e, s) {
      _logger.error('sync.background_failed', error: e, stackTrace: s);
      return false;
    }
  }
}
