/// Why the encrypted database can't be opened (06 §4).
enum DatabaseUnavailableReason {
  /// The file exists but the keychain has no key for it (e.g. keychain
  /// wiped, restored to a device without it).
  keyMissing,

  /// The stored key does not decrypt the file.
  keyRejected,

  /// Web only: another tab already has the database open (M2.9).
  openInAnotherTab,
}

/// Thrown on first use of a database whose file can't be decrypted. The
/// file is left untouched; recovery UI (M3.11) moves it aside and starts
/// fresh, with data returning via sync or a user export. Local backups use
/// the same key, so they can't help here.
final class DatabaseUnavailable implements Exception {
  const DatabaseUnavailable(this.reason);

  final DatabaseUnavailableReason reason;

  @override
  String toString() => 'DatabaseUnavailable(${reason.name})';
}
