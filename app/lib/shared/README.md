# shared/

Reusable, business-logic-free UI components: `AppSheet`, `TimeInput`, `DurationChips`,
`ColorIconPicker`, `UndoSnackbar`, `SyncPill`. See docs/03-ux-spec.md §3.3–3.4.

**May import:** `core/` (theme tokens, l10n).
**Must not import:** `features/`, `data/`, `domain/` services. Components take values and
callbacks; they never read repositories or providers with side effects.
