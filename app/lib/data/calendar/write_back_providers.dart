import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/calendar/calendar_providers.dart';
import 'package:dottoday/data/calendar/calendar_write_back.dart';
import 'package:dottoday/data/calendar/device_calendar_writer.dart';
import 'package:dottoday/data/daos/calendar_links_dao.dart';
import 'package:dottoday/data/db/database_providers.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/calendar/write_back_merge.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'write_back_providers.g.dart';

/// Write-back to calendars (docs/09 M7.3): the device writer for device
/// calendars; Google and Microsoft writers plug in here in M7.4.
@Riverpod(keepAlive: true)
CalendarWriteBack calendarWriteBack(Ref ref) {
  final device = DeviceCalendarWriter(ref.watch(deviceCalendarGatewayProvider));
  return CalendarWriteBack(
    db: ref.watch(appDatabaseProvider),
    writerFor: (provider) => switch (provider) {
      CalendarProvider.appleDevice || CalendarProvider.androidDevice => device,
      CalendarProvider.google ||
      CalendarProvider.microsoft ||
      CalendarProvider.caldav => null,
    },
    effects: ref.watch(afterWriteEffectsProvider),
    clock: ref.watch(clockProvider),
    logger: ref.watch(loggerProvider),
  );
}

/// Where an imported event's edits go, as the editor says it (docs/03
/// §3.4 "calendar write-back status", R-02 "says so").
final class CalendarWriteStatus {
  const CalendarWriteStatus({required this.calendar, required this.sends});

  /// The calendar's name.
  final String calendar;

  /// Whether moves, resizes and renames go back to it.
  final bool sends;
}

/// The write-back status of the imported event linked by [linkId]; null
/// when the link is gone.
@riverpod
Stream<CalendarWriteStatus?> calendarWriteStatus(
  Ref ref,
  String linkId,
) async* {
  final profile = await ref.watch(currentProfileProvider.future);
  yield* CalendarLinksDao(
    ref.watch(appDatabaseProvider),
  ).linkWithAccount(profile.id, linkId).watchSingleOrNull().map((row) {
    if (row == null) return null;
    final (link, account) = row;
    return CalendarWriteStatus(
      calendar: account.label,
      sends:
          account.writeBack &&
          account.enabled &&
          !link.readOnly &&
          writeBackProviders.contains(account.provider),
    );
  });
}

/// What the write-back banner shows: edits that couldn't reach their
/// calendar, and events changed on both sides.
final class WriteBackState {
  const WriteBackState({this.failed = 0, this.clashes = 0});

  final int failed;
  final int clashes;
}

/// Sends edits of imported events back as they happen (a short pause
/// first, so typing a title sends once), and keeps what needs the person
/// for the banner. A failed or clashing item is not retried on its own
/// until it changes again or the person taps Retry (no retry storm).
@Riverpod(keepAlive: true)
class WriteBackController extends _$WriteBackController {
  /// How long edits settle before they are sent. Behaviour, not motion.
  static const settle = Duration(seconds: 2);

  final _attempted = <String, String>{};
  final _failed = <String>{};
  final _clashes = <String>{};
  var _pending = const <PendingWriteBack>[];
  StreamSubscription<List<PendingWriteBack>>? _watch;
  String? _userId;
  var _started = false;
  Timer? _timer;
  Future<void> _queue = Future.value();

  @override
  WriteBackState build() {
    ref.onDispose(() {
      _timer?.cancel();
      unawaited(_watch?.cancel());
    });
    return const WriteBackState();
  }

  /// Starts following edits (idempotent). Called where calendars are
  /// imported, so nothing watches the database on a device without them.
  void start() {
    if (_started) return;
    _started = true;
    // Sign-in re-keys the profile: follow its id.
    ref.listen(
      currentProfileProvider,
      (_, next) => _follow(next.value?.id),
      fireImmediately: true,
    );
  }

  /// Sends what is waiting now (before an import reads the calendars).
  Future<void> flush() {
    _timer?.cancel();
    return _send(_fresh());
  }

  /// The banner's Retry: everything that couldn't be sent, again.
  Future<void> retry() => _send([
    for (final p in _pending)
      if (_failed.contains(p.link.id)) p,
  ]);

  /// The banner's Keep mine / Use calendar's, for every clash.
  Future<void> resolve(WriteBackPrefer prefer) => _send([
    for (final p in _pending)
      if (_clashes.contains(p.link.id)) p,
  ], prefer: prefer);

  void _follow(String? userId) {
    if (userId == null || userId == _userId) return;
    _userId = userId;
    unawaited(_watch?.cancel());
    _watch = ref
        .read(calendarWriteBackProvider)
        .watchPending(userId)
        .listen(_onPending);
  }

  void _onPending(List<PendingWriteBack> pending) {
    _pending = pending;
    final ids = {for (final p in pending) p.link.id};
    _failed.retainAll(ids);
    _clashes.retainAll(ids);
    _attempted.removeWhere((id, _) => !ids.contains(id));
    _publish();
    if (_fresh().isEmpty) return;
    _timer?.cancel();
    _timer = Timer(settle, () => unawaited(flush()));
  }

  /// Pending items not already tried as they are now.
  List<PendingWriteBack> _fresh() => [
    for (final p in _pending)
      if (_attempted[p.link.id] != p.signature) p,
  ];

  Future<void> _send(
    List<PendingWriteBack> items, {
    WriteBackPrefer prefer = WriteBackPrefer.ask,
  }) {
    if (items.isEmpty) return _queue;
    final run = _queue.then((_) => _push(items, prefer));
    _queue = run.then((_) {}, onError: (_) {});
    return run;
  }

  Future<void> _push(
    List<PendingWriteBack> items,
    WriteBackPrefer prefer,
  ) async {
    try {
      final profile = await ref.read(currentProfileProvider.future);
      final untitled = lookupAppLocalizations(
        Locale(profile.locale),
      ).calendarEventUntitled;
      final report = await ref
          .read(calendarWriteBackProvider)
          .push(items, untitled: untitled, prefer: prefer);
      for (final p in items) {
        final id = p.link.id;
        final failed = report.failed.contains(id);
        final clash = report.clashes.contains(id);
        failed ? _failed.add(id) : _failed.remove(id);
        clash ? _clashes.add(id) : _clashes.remove(id);
        if (failed || clash) _attempted[id] = p.signature;
      }
    } on Object catch (e, s) {
      // Nothing was stored for these; they count as not sent.
      ref
          .read(loggerProvider)
          .warn('calendar.write_back_failed', error: e, stackTrace: s);
      for (final p in items) {
        _failed.add(p.link.id);
        _attempted[p.link.id] = p.signature;
      }
    }
    if (ref.mounted) _publish();
  }

  void _publish() =>
      state = WriteBackState(failed: _failed.length, clashes: _clashes.length);
}
