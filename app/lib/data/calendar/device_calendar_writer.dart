import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/calendar/calendar_writer.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/calendar/imported_event.dart';

/// [CalendarWriter] for this device's calendars (EventKit, Calendar
/// Provider; docs/09 M7.3). They have no etags, so the version is a
/// fingerprint of what write-back looks at, compared right before the
/// write: a change made in the calendar since it was read is never
/// overwritten unseen.
final class DeviceCalendarWriter implements CalendarWriter {
  const DeviceCalendarWriter(this._gateway);

  final DeviceCalendarGateway _gateway;

  @override
  Future<Result<RemoteEvent?, AppFailure>> read(EventAddress at) async {
    final found = await _gateway.event(at.calendarId, at.eventId);
    return switch (found) {
      Err(:final failure) => Err(failure),
      Ok(:final value) => Ok(value == null ? null : _remote(value)),
    };
  }

  @override
  Future<WriteBackOutcome> write(
    EventAddress at,
    EventPatch patch, {
    required String expectedVersion,
  }) async {
    final RemoteEvent? now;
    switch (await read(at)) {
      case Err():
        return WriteBackOutcome.failed;
      case Ok(:final value):
        now = value;
    }
    if (now == null) return WriteBackOutcome.gone;
    if (now.version != expectedVersion) return WriteBackOutcome.changed;
    if (!now.writable) return WriteBackOutcome.notWritable;
    final result = await _gateway.updateEvent(
      EventUpdate(
        calendarId: at.calendarId,
        eventId: at.eventId,
        startUtc: patch.startUtc,
        endUtc: patch.endUtc,
        title: patch.title,
      ),
    );
    return _outcome(result);
  }

  @override
  Future<WriteBackOutcome> writeSeries(
    EventAddress at,
    SeriesPatch patch,
  ) async => _outcome(
    await _gateway.updateSeries(
      SeriesUpdate(
        calendarId: at.calendarId,
        eventId: at.eventId,
        shift: patch.shift,
        duration: patch.duration,
        title: patch.title,
      ),
    ),
  );

  @override
  Future<WriteBackOutcome> deleteSeries(EventAddress at) async =>
      _outcome(await _gateway.deleteSeries(at.calendarId, at.eventId));

  static WriteBackOutcome _outcome(EventWriteResult r) => switch (r) {
    EventWriteResult.written => WriteBackOutcome.written,
    EventWriteResult.gone => WriteBackOutcome.gone,
    EventWriteResult.notWritable => WriteBackOutcome.notWritable,
    EventWriteResult.failed => WriteBackOutcome.failed,
  };

  static RemoteEvent _remote(ExternalEvent e) => RemoteEvent(
    startUtc: e.startUtc,
    endUtc: e.endUtc,
    title: e.title,
    // Hashes, never the title itself (it could end up in a log).
    version: [
      e.startUtc.millisecondsSinceEpoch,
      e.endUtc.millisecondsSinceEpoch,
      textHash(e.title),
      e.allDay,
      e.repeating,
    ].join(';'),
    writable: !e.allDay && !e.repeating,
  );
}
