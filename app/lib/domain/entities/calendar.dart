import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/utc_millis_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar.freezed.dart';
part 'calendar.g.dart';

/// A connected calendar source (docs/05 `calendar_accounts`). OAuth tokens
/// are deliberately absent: they live in Supabase Vault (06 §4).
@freezed
abstract class CalendarAccount with _$CalendarAccount {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CalendarAccount({
    required String id,
    required String userId,
    required CalendarProvider provider,
    required String label,
    String? externalAccountId,
    @Default(false) bool writeBack,
    @Default(true) bool enabled,
    @UtcMillisConverter() required DateTime createdAt,
    @UtcMillisConverter() required DateTime updatedAt,
  }) = _CalendarAccount;

  factory CalendarAccount.fromJson(Map<String, Object?> json) =>
      _$CalendarAccountFromJson(json);
}

/// Ties an imported occurrence to its external event (docs/05
/// `calendar_links`); [etag] detects upstream changes on re-sync.
@freezed
abstract class CalendarLink with _$CalendarLink {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CalendarLink({
    required String id,
    required String userId,
    required String accountId,
    required String externalCalendarId,
    required String externalEventId,
    String? etag,
    @UtcMillisConverter() DateTime? lastSyncedUtc,
    @Default(true) bool readOnly,

    /// The event's place, device-only like the link itself (M7.5, R-17).
    String? location,

    /// The repeating event it is an instance of ([ImportedItem.seriesKey]);
    /// null for a one-off event. Device-only (docs/02 F5.7).
    String? seriesKey,
  }) = _CalendarLink;

  factory CalendarLink.fromJson(Map<String, Object?> json) =>
      _$CalendarLinkFromJson(json);
}
