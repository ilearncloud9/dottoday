# core/

App-wide foundations: theme tokens (`AppTheme`), router, l10n, `Clock`, PII-redacting `Logger`,
`Env`, `AppFailure`, small utils. See docs/04-architecture.md §2.

**May import:** Flutter, third-party packages.
**Must not import:** `features/`, `data/`, `domain/`, `shared/`. Everything else depends on core,
so core depends on nothing in the app.
