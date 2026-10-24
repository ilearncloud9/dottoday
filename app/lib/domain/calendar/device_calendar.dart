import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/notifications/notification_permission.dart';

/// A calendar on this device (EventKit on iOS/macOS, CalendarContract on
/// Android; docs/02 F5, R-02), or of a connected Google/Microsoft account
/// (M7.4, [provider] set). [colorArgb] is the provider's colour, which
/// Dottoday inherits as the nearest task colour ([inheritColorKey]).
final class DeviceCalendar {
  const DeviceCalendar({
    required this.id,
    required this.name,
    this.accountName,
    this.colorArgb,
    this.readOnly = false,
    this.provider,
  });

  /// The provider's calendar id; stable on this device only. A connected
  /// account's calendar is `<account id>/<provider calendar id>`, the same
  /// on every device.
  final String id;
  final String name;

  /// "iCloud", "kody@example.com": the rows are grouped by it.
  final String? accountName;
  final int? colorArgb;

  /// Subscriptions and holidays: shown, never written back (M7.3).
  final bool readOnly;

  /// Google or Microsoft for a connected account's calendar; null for
  /// this device's own store.
  final CalendarProvider? provider;

  @override
  bool operator ==(Object other) =>
      other is DeviceCalendar &&
      other.id == id &&
      other.name == name &&
      other.accountName == accountName &&
      other.colorArgb == colorArgb &&
      other.readOnly == readOnly &&
      other.provider == provider;

  @override
  int get hashCode =>
      Object.hash(id, name, accountName, colorArgb, readOnly, provider);
}

/// One event read from a [DeviceCalendar], before it becomes an
/// occurrence (M7.2).
///
/// Timed events carry real instants. An all-day event has no instant: its
/// [startUtc] / [endUtc] hold the first day and the day after the last as
/// UTC midnights of those calendar dates, so it lands on the same dates in
/// any zone ([allDayDates]).
final class ExternalEvent {
  const ExternalEvent({
    required this.id,
    required this.calendarId,
    required this.title,
    required this.startUtc,
    required this.endUtc,
    this.allDay = false,
    this.location,
    this.description,
    this.url,
    this.repeating = false,
    this.editable = true,
  });

  final String id;
  final String calendarId;
  final String title;
  final DateTime startUtc;
  final DateTime endUtc;
  final bool allDay;
  final String? location;
  final String? description;
  final Uri? url;

  /// Whether it is an instance of a repeating event. The device stores
  /// can only change the whole series through the plugin, so such an
  /// instance is never written back (docs/09 M7.3).
  final bool repeating;

  /// Whether the event itself takes changes: false for a meeting someone
  /// else organises in a Google/Microsoft calendar (M7.4).
  final bool editable;
}

/// A move, resize or rename of one event sent to its calendar (docs/09
/// M7.3). A null [title] leaves the calendar's own title as it is.
final class EventUpdate {
  const EventUpdate({
    required this.calendarId,
    required this.eventId,
    required this.startUtc,
    required this.endUtc,
    this.title,
  });

  final String calendarId;
  final String eventId;
  final DateTime startUtc;
  final DateTime endUtc;
  final String? title;
}

/// What a device calendar did with an [EventUpdate].
enum EventWriteResult {
  written,

  /// The event is no longer in the calendar.
  gone,

  /// The calendar or the event can't take changes (read only, repeating).
  notWritable,

  /// Anything else: no permission, the store refused; worth a retry.
  failed,
}

/// Where the import reads events from (docs/09 M7.2): this device's
/// calendars, or connected Google/Microsoft accounts (M7.4).
abstract interface class CalendarEventReader {
  /// Whether this source exists here at all.
  bool get available;

  /// [PermissionState.granted] once events may be read (the OS permission;
  /// for connected accounts, being signed in).
  Future<PermissionState> status();

  Future<Result<List<DeviceCalendar>, AppFailure>> calendars();

  /// Events of [calendarId] overlapping `[fromUtc, toUtc)`.
  Future<Result<List<ExternalEvent>, AppFailure>> events(
    String calendarId,
    DateTime fromUtc,
    DateTime toUtc,
  );
}

/// The device calendars (docs/04 §7): the OS permission, the list, and
/// their events. Web has none (Google/Microsoft via the backend, M7.4).
abstract interface class DeviceCalendarGateway implements CalendarEventReader {
  /// Shows the OS prompt (once; afterwards only Settings can change it).
  Future<PermissionState> request();

  /// Opens the system settings for Dottoday; false where that can't be
  /// done, so the UI says where to go instead.
  Future<bool> openSettings();

  /// The event [eventId] of [calendarId] as the calendar has it now, or
  /// null when it is gone (write-back's conflict check, M7.3).
  Future<Result<ExternalEvent?, AppFailure>> event(
    String calendarId,
    String eventId,
  );

  /// Changes the start, end and (when given) title of one event, leaving
  /// everything else on it as it is (M7.3).
  Future<EventWriteResult> updateEvent(EventUpdate update);
}

/// A device calendar as Settings › Calendars lists it: whether its events
/// come in and the task colour it inherits.
final class CalendarChoice {
  const CalendarChoice({
    required this.calendar,
    required this.enabled,
    required this.colorKey,
    this.writeBack = false,
  });

  final DeviceCalendar calendar;
  final bool enabled;
  final String colorKey;

  /// Whether moves, resizes and renames go back to it (opt-in, M7.3).
  final bool writeBack;
}
