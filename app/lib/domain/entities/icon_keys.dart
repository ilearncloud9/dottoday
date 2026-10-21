/// `icon_key` for new tasks; matches the column default (0001_init.sql).
const defaultIconKey = 'circle';

/// Shape every persisted `icon_key` must have (docs/05 "Validation").
///
/// The curated picker set is chosen with the picker (M3.1); until then the
/// allowed set is "lowercase snake_case token, ≤ 48 chars" so keys from a
/// newer app or icon pack round-trip, and the UI falls back to
/// [defaultIconKey] for keys it cannot draw.
final iconKeyPattern = RegExp(r'^[a-z][a-z0-9_]{0,47}$');
