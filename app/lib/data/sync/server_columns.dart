/// What `sync_push` may write per entity (supabase/migrations/0001), and
/// how values cross between the local JSON form and the server's columns
/// (docs/04 §4, docs/09 M6.2).
///
/// Locally every instant is epoch milliseconds (docs/05 intro); on the
/// server it is `timestamptz`. Everything else crosses as it is.
library;

/// Synced entities, in the order their rows may reference each other:
/// series before the occurrences they make, occurrences before subtasks;
/// routines reference only the profile.
const syncedEntities = [
  'profiles',
  'series',
  'occurrences',
  'subtasks',
  'routines',
];

/// The columns a change may set (never `id`, `user_id`, `updated_at`).
/// `calendar_link_id` stays on the device until calendar links sync (M7).
const pushableColumns = <String, Set<String>>{
  'profiles': {'display_name', 'tz_id', 'locale', 'settings', 'created_at'},
  'series': {
    'title',
    'notes',
    'color_key',
    'icon_key',
    'duration_min',
    'rrule',
    'dtstart_local',
    'tz_id',
    'until_utc',
    'count',
    'pinned',
    'travel_buffer_min',
    'energy',
    'alerts',
    'sound_id',
    'subtask_template',
    'duration_from_steps',
    'materialised_through_utc',
    'archived_at',
    'created_at',
    'deleted_at',
  },
  'occurrences': {
    'series_id',
    'original_start_utc',
    'title',
    'notes',
    'color_key',
    'icon_key',
    'start_utc',
    'tz_id',
    'duration_min',
    'pinned',
    'travel_buffer_min',
    'energy',
    'alerts',
    'sound_id',
    'status',
    'completed_at_utc',
    'sort_order',
    'source',
    'snoozed_until_utc',
    'actual_start_utc',
    'actual_end_utc',
    'duration_from_steps',
    'move_count',
    'routine_start',
    'created_at',
    'deleted_at',
  },
  'subtasks': {
    'occurrence_id',
    'title',
    'done',
    'sort_order',
    'duration_min',
    'done_at',
    'created_at',
    'deleted_at',
  },
  'routines': {
    'title',
    'anchor',
    'anchor_minute',
    'items',
    'sort_order',
    'created_at',
    'deleted_at',
  },
};

/// Whether [field] holds an instant (`*_utc`, `*_at`).
bool isInstantField(String field) =>
    field.endsWith('_utc') || field.endsWith('_at');

/// A local JSON value as the server column takes it.
Object? toServerValue(String field, Object? value) =>
    isInstantField(field) && value is int
    ? DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toIso8601String()
    : value;

/// A server column value as the local JSON form holds it.
Object? toLocalValue(String field, Object? value) =>
    isInstantField(field) && value is String
    ? DateTime.parse(value).toUtc().millisecondsSinceEpoch
    : value;

/// A server row in the local JSON form (instants as milliseconds).
Map<String, Object?> toLocalRow(Map<String, Object?> row) => {
  for (final MapEntry(:key, :value) in row.entries)
    key: toLocalValue(key, value),
};
