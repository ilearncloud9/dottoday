/// What the browser said about keeping Dottoday's data (E-G4-7 Q2,
/// ED-188 to ED-192; M20.10 part 6, ED-484): [kept] (it agreed),
/// [notKept] (it said no, or hasn't been asked yet), [unsupported] (it
/// can't be asked). None of them is a guarantee, sync or a backup.
enum BrowserStorageState { kept, notKept, unsupported }

/// The browser's storage manager and a small local record, behind an
/// interface so tests can fake them (handoff § G4-7 Q2).
abstract interface class BrowserStorageGateway {
  /// `navigator.storage.persisted()`; null when it can't be asked.
  Future<bool?> persisted();

  /// `navigator.storage.persist()`; null when it can't be asked.
  Future<bool?> persist();

  /// Whether this browser profile already asked for [owner].
  bool asked(String owner);

  /// Records that it asked for [owner], so a launch never asks again.
  void markAsked(String owner);
}
