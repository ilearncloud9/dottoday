# Concept E — Refined Focus: versions

**Status:** LEADING CANDIDATE — NOT APPROVED FOR PRODUCTION IMPLEMENTATION. A version here is a design baseline. It does not authorise any implementation.

**Canvas (private):** https://claude.ai/artifact/FmSwyPQt7FrCh3fXPkkXX9, row "E · Refined Focus". The canvas and this folder do not sync. Copy the board files here whenever a new version is cut.

## v1.0 (2026-11-04): snapshot of the owner's latest Concept A

**Source:** canvas version `1793757110-10fc`, saved as `v1.0/canvas.source-1793757110-10fc.json`.

| E board (canvas id) | Copied from | File | Contents |
|---|---|---|---|
| `E-Phones.dc.html` | `A-Phones.dc.html` | `v1.0/E-Phones.dc.html` | iPhone Today, Add, Task actions + Day menu, Empty day; Android Today, Edit |
| `E-PhonesMinimal.dc.html` | `A-PhonesMinimal.dc.html` | `v1.0/E-PhonesMinimal.dc.html` | iPhone Now, Rest of today, Add, Empty, end of day; Android Now, Add |
| `E-Workspace.dc.html` | `A-Workspace.dc.html` | `v1.0/E-Workspace.dc.html` | Mac Plan Week, web Plan Day |
| `E-Focus.dc.html` | `A-Focus.dc.html` | `v1.0/E-Focus.dc.html` | Mac and web Now + Day + inspector |
| `E-Map-v1.0.dc.html` | `A-Map.dc.html` | `v1.0/E-Map-v1.0.dc.html` | A's map, preserved unchanged (historical) |
| `E-Map.dc.html` | new | not in v1.0 | Working map; first drafted 2026-11-04 |

**Integrity:** the copies are byte-identical to the A boards, so they still carry "A · …" headers. Check them with `shasum -a 256 -c v1.0/SHA256SUMS`.

**Visual snapshots:** no PNG renders exist. The canvas has no export here, and render checks were not run. The `.dc.html` files are the durable source and open on the canvas.

## v1.1 working (2026-11-04): wide minimal replaced

This is not an approved version. It records the working canvas so that the docs can point at a fixed copy.

**Source:**
- canvas version `1793767935-3ecd`, the owner's replacement, saved as `v1.1-working/canvas.source-1793767935-3ecd.json`;
- refreshed at `1793768854-76be`, after the E-Map v1.1 update and copy fixes on E-Minimal, saved as `canvas.source-1793768854-76be.json`.

`v1.1-working/` holds the refreshed files.

| E board | State in v1.1 | File |
|---|---|---|
| `E-Phones`, `E-PhonesMinimal`, `E-Workspace` | Unchanged; byte-identical to v1.0 | `v1.0/` |
| `E-Minimal.dc.html` | **New.** Mac/web minimal: C's layout in E's look, with the Day in the right column (ED-063, ED-064) | `v1.1-working/E-Minimal.dc.html` |
| `E-Focus.dc.html` | **Removed from the canvas** by the owner and replaced by E-Minimal. Kept as history | `v1.0/E-Focus.dc.html` |
| `E-Map.dc.html` | Working map, updated for v1.1 | `v1.1-working/E-Map.dc.html` (refreshed after the v1.1 update) |
| `E-Map-v1.0.dc.html` | Historical copy of A's map, unchanged | `v1.0/` |

The folder `working/` holds the first E-Map draft (2026-11-04, before v1.1). It is kept as history.

**v1.0 integrity:** re-checked on 2026-11-04, and all five sums still match.

## G1-1 options (2026-11-04): two Full Mac/web alternatives

These are not a version. They are comparison boards the owner asked for to choose G1-1 (ED-070). Neither is approved.

**Source:** canvas version `1793805093-4320`, saved as `g1-1-options/canvas.source-1793805093-4320.json`. Sums are in `g1-1-options/SHA256SUMS`.

| Board | Option | Contents |
|---|---|---|
| `E-FullA.dc.html` | A · E-Workspace is the Full default | Mac: opens on the Day grid with the Inbox column and inspector. Web: the same workspace at 3 days, dragging from the Inbox onto the empty Wed 4 |
| `E-FullB.dc.html` | B · timeline-led Today, Workspace inside Full | Mac: opens on the Today thread with the now card and the inspector. Web: Calendar opens Workspace's 3 days / Week / Month grid with the Inbox column |

Both show the same moment (Tue 3 Nov 2026, 10:42) in E's existing look, built from E-Workspace's parts. `E-Workspace` and `E-Minimal` are unchanged.

**Fidelity pass (canvas `1793807345-9db8`, ED-071):** the boards in this folder are the rebuilt ones. Option A embeds E-Workspace's own Mac and web frames byte-for-byte. Option B is assembled from E-Workspace markup. The first pass, redrawn from descriptions, is kept in `pass1/` with its own sums and canvas source.

**Live boards re-checked (2026-11-04, canvas `1793770633-85e7`):** the owner's last page save changed only serialization on `E-Phones`, `E-Workspace` and `E-Map` (`&` → `&amp;`, `checked` → `checked=""`). No content changed. The v1.0 sums still match the archived files.

## Option A v2 (2026-11-04): complete candidate

`a-v2/E-FullA-v2.dc.html` (canvas `1793809787-c4b9`, ED-072). It uses E-Workspace's frames with 15 listed edits, plus the Day, View and Go menus, the palette, the Settings row, the Full ↔ E-Minimal flow, and proposed keys and routes. Not approved. `E-FullA` (the fidelity-pass board) stays on the canvas as the previous revision.

## v1.2 working (2026-11-04): Group 1 and G2-1 to G2-4 merged

This folder is `v1.2-working/`: the approved boards after the Calendar, Settings and Wake Up and Wind Down merges (ED-079, ED-084), plus the updated E-Map.

| Board | Change |
|---|---|
| E-Phones | Calendar, Settings, and Wake Up and Wind Down rows |
| E-PhonesMinimal | Minimal Settings row |
| E-FullA-v2 | Settings row; Lists removed (ED-080) |
| E-Minimal | "Search or run" naming |
| E-Map | "Decided since v1.1" panel |

Canvas source `1793818041-761c`. Review boards and their revisions are in `g2-1-calendar/` and `g2-4/`.

## v1.3 working (2026-11-04): G2-5 option D merged

`v1.3-working/` holds E-Phones (F3 and F6 replaced, plus a Task editor section), E-FullA-v2 (colour and icon popover) and E-Map (Task editor line). Canvas `1793824402-8088`. The G2-5 review boards are in `g2-5/` (A/B, C, D r1 and r2, merge preview).

## v1.4 working (2026-11-04): G2-6 merged (ED-089)

`v1.4-working/` holds E-PhonesMinimal (new Task sheet row), E-Minimal (approved Mac task column and a new web column section) and E-Map ("Minimal task screen" line). Canvas `1793826732-d0c2`, saved with the copies. E-Phones is unchanged; only its canvas frame moved to 2760 × 8320 so nothing is clipped. The G2-6 boards (`E-G2-6`, `E-G2-6-Review`) are kept on the canvas and in `g2-6/` as history. Check with `shasum -a 256 -c v1.4-working/SHA256SUMS`.

## v1.5 working (2026-11-04): G2-8 merged (ED-091)

`v1.5-working/` holds E-Phones (F2 approved line, FAB inset tag, new Add modes row), E-FullA-v2 (Add modes · Mac and web) and E-Map (Add modes line). Canvas `1793829085-95f3`, saved with the copies. The historical `E-FullA` board was moved on the canvas (y 24050) so E-Phones does not cover it; its file is unchanged. `E-G2-8` stays as history (copy in `g2-8/`). Check with `shasum -a 256 -c v1.5-working/SHA256SUMS`.

## v1.6 working (2026-11-05): G2-9 merged (ED-093)

`v1.6-working/` holds E-Phones (insets 3 and 6: the four-group Full Day menu, approved), E-FullA-v2 (Drop a Routine…, Plan / Reality, labels approved), E-PhonesMinimal (Low-energy mode, Settings as the third item), E-Minimal (aligned names, new "Day menu (minimal, Mac and web)" section) and E-Map (Day menu line). Canvas `1793833662-a67e`, saved with the copies. Earlier versions of these boards stay in `v1.4-working/` and `v1.5-working/`; the decision board stays in `g2-9/`.

## G2-11 decision board (2026-11-05, ED-096)

`g2-11/` holds `E-G2-11` (web routes; recommendation A′ with D1–D4) with the canvas `1793837899-6a74` and sums. No E board changed.

## v1.46 working (2026-11-08): ED-179

`v1.46-working/`: E-G4-6-Dark-Frames, E-G4-6-Dark-Tokens, E-Phones, E-Phones-3, E-PhonesMinimal, E-Map and canvas.json as published at `1794093242-bd6c`; `captures/` (19 PNG pairs at 2×, 21-page PDF); generators; pre-change copies in `pre/`. Check with `shasum -a 256 -c v1.46-working/SHA256SUMS`.

## v1.45 working (2026-11-07): ED-178, Stage 2 visual review

`v1.45-working/`: E-G4-6-Dark-Frames (rebuilt), E-G4-6-Dark-Tokens, E-Map and canvas.json as published at `1794090984-0220` (boards, canvas) and `1794091034-fc53` (E-Map); `captures/` holds 19 light/dark PNG pairs at 2× and `G4-6-dark-stage2-review.pdf`; generators included; pre-change copies in `pre/`. Check with `shasum -a 256 -c v1.45-working/SHA256SUMS`.

## v1.44 working (2026-11-07): G4-6 Stage 1 complete, Stage 2 presented (ED-175 to ED-177)

`v1.44-working/`: E-G4-6-Dark-Tokens, E-G4-6-Dark-Frames (new) and canvas.json as published at `1794089382-1995`, E-Map at `1794089446-8841`, the generators (`dark.py`, `g46.py`, `g46_add.py`, `darkify.py`, `stage2.py`) and `macspike/` (sample source, measuring scripts, second-run captures); pre-change copies in `pre/`. Check with `shasum -a 256 -c v1.44-working/SHA256SUMS`.

## v1.43 working (2026-11-07): G4-6 Stage 1 (ED-174)

`v1.43-working/`: E-G4-6-Dark-Tokens (`1794088620-9ecd`), E-Map and canvas.json (`1794088693-ab41`, E-Map grown to 5300, E-Responsive moved to y 17820); `macspike/` holds the throwaway AppKit sample source, the measuring script and the six genuine captures; pre-change copies in `pre/`. Check with `shasum -a 256 -c v1.43-working/SHA256SUMS`.

## v1.42 working (2026-11-07): G4-6 Stage 1 (ED-173)

`v1.42-working/`: E-G4-6-Dark-Tokens (new decision board) and canvas.json as published at `1794087849-2977`; pre-change canvas in `pre/`. Check with `shasum -a 256 -c v1.42-working/SHA256SUMS`.

## v1.41 working (2026-11-07): G4-5 (ED-172)

`v1.41-working/`: E-MobileWeb (new), E-Responsive, E-Map and canvas.json as published at `1794086583-82a8`; pre-change copies in `pre/`. Check with `shasum -a 256 -c v1.41-working/SHA256SUMS`.

## v1.40 working (2026-11-07): ED-170, ED-171

`v1.40-working/`: E-G4-3-Narrow (approved reference), E-Responsive, E-Map, E-Minimal, E-FullA-v2 and canvas.json as published at `1794085999-d417`; pre-change copies in `pre/`. Check with `shasum -a 256 -c v1.40-working/SHA256SUMS`.

## v1.39 working (2026-11-07): G4-3 (ED-169)

`v1.39-working/`: E-G4-3-Narrow (new), E-G4-3, E-Responsive, E-Map and canvas.json as published at `1794085453-26c4`; pre-change copies in `pre/`. Check with `shasum -a 256 -c v1.39-working/SHA256SUMS`.

## v1.38 working (2026-11-07): H1 and M (ED-168), G4-3 board

`v1.38-working/`: E-Responsive (updated), E-G4-3 (new decision board), E-Map and canvas.json as published at `1794084987-b330`; pre-change copies in `pre/`. Check with `shasum -a 256 -c v1.38-working/SHA256SUMS`.

## v1.37 working (2026-11-07): G4-2 responsive (ED-167)

`v1.37-working/`: new board E-Responsive, E-Map and canvas.json as published at `1794084547-f629`; pre-change copies in `pre/`. Check with `shasum -a 256 -c v1.37-working/SHA256SUMS`.

## v1.36 working (2026-11-07): Group 3 follow-ups (ED-165)

`v1.36-working/`: E-Phones, E-Phones-2, E-PhonesMinimal, E-Minimal, E-FullA-v2 (at `1794083800-6a81`), E-Map and canvas.json (at `1794084013-af5b`, E-Map grown to 4600); pre-change copies in `pre/` (including E-Phones before the CR-135 comment fix as `pre/E-Phones.before-comment.dc.html`). Check with `shasum -a 256 -c v1.36-working/SHA256SUMS`.

## v1.35 working (2026-11-07): G3-12 Earlier fold (ED-164)

`v1.35-working/`: new board E-Earlier, plus E-PhonesMinimal, E-Minimal, E-FullA-v2, E-Map and canvas.json as published at `1794081347-9d2f`; pre-change copies in `pre/`. Check with `shasum -a 256 -c v1.35-working/SHA256SUMS`.

## v1.34 working (2026-11-07): G3-11 +5 / +15 / +30 (ED-163)

`v1.34-working/`: E-Phones, E-PhonesMinimal, E-Minimal, E-Workspace, E-FullA-v2 and E-Map as published at `1794080578-9c6b`; pre-change copies in `pre/`. Check with `shasum -a 256 -c v1.34-working/SHA256SUMS`.

## v1.33 working (2026-11-07): G3-10 one vocabulary (ED-162)

`v1.33-working/`: E-Phones, E-PhonesMinimal, E-FullA-v2, E-Minimal, E-Workspace and E-Map as published at `1794080104-b060`; pre-change copies in `pre/`. Check with `shasum -a 256 -c v1.33-working/SHA256SUMS`.

## v1.32 working (2026-11-07): G3-9b merged (ED-161)

`v1.32-working/`: E-Phones, E-Phones-2, E-Phones-3, E-PhonesMinimal, E-FullA-v2, E-Minimal, E-Workspace, E-Map and canvas.json as published at `1794079376-3bb6`; pre-change copies in `pre/`. Check with `shasum -a 256 -c v1.32-working/SHA256SUMS`.

## v1.31 working (2026-11-07): Android toolbar full-item selection (ED-160)

`v1.31-working/`: E-Phones, E-Phones-2, E-PhonesMinimal, E-Map and E-G3-9b-Screens as published at `1794078988-8928`; pre-change copies `*.pre-ed160.dc.html`. Check with `shasum -a 256 -c v1.31-working/SHA256SUMS`.

## g3-9b (2026-11-07): full palette review board, in progress

`g3-9b/`: E-G3-9b-Palette and canvas.json as published at `1794069976-3846`; E-G3-9b-Screens and canvas.json (`canvas-screens.json`) as published at the warm-suggestions version (see SHA256SUMS; earlier `1794076522-6494` added Appearance, theme thumbnails, Edit palette, ED-157 arcs; earlier `1794075277-13b2`, `1794075181-3ca1`, Mac/web approved ED-156; earlier `1794074754-21cb`, earlier `1794073821-df1e` and `1794071232-6244` superseded). Not approved. Check with `shasum -a 256 -c g3-9b/SHA256SUMS`.

## v1.30 working (2026-11-07): G3-9 ring tokens (ED-155)

`v1.30-working/`: E-Phones, E-Phones-2, E-PhonesMinimal, E-FullA-v2, E-Minimal, E-Workspace and E-Map as published (`1794066219-c3df`, E-Map `1794066237-c9f8`); pre-change copies `*.pre-ed155.dc.html`. Check with `shasum -a 256 -c v1.30-working/SHA256SUMS`.

## v1.29 working (2026-11-07): G3-8 tab labels (ED-154)

`v1.29-working/`: E-Phones, E-Phones-2 and E-Map as published at canvas `1794065740-e6cb`; pre-change copies `*.pre-ed154.dc.html`. Check with `shasum -a 256 -c v1.29-working/SHA256SUMS`.

## v1.28 working (2026-11-07): ED-152 / ED-153, Add tab actions and text fixes

`v1.28-working/`: E-Phones-2, E-PhonesMinimal and E-Map as published at canvas `1794065114-131a`; pre-change copies `*.pre-ed153.dc.html`. Check with `shasum -a 256 -c v1.28-working/SHA256SUMS`.

## v1.27 working (2026-11-07): synchronisation after ED-145 to ED-151

`v1.27-working/`: every active Concept E board (E-Phones, E-Phones-2, E-PhonesMinimal, E-Map, E-Minimal, E-FullA-v2, E-Workspace, E-PhonesCalendar) plus the edited history boards E-G2-8 and E-G3-7 and canvas.json, as published at canvas `1794062819-2967`; pre-change copy `E-Map.pre-v127.dc.html`. Check with `shasum -a 256 -c v1.27-working/SHA256SUMS`.

## v1.26 working (2026-11-07): G3-7 Full B, C, A frames show Create task (ED-151)

`v1.26-working/`: E-G3-7 and canvas.json as published at canvas `1794062664-54b1`; pre-change copies `E-G3-7.pre-ed151.dc.html` (before B) and `E-G3-7.pre-ed151b.dc.html` (before C and A) (the g3-7 snapshot keeps the original board). Check with `shasum -a 256 -c v1.26-working/SHA256SUMS`.

## v1.25 working (2026-11-07): proposal full screen, Android proposal (ED-150)

`v1.25-working/`: E-G2-8, E-Phones-2 and canvas.json as published at canvas `1794062098-7bf2`; pre-change copies `*.pre-ed150.dc.html`. Check with `shasum -a 256 -c v1.25-working/SHA256SUMS`.

## v1.24 working (2026-11-07): Routine full screen, Android Routine (ED-149)

`v1.24-working/`: E-G2-8 and E-Phones-2 as published at canvas `1794061948-9904`; pre-change copies `*.pre-ed149.dc.html`. Check with `shasum -a 256 -c v1.24-working/SHA256SUMS`.

## v1.23 working (2026-11-07): Android Brain dump full screen, G2-8 A5 (ED-148)

`v1.23-working/`: E-G2-8 and E-Phones-2 as published at canvas `1794061835-e89c`; pre-change copies `*.pre-ed148.dc.html`. Check with `shasum -a 256 -c v1.23-working/SHA256SUMS`.

## v1.22 working (2026-11-07): Brain dump full screen (ED-147)

`v1.22-working/`: E-G2-8 and E-Phones-2 as published at canvas `1794061690-7f36`; pre-change copies `*.pre-ed147.dc.html`. Check with `shasum -a 256 -c v1.22-working/SHA256SUMS`.

## v1.21 working (2026-11-07): G2-8 A1 shows Create task (ED-146)

`v1.21-working/`: E-G2-8 as published at canvas `1794061527-38aa`, built on `1794019141-7cd0`; pre-change copy `E-G2-8.pre-ed146.dc.html`. Check with `shasum -a 256 -c v1.21-working/SHA256SUMS`.

## v1.20 working (2026-11-06): Minimal editor steps and notes (ED-145)

`v1.20-working/`: E-PhonesMinimal as published at canvas `1793992927-edfa`; pre-change copy `E-PhonesMinimal.pre-ed145.dc.html`. Check with `shasum -a 256 -c v1.20-working/SHA256SUMS`.

## v1.19 working (2026-11-06): E-Phones split and sync of ED-137 to ED-142 (ED-144)

`v1.19-working/`: E-Phones (7920 px), the new E-Phones-2 (4120 px), E-Map (4380 px) and canvas.json as published at canvas `1793992626-6cd7`; pre-change copies `E-Phones.pre-split.dc.html` and `E-Map.pre-v119.dc.html`. Rendered content bottoms: E-Phones 7880, E-Phones-2 4063, E-Map 4338 (headless Chromium). Check with `shasum -a 256 -c v1.19-working/SHA256SUMS`.

## v1.18 working (2026-11-06): full editor steps and notes (ED-137)

`v1.18-working/`: E-Phones as published at canvas `1793989736-7f40`, built on the page-saved version `1793989065-5d95` (kept as `E-Phones.pre-ed137.dc.html`). Check with `shasum -a 256 -c v1.18-working/SHA256SUMS`.

## v1.17 working (2026-11-06): G3-7 keyboard follow-up (ED-136)

`v1.17-working/`: E-Phones and E-PhonesMinimal with the iOS 26 keyboard drawing, the completed step keyboard, the keyboard open / dismissed sections and the Android Gboard note, as published at canvas `1793947367-a40d` (E-FullA moved down on the canvas to clear the taller E-Phones). Pre-change copies `*.pre-kb26.dc.html` equal `v1.16-working`. Check with `shasum -a 256 -c v1.17-working/SHA256SUMS`.

## v1.16 working (2026-11-06): G3-7 C merged (ED-135)

`v1.16-working/`: E-Phones and E-PhonesMinimal (iPhone Add keyboards now stock, neutral return key) and E-Map, as published at canvas `1793946525-dc45`; pre-merge copies `*.pre-g37.dc.html` (E-Phones equals `v1.14-working`, E-PhonesMinimal and E-Map equal `v1.15-working`). Check with `shasum -a 256 -c v1.16-working/SHA256SUMS`.

## G3-7 decision board (2026-11-06, ED-134)

`g3-7/`: `E-G3-7.dc.html` as published at canvas `1793943183-08ac`. No active board changed. Check with `shasum -a 256 -c g3-7/SHA256SUMS`.

## v1.15 working (2026-11-06): F1 (a) merged, G3-6 resolved (ED-132, ED-133)

`v1.15-working/`: E-PhonesMinimal (five iPhone Minimal frames at the native three-tab capsule width with the 6 pt gap) and E-Map (phone-bottom-row line) as published at canvas `1793942349-5a4f`; pre-merge copies `*.pre-f1.dc.html` equal `v1.14-working`. Check with `shasum -a 256 -c v1.15-working/SHA256SUMS`.

## G3-6 compatibility results: F2 on iOS 18.6, N3 on iOS 26.5 (2026-11-06, ED-131)

`g3-6-compat/`: `E-G3-6-Compat.dc.html` and the updated `E-G3-6-Remaining.dc.html` as published at canvas `1793941932-48fa`; `captures/` holds the genuine Simulator captures (throwaway iPhone 16 Pro on iOS 18.6 and iPhone 17 Pro on iOS 26.5, synthetic data, both deleted after the run); `v18-summary.txt` and `v26-summary.txt` are the test app's measurement logs. Check with `shasum -a 256 -c g3-6-compat/SHA256SUMS`.

## G3-6 D6 approved; F2 choices and closing criteria (2026-11-06, ED-130)

`g3-6-d6-approved/`: `E-G3-6-Decision.dc.html` (D6 approved) and `E-G3-6-Remaining.dc.html` (F2 verification choices V1–V4, proposed G3-6 closing criteria) as published at canvas `1793937492-6ed8`. The ED-129 versions stay in `g3-6-remaining/` and `g3-6-decision-selected/`.

## G3-6 remaining questions: Mac warm tint and F2 findings (2026-11-06, ED-129)

`g3-6-remaining/`: `E-G3-6-Remaining.dc.html` as published at canvas `1793937030-1796`, with `captures/` (genuine: four Mac sidebar captures from the isolated Mac sample over a synthetic backdrop; three F2 captures from a throwaway iOS 26.5 Simulator in compatibility mode). Synthetic content only. Check with `shasum -a 256 -c g3-6-remaining/SHA256SUMS`.

## G3-6 decision board with the owner's choices (2026-11-06, ED-128)

`g3-6-decision-selected/`: `E-G3-6-Decision.dc.html` with the "Your decision" column, canvas `1793937030-1796`. The version before the choices stays in `g3-6-decision/`.

## G3-6 decision board, reopened with the approved phone rows (2026-11-06, ED-127)

`g3-6-decision/`: `E-G3-6-Decision.dc.html` as published at canvas `1793934718-fc4b` (`canvas.source-1793934718-fc4b.json`). Approved appearance, verified results, unverified questions, fallbacks and the architecture choices awaiting approval. Check with `shasum -a 256 -c g3-6-decision/SHA256SUMS`.

## v1.14 working (2026-11-06): phone bottom rows merged (ED-124, ED-125, ED-126)

`v1.14-working/`: E-Phones, E-PhonesMinimal and E-Map after the merge, as published at canvas `1793934718-fc4b` (`canvas.source-1793934718-fc4b.json`). The pre-merge copies are kept beside them as `*.pre-merge.dc.html` with the pre-merge index `canvas.pre-merge-1793931974-b8a6.json`; they equal E-Phones in `v1.12-working` and E-PhonesMinimal and E-Map in `v1.9-working`. `coverage-matrix.md` lists every phone frame checked (19 updated, 34 exempt). Earlier snapshots are unchanged. Check with `shasum -a 256 -c v1.14-working/SHA256SUMS`.

## G3-6 spike results with the iPhone run (2026-11-06, ED-121)

`g3-6-spikes-device/` holds `E-G3-6-Spikes` updated with section 1b (genuine captures and timings from the owner's iPhone). Canvas `1793927507-1ccc`. The earlier version stays in `g3-6-spikes/`. No E board changed.

## G3-6 Android bottom-row comparison (2026-11-06, ED-123)

`g3-6-android/` holds `E-G3-6-Android`: Android Full Today and Minimal Now as approved and in three drawn options (A approved layout with the + only; B + in the navigation bar's line; C Material 3 Expressive floating toolbar + FAB), "Add" replaced by the + in all. Canvas `1793930840-6595`. No E board changed.

## G3-6 iPhone bottom-row proposal (2026-11-06, ED-122)

`g3-6-bottom-row/` holds `E-G3-6-BottomRow`: the owner's request drawn on six Full and Minimal iPhone frames (now vs proposed), a 2× close-up, and genuine captures of a native build from the owner's iPhone (spike app, not Dottoday). Canvas `1793928658-0dfb`. No E board changed.

## G3-6 native feasibility spike results (2026-11-06, ED-120)

`g3-6-spikes/` holds `E-G3-6-Spikes` (results board with the genuine captures embedded). Canvas `1793924887-c726`. The experiment source, raw captures and logs are kept outside the repository, as the owner required, in the session scratchpad (`/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/a56f9682-4158-45e0-89f7-927795c669b9/scratchpad/spikes`); they are throwaway. No E board changed.

## G3-6 native-first exploration (2026-11-06, ED-119)

`g3-6-native/` holds `E-G3-6-Native` and, in `captures/`, the five genuine iOS Simulator screenshots it is built from (Apple Photos app, iPhone 17 Pro simulator, iOS 26.5, 6 Nov 2026: tab bar; tab bar with Reduce Transparency; glass controls over a photo by default, with Increase Contrast and with Reduce Transparency). They are Apple system UI with Apple's sample photos; no personal information. No Mac capture was taken (it would show the owner's desktop). Canvas `1793922300-995e`. No E board changed; `E-G3-6` unchanged (title only).

## G3-6 decision board (2026-11-06, ED-118)

`g3-6/` holds `E-G3-6` (glass and vibrancy: E-Phones iPhone and Android Today scrolled so tasks pass under the chrome, as drawn and with the translucent backgrounds made solid; the E-FullA-v2 Mac sidebar likewise; 2× close-ups; facts for A approximated, B native, C solid). Canvas `1793921025-dfd5`. No E board changed.

## v1.13 working (2026-11-06): G3-5 option C merged (ED-116)

`v1.13-working/` holds E-FullA-v2 after the merge (Lunch hover: tint and hairline; one caption line). Canvas `1793919701-ad03`. Every other E board is unchanged from `v1.12-working/` or earlier.

## G3-5 with option C (2026-11-05, ED-115)

`g3-5-option-c/` holds the revised `E-G3-5`: A, B and the owner's hybrid C side by side in the real E-FullA-v2 web Plan Day frame (hover row as drawn; drag row and close-ups with the Day menu closed, Lunch dragged over Deep work and Call with Sam), plus close-ups of rest, hover, drag and keyboard focus. The board as first presented (A and B only) stays in `g3-5/`. Canvas `1793919161-8dfd` (E-Phones frame height restored to 10520). No E board changed.

## G3-5 decision board (2026-11-05, ED-113)

`g3-5/` holds `E-G3-5` (hover lift on a web block: E-FullA-v2's web Plan Day frame as drawn and with Lunch flattened; 2× close-ups at rest, hover and dragging over another block; facts). Canvas `1793916412-27e3`, saved with the copy. No E board changed. Check from inside the folder: `shasum -a 256 -c SHA256SUMS`.

## G3-4 resolved (2026-11-05, ED-112)

`g3-4-resolved/` records the resolution: option A · teal. No E board changed; `E-G3-4.dc.html` is byte-identical to `g3-4/` (only its canvas title changed). Canvas `1793916412-27e3`.

## G3-4 decision board (2026-11-05, ED-111)

`g3-4/` holds `E-G3-4` (iOS switch colour when on: the four iPhone frames from E-Phones that show a switch, as drawn in teal and with the on colour changed to system green; 3× close-ups including On/Off Labels; facts with measured contrast). Canvas `1793914701-e1ae`, saved with the copy. No E board changed. Check from inside the folder: `shasum -a 256 -c SHA256SUMS`.

## G3-3 resolved (2026-11-05, ED-110)

`g3-3-resolved/` records the resolution: option A · Manrope. No E board changed; `E-G3-3.dc.html` is byte-identical to `g3-3/` (only its canvas title changed to "resolved"). Canvas `1793914701-e1ae`, saved with the copy. Type scale, text-size rules, implementation checks and tablet notes are in `E_DESIGN_RULES.md` §3.4–3.7.

## G3-3 decision board (2026-11-05, ED-109)

`g3-3/` holds `E-G3-3` (content typeface: E-Phones Today in Manrope, Inter and the system font; specimen; facts). Canvas `1793894754-fa5d`, saved with the copy. No E board changed. Check from inside the folder: `shasum -a 256 -c SHA256SUMS`.

## v1.12 working (2026-11-05): visual-review corrections merged (ED-108)

`v1.12-working/` holds E-Minimal (Day review column without the Week in review row; key hints in both minimal Day menus; the two flags replaced by "Reviewed · ED-108") and E-Phones (the six dimmed Todays with the G3-1 now card). Nothing else changed. Pre-merge copies: `v1.11-working/E-Minimal`, `v1.10-working/E-Phones`. Canvas `1793894587-d7ac`, saved with the copies. Check from inside the folder: `shasum -a 256 -c SHA256SUMS`.

## Visual review 1 (2026-11-05, ED-107)

`visual-review-1/` holds `E-V1`: the two flagged E-Minimal drawings as drawn, each with one proposed correction, and the six dimmed E-Phones Todays as drawn and with the G3-1 correction. Canvas `1793893513-fe26`, saved with the copy. No E board changed. Check from inside the folder: `shasum -a 256 -c SHA256SUMS`.

## v1.11 working (2026-11-05): G3-2 merged (ED-106)

`v1.11-working/` holds E-Minimal with G3-2 option A: the Mac orb centre (numeral 800 100 px, icon 26, "min left" 15) and the web orb centre (800 85 px, icon 22, label 13), one "Approved · G3-2 (ED-106)" caption line, and the "orb numeral 700" note removed. Nothing else changed; no other board changed. The pre-merge E-Minimal is the copy in `g3-1/`. Canvas `1793891919-04e5`, saved with the copy. Check from inside the folder: `shasum -a 256 -c SHA256SUMS`.

## G3-2 decision board (2026-11-05, ED-105)

`g3-2/` holds `E-G3-2` (one drawing for the orb: as drawn on four platforms, A one drawing, B plainer web), corrected 2026-11-05 (ED-106: option A's Mac and web orbs had been drawn too light by a font error), and `E-G3-2.as-presented.dc.html`, the board exactly as first shown. The "as drawn" orbs are cut unchanged from E-PhonesMinimal and E-Minimal. Canvas `1793888468-4491`, saved with the copy. No E board changed. Check from inside the folder: `shasum -a 256 -c SHA256SUMS`.

## v1.10 working (2026-11-05): G3-1 merged (ED-104)

`v1.10-working/` holds E-Phones with G3-1 option C · Both, revised, in Frame 1 (iPhone Today) and Frame 5 (Android Today) only: the now card (45 ring, 19/700 title, card grows with its text) and 32 px above and below the now group, plus an "Approved · G3-1 (ED-104)" caption line. Nothing else on E-Phones changed; no other board changed. The pre-merge E-Phones is the copy in `v1.9-working/`. Canvas `1793888292-5e78`, saved with the copy. Check from inside the folder: `shasum -a 256 -c SHA256SUMS`.

## G3-1 decision board (2026-11-05, ED-101, ED-102)

`g3-1/` holds `E-G3-1` (scale direction: A keep large, B C confidence, C both; phone frames copied from E-Phones F1 and F5, only the thread list changed in B and C) and `E-Minimal` with two amber "Drawn at merge · awaiting your visual review" tags added (Day review column, ED-099; minimal web Day menu, ED-093; tags only, frame unchanged at 4320). Updated 2026-11-05 (ED-103): option C replaced by the owner's sizes (45 ring, 19/700 title, 32 px gaps) and a checks section (compact phones, long title, 200 % text, scrolled, 2x thread alignment). Canvas `1793887095-8ede`, saved with the copies (the earlier canvas copy was replaced). No other E board changed. Check from inside the folder: `shasum -a 256 -c SHA256SUMS`.

## v1.9 working (2026-11-05): G2-12 merged (ED-099), Group 2 complete

`v1.9-working/` holds E-Phones (row "Day review and the When picker"; Day ▾ insets read Week in review; frame 9460 → 10520), E-FullA-v2 (row "Review and the When popover"; Mac and web Day menus read Week in Review; 5010 → 5740), E-Minimal (row "Day review (minimal, Mac and web)", the Day column; 3680 → 4320), E-PhonesMinimal (two captions) and E-Map (Day review and Week in review rows, Duplicate screens line; 4240 → 4320). On the canvas E-Workspace moved right (x 1134 → 2840) so the taller E-Phones does not overlap it; nothing else moved. Canvas `1793856664-fdc7`, saved with the copies. `E-G2-12` is unchanged (identical to `g2-12/`) and retitled on the canvas as the historical review board. Check from inside the folder: `shasum -a 256 -c SHA256SUMS`.

## G2-12 decision board (2026-11-05, ED-098)

`g2-12/` holds `E-G2-12` (duplicate screens: what is settled, Q1 one Review surface, Q2 one picker for “when?”, Q3 “This week” → Week in review; options A / B / C) with the canvas `1793851377-765f` and sums. No E board changed.

## v1.8 working (2026-11-05): G2-11 merged (ED-097)

`v1.8-working/` holds E-FullA-v2 (address bars and captions on `/#/`, route table resolved: `/search` without text, task links open on their date, Show Everything returns to the Full view you left), E-Minimal (`/#/now`, approved route line; the `/now` route left the Hypothesis line) and E-Map (Routes line, hash URLs; frame 4200 → 4240 so the new line fits). Labels only; layouts unchanged (same measured heights as v1.7 for E-FullA-v2 and E-Minimal). Canvas `1793850945-1f54`, saved with the copies. Check with `shasum -a 256 -c v1.8-working/SHA256SUMS`.

## G2-11 resolved board (2026-11-05, ED-097)

`g2-11-resolved/` holds `E-G2-11` with the corrected routing table (per layout), rules D and T, Back / Forward / Refresh, the links that must keep working, the one guard change and the verification table, with the presented board kept below it as history. Canvas `1793851377-765f` (the table's Settings row adds that Routines keeps `/settings/routines`). The presented version stays unchanged in `g2-11/`.

## v1.7 working (2026-11-05): G2-10 merged (ED-095)

`v1.7-working/` holds E-FullA-v2 and E-Minimal with the resolved key labels, and E-Map (Keyboard line). Canvas `1793837638-aed0`, saved with the copies; the canvas also restores E-Phones' frame (x 30, y 12480, 9460 tall). Earlier versions stay in `v1.5-working/` and `v1.6-working/`.

## G2-10 decision board (2026-11-05, ED-094)

`g2-10/` holds `E-G2-10` (one keyboard scheme; options A / B / C for ⌘1–4) with the canvas `1793834077-bbe4` and sums. No E board changed.

## Process for v1.1 and later

1. Change the E board on the canvas. Never edit the A boards to change E.
2. In the same change, add an entry to `../../E_DESIGN_DECISIONS.md` and update `../../E_DESIGN_RULES.md`, plus `E-Map` and `../../E_SCREEN_INVENTORY.md` where they are affected.
3. When the owner accepts a set of changes, cut `vX.Y/` here with copies, sums and the canvas version id, and add a row to this file.
4. Nothing in an E version is implementation approval. Production work needs Round 2, Prompt E and the owner's explicit go.
