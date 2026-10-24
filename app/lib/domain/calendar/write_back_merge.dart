import 'package:dottoday/domain/calendar/calendar_writer.dart';
import 'package:dottoday/domain/calendar/imported_event.dart';
import 'package:dottoday/domain/entities/occurrence.dart';

/// The fields write-back sends (docs/02 F5: move, resize, rename).
enum WriteBackField { start, duration, title }

/// Who wins a field changed on both sides to different values.
enum WriteBackPrefer {
  /// Nobody: the person is asked ([WriteBackClash]).
  ask,

  /// "Keep mine": Dottoday's value goes to the calendar.
  mine,

  /// "Use calendar's": the calendar's value comes here.
  calendar,
}

/// Whether [o] was moved, resized or renamed here since [base] (what the
/// calendar last had, `calendar_links.etag`), so it has something to send.
bool hasLocalChange(Occurrence o, ImportFingerprint base) =>
    o.startUtc?.millisecondsSinceEpoch != base.startMs ||
    o.durationMin != base.durationMin ||
    textHash(o.title) != base.title;

/// The result of [mergeWriteBack].
sealed class WriteBackMerge {
  const WriteBackMerge();
}

/// A clean merge: send [patch] (null when the calendar already matches),
/// store [adopted] here (null when nothing came from the calendar), and
/// keep [fingerprint] as the new base.
final class WriteBackMerged extends WriteBackMerge {
  const WriteBackMerged({required this.fingerprint, this.patch, this.adopted});

  final EventPatch? patch;
  final Occurrence? adopted;
  final ImportFingerprint fingerprint;
}

/// [fields] changed both here and in the calendar to different values.
final class WriteBackClash extends WriteBackMerge {
  const WriteBackClash(this.fields);

  final Set<WriteBackField> fields;
}

/// A three-way merge of one imported event, field by field: [base] is
/// what both sides last agreed on, [local] the occurrence here, [remote]
/// the event in its calendar now. A field changed on one side takes that
/// side's value; changed on both to different values it is a clash,
/// settled by [prefer] or returned as [WriteBackClash]. Notes never go
/// back (docs/02 F5): the fingerprint keeps [base]'s.
///
/// ```dart
/// // Moved here to 10:00, renamed in the calendar to "Sync":
/// mergeWriteBack(base: b, local: at10, remote: renamed, untitled: 'x');
/// // WriteBackMerged(patch: 10:00 keeping "Sync", adopted: "Sync" here)
/// ```
WriteBackMerge mergeWriteBack({
  required ImportFingerprint base,
  required Occurrence local,
  required RemoteEvent remote,
  required String untitled,
  WriteBackPrefer prefer = WriteBackPrefer.ask,
}) {
  final there = local.copyWith(
    startUtc: remote.startUtc,
    durationMin: importedDurationMin(remote.startUtc, remote.endUtc),
    title: importedTitle(remote.title, untitled),
  );
  final clashes = <WriteBackField>{};
  final mine = {
    for (final f in WriteBackField.values)
      if (_takeMine(f, base, local, there, prefer, clashes)) f,
  };
  if (clashes.isNotEmpty) return WriteBackClash(clashes);
  final merged = local.copyWith(
    startUtc: (mine.contains(WriteBackField.start) ? local : there).startUtc,
    durationMin:
        (mine.contains(WriteBackField.duration) ? local : there).durationMin,
    title: (mine.contains(WriteBackField.title) ? local : there).title,
  );
  return WriteBackMerged(
    patch: _patch(merged, remote, there, mine),
    adopted: merged == local ? null : merged,
    fingerprint: ImportFingerprint(
      startMs: merged.startUtc!.millisecondsSinceEpoch,
      durationMin: merged.durationMin,
      title: textHash(merged.title),
      notes: base.notes,
    ),
  );
}

/// Whether field [f] takes [local]'s value; a both-sides change to
/// different values is added to [clashes] when [prefer] can't settle it.
bool _takeMine(
  WriteBackField f,
  ImportFingerprint base,
  Occurrence local,
  Occurrence there,
  WriteBackPrefer prefer,
  Set<WriteBackField> clashes,
) {
  final (here, cal, differ) = switch (f) {
    WriteBackField.start => (
      local.startUtc!.millisecondsSinceEpoch != base.startMs,
      there.startUtc!.millisecondsSinceEpoch != base.startMs,
      local.startUtc != there.startUtc,
    ),
    WriteBackField.duration => (
      local.durationMin != base.durationMin,
      there.durationMin != base.durationMin,
      local.durationMin != there.durationMin,
    ),
    WriteBackField.title => (
      textHash(local.title) != base.title,
      textHash(there.title) != base.title,
      local.title != there.title,
    ),
  };
  if (!here) return false;
  if (!cal || !differ) return true;
  if (prefer == WriteBackPrefer.ask) clashes.add(f);
  return prefer == WriteBackPrefer.mine;
}

/// What to send so the calendar has [merged], or null when it has it.
EventPatch? _patch(
  Occurrence merged,
  RemoteEvent remote,
  Occurrence there,
  Set<WriteBackField> mine,
) {
  final start = merged.startUtc!;
  // Both sides making the same change leaves nothing to send.
  final resized =
      mine.contains(WriteBackField.duration) &&
      merged.durationMin != there.durationMin;
  final renamed =
      mine.contains(WriteBackField.title) && merged.title != there.title;
  if (start == remote.startUtc && !resized && !renamed) return null;
  return EventPatch(
    startUtc: start,
    // Only a resize sets the length; a move keeps the calendar's real
    // one (it may be longer than the 24 h block shows).
    endUtc: resized
        ? start.add(Duration(minutes: merged.durationMin))
        : start.add(remote.endUtc.difference(remote.startUtc)),
    title: renamed ? merged.title : null,
  );
}
