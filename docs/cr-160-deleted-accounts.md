# CR-160: what happens to a deleted account's copy on this device

Status: **history; see `docs/cr-160-ownership-policy.md` §4 for the current proposal.**
Data-layer isolation is built and tested; the choice and recovery screens are not.

## The existing contract (what was promised)

- PRD F7.7: "Account deletion: one tap in settings, deletes server data within 24 h, confirmed by
  email (GDPR)." Security 06 §6: the Edge Function deletes every row and the auth user, then mails a
  confirmation.
- Settings › Account › Delete account (M6.5, `account_dialogs.dart`) asks for the typed word and
  offers "Export my data first". Its body says (`accountDeleteBody`): *"This deletes your account and
  everything synced to it. Tasks on this device stay."*
- So the contract deletes the **server** copy only. The **device** copy is promised to stay. Nothing
  in the PRD, security doc or plan says the device copy may move into another account; that was an
  implementation choice in M6.5 (`requeueAll` on the next sign-in), which CR-160 removes.

## What the branch does now (built, tested)

- `retireAccount` (`data/sync/account_owners.dart`) runs after the server confirms the deletion:
  the copy stays an **account** owner marked `owner_deleted:<id>`. It is hidden, never pushed, and
  `signInOwner` never re-keys it. Signing in as anyone afterwards gets their own profile
  (`OwnerChange.newAccount`). Nothing is deleted; its unsynced entries stay its own.
- Tests: `account_switch_test.dart` group "a deleted account".
- Consequence today: "Tasks on this device stay" is true (they are kept) but they are **not
  visible**. The copy needs to change, or a recovery path must be added (below).

## Options for the owner

| | What the person gets | Privacy | Copy change |
|---|---|---|---|
| **D1 (recommended): choose at deletion** | The delete dialog gains one explicit choice after the typed word: **"Keep my tasks on this device"** (they stay usable without an account, on this device only) or **"Remove them from this device too"** (after the existing "Export my data first" offer). If kept, any later sign-in **asks** before bringing them into that account ("Bring 42 tasks kept from a deleted account into sam@…?" · Keep separate (default) / Bring them in). | The deleter decides while still signed in; no automatic transfer; a later account only receives them on an explicit yes. | Yes: body and two new choices |
| D2: keep, export only | The copy stays hidden. Settings › Data and privacy shows "Tasks kept from a deleted account · Export" (JSON/CSV/ICS via the existing export) and "Remove from this device" (typed confirm). Never shown in the planner again. | Strongest isolation; the data is only reachable by export. | Yes: body, plus a row |
| D3: remove with the account | Deleting the account also removes the device copy after the export offer. | Simple, but contradicts the current promise and could surprise people with unsynced work. | Yes |

Recommendation: **D1.** It keeps today's promise ("Tasks on this device stay"), makes the person who
owns the data decide, and never moves data into another account without a yes. "Remove" is explicit
and confirmed, never silent; the existing export offer comes first.

Not changed by any option: export keeps working; unsynced work is never deleted without an explicit,
confirmed choice; deleted accounts are never adopted automatically.

## Tests to add once an option is chosen

- D1: keep → the copy shows signed out as device-only data; a later sign-in asks; Keep separate leaves
  the account's server empty of it; Bring them in moves it once (no duplicates, interrupted move
  resumes). Remove → only after the confirm; export offered first.
- D2: export of a hidden owner contains exactly its rows; Remove needs the typed confirm.
- Every option: B's server receives nothing of the deleted account without an explicit choice.

## Superseded by the ownership and recovery policy (2026-11-08, second review)

The owner did not approve device authentication (`local_auth`): it proves who may unlock the device,
not who owned a deleted account. The current proposal is in `docs/cr-160-ownership-policy.md` §4:
export while signed in, then delete and remove the device copy, on every platform; no Keep option on
the web; an interrupted browser removal stays hidden until "Finish removing". The locked copy
(passphrase-protected, native only) is a conditional proposal, not for build.
