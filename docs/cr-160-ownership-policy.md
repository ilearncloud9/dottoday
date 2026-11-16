# CR-160: ownership and recovery policy

Status: **approved by the owner; built on `fix/cr-160-account-ownership` (2026-11-09), awaiting the
owner's verification review.** It covers the security rules behind board E-CR160. Evidence per
criterion is in `docs/cr-160-verification.md`; no criterion is PASS because its design is approved.

## 1. Owners

| Owner | What it is | Who may see it | May it move? |
|---|---|---|---|
| Account | Rows keyed by an auth user id (`owner_account:<id>`) | Only while that account is signed in | Never into another owner |
| Guest | Rows made on this device without an account | Anyone using the device without an account | Only into the account signing in, only if eligible (§3) and explicitly confirmed |
| Deleted account | An account deleted on this device | Nobody | Never (§4) |

Every row and pending change has exactly one owner (built). Sync runs, pushes and pulls per owner
(built). The server refuses a change whose owner isn't the signed-in user (0014, built, pgTAP).

## 2. Signing out

- Hides the account immediately; only the guest may show afterwards (built; A3 screen built).
- Unsynced changes stay under the account and go up only when the same account signs in (built).
- A1 ("Everything has synced to your account") shows only when the server confirmed the last sync and
  nothing is waiting; otherwise A2 (built).
- A2's sentence "no one else who uses Dottoday on this device can see them" ships only after I1–I8
  are fixed and tested on devices. I1–I8 are fixed and tested in code, but lock-screen, widget, Live
  Activity and status-item removal still need a physical device, so A2 ships the narrower "They stay
  on this device under this account." (`a2IsolationVerified = false` in `sign_out_prompt.dart`).
- Mac/web: Esc cancels and starts nothing; only "Stay signed in" starts a sync.

## 3. Guest tasks at sign-in

- Default: keep them separate (built). Nothing moves without a choice (built).
- **Eligibility (built):** "Bring them into your account" is offered only for guest tasks created
  in the current uninterrupted guest session. The session is a random identifier in `local_meta`
  (`guest_session`), replaced at every owner change (sign-in that changes owner, sign-out, account
  removal); each guest row records the session that first wrote it (`guest_row_sessions`). No clock
  is used, so a changed device clock cannot make old work eligible. Rows from before schema v19 are
  never eligible. The check runs in the data layer (`signInOwner`) at the moment of the move, and
  only the eligible subset moves.
  - All eligible: G1, with the "I made these tasks myself" box required for "Bring them in".
  - None eligible: G1b; nothing can be brought in; the tasks stay on the device.
  - Some eligible: G1 offers only the eligible ones ("Bring the 8 tasks made since …"); the rest stay.
- No preview of guest tasks after sign-in. Guest tasks are reviewed in the guest experience before
  signing in.
- Ineligible or kept-separate guest work is never deleted and never moved by itself.
- **Residual risk:** the confirmation is a choice, not proof of ownership. Someone who used the device
  without an account in the same session, just before another person signs in, could have their tasks
  brought in by that person. The window is the current guest session only.

## 4. Deleted accounts

**Interim, all platforms (built):** the only recovery is export while the account is still
signed in. The delete screen offers "Export my data first", then deletes the account and removes
its copy from this device: the profile, every row and pending change it owns, its owner-keyed local
caches (I4) and backups (I2), and on the web its browser storage and scheduled pushes (I3). One
transaction locally. On the web, removal that is interrupted (tab closed, reload) leaves the copy
hidden and marked "removal pending"; at next launch the app shows "Removal from this browser didn't
finish" with **Finish removing**, and it is never shown, synced, converted to guest data or
transferred meanwhile.

On native, an interrupted removal is retried automatically at next launch (`removal_runner.dart`); the
copy stays hidden and unsynced meanwhile.

**Conditional proposal, not built: a locked copy (native only).** A device passcode or
biometric (`local_auth`) proves who may unlock the device, not who owned a deleted Dottoday account,
so it is not used. The only owner-bound option found is a **recovery passphrase** the person sets
while still signed in: the kept copy is written to a separate SQLCipher database keyed by that
passphrase (the existing `sqlite3` build hook with `source: sqlcipher`, ADR-0006, so no new
dependency), and the live rows are then removed. Export later needs the passphrase. Open questions
before it could be approved: key derivation and brute-force cost on a lost device, what happens when
the passphrase is forgotten (the copy is unrecoverable), and copy that never promises more than this.
Not offered on the web.

## 5. What remains open

- Owner verification review of the build.
- Device-only checks (lock screen, widgets, Live Activity, status item, Wake Up alarms), Firefox and
  Safari runs, hosted staging: see `docs/cr-160-verification.md`.
- Migration 0014: staged rollout as approved (`docs/cr-160-rollout.md`); nothing hosted is authorised.
