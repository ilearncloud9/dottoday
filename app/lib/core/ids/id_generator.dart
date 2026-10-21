import 'package:uuid/uuid.dart';

/// Source of new entity IDs. Inject it so domain code stays deterministic in
/// tests (CLAUDE.md §2: UUID v7, client-generated).
abstract interface class IdGenerator {
  /// A new, globally unique ID.
  String newId();
}

/// Time-ordered UUID v7 IDs (docs/05 intro).
final class UuidV7Generator implements IdGenerator {
  const UuidV7Generator();

  static const _uuid = Uuid();

  @override
  String newId() => _uuid.v7();
}
