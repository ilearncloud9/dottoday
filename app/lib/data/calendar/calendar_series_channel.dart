import 'package:dottoday/core/logging/logger.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:flutter/services.dart';

/// `dottoday/calendar_series` (docs/02 F5.7): whole-series edits of a
/// repeating device-calendar event, native on iOS/macOS
/// (`CalendarSeriesBridge.swift`) and Android (`CalendarSeries.kt`). The
/// plugin can't be used: it saves its own copy of the repeat rule and
/// invitees. Only codes are logged, never titles.
final class CalendarSeriesChannel {
  const CalendarSeriesChannel(
    this._logger, [
    this._channel = const MethodChannel('dottoday/calendar_series'),
  ]);

  final Logger _logger;
  final MethodChannel _channel;

  Future<EventWriteResult> update(SeriesUpdate u) => _call('update', {
    'calendarId': u.calendarId,
    'eventId': u.eventId,
    'shiftMs': u.shift.inMilliseconds,
    'durationMs': ?u.duration?.inMilliseconds,
    'title': ?u.title,
  });

  Future<EventWriteResult> delete(String calendarId, String eventId) =>
      _call('delete', {'calendarId': calendarId, 'eventId': eventId});

  Future<EventWriteResult> _call(
    String method,
    Map<String, Object> args,
  ) async {
    try {
      return switch (await _channel.invokeMethod<String>(method, args)) {
        'written' => EventWriteResult.written,
        'gone' => EventWriteResult.gone,
        'notWritable' => EventWriteResult.notWritable,
        _ => EventWriteResult.failed,
      };
    } on PlatformException catch (e, st) {
      _logger.warn('calendar.series_failed', error: e, stackTrace: st);
      return EventWriteResult.failed;
    } on MissingPluginException {
      return EventWriteResult.notWritable;
    }
  }
}
