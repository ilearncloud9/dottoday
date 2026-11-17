import 'dart:convert';

/// The shared action queue (docs/09 M9.2, ADR-0010): where a surface that
/// runs without the app — a widget, a control, the Live Activity, the
/// service worker, the share extension, later the watch — leaves its
/// actions. The app drains it on launch, on resume and in the background
/// job.
///
/// Entries are raw JSON maps (`encodeQueuedAction`); the store never
/// interprets them. Every entry carries the owner the surface stamped it
/// with from [publish] (CR-160 I7); entries are removed only once
/// their own owner applied them or they reached a terminal state.
abstract interface class ActionQueueStore {
  /// Every entry, oldest first, as written.
  Future<List<Object?>> read();

  /// Removes the entries whose `id` is in [ids]; keeps everything else,
  /// including entries appended since [read]. Entries that can't be read
  /// are never removed here (CR-160 I7: kept, never applied).
  Future<void> remove(Set<String> ids);

  /// Tells the surfaces what to do with the next entries: stamp the shown
  /// owner, stamp nobody while a change of owner is under way, or refuse
  /// them (an account deletion in progress). Written under the same lock
  /// as the native appends.
  Future<void> publish(QueueMarker marker);
}

/// What the queue's surfaces do with a new entry (CR-160 I7).
sealed class QueueMarker {
  const QueueMarker();
}

/// Stamp entries with the owner the app shows.
final class QueueOwner extends QueueMarker {
  const QueueOwner(this.id, {this.guestSession});

  /// The shown profile's id: an account id, or the guest profile's.
  final String id;

  /// The current guest session when [id] is the guest (policy §3).
  final String? guestSession;
}

/// A change of owner is under way: entries name nobody, so the app keeps
/// them and never applies them (quarantine).
final class QueueSwitching extends QueueMarker {
  const QueueSwitching();
}

/// The shown account is being deleted: surfaces refuse new entries and say
/// so, rather than queue work that would vanish with the account or land
/// with the next owner.
final class QueueRefusing extends QueueMarker {
  const QueueRefusing();
}

/// Key of the published marker in the native shared stores, beside
/// `action_queue` (ios/Shared/DotStore.swift, DotQueue.kt).
const queueOwnerKey = 'action_queue_owner';

/// Most entries a surface may queue; past it a new entry is refused, never
/// an older one evicted (CR-160 I7 retention).
const queueCapacity = 500;

/// The marker's wire form, as Swift, Kotlin and `web/action_queue.js` read
/// it: `{"v": 1, "owner", "guest_session"}`, `{"v": 1, "switching": true}`
/// or `{"v": 1, "refuse": true}`.
String encodeQueueMarker(QueueMarker marker) => jsonEncode({
  'v': 1,
  ...switch (marker) {
    QueueOwner(:final id, :final guestSession) => {
      'owner': id,
      'guest_session': ?guestSession,
    },
    QueueSwitching() => {'switching': true},
    QueueRefusing() => {'refuse': true},
  },
});
