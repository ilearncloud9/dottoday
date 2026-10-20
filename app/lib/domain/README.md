# domain/

Pure Dart: freezed entities, repository *interfaces*, and services (`RecurrenceExpander`,
`DayScheduler`, `QuickAddParser`, `NotificationPlanner`, `ConflictResolver`). See
docs/04-architecture.md §2–§5.

**May import:** `core/` non-UI pieces (`Clock`, failures, utils), pure-Dart packages.
**Must not import:** `package:flutter`, `data/`, `features/`, `shared/`. No `DateTime.now()` —
inject `Clock`. Target ≥ 90 % test coverage (docs/09 M1.9).
