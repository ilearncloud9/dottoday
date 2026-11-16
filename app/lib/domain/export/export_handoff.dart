/// The three states of a multipart export (CR-160 Stage B6,
/// docs/cr-160-multipart-export.md §10), never collapsed into one, and
/// the check that moves a set to the last of them.
library;

import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_part.dart';

/// How far a set got, per export.
enum HandoffState {
  /// Every file written and read back with a matching hash on this device.
  prepared,

  /// The share sheet or save dialog returned success, or the browser was
  /// asked to download each file. Not proof every file was kept: one share
  /// result covers all of them, and a browser may block a download.
  handoffAttempted,

  /// The person picked the manifest and every part back into the app and
  /// each hash and count matched, on this device, at that moment.
  possessionConfirmed,
}

/// Why picked files are not the prepared set.
enum PossessionProblem {
  /// The manifest isn't this export's (another export, or changed).
  notThisExport,

  /// A part was refused: changed, from another set, or not a part.
  partRefused,

  /// The same part picked twice.
  duplicate,

  /// At least one part wasn't picked.
  partMissing,
}

/// The result of [checkPossession].
sealed class PossessionCheck {
  const PossessionCheck();
}

final class PossessionConfirmed extends PossessionCheck {
  const PossessionConfirmed();
}

final class PossessionNotConfirmed extends PossessionCheck {
  const PossessionNotConfirmed(this.problem);
  final PossessionProblem problem;
}

/// Whether [manifestText] and [parts] (read lazily, one at a time) are
/// exactly the set prepared as [prepared].
///
/// ```dart
/// checkPossession(set.manifest, pickedManifest, pickedParts)
///     is PossessionConfirmed // → HandoffState.possessionConfirmed
/// ```
PossessionCheck checkPossession(
  ExportManifest prepared,
  String manifestText,
  Iterable<String> parts,
) {
  final picked = ExportManifest.decode(manifestText);
  if (picked == null ||
      canonicalJson(picked.toJson()) != canonicalJson(prepared.toJson())) {
    return const PossessionNotConfirmed(PossessionProblem.notThisExport);
  }
  final set = PartSet(prepared);
  for (final text in parts) {
    switch (set.add(text)) {
      case PartRefused():
        return const PossessionNotConfirmed(PossessionProblem.partRefused);
      case PartAccepted(duplicate: true):
        return const PossessionNotConfirmed(PossessionProblem.duplicate);
      case PartAccepted():
    }
  }
  return set.complete
      ? const PossessionConfirmed()
      : const PossessionNotConfirmed(PossessionProblem.partMissing);
}
