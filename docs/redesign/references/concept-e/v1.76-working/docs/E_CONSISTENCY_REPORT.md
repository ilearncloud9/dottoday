# Concept E — consistency review (v1.1)

**Status:** LEADING CANDIDATE — NOT APPROVED FOR PRODUCTION IMPLEMENTATION. Written 2026-11-04 for owner review. Findings only: no board was changed.

**What was reviewed:** the live E boards on canvas version `1793767935-3ecd`.

| Board | State in v1.1 | Checked how |
|---|---|---|
| `E-Phones` | Unchanged since v1.0 | SHA-256 matches `references/concept-e/v1.0/` |
| `E-PhonesMinimal` | Unchanged since v1.0 | SHA-256 matches v1.0 |
| `E-Workspace` | Unchanged since v1.0 | SHA-256 matches v1.0 |
| `E-Minimal` | **New.** Mac and web minimal: C's layout in E's look. The Day thread sits in the right column; a task opens there and closes back to the Day | Read in full; same bytes as `v1.1-working/E-Minimal.dc.html` |
| `E-Map` | Working map | Read; same bytes as `v1.1-working/E-Map.dc.html`. Its text is still v1.0 (CR-109) |
| `E-Map-v1.0` | Historical | SHA-256 matches v1.0 |
| `E-Focus` | **Removed from the canvas.** Archived at `references/concept-e/v1.0/E-Focus.dc.html` | Owner: "I have completed the redesign and replacement of Concept E's Mac and Web Minimal Layout." Focus as a product feature is not removed |

**Cross-checked against:** `E_DESIGN_RULES.md`, `E_DESIGN_DECISIONS.md` (ED-001 to ED-064), `E_SCREEN_INVENTORY.md`, `FEATURE_PARITY_MATRIX.md`, `PRODUCT_BRIEF.md`, `DESIGN_PRINCIPLES.md`, `PLATFORM_QUALITY_MATRIX.md`, `references/platform-guidelines/premium-native-experience.md`, `CLAUDE.md` §8 and §11, and `docs/14-minimal-mode.md`.

**How to read it.** Every finding has a stable ID (CR-001…) and exactly one status:
- **RESOLVED:** fixed or now consistent. The evidence names the board and frame.
- **STILL CONFLICTING:** two sources disagree. Both sides are named.
- **NOT DESIGNED:** no frame. An entry point or caption at most.
- **NOT VERIFIED:** drawn, but it needs a render, device or contrast check.
- **AWAITING OWNER DECISION:** a choice only the owner can make.

Frame shorthand: **EM** = E-Minimal (Mac frame, web frame, insets, band) · **EW** = E-Workspace · **EP** = E-Phones (F1–F6, insets I1–I6) · **EPM** = E-PhonesMinimal (F1–F6, end-of-day inset, band).

## Addendum: after the review (canvas `1793768854-76be`, 2026-11-04)

These changes landed after the review was written. The original findings below are left unchanged.

- **CR-109: now RESOLVED.** The working E-Map was republished as v1.1. It now has E-Minimal as the wide minimal layout, E-Focus as "v1.0 archive only", and new open decision #21 (wide Focus presentation).
- **CR-110: now RESOLVED.** `E_DESIGN_RULES.md` (§0 v1.1 changes, §9 four presentations) and `E_SCREEN_INVENTORY.md` were updated to v1.1.
- **CR-032: partly fixed, still awaiting an owner decision.**
  - **Fixed:** E-Minimal's band no longer says "Opens E-Focus". It now says Show everything opens E's standard wide layout, which is an owner decision.
  - **Still open:** what that layout is. This is decision G1-1 in `E_DECISION_REGISTER.md`.
- **Other copy fixes on E-Minimal (no change to the design):**
  - its header now says it replaces E-Focus;
  - its caption no longer calls the layout itself a hypothesis (ED-064).
- **Updated counts:** RESOLVED 15, STILL CONFLICTING 48, NOT DESIGNED 32, NOT VERIFIED 9, AWAITING OWNER DECISION 8, total 112.

## Addendum 2: Group 1 answers (2026-11-04, canvas `1793770633-85e7`)

The original rows are unchanged. These statuses replace theirs:

| ID | New status | Why |
|---|---|---|
| CR-034 | RESOLVED | Minimal phones keep Now · Today · Inbox by owner decision; doc 14 §3 superseded for the redesign branch (ED-068) |
| CR-036 | RESOLVED | Wide minimal's sidebar and Now entry are the owner's design (ED-066, ED-068) |
| CR-037 | STILL CONFLICTING (narrowed) | Different navigation is now intended (ED-068). What each mode's Day menu holds, and Search's home on phone minimal, stay open in G2-9 |
| CR-041 | RESOLVED (rule) · NOT DESIGNED (frames) | Rule set by ED-067: Day menu + Settings row 1 everywhere, plus native extras. E-Minimal's Day menu and the web Settings row still have to be drawn |
| CR-042 | NOT VERIFIED | Mini window and status item are kept for both modes but marked for a feasibility check (ED-066) |
| CR-043 | AWAITING OWNER DECISION | The wide *minimal* sidebar is settled (ED-068). The wide *Full* sidebar depends on G1-1 (ED-069) |
| CR-045 | STILL CONFLICTING (moved) | ⌘1–4 now belongs to G2-10 |
| CR-032 | AWAITING OWNER DECISION | Narrowed to A vs B, shown on `E-FullA` and `E-FullB` (ED-070) |

Counts after Group 1: RESOLVED 18, STILL CONFLICTING 46, NOT DESIGNED 31, NOT VERIFIED 10, AWAITING OWNER DECISION 7, total 112. CR-041 is counted as RESOLVED (its missing frames are tracked in G1-4's "what I'd draw next"); CR-043 moved from STILL CONFLICTING to AWAITING.

## Addendum 3: G1-1 resolved (2026-11-04, canvas `1793809787-c4b9`)

| ID | New status | Why |
|---|---|---|
| CR-032 | RESOLVED | Full on Mac and web = Workspace (ED-073); E-Minimal's Show everything now has a target. E-Minimal's band text still says "an owner decision" and is listed as a design fix |
| CR-043 | RESOLVED | Each mode has its own wide sidebar by owner decision: Minimal per ED-068, Full = E-Workspace's per ED-073 |
| CR-045, CR-051 to CR-057 | STILL CONFLICTING | `E-FullA-v2` proposes one Full key scheme; E-Minimal still has its own (⌘1–4, ⌘F, ⌥⌘D). G2-10 |
| CR-060 | STILL CONFLICTING (narrowed) | `E-FullA-v2`'s context menu uses Need More Time… and Move to Trash; E-Workspace and E-Minimal are unchanged |

Counts after Addendum 3: RESOLVED 20, STILL CONFLICTING 46, NOT DESIGNED 31, NOT VERIFIED 10, AWAITING OWNER DECISION 5, total 112.

## Summary

| Status | Findings |
|---|---|
| RESOLVED | 13 |
| STILL CONFLICTING | 48 |
| NOT DESIGNED | 32 |
| NOT VERIFIED | 9 |
| AWAITING OWNER DECISION | 10 |
| **Total** | **112** |

## Top 10 issues

1. **No full wide layout to switch to (CR-032).** EM's "Show everything" opens E-Focus, which is gone. EW is the only full wide board, it has no Now, and nothing replaces the three-day spread.
2. **The two wide shells still disagree (CR-043, CR-044, CR-051).** EM's sidebar is Now · Inbox · Calendar · Search with ⌘1–4 = Now/Day/Calendar/Inbox. EW's is Today · Plan · … with ⌘1–4 = Day/3 days/Week/Month.
3. **The task opens in three different ways (CR-070, CR-071).** Phones use a sheet, EW a docked inspector, and EM a screen that replaces the Day column. EM's task screen has no Done or Delete, which doc 14 §4 requires.
4. **"Everything else" and ⌘K mean three things (CR-040, CR-054).** Phone minimal: a Settings row. EM: an action, place and task finder. EW: a "Search or run" palette.
5. **Menus disagree (CR-058, CR-060).** There are three Day menus, and two context menus: Delete ⌫ in EM against Move to Trash ⌘⌫ in EW. The app has a 30-day Trash.
6. **Web routes are split (CR-066).** EM uses `/now?task=`, EW uses `/plan/day/2026-11-03?task=`, and today's app uses `/today` and `/day/:date`. `DESIGN_PRINCIPLES.md` §2 says routes are shared.
7. **EM departs from doc 14 (CR-020, CR-036, CR-039, CR-041, CR-071).** It keeps a sidebar and a Now entry, shows a "3 done" count, keeps a full Day menu, and does not put Show everything in the Day menu.
8. **Copy is still split (CR-062, CR-063, CR-064).** "Running late" is still on EW and the phone menus, even though EM renamed it. The increments are +15/+30 against +5/+15/+30. Low-energy has four names, now including "Gentle Day".
9. **New Mac shortcut clashes (CR-052, CR-055, CR-056).** ⌥⌘D is the system Dock shortcut. ⇧⌘→ is select-to-end-of-line in text. ⌘F is Focus in EM, but Find by Mac convention.
10. **Only 1280 × 800 light mode is drawn (CR-091, CR-093, CR-094, CR-103).** EM's Mac and web split 1280 differently. No narrow, tablet, mobile web, dark, 200 % text or reduced-motion layout exists.

---

## 1. Visual identity and typography

| ID | Finding | Evidence | Status |
|---|---|---|---|
| CR-001 | The thread-of-dots identity reaches wide minimal. EM draws the thread, task dots, knot, now-bead, Wind Down cap and horizon. C's ribbon, apricot notch and orb were translated into E's forms | EM header legend; Mac and web frames; ED-063 | RESOLVED (by EM) |
| CR-002 | Type families follow the rules on EM. Content is Manrope. Mac chrome is `-apple-system`. The web sidebar uses `system-ui`, with the brand name in Manrope 700 16 | EM Mac toolbar ("Everything else ⌘K", 500 13 -apple-system); EM web sidebar; rules §3.1 | RESOLVED (EM matches E-Workspace) |
| CR-003 | Orb numeral differs on every board. Phones: 800, 84 px (Android 80). EM: 700, 76 px on Mac and 64 px on web. E-Focus v1.0 was 700, 56/60 | EPM F1, F5; EM Mac and web Now | STILL CONFLICTING (EPM vs EM) |
| CR-004 | Add input text is 500 19 on full iPhone, 600 20 on minimal iPhone and 600 19 on Android | EP F2; EPM F3, F6 | RESOLVED 2026-11-09 (ED-204): Manrope 600 20 on iPhone and Android Minimal |
| CR-005 | The Android Edit sheet sets the task title in Roboto. Task titles are content, so they should be Manrope | EP F6 vs rules §3.1 | RESOLVED 2026-11-09 (ED-204): Android task titles Manrope 700 24/30 |
| CR-006 | Board headers are stale. EP says "dots with depth", but the dots are flat. EW still says "A · …" and calls A's thread-only board "the candidate minimal look". EM says it "sits beside E-Focus … and replaces neither" and tags ED-005 as open | EP header; EW header; EM header and Hypothesis caption | STILL CONFLICTING (board copy vs the v1.1 canvas) |
| CR-007 | Scale direction ("keep large", "C confidence", or both) is unanswered. EM uses the large scale | `E_DESIGN_DECISIONS.md` pending table (9acf09f2) | AWAITING OWNER DECISION |

## 2. Colours, semantic tokens and iconography

| ID | Finding | Evidence | Status |
|---|---|---|---|
| CR-008 | EM adds no new colour. Every hex value on it already appears on the other E boards. There is no apricot, and the caps keep their colours (`#E6E3F7` / `#4B3FB0`) | Colour diff of EM against EP, EPM, EW and E-Focus v1.0 | RESOLVED |
| CR-009 | The calendar dot centre is `#FBF7F1` on phones, `#FFFFFF` on EM and `#FFFDF9` on EW. EM draws its ring at 2 px; the rules say 2.5 px | EP F1; EM Day column "Dentist"; EW Mon–Thu | RESOLVED 2026-11-09 (ED-200): centre = surface behind; ring 2.5 px standard, 2 px ≤ 16 px; light and dark |
| CR-010 | The primary Add is ink `#241F2B` in EM's web Now pane but teal in EM's Mac toolbar and everywhere else | EM web "Add n"; EM Mac toolbar +; EP, EW | STILL CONFLICTING (within EM, and EM web vs all others) |
| CR-011 | Android AM/PM selected uses the board's Hypothesis-tag amber (`#FBEBD0` / `#6E4300`). This is a board colour leaking into product UI | EP F6 time picker | CLOSED 2026-11-07: the AM/PM control is no longer drawn; a new amber leak (iPad "Alarms off" tag) is item 8c in E_CLEANUP_BATCH |
| CR-012 | The repeat marker has three forms: an icon (phones), "· repeats" (E-Focus v1.0) and "↻" (EW). EM shows repeats only in aria labels | EP F1; EW Mon/Wed/Thu standup; EM horizon aria "repeats" | RESOLVED 2026-11-09 (ED-208): the repeat icon on all active boards; E-G4-7 review boards still draw ↻ |
| CR-013 | Four task colours (coral, amber, sky, green) are below 3:1 as an outline ring on `#FBF7F1`. White on amber is 2.29:1. EM's horizon draws ahead dots with 2.5 px rings, which makes the weak rings weaker | Rules §4.3; EM horizon dots | RESOLVED 2026-11-07 (ED-155) |
| CR-014 | Chrome icons are SVG approximations of SF Symbols and Material Symbols. The native paths are not checked | EP Platform notes; EM Platform note | NOT VERIFIED |

## 3. Task dots, thread, progress rings and now-bead

| ID | Finding | Evidence | Status |
|---|---|---|---|
| CR-015 | The now-bead is 16 px in phone frames, 14 px on EM and EW, and 12 px in legends | EP F1; EM Day column "Now, 10:42" (14 px); EP legend | STILL CONFLICTING |
| CR-016 | The now-ring track is mixed, even inside one board. EM uses `#E4E3F7` for Deep work but `rgba(task,.2)` for Call with Sam. Phones use `rgba(task,.2)`. EW uses `#E4E3F7` in the inspector and rgba in the grid. The cut-out is 3, 4, 4.5 or 5 px | EM horizon and Day column; EP F1; EW grid and inspector | RESOLVED 2026-11-08 (ED-198): light now-ring = task colour at 20 % track, ring-token arc; cut-outs 5 / 4.5 verified |
| CR-017 | The ahead-ring width differs: 4 px inset on phones, 3.5 px on EW, and 2.5, 3 and 3.5 px inside EM | EP F1; EW Wed; EM horizon, Day column and context-menu Gym dot | RESOLVED 2026-11-08 (ED-199): 4 px phone, 3.5 px wide, 2.5 px for dots ≤ 16 px, light and dark |
| CR-018 | The Wake Up cap is 32 px on Today and 34 px on the empty day and in minimal. EM draws a 32 px Wind Down cap | EP F1 vs F4; EPM F2; EM Day column | RESOLVED 2026-11-09 (ED-201): thread caps 34 px, icon 19, phones and wide, light and dark |
| CR-019 | Dots are flat on every v1.1 board. There is no halo, glow or glossy dot. The orb keeps the ED-020 shadow, as it did in v1.0 | EM, EPM and EW raw styles; ED-023 | RESOLVED |
| CR-020 | The "Earlier · 3 done" fold shows a done count. Doc 14 §2 rule 5 and §4 say minimal has no done count | EPM F2; EM Mac and web Day column | RESOLVED 2026-11-07 (ED-164): label is "Earlier", no count |
| CR-021 | The horizon is labelled 7 AM to 11 PM, but it draws Morning run at 6:45. The before-Wake-Up fold is not drawn anywhere | EM horizon aria; EP F1 | NOT DESIGNED |
| CR-022 | Now-bead motion, the live tick and its polite announcement are not drawn | Rules §7.5 | NOT DESIGNED |

## 4. Spacing, component sizes and surfaces

| ID | Finding | Evidence | Status |
|---|---|---|---|
| CR-023 | Wide pane widths differ. Sidebar: 200 (EM Mac), 210 (EM web), 216 (EW). Task pane: 290 (EM column) against 248 (EW inspector) | EM Mac and web `Sidebar`; EM task inset; EW inspector | RESOLVED 2026-11-09: sidebar Full 216 (ED-168), Minimal 200 on Mac and web (ED-207); task pane 290 vs 248 are different components (ED-197) |
| CR-024 | The Mac sidebar has no blur on EM but `blur(30px)` on EW | EM Mac sidebar; EW Mac sidebar | RESOLVED 2026-11-07 (ED-165): E-Minimal Mac sidebar drawn with the ED-130 material |
| CR-025 | The Mac context-menu radius is 8 on EM and 10 on EW | EM Gym menu; EW Lunch menu | STILL CONFLICTING |
| CR-026 | There are two web focus rings. EM: a 3 px teal outline at 45 % with a 2 px offset. EW: a 2 px gap plus 2 px solid teal | EM web "Need more time?" popover; EW web Deep work block | STILL CONFLICTING |
| CR-027 | Android and iOS sizes still differ. Android FAB radius is 22 (extended) or 16 (minimal). The Now card is r24/72 on iOS and r22/74 on Android. The Android Day menu surface is `#F7EFF4` | EP F5, I6; EPM F1, F5 | STILL CONFLICTING |
| CR-028 | Solid surfaces are kept where required. The web popover and finder are solid, EM's Mac task screen is solid, and there is no glass on web | EM web popover; EM finder; EM task inset | RESOLVED |

## 5. Standard, Minimal, Focus and Workspace

| ID | Finding | Evidence | Status |
|---|---|---|---|
| CR-029 | A wide Minimal layout exists again, and the owner says the replacement is complete | EM board; ED-064 | RESOLVED (by EM) |
| CR-030 | The v1.0 problem "E-Focus is titled minimal but drawn full" is gone | E-Focus removed; ED-064 | RESOLVED (by removing E-Focus) |
| CR-031 | Now now has one rule. It is the minimal entry on phones and on wide windows, and full mode has no Now on either | EPM F1, F5; EM Mac and web; EP and EW have no Now | RESOLVED (by EM plus the removal of E-Focus) |
| CR-032 | What "full" means on Mac and web is open. EM's band says "Show everything … Opens E-Focus", and that board is gone. EW is the only full wide board. It has no Now pane, no thread-only view and no three-day spread. ED-064 also leaves open whether a full Focus-style layout (Now + Day + inspector) comes back | EM band row 1; EW; ED-064 | AWAITING OWNER DECISION |
| CR-033 | E as a whole, and each "Hypothesis · not approved" structure, still need approval: Settings out of the tab bar, one task surface, Add modes, the Day menu, Calendar as a destination, the Settings regrouping, the Workspace structure, and EM's behaviours (Day in the right column, task screen there, Now as the entry, ⌘1–4, ⌘K, `/now`) | ED-043 to ED-051; ED-063; ED-064 | AWAITING OWNER DECISION |
| CR-034 | Minimal phones keep a three-tab bar (Now · Today · Inbox). Doc 14 says no tab bar and an Inbox "Later" row | EPM F1, F5; doc 14 §3 "Navigation bar / rail" | AWAITING OWNER DECISION |
| CR-035 | Minimal folds done tasks into "Earlier" on phones and on EM. Doc 14 keeps them in place, struck through | EPM F2; EM Day column; doc 14 §4 | RESOLVED 2026-11-07 (ED-164): fold approved; doc 14 §4 amended with a superseded note |
| CR-036 | Wide minimal departs from doc 14 §3. Doc 14 says "Today alone … no sidebar". EM keeps a four-row sidebar, opens on Now, and keeps Inbox and Search as rows. The board itself flags this | EM Mac and web captions "Differs from §3"; doc 14 §3 | AWAITING OWNER DECISION |
| CR-037 | Phone minimal and wide minimal hide different things. Phone: no Search (it is under Settings › Everything else), and the Day menu holds only Show everything and Low-energy day. Wide: Search is a sidebar row, and the Day menu holds Brain Dump, Drop a Routine, Duplicate Day, Copy Day as Text and Review | EPM band and F2 pull-down; EM sidebar; EM menu-bar inset | STILL CONFLICTING (EPM vs EM) |
| CR-038 | Minimal is shown the same way on every platform: no counts in the summary, the large now-dot, the horizon, and "Also now / Next" | EPM F1; EM Mac toolbar "Now 10:42 · Wind Down at 11:00 PM"; EM web | RESOLVED |
| CR-039 | The Day menu in wide minimal carries Duplicate Day, Copy Day as Text and Drop a Routine. Doc 14 §3 says these are "Not in minimal's three-item header menu; full ⋯ only" | EM menu-bar inset; doc 14 §3 | STILL CONFLICTING (EM vs doc 14) |
| CR-040 | "Everything else" means three things. Phone minimal: a Settings row that opens the full Settings tree (doc 14 §4). EM: a finder for actions, places and tasks. D1 and D3: open the regrouped Settings root | EPM band; EM finder inset; doc 14 §4; D1/D3 | STILL CONFLICTING |
| CR-041 | Show everything is not always in the same place. Doc 14 §2 rule 6 puts it in the Today header menu and Settings row 1. Phones use the Day menu. EM uses View › Show Everything (Mac) and the finder (web), and it is not in EM's Day menu | EPM F2; EM band; EM menu-bar inset; doc 14 §2, §5 | STILL CONFLICTING (EM vs doc 14 and EPM) |
| CR-042 | The full-mode Now mini window and status item appear only on EM (minimal). Whether full mode keeps the mini window is not drawn. EW mentions only the status item | EM Mac inset; EW menu-bar caption | NOT DESIGNED |

## 6. Navigation and Settings access

| ID | Finding | Evidence | Status |
|---|---|---|---|
| CR-043 | The two wide sidebars share almost nothing. EM Mac has Now · Inbox · Calendar · Search; EM web adds Everything else and Settings. EW has Today · Plan · Inbox · Routines · Brain dump · Calendar views · Review · Search · Lists. Switching modes changes the whole sidebar | EM Mac and web sidebars; EW Mac and web sidebars | STILL CONFLICTING (EM vs EW) |
| CR-044 | Today and Day mean different things. Phones: a "Today" tab. EM: "Day" is the thread column and ⌘2. EW: "Today" is a sidebar row, and "Day ⌘1" is a canvas range | EP F1; EM View menu; EW sidebar | STILL CONFLICTING |
| CR-045 | EM's sidebar order (Now, Inbox, Calendar, Search) does not match its ⌘ order (Now ⌘1, Day ⌘2, Calendar ⌘3, Inbox ⌘4). Day has a shortcut but no row | EM Mac sidebar vs EM View menu | STILL CONFLICTING (within EM) |
| CR-046 | The wide destination is "Reviews" on EM but "Review" on EW | EM View menu and finder; EW sidebar | STILL CONFLICTING |
| CR-047 | Settings has one entry per platform on every v1.1 board: the avatar on phones, Dottoday › Settings… ⌘, in its own window on Mac, and a sidebar row on web | EP F1; EPM F1; EM Mac caption and web sidebar; EW captions | RESOLVED (consistent; still the D1 hypothesis, CR-033) |
| CR-048 | The Settings screens are not drawn: the root, its groups, the Mac Settings window, and minimal Settings (nine rows, with Layout first) | Inventory §1.4; doc 14 §4 | NOT DESIGNED |
| CR-049 | "Lists" on the EW Mac sidebar is outside parity | EW Mac sidebar | AWAITING OWNER DECISION |
| CR-050 | The phone minimal band says "Week view in full mode", but full phones have no Week | EPM band; EP | STILL CONFLICTING |

## 7. Shortcuts and menus

| ID | Finding | Evidence | Status |
|---|---|---|---|
| CR-051 | ⌘1–4 is Now / Day / Calendar / Inbox on EM, but Day / 3 days / Week / Month on EW | EM View menu; EW menu-bar caption and sidebar | STILL CONFLICTING (EM vs EW) |
| CR-052 | On EM, ⌘F is Focus (context menu). Mac convention, and E-Map-v1.0, use ⌘F for Find. EM gives Search no Mac shortcut | EM Gym context menu; premium-native guide §macOS ("⌘F"); E-Map-v1.0 | STILL CONFLICTING |
| CR-053 | ⌘C: EM fixed the clash (Copy Day as Text ⇧⌘C, and Copy as Text has no key). EW's context menu still uses "Copy as Text ⌘C", which clashes with Copy | EM menu-bar caption and context menu; EW Lunch menu | STILL CONFLICTING (EW vs EM and macOS) |
| CR-054 | ⌘K on EM opens "Everything else" (actions, places, tasks). On EW it opens "Search or run", and the EW Mac sidebar labels Search ⌘K. On web, EM uses the single key `k` and EW uses Ctrl K, which Chrome and Firefox already use on Windows and Linux | EM toolbar and finder inset; EW palette inset and sidebars | STILL CONFLICTING |
| CR-055 | EM's ⌥⌘D (show or hide the Day column) is macOS's system shortcut for showing or hiding the Dock | EM toolbar, View menu and Day column header | STILL CONFLICTING (EM vs macOS) |
| CR-056 | EM's Shift the Rest ⇧⌘→ is the text shortcut for "select to end of line". It would take that key from any text field in the window | EM menu-bar caption | STILL CONFLICTING (EM vs macOS text editing) |
| CR-057 | Brain dump ⇧⌘N is in the Day menu on EM but under File › New Brain Dump on EW | EM menu-bar caption; EW menu-bar caption | STILL CONFLICTING |
| CR-058 | There are three Day menus. Phones: Replan · Plan · Reflect · View · Share, with Running late, Pick today's one thing, This week, Low-energy mode, Show less and Plan / Reality. EW: Running Late ▸, Shift the Rest…, Rebalance…, Low-Energy Mode, Pick One Thing…, Duplicate, Copy, Review. EM: Need More Time…, Shift ⇧⌘→, Brain Dump…, Drop a Routine, Duplicate, Copy ⇧⌘C, Review, Gentle Day | EP I3, I6; EW menu-bar inset; EM menu-bar caption | STILL CONFLICTING |
| CR-059 | The web Day menu popover's contents are not drawn on either web board. EM web has a "Day menu" button; EW web has none | EM web Day column; EW web | NOT DESIGNED |
| CR-060 | The context menus differ. EM: Mark Done ⌘↩, Focus ⌘F, Delete ⌫, no Running late. EW: Mark Done with no key, Running Late ▸, Move to Trash ⌘⌫. The app keeps deleted tasks in Trash for 30 days, and EM's own finder lists "Backups and Trash" | EM Gym menu; EW Lunch menu; EM finder; parity §4 | STILL CONFLICTING (EM vs EW) |
| CR-061 | Web single keys differ. EM: n / t [ ] k ?. EW: n / t [ ] ↑↓ Alt↑↓ m Enter | EM web sidebar hint; EW web hint bar | STILL CONFLICTING |
| CR-062 | "Running late": EM renamed it "Need More Time…". EW (Day menu, context menu, palette "Running late +15") and both phone Day menus still say "Running late". `CLAUDE.md` §11 bans "late" in user-facing copy | EM menu bar; EW insets; EP I3, I6 | STILL CONFLICTING |
| CR-063 | The increments are +15/+30 on phones and EM, but +5/+15/+30 on EW and in the parity matrix | EP F3; EM web popover; EW Running Late ▸; parity §1 | RESOLVED 2026-11-07 (ED-163): +5 / +15 / +30 everywhere |
| CR-064 | Low-energy has four names: "Low-energy mode" (EP), "Low-energy day" (EPM), "Low-Energy Mode" (EW) and "Gentle Day" / "Gentle day" (EM). Doc 14 and parity say "Low-energy mode" | EP I3; EPM F2; EW Day menu; EM menu bar and finder | STILL CONFLICTING |
| CR-065 | "Brain dump" against "Clear your head" is settled on the boards. EM uses "Brain Dump…", and the only "Clear your head" was on E-Focus. The working E-Map still lists "Clear your head" (CR-109) | EM menu bar and finder; E-Focus archived | RESOLVED (by removing E-Focus) |

## 8. Web routes

| ID | Finding | Evidence | Status |
|---|---|---|---|
| CR-066 | Web routes disagree. EM: `/now?task=…`. EW: `/plan/day/2026-11-03?task=deep-work`. Today's app: `/today`, `/day/:date`, `/task/:id`. `DESIGN_PRINCIPLES.md` §2 says routes are shared ("`/day/:date` names the same day everywhere") | EM web address bar and caption; EW web address bar; parity §1–2 | STILL CONFLICTING |
| CR-067 | EM gives no URL for the Day thread, Calendar, Inbox, Search or the finder, or for the Day column hidden or shown | EM web frame and caption | NOT DESIGNED |
| CR-068 | Path URLs need a static-host rewrite, and refresh and Back restoring `?task=` is claimed but not tested | EM and EW web captions | NOT VERIFIED |

## 9. Task creation, viewing and editing

| ID | Finding | Evidence | Status |
|---|---|---|---|
| CR-069 | Quick Add on wide is entry-only: Mac toolbar + (⌘N), EM "Add a task ⌘N", web Add `n`. No Add popover or sheet is drawn on Mac or web | EM Mac and web; EW capture field | NOT DESIGNED |
| CR-070 | The task surface takes three forms. Phones: a sheet (medium detent; pull up = editor). EW: a docked inspector beside the grid (⌥⌘I, 248 wide, every field). EM: a task screen that replaces the Day column (290 wide, ✕ or Esc goes back). D2 recommends one surface | EP F3, F6; EW inspector; EM task inset | STILL CONFLICTING (EM vs EW vs phones) |
| CR-071 | EM's task screen has Starts, Duration, Tomorrow, Later, Move… and More details. Doc 14 §4 says minimal's task sheet is Done · Tomorrow · Later · Delete, with Move under More | EM task inset; doc 14 §3–§4 | STILL CONFLICTING (EM vs doc 14) |
| CR-072 | EM's "More details" (alerts, repeat, subtasks, colour, icon, notes, Shift the rest, Break it down) has no drawn destination | EM task inset | NOT DESIGNED |
| CR-073 | The EM web task screen is not drawn. The caption says it opens in the 510-wide Day column "as on Mac", where the column is 290 | EM web caption | NOT DESIGNED |
| CR-074 | The phone task editor is not drawn: the iOS large detent, the Android full-screen editor, the iOS Move picker and the repeat-scope prompt | Inventory §1.2 | NOT DESIGNED |
| CR-075 | The generic proposal sheet is not drawn. Only the paste proposal ("Add 4 tasks") exists. EM's band promises "nothing is written before Accept" | EP I2; EM band "Brain dump" | NOT DESIGNED |

## 10. Feature locations and entry points

| ID | Finding | Evidence | Status |
|---|---|---|---|
| CR-076 | Focus, the product feature, has entry points: the Focus button and big-dot click on EM, ⌘F, the EW inspector, and the phone sheet. The Focus screen (`/focus/:id`) is not drawn on any platform | EM Now; EW inspector; EP F3 | NOT DESIGNED |
| CR-077 | The Reality thread has no wide home. It is not on EW or EM; it exists only as a phone Day-menu item | EP I3, I6; EW; EM | NOT DESIGNED |
| CR-078 | Multi-select, the selection bar and Save as routine are not drawn on any board. EM and EW show no ⇧/⌘-click | EP F1 tip only | NOT DESIGNED |
| CR-079 | The Undo toast or snackbar, and ⌘Z feedback, are not drawn | All boards | NOT DESIGNED |
| CR-080 | The Inbox, Calendar and Search screens are not drawn. Phones have tabs, and EM has sidebar rows that open nothing drawn | EP F1; EPM F1; EM sidebar | NOT DESIGNED |
| CR-081 | Rebalance is only an EW menu item. The shift-followers drag chip and pin are not drawn | EW Day menu | NOT DESIGNED |
| CR-082 | Go to a date has entries only: ⇧⌘G, EM's date button and "Go to date…" in the finder. No Mac or web date popover, and no Android M3 date picker, is drawn | EM toolbar and finder; EP I4 | NOT DESIGNED |
| CR-083 | Spoken Brain dump exists only as EW's Dictate mic. Phones and EM have no mic | EW Brain dump block | NOT DESIGNED |
| CR-084 | This week, Past days and the year strip are entries only (EM "Reviews" and "Past days" in the finder; EW "Review") | EM finder; EW sidebar | NOT DESIGNED |
| CR-085 | Low-energy mode's screen and header switch are not drawn. Only menu items exist | EP I3; EM menu bar | NOT DESIGNED |
| CR-086 | The Wake Up family (alarm, card, Check, missions, day shape, sleep target) and notifications (task alert, Start nudge, health, test alarm) are not drawn | Inventory §1.3 | NOT DESIGNED |
| CR-087 | Account, sync banner and sheet, recovery, app lock, export, backups, import and Trash are entries only. EM adds finder rows "Export…" and "Backups and Trash" | EM finder; EW File › Export | NOT DESIGNED |
| CR-088 | System surfaces are not drawn: widgets, Live Activity, ongoing notification, Controls, Quick Settings tiles, App Intents, Share into Inbox, PWA install, web push and the tab live dot | Inventory §1.5 | NOT DESIGNED |
| CR-089 | Onboarding, including step 0 (Show less or Show everything), is not drawn | Inventory §1.4 | NOT DESIGNED |
| CR-090 | The Duplicate-day target picker and the Copy-day confirmation are not drawn | All boards | NOT DESIGNED |

## 11. Responsive layouts and window resizing

| ID | Finding | Evidence | Status |
|---|---|---|---|
| CR-091 | Every wide frame is 1280 × 800. The Mac minimum window (960 × 640) falls in the proposed medium class, and EM has no rule for it: Now 790 + column 290 does not fit | EM; EW; E-Map responsive section | NOT DESIGNED |
| CR-092 | The EM state with the Day column hidden (⌥⌘D) is described but not drawn. EW's Week shows only four days at 1280 | EM "How the right column works"; EW Week | NOT DESIGNED |
| CR-093 | EM splits 1280 differently on Mac (Now 790 + Day 290) and on web (Now 560 + Day 510), while its caption says "Same layout as Mac at the same width". `DESIGN_PRINCIPLES.md` §3 says width decides composition | EM Mac and web frames and web caption | STILL CONFLICTING (EM Mac vs EM web) |
| CR-094 | iPad, Android tablet and foldable, mobile web and phone landscape are not drawn. Hardware keyboard and pointer on iPad and Android are not drawn | All boards | NOT DESIGNED |
| CR-095 | The breakpoints (720 / 1160) and the Mac minimum window (keep 960 and design medium, or raise it to 1160) need a choice | E-Map responsive section | RESOLVED 2026-11-07: breakpoints (ED-167), Mac minimum 840 × 640 (ED-169) |

## 12. Native interactions per platform

| ID | Finding | Evidence | Status |
|---|---|---|---|
| CR-096 | Liquid Glass (iOS), translucent tonal bars (Android) and Mac vibrancy are drawn as approximations. Native platform views against Flutter blur is an open engineering choice | EP, EPM Platform notes; EM Mac sidebar | NOT VERIFIED |
| CR-097 | The Mac Now mini window (a new window type) and the status item need a feasibility check | EM Mac inset "Platform note" | NOT VERIFIED |
| CR-098 | Mac right-click menus need a native path (PlatformMenu); EM and EW only draw them | EM and EW Platform notes | NOT VERIFIED |
| CR-099 | iPhone keyboard choices are open: the custom teal "Add" return key, restoring the earlier keyboard look (ED-032), and a teal or system-green switch (ED-041) | EP F2; decision log pending table | PARTLY RESOLVED 2026-11-05: switch teal (G3-4, ED-112; design verification PASS, ED-117; Flutter not yet implemented); keyboard RESOLVED 2026-11-06 (G3-7 C, ED-135): stock keyboard, neutral return adds |

## 13. Dark mode and accessibility

| ID | Finding | Evidence | Status |
|---|---|---|---|
| CR-100 | Phone targets below the minimum: iOS tip dismiss 40, iOS in-field Add 40, iOS full-mode chips 34, +15/+30 at 36; Android tip dismiss 44 and Day button 40 | EP F1, F2, F3, F5; rules §6.4 | PARTLY RESOLVED (ED-163, ED-165): hit areas fixed; iOS toolbar glass buttons are native (implementation check) |
| CR-101 | The iOS inactive tab label is `#8E8E93` (3.06:1) in full mode and `#6E6E73` in minimal. Accessibility outranks native look (`DESIGN_PRINCIPLES.md` §3) | EP F1 vs EPM F1 | STILL CONFLICTING |
| CR-102 | Wide pointer targets on EM are 28 px (Mac done checks), 32 (close, web checks) and 34 × 30 (toolbar Add). They meet WCAG 2.2's 24 px. A touchscreen laptop or iPad would need 44 | EM Day column and toolbar | NOT VERIFIED |
| CR-103 | Dark mode, 200 % text, reduced motion and reduced transparency are not drawn on any board, EM included | All boards | NOT DESIGNED |
| CR-104 | EM's screen-reader labels look complete: a horizon summary, one label per dot, "Earlier, 3 done. Show.", and "Close the task and show the Day (Esc)". They have not been run with VoiceOver, TalkBack or NVDA | EM aria labels | NOT VERIFIED |
| CR-105 | Focus handling is not specified. Where keyboard and screen-reader focus go when a task replaces the Day column, and where they return on Esc, is not drawn. How the keyboard moves across horizon dots is also not drawn | EM task inset; EM horizon | NOT DESIGNED |
| CR-106 | Contrast on translucent chrome is unmeasured: iOS glass, the Android blur, and EM's Mac sidebar at `rgba(239,231,219,.78)` over the desktop | EP, EPM, EM | NOT VERIFIED |
| CR-107 | The Mac Week grid has no drawn non-grid alternative for screen readers | EW Mac Week | NOT DESIGNED |

## 14. Previously rejected styles and interactions

| ID | Finding | Evidence | Status |
|---|---|---|---|
| CR-108 | Nothing rejected came back on EM. No apricot (ED-016). No lavender Wind Down or apricot Wake Up (ED-018). No halos, glows or glossy dots (ED-023). No floating inset sidebar: it is flat and full height (ED-014). No solid chips (ED-010). No floating glass sheets (ED-036). No Inbox tray (ED-037). No glass on web. C's ribbon and notch were translated, not copied | EM raw styles and colour diff; EM Mac and web sidebars | RESOLVED |

## 15. Feature coverage against `FEATURE_PARITY_MATRIX.md`

Where each parity group stands in v1.1. "Home" means an entry point is drawn; a screen may still be missing.

| Parity group | Phones (EP, EPM) | Wide full (EW) | Wide minimal (EM) | Findings |
|---|---|---|---|---|
| Today timeline, paging, now-bead | drawn | Day / Week grid | Day column + horizon | CR-015 to CR-018 |
| Go to date, week strip, month | strip, iOS month sheet | caption ⇧⌘G | date button, ⇧⌘G, finder | CR-082 |
| Week / Month / 3 days | not on phones | ⌘1–4 canvases | View menu, finder | CR-051 |
| Drag, multi-select, selection bar | drag, tip only | Inbox → grid drag | "drag to move" hover only | CR-078 |
| Shift the rest, Running late, Rebalance | sheet +15/+30 | menu, inspector, +5/15/30 | Need more time? +15/+30 | CR-062, CR-063, CR-081 |
| Done + Undo | ring dot, swipe | inspector Done | big dot Done, row checks | CR-079 |
| Reality thread, before-Wake-Up fold | menu item only | none | none | CR-077, CR-021 |
| Duplicate day, Copy day as text | Day menu | Day menu | Day menu, finder | CR-090, CR-039 |
| Minimal switch | Day menu | none drawn | View menu, finder | CR-041 |
| Quick Add, paste a list | drawn (iPhone) | capture field | entry only | CR-069 |
| Brain dump typed / spoken | Add mode / none | block + Dictate | Day menu, finder / none | CR-083, CR-075 |
| Break it down, Smallest step, Unstick, AI status | none | none | "More details" text | CR-072 |
| Routines | Add mode, empty day | sidebar, column | View menu, finder | CR-037 |
| Focus | sheet tile | inspector, menu | big dot, Focus, ⌘F | CR-076 |
| Pick today's one thing | Day menu | Day menu | none (doc 14: full only) | CR-058 |
| Low-energy mode | Day menu | Day menu | "Gentle Day" | CR-064, CR-085 |
| Task editor fields | not drawn | inspector | "More details" | CR-070 to CR-074 |
| Inbox + scheduling | tab badge | column + drag | sidebar row | CR-080 |
| Wake Up family, notifications | caps only | caps only | Wind Down cap | CR-086 |
| Day review, This week, Past days | end-of-day card (minimal) | Review | Reviews, Past days | CR-084, CR-046 |
| Settings, account, sync, data, Trash | avatar, sync capsule | ⌘,, footer "Synced" | ⌘,, "Synced", finder rows | CR-047, CR-048, CR-087 |
| Calendars | read-only event dot | event block | event dot | CR-009 |
| System surfaces | none | menu bar, status item | menu bar, status item, mini window | CR-088, CR-097 |
| Keyboard shortcuts, deep links | none drawn | drawn | drawn | CR-051 to CR-061, CR-066 |

**`CLAUDE.md` §8 check.** Drag, Shift the rest, quick add and paste are drawn. Long-press multi-select, the selection bar and the sync-conflict UI are still not drawn (CR-078, CR-087). The no-shame rule still fails on "Running late" (CR-062) and on minimal's "3 done" count (CR-020).

## 16. Agreement between boards and docs

| ID | Finding | Evidence | Status |
|---|---|---|---|
| CR-109 | The live working E-Map is still v1.0 text. It says "v1.0", lists E-Focus as a board, says there is no wide minimal board, and lists "Clear your head" as adopted. Another agent is updating it, so re-check it when that work lands | E-Map on canvas `1793767935-3ecd` (same bytes as `v1.1-working/E-Map.dc.html`) | STILL CONFLICTING (E-Map vs canvas) |
| CR-110 | When read, `E_DESIGN_RULES.md` (§1, §9) and `E_SCREEN_INVENTORY.md` still described v1.0: E-Focus frames and the "Focus" presentation, with no E-Minimal. Both are being edited in parallel | Files as read on 2026-11-04 | NOT VERIFIED (re-check after the parallel edits) |
| CR-111 | The decision log matches the canvas. ED-062 records E-Focus's removal, ED-063 records E-Minimal, and ED-064 settles it as the wide minimal direction | `E_DESIGN_DECISIONS.md` §9 | RESOLVED |
| CR-112 | `THREE_UX_CONCEPTS.md` §3.1 gives A as Inter and cobalt. E uses Manrope and the warm palette. The final content family is set at Step 9 | Rules §3.1 | RESOLVED 2026-11-05 (ED-110): Manrope |
| CR-113 | Approved phone bottom rows vs active boards: 19 frames updated (12 iPhone, 7 Android); the 8 frames that appear on `E-G3-6-BottomRow` and `E-G3-6-Android` (C) are byte-identical after the merge; 34 frames exempt with a reason (inventory §4) | EP, EPM; coverage matrix | RESOLVED 2026-11-06 (ED-126) |
| CR-114 | On the approval board, Minimal "Rest of today" moved Day ▾ right but left its open pull-down at the old left anchor; three EPM frames had the same menu. Fixed on EPM (menu right 21, bottom 156); the approval board is kept as history | `E-G3-6-BottomRow` Minimal pair; EPM F2 and two task-sheet frames | RESOLVED 2026-11-06 (ED-126) |
| CR-115 | Rules §2, §6.2, §7.1, §7.2, §8.1, §8.2, §8.4, §10 and §11 described the superseded rows (52 pt solid +, 62 pt bar 16/26, edge-to-edge NavigationBar, extended "Add") | `E_DESIGN_RULES.md` | RESOLVED 2026-11-06: updated, old values kept as "superseded"; new §9.15 |
| CR-116 | The drawn + and bar are 63 pt; on the owner's iPhone iOS sets the glass capsule to 62 pt and N3's native + matches it. Rule: the + matches the bar's height as iOS draws it | `E-G3-6-BottomRow` spec table vs N3 captures (ED-122) | NOTED (not a conflict) |
| CR-117 | The Android + is labelled "Add" in Full and "Add a task" in Minimal (carried over from the extended FAB and the Minimal FAB); iPhone uses "Add a task …" in both. Drawn as approved; the implementation should use one label per platform (recommended "Add a task", with the FAB menu announced) | EP Android F5, EPM F5 | OPEN · copy, for implementation (no board change) |
| CR-118 | A native Day UIMenu opened upward lists its groups in reverse (Day first, Time last), against the G2-9 order | F2 spike capture (ED-129) vs rules §9.10 | OPEN · implementation rule recorded (fixed order); verify on device |
| CR-119 | Rules §7.3 and boards draw the Mac sidebar as a flat approximation; the selected direction (D6, conditional) is native vibrancy with a warm tint | rules §7.3; `E-G3-6-Remaining` | RESOLVED as a direction 2026-11-06 (ED-130): native vibrancy + 35 % warm tint approved; boards keep the flat approximation as the drawn reference; accessibility checks PENDING |
| CR-120 | ED-124 draws Minimal's bar 21 / 291 with a 6 pt gap; on iOS 26.5 the genuine three-tab capsule is capped at 274 pt (30 left, 15 gap as run) | `E-G3-6-Compat` Minimal 26.5 vs E-PhonesMinimal | RESOLVED 2026-11-06 (ED-132): option (a); EPM Minimal frames redrawn at the native width with the 6 pt gap |
| CR-121 | CR-118 (menu order) addressed: fixed element order shown on both versions; the + menu on 26.5 retest pending | `E-G3-6-Compat` §2–3 | PARTLY RESOLVED (ED-131) |
| CR-122 | The iPhone editor's "typing a step" frame draws the keyboard without its return row; the Android Add frame draws Gboard's check key teal, which Gboard decides | EP editor frame; EPM Android Add | RESOLVED 2026-11-06 (ED-136): step keyboard completed (iOS 26 drawing); Android note corrected (Gboard sets the colour) |
| CR-123 | Keyboard-dismissed states with the same draft were missing; added for Add (Full, Minimal) and steps | E-Phones, E-PhonesMinimal new sections | RESOLVED 2026-11-06 (ED-136) |
| CR-124 | E-Phones (11840 px) exceeded the canvas's 8000 px board cap, so its last four sections were hidden | E-Phones | RESOLVED 2026-11-06 (ED-144): split into E-Phones and E-Phones-2 |
| CR-125 | iPhone "Add › Brain dump" and "Add › Routine" frames still show the compact Add sheet (field row, teal Add), while Add › Task is now the full Create task screen with tabs (ED-139, ED-140) | E-Phones-2 Add modes | RESOLVED 2026-11-07: Brain dump and Routine full screen on iPhone and Android (ED-147 to ED-149) |
| CR-126 | Rules §8.4 Surface/Field/Return rows and the G3-7 handoff still described the compact Add sheet with a teal Add in the field row for Full iPhone | E_DESIGN_RULES §8.4, handoff | RESOLVED 2026-11-06: rows now say Create task, teal Create task in the header; Minimal keeps the nav-bar Add |
| CR-127 | Tablets: Create task (ED-140), the full-screen Brain dump, Routine and proposal (ED-147 to ED-150) and the editor's steps/notes scroll (ED-137) are drawn for phones only; iPad and Android tablet layouts are not assumed | iPad / AndT | OPEN · Prompt D Round 2 (G4-4) |
| CR-128 | History boards E-G2-8 (A1–A6) and E-G3-7 (Full B, C, A) now show the current Create task / full-screen modes at the owner's request; their original drawings live only in the g2-8 and g3-7 snapshots | E-G2-8, E-G3-7 | NOTED 2026-11-07 (ED-146 to ED-151); decisions G2-8 A and G3-7 C unchanged |
| CR-129 | "Add another" (old compact sheet) has no place on Create task; the G3-7 handoff rule "Add another keeps the sheet open" is suspended until decided | E-Phones, handoff | DECIDED 2026-11-07: dropped (ED-152); handoff updated |
| CR-130 | Leftover "Add another" text: the "How the keyboard is dismissed" cards on E-Phones-2 and E-PhonesMinimal ("With Add another off, the sheet closes after adding") and the E-Map row label "Quick Add (NL time, Add another)" | E-Phones-2, E-PhonesMinimal, E-Map | RESOLVED 2026-11-07 (ED-153) |
| CR-131 | iPhone Brain dump / Routine headers show a centre title; Create task has none | E-Phones-2 | RESOLVED 2026-11-07 (ED-153); E-G2-8 history frames keep the title |
| CR-132 | After G3-8, Mac and web sidebar secondary text has not been re-measured against 4.5:1 | E-FullA-v2, E-Minimal, E-Workspace | CHECKED 2026-11-07: secondary `#6A6273` 4.55–4.75:1 on sidebar surfaces (passes, thin margin over vibrancy); no change; device check over other wallpapers PENDING (ED-154) |
| CR-133 | After G3-9: three ring contexts stay under 3:1 by design: the Minimal "Lands at" preview fades other tasks to 45 % (1.60–1.71:1, aria-hidden); rings behind a 30 % modal scrim (about 2.77:1, inert); the colour picker's selected-swatch halo uses the fill (coral 2.90:1) | E-PhonesMinimal Add, sheets over Today, E-Phones colour picker | VERIFIED 2026-11-07 (ED-165): (1) decorative, (2) acceptable if sheets with a dimmed backdrop are modal, (3) every selected swatch has a check at 3:1 or better |
| CR-134 | Minimal-mode Settings list keeps its Layout row (the way back to Everything) while the Full Settings root moved Layout to Appearance (ED-161) | E-PhonesMinimal | RESOLVED 2026-11-07 (ED-165): intentional; both lead to the same view-mode setting |
| CR-135 | The "All icons, pinned palette" frame on E-Phones still draws the 9-colour pinned row (first six visible match the new order) | E-Phones | RESOLVED 2026-11-07: All icons sheet now has the 12-colour row and ⋯ All colours (owner comment) |
| CR-136 | Naming variants (CR-046, CR-060, CR-062, CR-064, CR-065): Running late / Need more time, Reviews / Review, Gentle Day / Low-energy day / Low-energy mode, Delete / Move to Trash | all active boards | RESOLVED 2026-11-07 (ED-162) |
| CR-137 | Need more time chips at 36 pt on phones (part of CR-100) | E-Phones, E-PhonesMinimal | RESOLVED 2026-11-07 (ED-163): 44 pt, wraps at 200 % |
| CR-138 | The Now horizon's spoken summary in minimal still says "3 done … 5 ahead" (aria-label only, not visible) while doc 14 rule 5 allows no done count | E-PhonesMinimal Now (iPhone, Android), E-Minimal Mac and web Now, E-FullA-v2 Now | RESOLVED 2026-11-07 (ED-165): calm summaries, no counts or percentages in Minimal |
| CR-139 | Width alone puts most landscape phones (852–932 pt wide, about 400 tall) into the expanded desktop layout; the app supports landscape on iPhone and measures the whole window | E-Responsive row 5; app `WidthClass` via window width | RESOLVED 2026-11-07 (ED-168): H1, usable height under 480 keeps the compact layout |
| CR-140 | Minimum widths that allow docking are not set; E-Map measured 320 for the thread, but 339 was judged cramped | E-Responsive rows 1 and 4; E-Map | RESOLVED 2026-11-07 (ED-168): M, Today 480 / 600, editor 420, sidebar 216 |
| CR-141 | The Full Mac Workspace docks a 248 inspector at 1280 (E-FullA-v2), but M's editor minimum is 420, which would make it float | E-FullA-v2; E-G4-3-Narrow | RESOLVED 2026-11-07 (ED-170): C1 (a), the inspector (248) is separate from the editor (420) |
| CR-142 | The Mac minimum is 840 × 640 in the design but 960 × 640 in the app (`MainFlutterWindow.swift`) | app vs ED-169 | NOTED · implementation not authorised |
| CR-143 | Show/hide Day column key: ⌥⌘D in rules, ⌥⌘I on E-Minimal ("Hide the Day column ⌥⌘I", which is also the Workspace inspector key) | E-Minimal; rules §11 | OPEN · owner choice when shortcuts are next reviewed |
| CR-144 | A rules line listed "Now ⌘1, Day ⌘2, Calendar ⌘3, Inbox ⌘4" for E-Minimal, contradicting the board and §11 (⌘2 = Inbox) | rules | RESOLVED 2026-11-07 (ED-170): line superseded |
| CR-145 | Rules §11 Web row described path URLs (`/plan/day/…`) after ED-097 adopted hash URLs | rules | RESOLVED 2026-11-07 (ED-172): marked superseded |
| CR-146 | iOS switch teal #11615C is 2.1:1 on dark rows | E-G4-6-Dark-Tokens | RESOLVED 2026-11-07 (ED-174): dark on-tint #2A8C83 |
| CR-147 | Five task rings sit at 3.02–3.37:1 on dark surfaces (low margin) | E-G4-6-Dark-Tokens §4 | RESOLVED 2026-11-07 (ED-175): six colours lifted to ≥ 3.50:1 |
| CR-148 | Dark Mac sidebar: teal selected label 3.07:1 on its pill, 3.95:1 on the sidebar (light wallpaper), measured natively | E-G4-6-Dark-Tokens §5 | RESOLVED 2026-11-07 (ED-176): primary-text label; icon colour I1/I2 open (CR-149) |
| CR-149 | Dark Mac selected icon in teal is 2.89:1 on its pill over a light wallpaper (native capture) | E-G4-6-Dark-Tokens §6 | RESOLVED 2026-11-07 (ED-178): I1 #A3E2D9 |
| CR-150 | Light-mode dotted thread #BEB6C7 is 1.84:1 (decorative); dark choice T2 asks whether "ahead" should meet 3:1 | E-G4-6-Dark-Tokens §7 | RESOLVED 2026-11-07 (ED-178): T2-B #6B6369 in dark; light unchanged; lighter-surface case is Q1 (CR-151) |
| CR-151 | Dotted thread #6B6369 is under 3:1 on surface, raised and sheet (2.93 / 2.65 / 2.42); all drawn timelines sit on the ground | E-G4-6-Dark-Frames Q1 | RESOLVED 2026-11-08 (ED-179): Q1-B, #7B7279 on lighter surfaces where measured; popover flagged |
| CR-152 | Text below 4.5:1 found in dark frames and inherited from light: "Add a step" placeholder 4.20, violet "#" hex prefix 4.29, iOS keyboard keys 4.46 (system-drawn) | E-G4-6-Dark-Frames | RESOLVED 2026-11-08 (ED-179): placeholder #6F6978 / #A0999F and hex "#" in secondary text, light and dark; iOS keyboard system-owned |
| CR-153 | E-G4-3-Narrow (light) has no `.blk` / `.dot` CSS, so its Workspace week grid draws browser-default grey buttons with overlapping text | E-G4-3-Narrow §1, all Full frames | RESOLVED 2026-11-08 (ED-183): the grid styles are restored on E-G4-3-Narrow and its dark copy |
| CR-154 | Android title placeholder "What is it?" #8A8494 is 2.89–3.15:1 in light (tinted headers) | E-Phones-3 Android editors | RESOLVED 2026-11-08 (ED-185) as approved; 4.24:1 on two tinted Android headers flagged (G4-7 Q5); **Q5 option A applied 2026-11-08 (ED-196): #6A6473, rendered 4.56–4.96:1; CLOSED at design level** |
| CR-155 | "Your colours" swatches have no outline: light customs on the light sheet are 2.0–2.3:1, dark customs on the dark sheet 1.4–1.7:1 | E-Phones-3, E-FullA-v2 colour pickers | RESOLVED 2026-11-08 (ED-185): 1.5 px neutral outline below 3:1 (light #7A7280, dark #8C838A); dark check glyph re-derived |
| CR-158 | During sync an expired session maps to the generic "Couldn't sync… it will try again" instead of "Sign in again" (`supabase_sync_gateway.dart`) | E-G4-7-States A10 | OPEN · implementation (design shows Sign in…) |
| CR-159 | Web storage is not requested as persistent (`navigator.storage.persist` absent), so a browser may evict tasks | E-G4-7-States B6, Q2a–Q2f | Design CLOSED (ED-188 to ED-192). Requirement: ask after sign-in and, when not signed in, after the first successfully saved change; check `persisted()` first; once only; never blocks saving. OPEN · implementation, not built or tested (handoff § G4-7 Q2) |
| CR-160 | **CRITICAL · privacy/security · RELEASE BLOCKER (ED-193).** On a shared device, after one person signs out and another signs in, `adoptAccount` re-keys every local row to the new account and `requeueAll` uploads them: the first person's tasks go into the second person's account. Also: guest sign-in into an account that already has data is untested; guest profile settings silently replace the account's; starter tasks and routines can duplicate; no web end-to-end or shared-device test. Simple guest-to-new-account adoption is unit-tested; that test does not cover the other cases. | `app/lib/data/sync/account_adoption.dart`, `requeue.dart`, `sync_engine.dart`, `engine_sync_service.dart`; E-G4-7-States Q2e | OPEN · implementation and verification. Account switching is not safe until every acceptance criterion in handoff § "CR-160" passes. Guest Sign in must not be described as safe for existing-account or shared-device cases until then. No workaround may delete unsynced work. |
| CR-161 | Conflict Undo (G4-7 Q3) is designed but not in the app: resolution is final today, no Undo action, no ⌘Z / Ctrl+Z handling, no screen-reader persistence for the confirmation | E-G4-7-States C3, C5 | Design APPROVED (ED-194). OPEN · implementation and device testing (handoff § G4-7 Q3) |
| CR-162 | Dark amber task dot glyph: #F3ECE4 on #D9A23A was 1.95:1 (type icon and done check) | 8 boards, 90 glyph dots (ED-196) | RESOLVED at design level 2026-11-08 (ED-196): ink #171416, 8.0:1. Historical E-G4-6-Dark-Frames kept. Device accessibility tests PENDING |
| CR-163 | Keep both for notes (G4-7 Q4) designed, not in the app | E-G4-7-Q4-KeepBoth | Design APPROVED (ED-195); Q4-L1 limit approved (ED-196). OPEN · implementation and tests (handoff § G4-7 Q4) |
| CR-164 | Notes length counted three ways: editor `maxLength` (grapheme clusters), validator `String.length` (UTF-16), SQLite/Postgres (code points). Emoji-heavy notes accepted by the editor can exceed the database limit and fail to save | `editor_notes.dart`, `field_rules.dart`, notes CHECKs | OPEN · implementation: one acceptance rule everywhere (the validator's); a rejected save never discards text, keeps the whole draft and shows the truthful existing error; regression tests tracked separately (ED-196, ED-197) |
| CR-165 | Pre-existing findings, verified (ED-197): (1) web Forward arrow 2.68:1 is the browser's own disabled control, not Dottoday UI; (2) Mac "3 of 9 · 7 h 40" 4.42:1 and "⌘3" 4.38:1: secondary `#6A6273` on the selected sidebar row, light only; (3) dark "clipping" flags render identically to the approved light boards (ED-183 clamp; ED-170 floating inspector) | E-FullA-v2, E-G4-3-Narrow, E-Minimal, G4-7 kit; dark copies | OPEN · (2) needs the owner: proposed `#4E4757` for secondary labels on the selected row only (≥ 6.7:1); (1) and (3) no change recommended; (4) E-PhonesMinimal: six pre-existing horizontal text-fit flags ("3:00–3:45 PM", "Pick up parcel"), not yet inspected (ED-198) |
| CR-166 | Dark now-ring tracks don't follow ED-174 (task colour at 25 %): light-derived `rgba(91,95,214,.2)`, `#5B5FD633` or fixed `#302F48` under the dark indigo arc; teal tracks at light teal 20 % | All dark copies (E-FullA-v2-Dark, E-G4-3-Narrow-Dark, E-Minimal-Dark, E-Earlier-Dark, E-Phones*-Dark, E-MobileWeb-Dark) | OPEN · owner OK needed; mechanical under ED-174 (ED-198) |
| CR-167 | iPad "Alarms off" tag used the board's Hypothesis amber `#FBEBD0` / `#6E4300` in product UI (cleanup 8c) | E-Phones, E-Phones-Dark | RESOLVED 2026-11-09 (ED-205): neutral tag + amber bell-off icon. Note: light icon `#AF7E22` is 3.06:1 by colour, only 54 % (1×) to 87 % (3×) of antialiased stroke pixels reach 3:1; darker light icon `#A57620` proposed, not applied. Device tests (VoiceOver, TalkBack) PENDING |
| CR-170 | iPhone glass outer shadows varied per element (I32, cleanup 15) | E-Phones, E-PhonesMinimal and dark copies | RESOLVED 2026-11-09 (ED-210): five tiers confirmed as intended; measured consistent across all phone boards, light and dark |
| CR-169 | Minimal Day-column Now card differed: Mac 68 px / title 16, web 64 px / title 17 / Now 13.5 (N12, cleanup 14) | E-Minimal and dark | RESOLVED 2026-11-09 (ED-209): Mac sizes on both |
| CR-168 | Mac and web Day button fonts differed: Mac system 13 at 500 or 700, web Manrope 13/700 against the web-chrome rule (N14, cleanup 10) | E-Minimal, E-FullA-v2, E-G4-3-Narrow and dark copies | RESOLVED 2026-11-09 (ED-206): system 13/500 on both. CR-010 (web Add teal) stays open: approved, not applied. E-G4-7-States (review board) still draws the web Day button in Manrope 13/700 |
| CR-157 | E-G4-3-Narrow 840 × 640 toolbar is wider than its 624 px: "3 days" wraps onto two lines and the 34 px search button clips its ⌘K | E-G4-3-Narrow §1, §2 (840 frames) | RESOLVED 2026-11-08 (ED-183): 840 toolbar fits (Week ⌄ pop-up, search button sized to ⌘K, 6 px gaps); rule §12.3 |
| CR-156 | E-Phones-2 (light) routine dots use five pre-G3-9b hues (#4FA37A, #3E9C6B, #5B8DD6, #E2A93B, #C9A227) | E-Phones-2 Routine frames | RESOLVED 2026-11-08 (ED-185): amber / green / sky ring tokens; Wind down grey → slate #6E6A75 |

---

## v1.0 findings, 2026-11-04 — kept for history

The v1.0 report is kept unchanged below, with its headings moved down one level. Its items are re-checked above. Where a v1.0 item is now settled, the v1.1 table says so (for example, CR-030 and CR-031 replace v1.0 §3 items 2 and 4).

*Original title: "Concept E — feature coverage and consistency report (v1.0)".*


**Status:** LEADING CANDIDATE — NOT APPROVED FOR PRODUCTION IMPLEMENTATION. Written 2026-11-04 for owner review.

**Cross-checked:**
- the five E boards and the working `E-Map`;
- `E_DESIGN_RULES.md`, `E_DESIGN_DECISIONS.md`, `E_SCREEN_INVENTORY.md`;
- `FEATURE_PARITY_MATRIX.md`, `PRODUCT_BRIEF.md`, `DESIGN_PRINCIPLES.md`, `PLATFORM_QUALITY_MATRIX.md`;
- `CLAUDE.md` §8 and §11.

**What this is:** findings only. Nothing on the boards was changed to fix them, because v1.0 has to stay an exact copy of A. Each item is a proposed v1.1 fix or an owner decision.

### 1. Snapshot check

| E board | Copied from | SHA-256 matches the live A board |
|---|---|---|
| E-Phones | A-Phones | yes (`96c85552…`) |
| E-PhonesMinimal | A-PhonesMinimal | yes (`0cd4011a…`) |
| E-Map-v1.0 | A-Map | yes (`97ac2bbb…`) |
| E-Workspace | A-Workspace | yes (`a310f7b5…`) |
| E-Focus | A-Focus | yes (`8a8c42b4…`) |

The source was canvas version 1793757110-10fc. Full sums are in `references/concept-e/v1.0/SHA256SUMS`.

### 2. Features with no home in E's boards

These have no frame, no menu item and no caption in E. Each still needs a place before E can claim parity. `FEATURE_PARITY_MATRIX.md` keeps them all in scope.

- **Wake Up family:**
  - alarm, snooze, the Wake Up card, the Wake Up Check and the missions;
  - day shape, sleep target and night;
  - only the caps on the thread are drawn.
- **Thread details:**
  - Reality thread: a phone Day-menu item only, with no Mac or web home;
  - the fold for tasks that start before Wake Up: Morning run (6:45) is drawn after the 7:00 cap.
- **Assist:** Smallest step, Unstick, on-device AI status.
- **Selection:**
  - selection bar with "Save as routine";
  - the shift-followers drag chip;
  - pin, travel and energy fields.
- **Settings:**
  - the Low-energy header switch;
  - notification health and test alarm, quiet hours, day-start summary, nudges, sounds.
- **Account and data:**
  - recovery screen, app lock, account sign-in, sign-out everywhere and delete;
  - backups, restore and import, Trash;
  - calendar connection and write-back.
- **Reflection and app-level screens:**
  - Past days and the year strip;
  - weekly review share and the learning reveal;
  - feedback and What's new;
  - onboarding;
  - minimal Settings.
- **System surfaces:**
  - widgets, Live Activity or ongoing notification;
  - Controls and Quick Settings tiles;
  - App Intents and Siri, Share into Inbox;
  - PWA install, web push, the web tab live dot.
- **Spoken Brain dump:** only on the Mac workspace (the Dictate mic).

**Entry point drawn, screen not drawn:**
- Focus, Search;
- the phone Inbox screen, the phone Calendar tab;
- This week, Pick one thing, the Undo toast, the Settings root.

### 3. Structural contradictions (owner decisions)

1. **No standard wide layout.** A-Wide (the thread with the three-day spread) was deleted, and E-Map-v1.0 still describes and scores it. E's only wide layouts are Workspace and Focus.
2. **E-Focus is mislabelled.** It is titled "minimal look, Mac and Web", but its frames are captioned "full" and show the full sidebar. No wide minimal layout exists after A-Minimal was deleted. Minimal mode is required on every platform (R-13, doc 14).
3. **Two wide shells disagree:**
   - **Sidebar:** Workspace has Today/Plan/Inbox/Routines/Brain dump/Calendar/Review/Search; Focus has Now/Day/Calendar/Inbox/Search/Reviews/Routines.
   - **⌘1–4:** Day/3 days/Week/Month against Now/Day/Calendar/Inbox.
   - **Day menus:** different.
   - **Context menu:** "Move to Trash ⌘⌫" against "Delete ⌫".
   - **⌘K:** a command palette against a search field.
   - **Web routes:** `/plan/day/…` against `/now`, `/today`, `/day/:date`.
4. **Now has no consistent home.** Full phones have no Now view, but minimal phones and the wide Focus layout open on Now.
5. **Minimal phones conflict with doc 14.** They keep a three-tab bar (Now · Today · Inbox) and fold done tasks into an "Earlier" row. Doc 14 and today's app have no tab bar and an Inbox "Later" row. The board tags these as hypotheses.
6. **"Settings › Everything else" disagrees with the decision boards.** The minimal table routes Routines, Search and Export through it. D1 and D3 recommend that Everything else opens the regrouped root.
7. **"Lists" is outside parity.** It sits on the Mac Workspace sidebar.

### 4. Naming and copy conflicts

- **Low-energy:** "Low-energy mode", "Low-energy day", "Gentle Day" and "Low-Energy Mode".
- **Brain dump:** "Brain dump" and "Clear your head".
- **Destinations:** Review and Reviews; Today and Day.
- **Repeat marker:** an icon, "· repeats" and "↻".
- **Running late:** +15/+30 on phones, but +5/+15/+30 on Mac and in the parity matrix.
- **No-shame rule:** "Running late" appears in the Day menus, the Mac menu bar and the palette. CLAUDE.md §11 bans "late" in user-facing copy, and E's own Now copy already says "Need more time?". **Needs an owner ruling:** rename the menu items, or record an exception.
- **"Week view in full mode":** the minimal "hidden things" table says this, but full phones have no Week.
- **Mac shortcuts:** ⌘F is Focus in E-Focus but Search in E-Map-v1.0. Copy Day as Text ⌘C clashes with Copy.

### 5. Visual inconsistencies between boards (proposed v1.1 fixes)

These come from `E_DESIGN_RULES.md`. Each needs one value chosen.

| Element | Variants found |
|---|---|
| Now bead | 16 px in frames, 12 in legends, 14 on wide |
| Now ring | track `rgba(task,.2)` on phones and `#E4E3F7` on Mac; cut-out 5, 4.5 or 4 px |
| Ahead-dot ring | 4 px inset on phones, 3.5 px border on wide, 3 px in legends |
| Calendar dot centre | `#FBF7F1`, `#FFF`, `#FFFDF9` |
| Wake Up cap | 32 px on Today, 34 px on the empty day and in minimal |
| iOS inactive tab label | `#8E8E93` (3.06:1, fails 4.5:1) in full, `#6E6E73` in minimal |
| Android Day button | 40 px (under 48 dp) in full, 48 px in minimal |
| Android FAB radius | 22 extended, 16 in minimal |
| Now card | iOS r24 / 72 px, Android r22 / 74 px |
| Add input text | 500 19, 600 20, 600 19 |
| Orb numerals | 800 on phones, 700 on wide |
| Android Edit title | Roboto, not Manrope |
| Android Day menu surface | `#F7EFF4`, unlike other Android surfaces |
| Mac sidebar | blurred in Workspace, not in Focus |
| Inspector / web sidebar | 300 and 248 wide / 220 and 216 |
| Web focus ring | two recipes |
| Now-panel Add | ink `#241F2B`; teal everywhere else |
| Board header copy | says "dots with depth", but the dots are drawn flat (ED-023 removed depth) |

### 6. Accessibility findings

- **Touch targets below the minimum:**
  - iOS tip dismiss 40, iOS in-field Add 40;
  - iOS full-mode chips 34, +15/+30 at 36;
  - Android tip dismiss 44, Android Day button 40.
- **Contrast:**
  - the iOS inactive tab label is 3.06:1;
  - four task colours fall below 3:1 as outline rings;
  - white on amber is 2.29:1;
  - contrast on glass, as rendered, is unverified.
- **Not drawn:**
  - 200 % text;
  - dark mode;
  - reduced transparency over glass;
  - reduced motion;
  - a non-grid alternative for the Mac Week grid.

### 7. Platform treatments missing

- **Layouts not drawn:** iPad, Android tablet and foldable, mobile web, narrow Mac and web windows, phone landscape.
- **Mac minimum window:** 960 lands in the proposed medium class, and no medium layout is drawn.
- **Dark mode:** not drawn on any platform.
- **Native glass and vibrancy:** drawn as approximations. A native platform view against Flutter blur is an open engineering decision.

### 8. Agreement check

| Pair | Agrees? | Note |
|---|---|---|
| E-Map ↔ E boards | Yes, with flags | The working E-Map marks every not-drawn cell and lists §3 as decisions |
| E-Map-v1.0 ↔ E boards | **No** | Historical. It describes the deleted A-Wide; kept unchanged as the v1.0 snapshot |
| Inventory ↔ boards | Yes | About 75 screens; designed, partly designed or not designed, per frame |
| Rules ↔ decisions | Yes | Rejected items (floating glass sheets, Inbox tray, halos and glows, apricot, Android glass rims, solid chips, inset sidebar) are banned in the rules |
| E ↔ `THREE_UX_CONCEPTS.md` §3.1 | **No** | It gives A as Inter and cobalt; E is Manrope with the warm palette. That doc is historical for E, and was not edited |
| E ↔ `DESIGN_PRINCIPLES.md` | Yes | One identity, native presentation per platform |
| E ↔ CLAUDE.md §8 | Partly | Drag, multi-select, Shift the rest, quick add and paste are present. Multi-select, the selection bar and the sync conflict UI are not drawn |
