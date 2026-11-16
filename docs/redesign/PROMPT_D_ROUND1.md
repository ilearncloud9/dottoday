# Prompt D · Round 1 (comparable visual prototypes)

**Status:** presented for owner review, 2026-11-03. Design exploration only: no Flutter code, no `lib/design_lab/`, nothing committed. Round 2 waits for the owner to approve two finalists.

**Canvas (private, Claude Design):** https://claude.ai/artifact/FmSwyPQt7FrCh3fXPkkXX9. Only the owner can open it until it's shared from the page's Share menu.

**Design system:** none. The organisation's default system belongs to another brand (Coupons.com), so Dottoday uses its own concept identities.

## What's on the canvas

| Row | Boards | Contents |
|---|---|---|
| Overview | `Main` | Three concepts side by side, evaluation (8 criteria), recommended finalists |
| A Refined Timeline | `A-Phones`, `A-Wide`, `A-Map` | iPhone Today / Add / task surface + Day menu / empty day; Android Today / Move with M3 dial; Mac + web workspace; feature access map, responsive map, §21 scorecard, strengths/problems/a11y/engineering |
| B Productivity Workspace | `B-Phones`, `B-Wide`, `B-Map` | iPhone Today ("do") / Plan / task sheet + Replan / empty; Android Today / M3 Schedule sheet; Mac + web Plan workspace with time grid, drag from Inbox, ⌘K; map, scorecard |
| C Focus-First | `C-Phones`, `C-Wide`, `C-Map` | iPhone Now / Add + Clear your head / More time + task surface + Day inset / empty Now; Android Now / Edit; Mac Now + Day + mini window, web; map incl. morning/day/evening/minimal states |
| Decisions | `D1-Settings`, `D2-TaskSurface`, `D3-Duplicates` | Option 1 vs Option 2 per decision, per-platform recommendations; each stamped NOT APPROVED FOR IMPLEMENTATION |

**Same data in every concept:**
- the synthetic Tue 3 Nov 2026 at 10:42;
- the overlap knot between Deep work and Call with Sam;
- the empty day, Wed 4 Nov.

**Copy check:** no "late / missed / failed / not done". An open task past its end says "ended 9:15 · still open"; running over says "Need more time?".

**iOS long-press stays hold-to-select** in every concept.

## Decision boards in brief (recommendations, not decisions)

- **D1 Settings:** Option 2 (out of the tab bar) everywhere, most strongly on Mac (⌘, window). The alternative offered: keep the Settings tab on phones only, if discoverability matters more.
- **D2 Task surface:** Option 2 (one surface).
  - iPhone: detents.
  - Android: an M3 sheet whose Back steps down through states.
  - iPad, Mac and web: a popover or inspector, with `?task=` in the URL.
  - Autosave vs explicit Save is an owner call.
- **D3 Duplicates:**
  - **Consolidate:** the day review sheet and page, the three Inbox scheduling sheets, minimal "Everything else", task detail, and the Wake Up/Wind Down times.
  - **Keep the entries, one screen:** the alarm switch, test alarm, notification health, layout, low-energy, Routines, alerts, account/sync, Running late.
  - **Keep both:** Add vs the Inbox field, and the Today vs spread headers.
  - **Owner call:** Month.
  - **Rename:** "This week".

## Evaluation and finalists

See the `Main` board.
- **Unweighted totals are close:** A 30 · B 30 · C 31.
- **Recommended finalists (not a choice):** **A and B.** Together they cover the timeline-first job and real large-screen planning. B's Today already carries C's Now card.
- **Alternative:** B and C.

## Concept E — Refined Focus (added 2026-11-04)

**Status (history):** written as LEADING CANDIDATE before Round 2. Concept E is approved for production implementation since ED-353 (2026-11-15).

- **What it is:** E v1.0 is an exact copy of the owner's latest modified A boards (canvas version 1793757110-10fc): `E-Phones`, `E-PhonesMinimal`, `E-Workspace`, `E-Focus`, plus `E-Map-v1.0` (the A map, kept unchanged as a historical snapshot) and a new working `E-Map`. The copies keep their "A · …" headers so they stay byte-identical; SHA-256 sums are in `references/concept-e/v1.0/SHA256SUMS`.
- **Concept A on the canvas:** left as the owner edited it (A-Wide and A-Minimal were deleted by the owner before E was made). Not restored.
- **Docs:** `E_DESIGN_RULES.md` (design system), `E_DESIGN_DECISIONS.md` (61 logged decisions: accepted, rejected, proposed, needs verification), `E_SCREEN_INVENTORY.md`, `E_CONSISTENCY_REPORT.md`.
- **Score:** on the Main board's 8 criteria E totals 28 (A 30 · B 30 · C 31). E was scored independently from its boards. Implementation risk scores 2 because it has two wide shells (Workspace and Focus) still to reconcile.
- **Versioning:** v1.0 is the baseline snapshot. Every later change is v1.1+ and updates the board, `E_DESIGN_RULES.md` and `E_DESIGN_DECISIONS.md` together. Canvas and repo do not sync automatically.

**v1.1 (working, 2026-11-04):**
- **What changed:** the owner replaced E's Mac/web minimal layout. `E-Minimal` (C's minimal layout in E's look) replaces `E-Focus`, which is removed from the canvas and archived in `references/concept-e/v1.0/`. Focus as a product feature is unchanged. Whether E keeps a full wide Focus presentation is an open decision.
- **Docs:** decisions ED-062 to ED-064, `E_DECISION_REGISTER.md` (one consolidated list of open decisions, reviewed in four groups), and the v1.1 sections of the rules, inventory and consistency report.
- **Canvas version:** `1793767935-3ecd`.
- **Group 1 (2026-11-04):** two modes (Full, Minimal); Focus a feature; Workspace = planning inside Full; Now leads in Minimal; the switch lives in the Day menu and Settings row 1; Minimal navigation kept as designed per viewport (ED-065 to ED-069). G1-1 resolved as Option A: Full on Mac/web is the Workspace, candidate board `E-FullA-v2` (ED-070 to ED-073).

**Older instructions that conflict with E (not overwritten):**
- `THREE_UX_CONCEPTS.md` §3.1 gives A's content font as Inter and A's palette as cobalt on #F7F6F2; E uses Manrope and C's warm palette with teal.
- The "Concept identities" section of the Round 1 brief describes A with halos and a glowing bead. E rejected both (decision log ED-023).
- The "What's on the canvas" table above still lists `A-Wide`. The owner has since deleted it.
- `CLAUDE.md` §11's no-"late" copy rule conflicts with the "Running late" labels on E's menus. See the consistency report.

## Not prototyped or not validated in Round 1

- **Not prototyped:** iPad, Android tablet/foldable, mobile web, and narrow Mac/web windows. These are Round 2 for the finalists. Before Round 2 begins, the comprehensive tablet coverage checklist is prepared and shown to the owner (mandatory, owner sequencing 2026-11-04; see `STATUS.md` Open items).
- **Not rendered or checked by Claude:** the canvas instructions forbid render checks unless asked. Board heights are the agents' estimates, and visual finish is judged from the design, so it needs the owner's eye.
- **Labelled design-only or feasibility:**
  - Apple glass and vibrancy, approximated;
  - SF Symbols chrome;
  - C's Mac "Now" mini window, a new window type;
  - web path URLs on the chosen host.

## Things the agents noted

- **Invented filler sample data** (synthetic, not real): Deep work's subtasks and notes, other days' blocks, the pasted list lines, and some menu shortcuts (⌘M, ⌘D, ⇧⌘→).
- **C's orb shows 82 % elapsed as briefed.** 9:00–11:00 at 10:42 is actually 85 %; fix it in Round 2.
- **Move tile discrepancy:** the decision agent found the task sheet's Move tile still wired to an action in code, while `FEATURE_PARITY_MATRIX.md` calls it dead. Re-check before relying on that finding.
