# data/

Persistence and network: Drift schema + DAOs, repository implementations, `SupabaseGateway`,
`SyncEngine`, `BackupService`, `ExportService`. See docs/04-architecture.md §2, §4 and
docs/05-data-model.md.

**May import:** `domain/` (implements its interfaces), `core/`.
**Must not import:** `features/`, `shared/`. Features reach data only through `domain` interfaces
exposed via Riverpod providers.
