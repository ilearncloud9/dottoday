import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/auth/account.dart';
import 'package:dottoday/domain/sync/clock_skew.dart';

/// Where sync stands (docs/02 F7, R-08): the pill, the banner and the Sync
/// sheet read this. [sessionEnded]: the server no longer accepts this
/// sign-in (E-G4-7 A10, CR-158; ED-482); only signing in again fixes it,
/// and the tasks stay on this device.
enum SyncState { localOnly, synced, syncing, offline, error, sessionEnded }

/// What "Sync now" reports once a run has ended in [state]: offline or a
/// refusing server are failures; anything else is fine.
Result<void, AppFailure> syncOutcome(SyncState state) => switch (state) {
  SyncState.offline => const Err(NetworkFailure(NetworkFailureKind.offline)),
  SyncState.error => const Err(NetworkFailure(NetworkFailureKind.server)),
  SyncState.sessionEnded => const Err(AuthFailure()),
  _ => const Ok(null),
};

/// A field two devices changed within a minute (docs/04 §4): the server's
/// value is applied; the user may keep theirs instead. [title] names the
/// task; [field], [mine] and [theirs] are display text, never logged.
final class SyncConflict {
  const SyncConflict({
    required this.id,
    required this.title,
    required this.field,
    required this.mine,
    required this.theirs,
    this.mineNotes,
    this.theirsNotes,
  });

  final String id;
  final String title;
  final ConflictField field;

  /// Each side as the card shows it ("9:00–11:00 AM", "—").
  final String mine;
  final String theirs;

  /// A notes conflict's two texts as stored, for Keep both and Copy (null
  /// for other fields, or empty notes).
  final String? mineNotes;
  final String? theirsNotes;
}

/// The fields a conflict can be about, for its label.
enum ConflictField { title, time, duration, notes, colour, status, other }

/// What the user picked for a conflict: [both] only for notes (ED-195).
enum ConflictChoice { mine, theirs, both }

/// How to take back a resolved conflict (Undo after resolving, ED-194;
/// M20.10 part 5, ED-483): put [restore] back in [entity] [entityId]'s
/// [column] as a new edit, but only while it still holds [expect]; if
/// another change came since, a new conflict opens instead. Values are
/// JSON, as the conflict stored them. [kept] and [field] word the toast.
final class ConflictUndo {
  const ConflictUndo({
    required this.entity,
    required this.entityId,
    required this.column,
    required this.restore,
    required this.expect,
    required this.kept,
    required this.field,
    required this.title,
  });

  final String entity;
  final String entityId;
  final String column;
  final String? restore;
  final String? expect;
  final ConflictChoice kept;
  final ConflictField field;

  /// The task's title, for the Mac and web popover's second line.
  final String title;
}

/// The note Keep both saves (ED-195): this device's notes, a blank line,
/// [label] ("— From your other device —"), the other device's notes.
///
/// ```dart
/// combinedNotes('Pull last quarter.', 'Ask Sam.', '— From your other device —');
/// // 'Pull last quarter.\n\n— From your other device —\nAsk Sam.'
/// ```
String combinedNotes(String? mine, String? theirs, String label) =>
    '${mine ?? ''}\n\n$label\n${theirs ?? ''}';

/// A snapshot of sync for the UI.
final class SyncStatus {
  const SyncStatus({
    required this.state,
    this.lastSyncedUtc,
    this.pending = 0,
    this.conflicts = const [],
    this.clockSkew,
  });

  /// No account: nothing to sync, nothing to show.
  static const localOnly = SyncStatus(state: SyncState.localOnly);

  final SyncState state;
  final DateTime? lastSyncedUtc;

  /// Local changes not yet pushed.
  final int pending;
  final List<SyncConflict> conflicts;

  /// Set when this device's clock is more than 5 min off the server's
  /// (M6.5.7): pulls go on; a fast clock's pushes wait until it is right.
  final ClockSkew? clockSkew;
}

/// The sync engine as the UI sees it (docs/04 §4); the real one arrives in
/// M6.3, the screens are built against this now (docs/09 M3f.8).
abstract interface class SyncService {
  Stream<SyncStatus> watch();

  /// Pull and push now ("Sync now").
  Future<Result<void, AppFailure>> syncNow();

  /// Keeps [choice] for conflict [id]; the other value is dropped. Keep
  /// both saves [combined] (notes only, within the notes limit). Returns
  /// how to take it back (Undo, ED-194).
  Future<Result<ConflictUndo, AppFailure>> resolve(
    String id,
    ConflictChoice choice, {
    String? combined,
  });

  /// Takes back a resolve ([undo]): the replaced value is saved as a new
  /// edit, or a new conflict opens if the value changed since.
  Future<Result<void, AppFailure>> undoResolve(ConflictUndo undo);

  /// An account's first sync bringing its rows down ("Bringing your
  /// tasks… 120 of 300", docs/09 M6.4); finished after every run, so the
  /// screen never waits on a device that is offline.
  Stream<RestoreProgress> watchRestore();

  /// D1's review (CR-160 W0, W2): this device holds everything the server
  /// has for [owner] at one server revision, nothing of it is still waiting
  /// to go up, and no conflict hides a local value. Bounded; never a guess.
  Future<DeletionCheck> verifyForDeletion(String owner);
}

/// What [SyncService.verifyForDeletion] established.
sealed class DeletionCheck {
  const DeletionCheck();
}

/// Everything [serverRevision] covers is on this device, checked in owner
/// session [generation]; only that session may send it with a deletion.
final class DeletionVerified extends DeletionCheck {
  const DeletionVerified({
    required this.serverRevision,
    required this.generation,
  });

  final int serverRevision;
  final int generation;
}

/// Not established, for [failure]'s reason: a deletion must not go ahead.
final class DeletionUnverified extends DeletionCheck {
  const DeletionUnverified(this.failure);

  final AppFailure failure;
}
