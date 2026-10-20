# core/

App-wide foundations: theme tokens (`AppTheme`), router, l10n, `Clock`, PII-redacting `Logger`,
`Env`, `AppFailure`, small utils. See docs/04-architecture.md §2.

**May import:** Flutter, third-party packages.
**Must not import:** `features/`, `data/`, `domain/`, `shared/`. Everything else depends on core,
so core depends on nothing in the app.

**Riverpod 3 notes** (M0.11): the root `ProviderScope` sets `retry: noProviderRetry`, so failed
providers are *not* retried unless they pass their own `retry:`. Errors read from providers arrive
wrapped in `ProviderException`; `unwrapProviderException` (core/logging) recovers the original.
Notifier state updates are filtered by `==`, so state types need value equality.
