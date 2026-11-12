# CR-160 verification: account ownership and switching

CR-160 (ED-193) is a critical privacy/security release blocker. The acceptance criteria are in
`docs/redesign/E_IMPLEMENTATION_HANDOFF.md` § CR-160 on `redesign/design-lab`. This file records
what proves each one on `fix/cr-160-account-ownership`, and what is still not run.

Status words: **PASS** = run and green, with the scope stated (automated, local stack, platform);
**PARTIAL** = some of the criterion's required runs are done, the rest named; **PENDING** = not run.
Nothing below ran against hosted Supabase.

| # | Criterion | Status | Evidence |
|---|---|---|---|
| 1 | Strict ownership | PASS (automated) | `change_log.owner_id`, owner-keyed `sync_cursors` (schema 18), `guest_row_sessions` (19); `account_switch_test.dart` "only a guest is adopted"; `migration_test.dart` v17 → v18; owner-keyed caches (I4), backups (I2) |
| 2 | Safe sign-out | PARTIAL (data and screens PASS, automated + local stack, 4 platforms; the share-extension race (I7) and the misleading offline error are open) | A1/A2/A3 built (`sign_out_prompt.dart`, `signed_out_screen.dart`); `sign_out_prompt_test.dart` (A1 only when confirmed and nothing waits; A2 otherwise; Esc cancels with no sync on Mac/web); `owner_switch_test.dart` "signing out: nothing of A is pending, shown or on a surface"; criterion 11 runs. A2 ships the narrower sentence (device-only surfaces unverified) |
| 3 | Safe account switching | PARTIAL (PASS automated + local stack, 4 platforms; share-extension actions queued under A can land with B (I7), Wake Up ownership unverified) | `account_switch_test.dart` "B signs in: none of A goes up, shows, or changes owner"; `sync_engine_test.dart` (replaces the old leaking test); `owner_switch_test.dart` (queued runs/actions, repeated switches, restart); criterion 11 step 3 (RLS + admin) |
| 4 | Unsynced data preserved without leaking | PASS (automated + local stack, 4 platforms) | `account_switch_test.dart` group "signing out"; criterion 11 steps 2–4: A's offline tasks reach A once each, never B |
| 5 | Guest → new account | PASS (automated + Chromium, local stack) | Explicit "Bring them in" with "I made these tasks myself" (G1); only the current guest session's tasks (`account_switch_test.dart` group "guest eligibility", incl. clock change and restart); web flow 1 |
| 6 | Guest → existing account | PASS (automated + Chromium, local stack) | `first_sync_test.dart` "a guest's tasks join the account's"; web flow 2 (2+2 once each, settings stay the account's) |
| 7 | No silent settings replacement | PASS (automated) | `first_sync_test.dart` "a guest's settings never replace the account's", "choosing the guest's settings"; B1 built (`settings_choice_screen.dart`, `account_screens_test.dart` group "B1 settings"); web flow 2 server check. B1 not tapped on a platform run |
| 8 | No duplicate starter content | PASS (automated) | Stable ids (`domain/sync/stable_ids.dart`); `account_switch_test.dart` "starters planted on two devices merge into one". Not in a web/device run |
| 9 | Interrupted or failed migration | PASS (automated + Chromium, local stack) | `account_switch_test.dart` group "interrupted"; `engine_sync_service_test.dart` failed sign-in step; web flow 4 (reload after the local step; not inside it) |
| 10 | Web end-to-end | PARTIAL | Chromium 156: flows 1–5 PASS on the local stack (runs below); re-run after Stage B (B8, 2026-11-12): flows 1–5 PASS. Firefox, Safari PENDING (no driver; installing one needs the owner's go). Hosted staging PENDING |
| 11 | Shared-device tests on all four platforms | PARTIAL | PASS on the local stack: macOS 26.6.2, iOS 18.6 Simulator, Android 17 emulator, web/Chromium (runs below); re-run after Stage B (B8, 2026-11-12): PASS on macOS, the iPhone 17 Pro Simulator (iOS 26.5), the Android API 37 emulator and Chromium 156, after the test was brought up to D1's review step (`docs/cr-160-multipart-export.md`, B8). Physical iPhone/Android and hosted staging PENDING |
| 12 | Server-side guard | PASS (pgTAP, local stack) | `supabase/migrations/0014_push_owner_guard.sql` + `supabase/tests/0014_push_owner_guard.sql`; `supabase db reset` + `supabase test db`: 14 files, 119 tests. Not deployed |

## CRITICAL — OPEN — RELEASE BLOCKER (owner 2026-11-09)

The draft PR is for review only. Before it can be marked ready:

1. **Share-extension race (I7).** Native queued actions get an owner when queued, ownership is
   checked again when each runs, and a stale action is deferred for its owner (never attached to
   the next account, never silently deleted). Tests: delayed actions, rapid switching, offline,
   restarts.
2. **Wake Up ownership.** Find out whether per-device Wake Up days can show another account's
   schedule or arm the wrong account's alarms; isolate before release.
3. **Android ringing alarm.** Verify the limitation on a real ringing alarm; no previous-account task
   text may stay visible after a switch; mitigation if it cannot be removed at once.
4. **Offline sign-out** shows an error although the sign-out took effect: fix.
5. **Sync now** must always give truthful feedback, including while a run is failing.
6. **Visual discrepancy.** The new screens use DotTheme (Inter, app accent), not the approved
   Concept E Manrope/teal treatment; screen-specific adjustments only.
7. **Verification.** Firefox and Safari (criterion 10); physical iPhone and Android incl. widgets,
   Live Activity, lock-screen notifications, Wake Up alarms (criterion 11); hosted staging only after
   the owner's separate go.
8. **Older-build data.** Records already misattributed by older builds: define detection,
   quarantine or recovery before release; never relabel possibly mixed data as the current account's.
9. **Migration 0014** is not deployed; rollout per `docs/cr-160-rollout.md` after separate approval.

## Guest work on a shared device

Built and tested. `signInOwner` returns `guestChoiceNeeded` and changes nothing while the device has
eligible guest tasks and no recorded choice; sync waits. Keep separate is the default (G1). Bring
them in needs the "I made these tasks myself" box, and moves only the eligible subset, checked in the
data layer at the moment of the move. Eligible = first written in the current guest session
(`guest_sessions.dart`: a random id replaced at every owner change; no clock). Older guest work gets
G1b once and stays on the device as the guest's. Guest settings are copied only into a fresh account
profile, and only when the guest profile itself is eligible; an existing account's settings are never
replaced without B1. No preview of guest tasks after sign-in.

Residual risk (accepted in the policy): the box is a choice, not proof. Someone who used the device
without an account in the same guest session, just before another person signs in, could have their
tasks brought in by that person.

## Account isolation across every visible surface (I1–I8)

I1–I6 and I8 fixed in code with tests; I7 is open (share extension). Device-only effects are named in "Still unverified".

| # | Surface | Fix | Tests |
|---|---|---|---|
| I1 | Sign-out | `OwnerSwitch.signOut` before auth sign-out: drain queued actions and alarm events, wait for effects, clear reminders, bump the owner epoch, empty snapshot, A3 gate | `owner_switch_test.dart`, `account_gate_test.dart`, criterion 11 |
| I2 | Backups | Owner column (backup DB v2, owner inferred from each backup's profile); list, restore, daily, pruning per owner; restore of another owner's backup refused; removal deletes the owner's backups | `backup_owner_test.dart`, `backup_migration_test.dart`, criterion 11 step 5 |
| I3 | Web reminders | Timers disposed on switch; `scheduled_pushes` cleared before sign-out; resync only for the shown owner | `owner_switch_test.dart`; web criterion 11 |
| I4 | Brain dumps, thinking log, recent searches, calendar moves, dictation, learning | `owned_local_meta.dart`: keyed by owner; legacy global values adopted only with exactly one profile, otherwise kept hidden and marked | `test/data/search/`, `calendar_moves_owner_test.dart`, owned-meta tests |
| I5 | Undo, open editor, focus task, proposal, pending brain dump/routine drop, in-app alerts, trash | Watch the owner epoch and reset; undo refuses another owner's tokens | `owner_switch_reset_test.dart`, `undo_owner_test.dart` |
| I6 | Delivered notifications | `clearAll` removes pending and delivered at every switch | `owner_switch_test.dart`; criterion 11 "delivered=0 none of A" (macOS, iOS Sim, Android emu) |
| I7 | Wind Down timer; action queue | **OPEN** (owner review). Wind Down cancelled and re-armed. Queued native actions now carry their owner and apply only for it (section "I7: queued actions" below); physical devices, iOS/Mac share sheets driven end to end, and owner decisions D-I7-1…4 still open | `queue_owner_switching_test.dart`, `queue_owner_outcomes_test.dart`, `owner_switch_test.dart`, native tests below |
| I8 | Widgets, Live Activity, ongoing notification, status item, Wake Up alarms | Empty snapshot written at the switch, then the new owner's; `disarmAll` alarms | `owner_switch_test.dart`, `snapshot_write_paths_test.dart` |

## I7: queued actions keep their owner (second pass 2026-11-09, awaiting owner review)

**Status (owner 2026-11-09):** I7 implementation completed and locally verified in the tested
scopes; security review and end-to-end verification outstanding (I7 stays OPEN). ED-223 A3: locally
verified and included in draft review. CR-160: **CRITICAL — OPEN — RELEASE BLOCKER**. PR #75:
**DRAFT — NOT READY TO MERGE**.

### Root cause and race timeline (before this pass)

Widgets, controls, Siri, the Live Activity, notification actions, the share extension (iOS, Mac),
the share intent (Android) and the web service worker append to one shared queue (App Group
defaults, `home_widget` prefs, Cache Storage). Entries carried **no owner**: the drain applied each
to whichever profile `latestProfile(ref)` returned at that moment.

| # | Window | What went wrong |
|---|---|---|
| W1 | Share posted after the switch's own drain read the queue, before the switch finished | Next drain applied A's share to B (or the guest) |
| W2 | Sign-in: `signInOwner` flipped the owner, then `signedIn()` drained with the cached profile | An entry could be written for either owner, depending on cache timing |
| W3 | A drain running (resume, `queueChanged`) while a switch ran | Owner checked before the switch, written after it |
| W4 | Share posted while the owner changed | No way to tell whose it was; applied to the next owner |
| W5 | App killed with A shown, share queued, next launch | Applied to whoever was shown at the first drain |
| W6 | iOS/Mac: the share/widget extension (another process) appends while the app removes | `NSLock` is per process: the app's read-modify-write could drop the append |
| W7 | Web: the worker appends while a tab removes | No lock at all |
| W8 | Android background engine (no channel): `home_widget` read-then-write remove | Could drop an append |
| W9 | Drainer removed unreadable entries | Possibly valid shared content discarded |

### Queue protocol and owner attribution

- **Published marker.** The app publishes what surfaces do with a new entry (`action_queue_owner`;
  web `__snapshot/queue_owner.json`): `{"v":1,"owner":<profile id>,"guest_session":<id>}` (stamp
  it), `{"v":1,"switching":true}` around the database flip of every change of owner (stamp
  nobody), or `{"v":1,"refuse":true}` while an account deletion runs (queue nothing). Published at
  launch, every resume and after every switch; never while a switch or a deletion is under way
  (`OwnerSwitch.publishShownOwner`).
- **Stamped at enqueue, natively, under the queue lock:** Swift `DotQueue.append`, Kotlin
  `ShareIntake.append` / `DotActionReceiver.perform`, `web/action_queue.js append`. The marker
  persists in the shared store, so an extension needs no running app.
- **Refused explicitly, never evicted.** An append is refused (nothing queued, nothing shown as
  done) while the marker says `refuse`, at 500 entries or 1 MB, when the write doesn't read back,
  or when the stored queue can't be read (it is never written over). The share sheets say "Dottoday
  couldn't save this right now. Open Dottoday and try again." (iOS/Mac alert, Android toast, the Add
  task intent's dialog; four languages); widget/Live Activity/notification buttons do nothing
  visible; the web worker opens the app instead.
- **One lock per platform for append, remove and publish:** iOS/Mac `flock` on
  `action_queue.lock` in the App Group container (app and extensions are separate processes), with
  `CFPreferencesAppSynchronize` before every read; Android `synchronized(DotQueue)` (one process,
  verified below); web the Web Lock `dottoday-action-queue` (worker and tab).
- **Executed only for its owner, checked twice.** The drainer applies an entry only when its owner
  is the owner the database shows; `DotIntents.apply` refuses any other (`notOwner`); the write
  carries `onlyWhileShown`, checked inside the write's own transaction (`DriftWriteUseCase`), so a
  check before a switch can never become a write after it (also from Android's background
  isolate). A refused write fails and the entry stays.
- **Waiting, not blocking.** Other owners' entries keep their place; the shown owner's proceed. A
  switch drains the old owner's before the flip and the new owner's after.
- **Replay-safe.** Removal happens after the write; a crash in between replays the entry, which
  then changes nothing (`alreadyApplied`) and is removed. Android's background engine applies but
  never removes.

### Owner decisions (2026-11-09) and the behaviour now

**1. Unknown owner: conservative.** Entries stamped `switching`, written before the first publish
after this update, or by an older version have no owner and stay quarantined: never applied,
synced, shown or previewed, never assigned to the next account or guest session, never expired.
Automatic legacy attribution was examined and **not built**: no build before CR-160 recorded a
durable history of owner changes (the only trace, `sync_account`, held the last account and was
removed by migration 18), so no device can prove one original owner and rule out earlier switches.
A profile count is not such proof. No recovery UI.

**2. Another account's task: terminal.** Done, +15 or Start for a task that exists only under
another owner is refused (`droppedForeign`): no task changes, a record
`queue_outcome:<action id>:<owner>` = `droppedForeign` is written (ids and reason code only; it
goes with the owner's account removal), then the entry leaves the queue. A crash in between
records the same outcome again. Not terminal: a database error (the drain throws; the entry
stays), an inactive owner (waits), an unattributed or unreadable entry (quarantined), and an Add
task whose id another owner holds (kept: its text may be the only copy). A task gone for everyone
stays `droppedMissing` as before. Nothing about the other account's task reaches any screen.

**3. Account deletion: export gap closed.** D1's summary first applies what is queued for the
account (counted in the summary), then **holds** the account's queue: later arrivals wait
unapplied. "Export my data first" applies it again before building the file; anything left that
can't be applied fails the export ("Couldn't export all your data…"). At "Delete account" the
surfaces are switched to `refuse`, then the account's queued ids are compared with the last review;
if anything arrived, nothing is deleted, the typed word and the export status are cleared, and the
screen says: "Something new arrived for this account after you started, so nothing was deleted.
Export again to keep it, then type DELETE again." (four languages). A renewed confirmation without
exporting deletes it with the account, as the person was told. During the server deletion and until
the removal is recorded and finished, surfaces refuse; afterwards they stamp the guest. The
account's queued entries and outcome records go with its copy. A failed server deletion releases
the refusal; closing D1 releases the hold and applies what waited.

**4. Retention.** Known-owner entries stay until applied, terminally invalid (decision 2) or
removed with their account (decision 3). Unknown-owner entries stay quarantined. No time-based
purge. Capacity: 500 entries / 1 MB, then new entries are refused (above), never older ones
evicted. Logs carry action ids, owner-free reason codes and occurrence ids only, never text.

At-rest protection of the queue (unchanged by this pass, reviewed):

| Platform | Where | Who can read it | At rest |
|---|---|---|---|
| iOS | App Group `UserDefaults` plist (`group.app.dottoday.planner`) | The app and its extensions (same team, group entitlement) | iOS Data Protection, default class (until first unlock); not in the SQLCipher database |
| macOS | Team-prefixed App Group container | The app and its share extension; other processes of the same user subject to macOS App Data / group-container protection | FileVault if on; not encrypted by Dottoday |
| Android | `HomeWidgetPreferences` in the app's private storage | The app only (one process) | File-based encryption of credential-protected storage; not encrypted by Dottoday |
| Web | Cache Storage of the app's origin | Pages and the worker of that origin | Browser profile on disk, not encrypted by Dottoday |

Trade-off: a share or Add task text waits in plain text in these stores until applied, and an
unattributed one waits with no limit. Encrypting the queue would need a key the share extension can
use without the app (a Keychain/Keystore key shared with extensions): not done in this pass (new
mechanism, owner decision).

### Locking across execution contexts (verified)

- **iOS/macOS, across processes:** `tool/cr160/queue_lock_check.sh` builds the real
  `ios/Shared/DotStore.swift` into a command-line driver and runs 8 processes at once on one
  preferences suite (6 append 60 each, 2 remove 50 seeded): with one lock file every append
  survives and every removal lands (360 of 360); the control, each process with its own lock file,
  lost 22 entries and had read-back failures. In the app the lock file is in the App Group
  container, which the app and its extensions share.
- **Android, one process:** no component in `AndroidManifest.xml` and no plugin manifest declares
  `android:process`; the share intent (`MainActivity`), `DotActionReceiver` (widgets,
  notifications, the ongoing notification), the Start focus tile, the channel (`IntentQueueBridge`)
  and the WorkManager background engine all run in the app process. Every queue read-modify-write
  and the marker publish take `synchronized(DotQueue)`; the background engine's `home_widget`
  fallback only reads (removal and publish are no-ops). `home_widget` writes only the snapshot key.
- **Web, real tab and worker:** `tool/cr160/web_queue_lock.mjs` serves a page and a real service
  worker that loads the shipped `app/web/action_queue.js`; the worker appends 120 while the tab
  removes 40 seeded entries. With the Web Lock: 120 kept, 40 removed, all stamped with the owner;
  the control without it kept 115 and removed 1. With `refuse`, the worker queued nothing (120
  refused). The Dart side: `test/web/action_queue_store_web_test.dart` in Chrome for Testing shows
  `WebActionQueueStore.remove` waits while another context holds the lock.
- **Check and write:** the `onlyWhileShown` check runs in the write transaction (tested by a drain
  that believes A is shown after A left). **Crash between write and trim:** replay changes nothing
  (tested).

### Regression tests and results (second pass, 2026-11-09, local only)

Host Mac15,7, macOS 26.6.2 (25G83); Flutter 3.47.8 / Dart 3.13.7; Supabase CLI 2.121.0 (local
stack only).

| Test | Covers | Result |
|---|---|---|
| `test/data/intents/queue_owner_switching_test.dart` (10) and `queue_owner_outcomes_test.dart` (6), shared `queue_owner_world.dart` | Share for A drained after A left and B signed in (kept, applied to A on return, B zero writes); share mid-switch (quarantined, never applied); app closed then restart; closed app then a switch first; check before a switch refused by the write transaction; A → guest → B → A in quick turns, each once; mixed owners with an inactive owner ahead; another account's task (`droppedForeign`: no write, durable record, removed); an Add task whose id another owner holds (kept); a database error (stays pending); legacy entry with no owner (quarantined); duplicate delivery and crash before trim (applied once); append during a drain; guest share from an earlier guest session (never eligible); account deletion removes only its own entries; logs carry no share text | PASS |
| `test/data/owners/deletion_queue_test.dart` (8) | Review applies queued work (summary counts it, export holds it); share during the export stops the deletion, a new export keeps it; share between export and confirmation waits unapplied and stops the deletion, renewed confirmation deletes it; during the server deletion surfaces are refused; after the removal is recorded refused until the deletion ends, then the guest's; failed server deletion releases; export can't claim done with unapplied queued work; declined export | PASS |
| `test/data/owners/owner_switch_test.dart` (12), drainer and intents tests | Switch order, marker publishing, guest work at sign-in | PASS |
| `test/policy/intent_wire_contract_test.dart`, `os_strings_test.dart` | Swift, Kotlin, JS and Dart spell the owner keys, marker, path and lock the same; every native append stamps; new strings in all four languages | PASS |
| `tool/action_queue_test.mjs` (9, node) | Worker stamping, nobody while switching, refuse, capacity, unreadable queue never overwritten, concurrent appends | PASS |
| `test/web/action_queue_store_web_test.dart` (3, Chrome for Testing 1248) | The tab's remove keeps unreadable entries, publishes the marker, and waits for the lock another context holds | PASS |
| `tool/cr160/web_queue_lock.mjs` (Chromium 156.0.8078.4) | **Real tab + real service worker** running the shipped `action_queue.js`: 120 of 120 appends kept and 40 of 40 removals with the lock (control without: 117 kept, 39 removals lost); while deleting, 120 of 120 refused | PASS |
| `tool/cr160/queue_lock_check.sh` (macOS 26.6.2) | **8 real processes** on the real `DotStore.swift` code: 360 of 360 with one lock file; controls with a lock file each lost 69 and 36 entries | PASS |
| `macos/RunnerTests` (7, XCTest, macOS 26.6.2) | Share queue carries the published owner; nobody during a switch; appends and removes from many threads lose nothing; plus the 4 existing menu-bar tests | PASS |
| `ios/RunnerTests/DotIntentsTests` (13, XCTest, iPhone 16 Pro Simulator, iOS 18.6) | Stamping (owner, guest session, switching, none yet); refused while deleting and when full (nothing patched, nothing evicted); unreadable queue never overwritten; 200 concurrent appends/removes | PASS |
| `integration_test/cr160_share_owner_test.dart` via `tool/cr160/share_owner_check.sh` (emulator Medium_Phone_API_37.0, Android 17 / API 37, debug) | **Real `ACTION_SEND` shares** through `ShareIntake`, the real channel and encrypted database, three launches: cold start by a share (A's, applied to A); share while B shown (B's); share while the published owner still read A (B never gets it; kept); force-stop; after restart still waiting, A signs back in and gets it once; share mid-switch (no owner, kept); share while an account is being deleted (refused, nothing queued) | PASS |
| Final gate (no other build running) | `supabase db reset` + `supabase test db`: 14 files, 119 tests PASS; `dart format`: 1675 files, 0 changed; `flutter analyze`: no issues; `flutter test --timeout 90s`: **6,244 passed, 21 skipped, 0 failed** (search p95 test passed) | PASS |

**Not verified end to end (lower-level tests are not counted as these):**
- The iOS and Mac **share sheets** themselves (`SLComposeServiceViewController` → Post): only the
  `ShareQueue`/`DotQueue` code they call is tested (XCTest, cross-process check). Driving the Mac
  share sheet needs an Accessibility grant for UI automation (a security setting, not changed);
  an iOS share-sheet UI test needs a new UI-test target (owner approval for a native target).
- The refusal alert in the iOS/Mac share sheet and the Android toast were not seen on screen
  (Android: the refusal itself is verified; the toast is not asserted).
- iOS widget, Live Activity, Siri and notification-action appends on a device; the Android widget
  and notification buttons (they share `DotActionReceiver.perform`, tested only through the share
  path's lock and the Dart suites).
- A real service-worker **notification click** (the test worker appends through the same
  `append`, triggered by a message, not by a notification).
- Physical iPhone, Android phone; Firefox and Safari; hosted staging.

**Remaining limitations and risks:**
- Unattributed entries are kept with no automatic expiry and are invisible to everyone (decision 1), but they count toward the 500-entry / 1 MB capacity, so enough of them would make new actions be refused. Their
  share text, and any waiting entry's, has been sealed at rest on Android and Apple since
  Iteration 1 Q2/Q3 (see "Iteration 1 final verification" below); ids, times and owners are
  still plaintext.
- A share refused while an account is deleted, or when the queue is full, is not saved: the person
  is told on the share sheets and the Add task intent; widget, Live Activity and notification
  buttons just do nothing visible.
- An account deleted while D1 was never opened (another device, the server) leaves its queued
  entries waiting under its id until `finishRemoval` runs on this device.
- The I7 hold is in memory: if the app is killed with D1 open, nothing is deleted, and the hold
  simply ends.

### Refusal feedback on iOS: Live Activity and Siri (third pass, 2026-11-09, awaiting review)

Owner-approved scope: fixes 1 and 2 of the silent-refusal audit only.

- **Live Activity Done / +15** (`LiveMarkDoneIntent`, `LiveAddFifteenIntent`, and the test channel's
  `perform`): the activity is ended or extended only when `DotActions.performLive` reports the
  action was queued. Refused (account deletion, queue full, unreadable queue): the activity stays
  exactly as it was. Live Activity buttons can't show a message, so "unchanged" is the honest result.
  An action stamped for an owner the app doesn't show yet is queued and counts as queued.
- **Siri / Shortcuts Mark done, Add 15 minutes, Start focus:** a refused action throws
  `NotSavedError`, whose text is the existing `intentNotSaved` string (en/de/fr/es: "Dottoday
  couldn't save this right now. Open Dottoday and try again."): no task, time or account. A queued
  action keeps its existing silent result.
- **Limitations:** Start focus from the iOS 18 Control Center control (`openAppWhenRun`) opens the
  app; whether Control Center shows the thrown error is up to the system and was not verified on a
  device. How Siri voices a thrown error is the system's wording. Widget Done, Android toasts and the
  reminder buttons during a deletion are separate follow-ups (not in this pass).

Tests: `ios/RunnerTests/DotIntentsTests` (16, iPhone 16 Pro Simulator, iOS 18.6) adds Live Done and
+15 accepted vs refused for each refusal reason (activity update not run, queue unchanged, no ticked
dot), an action for an owner not shown (queued, update runs), and the real `MarkDoneIntent`,
`AddFifteenIntent` and `StartFocusIntent` on the test host's App Group: no error when queued,
`NotSavedError` when refused, nothing queued, and the message carries no task id or account id.
`integration_test/live_activity_test.dart` adds a refused Done against a real Live Activity.

### Reminder actions during account deletion (fourth pass, 2026-11-09, awaiting review)

Owner-approved Option 1. The problem: a reminder's Done, Snooze or +15 (iOS, macOS and Android
notification buttons, the app launched by one, the in-app banner, the web with a tab open) goes
straight to `NotificationResponder`, which saved through the write path without the I7 queue. D1
only compared queued action ids, so a save after the review or export was deleted with the account
and missing from the export, with no warning (F1). The same save while the server deletion ran was
saved and then removed (F2). A change of owner between the lookup and the save let it land on the
previous owner's hidden rows (F3). Start and Open navigated with `router.go`, which closed D1
mid-deletion and ended its hold early (F5).

- **Write revision (F1):** `data/owners/deletion_seal.dart` keeps `write_revision:<owner>` in
  `local_meta`. `DriftWriteUseCase` raises it inside the save's own transaction, only when rows
  were actually written (`writeRows` now reports it). A save that fails or rolls back takes the
  raise with it. D1's review (`summary`, `exportFirst`) records it after the queue drain and before
  the rows are read, so it can only over-report. `deleteAccount` compares it as well as the queued
  ids, and a difference returns the existing `ReviewChangedFailure` with the existing D1 behaviour
  (export status cleared, typed word asked again). The sync log is not used: uploads prune it.
- **Deletion seal (F2):** `deleteAccount` calls `sealForDeletion` after `refuseQueue`. In one
  transaction, it writes `deletion_seal:<owner>` and then reads the revision. Every save checks the
  seal first, inside its own transaction (`checkNotSealed`), and is refused with the generic
  `StorageFailure` ("Couldn't save on this device. Try again."). Saves for other owners go through.
  The seal is removed in `finally` on every outcome: review changed, server failure, success
  (account removal also deletes `%:<owner>` keys) and seal failure. A seal a crash or kill left
  behind is cleared once at the app's launch (`AppLifecycleScope`), never by the background refresh.
  The calendar importer and write-back also check the seal. They don't raise the revision because
  imported events are not in the export.
- **Why no save can slip between:** the seal and every counted save are SQLite transactions on
  the same database, and SQLite runs them serializably, across connections too. The background
  refresh isolate opens its own connection, which is why an in-memory counter was not enough. A save
  ordered before the seal raised the revision the seal reads, so D1 stops. A save ordered after
  sees the seal and is refused before it commits. In WAL, a save whose read snapshot predates the
  seal can't commit its write (`SQLITE_BUSY_SNAPSHOT`), so it fails and nothing is written.
- **Owner check (F3):** the responder's Done, Snooze and +15 use `.whileShown()`. A change of owner
  between the lookup and the save writes nothing for either owner.
- **Feedback and navigation (F5):** while a deletion runs (`OwnerSwitch.deleting`, from
  `refuseQueue` to `releaseQueue`) the responder doesn't navigate (Open, Start, Wind Down, day
  summary, Wake Up), so D1 and its hold stay. A save refused while a deletion ran is reported
  through `reminderRefusalProvider`, but only within the owner session the tap began in (see
  "Refusals stay in their owner session" below). The message is `failureMessage`, with no task or
  account detail, and no new string. Outside a deletion, reminders behave as before.

Tests (local only):

- `test/data/owners/deletion_reminder_test.dart` (11):
  - Done, Snooze and +15 after the export stop the deletion; the next export holds the change; the
    renewed confirmation deletes.
  - A change before the export is in it.
  - Each action during the server deletion is refused with `StorageFailure`, saves nothing and
    doesn't navigate.
  - Open, Start, Wind Down and day summary don't navigate during the deletion and do afterwards.
  - A failed server deletion releases the seal and saves resume.
  - Outside a deletion a reminder saves and the revision rises by one.
  - Wake Up's Check-ping hint (common write path) is refused during the deletion.
- `test/data/owners/deletion_race_test.dart` (9):
  - Concurrency: a raw save raced against `deleteAccount` at 40 microtask offsets; both outcomes
    were exercised and none was silent.
  - Concurrency: a reminder Done raced against the confirmation at 55 offsets, the tap sometimes
    starting first. Each run is detected, refused and reported, or after the deletion finished (a
    gone task opens Today); a deleted task's route is never opened.
  - Concurrency: two connections to one WAL file, 60 iterations of a background save against the
    seal. Every committed save is what the seal read, and a save after the seal is refused.
  - A change of owner between the lookup and the save.
  - The revision moves only for a committed change: no-op save, foreign-key failure, rolled-back
    transaction, refused save; another owner still saves; launch clears a stale seal.
- `test/data/calendar/calendar_importer_test.dart`: nothing is imported for a sealed account.
- `deletion_queue_test.dart` (8, I7 queue protections) now uses the shared `DeletingServer`.
- Mutation check: removing any one safeguard (the revision compare, the seal check, `.whileShown()`,
  the navigation hold, the revision raise) fails at least one of the new tests.

Results (macOS host, local only):

- `dart format --set-exit-if-changed`: 0 files changed.
- `flutter analyze` and `dart analyze`: no issues.
- Unit (`--exclude-tags golden,perf,supabase`, random order, seed 1924442251): 4004 passed, 21
  skipped.
- Goldens (`--tags golden`): 2248 passed.
- Perf (`--tags perf --concurrency=1`): 5 passed.
- New files: `deletion_reminder_test` 11/11, `deletion_race_test` 9/9.
- The related owner, I7, responder, write and calendar suites: 151 passed before the new tests.
- Not run: the `supabase` tag needs a local stack (`supabase start`) and hangs without one, as in
  CI's unit job; device or simulator runs; integration tests.

Limitations, not fixed by this pass:

- A change synced from another device while D1 is open is not detected. Sync pulls don't raise the
  revision. That is a separate export-consistency question.
- Trash purge (30-day tombstones) doesn't raise the revision. It only removes rows the export holds
  more of, so nothing is lost from a confirmed export.
- The Android Wake Up alarm actions (snooze, "I'm up") write `wake_up_days` through their own path.
  That is device-local and not in the export, and the Wake Up ownership blocker still covers it.
- Native notification buttons were not driven on a device or simulator in this pass: the tests
  stop at the responder. (The SnackBar under the D1 dialog is fixed below.)
- On the web, the service worker posts a tap to the first window, which may be a tab without the
  database (an existing, unrelated issue).

Open before push approval (owner 2026-11-09):

- **A. Refusal-message visibility:** fixed locally (below, uncommitted, awaiting review); still
  not seen on a device or simulator.
- **B. Crash recovery:** whether clearing a stale seal at launch can reopen saves to an account
  whose deletion or local removal is still pending.
- **C. External changes:** changes synced from another device during the D1 review are not
  covered by the local revision (export-consistency risk, separate).
- **D. Remaining paths:** the Android Wake Up path, physical-device behaviour, and the writers
  outside the revision: sync pulls, trash purge, and the calendar import and write-back (seal only).

#### Refusal message inside the D1 dialog (2026-11-09, commit `19047b7`)

Found after commit `9c253d9`, with a throwaway widget probe. On tablet, Mac and web, D1 is a modal
dialog. The root SnackBar was drawn under its barrier: dimmed, not hit-testable and missing from the
semantics tree, so screen readers never heard it. On phones D1 is a full-screen page and the
SnackBar shows on it.

- While a D1 dialog is open it registers with `refusalDialogsProvider` (a plain counter, set in
  `initState` and cleared in `dispose`). The root's `showReminderRefusal` then skips the SnackBar,
  and D1 listens to `reminderRefusalProvider` and shows the existing `failureStorage` message in its
  existing error line (`StatusLine`, a live region). The phone page doesn't register, so the
  SnackBar still shows there as before.
- Priority: a deletion error (`ReviewChangedFailure` "something new arrived", a server failure)
  replaces the refusal in the error line. A new export or deletion attempt clears it. The typed word,
  export status and buttons are unchanged.
- In `19047b7`, if the deletion succeeded while the refusal was showing, the message was shown
  again as a SnackBar after the dialog closed, to the guest or next account. That replay is removed
  in the next section.
- No new strings or components, and no change to deletion, queue, owner or write logic.

Tests: `test/features/settings/delete_account_refusal_test.dart`, 15 passed:

- Tablet (1024×1366, iOS), Mac (1440×900) and web (1280×800, browser):
  - The refusal is inside the dialog, hit-testable, found exactly once, with no SnackBar.
  - Its semantics node is a live region labelled with the message.
  - The text is only the generic message.
  - D1 stays open and `endDeletion` isn't called.
  - The accessibility guidelines pass.
  - The same holds while the deletion runs.
- Phone: the SnackBar on the D1 page, found once.
- D1 closed: the SnackBar as before.
- "Something new arrived" and a server error each replace the refusal, and the dialog stays.
- Deleted while the refusal shows: the dialog closes and the message is shown once as a SnackBar.
- Light and dark at 200% text, 1024 and 1280 wide: no overflow, and the line sits inside the dialog
  and is hit-testable.

Mutation check: the root ignoring the open dialog, no inline refusal, and the refusal above a
deletion error each fail the tests.

Light, dark, accessibility-guideline and 200% text checks passed in the tested widget layouts.

Runs: `dart format` 0 changed; `flutter analyze` and `dart analyze` clean; 1,854 passed across
`test/features/settings` (D1 goldens included), `features/auth`, `data/owners`,
`data/notifications`, `policy`, `shared`, `a11y`, and the app shell, smoke, lifecycle and
screen-state tests. The full unit, golden and perf suites were not rerun for this change. Nothing
was checked on a device or simulator.

#### Refusals stay in their owner session (2026-11-09, uncommitted, awaiting review)

Owner decision: a refusal from a previous owner session is never shown to the owner or guest shown
now, even if this means a tap cut off by the switch ends with no message.

- **Tag at the start:** `NotificationResponder.handle` reads the owner epoch (`ownerEpochProvider`,
  raised at every change of owner) as soon as the tap arrives, before any profile or task lookup or
  save. Each refusal carries that epoch. It is never read when the failure happens.
- **Dropped at every step when the epoch is no longer current:**
  - The responder (`_refuse`) drops it; a save refused by a change of owner reports nothing.
  - `ReminderRefusal.report` won't take it.
  - The app root (`showReminderRefusal`) and the D1 dialog check `current` before showing it.
- **Not yet shown when the owner changes:**
  - A refusal reported but not taken yet is cleared, because the notifier is rebuilt on every
    epoch change.
  - A SnackBar already on screen, or waiting behind another, has session-bound text: when the
    epoch moves it removes itself and shows nothing.
- **No replay:** a successful deletion closes D1 without showing the refusal again. `showFailureSnack`
  (added in `19047b7` only for that replay) is removed.
- **Same session, unchanged:** the D1 dialog shows it in its error line, the phone D1 page and a
  closed D1 get the SnackBar. A save that went through reports nothing.
- **Untouched:** write outcomes, deletion, the revision, the seal and the I7 queue. Nothing is
  persisted, and no account identifier is in the message.

Tests (all passed):

- `test/data/notifications/notification_responder_session_test.dart` (8): a save held at the write
  path, then released as failed.
  - Done, Snooze and +15 refused within their session are reported, tagged with it.
  - Begun under A, refused after a switch to B: nothing reported, nothing opened.
  - Refused after a new guest session began: nothing reported, nothing opened.
  - A → B → A: still stale.
  - A save that went through reports nothing.
  - The epoch is taken before the lookups (switch during lookup: nothing reported).
- `test/data/notifications/reminder_refusal_test.dart` (3):
  - Taken within its session.
  - Never taken from an ended session (A → B, A → B → A).
  - Reported, then a switch: dropped and no longer current.
- `delete_account_refusal_test.dart` (now 18):
  - A successful deletion closes D1 with no replay, and a fresh refusal afterwards shows as usual.
  - A stale refusal shows neither in D1 nor as a SnackBar.
  - A refusal waiting behind another SnackBar never appears after a switch.
  - One on screen goes at once.
  - Dialog, phone, priority, accessibility and 200% cases as before.
- `deletion_race_test.dart`: in the racing Done (55 interleavings) every reported refusal was tagged
  with the session shown when it was reported. A switch between lookup and save reports nothing.
- Mutation check: removing the responder's, the notifier's or the SnackBar's session check each
  fails at least one test.

Runs: `dart format` 0 changed; `flutter analyze` and `dart analyze` clean; 1,895 passed across
`test/features/settings` (D1 goldens included), `features/auth`, `data/owners`,
`data/notifications`, `data/intents`, `core/editing`, `policy`, `shared`, `a11y`, and the app shell,
smoke, lifecycle and screen-state tests. The full unit, golden and perf suites were not rerun.
Nothing was checked on a device or simulator.

## Iteration 1 final verification (2026-11-10, local only, uncommitted, awaiting review)

Iteration 1 of the 5-iteration plan (account ownership and privacy). Accepted base: `733d7dda`.
Host Mac15,7, macOS 26.6.2; Flutter 3.47.8. **Local evidence:** this Mac, its iOS Simulator, the
Android emulator. **CI:** none for this checkpoint. **Physical devices and other browsers:** none.
Nothing ran against hosted Supabase.

### Cross-runtime fencing

`guestBackupFence` is a lock within one Dart isolate. It is enough only while every backup
operation, guest-work move, restore and privacy cleanup runs in the app's main isolate. That is
true today: `test/policy/cross_runtime_fence_test.dart` (7 tests) fails if any of it becomes
reachable elsewhere.

- The only other Dart entry point is `backgroundRefreshDispatcher` (workmanager). Neither it nor
  `daily_refresh`, the action-queue drainer or background sync names any backup, fence,
  owner-change or account-removal code.
- The calling files are exactly the backup data layer, the owner switch and sign-in step, app
  lifecycle housekeeping and the Settings export flows.
- The Apple extensions and `ios/Shared` run no Flutter engine and open no database. Only the two
  app bridges (`AppDelegate.swift`, macOS `IntentQueueBridge.swift`) open sealed words.
- On Android, only `DotQueue.kt` and the channel open sealed words.
- Web workers touch no IndexedDB and no backups.

No unsupported entry point was found, so no new locking was added. This is a check of the code's
shape, not of runtime behaviour. A future background backup, an extension database or a
worker-side restore would fail this test and needs a cross-process lock first.

### Backup and privacy failure injection

Two files: `test/data/backup/backup_privacy_failure_test.dart` (6 tests) and
`hidden_backup_survival_test.dart` (1). Failures are injected with SQLite triggers that abort the
write.

| Case | Result |
|---|---|
| Legacy evidence scrub fails just before a confirmed deletion (no promotion recorded, so only the legacy scrub can act) | The deletion call fails; removal stays pending; rows, owners, outbox, both write revisions and the shown owner unchanged; every backup byte-identical and the legacy backup still hidden. The rerun scrubs it, still quarantined, and finishes |
| P2 rewrite aborted before it lands | Same: unchanged, hidden, nothing recorded as scrubbed. The rerun scrubs and shows it |
| Crash between the validated rewrite and recording it as scrubbed | Rewritten but still hidden; a direct restore is refused. The rerun records it without rewriting again |
| Restore holding the fence while a deletion is confirmed | The scrub waits until the restore ends (backup still holds the moved row mid-restore), then runs; no stored backup and no live guest row holds the moved work |
| Restore of the hidden backup queued behind the deletion | Either refused or restored after the scrub; the moved work is never restored |
| Backups file recreated under an existing P1 cutoff | New guest backups, with restarted ids under the cutoff, are hidden (fail closed) until P2 shows them clean. The legacy-cutoff case was already covered by `legacy_guest_backup_test.dart` |
| Oversized (25 MB + 1) and not-a-backup guest backups, legacy and under a cutoff | Through the legacy scrub, P2, P3 after 31 days and maintenance: unchanged, hidden, stored, restore refused. The audit says `oversized` / `malformed`; none `restorableNow` |

Mutation checks (temporary source changes, restored afterwards; working tree verified):

| Mutation | Result |
|---|---|
| Restore not fenced | Caught |
| Legacy scrub removed from deletion cleanup | Caught |
| P2 records "scrubbed" before rewriting | Caught by 2 tests |

### Shared queue

**Defect found and fixed (uncommitted, needs review).** The native read returns an entry it can't
open marked `unreadable`, keeping its other fields. An entry stored with both sealed words and
stray `text` is never migrated, because it already has sealed words. If its words then failed to
open, `decodeQueuedAction` applied the stray text. Our writers never produce such an entry; it
needs a tampered or corrupted store. The fix is one line in `domain/intents/dot_action.dart`:
any entry still `sealed`, or marked `unreadable`, decodes to null, whatever plaintext it carries.

| Test | Result |
|---|---|
| `test/data/intents/sealed_queue_test.dart` (4): mixed queue after a restart (opened applies, unopenable kept across drains and owners); unreadable with stray text refused; sealed words as the background store reads them kept, never removed; no-owner entries quarantined whether opened or not | PASS (the stray-text test failed before the fix) |
| `ios/RunnerTests/DotIntentsTests` (27, iPhone 17 Simulator, iOS 26.5): adds a mixed sealed + leftover-plaintext queue (all open, the rest sealed, sealed entry untouched) and stray plaintext beside words that fail to open (marked unreadable, kept) | PASS 27/27 |
| `integration_test/queue_cipher_test.dart` (11, emulator Medium_Phone_API_37.0, Android 17 / API 37, debug): adds the mixed queue after a restart, stray plaintext never reaching the app as an action, and 40 concurrent shares and app reads (nothing lost, no plaintext at rest) | PASS 11/11 |

Already covered by earlier I1 tests:

- **Interrupted migration:** all or nothing, with a single write per platform. Android writes only
  if every entry sealed; Apple writes only if the list is complete.
- **Key loss and failed decryption:** covered on both platforms.
- **Concurrent native writes and app drains:** Swift (60 threads), the cross-process lock tool
  (360 entries, 0 plaintext) and the Dart drainer.
- **Unknown owner:** Dart.
- **No plaintext fallback on write:** Swift (no published key) and Android (refusal).
- **Debug-hook isolation:** a profile APK inspected earlier, plus the new policy test. The release
  APK is still **not built or inspected** (that build was denied earlier and was not retried).

### Performance and memory near 25 MB

`test/perf/backup_privacy_memory_test.dart` (`perf` tag, skipped unless `CR160_PERF` is set).

- **Workload:** six guest backups. Two are legacy backups and three are under a P1 cutoff, each
  23.7 MB of JSON with kept and moved work. The sixth is a 25.0 MB oversized backup. The moved
  half is then promoted.
- **Sampling:** RSS every 2 ms from a separate isolate.
- **Runs:** each step in a fresh process.
- **Scope:** flutter_tester on the macOS host (Mac15,7), in-memory SQLite with **no SQLCipher**,
  no I/O. These are **not** iPhone, Android or Mac app figures, and the web was **not measured**.
  The web does keep local backups (an encrypted sqlite3mc database in IndexedDB, taken by the
  same daily housekeeping), so these steps run there too; browser memory remains unmeasured.
- **What the number means:** "above idle" is RSS growth over a warm process. Heap freed during
  setup can be reused without RSS growth, so it understates the working set. It compares like
  with like, before and after.

**Memory fix (2026-11-11, uncommitted).** The P2/P3 scrub (`_scrubPromotion`) and the legacy
evidence scrub (`scrubLegacyByEvidence`) each read every candidate backup's JSON in one query
(about 6 × 24 MB held at once). Both now list ids and owners without any text, then read one
backup's text at a time (`data/backup/backup_rows.dart`). Nothing else changed:

- same visibility and quarantine checks;
- same owner-guarded update by original id;
- same read-back validation before the scrubbed marker;
- same fence and failure semantics.

Each read rechecks the owner: a backup removed between the listing and its read is the only one skipped; one whose owner changed is counted as left (never scrubbed, recorded or shown); a failed read throws, so the scrub stops and the removal stays pending. The benchmark below ran before this owner recheck was added (one extra small column per read; not re-measured).

| Step | Before (3 runs) | After (6 runs) | Change |
|---|---|---|---|
| Deletion cleanup (legacy + P2) | 194.1 / 209.7 / 209.2 MB, mean 204.3; 2.13–2.17 s | 32.3 / 39.5 / 38.3 / 49.2 / 47.7 / 28.1 MB, mean 39.2 (range 28.1–49.2); 2.00–2.08 s | −165 MB (−81 %); time −5 % |
| Maintenance (P3 + legacy + daily backup) | 167.1 / 167.4 / 169.3 MB, mean 167.9; 1.65–1.68 s | 40.0 / 29.1 / 29.5 / 66.3 / 29.6 / 42.8 MB, mean 39.6 (range 29.1–66.3); 1.56–1.60 s | −128 MB (−76 %); time −5 % |

Notes on the measurements:

- The last three "after" runs also assert each backup's outcome. The legacy backups stay
  quarantined, the P1 backups are listed again without the moved work, and the oversized one is
  hidden, stored and byte-identical. All three passed.
- Every run is under the 100 MB engineering target for this synthetic workload. That target is
  not an approved release budget, and these figures are not comparable with the Stage B
  import/export budgets.
- Variability is about ±20 MB, from GC timing.

Regression tests: `test/data/backup/scrub_memory_test.dart` (7). A drift `QueryInterceptor` on a
copy of the store counts the backup texts each query returns.

| Check | Result |
|---|---|
| P2, P3 and the legacy scrub return at most one text per query (the pre-fix code returned 7 and 8; mutation caught) | Pass |
| Each backup's scrubbed marker is absent when its rewrite runs | Pass |
| Oversized, not-a-backup and ownerless backups untouched | Pass |
| A failure on the second of three backups: the first stays scrubbed and shown, the rest hidden and unchanged, the removal pending; the rerun finishes, the legacy and junk backups stay hidden | Pass |
| Repeated maintenance changes nothing after the first run | Pass |
| Between listing and reading (P2 and legacy): a removed backup is skipped; one whose owner changed is left untouched, unrecorded and counted (mutation treating it as removed: caught by 2 tests) | Pass |
| A failed read is never skipped: the scrub throws, nothing after it is recorded, the backups stay hidden | Pass |

Restore-versus-scrub serialisation is the existing test in `backup_privacy_failure_test.dart`;
it passes after the fix.

### Unverified

Updated after Stage B (B8, 2026-11-12): the measurements of `docs/cr-160-multipart-export.md` §7 ran on
a physical iPhone 17 Pro (profile build, temporary databases, none of the account flows), and the
regression pass ran on the simulators, the Mac and Chromium; the list below still holds otherwise,
with §7's 4 GB iPhone and 3 GB Android phone and real file picks in each platform's picker added.


- The release APK (denied build).
- Physical iPhone, Android and Mac; locked-device and before-first-unlock behaviour.
- Real share sheets, Siri and Shortcuts end to end.
- Restore to a new device (device-only keys).
- Older Android versions.
- Firefox and Safari.
- Hosted Supabase.
- Goldens; the Supabase-, web- and perf-tagged suites, except the one measurement above.
- A process kill during migration (only the single-write design and the restart-state tests).

## Deleted accounts (interim, owner-approved)

Built. Delete screen: summary, "Export my data first" (complete and count-verified, or the delete
does not proceed), typed DELETE, then the server delete and local removal in one transaction
(profile, rows, pending changes, cursors, owner-keyed `local_meta`, backups). Removal is marked
pending first and idempotent; native retries at next launch, web shows "Removal from this browser
didn't finish" with Finish removing (with the clear-site-data warning). A copy pending removal is
never shown, synced, turned into guest data or moved. Web has no Keep. Tests:
`delete_account_test.dart`, `account_export_test.dart`, `account_switch_test.dart` group "a deleted
account", `account_screens_test.dart` group "web retry", criterion 11 step 5.

Not built (by owner decision): the passphrase-protected kept copy, `local_auth`.

## Regression tests (owner list 2026-11-08)

| Scenario | Status |
|---|---|
| Signing out with unsynced changes | PASS (data, screens, 4-platform local runs) |
| Signing into another account on the same device | PASS (data, 4-platform local runs) |
| Existing guest work, then a different person signs in | PASS (data + G1/G1b widget tests; criterion 11 step 3) |
| Guest to existing account (bring in) | PASS (data + web flow 2) |
| Deleted-account isolation and removal | PASS (data, screens, criterion 11 step 5) |
| Settings selection and Decide later | PASS (data + B1 widget tests) |
| Offline retries and interrupted migrations | PASS (data + web flow 4) |
| Server rejection of wrong-owner changes | PASS (pgTAP 0014; fake server) |

## Server rollout

Plan: `docs/cr-160-rollout.md` (single step, beta only, owner-approved). Nothing hosted touched.

## Runs 2026-11-09: criteria 10 and 11 (local stack only)

Everything below ran against the **local** Supabase stack (`supabase start`, migrations 0001–0014,
`supabase functions serve` for `delete-account`). Nothing hosted, no `db push`, no `.env.prod`.
Accounts were created with the local admin key and signed in on the app's own client with the
magic link's token (`auth.verifyOTP` with the link's `hashed_token`, i.e. what the link does; the
PKCE callback exchange itself is covered by `test/supabase/auth_flow_test.dart`, not here). The
admin key is test-only and never in the app (it is a `CR160_SERVICE_KEY` define read only by the
test). "Offline" is a real network failure for the app only: the app talks to the stack through
`tool/cr160/net_switch.py` (a pass-through on 127.0.0.1:54331 that the test turns off and on via
127.0.0.1:54332; off = open connections cut, new ones closed). Android reaches the host with
`adb reverse tcp:54331/54332/54321`.

Toolchain: Flutter 3.47.8 stable (Dart 3.13.7), Supabase CLI 2.121.0, host Mac15,7 on macOS 26.6.2
(25G83). Defines file (`SUPABASE_URL=http://127.0.0.1:54331`, the local anon key,
`CR160_SERVICE_KEY` = the local service-role key) kept outside the repo.

### Criterion 11: shared device (`integration_test/cr160_shared_device_test.dart`)

One run, on the real platform with the encrypted database, the real notification plugin, the real
`OwnerSwitch`, `AccountActions` and sync engine:

1. Guest makes a task (`gOld`). A signs in (guest work kept separate), syncs, adds a task with a
   reminder 30 s ahead; the reminder is **delivered** (OS notification centre; on the web the
   in-app strip) and Today's view model holds the task.
2. Network cut. A adds 2 tasks with reminders; sync shows offline; A signs out (Account page path:
   `ownerSwitch.signOut`, then auth sign-out). Checked: the guest is shown, A's pending changes are
   kept, the server has neither offline task.
3. B signs in having **asked to bring guest tasks in** (worst case). Checked on device: B is the
   shown owner; B's rows, Today's view model and the screen (text and semantics) have none of A's
   tasks or `gOld`; no pending or delivered notification of A remains. Server: RLS-scoped query
   with B's session sees B's task and none of A's ids or `gOld`; admin query: B's account has none
   of them, and A's offline tasks still aren't on A's account. `gOld` (made before A's session) was
   **not brought in** and is still the guest's (eligibility, policy §3).
4. B signs out; A signs in again: A's outbox empties; the server holds A's synced task and both
   offline tasks **exactly once** each (admin count by id and by run tag = 3), and none of B's ids
   or `gOld`; RLS-scoped query as A agrees.
5. D signs in, syncs a task, takes a backup, then deletes the account (`AccountActions.deleteAccount`
   → local `delete-account` function → `OwnerSwitch.accountDeleted`). Checked: no occurrences,
   profile, change log, owner-keyed `local_meta` or backups of D on the device; none on the server;
   signed out; A's copy untouched; a guest is shown.

| Date (UTC) | Platform | Device / runtime | OS | Build | Command | Result | Notes |
|---|---|---|---|---|---|---|---|
| 2026-11-09 02:20 | macOS | Mac15,7 (host) | macOS 26.6.2 (25G83) | debug | `flutter test integration_test/cr160_shared_device_test.dart -d macos --dart-define-from-file=<local defines>` | **PASS** (`All tests passed`, 56 s) | Same container as the owner's Mac debug builds: it signed out whatever was shown there first |
| 2026-11-09 02:22 | Android | emulator `Medium_Phone_API_37.0` (sdk_gphone64_arm64) | Android 17 (API 37) | debug APK | `DEFINES=<local defines> tool/device_tests.sh android emulator-5554 cr160_shared_device` (grants POST_NOTIFICATIONS and exact alarms) | **PASS** (121 s) | Earlier run 01:0x UTC with the previous test revision also PASS |
| 2026-11-09 02:24 | iOS | Simulator iPhone 16 Pro | iOS 18.6 (22G86) | debug (simulator) | `DEFINES=<local defines> tool/device_tests.sh ios 4FA4080A-… cr160_shared_device` (provisional notifications, no prompt) | **PASS** (121 s) | Earlier run with the previous revision also PASS |
| 2026-11-09 01:27 | Web | Playwright Chromium 156.0.8078.4, headless, fresh context | macOS 26.6.2 host | profile (dart2js), served locally | `flutter build web --profile -t integration_test/cr160_shared_device_test.dart --base-href /shared/ …`; `node tool/cr160/web_flows.mjs shared` | **PASS** | Delivered = in-app strip (no notification permission in a test browser); pending = the tab's timers |

Output excerpt (macOS, ids only; Android, iOS and web print the same lines with their own ids):

```
CR160 signed in b910b409-0de5-464d-a194-d49065fbe735          (A)
CR160 A reminder delivered ids={1494509896}
CR160 network offline
CR160 offline seen after 10s
CR160 signed out: auth err (local session cleared)
CR160 A offline tasks 01a1be1c-f653-… 01a1be1c-f693-… kept, outbox=54
CR160 signed in 719e5a8f-1532-4bb5-8ccb-9928fd764a21          (B)
CR160 B RLS ids=1 hasB1=true
CR160 B pending=8 delivered=0 none of A
CR160 signed in b910b409-0de5-464d-a194-d49065fbe735          (A again)
CR160 A returned: server=3 rls=3 B-ids=0
CR160 D deleted, left on device: {occurrences: 0, profiles: 0, change_log: 0, local_meta: 0, backups: 0}
CR160 RESULT PASS
```

### Criterion 10: web flows (`integration_test/cr160_web_flows_test.dart`)

One web build per page, all on one origin (`http://127.0.0.1:8099`): `/test/` (the flows test,
`?phase=`), `/shared/` (criterion 11 above, which is flow 3) and `/app/` (the real app,
`lib/main.dart`). `tool/cr160/web_flows.mjs` drives Playwright's Chromium (the `tool/a11y`
install): a reload is a new page load in the same browser profile, "another device" a fresh
profile, the second tab a second page in the same profile.

| Date (UTC) | Flow | Browser | Build | Command | Result | What was covered |
|---|---|---|---|---|---|---|
| 01:27 | 3 Sign-out → other account | Chromium 156, fresh context | profile | `node tool/cr160/web_flows.mjs shared` | **PASS** | As criterion 11 above, incl. network cut, offline sign-out, B, A again, deleted account |
| 01:37 | 1 Guest → new account (Bring in) | Chromium 156 | profile | `node tool/cr160/web_flows.mjs flow1` | **PASS** | 3 guest tasks; A (new) signs in with Bring in; A's local rows have them; server holds each once; **page reloaded**: A shown again, synced, still once each. Not covered: starters, a routine, settings on screen |
| 01:49 | 2 Guest → existing account | Chromium 156, two fresh contexts | profile | `node tool/cr160/web_flows.mjs flow2` | **PASS** | Profile 1: A with Europe/Berlin and 2 tasks. Profile 2: guest with Asia/Tokyo and 2 tasks signs in as A with Bring in: 2+2 tasks once each on the server; server profile and the stored device profile stay Europe/Berlin. Not covered: starters/hints, the B1 screen |
| 02:12 | 4 Interrupted migration | Chromium 156 | profile | `node tool/cr160/web_flows.mjs flow4` | **PASS** | Guest with 3 tasks, Bring in recorded, sign-in verified, **network cut at once and the page left** (`RELOAD-NOW` → same tab loads `flow4after`). Before leaving: the local sign-in step had already run (A shown, 3 rows). After the reload, still offline: A shown, status failed (the state that offers Try again), outbox kept; network back: each task once on the server. Not covered: a reload *inside* the local sign-in transaction (it finished before the reload could land; atomicity is unit-tested, criterion 9) |
| 02:10 | 5 Second tab | Chromium 156, one context | profile | `node tool/cr160/web_flows.mjs flow5` | **PASS** | Tab 1 signed in as A with a task; tab 2 opens the real app: "Dottoday is open in another tab", no A task text (semantics tree). Tab 1 switches to B; tab 2 reloads: still the lock screen, nothing of A. Not covered: "Use it here", a second tab during flow 1 |
| — | 1–5 | Firefox | — | — | **PENDING** | Playwright's Firefox isn't installed and no geckodriver; installing either is a download the owner has to allow |
| — | 1–5 | Safari | — | — | **PENDING** | `safaridriver` exists but needs `safaridriver --enable` (admin, a system setting); not done |
| — | private window | Chromium | — | — | Covered in effect | Every Playwright context is a fresh, ephemeral profile (like a private window); a real Chrome incognito window was not used |

Output excerpt (flow 4):

```
[flow4] CR160 network offline
[flow4] CR160 before reload: A rows 3, shown A true
[flow4] CR160 RELOAD-NOW
[flow4after] CR160 after reload offline: status failed, A rows 3, outbox 83
[flow4after] CR160 network online
[flow4after] CR160 server ee2c269c-7ae7-4349-bf78-ee3f6200e60c holds 3 ids once each (total 3)
SCENARIO flow4 PASS
```

### Defects found

**D-1 (fixed in this branch): after a sign-out, the next account never synced by itself.** Found
on macOS: the second sign-in in one app session threw `Bad state: Stream has already been listened
to` from `EngineSyncService._signedIn` (`_remote.listen`). The Realtime nudge stream
(`RealtimeNudges.stream()`, built once per sync service) was single-subscription; sync listens
again at every sign-in after `_stop()` cancelled it. The new account was shown and its sign-in
step ran, but its outbox watch, Realtime nudges and first run were never set up, so its changes
went up only on "Sync now" or after a restart (R-08). Not a leak between accounts, but it breaks
"A signs out, B signs in" on every platform. Fix (smallest): `stream()` now returns
`Stream.multi`, each listen opening its own feed (`lib/data/sync/realtime_nudges.dart`);
regression test "listening again after a cancel opens a new feed" in
`test/data/sync/realtime_nudges_test.dart` (fails with the old code with the same error). Errors and
the end of each feed are passed through.

**Observations (not fixed, no data risk):**
- Signing out while offline returns an error from the auth call although the local session is
  cleared and the account hidden (`signed out: auth err (local session cleared)` above), so the Account page shows the failure
  message although the sign-out took effect on this device. Misleading, not unsafe; follow-up.
- `SyncService.syncNow()` returns `Ok` without waiting when a run is already under way, so a
  "Sync now" pressed during a failing run reports nothing; the status stream is correct.
- The day thread paints task titles: on macOS and Android the title was found neither as text
  nor as a semantics label on Today's spread (iOS and web did find it), so the device-side check
  uses Today's view model (`timelineDataProvider`) and the screen check is a best-effort extra.
- On the web, GoTrue shares sessions between Supabase clients whose URL *host* matches (one
  BroadcastChannel per host). The test's admin client therefore uses `localhost` while the app uses
  `127.0.0.1`; the app itself has one client, so this does not affect it.

### Still unverified

- **Hosted staging**: not touched; the same runs against staging need the owner's go (and 0014
  deployed there, `docs/cr-160-rollout.md`).
- **Physical devices**: iPhone and Android phone not run. Only a device can show: notifications
  removed from a real lock screen / notification centre after the switch, widgets, Live Activity,
  the Android ongoing notification, the Mac status item and Wake Up alarms after a switch (I7, I8),
  a real network drop (Wi-Fi off, captive portal) instead of a cut at the pass-through, and Keychain
  / Keystore behaviour after reinstall.
- **Screens**: G1, G1b, B1, A1–A3 and D1 were exercised through `AccountActions`, not by tapping
  them; their widget tests cover the screens.
- **Firefox and Safari** (above), and a reload inside the local sign-in transaction.
- The magic-link PKCE callback on each platform (sign-in used the link's token directly).

## Plan for criterion 10 (web end-to-end) · run on Chromium 2026-11-09 (above); Firefox, Safari PENDING

Against a local Supabase (`supabase start`, migrations through 0014), the web build served locally
(`flutter run -d chrome --dart-define-from-file=.env`), two test accounts A and B made in the local
stack. Run in Chrome, Firefox and Safari, and once in a private window. For each flow record the
browser, build and result; check the server with RLS-scoped queries (signed in as each account) and
with the local admin key.

1. **Guest → new account.** As a guest, onboard (pick 2 starters), add 3 tasks and a routine. Sign in
   as A (new). Expect: same tasks and settings on screen; A's server rows = the guest's, once each;
   reload: nothing duplicated.
2. **Guest → existing account.** A already has tasks and Berlin settings from another device. In a
   fresh profile, as a guest pick Tokyo and add 2 tasks, then sign in as A. Expect: A's tasks plus
   the 2; settings stay Berlin; no starter or hint twice on the server.
3. **Sign-out → other account.** Signed in as A, go offline (DevTools), add 2 tasks, sign out, go
   online, sign in as B. Expect: B sees none of A's tasks; B's server rows have none of A's ids;
   sign out, sign in as A: A's 2 offline tasks reach A's server.
4. **Interrupted migration.** As a guest with tasks, start sign-in as A and reload the tab while the
   first sync runs ("Bringing your tasks…"); also once with the network cut mid-sync. Expect: after
   reload the tasks are A's, the status shows the existing error with Try again where it failed, and
   after it succeeds nothing is duplicated on the server.
5. **Second tab.** Open a second tab during flows 1 and 3. Expect: the one-tab lock (`tab_lock.dart`)
   holds; the second tab never shows the other account's tasks.

## Plan for criterion 11 (shared-device runs) · run on the local stack 2026-11-09 (above); hosted staging and physical devices PENDING

On each of iPhone, Android, Mac and web, with the hosted staging project only after the owner allows
it (this branch touched nothing hosted; `0014` is not pushed):

1. A signs in, syncs, then adds 2 tasks offline and signs out.
2. B signs in on the same device. Verify on the device that B sees none of A's tasks, and server side
   (an RLS-scoped query signed in as B, e.g. `select id from occurrences`) that B's account holds
   none of A's ids.
3. B signs out; A signs in again. Verify that A's 2 offline tasks reach A's account (RLS-scoped query
   as A) and that A's account holds none of B's.
4. Record per platform: build, OS version, date, result, query output (ids only, no task text).
