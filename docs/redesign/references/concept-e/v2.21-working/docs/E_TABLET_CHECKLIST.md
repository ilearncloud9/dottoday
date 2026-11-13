# Concept E: tablet coverage checklist

**Status:** this is the mandatory preparation step before Prompt D Round 2 (ED-090). It is written on 2026-11-13 and recorded as ED-249.

- **Round 2 is not started:** no tablet screen is drawn here. This checklist says what Round 2 must draw and what still has to be decided first.
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
| Foldables follow the window class, never the posture alone; no pane or text across a hinge | ED-099, ED-110 (rules §3.6), G4-4 |
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
| **Navigation shell**. Full: Today · Inbox · Calendar · Search, with Settings at the sidebar foot. Minimal: Now · Today · Inbox. (ED-068, ED-075, ED-171, ED-238) | Destinations, order, Settings entry | ◐ spike only | — | Yes: iPad top tabs ↔ sidebar; Android rail ↔ sidebar | Keyboard ⌘1–4 per mode (ED-095); pointer | Liquid Glass tab bar over Flutter on iPad (ED-120, simulator only); iOS 16–25 fallback | Yes |
| **Today thread** (Full) and Today tab (Minimal) (ED-104, ED-164, ED-246) | Rows, current-task card (45 ring, 19/700, 32 gaps), Earlier and before-Wake-Up folds, now motion | — | — | Yes at medium / expanded: thread pane beside a second pane | Drag with pointer; hover tint (ED-116) | The thread pane's width cap and line length | Yes |
| **Full on expanded tablets: thread or Workspace?** (ED-073, ED-104, ED-171) | Same as Mac/web at this width | ◐ E-T1 A | ◐ E-T1 A | **Decided: Workspace (ED-252)**; touch version | Long-press drag, 44 pt / 48 dp, no hover | — | Yes |
| **Now / orb / horizon** (Minimal) (ED-066, ED-106, ED-246) | Orb drawing at 0.36 numeral; horizon rule | — | — | Orb sized by window; horizon width | Horizon keys (ED-248); adjustable on touch | — | Yes |
| **Add / Create task**, Brain dump, Routine, proposal (ED-091, ED-140, ED-147 to ED-150) | Modes, parser, nothing written before Accept | — | — | Yes. iPad: popover from + at medium / expanded; proposal beside the day in landscape. Android: the + menu from the rail; Brain dump / Routine as a side sheet at expanded | ⇧⌘N / Ctrl+Shift+N; hold on +; hover on segments | The proposal in two panes; the M3 FAB menu in a rail; dictation on tablets (register G2-8) | Yes |
| **Task editor** (one task surface) (ED-086, ED-137) | Fields, scope chooser, autosave and Undo | ✓ editor beside the day (option D) | — | Android: side sheet or second pane at medium / expanded | ⌘S, Esc; pointer | The editor docking rule on iPad landscape at 1180 (docks, E-Responsive) vs 1133 iPad mini (floats) | Android yes; iPad: confirm the option D drawing against ED-167 docking |
| **Minimal task screen** (ED-088, ED-089) | Done · Tomorrow · Later · Delete, More options | — | — | Popover or column by width | — | — | Yes |
| **Complete / Done + Undo** | Ring dot, ⌘D / Space, Undo | — | — | — | Pointer click on the dot; keyboard | Undo toast placement with a rail / sidebar | With the Undo pass (3.2) |
| **Change day: the When picker** (ED-099, G2-7) | One picker, rules unchanged | — | — | iPad: popover from the row. Android expanded: side sheet. Compact: the phone sheet | Typed date and time fields with a keyboard; drop from the Inbox places directly | — | Yes |
| **Reopen a task** | As built | — | — | — | — | — | Covered by the Today and editor drawings |

### 3.2 Interaction and recovery

| Feature | Shared | iPad | Android tablet | New layout | Interaction | Unverified | Round 2 |
|---|---|---|---|---|---|---|---|
| **Multi-select and selection bar** (CR-078) | Not designed on any platform | — | — | Yes | Long-press; ⇧ / ⌘-click with a pointer; keyboard | — | Yes (also undrawn on phones) |
| **Undo toast and ⌘Z** (CR-079) | Not designed (only conflict Undo, ED-194) | — | — | Yes | ⌘Z / Ctrl+Z | — | Yes |
| **Sync states and conflicts** (G4-7 kit, ED-186 to ED-196) | Vocabulary, states, Q3 Undo, Q4 Keep both | — | — | Kit says "tablets inherit"; presentation per layout | — | Device tests | Yes, the presentation |
| **Focus session** (CR-076) | Not designed on any platform | — | — | Yes | Pencil: none proposed | — | Yes |
| **Keyboard scheme** (ED-095, ED-248) | ⌘ on iPad, Ctrl on Android; focus order | — | — | — | ⌘-hold overlay (iPad) and Meta+/ (Android) need native registration | Both unverified (ED-095) | Draw the overlays' contents |

### 3.3 Supporting experiences

| Feature | Shared | iPad | Android tablet | New layout | Interaction | Unverified | Round 2 |
|---|---|---|---|---|---|---|---|
| **Wake Up and Wind Down** (ED-083, ED-084) | Schedules, dial rule, one alarm device | ✓ Split View list + dial | ✓ list-detail | Drawn | — | AlarmKit on iPadOS 26; Play's full-screen-intent policy on tablets; device-list table (must-ask) | Re-check against ED-171 navigation |
| **Settings** (ED-081, ED-084, ED-161, ED-234 to ED-238) | Six groups, Appearance, search | ◐ (Wake Up pane only) | ◐ (Wake Up pane only) | Two-pane Settings (register G2-4); the sidebar-foot entry | — | — | Yes: root and groups (stage 3, ED-166) |
| **Calendar: Month and Week** (ED-075, register G2-1) | One month grid | — | — | Calendar in the sidebar / rail with Month and Week | Pointer drag on Week | — | Yes |
| **Inbox, Search, Search or run** (ED-081, ED-095) | — | — | — | Yes | ⌘F / ⌘K | — | Yes |
| **Workspace and Plan panel** (ED-073, ED-184) | Full on expanded wide windows | — | — | Depends on §4 Q1 | Hover / drag (ED-116) on pointer only | — | Yes |
| **Day review and Week in review** (ED-099) | One review body | — | — | iPad landscape / Android expanded: a pane beside the day; iPad narrow Split View / Android compact: the phone sheet | — | — | Yes |
| **Day menu** (ED-093) | Groups and commands | — | — | Pull-down from Day ▾ (iPad); M3 menu anchored to the Day button (Android, also in two panes) | iPadOS menu bar with a keyboard | Minimal on tablets: **decided by width (ED-254)**: E-Minimal's menu at medium and expanded, the phone 3-item menu at compact | Yes |
| **Colour and icon picker** (ED-161) | 12 colours, Your colours, Custom… | — | — | Popover (as Mac / web) or the phone half sheet by width | — | Must-ask data change before build (ED-219 to ED-221) | Yes |
| **Account screens** (E-CR160, ED-222 to ED-231) | Copy and rules | — | — | Dialog sizes by width class | — | CR-160 implementation | Yes (after CR-160) |
| **Onboarding** (CR-089) | Not designed | — | — | Yes | — | — | Yes (stage 3) |
| **System surfaces**: widgets, Live Activity, Controls, Share, Quick Settings tiles (CR-088) | `DaySnapshot` and the five App Intents (CLAUDE.md §11) | — | — | iPad widgets and Stage Manager; Android tablet widgets | Drag and drop from other apps | — | Yes (stage 3) |
| **Routes and multi-window** (ED-097, ED-242) | Hash routes; no address for view states | — | — | — | Each window keeps its own Back history | go_router per-window history (unverified); universal / App Links not built | Confirm in the layout pass |
| **Mobile web on tablets** (ED-172) | Tablet browsers follow G4-4 | — | — | As the native tablet layouts | Touch + keyboard | — | With the tablet layouts |
| **Typography on touch tablets** (ED-110, rules §3.6) | Family and roles | — | — | — | — | Medium / expanded touch tablets: Mac-size layouts or phone-size content type (**decision**, §4 Q3) | Yes |
| **Hover and drag** (ED-116) | Hybrid C | — | — | — | Pointer only; touch never simulates hover | — | Draw the pointer states |
| **Dark mode and accessibility** (ED-174 to ED-181, ED-246, ED-248) | Tokens, D4, focus | — | — | Every tablet frame in light and dark | 200 % text; VoiceOver / TalkBack | Device tests | Yes, with each frame |
| **Glass and native chrome** (ED-128, ED-133) | Native-first | ◐ spike | — | iPad tab bar / sidebar; Android rail surfaces | — | Reduce Transparency / Increase Contrast on device | Yes |

## 4. Decisions needed before tablet drawing starts

These are the only places where approved decisions leave a tablet question open. Each needs an owner answer before Round 2 draws the screens.

1. ~~**Q1 · Full on expanded tablets.**~~ **Decided 2026-11-13 (ED-252): A, the Workspace, as on Mac and web at the same width; touch version in Round 2 (board E-T1).** Original question: The Workspace (sidebar, Inbox and Routines column, time grid, inspector) as on Mac, or the Today thread with a second pane? ED-171 says expanded windows get "a richer workspace". ED-104 notes that G3-1 does not apply if tablet Full is a grid.
2. ~~**Q2 · Minimal on tablets.**~~ **Decided 2026-11-13 (ED-254): A, by width. Medium and expanded windows get E-Minimal's Day menu; compact windows get the phones' three items (board E-T2).** Original question: The phones' three-item Day menu, or E-Minimal's richer Mac/web menu (register G2-9)? Mockups were on E-T2 (ED-253).
3. **Q3 · Content type on touch tablets** at medium and expanded. The Mac-size wide type, or the phone content size for touch reading distance (rules §3.6)? Mockups on board E-T3 (ED-255): A Mac sizes, B phone content sizes with touch spacing (recommended).
4. **Q4 · Apple Pencil.** ED-171 says "where relevant". Proposed scope: Scribble in text fields only (system), and no drawing or handwriting features. Confirm, or name what Pencil should do.
5. **Q5 · The iPad task editor.** The option D drawing shows the editor beside the day. Under ED-167 it docks only from 1160 (iPad Air landscape 1180 docks; iPad mini 1133 floats). Confirm that the option D drawing applies only where the window allows docking.

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
