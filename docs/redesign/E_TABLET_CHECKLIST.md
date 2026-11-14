# Concept E: tablet coverage checklist

**Status:** this is the mandatory preparation step before Prompt D Round 2 (ED-090). It is written on 2026-11-13 and recorded as ED-249.

- **Round 2 is complete (2026-11-14, ED-335):** R2-1 to R2-31 are approved (ED-267 to ED-334). Each row in §3 says which board and decision cover it; what is still open is listed in E_DESIGN_DECISIONS.md ED-335. This checklist first said what Round 2 had to draw (ED-249).
- **Concept E** stays LEADING CANDIDATE — NOT APPROVED FOR PRODUCTION IMPLEMENTATION.
- **CR-160** stays CRITICAL — OPEN — RELEASE BLOCKER.

**Scope (ED-090):**
- Every approved Concept E feature and workflow.
- Full and Minimal.
- Portrait and landscape, Split View / Slide Over / Stage Manager, Android multi-window and resizable windows.
- Foldables: folded, unfolded, tabletop.
- Touch, hardware keyboard, pointer, and Apple Pencil where relevant.
- iPad: iPadOS 26 and the iOS 16–25 fallback (ED-128 D2).
- Android tablets and foldables: compact, medium and expanded.

**Sources:**
- `E_DESIGN_DECISIONS.md` (every "Tablets" note in ED-083 to ED-248);
- `E_DECISION_REGISTER.md` (tablet implications for G2-1 to G4-7);
- `STATUS.md` (open items);
- the boards listed in §2.

Phone mockups never count as tablet coverage.

## 1. Rules every tablet screen follows (already approved)

| Rule | Source |
|---|---|
| Width classes: compact < 600, medium 600–839, expanded ≥ 840, measured on the **window**, never the device or orientation | G4-2 · ED-167, G4-4 · ED-171 |
| H1: usable height under 480 keeps the compact layout and never docks | ED-168 |
| Docking: the editor floats below 1160 and docks from 1160 when Today 480 (600 above 130 % text), editor 420 and sidebar 216 fit | ED-167, ED-168 |
| The Workspace inspector (248) is not the editor (420); it docks from 1160 when the week keeps ≥ 3 days | ED-170 |
| iPad: iPadOS-native adaptive navigation (top tab bar that becomes a sidebar, split views); no Material rail | ED-171 |
| Android tablets and foldables: navigation rail at medium, sidebar at expanded, the approved compact navigation at compact; hinge-aware; 48 dp targets | ED-171 |
| Never: the phone bottom row enlarged and called the tablet design; a class assumed from orientation | ED-171 |
| Foldables follow the window class, never the posture alone; no pane or text across a hinge | ED-099, ED-110 (rules §3.6), G4-4 · **Since (2026-11-14):** Drawn R2-31 (ED-334): unfolded flat, tabletop and folded; the app reads no display features yet, so hinge awareness is a code task |
| A width-class change never saves, discards, commits a proposal or changes mode, task or date | ED-100, ED-168 |
| Same tokens, type family, light and dark, focus ring, text-fits rule | ED-110, ED-155, ED-174 to ED-181, ED-183 |
| Settings is not a tab: tablets use the sidebar footer | G2-3 · ED-238 |
| Reduce Transparency / Increase Contrast: E-G4-7-States D4 | ED-248 |

## 2. What already exists for tablets

| Board | What it shows | Standing |
|---|---|---|
| `E-WakeWindDown-Settings-Candidate` (r2) | iPad Settings in Split View: the list, then the dial at 340 pt beside the schedule. Android tablet list-detail with a rail-style list. "This iPad / tablet can be the alarm device" | Approved with G2-4 (ED-084) as the tablet reference for Wake Up and Wind Down |
| `E-G2-5-OptionD-RefinedEditor` | iPad: the task editor beside the day (the Day stays visible, dimmed while editing) | Approved with option D (ED-086); history board |
| `E-Responsive` (+ dark) | Layout class only, schematic at 25 %: iPad Air portrait / landscape, Split View ⅔ and ⅓, iPad mini and Pro 13, iPad landscape with the keyboard, foldable tabletop and unfolded | Responsive rules approved (ED-167, ED-168); navigation not drawn |
| `E-G3-6-Spikes` | iPad simulator: native tab placement (N1 top tabs + sidebar) | Feasibility only (ED-120); starting direction for iPad navigation |

Nothing else has a tablet drawing.

## 3. Feature checklist

Columns follow ED-090:
- **Shared:** the behaviour is the same on every platform.
- **iPad / Android tablet:** a drawing exists (✓), partly exists (◐), or none (—).
- **New layout:** needs its own tablet layout.
- **Interaction:** needs tablet-specific interaction.
- **Unverified:** a behaviour still to check.
- **Round 2:** must be designed in Round 2.

The order follows G4-1 (ED-166): core journey, then interaction and recovery, then supporting experiences.

### 3.1 Core journey

| Feature (Full / Minimal) | Shared | iPad | Android tablet | New layout | Interaction | Unverified | Round 2 |
|---|---|---|---|---|---|---|---|
| **Navigation shell**. Full: Today · Inbox · Calendar · Search, with Settings at the sidebar foot. Minimal: Now · Inbox · Calendar · Search at medium and expanded (by width, ED-266); Now · Today · Inbox in compact windows. (ED-068, ED-075, ED-171, ED-238; drawn on E-R2-1, ED-265) | Destinations, order, Settings entry | ◐ spike only | — | Yes: iPad top tabs ↔ sidebar; Android rail ↔ sidebar | Keyboard ⌘1–4 per mode (ED-095); pointer | Liquid Glass tab bar over Flutter on iPad (ED-120, simulator only); iOS 16–25 fallback | Yes · **Close-out (2026-11-14):** Approved: R2-1 (ED-267, by width ED-266); Stage Manager R2-31 (ED-334) |
| **Today thread** (Full) and Today tab (Minimal) (ED-104, ED-164, ED-246) | Rows, current-task card (45 ring, 19/700, 32 gaps), Earlier and before-Wake-Up folds, now motion | — | — | Yes at medium / expanded: thread pane beside a second pane | Drag with pointer; hover tint (ED-116) | The thread pane's width cap and line length | Yes · **Close-out (2026-11-14):** Approved: R2-1 and R2-2 (ED-267, ED-269); edge states R2-26 and R2-27 (ED-329, ED-330) |
| **Full on expanded tablets: thread or Workspace?** (ED-073, ED-104, ED-171) | Same as Mac/web at this width | ◐ E-T1 A | ◐ E-T1 A | **Decided: Workspace (ED-252)**; touch version | Long-press drag, 44 pt / 48 dp, no hover | — | Yes · **Close-out (2026-11-14):** Approved: Workspace at touch sizes R2-2 (ED-269) |
| **Now / orb / horizon** (Minimal) (ED-066, ED-106, ED-246) | Orb drawing at 0.36 numeral; horizon rule | — | — | Orb sized by window; horizon width | Horizon keys (ED-248); adjustable on touch | — | Yes · **Close-out (2026-11-14):** Approved: Minimal on tablets R2-1 (ED-267); Now states R2-26 (ED-329) |
| **Add / Create task**, Brain dump, Routine, proposal (ED-091, ED-140, ED-147 to ED-150) | Modes, parser, nothing written before Accept | — | — | Yes. iPad: popover from + at medium / expanded; proposal beside the day in landscape. Android: the + menu from the rail; Brain dump / Routine as a side sheet at expanded | ⇧⌘N / Ctrl+Shift+N; hold on +; hover on segments | The proposal in two panes; the M3 FAB menu in a rail; dictation on tablets (register G2-8) | Yes · **Close-out (2026-11-14):** Approved: R2-3 (ED-271) |
| **Task editor** (one task surface) (ED-086, ED-137) | Fields, scope chooser, autosave and Undo | ✓ editor beside the day (option D) | — | Android: side sheet or second pane at medium / expanded | ⌘S, Esc; pointer | Decided (ED-259): beside the day only where it docks (iPad landscape 1180, Android 1280); floats below (iPad mini 1133, portrait) | Yes: docked and floating on iPad and Android (**decided, ED-259**); in the tablet Workspace the editor replaces the Mac inspector (**ED-273**, drawn on E-R2-4) |
| **Minimal task screen** (ED-088, ED-089) | Done · Tomorrow · Later · Delete, More options | — | — | Popover or column by width | — | — | Yes · **Close-out (2026-11-14):** Approved: popover or column by width, R2-4 (ED-274) |
| **Complete / Done + Undo** | Ring dot, ⌘D / Space, Undo | — | — | — | Pointer click on the dot; keyboard | Undo toast placement with a rail / sidebar | With the Undo pass (3.2) · **Since (2026-11-14):** Undo toast at medium width drawn R2-31 (ED-334): centred on the content area beside the rail |
| **Change day: the When picker** (ED-099, G2-7) | One picker, rules unchanged | — | — | iPad: popover from the row. Android expanded: side sheet. Compact: the phone sheet | Typed date and time fields with a keyboard; drop from the Inbox places directly | — | Yes · **Close-out (2026-11-14):** Approved: R2-5 (ED-276); Move to a day and no free slot R2-28 (ED-331) |
| **Reopen a task** | As built | — | — | — | — | — | Covered by the Today and editor drawings · **Close-out (2026-11-14):** Approved: R2-5 (ED-276) |

### 3.2 Interaction and recovery

| Feature | Shared | iPad | Android tablet | New layout | Interaction | Unverified | Round 2 |
|---|---|---|---|---|---|---|---|
| **Multi-select and selection bar** (CR-078) | Not designed on any platform | — | — | Yes | Long-press; ⇧ / ⌘-click with a pointer; keyboard | — | Yes (also undrawn on phones) · **Close-out (2026-11-14):** Approved: R2-6 (ED-279) |
| **Undo toast and ⌘Z** (CR-079) | Not designed (only conflict Undo, ED-194) | — | — | Yes | ⌘Z / Ctrl+Z | — | Yes · **Since (2026-11-14):** Medium width drawn R2-31 (ED-334) · **Close-out (2026-11-14):** Approved: R2-7 (ED-281) |
| **Sync states and conflicts** (G4-7 kit, ED-186 to ED-196) | Vocabulary, states, Q3 Undo, Q4 Keep both | — | — | Kit says "tablets inherit"; presentation per layout | — | Device tests | Yes, the presentation · **Close-out (2026-11-14):** Approved: R2-8 (ED-283) |
| **Focus session** (CR-076) | Not designed on any platform | — | — | Yes | Pencil: none proposed | — | Yes · **Close-out (2026-11-14):** Approved: R2-9 (ED-286); time states R2-26 (ED-329) |
| **Keyboard scheme** (ED-095, ED-248) | ⌘ on iPad, Ctrl on Android; focus order | — | — | — | ⌘-hold overlay (iPad) and Meta+/ (Android) need native registration | Both unverified (ED-095) | Draw the overlays' contents · **Close-out (2026-11-14):** Approved: R2-10 (ED-288) |

### 3.3 Supporting experiences

| Feature | Shared | iPad | Android tablet | New layout | Interaction | Unverified | Round 2 |
|---|---|---|---|---|---|---|---|
| **Wake Up and Wind Down** (ED-083, ED-084) | Schedules, dial rule, one alarm device | ✓ Split View list + dial | ✓ list-detail | Drawn | — | AlarmKit on iPadOS 26; Play's full-screen-intent policy on tablets; device-list table (must-ask) | Re-checked and approved: R2-18 (ED-311) |
| **Wake Up alarm on tablets** (ED-083, ED-314) | One alarm device per account; a tablet can be it | ✓ iPadOS 26 AlarmKit full-screen alert; snooze is the system countdown on the Lock Screen (no Live Activity); the Wake Up card docks beside Today | ✓ Dottoday's full-screen ringing screen in landscape; Walk 20 steps mission | Drawn on E-R2-19-B (Tablets row) | Missions drawn for tablets (Walk, Stand up, Light, Breathe, Catch the dot, Pick today's one thing) but not offered on tablets yet | AlarmKit on iPadOS 26; Play's full-screen-intent policy on tablets | Approved: R2-19 Option B (ED-314) |
| **Notifications and alerts** (ED-316) | Task alerts, Wind Down, day-start summary, the in-app strip, Settings › Reminders, Notification health, test alarm | ✓ Settings › Reminders in two panes (R2-11 rule); system banners as on iPhone, no Live Activity | ✓ list-detail Reminders; the exact-timing notice on top | Two-pane Reminders drawn on E-R2-20 | — | Exact alarms and battery saving on Android tablets read like phones (built checks) | Approved: R2-20 (ED-317) |
| **Data safety** (ED-318) | Data and privacy, Export and backups, import and restore, Trash, recovery | ✓ Data and privacy and Export in two panes (R2-11 rule); system share sheet as a popover | ✓ list-detail | Drawn on E-R2-21 | Share popover and file picker are system UI | — | Approved: R2-21 (ED-319) |
| **Planning helpers** (ED-320) | Routines, Duplicate day, Copy as text, Low-energy mode | ✓ Routines as a sidebar destination (R2-1 shell); proposals as sheets | ✓ the same, with the drawer | Drawn on E-R2-22 (iPad) | — | — | Approved: R2-22 (ED-322) |
| **Proposal flows and learning** (ED-323) | Break it down, Smallest step, Unstick, Help with thinking, Reality thread | ✓ the proposal as a sheet; the Reality switch in the day header | ✓ the same | Mac and web panel drawn on E-R2-23 | Esc discards the panel | — | Approved: R2-23 (ED-324) |
| **The rest of the app** (ED-325) | This week, Calendars, App lock, Help and about, web install | ✓ This week as a popover from medium width; Settings pages in two panes (R2-11 rule) | ✓ the same | Not drawn at tablet width; built rule noted on E-R2-24 | — | — | Approved: R2-24 (ED-326) |
| **Settings** (ED-081, ED-084, ED-161, ED-234 to ED-238) | Six groups, Appearance, search | ◐ (Wake Up pane only) | ◐ (Wake Up pane only) | Two-pane Settings (register G2-4); the sidebar-foot entry | — | — | Yes: root and groups (stage 3, ED-166); tablets R2-11 (ED-291), Your day without the Day shape row (ED-321) |
| **Calendar: Month and Week** (ED-075, register G2-1) | One month grid | — | — | Calendar in the sidebar / rail with Month and Week | Pointer drag on Week | — | Yes · **Close-out (2026-11-14):** Approved: R2-12 (ED-293) |
| **Inbox, Search, Search or run** (ED-081, ED-095) | — | — | — | Yes | ⌘F / ⌘K | — | Yes · **Close-out (2026-11-14):** Approved: Inbox and Search R2-13 (ED-295); Mac and web R2-30 (ED-333); Search or run results design-only, not built |
| **Workspace and Plan panel** (ED-073, ED-184) | Full on expanded wide windows | — | — | Depends on §4 Q1 | Hover / drag (ED-116) on pointer only | — | Yes · **Close-out (2026-11-14):** Approved: R2-2 (ED-269) |
| **Day review and Week in review** (ED-099) | One review body | — | — | iPad landscape / Android expanded: a pane beside the day; iPad narrow Split View / Android compact: the phone sheet | — | — | Yes · **Close-out (2026-11-14):** Approved: R2-14 (ED-297) |
| **Day menu** (ED-093) | Groups and commands | — | — | Pull-down from Day ▾ (iPad); M3 menu anchored to the Day button (Android, also in two panes) | iPadOS menu bar with a keyboard | Minimal on tablets: **decided by width (ED-254)**: E-Minimal's menu at medium and expanded, the phone 3-item menu at compact | Yes · **Close-out (2026-11-14):** Approved: R2-5 (ED-276), by width (ED-254) |
| **Colour and icon picker** (ED-161) | 12 colours, Your colours, Custom… | — | — | Popover (as Mac / web) or the phone half sheet by width | — | Must-ask data change before build (ED-219 to ED-221) | Yes · **Close-out (2026-11-14):** Approved: R2-15 (ED-299); data change still must-ask before build |
| **Account screens** (E-CR160, ED-222 to ED-231) | Copy and rules | — | — | Dialog sizes by width class | — | CR-160 implementation | Yes (after CR-160) · **Close-out (2026-11-14):** Waiting on CR-160 |
| **Onboarding** (CR-089) | The interactive “Dottoday Onboarding Prototype” (Hello → Your day → What fills your days? (up to 5) → the nudge; no navigation on the steps) | — | — | Laid out by width as the phone steps; no separate tablet frames drawn | Drag the sun and moon; keyboard and screen-reader sliders | Age rule conflict with 06-security.md Children (ED-304) | Approved: R2-16 (ED-305) |
| **System surfaces**: widgets, Live Activity, Controls, Share, Quick Settings tiles (CR-088) | `DaySnapshot` and the five App Intents (CLAUDE.md §11) | — | — | iPad widgets and Stage Manager; Android tablet widgets | Drag and drop from other apps | — | Approved: R2-17 (ED-309): iPad widgets at iPad sizes (no Live Activity on iPad); Android tablet widgets and Quick Settings |
| **Routes and multi-window** (ED-097, ED-242) | Hash routes; no address for view states | — | — | — | Each window keeps its own Back history | go_router per-window history (unverified); universal / App Links not built | Confirm in the layout pass · **Close-out (2026-11-14):** Drawn by width on R2-1 and R2-31 (ED-267, ED-334); per-window history still to confirm in the build |
| **Mobile web on tablets** (ED-172) | Tablet browsers follow G4-4 | — | — | As the native tablet layouts | Touch + keyboard | — | With the tablet layouts · **Since (2026-11-14):** Drawn R2-31 (ED-334): iPad Safari (expanded) and Android Chrome (medium) |
| **Typography on touch tablets** (ED-110, rules §3.6) | Family and roles | — | — | — | — | Medium / expanded touch tablets: **decided, phone content scale with touch spacing (ED-256)** | Yes · **Close-out (2026-11-14):** Applied on every Round 2 tablet frame (ED-256) |
| **Hover and drag** (ED-116) | Hybrid C | — | — | — | Pointer only; touch never simulates hover | — | Approved: touch drag, pointer hover tint and pointer drag on R2-25 (ED-328) |
| **Dark mode and accessibility** (ED-174 to ED-181, ED-246, ED-248) | Tokens, D4, focus | — | — | Every tablet frame in light and dark | 200 % text; VoiceOver / TalkBack | Device tests | Yes, with each frame · **Close-out (2026-11-14):** Light and dark on every Round 2 board; 200 % on R2-7 only; device tests still open |
| **Glass and native chrome** (ED-128, ED-133) | Native-first | ◐ spike | — | iPad tab bar / sidebar; Android rail surfaces | — | Reduce Transparency / Increase Contrast on device | Yes · **Close-out (2026-11-14):** Native chrome drawn R2-1 (ED-267); Reduce Transparency and Increase Contrast still device tests |

## 4. Decisions needed before tablet drawing starts

These are the only places where approved decisions leave a tablet question open. Each needs an owner answer before Round 2 draws the screens.

1. ~~**Q1 · Full on expanded tablets.**~~ **Decided 2026-11-13 (ED-252): A, the Workspace, as on Mac and web at the same width; touch version in Round 2 (board E-T1).** Original question: The Workspace (sidebar, Inbox and Routines column, time grid, inspector) as on Mac, or the Today thread with a second pane? ED-171 says expanded windows get "a richer workspace". ED-104 notes that G3-1 does not apply if tablet Full is a grid.
2. ~~**Q2 · Minimal on tablets.**~~ **Decided 2026-11-13 (ED-254): A, by width. Medium and expanded windows get E-Minimal's Day menu; compact windows get the phones' three items (board E-T2).** Original question: The phones' three-item Day menu, or E-Minimal's richer Mac/web menu (register G2-9)? Mockups were on E-T2 (ED-253).
3. ~~**Q3 · Content type on touch tablets.**~~ **Decided 2026-11-13 (ED-256): B, phone content sizes with touch spacing in the wide layouts; chrome stays native (board E-T3).** Original question: at medium and expanded, the Mac-size wide type, or the phone content size for touch reading distance (rules §3.6)? Mockups were on E-T3 (ED-255).
4. ~~**Q4 · Apple Pencil.**~~ **Decided 2026-11-13 (ED-258): A, handwriting in text fields only (Scribble; Android system stylus handwriting); elsewhere the stylus acts like a finger; no Pencil-only actions (board E-T4).** Original question: ED-171 says "where relevant". Proposed scope: Scribble in text fields only (system), and no drawing or handwriting features. Confirm, or name what Pencil should do. Mockups were on E-T4 (ED-257).
5. ~~**Q5 · The iPad task editor.**~~ **Decided 2026-11-13 (ED-259), as proposed: beside the day only where the editor docks (≥ 1160 and the minimum widths fit, ED-167, ED-168); otherwise it floats over Today; compact windows use the phone sheet. Same rule on Android tablets.** Original question: The option D drawing shows the editor beside the day. Under ED-167 it docks only from 1160 (iPad Air landscape 1180 docks; iPad mini 1133 floats). Confirm that the option D drawing applies only where the window allows docking.

## 5. Round 2 drawing list (from §3)

Stage 1, the core journey:
- navigation shell (iPad, Android, each class);
- Today / thread pane;
- Now and horizon;
- Add with its modes and the proposal;
- Android editor;
- Minimal task screen;
- When picker;
- Day menu.

Stage 2, interaction and recovery:
- multi-select and the selection bar;
- Undo;
- sync states and conflicts;
- Focus session;
- keyboard overlays.

Stage 3, supporting experiences:
- Settings root and groups;
- Calendar Month and Week;
- Inbox and Search;
- Workspace and Plan panel (after Q1);
- Day review;
- colour picker;
- account screens;
- onboarding;
- system surfaces;
- the Wake Up and Wind Down re-check.

Every frame:
- light and dark;
- compact, medium and expanded;
- portrait and landscape;
- one Split View or multi-window case;
- one foldable case;
- 200 % text;
- keyboard and pointer states.

**Coverage at close-out (2026-11-14, ED-335).** Every stage above is drawn and approved. Against the "every frame" list:
- light and dark: every Round 2 board;
- compact, medium and expanded: R2-1, R2-31 and the platform boards; most feature boards show expanded and compact only;
- portrait: R2-1, R2-11 and R2-31; most tablet frames are landscape;
- Split View or multi-window: R2-1 (Split View ½) and R2-31 (Stage Manager);
- foldable: R2-1 and R2-31 (flat, tabletop, folded); hinge awareness is not built (ED-334);
- 200 % text: R2-7 only;
- keyboard and pointer states: R2-10 and R2-25.
The thin rows (portrait, 200 %) are left to the build's golden matrix rather than more boards.

## 6. Verification carried into Round 2 (not design)

- AlarmKit on iPadOS 26.
- Play's full-screen-intent policy on tablets.
- Liquid Glass tab bar over Flutter on an iPad device.
- iOS 16–25 fallback on iPad.
- The ⌘-hold overlay and Meta+/ helper registration.
- go_router per-window history.
- Reduce Transparency and Increase Contrast on device.
- Dynamic Type and font scale above 200 % on iPad.
- Pointer hover on the current-task card (ED-104).
