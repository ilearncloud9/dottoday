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
| 10 | Web end-to-end | PARTIAL | Chromium 156: flows 1–5 PASS on the local stack (runs below). Firefox, Safari PENDING (no driver; installing one needs the owner's go). Hosted staging PENDING |
| 11 | Shared-device tests on all four platforms | PARTIAL | PASS on the local stack: macOS 26.6.2, iOS 18.6 Simulator, Android 17 emulator, web/Chromium (runs below). Physical iPhone/Android and hosted staging PENDING |
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
| I7 | Wind Down timer; action queue | **OPEN.** Wind Down cancelled and re-armed; the in-app queue is drained before the switch. Not fixed: a native share-extension action queued under A and read after the switch lands with the next owner (queue entries carry no owner) | `owner_switch_test.dart` "actions queued before the switch…", "a run queued for A…" |
| I8 | Widgets, Live Activity, ongoing notification, status item, Wake Up alarms | Empty snapshot written at the switch, then the new owner's; `disarmAll` alarms | `owner_switch_test.dart`, `snapshot_write_paths_test.dart` |

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
