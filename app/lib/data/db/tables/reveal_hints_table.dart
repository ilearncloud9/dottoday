import 'package:dottoday/data/db/tables/columns.dart';
import 'package:dottoday/data/db/tables/profiles.dart';
import 'package:drift/drift.dart';

/// Minimal mode's reveal hints (docs/14 §5–§6): one row per user and hint,
/// counting how often it showed and whether *Not now* retired it. Schema 9
/// (M16).
@DataClassName('RevealHintRow')
@TableIndex(name: 'reveal_hints_user', columns: {#userId})
@TableIndex.sql(
  'CREATE INDEX reveal_hints_dirty ON reveal_hints (dirty) WHERE dirty = 1',
)
class RevealHintsTable extends Table with TimestampColumns, SyncColumns {
  @override
  String get tableName => 'reveal_hints';

  TextColumn get id => text()();
  TextColumn get userId => text().references(
    Profiles,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get hintId => text()();
  IntColumn get shownCount => integer().withDefault(const Constant(0))();
  IntColumn get lastShownUtc => integer().nullable()();
  IntColumn get dismissedAtUtc => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  // Mirrors the server checks in supabase/migrations/0010_minimal_mode.sql
  // and 0012_wake_up_discovery.sql (the hint list).
  @override
  List<String> get customConstraints => const [
    'UNIQUE (user_id, hint_id)',
    "CHECK (hint_id IN ('unstick', 'routines', 'breakDown', 'nextUpWidget', "
        "'weekReview', 'learnedDefaults', 'wakeUpPromise', 'wakeUpStartDay', "
        "'wakeUpShift', 'wakeUpCheckPing', 'missionOffer'))",
    'CHECK (shown_count BETWEEN 0 AND 2)',
  ];

  @override
  bool get isStrict => true;
}
