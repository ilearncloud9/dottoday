/// The shared action queue (docs/09 M9.2, ADR-0010): where a surface that
/// runs without the app — a widget, a control, the Live Activity, the
/// service worker, later the watch — leaves its actions. The app drains it
/// on launch, on resume and in the background job.
///
/// Entries are raw JSON maps (`encodeQueuedAction`); the store never
/// interprets them, so a malformed entry can still be removed.
abstract interface class ActionQueueStore {
  /// Every entry, oldest first, as written.
  Future<List<Object?>> read();

  /// Removes the entries whose `id` is in [ids] and, when [unreadable],
  /// every entry that isn't a map with a string `id`; keeps everything
  /// else, including entries appended since [read].
  Future<void> remove(Set<String> ids, {bool unreadable = false});
}
