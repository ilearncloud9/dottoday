/// `icon_key` for new tasks; matches the column default (0001_init.sql).
const defaultIconKey = 'circle';

/// Shape every persisted `icon_key` must have (docs/05 "Validation").
///
/// The picker offers the 26 Concept A icons (`TaskIcon` in core/theme, M3a.2), but
/// the allowed set stays "lowercase snake_case token, ≤ 48 chars" so keys
/// from a newer app or icon pack round-trip, and the UI falls back to
/// [defaultIconKey] for keys it cannot draw.
final iconKeyPattern = RegExp(r'^[a-z][a-z0-9_]{0,47}$');
