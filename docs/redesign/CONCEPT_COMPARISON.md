# Concept comparison (Prompt C)

**Status:** for owner review, 2026-11-03. Companion to `THREE_UX_CONCEPTS.md`.

Scores are design judgements made from the documents, not measurements. Prompt D's prototypes test them on real tasks.

**Concepts:**
- **A** = Refined Timeline.
- **B** = Productivity Workspace.
- **C** = Focus-First Planner.

**Baseline** = today's app (`UX_AUDIT.md` §2).

## 1. In one line each

| | Entry point | Signature | Wide windows become | Biggest bet |
|---|---|---|---|---|
| **A** | Today's thread | Dot + thread, finished (depth, filling thread, glowing now-bead) | Sidebar + day/three-day thread + inspector | Polish and organisation are enough |
| **B** | Today ("do") + Plan ("plan") | Time-proportional blocks on a grid; the dot is the block's chip | A planning workspace: Inbox/Routines/Brain dump beside a Day–Week canvas | People plan better with backlog and calendar side by side |
| **C** | Now (current task, orb) | The orb + day ribbon; a new identity | Now panel beside the Day thread | Answering "what now?" first reduces overwhelm |

## 2. Taps for key journeys

Compact = phone with a tab or nav bar. Wide = Mac, web or tablet at ≥ 840 by touch or pointer; keyboard shortcuts are in brackets.

| Journey | Baseline compact / wide | A compact / wide | B compact / wide | C compact / wide |
|---|---|---|---|---|
| Quick add with a time | 2 / 1–2 (⌘N) | 2 / 2 (⌘N, `n` on web) | 2 / 2 (⌘N, ⌘K) | 2 / 2 (⌘N) |
| Paste a list → tasks | 2 / 2 | 2 / 2 | 2 / 2 | 2 / 2 |
| Edit / reschedule (non-drag) | 3 / 2 | **2–3** / 2 (one task surface) | 3 / 2 | 2–3 current task; 3–4 others / 2 |
| Reschedule by drag | 1 drag | 1 | 1 (also across days on the canvas) | 1 on Day (2 from Now) |
| Complete | 1 / 1 | 1 / 1 | 1 / 1 | **1 current** (2 others) / 1 |
| Reopen | 1 / 1 | 1 / 1 | 1 / 1 | 1–2 / 1 |
| Change day: next / far | 1 / 3 wide | 1 / **2** (title → month) | 1 / 2 | 2 (Day tab first) / 2 |
| Shift the rest / Running late | 1–2 live row; 4 via ⋯ / 3 | 1–2 live row; 3 Day menu / **2** toolbar | 1–2 / 3 Replan menu | **2** ("More time" on Now) / 2 |
| Brain dump to Accept | 4 (⋯, today only) | 4 (Add → mode), every day | 4 (Plan section) | **3** ("Clear your head") |
| Drop a routine | 4 (⋯) | 4 (Add → Routine) | 3 wide (drag + Accept) / 4 compact | 3 (Now morning) / 4 otherwise |
| Inbox → timeline | 3 / 2 | **2** (tray + drag) / 1 drag | 3 / **1** drag | 3 (2 via a Now suggestion) / 1 drag |
| Change Wake Up time | 3 (or the cap) | 2 (cap → dial) / 3 Settings | 3 | 2 / 3 |
| Find Settings | 1 tab | 1 avatar / ⌘, | 1 avatar / ⌘, | 1 avatar / ⌘, |
| Find Brain dump the first time | needs ⋯ | visible on Add | visible in Plan | **visible on Now** |

`00-vision.md` targets:
- **Inbox → timeline ≤ 2:** A meets it everywhere; B and C only on wide windows.
- **Shift the rest in one gesture:** all three, from the live row.

## 3. The six-task acceptance exercise (playbook Step 7)

| Task | A Refined Timeline | B Workspace | C Focus-First |
|---|---|---|---|
| **1. Capture rapidly** | + → "Gym 6pm 1h" → Return; chips confirm. Brain dump is a visible mode. **Good** | Same on Today; the capture field is always open in Plan. **Good**; untimed items land in Inbox, out of sight on phones | + or "Clear your head" right on the entry screen. **Best for a crowded head** |
| **2. Plan a busy day** | Thread + Inbox tray + Day menu (routine, one thing, shift). Wide: three-day spread + inspector. **Good**; the phone still plans one day at a time | **Best on wide windows**: Inbox, routines and the week grid side by side with drag. **Weaker on phones**: Plan has segments, 3 taps per item | Morning Now proposes one thing + a routine, then Day for the rest. **Fine** for light days; heavy planning moves to Day, which is A's thread |
| **3. Edit / reschedule** | Merged task surface; drag; Move to… **Best on phones** | Inspector + canvas drag across days. **Best on desktop** | Current task from Now in 2; others via Day. **Good** |
| **4. Go to another day** | Strip/swipe; title → month (2); ⇧⌘G. **Good** | Plan canvas arrows, Month; title popover. **Good**, but there are two places to "be on a day" (Today vs Plan) | Day tab → strip or title. **One extra tap** from Now |
| **5. Find Settings** | Avatar / sidebar footer / ⌘,. Six jobs; search. **Good** | Same + contextual "… settings" links. **Good**; contextual links help experts | Essentials first, then all. **Best for newcomers**; experts take 1 more tap |
| **6. Narrow / wide desktop window** | Narrow: compact shell (bottom bar → rail). Wide: sidebar + thread + overlaying inspector; no 339 px squeeze. **Good** | Narrow: Plan collapses to tabs inside Plan. Wide: excellent. **Mid-width (840–1100) is crowded**: three columns compete | Narrow: Now only, Day one click away. Wide: Now + Day side by side. **Good**; the Mac mini window helps |

## 4. What each concept needs the owner to approve

**All 16 rows are design hypotheses, NOT APPROVED FOR IMPLEMENTATION** (owner, 2026-11-03). Row 15 is an option only; hold-to-select stays the default.

| # | Approval item | A | B | C |
|---|---|---|---|---|
| 1 | Settings leaves the tab bar (avatar, sidebar footer, ⌘,) | ✓ | ✓ | ✓ |
| 2 | Merge the task sheet, `/task/:id` page and editor panel into one task surface (entry points kept) | ✓ | ✓ | ✓ |
| 3 | Merge duplicates per parity §7 (alarm switch, times, test-alarm card, notification health, day review forms), keeping every entry point | ✓ | ✓ | ✓ |
| 4 | Today ⋯ replaced by an organised Day menu, with items enabled on every day | ✓ | (Replan menu) ✓ | ✓ |
| 5 | Brain dump plans into the day being viewed (instead of today only), if wanted | optional | optional | optional |
| 6 | New "Calendar" destination (Month on phones) | ✓ | — | sidebar only |
| 7 | Inbox stops being a tab (it moves into Plan) | — | ✓ | — |
| 8 | New "Review" destination; Past days moves out of Search | — | ✓ | — |
| 9 | Week agenda on compact widths (new presentation) | — | ✓ | — |
| 10 | Week snapping follows the user's setting (not a fixed 15 min) | — | ✓ | — |
| 11 | Brand: refine the dot/thread | ✓ (within brief §15) | — | — |
| 12 | Brand: blocks-on-grid workspace language, new palette | — | ✓ | — |
| 13 | Brand: orb + ribbon, new identity | — | — | ✓ |
| 14 | Now becomes the entry; Today renamed "Day" (`/today` still works); new `/now` | — | — | ✓ |
| 15 | iOS long-press: context menu with "Select" first, and drag on move (instead of hold-to-select). **Default keeps hold-to-select** (R-05); this is an option only | optional | optional | optional |
| 16 | Dial crossing midnight (Q8 domain change), before Prompt F builds it | ✓ | ✓ | ✓ |

**Ordinary adaptations** (no approval) include:
- the per-platform shells, sheets/popovers/menus, controls and Back;
- path URLs and selection in the URL;
- the Mac menu bar set;
- web single-key shortcuts;
- the fixes for R1–R6.

## 5. Criteria matrix

Scores: ● strong · ◐ adequate · ○ weak or at risk.

| Criterion | A | B | C |
|---|---|---|---|
| **Job 1:** timeline + what's next | ● | ◐ (two visual models) | ◐ (what's next ●, timeline one step away) |
| **Job 2:** replan in one gesture | ● | ● | ● (More time is primary) |
| **Job 3:** capture instantly (incl. Brain dump) | ● | ◐ on phones, ● wide | ● |
| **Job 4:** Wake Up to start the day | ◐ (card + missions) | ◐ (briefing) | ● (alarm → Now morning) |
| Feels: Calm | ● | ○ (density) | ● |
| Feels: Unjudged | ● | ● | ◐ (Now must never nag) |
| Feels: Supported | ◐ | ◐ | ● |
| Feels: Capable | ● | ● | ● |
| Feels: In control | ● | ● | ◐ (adaptive Now can surprise) |
| Feels: Focused | ◐ | ○ | ● |
| P1 Settings | ● | ● | ● (Essentials) |
| P2 iOS-native | ● | ● | ● (same baseline in all three) |
| P3 features buried | ● | ● | ● |
| P4 duplicates | ● | ● (Review hub) | ● |
| P5 dial | ● | ● | ● |
| P6 visuals | ◐ (refined, familiar) | ● (new) | ● (new) |
| P7 mission motion | ● | ● | ● |
| Real tablet and desktop, not a stretched phone | ◐ | ● | ● |
| Phone simplicity | ● | ○ | ● |
| Accessibility risk | low | **high** (grid) | medium (live updates) |
| Minimal mode stays distinct | ● | ● | ◐ (looks minimal already) |
| Build complexity | medium | high | medium-high |
| Reuse of current code (`REUSE_VS_REPLACE.md`) | high | low–medium | medium |
| Risk to current testers' habits | low | high | medium |

## 6. The downside of each concept (stated plainly)

- **A: least ambitious.**
  - It fixes everything the audits found but may still read as "the same app, nicer".
  - Wide windows stay a day thread rather than a real planning workspace.
  - The Day menu is still a menu.
  - If the owner wants a visual leap (P6), A delivers the smallest one.
- **B: the most likely to obscure core planning on phones and to overwhelm.**
  - Inbox moves one level down.
  - Scheduling from a phone takes 3 taps.
  - Two visual models (thread vs blocks) weaken "the timeline is the product".
  - The grid is the hardest thing to make accessible and the most expensive to build.
  - It's excellent on Mac, web and tablets, but phone users carry its weight.
- **C: the most likely to make the timeline feel secondary.**
  - Owner job 1 explicitly names the timeline.
  - An adaptive Now screen can surprise or feel like a nag when nothing is scheduled.
  - It needs a new identity, which is an approval and a brand risk.
  - Minimal mode and full mode start to look alike.
  - Heavy planners take an extra step to the thread.

**Playbook rule:** a concept that's attractive but obscures core planning shouldn't win. On that rule, B's phone experience and C's thread-second entry are the risks to test hardest in Prompt D.

## 7. Recommendation (Rec, not a decision)

- **Prototype all three in Prompt D** on iPhone, Mac, Android phone and web (Q7).
- **Shortlist A and C** for the full iPad and Android-tablet layouts.
- **Borrow B's strongest wide-window ideas** into whichever wins, as wide-width capability rather than a separate IA:
  - drag from an Inbox column onto a multi-day canvas;
  - the command palette (⌘K);
  - the contextual "… settings" links.
- **B's Review hub** can be judged separately as a P4 consolidation.
- **Why A and C:**
  - they protect phone simplicity and job 1;
  - they cover the two audiences the brief ranks equally (visual time-blockers and the "what's next" ADHD audience);
  - each has a clear, testable downside: A's ambition, C's thread-second entry.

## 8. Exit-gate self-check (playbook Step 7)

- **Genuinely distinct:**
  - A keeps the IA and the thread;
  - B changes the IA (Plan/Review) and the visual model (blocks);
  - C changes the entry point and the identity (Now/orb).
  - They aren't recolours of one layout.
- **Complete enough to prototype:** each defines:
  - destinations for every platform;
  - compact, medium and wide layouts;
  - capture, edit, complete, scheduling and calendar;
  - Settings;
  - Wake Up;
  - homes for every ⋯ item;
  - planned features;
  - accessibility risks;
  - complexity and approvals.
- **Not verified:**
  - **feasibility items:** native glass, SF Symbols, the Mac multi-window, web path URLs on the chosen host;
  - **runtime behaviour** on iPad landscape, Mac and foldables (Prompt B limits);
  - **real-device feel:** the evidence so far is simulator, emulator and local browser only.
