import 'package:dottoday/domain/entities/calendar_series.dart';
import 'package:dottoday/domain/entities/enums.dart';

/// What a person set for a repeating calendar event ([CalendarSeries]),
/// named by the calendar's provider ids instead of this device's
/// `calendar_accounts` row: the D1 export's `calendarSeries` section and a
/// restored, not-yet-attached template (CR-160 Stage A). A file can't name
/// a local account row, so the calendar is [provider] +
/// [externalCalendarId] (`calendar_accounts.external_account_id`), and the
/// series is [CalendarSeries.seriesKey].
///
/// Those ids are only as stable as their provider makes them
/// (docs/05 "Export format", `calendarSeries`): a device calendar's id is
/// this device's, and a Google/Microsoft calendar's is
/// `<server connection id>/<provider calendar id>`, whose connection id
/// is gone once the account is deleted. [deviceTag] names the install a
/// device template came from; see `attachPendingCalendarSeries` for when
/// a template is attached.
final class CalendarSeriesTemplate {
  const CalendarSeriesTemplate({
    required this.provider,
    required this.externalCalendarId,
    required this.settings,
    this.deviceTag,
  });

  /// Decodes one `calendarSeries` item. Throws [TypeError] or
  /// [ArgumentError] on a wrong shape, as the rest of the file does.
  factory CalendarSeriesTemplate.fromJson(Map<String, Object?> json) {
    final wire = json['provider']! as String;
    final provider = CalendarProvider.values.where((p) => p.wire == wire);
    if (provider.isEmpty) throw ArgumentError.value(wire, 'provider');
    return CalendarSeriesTemplate(
      provider: provider.single,
      externalCalendarId: json['external_calendar_id']! as String,
      deviceTag: json['device_tag'] as String?,
      // A template has no local account row: the settings read without one.
      settings: CalendarSeries.fromJson({...json, 'account_id': ''}),
    );
  }

  final CalendarProvider provider;

  /// The provider's calendar id, as `calendar_accounts.external_account_id`
  /// holds it.
  final String externalCalendarId;

  /// The install a device calendar's template was exported on (null for a
  /// cloud calendar, or when unknown). Not a person's identifier.
  final String? deviceTag;

  /// Every setting, the series key and the owner; `accountId` is empty.
  final CalendarSeries settings;

  String get id => settings.id;
  String get userId => settings.userId;
  String get seriesKey => settings.seriesKey;

  /// Whether [provider] is a device calendar store (ids local to it).
  bool get isDevice =>
      provider == CalendarProvider.appleDevice ||
      provider == CalendarProvider.androidDevice;

  /// One `calendarSeries` item: the settings' JSON without `account_id`.
  Map<String, Object?> toJson() => {
    ...settings.toJson()..remove('account_id'),
    'provider': provider.wire,
    'external_calendar_id': externalCalendarId,
    'device_tag': deviceTag,
  };

  CalendarSeriesTemplate copyWith({
    CalendarSeries? settings,
    String? externalCalendarId,
  }) => CalendarSeriesTemplate(
    provider: provider,
    externalCalendarId: externalCalendarId ?? this.externalCalendarId,
    deviceTag: deviceTag,
    settings: settings ?? this.settings,
  );

  /// The same template owned by [userId].
  CalendarSeriesTemplate reownedTo(String userId) =>
      copyWith(settings: settings.copyWith(userId: userId));
}
