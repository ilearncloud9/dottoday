# shared/

Reusable, business-logic-free UI components. The Concept A set (docs/10-ui-concept-a.md §3) lives
in `dot/` (`TaskDot`, `Thread`, `TaskRow`, `LiveRow`, `DayDot`, `WeekStrip`, `DayCard`, `DayPager`,
`MonthGrid`, `ColourIconBlock`) and `navigation/` (`DotShell`: pill tab bar, Material bar, rail by width class). Older
pieces: `AppSheet`, `TimeInput`, `DurationChips`, `UndoSnackbar`, `SyncPill`.

**May import:** `core/` (theme tokens, l10n).
**Must not import:** `features/`, `data/`, `domain/` services. Components take values and
callbacks; they never read repositories or providers with side effects.
