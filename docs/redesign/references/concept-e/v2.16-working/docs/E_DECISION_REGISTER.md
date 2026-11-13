# Concept E — decision register

**Status: LEADING CANDIDATE — NOT APPROVED FOR PRODUCTION IMPLEMENTATION.**

| Item | Value |
|---|---|
| Date | 2026-11-04 |
| Version | E v1.1, live canvas `1793768854-76be`; Group 1 answers logged 2026-11-04 against `1793770633-85e7` |
| Boards read | `E-Phones`, `E-PhonesMinimal`, `E-Workspace`, `E-Minimal`, working `E-Map` (section D); archive `references/concept-e/v1.0/E-Focus.dc.html`; decision boards `D1-Settings`, `D2-TaskSurface`, `D3-Duplicates` |
| Docs merged | `E_DESIGN_DECISIONS.md` (ED-001…ED-064 and its "Pending owner answers" table), `E_CONSISTENCY_REPORT.md` v1.1 (CR-001…CR-112 and addendum), `E_DESIGN_RULES.md` §9 and §14, `E_SCREEN_INVENTORY.md`, `FEATURE_PARITY_MATRIX.md`, `OPEN_PRODUCT_DECISIONS.md`, `DESIGN_PRINCIPLES.md`, `PRODUCT_BRIEF.md`, `docs/14-minimal-mode.md` |

**What this is.** The one list of every choice Concept E still needs from the owner. It replaces three overlapping lists: the E-Map's 21 outstanding decisions, the decision log's pending answers, and the consistency report's AWAITING OWNER DECISION and STILL CONFLICTING items that need an owner choice. Duplicates are merged. Small fixes that only need one value picked (for example one bead size) are not decisions: they sit in each group's "Design fixes I can make once the related decision is answered" list.

**What it is not.** It does not approve anything. Approving a visual direction never approves a change to business logic or the removal of a feature. Free/Pro entitlement and pricing are out of scope.

**How the review runs.**
1. One group at a time. **Group 1 is complete** (2026-11-04, ED-065 to ED-073; G1-1 = Option A). **Group 2 is reviewed now, one decision at a time** (ED-074); G2-1 to G2-7 and G2-13 are settled; G2-8 resolved (ED-091); G2-9 resolved (ED-093); G2-10 resolved (ED-095); G2-11 resolved (ED-097); G2-12 resolved (ED-099). **Group 2 is complete** (2026-11-05); its completion summary lists what stays open for feasibility. The mode-switch workflow rule is resolved (ED-100) and its clarifications approved (ED-103). **Group 3 is reviewed now, one decision at a time** (ED-101): corrections are kept apart from new design proposals, each change to an approved screen gets a focused comparison first, and drawings not yet seen by the owner are flagged (ED-102). G3-1 resolved as option C revised and merged into E-Phones Today (ED-104). G3-2 resolved as option A and merged into E-Minimal (ED-106). G2-4, G2-5, G2-6, G2-8, G2-9 and G2-10 get visual comparisons before approval. Groups 3–4 wait until Group 2 is complete and reconciled.
2. Each answer is logged as a new decision-log entry (ED-065 onward). Old entries are never edited.
3. After each group: `E_DESIGN_RULES.md`, the affected boards and the working E-Map are updated together, and this register marks the decisions RESOLVED with the new ED number as evidence.
4. A decision is RESOLVED only with explicit owner approval (a quote and where it was said). A canvas edit approves only that visual change. Deleting a board is not a rejection of the idea unless the intent is clear.

**Status words.** OPEN = no owner answer yet. PARTLY RESOLVED = part is answered (evidence given), part is open. RESOLVED = answered (evidence given).

## Summary

| Group | Decisions | Open | Partly resolved | Resolved | Adopted from board |
|---|---|---|---|---|---|
| 1 · Foundational experience | 5 | 0 | 0 | 5 | 0 |
| 2 · Navigation and workflows | 13 | 0 | 0 | 10 | 3 |
| 3 · Visual and interaction consistency | 12 | 11 | 1 | 0 | 0 |
| 4 · Missing experiences | 7 | 7 | 0 | 0 | 0 |
| **Total** | **37** | **18** | **1** | **15** | **3** |

Counts refreshed 2026-11-05 at the close of Group 2 (ED-099). Adopted from board (ED-077: G2-3, G2-7, G2-13) means no conflict was found and the owner may still override.

Final sign-off, asked once after Group 4 and not counted above: **approve Concept E as the direction** (E-Map D #1). Until then E is a leading candidate only.

## Resolved already (with evidence)

These are settled and are not asked again. Each one settles only what its evidence covers.

| What is settled | Evidence (quote · where) | What it does **not** settle |
|---|---|---|
| `E-Minimal` is E's Mac and web **minimal** layout, replacing `E-Focus` in that role | "I have completed the redesign and replacement of Concept E's Mac and Web Minimal Layout." · owner instruction for v1.1, 2026-11-04 (ED-064); E-Focus removed from the canvas by the owner (ED-062) | The behaviours inside E-Minimal (sidebar kept in minimal, Now as the entry, task screen in the Day column, Inbox row, Earlier fold, ⌘1–4, ⌘K, `/now`). They are still hypotheses (G1-5, G2-6, G2-10, G2-11, G3-12) |
| Removing `E-Focus` replaced it as the wide minimal layout; it did **not** reject Focus | Same statement (ED-064); rules §0 item 3 | Whether E keeps a full wide Focus *presentation* (G1-2). Focus the feature (task Focus action, focus session, Now mini window) stays |
| Phones reach the Inbox through a tab with a count badge; the pull-up Inbox tray and its grab line are gone | "Remove that inbox.3 and line above across the phone platforms" then "go and yes" · thread 0bda86e4, 2026-11-04 (ED-037, ED-038) | Whether minimal phones keep a tab bar at all (G1-5); the "Plan from Inbox · 3" empty-day button (G2-13) |
| iPhone sheets stay solid, edge to edge (no floating glass sheets) | "undo this last edit done from here" · thread b89ef23e, 2026-11-04 (ED-036) | — |
| Phone bottom rows: iPhone + in the tab bar's line (63 pt teal glass, 21 pt from bottom and sides, Day ▾ right); Android revised C (floating frosted toolbar, icon-only +, Day left) | "I am formally approving BOTH new phone bottom-row designs … Do not interpret my Android approval as Option A or B" · 2026-11-06 (ED-124, ED-125) | Native vs drawn glass, the iOS 16–25 fallback, the Flutter build of Android C, N3's hands-on and accessibility checks, tablets (G3-6 open; Prompt D Round 2) |
| Liquid Glass on iPhone chrome; translucent tonal M3 bars on Android, no glass rims | "make it iOS's Liquid Glass across the iPhones …", "do same for Android using the appropriate android features" · thread b89ef23e (ED-034, ED-035) | Native views vs Flutter approximation (G3-6) |
| iPhone keyboard return key reads "Add" in app teal, not "done" in iOS blue | "this should have Add and not done, with the correct color" · thread f55c7d26 (ED-030, ED-031) | Whether the rest of the keyboard goes back to its earlier look, and how the key is built (G3-7) |
| iPhone keyboard: stock keyboard, neutral "return" key adds, no custom key or extra bar; teal Add stays in the field row / nav bar | "C · stock only" · 2026-11-06 (ED-135) | Redrawing keyboards in iOS 26 style; the editor's step keyboard drawing |
| Swipe actions use the app palette, not iOS system colours | "this should be restored back to it's previous color" · thread 9c2e39da (ED-029) | — |
| E's look: C's dot states (done solid, now ring, ahead outline), Manrope content type with teal #11615C, warm surfaces, faint lavender menus, bold lean finish, original Wake Up / Wind Down cap colours; no apricot, halos, glows, solid chips or inset sidebar | Owner requests and "go" replies · threads 453cd3c5, 69ac6f26, ccd0bc55, 9c2e39da, 94195952 (ED-009, ED-012, ED-013, ED-015, ED-017, ED-022; rejections ED-010, ED-014, ED-016, ED-018, ED-023) | The final production content typeface (G3-3); dark mode (G4-6) |
| Large, comfortable scale is applied across E | "is their a way to just have a Large feel?" then "go" · thread 9acf09f2 (ED-025) | Keep large, C confidence, or both (G3-1) |
| One identity, native presentation per platform; layout by width, conventions by platform | `DESIGN_PRINCIPLES.md`, "APPROVED by the owner (2026-11-03)"; ADR RD-0001 | — |
| OS chrome uses system typography; task icons stay one library, chrome icons may follow the platform | `DESIGN_PRINCIPLES.md` §7 K6 and K9, "Decided (owner, 2026-11-03)" | Final glyph mapping (rules §14.1 item 17) |
| Week view wherever the width allows, tablets included | Q5 "Week wherever the width allows, tablets included." · `OPEN_PRODUCT_DECISIONS.md`, owner answers 2026-11-02 | Calendar on phones and the month sheet (G2-1) |
| Concepts may merge duplicate screens, keeping every entry point; concepts decide homes for Brain dump, Routines, Pick one thing, Low-energy, Duplicate/Copy day, This week | Q4 "Concepts may merge duplicates, keeping every current entry point." Q3 "Concepts decide the homes …" · `OPEN_PRODUCT_DECISIONS.md`, 2026-11-02 | Which merges and homes E proposes (G2-8, G2-12). E's proposals are still tagged "Hypothesis · not approved" |
| Overlap-on-add with the knot; no bump on Add | Q2 "Keep overlap-on-add and the knot. No bump on Add." · `OPEN_PRODUCT_DECISIONS.md` | — |

**Not resolved, although a board was deleted (intent unclear):**
- **A-Wide** (thread-only Mac/web with the three-day spread) was deleted by the owner (ED-003). That removes the board. It does not show whether a thread-first wide layout is unwanted. Handled in G1-1.
- **A-Minimal** (an earlier Mac/web minimal) was deleted (ED-002). E-Minimal now fills that role, so nothing is open here.

---

## GROUP 1 · Foundational experience

**Read this first.** These five choices shape every other screen. They are ordered so each answer unlocks the next: first what the big-screen app *is* (G1-1), then how the four "presentations" fit together (G1-2), then where the "Now" view lives (G1-3), how people switch (G1-4), and finally which tabs and sidebar rows each mode shows (G1-5).

**Four words used below.**
- **Standard (full):** the whole app. Today's thread of dots, every feature visible.
- **Minimal:** the calm version of the same app (Show less). Same data, fewer controls. Already built today.
- **Focus:** today, two things share this name. *Focus the feature* is the per-task focus session and the Mac Now mini window. It is staying. *Focus the presentation* was the old E-Focus board: a full big-screen layout with a Now panel, the Day and an inspector.
- **Workspace:** the planning layout from Concept B in E's look: an Inbox column, a time grid (Day / 3 days / Week / Month) and an inspector.

### G1-1 · What the full app looks like on Mac and web

- **Why it matters.** Every Mac and web screen, every shortcut, and the "Show everything" button hang on this answer. Today, Show everything on E-Minimal leads nowhere that is drawn. Today's shipped app opens wide windows on a three-day spread with an Inbox sidebar, and E has nothing in its place.
- **What the latest design shows.**
  - `E-Workspace`: Mac opens on a Week grid (Mon–Thu visible at 1280), web on a Day grid; sidebar Today · Plan · Calendar views · Review · Search; Inbox column; docked inspector; ⌘K palette.
  - `E-Minimal`: the minimal layout only (Now pane + Day column). Its band now says Show everything "Opens E's standard wide layout, which is an owner decision".
  - No thread-first wide board. A-Wide was deleted (intent unclear). E-Focus is archived (v1.0).
- **Options.**
  - **A. Workspace is the full layout.** Big screens open on the planning grid with the Inbox column and the inspector.
  - **B. Thread-first full layout.** Big screens open on Today's thread (the same dots and line as the phone), with a sidebar and a docked inspector. Workspace's grid becomes the Day / 3 days / Week / Month views and the Plan page inside the same window. Nothing from Workspace is lost.
  - **C. Bring back the Focus presentation as the full layout.** Now panel + Day + inspector with the full sidebar (old E-Focus).
  - **D. E-Minimal with everything switched on.** The same Now + Day column layout, with the full sidebar and menus.
- **Recommendation: B.**
  - The product brief says "the timeline is the product" (job 1). Phones open on the thread; B makes the Mac and the web feel like the same app (`DESIGN_PRINCIPLES.md` §2: same intention, same feature, same outcome).
  - It keeps every Workspace feature (grid, drag from Inbox to a day, ⌘K) as views, so no feature is removed.
  - A grid-first start was the weakest for accessibility (B scored 2 of 5 on the Main board) and the E-Map scorecard says two wide shells "split the identity".
  - The 3-day view gives today's three-day spread a home without making it the opening screen (ED-003 asked not to bring the spread back as *the* layout).
  - C and D both put Now first in full mode too, which blurs the difference between full and minimal (see G1-3).
- **What I'd draw next if you pick this.** Mac and web at 1280: sidebar + Today thread with the now card + docked inspector; the same window switched to Week; and the same layout at 960 (Mac minimum window).
- **Consequences.**

  | Platform | What changes |
  |---|---|
  | iPhone | Nothing. Phones already open on the thread |
  | iPad | Landscape and wide windows use the same thread-first layout; portrait gets the medium version |
  | macOS | Opens on Today's thread. Week grid one shortcut away. Workspace board becomes a "Week / Plan" view, not a separate app shape |
  | Android | Phones unchanged; tablets and unfolded foldables follow iPad |
  | Web | Opens on `/today`; the grid lives at the calendar routes (see G2-11) |

- **Affects:** product behaviour (what a wide window opens on) · design · implementation.
- **Owner answer (2026-11-04):** "G1-1 — NEEDS VISUAL COMPARISON. Show me two Full Mac/Web alternatives: A. Preserve E-Workspace as the default Full experience. B. Introduce a timeline-led Full Today experience, with E-Workspace's planning views available within Full." Options C and D are no longer in play: G1-2 removed a wide Focus presentation, and E-Minimal is Minimal only (ED-065).
- **Shown as:** `E-FullA` (option A) and `E-FullB` (option B) on the canvas, same moments, E's look (ED-070). `E-Workspace` and `E-Minimal` unchanged.
- **Owner (2026-11-04, after the first boards):** leaning A, "but I am NOT giving final approval yet". The boards were rebuilt from E-Workspace's own markup (ED-071).
- **Option A v2 (2026-11-04, ED-072):** `E-FullA-v2` makes option A a complete candidate: Day menu with Show Less, Need More Time… wording, a proposed key scheme and a proposed route scheme. Those are proposals for G2-10 and G2-11, which stay open.
- **Owner review (2026-11-04):** "Looks right" on `E-FullA-v2` as the Option A candidate (ED-072). This is not the G1-1 choice.
- **Owner answer (2026-11-04):** "Approve Option A" (ED-073).
- **Status:** RESOLVED · ED-073. Full on Mac and web = Workspace (`E-FullA-v2`). Its proposed keys, routes, Day menu and increments stay open in Group 2.
- **Sources:** E-Map D #2, #4; CR-032, CR-043; ED-003, ED-050, ED-057, ED-064; rules §9.1, §9.4, §14.1 item 15, §14.3 N2; inventory "Owner decision needed — wide Standard layout"; parity matrix "Three-day spread + Inbox sidebar".

### G1-2 · How Standard, Minimal, Focus and Workspace fit together

- **Why it matters.** Four names on the boards suggest four modes. If people must choose between four layouts, the app gets harder to learn and every screen must be drawn four times. The built app has one switch: Show less / Show everything (ADR-0016).
- **What the latest design shows.**
  - Phones: Standard (`E-Phones`) and Minimal (`E-PhonesMinimal`).
  - Mac/web: Minimal (`E-Minimal`) and Workspace (`E-Workspace`). No wide Focus presentation in v1.1.
  - Focus the feature appears as entry points only (phone Focus tile, big-dot tap, E-Minimal Focus button, ⌘F, Now mini window).
- **Options.**
  - **A. Two layouts, one switch.** Minimal and Full. Focus is a feature you can start from either. Workspace is the planning views (Plan, 3 days, Week, Month) inside Full.
  - **B. Three layouts.** Minimal, Full, plus a separate "Planning" layout on big screens that you switch into.
  - **C. Four layouts.** As B, plus the wide Focus presentation (old E-Focus) as a layout you can choose.
- **Recommendation: A.**
  - It matches what is already built and approved: one standing choice, "minimal hides, never removes" (ADR-0016, doc 14 §2).
  - One switch is calmer and easier to find (brief §4: calm, in control).
  - Fewer concepts to learn and to build (CLAUDE.md §10: "pick the one with fewer new concepts").
  - Nothing is removed: Focus sessions, the mini window and every planning view stay.
  - This also answers E-Map #21: no wide Focus *presentation*; Focus stays as a feature.
- **What I'd draw next if you pick this.** A one-page "map of modes": Minimal and Full side by side on phone and on Mac, with arrows showing where Focus and the planning views open from in each.
- **Consequences.**

  | Platform | What changes |
  |---|---|
  | iPhone | No change to the two phone boards; Focus opens from the task sheet and the big now-dot |
  | iPad | Same two layouts; planning views appear when the width allows (Q5) |
  | macOS | Full = G1-1's layout with the Week/Plan views; Minimal = E-Minimal. No third window shape |
  | Android | Same as iPhone; tablets as iPad |
  | Web | Same as Mac; one set of routes per view, not per mode |

- **Affects:** product behaviour (how many modes exist) · design.
- **Owner answer (2026-11-04):** "G1-2 — APPROVED. Two main presentation modes: Full and Minimal. Focus remains a feature available from either mode. Workspace provides advanced planning within Full." Plus: "Do not treat this structural approval as permission to redesign existing boards without review."
- **Status:** RESOLVED (structure) · ED-065. What Full looks like on Mac/web stays with G1-1.
- **Sources:** E-Map D #3, #4, #21; CR-029, CR-032, CR-033; ED-004, ED-005, ED-062, ED-064; rules §9 and §9.5; inventory "Owner decision needed — wide Focus presentation".

### G1-3 · Where "Now" lives

- **Why it matters.** "Now" (one big dot with time left, the day as a flat line above it, and what's next) is E's calmest view and the one ADHD users most need (brief §2). Where it appears decides the phone tabs, the first sidebar row and what opens first.
- **What the latest design shows.**
  - Minimal phones and E-Minimal open on Now. Full phones and E-Workspace have no Now; the live task shows as the now card on the thread.
  - E-Minimal also draws a Mac menu-bar status item (live ring, "18 min") and a Now mini window (⌥⌘0). Whether full mode keeps them is not drawn.
  - Tapping the big now-dot starts Focus (doc 14 already says "tap the live dot" for Focus).
- **Options.**
  - **A. Now leads in Minimal only.** In Full, the live task is the now card on the thread. The Mac status item and Now mini window work in both modes.
  - **B. Now everywhere.** A Now tab on phones in Full too, and Now as the first sidebar row on big screens in both modes.
  - **C. A Now strip in Full on big screens only.** A slim Now bar above the thread on Mac/web; phones unchanged.
- **Recommendation: A.**
  - The boards already agree on it (CR-031 is resolved this way).
  - It keeps Full and Minimal meaningfully different: Full shows the whole day, Minimal shows what to do now.
  - B makes five phone tabs, which D1 warns against (tab-bar crowding).
  - In Full, "know what's next" is already served by the now card and the now-bead on the thread (brief §3 job 1).
  - The status item and mini window are system surfaces, not layouts, so they belong to both modes (doc 14 row A1 keeps "the menu-bar dot" in minimal). Both still need a feasibility check (new window type).
- **What I'd draw next if you pick this.** The Mac Full layout with the status item and mini window open over it; and the Now view's missing states (morning, evening, running over, nothing on now).
- **Consequences.**

  | Platform | What changes |
  |---|---|
  | iPhone | No new tab. Now stays the first minimal tab |
  | iPad | Same as iPhone by mode |
  | macOS | Status item and Now mini window in both modes (after a feasibility check) |
  | Android | Same as iPhone; the ongoing notification carries Now in both modes |
  | Web | `/now` exists in Minimal only; Full opens on `/today` |

- **Affects:** product behaviour (where Now appears) · design · implementation (mini window feasibility).
- **Owner answer (2026-11-04):** "G1-3 — APPROVED. Now leads in Minimal. Full shows the current task on the Today timeline rather than requiring a separate Now destination. Keep Focus accessible, and mark the proposed Mac mini window and status item for feasibility verification."
- **Status:** RESOLVED · ED-066. The Mac Now mini window and menu-bar status item are NEEDS VERIFICATION (feasibility), not approved as drawn. The web `/now` route in the consequences table is not decided (G2-11).
- **Sources:** E-Map D #5, #16; CR-031, CR-042, CR-097; ED-051, ED-055 (tap-to-Focus); rules §9.3; inventory §3 "Full-mode Now on phones"; doc 14 §3 rows A1, A3.

### G1-4 · How people switch between Minimal and Full

- **Why it matters.** If the switch moves around, people get stuck in one mode. Doc 14 promises "the exit is always in the same place". The boards currently put it in three different places.
- **What the latest design shows.**
  - Phones: Day menu (Show less in Full, Show everything in Minimal).
  - Mac (E-Minimal): View › Show Less / Show Everything, and the Everything else finder. Not in E-Minimal's own Day menu.
  - Web (E-Minimal): the finder, or Settings.
  - Built today: Settings row 1 and the Today header menu. The choice is one setting per account, so it is the same on every device (doc 14 §6).
- **Options.**
  - **A. Same two places everywhere, plus native extras.** Always in the Day menu and as the first Settings row. Mac also has View › Show Less / Show Everything; Mac and web also find it in ⌘K. Switching keeps you on the same day and the same open task.
  - **B. Each platform its own place, as drawn now.**
  - **C. An always-visible toggle** in the header or sidebar.
- **Recommendation: A.**
  - It keeps doc 14's promise ("Show everything sits in the Today header menu and as the first row of Settings") and D3's "keep entries (owner-mandated)".
  - Extra native routes are allowed by the design principles; they add a way in, never move the main one.
  - C puts a permanent control on the calm screen, against doc 14 rule 2 (three verbs on screen).
  - Keep the switch as built: one choice per account. Changing that would be a business-logic change, so it is not proposed here.
- **What I'd draw next if you pick this.** The Day menu open on each platform in both modes, the first Settings row, and one before/after pair showing the same day and task staying in place across the switch.
- **Consequences.**

  | Platform | What changes |
  |---|---|
  | iPhone | Already in the Day menu; Settings row 1 still to draw |
  | iPad | Same as iPhone, plus the hardware-keyboard menu |
  | macOS | Show Everything added to E-Minimal's Day menu; View menu stays |
  | Android | Same as iPhone |
  | Web | Added to the web Day menu popover (not drawn yet) and Settings row 1 |

- **Affects:** design (placement) · product behaviour only if you choose C.
- **Owner answer (2026-11-04):** "G1-4 — APPROVED. The Full/Minimal switch should remain accessible through the Day menu and the first Settings row, with platform-appropriate native access such as the Mac View menu. Preserve the current task, selected day and relevant navigation state when switching."
- **Status:** RESOLVED · ED-067. ⌘K and any switch shortcut belong to G2-10.
- **Sources:** CR-041; E-Minimal band; doc 14 §2 rule 6, §5 "Where the switch lives", §6 "The flag"; D3 "Layout (full / minimal)"; rules §9.2.

### G1-5 · Tabs and sidebar rows: one set per mode, on phones and big screens

- **Why it matters.** Right now each board has its own list of places, with different names and orders. Moving from phone to Mac, or from Minimal to Full, changes almost everything you see. It also decides the ⌘1–4 shortcuts.
- **What the latest design shows.**
  - Full phones: Today · Inbox · Calendar · Search.
  - Minimal phones: Now · Today · Inbox (a tab bar; doc 14 says minimal has no tab bar and shows the Inbox as a "Later" row).
  - E-Minimal (wide minimal): Now · Inbox · Calendar · Search, with the Day as a side column; web adds Everything else and Settings. Doc 14 says expanded minimal shows Today alone, no sidebar.
  - E-Workspace: Today · Plan (Inbox, Routines, Brain dump) · Calendar views · Review · Search, plus a "Lists" sketch.
  - "Today" on phones and E-Workspace; "Day" on E-Minimal.
- **Options.**
  - **A. One set per mode, the same on every width.** Big screens may add rows below a divider but never rename or reorder.
    - Full: Today · Inbox · Calendar · Search. Wide adds Plan, Routines and Review below the divider (G2-2).
    - Minimal: Now · Today · Inbox. Calendar and Search move into Everything else (hidden, not removed), as on phones. On wide, Today is the right column and its row shows or focuses it.
    - ⌘1–4 follow the visible order (G2-10).
  - **B. Keep each board's own set** as drawn.
  - **C. Follow doc 14 exactly.** Minimal has no tab bar on phones and no sidebar on wide; the Inbox is a "Later (3)" row at the end of the thread.
- **Recommendation: A.**
  - The same intention should reach the same place on every device (`DESIGN_PRINCIPLES.md` §2). B leaves two wide sidebars that "share almost nothing" (CR-043).
  - Minimal needs a way between Now and Today; a small three-item bar does that. Your own boards draw it on phones and on wide.
  - Moving Calendar and Search out of the wide minimal sidebar matches phones and doc 14 (Search is hidden in minimal), and nothing is lost.
  - A changes three doc 14 §3 rows ("Navigation bar / rail", "Inbox", "Mac/web spread"). That is a change to an adopted rule (ADR-0016), so it needs your yes. C keeps doc 14 untouched but drops the Now / Today split your minimal boards are built on.
  - One name: "Today" for the place, "Day" only for the Day menu (also G3-10).
- **What I'd draw next if you pick this.** The four navigation shells side by side (phone Full, phone Minimal, wide Full, wide Minimal) with the same names and order, plus the iPad and Android tablet rail versions.
- **Consequences.**

  | Platform | What changes |
  |---|---|
  | iPhone | Full unchanged. Minimal tab bar kept as Now · Today · Inbox |
  | iPad | Sidebar or tab bar with the same items per mode (shell chosen in G4-4) |
  | macOS | E-Minimal sidebar becomes Now · Today · Inbox; E-Workspace's sidebar is redrawn as the Full set + divider |
  | Android | NavigationBar mirrors iPhone; rail on tablets with the same items |
  | Web | Same as Mac; routes follow the same names (G2-11) |

- **Affects:** product behaviour (minimal navigation differs from doc 14) · design · implementation.
- **Owner answer (2026-11-04):** "G1-5 — APPROVE THE EXISTING MINIMAL NAVIGATION PATTERNS, NOT OPTION A." Minimal phones keep Now · Today · Inbox in the bottom navigation; Minimal Mac and web keep Now · Inbox · Calendar · Search in the sidebar, with the Day timeline in its own column. "These are deliberate platform/viewport adaptations, not missing designs." Do not replace the wide sidebar, move Calendar and Search out of it, or remove the phone Minimal tab bar for uniformity. "For G1-5's Full navigation, keep the current phone design and defer the final wide sidebar arrangement until G1-1 is resolved." Shortcuts and web routes are not decided here.
- **Recommendation A above: not accepted.** The text above is kept as it was presented.
- **Status:**
  - Minimal (phones and wide): RESOLVED · ED-068. Supersedes doc 14 §3 / ADR-0016 minimal-navigation assumptions for the redesign branch only; neither is edited.
  - Full phones: RESOLVED · ED-069 (current `E-Phones` tab bar kept).
  - Full Mac/web sidebar: RESOLVED · ED-073 (E-Workspace's sidebar, as on `E-FullA-v2`); which extra rows stay is G2-2.
  - Shortcuts (⌘1–4) and routes: moved to G2-10 and G2-11.
- **Sources:** E-Map D #4, #6; CR-034, CR-036, CR-037, CR-043, CR-044, CR-045, CR-050; ED-038, ED-055; rules §8.1, §14.2 I24, §14.3 N3, N4, N7; doc 14 §3.

### Design fixes I can make once Group 1 is answered

*Updated 2026-11-04.* None of these are made yet: the owner asked that existing boards are not redesigned without review. They wait until G1-1 is chosen and are then shown for review.

- E-Minimal band: point Show everything at the layout chosen in G1-1 (CR-032, N2).
- E-Workspace header still calls A's thread-only board "the candidate minimal look" (ED-057, CR-006).
- E-Phones header says "dots with depth"; dots are flat (CR-006, I28).
- E-Minimal web "Day ▾" in the Day column header reads as a view switcher in minimal; make it the Day menu button (N15).
- E-Minimal splits 1280 differently on Mac (Now 790 + Day 290) and web (Now 560 + Day 510); align them by width (CR-093). *Ask first: ED-068 keeps E-Minimal's navigation as designed; this is a layout proportion only.*
- Draw what ⌘2 / the Today row does when the Day column is hidden or a task is open (N6, CR-092).
- `E-Map-v1.0` stays frozen as history; only the working E-Map follows the answers (ED-056; CR-109 resolved).
- The old E-Focus intro and orb naming need no change: the board is archived (ED-058). Rules call it "the orb" or "large now-dot" consistently (ED-059).

---

## GROUP 2 · Navigation and workflows

Reviewed after Group 1. **Re-baselined 2026-11-04 from the boards (ED-076, ED-077).**

| Decision | Status |
|---|---|
| G2-1 Calendar | RESOLVED (ED-075); screens on `E-PhonesCalendar` for review |
| G2-2 extra Full sidebar rows | RESOLVED (ED-080): rows kept, Lists removed, Routines page |
| G2-3 Settings entry | RESOLVED · option A (ED-238); was adopted from board (ED-077) |
| G2-7 Move picker | ADOPTED FROM BOARD (ED-077); iOS, Android and Mac/web pickers drawn as the one When picker (ED-099) |
| G2-13 Plan from Inbox on the empty day | ADOPTED FROM BOARD (ED-077) |
| G2-4 Settings | RESOLVED and merged (ED-081 to ED-084) |
| G2-5 Task editor | RESOLVED and merged (ED-086, ED-087): option D |
| G2-6 Minimal task screen | RESOLVED and merged (ED-088, ED-089) |
| G2-8 Add modes | RESOLVED and merged (ED-090, ED-091): option A |
| G2-9 Day menu | RESOLVED and merged (ED-092, ED-093): option B |
| G2-10 Keyboard | RESOLVED and merged (ED-094, ED-095): option B, reconciled with the built app |
| G2-11 Web routes | RESOLVED and merged (ED-096, ED-097): option A′, D4 reconciled per layout |
| G2-12 Duplicate screens | RESOLVED and merged (ED-098, ED-099): option A |
| Mode switch mid-action (workflow) | RESOLVED (ED-100): cancel drag / selection, keep date, task, saved edits, Undo and drafts |
| G3-1 Scale direction | RESOLVED and merged (ED-104): option C · Both, revised; Full phone Today only |
| Dimmed Today copies under sheets on E-Phones (6) | RESOLVED and merged (ED-108): G3-1 now card |
| Flagged E-Minimal drawings (Day review column, web Day menu) | RESOLVED and merged (ED-108): Week in review row removed; key hints added; flags cleared |
| G3-3 Content typeface | RESOLVED (ED-110): option A · Manrope for content, system chrome; no board changed |
| G3-2 One orb drawing | RESOLVED and merged (ED-106): option A; E-Minimal Mac and web orbs |
| G3-4 iOS switch colour | RESOLVED (ED-112): option A · teal; 8 iOS switches as drawn; no board changed · design verification PASS (ED-117) · Flutter NOT YET IMPLEMENTED / VERIFIED (3 known gaps) · dark mode PENDING G4-6 |
| G3-5 Hover lift on a web block | RESOLVED and merged (ED-116): option C · Hybrid; Lunch on E-FullA-v2; shared rule in rules §7.4; motion open |
| G3-6 Glass and vibrancy | **RESOLVED (ED-133)** as a design and selected architecture direction: rows ED-124/125/126 + Minimal exception ED-132; D1 N3, D2 F2 (18.6 Simulator PASS; 16/17 PENDING), D3 native Day menu, D4 Flutter chrome, D5 Android C in Flutter, D6 Mac native vibrancy + 35 % tint (ED-130). Implementation tests PENDING (handoff checklist); production implementation not authorised |
| G3-6 follow-up · iPhone bottom row (+ in the bar's line, Day moved) | **APPROVED (ED-124)** · Full and Minimal; proposal ED-122 on `E-G3-6-BottomRow`; merged into E-Phones and E-PhonesMinimal (ED-126); N3's hands-on and accessibility checks not approved, still open |
| G3-6 follow-up · Android bottom row (+ only) | **APPROVED (ED-125): revised option C** (floating frosted toolbar, icon-only +, Day left), not A or B; proposal ED-123 on `E-G3-6-Android`; merged (ED-126); custom Material-inspired arrangement |
| G3-C1 Task text in system font inside phone sheets | OPEN · direction agreed (ED-112); comparison drawn (ED-203); **CLOSED (ED-204): Android task text in Manrope (600 20 input, 700 24/30 title)** |
| A11Y-V1 Bold Text weights · A11Y-V2 two-line Calendar rows at large text | PROPOSED · for accessibility verification; no approved layout changed (ED-112) |
| Today opens scrolled to now (found in G3-1 checks) | OPEN · not drawn; compact phones open with the current task under the floating controls (ED-103) |

**Refreshed 2026-11-04 against the Group 1 answers** (ED-065 to ED-073):
- Full on Mac and web is the Workspace (`E-FullA-v2`).
- Minimal navigation is kept as drawn.
- Focus is a feature.
- The switch lives in the Day menu and Settings row 1.

G1-5's option A is no longer assumed anywhere. G2-2, G2-7, G2-9, G2-10 and G2-11 were rewritten to match. This register is a working list, so the rewrite is noted here; the decision log (`E_DESIGN_DECISIONS.md`) is never edited. Each one ends with the line "Refreshed after Group 1".

### Sidebar and tab destinations

#### G2-1 · What the phone Calendar tab shows, and how Month is reached
- **Why it matters.**
  - Jumping to a far date takes several steps today.
  - The built app reaches Month two ways: the `/month` screen and a pull-open month peek on Today. D3 left this as your call.
  - E-Phones adds a Calendar tab and a "Tue 3 Nov ▾" title that opens a month sheet. That makes three month surfaces unless they share one grid.
- **What is already settled.**
  - Full phones keep E-Phones' tab bar (ED-069): Today · Inbox · Calendar · Search. So the Calendar tab exists. This decision is only about what it shows and how Month is reached.
  - Week is shown wherever the width allows (Q5).
  - Full on Mac and web is the Workspace, so the grid views there are settled (ED-073).
- **What the design shows.**
  - `E-Phones` F1 and F5 have the Calendar tab, but **no Calendar screen is drawn**.
  - Inset 4: the title ▾ opens a month sheet ("go to a date in 2 taps").
  - The Android M3 date picker is not drawn.
  - `E-PhonesMinimal` hides Calendar. Its band puts Month, Week and Go to date under Everything else.
- **Built today (checked in code).**
  - Phone tabs: Today · Inbox · Search · Settings. Week is a tab only at expanded width.
  - Month: the `/month` screen and the pull-open peek on Today, both drawn with the shared `MonthGrid`.
- **Options.**
  - **A. One month grid, three ways in.**
    - The Calendar tab opens Month.
    - The title ▾ opens the same month as a sheet for quick jumps.
    - The built pull-open peek on Today stays.
    - Tablets and wide windows add Week.
  - **B. Two ways in.**
    - The Calendar tab opens Month, and the title ▾ sheet stays.
    - The pull-open peek is removed, because the title sheet does the same job.
  - **C. The Calendar tab opens a Week / agenda list.** Month is reached only from the title ▾ sheet.
- **Recommendation: A.**
  - Q4 says merges keep every entry point. The peek is a built entry point, so removing it (B) would remove one.
  - One shared `MonthGrid` means the three surfaces cannot drift apart.
  - C hides Month one level deeper and needs a new agenda design.
- **Consequences.**

  | Platform | What changes |
  |---|---|
  | iPhone | The Calendar tab opens Month (screen still to draw). The title ▾ opens the month sheet (drawn, inset 4). The peek stays as built |
  | Android | The same; the M3 date picker for Go to date is still to draw |
  | iPad, Android tablet | Calendar in the sidebar or rail, with Month and Week |
  | Mac, web | No change: the Workspace views (Day / 3 days / Week / Month) are settled by G1-1 |
  | Minimal | No change: Calendar stays hidden, reached through Everything else (ED-068) |

- **Board changes if approved:** add one iPhone and one Android Calendar (Month) frame to `E-Phones`, shown to you first. The existing frames are not altered.
- **Affects:** design · product (which month surfaces exist).
- **Owner answer (2026-11-04):** "For G2-1, I choose Option A", with the keep-list in ED-075.
- **Status:** RESOLVED · ED-075. Calendar screens drawn for review on `E-PhonesCalendar`.
- **Sources:** E-Map D #10; ED-047, ED-069, ED-073; D3 Month row; CR-050, CR-082; Q4, Q5; `app_shell.dart`, `month_screen.dart`, `today_month.dart`, `shared/dot/month_grid.dart`.

#### G2-2 · Extra Full sidebar rows on Mac and web: Plan, Routines, Brain dump, Review, "Lists"
- **Why it matters.** G1-1 made E-Workspace's sidebar the Full wide sidebar. Some of its rows are features in parity; "Lists" is not.
- **Design shows.**
  - **`E-FullA-v2` / `E-Workspace` sidebar:** Today · Plan (Inbox, Routines, Brain dump) · Calendar views (Day, 3 days, Week, Month) · Review · Search, plus a dashed "Lists (future, not part of this release)" sketch.
  - **`E-Minimal`:** reaches Routines and Reviews through View and the ⌘K finder.
- **Options.**
  - **A.** Keep the rows as drawn. Remove the "Lists" sketch. Give Routines its own page (`/settings/routines` today opens inside Settings).
  - **B.** As A, but keep "Lists" as a labelled future sketch.
  - **C.** Fewer rows: drop Plan's sub-rows and reach Routines and Brain dump from the Inbox column and the Day menu only.
- **Recommendation: A.**
  - "Lists" is outside parity (brief §9: no projects or tags; Q6), so drawing it suggests a feature that isn't coming.
  - Routines and Brain dump keep their first-level entries (Q3).
  - One "Review" name follows G3-10.
- **Consequences.**
  - iPhone, Android phones: none; these stay in the Day menu and Add.
  - iPad, Android tablets: the same rows when the width allows.
  - macOS, web: `E-FullA-v2` sidebar minus "Lists".
- **Affects:** design · product (Lists).
- **Correction (ED-077):** the owner's Q6 answer explicitly allows a labelled future sketch of project-style grouping, so removing "Lists" (recommendation A above) is not needed. The board is kept as drawn, and Lists stays outside the implementation spec.
- **Owner answer (2026-11-04):** recommendation A accepted: keep the rows, remove Lists, Routines gets its own page (ED-080).
- **Status:** RESOLVED · ED-080.
- **Sources:** ED-050, ED-073; CR-046, CR-049, CR-084; D3 Routines and "This week" rows.

### Settings placement

#### G2-3 · Where Settings opens
- **Why it matters.** Owner problem P1 (Settings busy). Taking Settings out of the tab bar keeps four phone tabs.
- **Design shows.** Avatar on phones; Dottoday › Settings… ⌘, in its own window on Mac; sidebar footer and `/settings` on web. Consistent on every v1.1 board (CR-047), tagged Hypothesis.
- **Options.** A. Native secondary place on every platform (D1 Option 2). B. Settings tab on phones, native place on Mac/iPad/tablets/web (D1's owner-call variant). C. Settings tab everywhere (today's app).
- **Recommendation: A.** Platform conventions (⌘, window is the Mac standard), keeps four tabs, and makes Full match Minimal (doc 14 already puts Settings in the header menu).
- **Consequences.**
  - iPhone: avatar in the top capsule.
  - iPad: sidebar footer.
  - macOS: ⌘, window.
  - Android: avatar in the top app bar.
  - Web: sidebar footer, `/settings`.
- **Affects:** design (entry point move; every entry still reaches Settings).
- **Status:** RESOLVED 2026-11-13, option A (ED-238). Settings pages keep the platform bar with no tab selected (ED-234, ED-235). Not built.
- **Status:** ADOPTED FROM BOARD · ED-077 (no conflict found; owner may override). Previous status line: OPEN.
- **Sources:** E-Map D #7; ED-043; D1; CR-033, CR-047.

#### G2-4 · Settings regrouped into six jobs, and what "Everything else" opens
- **Why it matters.** Today Settings has 43–47 rows in 9 sections (D1). "Everything else" means three different things on the boards.
- **Design shows.** D1's six groups (reference only; no Settings screen drawn in E). Phone minimal: Everything else is a Settings row. E-Minimal: a ⌘K finder of actions, places and tasks.
- **Options.** A. Six groups (D1); minimal Settings keeps its nine rows and its Everything else row opens the real root (D3); the wide ⌘K finder is renamed and treated as search + actions (G2-10). B. Keep today's Settings sections; only the entry moves. C. Six groups, and Everything else becomes the finder on every platform.
- **Recommendation: A.** One Settings tree avoids two copies drifting (D3); the finder is a different job (find and do) and should not share the name.
- **Consequences.**
  - iPhone: regrouped root; Everything else opens it.
  - iPad: two-pane Settings.
  - macOS: Settings window with six panes.
  - Android: regrouped root.
  - Web: `/settings/<group>`.
- **Affects:** design · implementation.
- **Owner answer (2026-11-04):** "Accept A + A" (ED-081).
- **Status:** RESOLVED · ED-081, ED-082, ED-083, ED-084 (direction, iPhone icons, Wake Up and Wind Down, one alarm device). Merged into the E boards.
- **Sources:** E-Map D #9 (part); ED-048; D1; D3 "Minimal Everything else"; CR-040, CR-048; N7.

### Task viewing and editing

#### G2-5 · One task surface, autosave or Save
- **Why it matters.** Today a task opens in up to three different editors. On the boards it opens three ways (phone sheet, docked inspector, task screen in the Day column).
- **Design shows.** Phones: sheet at medium detent, "Pull up to edit" (large detent not drawn). E-Workspace: docked inspector. E-Minimal: task screen replacing the Day column.
- **Options.** A. One surface that grows from summary to full editor, autosave + Undo (D2 Option 2). B. One surface with explicit Done (commit) and Cancel. C. Keep today's chain (sheet → editor → Save, plus `/task/:id` and the wide panel).
- **Recommendation: A.** Fewer steps (brief job 2/3), every entry and deep link kept (D2). The minimal wide task screen is the same surface in the right column. Autosave relies on Undo (CLAUDE.md §4 never-lose-data).
- **Consequences.**
  - iPhone: medium → large detent.
  - iPad: popover from the dot; inspector when wide.
  - macOS: inspector (minimal: the right column).
  - Android: M3 bottom sheet → full screen; Back steps down.
  - Web: inspector + `?task=`; `/task/:id` full page at narrow widths.
- **Affects:** product behaviour (save model) · design · implementation.
- **Also decide here (ED-078):** does a Full/Minimal switch cancel a multi-selection or a drag in progress? Undo would still work.
- **Re-baselined 2026-11-04 (ED-076):**
  - The built editor already autosaves (`DraftAutosave`, doc 03 §3.4) and also shows Cancel and Save (`editor_footer.dart`).
  - The boards already draw one surface: the sheet grows to the full editor on phones, the inspector has no Save, and the task opens in the Day column in wide Minimal.
  - The remaining choice is Done (A, recommended) or Cancel / Save (B), plus the switch rule.
  - Decision board: `E-G2-5`.
- **Option C added 2026-11-04 (owner request):** Decision 2's proposed frame "3 · Large detent = the full editor", rebuilt in Concept E.
  - Board: `E-G2-5-FullEditor`.
  - The E-Phones task sheet grows in place. The header, overlap line, action tiles and Need more time? stay on top, and every field follows in one scroll. Done closes; edits save as built.
  - Also drawn: a repeating-task prompt (asked once per open), large text, an Android full screen, and the Mac/web inspector.
  - Options A and B stay on `E-G2-5`.
- **Option D added 2026-11-04 (ED-085):** `E-G2-5-OptionD-RefinedEditor` is exploratory. The task dot opens the colour and icon picker; date, time and alerts sit in one card with Repeat and Energy pills; steps and notes are edited in place; a full scope chooser handles repeating tasks; there's a Create task variant; Android, iPad and Mac/web versions are drawn.
- **Owner answer (2026-11-04):** "Approve option D" (ED-086).
- **Status:** RESOLVED · ED-086. The switch rule for selections and drags moves to G2-11.
- **Sources:** E-Map D #8; ED-044, ED-064 (task screen in column); D2; CR-070, CR-073, CR-074; D3 "Task detail".

#### G2-6 · What the minimal task screen offers
- **Why it matters.** Doc 14 fixes minimal's task sheet as Done · Tomorrow · Later · Delete (Move under More). E-Minimal shows Starts, Duration, Tomorrow / Later / Move… and More, with no Done or Delete, and offers Tomorrow for the task running now.
- **Design shows.** `E-Minimal` task inset (Mac); web described only.
- **Options.** A. Doc 14's set on every platform: title, time, duration, Done · Tomorrow · Later · Delete, More. B. E-Minimal's set (no Done/Delete). C. Doc 14's set plus Move as a fifth button.
- **Recommendation: A.** It is the adopted rule, keeps Done one tap away (doc 14 rule 2) and drops nothing; Move stays under More.
- **Consequences.**
  - iPhone: minimal sheet with four buttons (still to draw).
  - iPad: same in the popover.
  - macOS: E-Minimal task screen gains Done and Delete.
  - Android: same as iPhone.
  - Web: same as Mac.
- **Affects:** design.
- **Re-baselined 2026-11-04:**
  - The built minimal sheet (`task_sheet.dart`) matches doc 14: Done · Tomorrow · Later · Delete, with More options opening the full editor.
  - E-PhonesMinimal draws no task sheet.
  - E-Minimal's Day-column screen has no Done or Delete and adds Move….
  - Decision board `E-G2-6`: options A (built set in option D's look, plus Need more time? for the running task), B (E-Minimal as drawn) and C (A plus Move…).
- **Owner answer (2026-11-04):** option A behaviour (ED-088). Drawings on `E-G2-6-Review` approved and merged into `E-PhonesMinimal` and `E-Minimal` (ED-089).
- **Status:** RESOLVED · ED-088, ED-089.
- **Sources:** CR-071, CR-072; N17; ED-064; doc 14 §3 "Task sheet", §4.

#### G2-7 · Move opens a day-and-time picker
- **Why it matters.** The Move tile on the task sheet is reported dead (parity matrix; PROMPT_D notes it may be wired; re-check). Move is also the screen-reader route for drag.
- **Design shows.** Android M3 dial picker (`E-Phones` F6). iOS picker and Mac/web picker not drawn.
- **Options.** A. Move opens one picker (day + time) on every platform; also "Move to…" for screen readers. B. Move only changes the day (Tomorrow / Later / pick day). C. Keep drag only.
- **Recommendation: A.** Every gesture needs a non-gesture route (rules §13 item 9; R-04, R-12).
- **Consequences.**
  - iPhone: native wheels or a compact date picker sheet.
  - iPad: popover picker.
  - macOS: popover with date and time fields; Move To… (`E-FullA-v2` proposes ⇧⌘M, because ⌘M is Minimize; G2-10).
  - Android: M3 time picker with Change day.
  - Web: popover; `m` key.
- **Affects:** product behaviour (Move works) · design.
- **Status:** ADOPTED FROM BOARD · ED-077 (no conflict found; owner may override). Previous status line: OPEN.
- **Drawn 2026-11-05 (ED-099):** the picker is the G2-12 When picker: iPhone and Android sheets on `E-Phones`, the Mac/web popover on `E-FullA-v2`; Move To… ⇧⌘M and web `m` open it. Status unchanged.
- **Sources:** ED-049; CR-074; parity matrix; PROMPT_D_ROUND1 "Move tile discrepancy".

#### G2-8 · Brain dump and Routine as modes of Add
- **Why it matters.** Owner problem P3: Brain dump and Routines are buried. Q3 asked for a first-level entry.
- **Design shows.** iPhone Add with a segmented Task · Brain dump · Routine; Android FAB menu; Mac ⇧⌘N.
- **Options.** A. Both are Add modes (hold + on iPhone, FAB menu on Android, ⇧⌘N / menu on Mac and web) and both go through the proposal sheet. B. Keep them in the Day menu only. C. Add modes on phones; sidebar rows only on wide.
- **Recommendation: A.** One tap from Add meets the Q3 constraint; the proposal rule keeps nothing written before Accept. Routines also keeps its own page (G2-2).
- **Consequences.**
  - iPhone: segmented control + hold menu.
  - iPad: same; keyboard shortcut.
  - macOS: ⇧⌘N, File menu.
  - Android: M3 FAB menu.
  - Web: Add menu; key shortcut.
- **Affects:** design.
- **Re-baselined 2026-11-04 (ED-090):**
  - **Built today:** Brain dump is in Today's ⋯ menu (M12.5) and opens a sheet (one thing per line, mic, Today / Tomorrow, Plan it, Earlier dumps). Routines… is in ⋯, and ROUTINES chips sit under Add's suggestions (M11.4). Both open the one ProposalSheet; nothing is written before Accept.
  - **E boards:** E-Phones F2 draws Add with Task · Brain dump · Routine, and an Android FAB menu, but not the Brain dump or Routine screens. E-Minimal and E-FullA-v2 list Brain Dump… ⇧⌘N and Drop a routine in their menus. E-PhonesMinimal has no modes (several lines → Brain dump; Routines hidden, doc 14).
  - **Decision board `E-G2-8`:** A (modes of Add; new drawings A2 Brain dump mode, A3 Routine mode, A4 proposal, A6 Android Brain dump sheet; Mac File menu and web Add ▾ proposed), B (Day menu only, as built), C (phones only; described). Minimal unchanged in every option.
- **Tablet implications (recorded, not drawn):**
  - **iPad:** Add is a popover from + at medium and wide widths (built), with the segmented control at its top; hold on + and ⇧⌘N with a keyboard; pointer hover on the segments; the proposal opens beside the day in landscape; Slide Over and narrow Split View fall back to the phone sheet.
  - **Android tablets and foldables:** the FAB sits in the navigation rail at medium/expanded and its menu opens beside the rail; Brain dump and Routine open as a side sheet in expanded, a bottom sheet in compact; folding keeps the draft (it is already in local history); Ctrl+Shift+N.
  - **Unverified:** the proposal's placement in two panes; the M3 FAB menu in a rail; dictation on tablets. **Round 2:** draw these in the tablet checklist pass.
- **Owner answer (2026-11-04):** "I approve G2-8 Option A", including the designs on E-G2-8; keys stay with G2-10 (ED-091).
- **Status:** RESOLVED and merged · ED-091.
- **Sources:** E-Map D #11; ED-045; Q3; CR-057, CR-075, CR-083.

### Day menus and contextual actions

#### G2-9 · The Day menu: one grouped menu, contents per mode, Replan inside it
- **Why it matters.** The boards have four Day menus:
  - phones: Replan · Plan · Reflect · View · Share;
  - E-Workspace: a Mac menu with Running Late plus a separate Replan button;
  - E-Minimal: a long Mac menu;
  - `E-FullA-v2`: a proposal.
  G1-4 requires Show Less / Show everything in it. Doc 14 caps minimal's header menu at three items.
- **Design shows.**
  - **`E-FullA-v2`**, Full Mac and web, drawn with disabled states on an empty day:
    - Time: Need More Time ▸ (+5 / +15 / +30, then Shift the Rest), Shift the Rest From Here…, Rebalance…
    - Plan: Brain Dump…, Routines…, Pick Today's One Thing…
    - Day: Duplicate Day…, Copy Day as Text, Review the Day, This Week
    - Layout: Low-Energy Mode, Show Less
  - **Phones (`E-Phones`):** five groups. **Minimal phones:** Show everything and Low-energy day.
  - **`E-Minimal`:** Need More Time…, Shift the Rest, Brain Dump…, Drop a Routine, Duplicate Day, Copy Day as Text, Review the Day, Gentle Day.
- **Options.**
  - **A. One Full menu everywhere, one Minimal menu everywhere.**
    - Full uses `E-FullA-v2`'s four groups on every platform; phones get the same groups in their native menu.
    - Replan's actions live in the Time group, with no separate Replan button.
    - Minimal uses doc 14's three items: Show everything · Low-energy · Settings. Need more time stays on the Now view.
  - **B.** As A for Full, but wide Minimal keeps E-Minimal's longer menu.
  - **C.** Keep a separate Replan button next to the Day menu in Full on Mac and web.
- **Recommendation: A.**
  - One grouped menu fixes owner problem P3.
  - Minimal keeps doc 14's calm promise, and Show Less / Show everything is always in it (G1-4).
  - C keeps two buttons for one job.
- **Also to approve with this:**
  - one increment set, +5 / +15 / +30, everywhere (as built);
  - "Need More Time" behaving like the built Running late (extend now, move the rest).
- **Consequences.**
  - iPhone: pull-down with the four groups; minimal three items.
  - iPad: the same, plus the hardware-keyboard menu.
  - macOS: Day menu in the menu bar and the toolbar Day ▾ (drawn on `E-FullA-v2`).
  - Android: M3 menu.
  - Web: popover (drawn on `E-FullA-v2`).
  - E-Minimal's own menu would be trimmed; that needs your review, because E-Minimal is your design.
- **Affects:** product behaviour (increments, Replan) · design.
- **Re-baselined 2026-11-04 (ED-092):**
  - **Built:** Full ⋯ has Show less, Running late… (+5 / +15 / +30, then shift the rest), Review the day, This week, Duplicate day…, Copy day as text, Routines…, Brain dump, Pick today's one thing…, Low-energy mode; the Mac/web spread has a separate Running late button. Minimal has Show everything · Low-energy mode · Settings. Plan / Reality is a header toggle; Rebalance is a prompt.
  - **E-Minimal's Day menu** (menu bar, column Day button, web) is the owner's design: Need More Time…, Shift the Rest, Brain Dump…, Drop a Routine, Duplicate Day, Copy Day as Text, Review the Day, Gentle Day. Its band says minimal hides, never removes.
  - **Board `E-G2-9`:** Full unified on E-FullA-v2's four groups (A and B); minimal phones unchanged; wide minimal A (trim) or B (keep, recommended, ED-076); C described.
  - **Names:** Low-energy mode (built) replaces Low-energy day and Gentle Day; Drop a routine… in the menu.
- **Tablet implications (recorded, not drawn):** iPad uses the Day ▾ pull-down at every width and shows the same groups in the iPadOS menu bar with a keyboard; Android tablets anchor the M3 menu to the Day button in every window size (with the day pane in two-pane); wide minimal on tablets follows the phones unless Round 2 decides otherwise. Unverified: iPadOS menu-bar contents per window size; Android shortcut helper.
- **Resolved 2026-11-05 (ED-093): option B.** Full: Time · Plan · Day · Layout on every platform, Replan inside Time, Plan / Reality in Layout. Minimal phones: Show everything · Low-energy mode · Settings. Minimal Mac and web: E-Minimal's richer menu with aligned names and Show Everything. Need more time (+5 / +15 / +30, behaves as built Running late); Low-energy mode; Drop a routine…. Keys stay G2-10, routes G2-11. Merged into E-Phones, E-FullA-v2, E-PhonesMinimal, E-Minimal and E-Map (canvas `1793833662-a67e`); E-G2-9 kept as history.
- **Status:** RESOLVED · ED-093. *Refreshed after Group 1.*
- **Sources:** ED-046, ED-067, ED-072; CR-037, CR-039, CR-058, CR-059; doc 14 §3, §4; built Today ⋯ menu (`today_menu.dart`).

### Keyboard shortcuts and web routes

#### G2-10 · One keyboard scheme (Mac, web, iPad keyboards)
- **Why it matters.** ⌘1–4, ⌘K and ⌘F mean different things on each board and in the built app. Several proposed keys clash with macOS:
  - ⌘M is Minimize;
  - ⇧⌘G is Find Previous;
  - ⌥⌘D shows and hides the Dock;
  - ⇧⌘→ selects to the end of the line;
  - ⌘F is Find.
  On the web, the built app binds ⌘/Ctrl 1–4, which browsers use to switch tabs.
- **Design shows.**
  - **Built app:** ⌘1 Today, ⌘2 Inbox, ⌘3 Week, ⌘4 Month, ⌘N, ⌘/, ⌘, and ⌘Z / ⇧⌘Z.
  - **E-Minimal:** ⌘1–4 = Now / Day / Calendar / Inbox, ⌘K finder, ⌘F Focus, ⌥⌘D Day column, ⇧⌘→ Shift the rest.
  - **`E-FullA-v2` (Full proposal):**
    - ⌘1–4 = Day / 3 Days / Week / Month;
    - ⌘T Today; ⌘← / ⌘→ days; ⌘[ / ⌘] Back / Forward;
    - ⇧⌘T Go to Date; ⇧⌘I Inbox;
    - ⌘F Search; ⌘K palette;
    - ⇧⌘L Show Less / Everything;
    - ⇧⌘M Move To; ⇧⌘F Focus; ⌘↩ Done; ⌘⌫ Move to Trash; ⌥⌘I Inspector;
    - no keys for day-level replanning;
    - web: single keys (n, /, t, [ ], d 3 w m, g, i, ⇧L, f, ?) and ⌘/Ctrl K.
- **Options.**
  - **A. `E-FullA-v2`'s scheme in Full. In Minimal, ⌘1–4 follow E-Minimal's sidebar order** (Now · Inbox · Calendar · Search, fixing CR-045). The shared keys (⌘K, ⌘F, ⇧⌘L, ⇧⌘T, ⇧⌘M, ⇧⌘F, ⌘↩) mean the same in both modes. E-Minimal's clashing keys move: Day column ⌥⌘D → ⌥⌘I (the inspector key), Focus ⌘F → ⇧⌘F.
  - **B.** As A, but ⌘1–4 keep the built meaning in Full (Today / Inbox / Week / Month), with 3 Days left without a key.
  - **C.** Keep each board's own map.
- **Recommendation: A.**
  - It removes every macOS clash found.
  - It matches Calendar.app for views.
  - It gives each mode keys that follow what you see.
  - It never binds browser-reserved keys on the web.
  - **Cost:** ⌘2 changes from Inbox to 3 Days for current users, and ⌘1–4 mean different things in each mode.
- **Consequences.**
  - iPad: the same scheme on hardware keyboards.
  - macOS: menus as drawn on `E-FullA-v2`; E-Minimal's labels change (needs your review).
  - Android tablets: the same scheme with Ctrl.
  - Web: single keys outside text fields.
  - Built app: ⌘2 and the web ⌘1–4 bindings change.
- **Affects:** implementation · design.
- **Re-baselined 2026-11-05 (ED-094):**
  - **Built, verified in code:** ⌘1 Today, ⌘2 Inbox, ⌘3 Week, ⌘4 Month, ⌘N, ⌘/, ⌘, and ⌘Z / ⇧⌘Z; ⌘← / ⌘→ and ⌘T on Today, Week and Month; ⌘D marks the running task done; ⇧⌘P plans the Inbox; ↑↓ step, ⇧⌘↑↓ nudge, ↩ open, Space done, ⌫ / Delete trash, Esc closes. ⌘ on macOS and iOS, Ctrl elsewhere, including the web on non-Apple hosts.
  - **New since the first pass:** G2-8 shows ⌘N, ⇧⌘N, ⇧⌘V and web n / ⇧N. G2-9 menus show ⇧⌘N, ⇧⌘C, ⇧⌘L and web b / ⇧L. All are proposals.
  - **More clashes found:** ⌘D (built Done vs board Duplicate); the web's ⌘/Ctrl ⇧P (a Firefox private window); web Brain dump b vs ⇧N; E-Minimal web k vs E-FullA-v2 ⌘K (both kept).
  - **Board `E-G2-10`:** one scheme for both modes with ⌘, Ctrl and web columns; the ⌘1–4 choice A / B / C; menus with keys; web hint bars; a new web setting for single-key shortcuts (WCAG 2.1.4).
  - **Recommendation changed to B:** ⌘1–4 keep the built meaning in Full (Today · Inbox · Week · Month); minimal follows E-Minimal's sidebar (Now · Inbox · Calendar · Search). This follows the owner's G2-9 instruction to preserve built behaviour. A remains drawn.
- **Tablet implications (recorded, not drawn):**
  - iPad hardware keyboards use the ⌘ column. The iPadOS ⌘-hold overlay lists only natively registered commands (needs a native path, unverified).
  - Android tablets, foldables and Chromebooks use the Ctrl column. Meta+/ opens the system shortcut helper only for published shortcuts (unverified in Flutter).
  - Which ⌘1–4 set applies follows the Round 2 tablet layout (Full or minimal).
  - Reserved system keys are to be checked per OS version on devices.
- **Resolved 2026-11-05 (ED-095): option B.** Full ⌘1–4 Today · Inbox · Week · Month (built); minimal Now · Inbox · Calendar · Search. Verification kept ⌘D = Done (built, doc 10, plan M3e.6) and ⌘↩ = Inbox Place in First Free Gap; Duplicate has no key; no ⇧⌘I; web 1–4 mirror ⌘1–4. User-facing changes are listed in ED-095. Merged into E-FullA-v2, E-Minimal and E-Map (canvas `1793837638-aed0`); E-G2-10 kept as history.
- **Status:** RESOLVED · ED-095. *Refreshed after Group 1.*
- **Sources:** ED-072; CR-045, CR-051 to CR-057, CR-061; N6, N8; `app_shortcuts.dart`, `app_menu.dart`.

#### G2-11 · One set of web routes
- **Why it matters.** Links, Back and refresh must land on the same place on every platform (`DESIGN_PRINCIPLES.md` §2). Existing links must keep working.
- **Design shows.**
  - **Built:** `/today`, `/day/:date`, `/week`, `/month`, `/inbox`, `/search`, `/settings/:page`, `/task/:id`, `/focus/:id`, `/review`, `/add`, `/wake-up`.
  - **E-Workspace:** `/plan/day/…?task=`. **E-Minimal:** `/now?task=`.
  - **`E-FullA-v2` proposal:**
    - all built paths kept;
    - new dated `/3-days/:date`, `/week/:date`, `/month/:yyyy-mm`;
    - `?task=:id` opens the inspector on any view; `/task/:id` redirects on wide;
    - `/now` only while Minimal is on;
    - Show everything returns to the last Full location;
    - each view, date or task change is a Back step; the layout switch is not.
- **Options.**
  - **A. `E-FullA-v2`'s scheme.**
  - **B.** Grouped `/calendar/week/:date` and `/calendar/month/:date` paths. They are new names for things that already have built paths.
  - **C.** E-Workspace's `/plan/…` tree.
- **Recommendation: A.** No built link breaks, and one name per place. Still to decide inside A: what a link to Week does while Minimal is on (open Week once, or Minimal on that date). Path URLs need a static-host rewrite (implementation check).
- **Consequences.**
  - iPhone, Android: deep links use the same paths.
  - macOS: same app routes.
  - Web: refresh and Back restore the open task (to test).
- **Affects:** implementation · design.
- **Also decide here (ED-078):** a Full/Minimal switch is not a Back step, because it is a setting.
- **Also decide here (ED-086):** a Full/Minimal switch cancels a multi-selection or drag in progress (Undo still works); the open task stays open in the other mode.
- **Re-baselined 2026-11-05 (ED-096):**
  - **Built, verified in code:** the routes listed above, plus `/wake-up/mission/:date/:kind`. The deep-link guard refuses any query or fragment. Web uses hash URLs (no path strategy); the calendar sign-in returns to `https://dottoday.app/#/settings/calendars`.
  - **Recommendation changed to A′:** E-FullA-v2's names on the built hash URLs, with four details:
    - **D1:** hash URLs kept.
    - **D2:** `?task=` with a strict guard.
    - **D3:** no `?q=`.
    - **D4:** a link never changes the mode. The open question in A, a Week link in minimal, is answered by D4: Calendar on that date.
  - **Board `E-G2-11`:** built routes, the proposed table, D1–D4, address-bar examples, side by side, security.
- **Tablet implications (recorded, not drawn):**
  - The same `dottoday://` paths.
  - D4 follows the tablet's Round 2 layout.
  - Each window keeps its own place and Back history (unverified with go_router).
  - Universal links / App Links are not built.
- **Resolved 2026-11-05 (ED-097): option A′ with D1–D4.** D4 reconciled per layout: minimal phones' `/today` = Today tab; minimal Mac/web's `/today` reveals the Day column; date links open a date-based place on every layout (minimal phones: Today tab, month sheet for `/month`); task links open on the task's date (rule T); Back / Forward / Refresh keep view, date and task; built `dottoday://`, sign-in, notification and widget links unchanged. Corrected table on `E-G2-11`; labels merged into E-FullA-v2, E-Minimal and E-Map (canvas `1793850945-1f54`).
- **Status:** RESOLVED · ED-097. Previous status line: OPEN · presented on `E-G2-11` (ED-096); recommendation A′. *Refreshed after Group 1.*
- **Sources:** ED-072; CR-066, CR-067, CR-068; `app_routes.dart`, `app_router.dart`, `deep_link_guard.dart`; docs/08 (calendar return URL).

### Duplicate-screen consolidation

#### G2-12 · Which duplicate screens merge
- **Why it matters.** Owner problem P4. Q4 allows merges that keep every entry point.
- **Design shows.** D3 board (recommendations only); not drawn in E.
- **Options.** A. D3's set: one "Review the day" route; one Inbox scheduling picker; one Wake Up / Wind Down dial under Your day; Month kept as peek + `/month` with one grid; rename "This week" to "Week in review"; keep both Add and the Inbox field. B. Merge only the day review and the scheduling picker. C. No merges.
- **Recommendation: A.** Every merge keeps its entries (Q4); the rename ends the "This week" vs Week clash.
- **Consequences.**
  - iPhone: sheets with detents for review and scheduling.
  - iPad: review as a pane; picker as a popover.
  - macOS: Day › Review the Day; review in a pane.
  - Android: M3 sheets; predictive Back closes them first.
  - Web: `/review`, `/month` keep their URLs.
- **Affects:** design · implementation.
- **Re-baselined 2026-11-05 (ED-098):** most of D3's merges are settled by later decisions (listed in ED-098). Three questions remain, drawn on `E-G2-12`: Q1 one Day review surface per platform; Q2 one picker for Inbox Schedule and Move; Q3 rename "This week" → "Week in review". Options A (all three, recommended), B (Q1 and Q2), C (none). The Month item is settled by G2-1 (ED-075); the Everything else item by G2-4.
- **Resolved 2026-11-05 (ED-099): option A.** Q1 one Day review per platform (phone sheet; Full Mac/web Review place with Week in Review beside it; minimal Mac/web Day column); Q2 one When picker for Inbox Schedule, Move and Move To… (sheet on phones, popover on Mac/web; scheduling rules, overlaps and Undo unchanged); Q3 "This week" → Week in review, labels only, no route renamed. Every entry kept. Merged into E-Phones, E-FullA-v2, E-Minimal, E-PhonesMinimal and E-Map; `E-G2-12` kept as the historical review board.
- **Status:** RESOLVED · ED-099. Previous status line: OPEN · presented on `E-G2-12` (ED-098); recommendation A.
- **Sources:** E-Map D #9; D3; Q4; CR-090.

#### G2-13 · "Plan from Inbox · 3" on the empty iPhone day
- **Why it matters.** You removed "Inbox · 3" on phones. It is unclear whether that meant this empty-day button too.
- **Design shows.** `E-Phones` F4 still has it. Doc 14 hides empty-day Inbox suggestions in minimal (`E-PhonesMinimal` F4 has none).
- **Options.** A. Keep it in Full (it is today's "Pull from Inbox" empty-day action), hidden in Minimal. B. Remove it everywhere (Inbox tab is enough).
- **Recommendation: A.** It is a built empty-day action, not the tray you removed; removing it would remove an entry point.
- **Consequences.**
  - iPhone: kept on the full empty day.
  - iPad: same.
  - macOS: empty-day state shows the same action.
  - Android: same.
  - Web: same.
- **Affects:** design.
- **Status:** ADOPTED FROM BOARD · ED-077 (no conflict found; owner may override). Previous status line: OPEN.
- **Sources:** ED-039; ED-037; doc 14 §3 "Empty-day actions".

### Group 2 completion (2026-11-05, after ED-099)
- **Resolved (10):** G2-1 Calendar (ED-075), G2-2 sidebar rows (ED-080), G2-4 Settings (ED-081 to ED-084), G2-5 task editor (ED-086, ED-087), G2-6 minimal task screen (ED-088, ED-089), G2-8 Add modes (ED-091), G2-9 Day menu (ED-093), G2-10 keyboard (ED-095), G2-11 routes (ED-097), G2-12 duplicate screens (ED-099). **Adopted from board (3):** G2-3 Settings entry, G2-7 Move picker (now drawn, ED-099), G2-13 Plan from Inbox (ED-077).
- **Workflow items still unsettled (no owner answer yet):**
  - ~~What a Full ↔ Minimal switch does to a multi-selection or a drag in progress.~~ **Resolved 2026-11-05 (ED-100):** cancel an unfinished drag or selection without applying anything; keep the date, open task, saved edits and Undo; never drop unsaved text without asking.
  - Names that differ across boards: Review (Full sidebar) vs Reviews (minimal View menu and finder); Delete vs Move to Trash; Need more time naming. These go to G3-10.
  - Not designed yet: the phone Inbox screen, the Routines page, Week in review states (first week, no data), share image and learning reveal, Trash, the picker's no-free-time state. These go to Group 4.
  - The design fixes listed below.
- **Feasibility checks still open (verify before building; none blocks Group 3):**
  - Mac Now mini window and the new status-item menu items (ED-066, ED-078).
  - Native sheet detents in Flutter, and the selected ring's contrast on glass (ED-087); the glass palette over a scrolling grid (ED-086).
  - Repeat scope asked before autosave writes a repeating change (ED-086); Recently used icons are new (ED-086).
  - Wake Up: AlarmKit on iPadOS 26; Play's full-screen-intent policy on tablets; the device-list Supabase table with RLS, which needs approval before any schema change or push (ED-084).
  - Routes: the guard change for `?task=`; `/task/:id` as the task over its date; per-window Back history with go_router; universal / App Links not built (ED-097).
  - Keyboard: the iPadOS ⌘-hold overlay and Android Meta+/ helper need native registration (ED-095).
  - Later: a Focus Filter through App Intents (ED-082).
- **Before Round 2:** the mandatory tablet coverage checklist (ED-090; inputs recorded in STATUS).

### Drawings awaiting the owner's visual review (ED-102)
- None. Both flagged E-Minimal drawings were reviewed and corrected (ED-108); the G3 boards are kept as history.

### Design fixes I can make once Group 2 is answered
- Redraw the Workspace and E-Minimal context menus with one item set and one Delete label (CR-060; label in G3-10).
- Draw the web Day menu popover (CR-059) and the Mac/web Add popover with live chips (CR-069).
- Draw `/task/:id` at narrow widths and the E-Minimal web task screen (CR-073).
- E-Workspace itself keeps its v1.0 keys and "Running Late"; `E-FullA-v2` is the candidate. Decide whether E-Workspace is frozen as history or updated (CR-053).
- Label the filler data on E-Workspace (other days, subtasks, alert chips) as sample data (ED-054).
- "Week view in full mode" on the phone minimal band: correct after G2-1 (CR-050).

---

## GROUP 3 · Visual and interaction consistency

### Dot, ring and bead dimensions

#### G3-1 · Scale direction: keep large, "C confidence", or both
- **Why it matters.** It sets every row height and dot size. You asked why C "looks more Confident"; the answer (scale contrast, not bigger rows) was never chosen.
- **Design shows.** Large scale on every E board (dots 32–34 px, now-dot 38–40 px).
- **Options.** A. Keep large. B. C confidence: modest rows, one big hero, more space between groups. C. Both: keep large dots and targets, add a bigger hero and more space between groups.
- **Recommendation: C.** Keeps your "Large feel" and comfortable 44 pt targets, and adds the hierarchy that makes C look confident.
- **Consequences.**
  - iPhone: hero grows; group spacing up.
  - iPad: same rules by width.
  - macOS: Now pane and thread spacing re-tuned.
  - Android: same as iPhone.
  - Web: same as Mac.
- **Affects:** design.
- **Presented 2026-11-05 (ED-101)** on `E-G3-1`: iPhone and Android Today drawn three ways from E-Phones F1 and F5 (A copy; B and C change the thread list only). Kind: new design proposal, not a correction. Measured: task rows above the tab bar A 6, B 6, C 5; 44 pt targets in all. Mac/web Full: C leaves the Workspace grid unchanged. Minimal: unchanged.
- **Revised 2026-11-05 (ED-103):** at the owner's request, option C now uses a 45 ring (24 icon), a 19/700 title and 32 px around the now group; the card grows with its text. Six task rows fit on iPhone and Android, as in A. Checks drawn: compact iPhone and Android, long title, 200 % text, scrolled, 2x thread alignment; no overlap or clipping, 44 pt / 48 dp targets.
- **Status:** RESOLVED 2026-11-05 (ED-104): option C · Both, revised, merged into E-Phones Frames 1 and 5 only. E-Minimal, E-FullA-v2 and the other layouts are not rescaled. The 3 Nov comment ending in "what" is closed: not a requirement.
- **Tablets (for Prompt D Round 2, not drawn):** iPad and Android tablets in a compact window (Split View, Slide Over, compact multi-window) use the phone Today exactly, current task included. At medium and expanded widths the thread pane keeps the same 45 ring, 19/700 title and 32 gaps (a width class never shrinks rows); the card widens with the pane, and the title line length is capped by the pane, not stretched. In two panes the current task stays in the Today list; the detail pane does not repeat it. Foldables follow the window class, not the posture. Whether tablet Full uses the phone thread or a Workspace-style grid is decided in Round 2; if a grid, G3-1 does not apply there (the Workspace was left unchanged). Unverified: Dynamic Type / font scale above 200 % on iPad, and pointer hover on the card.
- **Sources:** ED-025, ED-026; CR-007; pending table 9acf09f2.

#### G3-2 · One drawing for the large now-dot on every platform
- **Why it matters.** The large now-dot is E's signature on Now. It differs between phones, Mac and web (numeral 800 vs 700; plainer web version offered and never answered).
- **Design shows.** `E-PhonesMinimal` 236/228 px, numeral 800; `E-Minimal` 280 (Mac) / 240 (web), numeral 700. ED-052's question was asked about the archived E-Focus web orb.
- **Options.** A. One drawing everywhere (icon, track, arc, numeral weight); size by width. B. A plainer web version (no icon, no shadow).
- **Recommendation: A.** One identity (`DESIGN_PRINCIPLES.md` §2); web is not a lesser surface.
- **Consequences.**
  - iPhone: numeral weight aligned.
  - iPad: inherits.
  - macOS: inherits.
  - Android: inherits.
  - Web: same drawing as Mac.
- **Affects:** design.
- **Presented 2026-11-05 (ED-105)** on `E-G3-2`. Kind: consistency correction. Found: one SVG everywhere; only the centre type differs (phones 800 at 0.36 of the orb, Mac and web 700 at 0.27; inherited from Concept C). A: the phones' centre type at the same proportion everywhere (Mac 100 px, web 85 px; phones unchanged). B: plainer web orb. C: keep as drawn.
- **Status:** RESOLVED 2026-11-05 (ED-106): option A, merged into E-Minimal (Mac 100 / web 85, 800). The board first drew A's Mac and web orbs too light (font error); corrected, and the owner confirmed the merged orbs ("Looks right").
- **Sources:** ED-020, ED-052, ED-059; CR-003; N11.

### Typography and spacing

#### G3-3 · Content typeface
- **Why it matters.** E draws content in Manrope; today's app and `THREE_UX_CONCEPTS.md` use Inter. The type family is a brand decision (`DESIGN_PRINCIPLES.md` §4).
- **Design shows.** Manrope everywhere for content; system fonts for chrome (K6).
- **Options.** A. Manrope for content. B. Inter (today). C. System font for content too.
- **Recommendation: A**, fixed at Step 9 with a bundled-font and licence check.
- **Consequences.**
  - iPhone: Manrope content, SF chrome.
  - iPad: same.
  - macOS: same.
  - Android: Manrope content, Roboto chrome.
  - Web: Manrope content, system stack chrome.
- **Affects:** design · implementation (font asset).
- **Presented 2026-11-05 (ED-109)** on `E-G3-3`: E-Phones Today in Manrope, Inter and the system font; specimen; facts (licences, built app, measured widths).
- **Status:** RESOLVED 2026-11-05 (ED-110): option A, Manrope for task names, descriptions, times, the Now-dot numbers, task sheets and other branded content; native system type for chrome. No board changed. Text size rules, implementation checks and tablet notes in rules §3.4–3.6. Follow-up correction (task text in system font inside phone sheets) proposed in rules §3.7, awaiting the owner.
- **Sources:** ED-012; CR-112; I29; `DESIGN_PRINCIPLES.md` K6.

### Colours, surfaces and states

#### G3-4 · iOS switch colour when on
- **Why it matters.** Small, but it is on every Settings screen.
- **Design shows.** Teal on-state (Claude's choice; system green offered, no answer).
- **Options.** A. Teal (app accent). B. iOS system green.
- **Recommendation: A.** iOS allows a tint; teal on cream measures 6.81:1 and matches the brand accent.
- **Consequences.**
  - iPhone: teal switch.
  - iPad: teal switch.
  - macOS: native Mac switch with accent tint.
  - Android: M3 switch in teal (already).
  - Web: teal toggle.
- **Affects:** design.
- **Presented 2026-11-05 (ED-111)** on `E-G3-4`: the four iPhone frames with switches as drawn (teal) and with system green; 3× close-ups with On/Off Labels; measured contrast (teal 7.16:1, green 2.19:1 against the row).
- **Status:** RESOLVED 2026-11-05 (ED-112): option A, teal. The 8 iOS switches stay as drawn; native shape, motion and interaction; On/Off Labels honoured; Android unchanged; dark-mode contrast checked separately under G4-6.
- **Verification 2026-11-06 (ED-117):** design verification PASS; Flutter implementation NOT YET IMPLEMENTED / VERIFIED (implementation checks and three known gaps in rules §4.2, future tasks only); dark-mode verification PENDING G4-6.
- **Sources:** ED-041; CR-099.

#### G3-5 · Hover lift shadow on a web block
- **Why it matters.** The lean finish removed shadows except on floating surfaces. Lunch on the web Workspace keeps a hover lift.
- **Design shows.** `E-Workspace` web, Lunch block.
- **Options.** A. Keep the lift on hover and while dragging only. B. Flatten it (tint change only).
- **Recommendation: A.** A lifted block is a floating surface, which ED-022 allows; it tells pointer users the block can be dragged.
- **Consequences.**
  - iPhone: none (drag lift is a separate motion spec).
  - iPad: pointer hover shows the lift.
  - macOS: same as web.
  - Android: none on phones; pointer on tablets.
  - Web: hover lift kept.
- **Affects:** design.
- **Presented 2026-11-05 (ED-113)** on `E-G3-5`: E-FullA-v2 web Plan Day as drawn and with Lunch flattened; 2× close-ups at rest, hover and dragging over another block.
- **Option C (owner, 2026-11-05, ED-115):** flat at rest; B's tint and hairline on hover; A's lift only while dragging; teal focus ring unchanged. Drawn next to A and B on the revised `E-G3-5`. Recommendation changed to **C**.
- **Status:** RESOLVED 2026-11-06 (ED-116): option C. Merged into E-FullA-v2 (Lunch hover: tint and hairline). Shared rule for eligible Workspace blocks in rules §7.4. Drag timing, scale and haptics stay open (§7.5).
- **Sources:** ED-053.

#### G3-6 · Glass and vibrancy: native views or Flutter approximations
- **Why it matters.** Cost and risk. The boards draw iOS Liquid Glass, Android blur and Mac vibrancy as approximations; the platform guide warns against faking system materials and calling them native (`DESIGN_PRINCIPLES.md` K8).
- **Design shows.** Approximations, labelled "Platform note".
- **Options.** A. Flutter approximation (no new dependency), with a solid fallback under Reduce Transparency. B. Native platform views for the iOS tab bar, menus and Mac sidebar. C. Solid surfaces until a native check is done.
- **Recommendation: A**, labelled "approximated", with a short native spike on the iPhone tab bar before Prompt F. B needs a must-ask (native targets) and C drops the glass you approved.
- **Consequences.**
  - iPhone: approximated glass; solid when Reduce Transparency is on.
  - iPad: same.
  - macOS: approximated vibrancy.
  - Android: blur on 12+, solid tonal below.
  - Web: solid (unchanged).
- **Affects:** implementation · design (fallback states).
- **Presented 2026-11-06 (ED-118)** on `E-G3-6`: iPhone and Android Today scrolled under the chrome, as drawn and solid; the Mac sidebar as drawn and solid; 2× close-ups; facts for A, B and C.
- **Native-first exploration 2026-11-06 (ED-119)** on `E-G3-6-Native`: genuine iOS 26.5 captures beside our drawings; native candidates (iPhone tab bar, Day menu, Mac sidebar material); risks; fallbacks; spike plan; confirmed vs to-test. The earlier recommendation A is not approved.
- **Spike results 2026-11-06 (ED-120)** on `E-G3-6-Spikes`: iPhone N1 and N2 show genuine glass over Flutter in the Simulator; N1 recommended (with Search as a regular tab) pending device validation; iPad N1 puts tabs at the top; Mac vibrancy behind transparent Flutter works on this Mac with no measurable cost. Device checks (VoiceOver, keyboard, performance, touch, older iOS) outstanding.
- **Phone bottom rows approved 2026-11-06:** iPhone (ED-124, from `E-G3-6-BottomRow`, N3 native build on the owner's iPhone, ED-122) and Android revised C (ED-125, from `E-G3-6-Android`, ED-123); merged into the active phone boards (ED-126). This settles the **appearance** only; the architecture questions below are reassessed against these rows.
- **Reassessed 2026-11-06 (ED-127)** on `E-G3-6-Decision` against the approved rows. Choices awaiting approval: D1 iPhone architecture (recommend N3 native composition), D2 iOS 16–25 fallback (recommend same native composition with pre-26 styles), D3 Day ▾ menu (native UIMenu), D4 other iPhone glass (Flutter for now), D5 Android C build (Flutter BackdropFilter widget, solid on 11 and older), D6 Mac sidebar (native vibrancy, warm tint after a spike). Tablets: Round 2. Web: unchanged.
- **Directions selected 2026-11-06 (ED-128):** D1 A (N3), D3 A (native UIMenu), D4 (Flutter), D5 A (Flutter); D2 F2 conditional on older-iOS tests; D6 B preferred, conditional on visual approval. **Findings (ED-129)** on `E-G3-6-Remaining`: warm 35 % tint keeps ≈ 60 % of the native show-through, contrast passes; F2 builds for iOS 16 and keeps the geometry in compatibility mode but is not run on iOS 16–25.
- **D6 approved 2026-11-06 (ED-130):** native sidebar vibrancy, `#EFE7DB` at 35 %, light mode; Reduce Transparency fallback, Increase Contrast, VoiceOver, keyboard and dark mode (G4-6) PENDING.
- **Compatibility run 2026-11-06 (ED-131)** on `E-G3-6-Compat`: F2 on iOS 18.6 and N3 on iOS 26.5 (Simulator) pass the functional and accessibility-setting checks listed there; two test-app defects fixed; one architecture limit F1 (N3 Minimal capsule 274 pt) needs a decision; iOS 16/17, devices and VoiceOver PENDING.
- **F1 decided (ED-132):** option (a), keep the 6 pt gap; the iOS 26+ Minimal capsule keeps Apple's width. Merged into E-PhonesMinimal.
- **Status:** RESOLVED 2026-11-06 (ED-133) as a design and selected architecture direction; every untested behaviour stays PENDING in `E_IMPLEMENTATION_HANDOFF.md`.
- **Sources:** E-Map D #20; CR-096, CR-106; ED-034, ED-035, ED-122 to ED-126.

#### G3-7 · iPhone keyboard and the teal "Add" key
- **Why it matters.** You asked for "Add" in teal (resolved). You then wrote "the keyboard"; restoring the whole keyboard was offered and not answered. A real app cannot restyle the iOS keyboard, and iOS has no "Add" return key.
- **Design shows.** iOS-styled keyboard with a custom teal Add key.
- **Options.** A. Stock iOS keyboard; teal "Add" in an input bar above it (and the in-field Add button). B. Custom-drawn key (not buildable with the system keyboard). C. Stock keyboard only; in-field Add button only.
- **Recommendation: A.** It keeps your teal Add and the real keyboard; boards then draw the stock keyboard.
- **Consequences.**
  - iPhone: input accessory bar with Add.
  - iPad: same bar; hardware Return adds.
  - macOS: Return adds.
  - Android: keyboard check key adds (as drawn).
  - Web: Enter adds.
- **Affects:** design · implementation.
- **Presented 2026-11-06 (ED-134)** on `E-G3-7`: audit of the four drawn keyboards, genuine iOS 18.6 / 26.5 default keyboards, options A, B, C drawn on copies of the Full and Minimal Add frames; recommendation A (stock keyboard + teal Add bar), C as the minimal alternative.
- **Status:** RESOLVED 2026-11-06 (ED-135): option C · stock keyboard, neutral return key adds; teal Add stays in the field row / nav bar; merged into E-Phones and E-PhonesMinimal.
- **Sources:** ED-031, ED-032; CR-099.

### Open questions from the owner's latest edits (2026-11-06 to 11-07)

#### Q-A1 · Does Create task keep "Add another"?
- **Why it matters.** The old compact Add sheet had "Add another" (the owner asked for it as a check, thread 219487e0). Create task (ED-140) replaced that sheet and has no such option, so every task closes the screen.
- **Design shows.** Create task on E-Phones (iPhone and Android) without "Add another"; Minimal Add unchanged.
- **Options.** A. Drop it: Create task always closes; several tasks go through paste a list or Brain dump. B. Keep it as a check row under the title: when on, Create task / Return saves, clears the form and keeps the title focused.
- **Recommendation (superseded): B.** Matches the owner's earlier request and keeps entering several tasks quick (R-06); one row, nothing removed.
- **Consequences.** iPhone: check row (teal check). Android: M3 checkbox row. Mac / web: same row in the capture popover. Tablets: Round 2.
- **Affects:** design · implementation (CR-129).
- **Status:** RESOLVED 2026-11-07: option A, no "Add another" (ED-152); the owner's final choice supersedes the recommendation.

#### Q-A2 · Brain dump and Routine in the Create task chrome
- **Status:** Full-screen part RESOLVED 2026-11-07 (ED-147 to ED-150); tab and action rules set by the owner (ED-152). Q-A2a resolved (ED-153). **Q-A2 RESOLVED.**

#### Q-A2a · Title in the iPhone Brain dump and Routine header
- **Why it matters.** iPhone Create task's header is Cancel · (no title) · ⋯ · Create task; the full-screen Brain dump and Routine (ED-147, ED-149) show a centred title ("Brain dump", "Routine") that repeats the selected tab. Android shows a title in all three (New task / Brain dump / Routine), so Android is already consistent.
- **Options.** A. Remove the iPhone centre title on Brain dump and Routine (header = Cancel only), matching Create task. B. Keep the titles.
- **Recommendation: A.** The selected tab already names the mode; matching Create task makes the three tabs read as one screen.
- **Status:** RESOLVED 2026-11-07: option A (ED-153).

### Accessibility corrections

#### G3-8 · Grey text below 4.5:1 on iPhone tabs
- **Why it matters.** The full-mode inactive tab label (#8E8E93) measures 3.06:1. The design principles put accessibility above native look.
- **Design shows.** #8E8E93 on `E-Phones`; darker #6E6E73 on `E-PhonesMinimal`.
- **Options.** A. Darker grey (#6E6E73) everywhere. B. Keep the iOS system grey.
- **Recommendation: A.** WCAG 2.2 AA is an owner target (brief §17); `DESIGN_PRINCIPLES.md` §3 order puts accessibility first.
- **Consequences.**
  - iPhone: darker inactive labels.
  - iPad: same.
  - macOS: check sidebar secondary text the same way.
  - Android: check NavigationBar labels.
  - Web: check sidebar labels.
- **Affects:** design.
- **Status:** RESOLVED 2026-11-07: option A, #6E6E73 in Full and Minimal (ED-154).
- **Sources:** ED-042; CR-101; I6.

#### G3-9 · Task colours that are too light as rings
- **Why it matters.** Coral, amber, sky and green rings are below 3:1 on cream; white on amber is 2.29:1. "Ahead" is drawn as a ring, so these tasks are hard to see.
- **Design shows.** C's palette on every board.
- **Options.** A. A darker ring shade per colour (fill colour unchanged). B. A thin ink outline around light rings. C. Keep as is.
- **Recommendation: A.** Keeps the palette's look and meets WCAG 1.4.11; a palette change is a brand decision, so it is yours.
- **Consequences.**
  - iPhone: ring tones darken for four colours.
  - iPad: same.
  - macOS: same.
  - Android: same.
  - Web: same.
- **Affects:** design.
- **Status:** RESOLVED 2026-11-07: option A, ring tokens coral #DF6147, amber #AF7E22, sky #338ED1, green #469763; ink glyphs on amber (ED-155).
- **Sources:** CR-013; rules §4.3, §12.1.


#### G3-9b · Full task colour palette (follow-up to G3-9)
- **Why it matters.** The owner approved applying G3-9's accessibility standard to every existing and future task colour (2026-11-07), without darkening every fill or limiting the palette. No full palette review was scheduled before; rules §4.3 listed "the full list of user-selectable task colours" as UNRESOLVED.
- **Audit (read-only, original app).** 9 stored keys coral · amber · mint · teal · sky · indigo · violet · rose · slate (`palette.json`, `color_key` ≤ 24 chars, default indigo, legacy tangerine/lime/magenta mapped); no custom colours; 4 accents indigo (default) · teal · coral · violet. Concept E draws C's 9 colours: the same keys re-tinted, plus Brown (no key) and no slate; E's accent is fixed deep teal `#11615C`.
- **Boards:** `E-G3-9b-Palette` (palette cards with fill, ring, done glyph, now; picker sketches; rules; decisions) and `E-G3-9b-Screens` (owner's request 2026-11-07: full selection flows on the approved screens: iPhone Create task › Colour and icon sheet › back, iPhone Settings › Appearance › App colour; Android Create task › M3 colour sheet › back, Android Settings › Appearance; Mac inspector colour popover and Settings Appearance pane; web inspector colour menu and two-pane Settings Appearance). Appearance pages are new drawings under the approved Settings root; only colour parts of approved screens change.
- **Owner direction 2026-11-07 (with two reference screenshots):** on iPhone and Android Create task / editor colour selection, a ⋯ at the top opens a second pull-up with all colours (any colour, e.g. hue and shade sliders, hex, presets); "every color should be included in Dottoday"; Mac and web to be designed with UI/UX in mind. Drawn on `E-G3-9b-Screens` (iPhone 5 steps, Android 4, Mac and web popover with Custom colour… expanded in place). This changes the earlier "custom colours: not now" recommendation; custom colours need a `color_hex` value and a saved "Your colours" list (Supabase migration, must-ask) before any build.
- **Proposed (not approved):** E shades for the 8 shared keys; slate kept with E shade `#6E6A75` and Brown `#8C6A4F` as a new key; new Plum `#9E4F8F` and Olive `#7F8A3A` (12 total); rings for teal `#289588` and rose `#D75E89` (both under 3:1 on the Minimal surface `#F3EEE6`); E shades for the 4 accent keys (teal `#11615C` default, indigo `#3F45C4`, coral `#A3412A`, violet `#6440D6`); custom colours: drawn per the owner's direction (⋯ › All colours; Mac / web Custom colour…), ring and check derived at render time, saved hex never changed.
- **Unchanged and kept:** ED-155 rings and ink amber glyphs; all stored keys; active boards and picker.
- **2026-11-07 (ED-156):** Mac and web custom colour picker APPROVED (design); phone All colours redrawn as a half sheet with the hex in the title row on iPhone and Android.
- **Q-G3-9b-1:** RESOLVED 2026-11-07, yes: the in-progress arc uses the ring shade for colours under 3:1 (ED-157).
- **Layout and pinned preview (ED-159, proposed):** Layout moves from the Settings root to Appearance on every platform; the preview stays pinned and shows Everything ↔ Less with motion; tab bar / toolbar on Settings except under pull-ups; Suggested removed from Edit palette. Supersedes G1-4's Settings-root placement if approved.
- **Appearance (ED-158, proposed):** theme thumbnails, App colour with Edit palette half sheet and live preview on iPhone and Android; Mac / web Appearance pane with Custom… and Preview.
- **Status:** RESOLVED 2026-11-07: approved as drawn on E-G3-9b-Screens and merged (ED-161). Data changes for custom colours and new keys stay must-ask. G3-10 resumes after.

### No-shame terminology and feature names

#### G3-10 · One name for each thing
- **Why it matters.** Renaming a feature needs owner approval (`DESIGN_PRINCIPLES.md` §4), and "Running late" breaks the no-"late" rule (CLAUDE.md §11).
- **Design shows.** Low-energy mode / Low-energy day / Low-Energy Mode / Gentle Day; Review / Reviews; Today / Day; Running late / Need more time; Delete ⌫ / Move to Trash ⌘⌫; Brain dump (Clear your head only on the archived E-Focus).
- **Options.** A. Low-energy mode · Brain dump · Review · Today (place) and Day (menu) · "Need more time?" everywhere · Delete (goes to Trash for 30 days, with Undo; ⌘⌫ on Mac). B. As A but "Gentle day" for Low-energy. C. Keep the current names per board.
- **Recommendation: A.** Uses the built and documented names (doc 14, parity), removes "late" from all copy, and one shared vocabulary (`DESIGN_PRINCIPLES.md` §2).
- **Consequences.**
  - iPhone: Day menu items renamed.
  - iPad: same.
  - macOS: menus renamed; Delete ⌘⌫.
  - Android: same as iPhone.
  - Web: same.
- **Affects:** design (copy).
- **Status:** RESOLVED 2026-11-07: option A with native Mac menu conventions (ED-162).
- **Sources:** E-Map D #17; CR-046, CR-060, CR-062, CR-064, CR-065; I21, I22, I24, I30; N9, N10.

#### G3-11 · "Need more time" amounts
- **Why it matters.** Today's app offers +5, +15 and +30. Phones and E-Minimal show only +15 and +30. Dropping +5 removes an option.
- **Design shows.** +15/+30 on phones and E-Minimal; +5/+15/+30 on E-Workspace.
- **Options.** A. +5, +15, +30 everywhere. B. +15, +30 with "Other amount…" (5 reachable). C. +15, +30 only.
- **Recommendation: A.** Matches what is built (parity) with no new control; C would remove an option and needs explicit approval.
- **Consequences.**
  - iPhone: three chips (check 44 pt targets).
  - iPad: same.
  - macOS: submenu with three items.
  - Android: three chips.
  - Web: popover with three items.
- **Affects:** product behaviour (only if C) · design.
- **Status:** RESOLVED 2026-11-07: option A, +5 / +15 / +30 everywhere (ED-163).
- **Sources:** CR-063; I23; parity matrix "Running late +5/15/30".

#### G3-12 · Done tasks and numbers in Minimal
- **Why it matters.** Doc 14: done tasks stay in place, struck through, and minimal shows no number that judges. The boards fold done tasks into "Earlier · 3 done".
- **Design shows.** "Earlier · 3 done" on `E-PhonesMinimal` F2 and `E-Minimal`; summary line shows time, not counts.
- **Options.** A. Fold into "Earlier" with no count ("Earlier · Show"). B. Keep doc 14: done tasks in place, struck through. C. Fold with the count (as drawn).
- **Recommendation: A.** Calmer screen, and no number (doc 14 rule 5). It changes doc 14 §4, so it needs your yes; B is the safe alternative.
- **Consequences.**
  - iPhone: fold row without a count.
  - iPad: same.
  - macOS: Day column fold without a count.
  - Android: same as iPhone.
  - Web: same as Mac.
- **Affects:** product behaviour (minimal rule) · design.
- **Status:** RESOLVED 2026-11-07: option A, "Earlier" with no count, also on the Full Mac/web Day column (ED-164). Group 3 complete.
- **Sources:** E-Map D #14; ED-055; CR-020, CR-035.

### Group 3 completion (2026-11-07, after ED-164)
- **All Group 3 decisions resolved:** G3-1 (ED-104), G3-2 (ED-106), G3-3 (ED-110), G3-4 (ED-112), G3-5 (ED-116), G3-6 (ED-133, behaviour tests pending), G3-7 (ED-135), Q-A1 (ED-152), Q-A2/Q-A2a (ED-147 to ED-153), G3-8 (ED-154), G3-9 (ED-155), G3-9b (ED-161), G3-10 (ED-162), G3-11 (ED-163), G3-12 (ED-164).
- **Owner follow-ups settled (ED-165):** CR-138 applied; CR-134 resolved; CR-133 verified per context; colour data reviewed in `E_COLOUR_DATA_REVIEW.md` (no change authorised). Cleanup batch in `E_CLEANUP_BATCH.md`: 6 applied, 3 no change, 13 waiting on the owner.
- **Mechanical work unblocked, not yet done:** the list below (CR-100 chips part done by ED-163) and CR-135.

### Design fixes I can make once Group 3 is answered
- Now-bead one size per width (16 / 14 / 12 px today) (CR-015, I1).
- ~~Now-ring track and cut-out one recipe (CR-016, I2).~~ Resolved (ED-198). Dark tracks aligned: CR-166 resolved (ED-212).
- ~~Ahead-ring width one value (CR-017, I3, N18).~~ Resolved by context (ED-199).
- ~~Calendar dot centre one colour (CR-009, I4).~~ Resolved: centre = surface (ED-200).
- ~~Wake Up cap one size (CR-018, I5).~~ Resolved: 34 px, icon 19 (ED-201).
- Android Day button 48 dp; FAB radius one value; Now card radius/height (CR-027, I7–I9). Now card: resolved (ED-104 heights, ED-202 radius 24).
- ~~Add input type one weight (CR-004, I10); Android Edit title in Manrope (CR-005, I12).~~ Resolved (ED-204).
- ~~iPad "Alarms off" tag off the board's amber (cleanup 8c).~~ Resolved: neutral tag + amber bell-off icon (ED-205). Light icon refined to #986C1C (ED-213).
- Android AM/PM selected stops using the board's Hypothesis amber; Android Day menu surface (CR-011, I13).
- Mac sidebar blur one rule; context-menu radius one value; web focus ring one recipe (CR-024–CR-026). Focus ring (cleanup 9c): ED-174 recipe applied on the active boards (ED-211).
- ~~Primary Add one colour on Mac and web (CR-010, I18, N13).~~ Resolved: teal accent, applied to E-Minimal web (ED-211).
- ~~Day button font (N14).~~ Resolved: system 13/500 on Mac and web (ED-206).
- ~~Pane widths: sidebar one set (CR-023, N5).~~ Resolved: Full 216 (ED-168), Minimal 200 on Mac and web (ED-207). Task pane 290 (Minimal column) vs 248 (Full inspector) are different components (ED-197).
- ~~Repeat marker one form (CR-012, I26).~~ Resolved: the repeat icon, named "repeats" (ED-208).
- Touch targets up to 44 pt / 48 dp: tip dismiss, in-field Add, chips, +15/+30, Android Day button (CR-100).
- ~~Now card and now title sizes on wide (N12).~~ Resolved: 68 / 12.5 / 16 on Mac and web (ED-209).
- ~~Glass shadow tiers confirmed (I32).~~ Resolved: five iPhone tiers confirmed as drawn (ED-210).

---

## GROUP 4 · Missing experiences

#### G4-1 · What Round 2 draws first
- **Why it matters.** About 30 screens are not drawn (CR-069 to CR-090). Order decides what you can judge first.
- **Design shows.** Entry points only for Focus session, Inbox, Calendar, Search, Settings, multi-select, Undo, sync banner, Wake Up family, onboarding, system surfaces.
- **Options.** A. Core journey and non-negotiables first: Today → Add → Edit → Complete → Change day → Reopen; multi-select + selection bar; Undo; sync conflict; Focus session; then Wake Up, Settings, onboarding, system surfaces. B. One platform at a time, everything on it. C. By board.
- **Recommendation: A.** The brief's first production slice and CLAUDE.md §8 non-negotiables (R-04, R-05, R-08) come first; all platforms move together (R-13).
- **Consequences.**
  - iPhone: editor, Inbox, Calendar, Search, selection first.
  - iPad: follows G4-4.
  - macOS: Add popover, Focus session, Inbox and Search in both modes.
  - Android: same set as iPhone plus full Add sheet and swipe.
  - Web: same as Mac plus Day menu popover.
- **Affects:** design (order).
- **Status:** RESOLVED 2026-11-07: option A, core journey first, then interaction and recovery, then supporting experiences (ED-166). Round 2 not started.
- **Sources:** CR-069 to CR-090; inventory §2; rules §14.1.

#### G4-2 · Width breakpoints
- **Why it matters.** Today's 600 / 840 split gives a 339 px Today at 840 with the editor open. The E-Map proposes 720 / 1160.
- **Design shows.** Only 390, 412 and 1280 widths drawn.
- **Options.** A. 720 / 1160 (E-Map). B. Keep 600 / 840 (Material classes, today's code). C. 600 / 840 for the shell, 1160 for docking the inspector.
- **Recommendation: A**, with "large text drops one class" and "short height keeps compact". Width decides layout, never device (CLAUDE.md §11).
- **Consequences.**
  - iPhone: compact (landscape stays compact by height).
  - iPad: portrait medium; landscape expanded.
  - macOS: 960 window is medium.
  - Android: tablets and unfolded foldables medium/expanded.
  - Web: same thresholds.
- **Affects:** design · implementation.
- **Status:** RESOLVED 2026-11-07: option C, 600 / 840 kept, editor docks from 1160 (ED-167). Refined by ED-168: H1 (short height) and M (docking minimums) approved.
- **Sources:** E-Map D #19; CR-095; rules §12.2.

#### G4-3 · Mac minimum window
- **Why it matters.** The Mac minimum (960 × 640) falls in medium, and no medium layout exists. E-Minimal needs 1280 as drawn.
- **Design shows.** 1280 × 800 only.
- **Options.** A. Keep 960 and design the medium layout. B. Raise the minimum to 1160.
- **Recommendation: A.** Small laptop windows and side-by-side use stay possible; medium is needed for iPad and tablets anyway.
- **Consequences.**
  - iPhone: none.
  - iPad: shares the medium layout.
  - macOS: medium layout drawn at 960.
  - Android: tablets share it.
  - Web: narrow browser windows share it.
- **Affects:** product behaviour (window size) · design.
- **Update 2026-11-07 (after ED-167):** under 600 / 840, 960 is *expanded*, not medium, so this entry's premise changed. The options are re-presented on board E-G4-3 (A keep 960 × 640, B 840 × 640, C 600 × 480, D 1160 × 720).
- **Status:** RESOLVED 2026-11-07: option B, 840 × 640, design only (ED-169). Follow-ups approved (ED-170): the Day-column fold (button labelled "Day", no shortcut), the narrow toolbar, the short-window now-dot, and C1 (a).
- **Sources:** E-Map D #19; CR-091, CR-095.

#### G4-4 · iPad and Android tablet shell
- **Why it matters.** Q6 and brief §16 ask for real tablet layouts. Nothing is drawn.
- **Design shows.** Nothing.
- **Options.** A. Medium: rail + two panes; expanded: sidebar like Mac (G1-1 layout); task surface as popover/side sheet; hardware keyboard and pointer supported. B. Phone layout stretched with a tab bar at all widths. C. Mac layout at every tablet width.
- **Recommendation: A.** Follows width classes, iPadOS sidebar conventions and Android rail; never split a pane across a hinge.
- **Consequences.**
  - iPhone: none.
  - iPad: sidebar or rail by width; Stage Manager windows by width.
  - macOS: shares the expanded layout.
  - Android: rail on tablets and foldables; hinge-aware panes.
  - Web: shares medium/expanded.
- **Affects:** design · implementation.
- **Status:** RESOLVED 2026-11-07 as strategy: option A with native navigation per platform (ED-171). Tablet screens are drawn in Round 2; not visually complete.
- **Sources:** CR-094; inventory §3; Q6; D2 iPad/Android tablet rows.

#### G4-5 · Mobile web and phone landscape
- **Why it matters.** The web must work in a phone browser, and phones rotate. Neither is drawn.
- **Design shows.** Nothing.
- **Options.** A. Mobile web uses the compact phone layout with a bottom bar, browser Back and no edge-swipe; phone landscape keeps the compact shell. B. Redirect phone browsers to the app stores. C. Mobile web shows Today only.
- **Recommendation: A.** Parity on every platform (R-13); B and C remove features from a platform.
- **Consequences.**
  - iPhone: landscape keeps compact shell.
  - iPad: none.
  - macOS: none.
  - Android: landscape keeps compact shell.
  - Web: phone-width layout with browser Back.
- **Affects:** design.
- **Status:** RESOLVED 2026-11-07: option A, a compact mobile web with its own web bottom bar; routes as ED-097 (ED-172). Phone landscape is covered by H1 (ED-168). Browser behaviour PENDING testing.
- **Sources:** CR-094; inventory §3.

#### G4-6 · Dark mode
- **Why it matters.** Not drawn on any board; no dark tokens. Dark palette is part of the brand.
- **Design shows.** Nothing.
- **Options.** A. Derive a full dark set (ground, surfaces, palette rings at 3:1, glass on dark) and draw one frame per board for approval. B. Dark mode later, after Round 2. C. Follow today's app's dark theme recoloured.
- **Recommendation: A.** Dark follows the device in both modes (doc 14); it must be checked before goldens, and glass contrast needs a dark recipe.
- **Consequences.**
  - iPhone: dark glass recipe.
  - iPad: same.
  - macOS: dark vibrancy.
  - Android: dark tonal bars.
  - Web: dark solid surfaces; no flash on switch.
- **Affects:** design.
- **Status:** P1, the switch tint, the focus gap and the iPhone, Android and web materials APPROVED (ED-174). Dark task colours frozen (ED-175); Mac D1 with the primary-text label approved (ED-176). Stage 2 key frames presented (ED-177). I1, T1 and T2-B approved: Stage 1 tokens FINAL (ED-178). Q1-B and two text corrections approved (ED-179). Stage 2 screens APPROVED (ED-180). Stage 3 merged as dark companions of every active board (ED-181). **RESOLVED as design**; device and assistive-technology tests PENDING; CR-153 to CR-156 await the owner.
- **Sources:** CR-103; rules §10, §14.1 item 1.

#### G4-P · Plan panel on Mac and web (owner-raised, 2026-11-08)
- **Status:** RESOLVED as A + B (ED-182 options, ED-184 approved and merged). Related rule: text always fits (ED-183, rules §12.3).

#### G4-7 · Shared states and accessibility states
- **Why it matters.** Loading, empty, error, offline, sync conflict, 200 % text, reduced motion and reduced transparency are not drawn anywhere. R-08 needs a visible sync state.
- **Design shows.** Empty day (phones) and a sync indicator only.
- **Options.** A. One shared state kit drawn once (skeleton thread, Try again, offline, sync banner and sheet, conflict) plus a 200 % / reduced-motion / reduced-transparency pass on each core screen. B. Draw states screen by screen as each is designed. C. Leave states to implementation.
- **Recommendation: A.** One kit avoids drift; accessibility is part of done (CLAUDE.md §5, brief §17).
- **Consequences.**
  - iPhone: kit + Dynamic Type 200 % frames.
  - iPad: inherits.
  - macOS: kit + keyboard focus order.
  - Android: kit + font scale 200 %.
  - Web: kit + focus rings and offline outside the shell.
- **Affects:** design.
- **Status:** Option A APPROVED (ED-186); kit drawn on E-G4-7-States; Q1 (look and one state system, direction only) APPROVED (ED-187); Q2 option A (web asks the browser to keep storage; wording unchanged) APPROVED as a requirement, not built (ED-188); its browser-storage warning drawn in web Sync details (ED-189), frames approved with the owner's caution wording (ED-190); Q2 resolved for signed-in web (ED-191); Q2-W1 option A approved, guest frames drawn (ED-192); **Q2 CLOSED at design level** (owner accepted, ED-193); implementation CR-159 OPEN; **CR-160 CRITICAL release blocker** (ED-193); Q3–Q5 OPEN (Undo after conflict is a proposal, not built, not approved); not merged.; **Q3 option A (conflict Undo) APPROVED as design (ED-194)**, not built; **Q4 option B (Keep both, notes only) APPROVED as design (ED-195)**, board E-G4-7-Q4-KeepBoth, not built; Q4-L1 APPROVED (ED-196); **Q5 option A APPROVED (ED-196)**; **G4-7 CLOSED at design level** (Q1–Q5); implementation CR-159, CR-160, CR-161, CR-163, CR-164 OPEN
- **Sources:** CR-079, CR-087, CR-103 to CR-107; rules §14.1 items 8, 18; inventory §1.4 "Shared loading / error / empty / offline states".

### Design fixes I can make once Group 4 is answered
- Draw the before-Wake-Up fold and fix Morning run's position (CR-021, I31).
- Now-bead motion and its polite announcement (CR-022).
- E-Minimal missing states: empty day, morning, evening, overrun, no current task, Day column hidden (rules §14.1 item 20).
- Mac Week grid non-grid alternative for screen readers (CR-107).
- Keyboard focus order when a task replaces the Day column, and horizon dot traversal (CR-105).
- Run VoiceOver, TalkBack and NVDA against the labels (CR-104) and measure contrast on glass (CR-106).
- CR-165 (2): selected sidebar row ⌘3 → #4E4757 (ED-214); Week Today header "3 of 9 · 7 h 40" → #4E4757 (ED-215). CR-165 resolved. CR-165 (4) closed (swipe state).
- Minimal task sheet title (logged as "Android Minimal edit title"): Manrope 800 21/26 kept on both phones (ED-216).
- ED-199 outliers reconciled (ED-217): Lunch corrected; board key exempt; Lands-at distinct.
- CR-143 resolved: ⌥⌘I toggles the right-hand pane in both modes (ED-218).
- Colour data Decision 1 (ED-219): brown, plum, olive as stored keys in two releases with forward-compatible validation.
- Colour data Decision 2 (ED-220): custom task colour = hex in color_key (C1), staged; Your colours storage moved to Decision 3.
- Colour data Decision 3 (ED-221): profiles.accent_hex + profiles.your_colours columns; colour data review complete.
- CR-160 screens (criteria 2 and 7) audited; A2 narrower wording applied on E-CR160 (ED-222); A3 wording and missing frames pending.
- E-CR160 A3 wording fixed, art decorative (ED-223).
- E-CR160 A1 Android and Mac/web frames added (ED-224).
- E-CR160 A2 sync-not-confirmed state on three platforms (ED-225).
- E-CR160 Android A2 hint added (ED-226).
- E-CR160 A3 Android and Mac/web frames added (ED-227).
- E-CR160 B1 Android and Mac/web frames added (ED-228); iPhone B1 large-text fix proposed.
- E-CR160 iPhone B1 large-text label fix applied (ED-229).
- E-CR160 "Choose settings" row on three platforms (ED-230); CR-173 resolved.
- E-CR160 read-only implementation handoff `E_CR160_HANDOFF.md` (ED-231); CR-160 stays CRITICAL — OPEN — RELEASE BLOCKER.
- CR-093 option A (ED-232): E-Minimal web uses the Mac split 200 / 790 / 290; web insets at 290; E-Map updated. Reconciliation correction: CR-006 and CR-050 reopened.
- ED-233: CR-093 follow-ups applied — web orb = Mac (280 / 100), "Hide the Day column" on web, ⌥⌘I in accessible names (E-Minimal, E-FullA-v2, E-G4-3-Narrow, light and dark).
- ED-234: phone tab bar / toolbar on every pushed Settings page, not on pull-ups or dialogs (E-Phones, E-PhonesMinimal, light and dark).
- ED-235: no tab selected in the phone bar on Settings pages (E-Phones, E-PhonesMinimal, E-Phones-3, light and dark).
- ED-236: E-G2-4 history board Settings frames get the phone bar (no tab selected).
- ED-237: E-SettingsReview Settings frames get the phone bar (no tab selected).
- ED-238: G2-3 option A approved; overall approval of Concept E moved to the release gate after Round 2 (STATUS); CR-033 and CR-047 resolved.
- ED-239: native Mac right-click menus (NSMenu); drawn Mac menus unified at radius 10; CR-025 resolved, CR-098 becomes a feasibility check.
- ED-240: the + is named "Add a task" on every platform (Android Full renamed, menu role added); CR-117 resolved.
- ED-241: now-bead 16 on phone threads, 14 on wide (Mac and web) and on the horizon; E-FullA-v2 web beads corrected; CR-015 resolved.
- ED-242: Minimal Day column state, the narrow Day panel and the Search or run palette get no address; CR-067 resolved.
- ED-243: stale board copy fixed (titles, header lines, tags relabelled with their decisions); CR-006 and CR-050 resolved; four tags without a decision kept and listed.
- ED-244: the last four board hypotheses approved (Focus from the big dot on phone and wide Minimal; no Inbox suggestions on an empty minimal day; thread optional beside the now-dot).
- ED-245: group 2 design fixes drawn on E-DF2 for review (before Wake Up fold; the moving now and Reduce Motion).
- ED-246: before-Wake-Up / after-Wind-Down fold and the moving now approved (E-DF2); CR-021, CR-022 resolved; CR-103 narrowed.
- ED-247: group 3 design fixes drawn on E-DF3 for review (focus order, the Week for screen readers, Reduce Transparency / Increase Contrast).
- ED-248: focus order on wide Minimal, the Week for screen readers, and Reduce Transparency / Increase Contrast approved (E-DF3); CR-103, CR-105, CR-107 resolved.
- ED-249: tablet coverage checklist written (`E_TABLET_CHECKLIST.md`); five tablet decisions (Q1 to Q5) await the owner before Round 2.
- ED-250: tablet Q1 mockups (A Workspace, B thread + second pane) on E-T1 for review.
