import 'package:dottoday/data/db/tables/columns.dart';
import 'package:drift/drift.dart';

/// One row per local owner (docs/05 `profiles`). Before sign-in the id is a
/// locally generated UUID v7; first sync re-owns it to the auth user id
/// (M6.4), which `ON UPDATE CASCADE` on every `user_id` carries along.
@DataClassName('ProfileRow')
class Profiles extends Table with TimestampColumns, SyncColumns {
  TextColumn get id => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get tzId => text().withDefault(const Constant('UTC'))();
  TextColumn get locale => text().withDefault(const Constant('en'))();

  /// `Settings` JSON (docs/05 "Settings JSON"); validated in the repository.
  TextColumn get settings =>
      text().withDefault(const Constant('{"dayBoundaries":{}}'))();

  /// The account's own colours (ED-220, server 0017): a JSON array of at
  /// most 24 `#RRGGBB`, newest first; validated in the repository.
  TextColumn get yourColours => text()
      .withDefault(const Constant('[]'))
      // Drift's documented column CHECK reads the column it declares.
      // ignore: recursive_getters
      .check(FunctionCallExpression<bool>('json_valid', [yourColours]))();

  /// A custom accent's `#RRGGBB` (server 0017); null = `settings.accent`.
  TextColumn get accentHex =>
      text().nullable().check(accentHex.length.equals(7))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'CHECK (length(tz_id) <= 64)',
    'CHECK (length(locale) <= 16)',
    'CHECK (display_name IS NULL OR length(display_name) <= 80)',
    'CHECK (json_valid(settings))',
  ];

  @override
  bool get isStrict => true;
}
