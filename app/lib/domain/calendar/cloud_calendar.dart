import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/calendar/calendar_writer.dart';
import 'package:dottoday/domain/calendar/device_calendar.dart';
import 'package:dottoday/domain/entities/enums.dart';

/// Whether a connected account's calendars can be read right now.
enum CloudAccountStatus {
  ok,

  /// The grant was revoked or expired: connect it again.
  reconnect,

  /// The provider didn't answer; worth another try later.
  failed,
}

/// A Google or Microsoft account connected through the backend (docs/09
/// M7.4): its tokens stay in Supabase Vault, the app only knows its id.
final class CloudAccount {
  const CloudAccount({
    required this.id,
    required this.provider,
    required this.label,
    required this.status,
    this.calendars = const [],
  });

  /// The server's `calendar_accounts.id`.
  final String id;
  final CalendarProvider provider;

  /// Its email address, as the provider names it.
  final String label;
  final CloudAccountStatus status;

  /// Empty unless [status] is [CloudAccountStatus.ok].
  final List<DeviceCalendar> calendars;
}

/// Google and Microsoft calendars through the `calendar-oauth` and
/// `calendar-sync` Edge Functions (docs/04 §7, ADR-0011): read for the
/// import like device calendars, written back with the event's etag.
abstract interface class CloudCalendars
    implements CalendarEventReader, CalendarWriter {
  /// The signed-in account's connections, each with its calendars.
  Future<Result<List<CloudAccount>, AppFailure>> accounts();

  /// The provider's sign-in page for connecting [provider]; afterwards the
  /// browser comes back to [returnTo].
  Future<Result<Uri, AppFailure>> connectUrl(
    CalendarProvider provider,
    String returnTo,
  );

  /// Removes connection [accountId] and its tokens.
  Future<Result<void, AppFailure>> disconnect(String accountId);
}
