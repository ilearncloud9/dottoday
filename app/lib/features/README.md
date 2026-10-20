# features/

One folder per feature: Riverpod notifiers + widgets. Notifiers call use-cases/repository
interfaces, never DAOs. See docs/04-architecture.md §2.

**May import:** `domain/`, `data/` (via interfaces/providers only), `shared/`, `core/`.
**Must not import:** another feature's files. Cross-feature calls go through `domain` interfaces
or Riverpod providers. No string literals in widgets — use `AppLocalizations`.
