import 'package:dottoday/data/db/tables/columns.dart';
import 'package:dottoday/data/db/tables/profiles.dart';
import 'package:drift/drift.dart';

/// Connected calendars (docs/05 `calendar_accounts`). OAuth tokens never
/// live here (Supabase Vault, 06 §1). Not pushed via `sync_push`, so no
/// sync columns; calendar data syncs through its provider (M7).
@DataClassName('CalendarAccountRow')
@TableIndex(
  name: 'calendar_accounts_user_updated',
  columns: {#userId, #updatedAt},
)
class CalendarAccounts extends Table with TimestampColumns {
  TextColumn get id => text()();
  TextColumn get userId => text().references(
    Profiles,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get provider => text()();
  TextColumn get label => text()();
  TextColumn get externalAccountId => text().nullable()();
  BoolColumn get writeBack => boolean().withDefault(const Constant(false))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    "CHECK (provider IN ('apple_device', 'android_device', 'google', "
        "'microsoft', 'caldav'))",
    'CHECK (length(label) <= 80)',
    'CHECK (external_account_id IS NULL OR length(external_account_id) <= 256)',
  ];

  @override
  bool get isStrict => true;
}

/// External event ↔ occurrence mapping (docs/05 `calendar_links`).
@DataClassName('CalendarLinkRow')
@TableIndex(
  name: 'calendar_links_user_event',
  columns: {#userId, #externalEventId},
)
@TableIndex(
  name: 'calendar_links_account_event',
  columns: {#userId, #accountId, #externalEventId},
  unique: true,
)
class CalendarLinks extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(
    Profiles,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get accountId =>
      text().references(CalendarAccounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get externalCalendarId => text()();
  TextColumn get externalEventId => text()();
  TextColumn get etag => text().nullable()();
  IntColumn get lastSyncedUtc => integer().nullable()();
  BoolColumn get readOnly => boolean().withDefault(const Constant(true))();

  /// The event's place (M7.5, R-17): travel time is suggested before an
  /// event that has one. Column-level CHECK so ALTER TABLE keeps it.
  TextColumn get location => text().nullable().check(
    const CustomExpression<bool>('location IS NULL OR length(location) <= 200'),
  )();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'CHECK (length(external_calendar_id) <= 256)',
    'CHECK (length(external_event_id) <= 512)',
  ];

  @override
  bool get isStrict => true;
}
