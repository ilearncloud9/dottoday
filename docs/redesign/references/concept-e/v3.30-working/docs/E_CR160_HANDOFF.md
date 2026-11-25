# E-CR160 implementation handoff (ED-231)

- **Status:** design COMPLETE for A1, A2 (both states), A3, B1 and the "Choose settings" return path (ED-222 to ED-230, CR-173 resolved). **CR-160 CLOSED by the owner 2026-11-16** ([ilearncloud9/dottoday#75](https://github.com/ilearncloud9/dottoday/pull/75) merged to main; accepted limits and the remaining production step, `docs/cr-160-rollout.md`, are in `docs/cr-160-verification.md` § "Owner close-out 2026-11-16"). These boards are the approved account screens for M20.12 (ED-362).
- **This file proves no acceptance criterion.** Finished mockups do not satisfy criterion 2 (safe sign-out) or criterion 7 (no silent settings replacement). Only the build's checks in `docs/cr-160-verification.md` can do that, and on 2026-11-09 they read:
  - criterion 2: PARTIAL (I7 share-extension race and the misleading offline error are still open);
  - criterion 7: PASS (automated) only. B1 has not been tapped on any platform run.
- **Board:** E-CR160, https://claude.ai/artifact/MaCdg3soqyxnFcxN5G9vja, version `1794224830-1be6`, snapshot v1.96-working. Each light frame has a `…Dark` twin. **Tablets (2026-11-17, ED-365, awaiting approval):** `Tablet…` (iPad) and `AndroidTablet…` frames for A1, A2, A2 unconfirmed, A3, B1 and Choose settings, version 56 (`1794934922-ed76`), snapshot v3.30-working.
- **Build facts:** read only, from `fix/cr-160-account-ownership` at `ff3266eb`, plus the uncommitted changes in that session's worktree, which is marked "(local)" where it matters. Nothing on the branch, the board, or in auth, sync or Supabase was changed to write this.
- **Applies to every screen below:**
  - **Styling.** The built screens use today's DotTheme, not Concept E's Manrope type, teal accent and tokens (verification blocker 6). Matching the frames' look is implementation-pending everywhere.
  - **Layout.** Choose it by width class (compact / medium / expanded). The Android idiom changes only its own chrome. Never branch on `Platform.isX`.

Legend: **Built** = present in the branch code. **Verify** = in code but not yet seen working on the platform. **Pending** = approved design that the build does not do yet.

## A1 · Sign out? (everything confirmed synced)

- **Frames:** `SignOutPlain` (iPhone), `AndroidA1`, `DesktopA1` (Mac/web); ED-224.
- **Shown when:** the server has confirmed a sync, nothing is pending, and there are no open conflicts. Otherwise A2 shows.
- **Copy:**
  - title: "Sign out?";
  - body: "Your tasks and settings are hidden on this device until you sign in again. Everything has synced to your account.";
  - buttons: Cancel, Sign out.
- **Actions:** Sign out signs out and shows A3. Cancel only closes the dialog, and A1 never starts a sync.
  - Android: Back or a tap outside cancels.
  - Mac/web: Esc cancels, and there is no Esc hint line.
- **Accessibility:**
  - the title is a heading;
  - targets are 44 pt on iPhone and 48 dp on Android;
  - on Mac/web, focus starts on Cancel and shows the ED-174 focus ring;
  - text at 200 % scrolls inside the dialog.

| Item | State |
|---|---|
| Rule for when A1 shows (`everythingSynced`: synced, last sync time set, 0 pending, no conflicts) | Built; unit-tested |
| Copy (`accountSignOutTitle`, `accountSignOutSyncedBody`) | Built |
| Body scrolls at large text (`SingleChildScrollView`) | Built; verify at 200 % on all four platforms |
| Esc, Back and a tap outside cancel | Built through `showDialog` defaults. The test "Esc cancels with no sync" covers Mac/web; verify Android Back |
| Title marked as a heading | Built |
| **Android buttons:** the board has right-aligned Roboto text buttons; the build uses one shared compact row with Cancel outlined and Sign out filled, both full width | **Pending** |
| **Mac/web initial focus on Cancel:** the build sets no `autofocus` | **Pending** (then verify the focus ring) |
| Offline sign-out shows an error even though sign-out worked (blocker 4) | **Pending** (implementation bug) |

## A2 · Changes not synced (two states)

- **Frames:**
  - count state: `Main` (iPhone), `AndroidA2`, `DesktopA2`;
  - unconfirmed state: `A2Unconfirmed`, `AndroidA2Unconfirmed`, `DesktopA2Unconfirmed`;
  - decisions: ED-222, ED-225, ED-226.
- **Shown when:** A1's rule fails.
  - Count state: one or more changes are waiting.
  - Unconfirmed state: nothing is waiting, but the last sync is not confirmed (count = 0).
- **Copy:**
  - Count state title: "{n} change(s) haven't synced yet". Body: "…saved on this device for {email}…". Then "They stay on this device under this account."
  - Unconfirmed state title: "Sync hasn't been confirmed yet". It uses the count-0 body.
  - Buttons: Stay signed in, and "Sign out and keep them here".
  - iPhone and Android: the hint "Dottoday tries to sync them now." sits under Stay signed in.
  - Mac/web: the note "Esc cancels and starts nothing. Stay signed in tries to sync now."
  - The fuller sentence "Until then, no one else…" is used **only** after I1–I8 and the physical-device runs pass.
- **Actions:**
  - Stay signed in syncs now.
  - "Sign out and keep them here" signs out and keeps the pending changes for this account.
  - Esc, Back or a tap outside starts nothing.
- **Accessibility:**
  - the title is a heading;
  - the cloud badge is decorative;
  - the body scrolls at 200 % and both actions stay reachable (ED-225);
  - Mac/web keyboard order runs from the secondary action to the main one, with the main action rightmost.

| Item | State |
|---|---|
| Both states and all copy (`accountSignOutPendingTitle`/`Body` plural with `=0`, `accountSignOutKeptHere`) | Built |
| Isolation sentence locked off (`a2IsolationVerified = false`) | Built; keep it false until I1–I8 and the physical-device runs pass |
| iPhone layout (badge, Stay filled, hint, Keep outlined) | Built |
| Android layout (icon, tonal Stay, hint, Keep as a text button) | Built (ED-226 hint present) |
| Mac/web layout (Keep outlined, Stay filled at the end, Esc note) | Built |
| Scrolls at 200 % | Built; verify on all four platforms, including that the last action is reachable |
| Feedback after "Stay signed in" while sync keeps failing (blocker 5) | **Pending** |
| The promise that nothing shows to another user (I7 share-extension race, blocker 1) | **Pending** (the CR-160 session is verifying I7) |
| Firefox, Safari, physical iPhone/Android, hosted staging | **Pending** (criteria 10 and 11 PARTIAL) |

## A3 · You're signed out

- **Frames:** `SignedOut` (iPhone), `AndroidA3`, `DesktopA3`; ED-223, ED-227.
- **Copy:**
  - title: "You're signed out";
  - body: "Your tasks stay on this device under your account. They come back when you sign in again with the same account.";
  - buttons: Sign in, and "Use without an account";
  - hint: "Opens this device's plan without an account. Anyone who uses this device without an account can see it."
- **Shown when:** right after sign-out, and on every launch until someone signs in or the guest plan is chosen.
- **Actions:**
  - Sign in opens the sign-in panel.
  - "Use without an account" opens the guest plan.
  - Both are disabled while busy.
- **Accessibility:**
  - the illustration is decorative and hidden from screen readers;
  - the title is a heading;
  - the page scrolls at 200 %;
  - on Mac/web the two buttons sit side by side and wrap onto separate rows at large text, and labels never truncate.

| Item | State |
|---|---|
| Title, buttons, hint | Built |
| New body (en/de/fr/es) and decorative art (`ExcludeSemantics`, `signedOutArt` removed) | **Local in the CR-160 worktree, uncommitted.** Committed `ff3266eb` still says "kept safely" and labels the art "An empty day" |
| Page scrolls (`DecisionFrame` → `CustomScrollView`) | Built; verify at 200 % |
| **Mac/web layout:** the board centres a 400 px column with the buttons side by side; the build stacks them in one readable column at every width | **Pending** |
| Android layout (filled Sign in, outlined "Use without an account", 48 dp) | Built in structure; Concept E styling pending |

## B1 · Which settings should Dottoday use?

- **Frames:** `SettingsChoice` (iPhone), `AndroidB1`, `DesktopB1`; ED-228, ED-229.
- **Shown when:** after sign-in, if the account already has settings and this device's settings differ. The board shows only rows that differ. It never previews guest tasks.
- **Copy:**
  - title: "Which settings should Dottoday use?";
  - body: "Your account already has settings. This device had different ones before you signed in. Your tasks won't be deleted.";
  - hidden legend: "Settings to use";
  - cards: "Your account's settings" (preselected) and "This device's settings";
  - row labels: Time zone, Language, Your day, Layout;
  - note: "Only the settings that differ are shown.";
  - buttons: Continue, Decide later;
  - hint: "Until you choose, your account's settings stay. You can choose in Settings › Account."
- **Actions:**
  - Continue applies the chosen card. Only "This device's settings" changes anything.
  - Decide later keeps the account's settings, records the deferral, and offers "Choose settings" in Settings › Account.
- **Accessibility:**
  - the cards form one radio group with the legend;
  - the selected card shows an accent border **and** a filled radio, so the state is not shown by colour alone;
  - radio rows are 48 dp on Android;
  - the label column grows to fit its longest label at large text (`minmax(N, max-content)`), never a fixed width;
  - buttons keep labels on one line and wrap;
  - on Mac/web the main action is rightmost.

| Item | State |
|---|---|
| Copy, legend semantics, account card preselected | Built |
| Rows that differ: Time zone, Language, Your day, Layout and **Theme** | Built. Theme is a fifth row the board does not draw. It uses existing strings (`settingsTheme`, `settingsThemeSystem/Light/Dark`), so no new copy; it renders with the same label/value pattern |
| Decide later keeps the account's settings (it only stores a deferral flag) | Built; test "Decide later keeps the choice for later" |
| Code comment on `SettingsChoiceScreen` says Decide later "keeps the device's for Settings › Account" | **Verify wording.** The behaviour keeps the *account's* settings and the device's *offer*. The comment should say so |
| Label column grows at 200 % | **Verify** in a 200 % golden/screenshot; the board rule is ED-228/229 |
| **Mac/web layout:** the board has two cards side by side and the buttons right-aligned with Continue rightmost; the build stacks everything in one column | **Pending** |
| B1 tapped on a real platform run (criterion 7 says "not tapped on a platform run") | **Pending** |

## Return path · Settings › Account "Choose settings" (after Decide later)

- **Frames:** `AccountChoose` (iPhone, 64 pt inset grouped row), `AndroidAccountChoose` (72 dp two-line item), `DesktopAccountChoose` (56 px bordered row in the Account pane); ED-230.
- **Copy:**
  - title: "Choose settings";
  - subtitle: "This device had different settings when you signed in.";
  - a chevron.
- **Shown when:** B1 was deferred **and** the device's settings still differ. The row disappears once a choice is made.
- **Action:** opens B1 again, which then behaves exactly as above.
- **Accessibility:**
  - one focusable row that is announced as a button with its title and subtitle;
  - the chevron is decorative;
  - the row grows with text at 200 %.

| Item | State |
|---|---|
| Row and copy (`accountChooseSettings`, `accountChooseSettingsBody`) | Built (`account_page.dart`) |
| Visibility: deferred and still different (`settingsChoiceLaterProvider`) | Built |
| Tap clears the deferral (`decideSettingsLater(owner, later: false)`) so the gate shows B1 again | Built in code. **Verify** that B1 really opens on all four platforms, and that the row hides afterwards |
| A widget test for the return path (tap → B1 → choice → row gone) | **Pending** (no test found) |
| Semantics announces it as a button, and it has a 44 pt / 48 dp target | **Verify** |

## Design-complete, implementation-pending (summary)

1. Concept E styling on every account screen (blocker 6).
2. A1 Android text-button dialog.
3. A1 Mac/web initial focus on Cancel.
4. Commit the A3 body and decorative art (local only today).
5. A3 Mac/web side-by-side buttons that wrap.
6. B1 Mac/web layout (cards side by side, actions right-aligned).
7. Fix the B1 code comment wording.
8. A widget test for the "Choose settings" return path.
9. Checks at 200 % text on four platforms for A1, A2, A3, B1 and the row.
10. The sync/auth items that only the build can close:
    - I7 share-extension race (blocker 1);
    - the misleading offline sign-out error (blocker 4);
    - "Sync now" feedback (blocker 5);
    - Firefox, Safari, physical devices and hosted staging.

Design work on these screens has stopped. A new decision is opened only when the build finds a specific discrepancy with a frame above.
