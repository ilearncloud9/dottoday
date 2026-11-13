# Concept E — Refined Focus: design rules

**Status: LEADING CANDIDATE — NOT APPROVED FOR PRODUCTION IMPLEMENTATION.**
Branch `redesign/design-lab` only. `DESIGN_PRINCIPLES.md` and ADR RD-0001 still govern. Nothing here is a production spec until the owner approves Concept E.

This file records the design system that the Concept E boards actually draw, so new screens stay consistent. Where the boards are silent, it says **UNRESOLVED** instead of inventing a value. Decisions and their reasons live in `E_DESIGN_DECISIONS.md` (written separately); this file holds the rules and tokens.

---

## 0. v1.1 changes (2026-11-04)

| Item | Value |
|---|---|
| Version | **E v1.1**, 2026-11-04, live canvas version `1793767935-3ecd` |
| Boards on the canvas | `E-Phones`, `E-PhonesMinimal`, `E-Workspace` (all three byte-identical to v1.0), **`E-Minimal` (new)**, `E-Map` (working map), `E-Map-v1.0` (historical) |
| Removed from the canvas | **`E-Focus`**, by the owner (ED-062). Its v1.0 copy stays at `references/concept-e/v1.0/E-Focus.dc.html` |
| Repo copy of the new board | `references/concept-e/v1.1-working/E-Minimal.dc.html` (byte-identical to the live board, checked 2026-11-04) |
| Decision log | ED-062 (E-Focus removed), ED-063 (E-Minimal built), ED-064 (replacement recorded as the owner's stated decision) |

What changed:
1. **E-Minimal replaces E-Focus as E's wide (Mac/web) minimal layout.** The owner removed E-Focus and stated: "I have completed the redesign and replacement of Concept E's Mac and Web Minimal Layout." (ED-064.) This is the only structural decision v1.1 records.
2. **E-Minimal** is C · Minimal's Mac/web layout in E's look: Mac = flat sidebar 200 (Now, Inbox, Calendar, Search) · Now pane 790 (flat horizon 7 AM–11 PM, teal now-bead, large now-dot, Done / Focus / Need more time?, Also now + Next, Add) · right column 290 showing the Day thread by default; opening a task replaces the Day with the task screen in that column, ✕ or Esc returns to the Day, ⌥⌘D / "Hide the Day column" folds the column. Web = sidebar 210 · Now 560 · Day thread 510, `/now` and `?task=`. Insets: menu bar with View menu and status item, task screen in the column, Now mini window, Everything else finder (⌘K / `k`), and a "Minimal hides, never removes" band.
3. **Focus the feature is not removed.** The task Focus action, the focus session, ⌘F, "click the big dot for Focus" and the Now mini window all remain. What has **no active board** is a full wide *Focus presentation* (C's Now + Day + inspector with the full sidebar, as E-Focus drew it). Whether E keeps one is **AWAITING OWNER DECISION** (§9).
4. Token and component sections now take Mac/web minimal values from **E-Minimal**. Where E-Focus was the source, its values are kept under "Historical (v1.0, E-Focus)" instead of being deleted.
5. Where E boards disagreed, E-Minimal followed E-Focus (no sidebar blur, Delete ⌫, ⌘1–4 = Now/Day/Calendar/Inbox, ⌘K = Everything else finder that also searches, "Gentle Day", +15/+30 (superseded: ED-162 names, ED-163 +5 / +15 / +30), `/now`, now ring track `#E4E3F7`, calendar dot centre white, orb numeral 700 (superseded by G3-2, ED-106: 800 everywhere), web focus ring 3 px at 45 %). It also replaced "Running late" with "Need More Time…". These are the board's choices for the minimal wide layout only. `E-Workspace` and the phone boards are unchanged, so the cross-board inconsistencies in §14.2 still stand; the ones E-Minimal takes a side on are marked there.
6. New inconsistencies that E-Minimal introduces are listed in §14.3.

---

## 1. Status and versioning

| Item | Value |
|---|---|
| Version | **E v1.1**, 2026-11-04 (canvas `1793767935-3ecd`). Previous: E v1.0, snapshot of 2026-11-04 (canvas `1793757110-10fc`) |
| What v1.0 is | An exact copy of the owner's latest modified Concept A boards on the Claude Design canvas |
| What v1.1 is | v1.0 minus `E-Focus` (removed by the owner) plus `E-Minimal` (new wide minimal layout) — §0 |
| Source boards (v1.1) | `E-Phones.dc.html`, `E-PhonesMinimal.dc.html`, `E-Workspace.dc.html`, `E-Minimal.dc.html`; `E-Map.dc.html` (working map, being updated); `E-Map-v1.0.dc.html` (historical) |
| Historical source | `references/concept-e/v1.0/E-Focus.dc.html` — reference only; not a rule source where it differs from a live board |
| Verified | v1.0: the five `E-*` files were byte-identical to `A-Phones`, `A-PhonesMinimal`, `A-Workspace`, `A-Focus` and `A-Map`. v1.1: `E-Phones`, `E-PhonesMinimal`, `E-Workspace` are still byte-identical to v1.0 |

Rules for later versions:
- **v1.1 and later** are reviewed refinements only. Each one gets a version number and a date.
- **Every change updates three things together:** the board on the canvas, this file, and the decision log (`E_DESIGN_DECISIONS.md`).
- **The canvas and the repo do not sync automatically.** A board change is not real in the repo until this file is updated, and the reverse.
- **The boards are the truth.** If this file and a board disagree, the board wins until the conflict is logged and resolved.
- `E-Map-v1.0` is **historical**. Its feature map predates the E presentations (Focus, Workspace, and in v1.1 E-Minimal) and is not a rule source where it disagrees with them.
- `E-Focus` (v1.0) is **historical** from v1.1. Its values are quoted below only as "Historical (v1.0, E-Focus)".

Known housekeeping gaps (not design decisions):
- Inside `E-Phones`, `E-PhonesMinimal` and `E-Workspace` the `<title>` and `<h1>` still read "A · …". `E-Minimal` is titled "E · Minimal · Mac and web".
- v1.0: the local `canvas.json` did not register the `E-*` boards. v1.1: the live `canvas.json` registers `E-Phones`, `E-PhonesMinimal`, `E-Workspace`, `E-Minimal`, `E-Map`, `E-Map-v1.0`.
- `E-Minimal`'s own header text still says it "sits beside E-Focus and E-Workspace and replaces neither", and its band says Show everything "Opens E-Focus". Both predate the owner's removal of E-Focus (§14.3 N1, N2).

---

## 2. Brand identity and distinctive elements

The day is **one thread of dots**. The timeline is the product. Everything else is chrome around it.

| Element | What it is | Where seen |
|---|---|---|
| **Task dot** | A circle per task, in the task's colour, with the task's icon inside. Its fill says its state (§5). | Every board |
| **Thread** | A 4 px vertical line joining the dots. Solid in task colours for time that has passed; dotted grey for time ahead. | Phones Today, E-Minimal Day column, Workspace grids (v1.0: Focus Day) |
| **Horizon** | The thread laid flat (3 px), 7 AM to 11 PM, with small dots. A day-at-a-glance strip. | PhonesMinimal Now/Empty/Add, E-Minimal Now pane (replaces C's ribbon) (v1.0: Focus Now panel) |
| **Now-bead** | A teal bead on the thread at the current time, with a time pill and a faint line across. | Phones Today, E-Minimal horizon and Day column (replaces C's now notch), Workspace (v1.0: Focus Day) |
| **Now-dot / orb** | The current task's dot drawn large, with a progress ring for elapsed time and minutes left in the centre. | PhonesMinimal Now, E-Minimal Now pane (replaces C's orb), Mac status item, Now mini window (v1.0: Focus Now panel) |
| **Overlap knot** | Two interlinked strokes in the two overlapping tasks' colours. Overlaps are allowed and drawn, never blocked. | Phones Today, task sheet, E-Minimal Day column and "Also now", Workspace grid edge |
| **Wake Up / Wind Down caps** | A sun cap at the top of the day and a moon cap at the end. | Phones Today/Empty, Minimal, E-Minimal (horizon ends; Wind Down only in the Day column, which opens on the Earlier fold), Workspace web header (v1.0: Focus) |
| **Free time** | Text between rows: "45 min free", "1 h 30 free · add here". | Phones Today, E-Minimal Day column ("1 h 30 free"; web "· add here"), Workspace web (v1.0: Focus Day) |
| **Day menu** | One grouped menu (Replan, Plan, Reflect, View, Share) that replaced the old ⋯ catch-all. | All boards |
| **Liquid Glass chrome (iOS)** | Tab bar, + (teal tinted glass, ED-124), Day chip, Sync/avatar capsule, "‹ Today" capsule, Close button, Day pull-down. | Phones, PhonesMinimal |

Not drawn on the E boards although older docs describe them:
- Dot "depth" (soft inner highlight and task-colour halo) from `THREE_UX_CONCEPTS.md` §3.1. E dots are **flat**. This was rejected in ED-023. The board headers still say "dots with depth"; fixing that copy is a v1.1 item.
- A "glowing" bead. The E bead has a 1 px teal ring and no glow (ED-023). The motion of the bead is **UNRESOLVED** (§7.5).

**Rejected (never reintroduce; the IDs are in `E_DESIGN_DECISIONS.md`):**
- Floating glass sheets on iPhone (ED-036). The owner undid them; sheets stay solid.
- An Inbox tray button on phones, or a line above the tab bar for a tray (ED-037). Inbox is a tab with a badge.
- Glass rims (edge highlights) on Android.
- Halos, glows and glossy dots (ED-023).
- The apricot accent `#F2A65A` and apricot tags (ED-016).
- Wind Down in lavender, or Wake Up in apricot (ED-018). The caps keep their original colours.
- Solid chips for every task (ED-010).
- The floating inset sidebar shape (ED-014). Sidebars are flat and full height.
- iOS system colours on swipe actions (ED-029), and the iOS blue "done" return key (ED-030).
- A-Wide's thread-only wide layout and A-Minimal's wide minimal layout, both deleted by the owner (ED-003, ED-002). v1.1: the wide **minimal** replacement is `E-Minimal` (owner statement, ED-064). A wide thread-only **Standard** replacement still needs an owner decision.
- C's ribbon, apricot now notch and orb styling on wide: E-Minimal redraws them as the horizon, the teal now-bead and E's now-dot (ED-063).

---

## 3. Typography

### 3.1 Families per surface

| Surface | iPhone | Android | Mac | Web |
|---|---|---|---|---|
| **Content** (task titles, times, free time, summary line, orb, sheets' task content) | Manrope | Manrope | Manrope | Manrope |
| **System chrome** (nav/tab bars, menus, segmented controls, switches, system buttons, keyboard) | `-apple-system`, SF Pro Display (≥ 20 px), SF Pro Text | Roboto | `-apple-system`, SF Pro Text | `system-ui, -apple-system, 'Segoe UI', sans-serif` |
| Numerals | Tabular (`font-variant-numeric: tabular-nums`, `tnum`) everywhere | same | same | same |

- Manrope weights loaded: 400, 500, 600, 700, 800. Roboto: 400, 500, 700.
- SF fonts are never bundled (`DESIGN_PRINCIPLES.md` K6). On the boards they are `-apple-system` references.
- **Content family: Manrope. RESOLVED 2026-11-05 (G3-3 option A, ED-110).** Manrope is used for task names, descriptions and notes, times, the large Now-dot numbers, task sheets and other branded content on all four platforms. Chrome keeps each platform's system typography (K6). `THREE_UX_CONCEPTS.md` §3.1 (Inter) is superseded for E. The built app's Inter is replaced at implementation (§3.5).
- What counts as content inside native sheets is being audited: see §3.7 (found while recording G3-3, awaiting the owner).
- Web sidebar brand name "Dottoday" is Manrope 700 16 px; other web chrome is system-ui.

### 3.2 Content scale (Manrope)

"Mac / web Minimal" is `E-Minimal` (v1.1). The last column keeps the v1.0 `E-Focus` values as history only.

| Role | Phones | Mac / web Minimal (E-Minimal) | Workspace blocks | Historical (v1.0, E-Focus) |
|---|---|---|---|---|
| Summary line | 700 15/20 `#6A6273` ("3 of 9 done · 7 h 40 planned"; minimal shows time) | Mac toolbar 700 13 "Now 10:42 · Wind Down at 11:00 PM"; web 700 14 "Wind Down at 11:00 PM" under the date. Time, no counts | 700 13 (web day header) | 700 13 (Mac toolbar), 700 14 (web) |
| Pane heading | — | Mac "Now · 10:42" 700 15/20 (time in teal); "Day" 700 15 (Mac column) / 700 17 with ▾ (web) | — | — |
| Row time | 400 13 `#6A6273` (now row 14) | 12.5 | 11 | 12.5 |
| Row title | 700 17, line-height 1.25 | 700 15 | 700 12.5 (short pill 11) | 700 15 |
| Now row title | 700 19/24 on Full Today (G3-1, ED-104); 700 18, line-height 1.3, in Minimal's Today tab | 700 16 (Mac) / 700 17 (web) | 700 11.5 (Mac narrow block) | 700 17 |
| "Now, 18 min left" | 700 `#11615C` (14 in the time line) | 700 12.5 (Mac, own line) / 700 13.5 (web, in the time line) `#11615C` | — | 700 13.5 `#11615C` |
| Free time / overlap label | 13 `#6A6273` | 12.5 | 12.5 (web) | 12.5 |
| Cap label ("Wind Down · 11:00 PM") | 14 `#6A6273` | 13 | 11.5 (web header) | 13 |
| Now pill ("10:42") | 700 13/18 `#11615C` | 700 13/18 | 700 11.5/16 | 700 13/18 |
| Sheet / task-screen title | 700 22/28, −0.2 px | task screen in the column 700 17/22 | inspector 700 18/23 | inspector 700 17/22 |
| Minimal Now task title | 700 26/32, −0.3 px | 700 24/30 (Mac) / 700 22/28 (web), −0.3 px; time below 700 15/20 `#6A6273` | — | Focus Now 700 22 |
| Orb numeral ("18") | 800 84/1, −0.05 em (Android 80) | 800 100/1 (Mac) / 85/1 (web), −0.05 em (G3-2, ED-106; was 700 76 / 64) | — | **700** 56 (Mac) / 60 (web), −0.04 em |
| "min left" | 600 13 `#6A6273` | 600 13 | — | 600 12–13 |
| "Also now" / "Next" rows | label 700 12 (iOS) / 500 12 (Android); title 700 16; time 14 | label 700 12 `#6A6273`; title 700 15 (Mac) / 14 (web); time 700 13 `#4E4757` | — | Next/Then label 700 13; title 700 15 |
| Empty-day hero ("16 h free") | 800 28/34, −0.5 px; minimal orb 800 80 | **UNRESOLVED** (no empty wide minimal frame) | — | — |
| Empty-day body | 15/22 `#6A6273` | — | — | — |
| Primary button label | 700 15–16 | 700 14 (Done / Focus / Need more time?, 40 tall) | 700 12 | 700 13–14 |
| Chip label | 700 14 (`#0B4642` on `#E2EFEC`) | +5 / +15 / +30 700 13 on `#E2EFEC` (web popover); Tomorrow / Later / Move… 700 13 outlined | 700 11.5 | 700 12 |
| Add field input | 500 19 (iPhone full), 600 20 (iPhone minimal), 600 19 (Android minimal) | 500 13 in a 40 px pill (Mac Now pane) | 13 (capture field) | — |
| Horizon labels | 12 `#6A6273`; now 700 12 `#11615C` | same | — | 12 |
| Inbox / routine rows | — | — | 700 14 title, 12.5 meta | — |
| Finder (Everything else) | — | input 15; group header 600 11 `#6A6273`; rows 13, 32 tall; footer 11.5 | ⌘K palette | — |

### 3.3 System chrome scale

| Role | iPhone | Android | Mac | Web |
|---|---|---|---|---|
| Date title | 700 28/34 SF Pro Display, in the nav row with the profile capsule | Roboto 400 24/32 in the M3 top app bar, filled ▾ | 700 15 in the toolbar ("Tuesday, 3 November"), a 30 px button that opens a date chooser; ‹ › day buttons in a `#ECE5DC` capsule (E-Minimal; same in v1.0 E-Focus) | Manrope 700 20/26, −0.3 px in the Now pane, "Tue 3 Nov · 10:42" (E-Minimal; v1.0 E-Focus same size) |
| Tab / nav label | 10 px, 600 selected / 500 other | 12 px, 600 selected / 500 other | sidebar 13 px (600 selected), rows 32; group header 700 11 (full sidebars only; E-Minimal has no groups) | sidebar 14 px (700 selected), rows 36 |
| Day chip / button | 700 15 | 500 14 | ~~700~~ **500 13 system font** (ED-206), 30 tall, outlined `rgba(36,31,43,.12)` on `#FFFDF9` (E-Minimal Day column) | ~~700 13 Manrope~~ **500 13 `system-ui`** (ED-206), 32 tall, "Day menu" (E-Minimal) |
| Menu row | 400 17/22, row 44; section header 13/18 `#6A6273` | 14, row 44; section header 500 12/16 `#4E4757` | 13, row 22; shortcut 12 `#6A6273`; checkmark column 12 (View menu) | Day menu popover **UNRESOLVED** (not drawn, also not in E-Minimal). Drawn web popovers: Need more time? (E-Minimal) and the finder rows 13/32 |
| Sheet nav row | Cancel 400 17, title 600 17, Add 600 17 (teal) | sheet title 400 22/28 | — | — |
| Segmented control | 600 13/18 | — | 500/600 12 (range tabs) | 500/700 (range tabs) |
| Dialog label | — | 500 12/16, +0.4 px | — | — |
| Time picker digits | — | 400 52/64 | — | — |

Inconsistency: the Android Edit sheet sets the task title in Roboto 400 24/30, not Manrope (`E-Phones` frame 6). Task titles are content, so this is flagged in §14.

### 3.4 Text size and accessibility (G3-3, ED-110)

The scale in §3.2–3.3 is the 100 % size. Every role follows the person's text-size setting up to 200 % (CLAUDE.md §5); nothing is clamped to make it fit.

| Setting | iPhone / iPad | Android | Mac | Web |
|---|---|---|---|---|
| Source of the size | Dynamic Type (content scaled by the same text scaler as SF chrome) | Font scale (Android 14+ scales non-linearly: large roles grow less than small ones) | No system-wide Dynamic Type. How the app follows Mac text size, or offers its own ⌘+ / ⌘−: **UNRESOLVED**, implementation check in §3.5 | Browser text size and zoom; sizes in rem so both work |
| Chrome | Native controls scale themselves | same | same | system-ui elements in rem |

- **Ratios stay fixed.** Line height scales with size; letter spacing in em stays as specified.
- **Wrap, never shrink.** Task titles, notes and labels wrap; content is never shrunk to fit. The now card already wraps and never truncates (§5.3, ED-104). The one drawn exception: 7 single-line task rows in the Calendar frames on E-Phones end in an ellipsis. They stay as drawn; at large text sizes they show up to two lines before the ellipsis, and the full title is in the screen-reader label. That behaviour was chosen here because the specs were silent. **Proposed, for accessibility verification (ED-112, register A11Y-V2):** the Calendar frames stay exactly as drawn at default text size; the two-line behaviour is checked at large sizes before it counts as approved.
- **Heights are minimums.** Rows, the now card (80 / 82, ED-104), chips and buttons grow with their text. G3-1 measured the phone Today at 200 %: rows grow, the hero title wraps to two lines, no overlap or clipping (ED-103).
- **Times** keep tabular figures. At 200 % a time line may break after "·" onto its own line.
- **Re-stacking:** task-sheet tiles re-stack to two rows at 200 % (Map); chip rows wrap to a second line.
- **Sized to geometry, not text size:** the orb numeral (0.36 of the orb diameter, G3-2) and the empty-day orb. The same remaining time is also in "min left", the time line and the screen-reader label, which all scale. G3-2 measured the centre stack with "min left" at 200 %: Mac 169 of 179, web 145 of 153, iPhone 144 of 150 (fits).
- **Bold Text** (iOS) / bold text (Android): 400 and 500 content roles draw at 600; 600–800 stay. Chosen here because the specs were silent (CLAUDE.md §10). **Proposed, for accessibility verification (ED-112, register A11Y-V1):** it applies only when the setting is on and changes no approved layout at default settings; it is verified (wrapping, row growth, no clipping) before it counts as approved.
- **Smallest content text** at 100 %: 11 px (Workspace short pill and minimal footer). Nothing smaller is added.

### 3.5 Implementation checks for Manrope (G3-3, ED-110)

Not done now: no Flutter code changes in the redesign (ED-110). These are the checks the implementation must pass; each one goes in the implementation task's definition of done.

| Check | What has to be true | How to check |
|---|---|---|
| **Licence** | Manrope is SIL OFL 1.1. The licence text ships beside the font (as `Inter-OFL.txt` does today) and appears on the app's licences page. The font comes from the upstream project at a pinned release, not a mirror. If the licence names a Reserved Font Name, the font is not renamed or subset under that name | Read the OFL header; licences page widget test; record source URL and release in the ADR |
| **Glyph coverage** | Every character in the shipped ARB files (en, de, es, fr) is in the font (ä ö ü ß, ñ ¿ ¡, é è ê ç œ « », – — · ’ …). Task text in scripts Manrope lacks (CJK, Arabic, Hebrew, Devanagari, Thai, emoji) falls back to the platform font per glyph, without a jump in line height | A test that checks the ARB characters against the font's character map; a golden of a mixed-script title |
| **International layout** | German and French strings are the longest; the 200 % checks are repeated with them. RTL comes from layout, not the font | Goldens in de and fr at 200 % |
| **Aligned numerals** | Every time, count, duration and the orb numeral use tabular figures (`tnum`) so digits do not shift as the countdown changes | Golden of "11:11" over "10:00"; check the `tnum` feature exists in the font |
| **Weights** | One variable file covers 400–800. The 700 and 800 roles render bold on all four targets (variable fonts can need an explicit weight axis) | Golden per weight on each target |
| **Font loading** | Bundled as an app asset on every target; no network font, no `google_fonts`. Web: the font loads before first paint, with no visible fallback flash or layout shift | Web cold-load screen recording; network log shows no font host |
| **Screenshot regression** | Goldens load the real font. All goldens are re-baselined in one commit after the swap: three widths × light and dark × 100 % and 200 % text, compared against the E board frames. CI never updates goldens | Golden diff reviewed by the owner before merge |
| **Size** | App size growth from the font is recorded | Build size report before and after |
| **Records** | An ADR for the brand typeface change (new ADR; historical ADRs are not rewritten); `DotType.fontFamily`; CHANGELOG | Review |

### 3.6 Tablets and foldables (for Prompt D Round 2, not drawn)

- Same family and the same type roles. Chrome stays native: iPadOS SF with Dynamic Type; Android tablets Roboto with the M3 type scale.
- Type follows the **width class**, never the device. A tablet in a compact window (Split View, Slide Over, compact multi-window) uses the phone scale exactly, including the G3-1 now card (19/24).
- Medium and expanded tablet windows use the wide layouts (E-FullA-v2, E-Minimal), which are drawn at Mac sizes (row titles 15 px). Whether touch tablets keep those sizes or use phone-sized content type with touch spacing is **open for Round 2**.
- Orb numerals keep the 0.36 proportion when the orb is sized by the window (G3-2).
- Foldables: folding or unfolding changes the width class mid-task (§9.14). The text size setting is kept, text reflows without losing the reading position, and no text sits across a hinge.
- Wide panes keep notes and long text at about 60–75 characters per line.

### 3.7 Content in system font inside phone sheets — tracked correction G3-C1 (found 2026-11-05, ED-110; direction agreed, ED-112)

The G3-3 approval puts task names, times and task sheets in Manrope. The phone boards draw some of that text in the system font, mostly inside native sheets. This extends I12 / CR-005 (§14). **Nothing has been changed**: the owner asked to approve visual changes before they are merged.

| Board | Text in the system font | Font as drawn |
|---|---|---|
| E-Phones, Android Edit sheet | Task title "Deep work: roadmap", its time line, the When value, a step ("Pull last quarter's notes") | Roboto 500 22, 400 14 / 16 |
| E-Phones, Android Schedule sheet | Sheet title "Schedule Go for a run" (contains the task name); time choices ("Today, 11:00–11:30 AM") | Roboto 500 22; 600 15 |
| E-Phones, iPhone sheets | Task title "Deep work: roadmap" in a sheet header; task time lines; time choices in the When picker and Move | SF 600 17; 500 14 / 19; 600 15 |
| E-PhonesMinimal | Next-task times ("12:30–1:15 PM · next", "10:30 AM") | SF 600 14; Roboto 400 14 |

**Owner, 2026-11-05 (ED-112):** agrees with the direction (Manrope for branded task content, native fonts for platform controls) and wants a visual comparison before anything is merged. Tracked as **G3-C1**, a separate Group 3 consistency correction.

Proposed boundary (direction agreed; drawing not yet presented or applied): text that **names or times the person's task** is Manrope wherever it appears, including in native sheets; a sheet's own heading ("Edit task", "Settings"), control labels, menu rows, buttons, settings values and system picker digits stay system font (K6).

---

## 4. Colour

Light mode only. Dark mode is not designed (§10).

### 4.1 Neutrals and roles

| Token (proposed name) | Value | Role | Contrast on ground `#FBF7F1` |
|---|---|---|---|
| `ground` | `#FBF7F1` | App background (phones, Mac/web main area) | — |
| `surface` | `#FFFDF9` | Cards, sheets (iOS), now-row card, workspace blocks, popovers | — |
| `surfaceSunk` | `#F6F1EA` | Add field, tip pill, grouped rows in sheets, Mac toolbar, inspector, calendar-event block, E-Minimal task screen in the column | — |
| `controlFill` | `#ECE5DC` | Mac toolbar capsules (‹ ›, Everything else), Close and Hide-column buttons (E-Minimal; also in v1.0 E-Focus) | — |
| `surfaceTonal` | `#F1ECE4` | Secondary action tiles (Move, Shift the rest) | — |
| `canvas` | `#EFE7DB` | Workspace time-grid background; Android Day button tint base | — |
| `sidebar` | `#F3ECE2` (web, solid) · `rgba(239,231,219,.78)` + `blur(30px)` on Mac, approximating the approved native material (ED-130); E-Minimal aligned in ED-165 | Sidebars | — |
| `ink` | `#241F2B` | Primary text, active icons | 15.07:1 |
| `ink2` | `#4E4757` | Body copy on boards, Android icons, menu headers | 8.33:1 |
| `secondary` | `#6A6273` | Times, summary, done titles, labels | 5.45:1 |
| `tertiary` | `#7A7280` | Calendar-event dot ring | 4.33:1 |
| `muted` | `#8A8494` | Open done-check ring, Android sheet handle, Inbox dot ring | 3.39:1 |
| `threadAhead` | `#BEB6C7` | Dotted thread ahead (decorative) | 1.84:1 |
| `hairline` | `rgba(36,31,43,.08)` | Row and pane dividers, card edges | — |
| `hairlineStrong` | `rgba(36,31,43,.12–.14)` | Inputs, outlined buttons, menu dividers | — |
| `borderOutline` | `#DDD7E0` (1.5 px) · `#CFC6D6` (1.5 px on wide) | Outlined secondary buttons | — |
| `scrim` | `rgba(36,31,43,.30)` (iOS Add), `.22` (iOS task sheet), `.36` (Android) | Modal dimming | — |
| `avatar` | `#E7DFEF` | Profile circle | — |

### 4.2 Accent and semantic

| Token | Value | Role |
|---|---|---|
| `accent` | `#11615C` (teal) | Add button, Done, selected tab text, links, now-bead, "Now" text, focus ring, sync dot. White on it: 7.27:1 |
| `switchOn` (iOS) | `#11615C`, the accent. **RESOLVED G3-4 (ED-112).** The 8 iOS switches as drawn on E-Phones: native shape, motion and interaction; only the on tint is the app's. Track vs row `#FFFDF9` 7.16:1, vs sheet `#F6F1EA` 6.47:1; white thumb vs track 7.27:1. iOS On/Off Labels and other accessibility settings are honoured (the system draws the marks). Android keeps its M3 teal switch as drawn. **Dark mode (ED-174):** on tint #2A8C83 (3.8:1 on raised, white thumb 4.1:1); #11615C fails on dark rows (2.1:1). **Status:** design approval RESOLVED (ED-112) · design verification PASS (ED-117) · Flutter implementation NOT YET IMPLEMENTED / VERIFIED · dark-mode verification PENDING G4-6. **Implementation checks (future tasks, not authorised in the design phase, ED-117):** (1) every iOS switch uses the native control with its on track tinted `#11615C` (no switch left on the system green default); (2) iOS On/Off Labels and other switch accessibility settings checked on a device; (3) Android keeps the Material 3 switch as drawn (teal track, 24 dp thumb when on), native behaviour; (4) dark-mode contrast measured on every dark surface under G4-6. **Known Flutter gaps (read 2026-11-06, not changed):** `app/lib/features/focus/focus_parts.dart:270` (`Switch.adaptive`, no tint), `app/lib/features/timeline/review/week_review_sheet.dart:185` (`SwitchListTile.adaptive`, no tint), `app/lib/features/timeline/editor/editor_duration.dart:105` (`SwitchListTile.adaptive`, no tint); on iOS these would show system green. Also to reconcile then: Settings switches use `accentFill`, low-energy mode uses `accent` | Switch on-state |
| `accentHover` | `#0B4642` | Link hover; text on accent-tonal |
| `accentTonal` | `#E2EFEC` (text `#0B4642`, 9.04:1) | Chips, Focus tile and Focus button (E-Minimal Now), +5 / +15 / +30 |
| `accentTonalAndroid` | `#CFE8E4` (text `#062F2C`, 11.25:1) | M3 nav pill, FAB, tonal buttons, selected day |
| `accentSelectedWeb` | `#D9ECE9` | Web sidebar selected row |
| `accentSelectedMac` | `rgba(17,97,92,.14)` | Mac sidebar selected row |
| `destructive` | `#C8322F` (white 5.31:1) | Swipe Delete only. Never for incomplete tasks (no-shame rule) |
| `swipeMove` | `#6A6273` | Swipe Move |
| `wakeCap` | bg `#FBEBC8`, icon `#9A5A0E` (4.64:1) | Wake Up sun cap |
| `windCap` | bg `#E6E3F7`, icon `#4B3FB0` (6.33:1) | Wind Down moon cap |
| `orbTrack` | `#E4E3F7` (now ring track on wide and in the orb) | E-Minimal uses it for the indigo now task in the horizon, Day column, task screen, mini window and orb; the concurrent task (Call with Sam) keeps its own colour at 20 % (`rgba(42,157,143,.2)`). `#E4E3F7` reads as indigo `#5B5FD6` at ≈ 20 % on white, so one rule ("task colour at 20 %") may cover both — **UNRESOLVED** |
| `statusTrack` | progress `#241F2B`, track `#C9C7EE` | Mac menu-bar status item ring only (monochrome, template-like; same in v1.0 E-Focus) |
| `orbInner` | `#F1F0FB` | Orb centre; large now-dot centre in sheets |
| `orbHairline` | `#E9E2F0` | Orb inner hairline |
| `emptyRing` | `#EDE7DF` (track), `#F6F1EA` (centre) | Empty-day orb |

Board-only status tags (not product tokens): Built today `#E3F1E7`/`#1D6436`, Design-only `#E2EFEC`/`#0B4642`, Hypothesis `#FBEBD0`/`#6E4300`, Platform note `#EDE7DF`/`#4E4757`. Android AM/PM selected uses the Hypothesis amber (`#FBEBD0`/`#6E4300`); this looks like a board leak and is flagged in §14.

### 4.3 Task palette

Each task has one colour. It fills the done dot, rings the ahead dot, colours the past thread segment and the knot.

| Colour | Hex (fill) | Sample task | On ground (non-text 3:1 target) | White icon on solid | Ahead ring token (ED-155) |
|---|---|---|---|---|---|
| Coral | `#E2725B` | Morning run | 2.90 ✗ | 3.09 | `#DF6147` (3.31) |
| Amber | `#D9A23A` | Coffee | 2.14 ✗ | 2.29 ✗ | `#AF7E22` (3.37); glyphs on fill are ink `#241F2B` (7.03) |
| Sky | `#4A9BD6` | Team standup | 2.83 ✗ | 3.02 | `#338ED1` (3.32) |
| Indigo | `#5B5FD6` | Deep work | 4.86 | 5.18 | = fill |
| Teal-green | `#2A9D8F` | Call with Sam | 3.11 | 3.32 | = fill |
| Rose | `#D9668F` | Lunch | 3.15 | 3.36 | = fill |
| Green | `#4CA36B` | Pick up parcel | 2.91 ✗ | 3.11 | `#469763` (3.35) |
| Violet | `#8B5CF6` | Gym; Add-field dot | 3.97 | 4.23 | = fill |
| Brown | `#8C6A4F` | Read | 4.59 | 4.90 | = fill |

- **G3-9b (ED-161):** 12 Dottoday task colours (adds slate shade `#6E6A75` for the existing key, new keys brown `#8C6A4F`, plum `#9E4F8F`, olive `#7F8A3A`) plus any custom colour. Ring tokens: teal `#289588`, rose `#D75E89` in addition to ED-155's four; custom colours derive ring (lightness until 3:1 on `#F3EEE6`) and glyph (white if ≥ 3:1 else ink) at render time. The in-progress arc uses the ring (ED-157). App colour: any colour; buttons and links use a derived shade reaching 4.5:1; suggestions Blush `#E9958E`, Peach `#F29E7C`, Honey `#E2A72E`, Sage `#8DBA6A`, Dusk blue `#6A88A8`, Pine `#2F7D5C`, Plum `#934B6E`, Ink navy `#2E4A6B`, current colour always first. Settings › Appearance holds Layout, Theme, App colour and Format under a pinned live preview; the tab bar / toolbar stays on Settings except under pull-ups.
- **RESOLVED G3-9 (ED-155):** each task colour has a `fill` token and a `ring` token. Ahead rings and the icon inside them use `ring`; done fills, thread, knots, the now ring and Wake Up / Wind Down use `fill`. Four rings are darker than their fills (table); glyphs on amber fills are ink. Previously: four task colours fell below 3:1 as an outline ring on `#FBF7F1`, and amber was below 3:1 under a white icon.~~**UNRESOLVED**~~ (contrast pass needed, §12).
- The full list of user-selectable task colours is **UNRESOLVED**. Only the nine above are drawn.

### 4.4 State colours

| State | Dot | Thread | Title | Done check |
|---|---|---|---|---|
| Done | Solid task colour, white icon | Solid task colour | `#6A6273` (no strike-through) | 28 px solid task colour, white check |
| Now | Progress ring in task colour (85 % arc), track `rgba(task,.2)` (phones) or `#E4E3F7` (wide); centre `#FFFDF9` | Solid down to the bead | `#241F2B` | 28 px, 2.5 px ring in task colour |
| Ahead | `#FFFDF9` centre, 4 px inset ring in task colour, icon in task colour | Dotted `#BEB6C7` | `#241F2B` | 28 px, 2.5 px ring `#8A8494` |
| Calendar event | `#FBF7F1` centre (wide: `#FFF`), 2.5 px ring `#7A7280`, icon `#3B3543` | Same as neighbours | `#241F2B`, time line ends "· Calendar" | None (read-only) |
| Inbox / unscheduled | `#FFFDF9`, 3 px ring `#8A8494`, no icon | — | — | — |

### 4.5 Values that differ between boards

| What | Values seen |
|---|---|
| Now ring track | `rgba(91,95,214,.2)` on phones and web workspace · `#E4E3F7` on E-Minimal Mac and web (v1.0: Mac Focus/inspector) |
| Ring cut-out width | 5 px (phones), 4.5 px (wide: E-Minimal Day column, Also now, task screen), 4 px (legend, horizon, web Also now) |
| Now-ring recipe (ED-198, ED-212) | Light: track = task colour at 20 %, arc = ring token; dark: track = the arc colour at 25 % (ED-174; applied ED-212). Cut-out 5 px phones, 4.5 px wide on thread now-dots; 4 px stays for legends, horizon and "Also now" |
| Ahead-ring width (ED-199) | 4 px on standard phone dots, 3.5 px on standard wide dots, 2.5 px on dots ≤ 16 px; inset stroke, outside diameter unchanged; light and dark |
| Calendar-event dot (ED-200) | Centre = the surface directly behind (opaque); ring #7A7280 light / #8C838A dark, 2.5 px standard, 2 px on dots ≤ 16 px |
| Wake Up / Wind Down thread cap (ED-201) | 34 px, icon 19 px, on phones and the wide Day column (matches the thread's task dots); settings caps keep their own sizes |
| Phone Now card (ED-202) | Radius 24 px on iPhone and Android; height 80 px iPhone, 82 px Android (ED-104) |
| Task text in phone editors (ED-204) | Add input Manrope 600 20 (iPhone and Android); task title Manrope 700 24/30 (iPhone and Android); app-bar and platform chrome stay native; long titles scroll inside the header at large text, never cut off |
| Device status tag, attention (ED-205) | Neutral tag `#F1ECE4` / `#4E4757` (dark `#2F2A30` / `#C7BEC4`), 12 px 600, radius 6, with a 13 px bell-off icon, light `#986C1C` (3.97:1; refined from `#AF7E22`, ED-213), dark `#D9A441`; wording carries the state, the icon is decorative to assistive tech. Applies to the iPad "Alarms off" tag only; no warning token. Ready stays green |
| Mac / web Day button (ED-206) | System font 13 / 500 in light and dark: Mac `-apple-system` (30 px), web `system-ui, -apple-system, 'Segoe UI', sans-serif` (32 px); colours, surface, border, radius, chevron and padding unchanged. Mobile-web Day chip (Manrope 14/700) and phone chips are separate |
| Sidebar width (ED-168, ED-207) | Full 216 px; Minimal 200 px on Mac and web (rows: Mac 13/32, web 14/36). Panes beside it take the remainder; changing the sidebar never moves the Day column |
| Repeat marker (ED-208) | Repeat icon (two arrows in a loop), 12 px in rows after the time, 10 px in week blocks after the title; text colour; spoken "repeats" once (container label, or the icon's own name when standalone) |
| Wide Now card, Minimal Day column (ED-209) | Mac and web: 68 px tall, radius 18; time and "Now, N min left" 12.5 px; title Manrope 16/700 (other rows 15). Phones: ED-104 / ED-202 |
| iPhone glass elevation (ED-210) | Hairline 0.5 px `rgba(36,31,43,.1)` / dark `rgba(255,245,235,.13)` plus: 0 sheet controls none · 1 top row `0 4 12` 8 % / 18 % · 2 Day ▾ `0 6 16` 10 % / 22 % · 3 floating bar `0 10 30` 12 % / 26 % · 4 overlay `0 20 50` 24 % / 50 % (dark shadows black). Native controls use the system shadow; Android uses M3 elevation |
| Secondary labels on a selected Mac/web sidebar row (ED-214) | `#4E4757` in light (≥ 6.6:1 on the selection tint); unselected rows keep `#6A6273`; dark unchanged (`#C7BEC4`) |
| Ahead ring | 4 px inset (phones) · 3.5 px (E-Minimal Day column as a border, Mac Next row as an inset; Workspace; v1.0 Focus) · 3 px (legends, end-of-day, web Next row) · 2.5 px (horizon) |
| Calendar dot centre | ~~`#FBF7F1` (phones) · `#FFFFFF` (E-Minimal; v1.0 Focus) · `#FFFDF9` (Workspace)~~ superseded by ED-200: the surface directly behind |
| Inactive iOS tab label | `#6E6E73` in Full and Minimal (4.75:1; G3-8, ED-154). `#8E8E93` (3.06:1) is no longer used for tab labels |
| Android Day menu surface | `#F3EEE6`, the Android surface token (ED-165; `#F7EFF4` superseded) |
| Outlined-button border | `#DDD7E0` (phones) · `#CFC6D6` 1.5 px (E-Minimal Need more time?; v1.0 Focus) · `rgba(36,31,43,.14)` 1 px (E-Minimal Tomorrow / Later / Move…) |

---

## 5. Dot, thread and task states

### 5.1 Dot sizes

| Context | Done | Now | Concurrent now | Ahead | Calendar | Caps | Icon |
|---|---|---|---|---|---|---|---|
| Phone thread | 32 | 45 in the now card on Full Today (ED-104); 40 in Minimal's Today tab | 34 | 34 | 34 | 32 (Today) / 34 (Empty, Minimal) | 18 (32), 19 (34), 24 (45), 22 (40) |
| Add field | — | — | — | 34, 4 px `#8B5CF6` ring | — | — | 19 |
| Task sheet header | — | 44, centre `#F1F0FB` | — | — | — | — | 24 |
| Minimal "Also now / Next" | — | — | 32 (iOS) / 36 (Android) / 32 (E-Minimal Mac) / 28 (E-Minimal web) | 32 / 36 / 32 / 28 | — | — | 18–19 (15 web) |
| E-Minimal Day column (Mac 290 / web 510) | 24 (three overlapping in the "Earlier · 3 done" fold) | 38 (in the now card) | 34 | 34 (3.5 px ring) | 34 (2.5 px `#7A7280`, white centre) | 32 (Wind Down only) | 19 (21 in the now dot) |
| E-Minimal task screen header (column) | — | 38 | — | — | — | — | 21 |
| E-Minimal mini window / status item | — | 54 ring (6 px stroke) / 14 status ring | — | — | — | — | — |
| Historical (v1.0, E-Focus) Day thread | 32 | 38 | 34 | 34 | 34 | 32 | — |
| Workspace block | 32 (17 Mac short, 22 web short) | 38 | 20 (Mac) / 28 (web) | 32 | 32 / 28 | 18 (web header) | — |
| Horizon (phones minimal, E-Minimal Mac 700 px / web 496 px) | 14 | 20 | 18 | 14 (2.5 px ring) | 14 (2 px ring) | 16, plain disc, no icon | none |
| Lands-at preview | 12 at 45 % opacity | — | — | new task 22, 4 px ring + 2 px halo + shadow | — | — | none |

Rule: the Add-field dot is the same size as a normal ahead dot (34 px, 19 px icon). It previews the new task's colour.

### 5.2 Thread geometry (phones)

- Dot column: 48 px wide, row left padding 20 px, so the thread centre sits at x = 44.
- Thread: `left: 42px; width: 4px`. Now card shifts it to `left: 32px` because the card has a 10 px margin.
- Past: solid 4 px. Each row's upper half takes the previous task's colour; the lower half takes this task's colour.
- Ahead: `border-left: 4px dotted #BEB6C7`.
- The thread starts at the Wake Up cap's centre and ends at the Wind Down cap's centre.
- Text column starts 10 px after the dot column.
- Row heights: cap 40–44; done 48 (Android 50); concurrent now 52 (Android 54); ahead/calendar 54; now card 80 minimum on Full Today, Android 82 (ED-104; Minimal's Today tab 72 / 74); free-time 28, 32 above and below the now group on Full Today (ED-104); knot 26; bead 26 (minimal 24).
- **E-Minimal Day column (wide minimal):** thread at `left: 30px` (centre x = 32 inside the column), dot column 44, row padding 0 4 0 10, text 8 px after the dot column. Rows: Earlier fold 44; now card 68 (Mac) / 64 (web), radius 18, `#FFFDF9`, `inset 0 0 0 1px rgba(36,31,43,.08)`; overlap 20; concurrent 48; bead row 20; free time 22; ahead / calendar 50; Wind Down cap 36. The column opens on the Earlier fold: no Wake Up cap at the top. Done check 22 px visual in a 28 (Mac) / 32 (web) button. Selected-for-menu row (Gym): `rgba(17,97,92,.06)`, radius 10.
- Historical (v1.0, E-Focus) Day thread: thread at `left: 30px`, dot column 44, rows 48–50, now row 64.
- Workspace: thread runs behind the cards, centred on the dots (`x = col + 69` Mac; `x = 82` web). Past days solid, today solid to now, future days dotted.

### 5.3 Now

- **Now card (phones, Full Today, ED-104):** min-height 80 (Android 82) with 8 px top and bottom padding so it grows with its title; ring 45 with a 5.5 px stroke and 24 icon, in the 48 px dot column on the thread's centre line; title 19/700, line height 24, wraps (never truncates). Minimal's Today tab keeps 72 / 74 and the 40 ring. Both: margin 0 10 px, radius 24 (Android 22), `#FFFDF9`, `inset 0 0 0 1px rgba(36,31,43,.08)`. Time line "9:00–11:00 AM · **Now, 18 min left**".
- **Now-bead (phones):** 16 px, `#11615C`, 2 px white border, `0 0 0 1px rgba(17,97,92,.4)`. Pill: 700 13/18 teal, padding 0 7, radius 9, `#FFFDF9`, `0 0 0 1px rgba(17,97,92,.3)`. Line: 1 px `rgba(17,97,92,.28)` to 20 px from the edge. Legend draws it at 12 px.
- **Now-bead (wide):** 14 px (border-box, including a 2 px white border), no outer ring; pill 700 13/18, padding 0 6, radius 9, `#FFFDF9`, 1 px border `rgba(17,97,92,.3)`; line 1 px `rgba(17,97,92,.28)`. E-Minimal draws this same 14 px bead in the Day column, on the horizon and in its legend, so on the wide minimal board the legend and the frames agree (resolves I1 *for E-Minimal only*). Workspace adds a full-width 1 px `rgba(17,97,92,.22)` line and a 1.5 px `rgba(17,97,92,.65)` segment on today's column. Historical (v1.0, E-Focus): horizon bead 10 px + 2 px border (14 overall), Day bead 14 px.
- **Orb / large now-dot (minimal):** SVG on a 232 viewBox: r112 `#FFFDF9`; track r100 12 px `#E4E3F7`; progress r100 12 px task colour, round cap; hairline r84 1 px `#E9E2F0`; centre r74 `#F1F0FB`; shadow `0 18px 40px rgba(91,95,214,.16)`. Centre (one drawing, G3-2, ED-106): task icon, numeral 800 −0.05 em at 0.36 of the orb, "min left" 600; iPhone 22 / 84 / 13, Android 22 / 80 / 13, Mac 26 / 100 / 15, web 22 / 85 / 13. Sizes: 236 (iPhone), 228 (Android), **280 (E-Mac minimal), 240 (E-web minimal)**. Click/tap opens Focus (the feature). Historical (v1.0, E-Focus): 203 (Mac), 209 (web).
- **Horizon (wide minimal, E-Minimal):** 3 px line, 7 AM–11 PM; Mac 700 × 46 at 43.75 px per hour, web 496 × 46 at 31 px per hour. Past segments solid in each task's colour; ahead dotted `#BEB6C7`. Every dot is cut out of the line by a 2 px ground-colour gap (`0 0 0 2px #FBF7F1`; a gap, not a halo — halos stay rejected, ED-023). Caps are plain 16 px discs (`#FBEBC8`, `#E6E3F7`) with no icon. Labels 12 px under the line; now label 700 teal. Click a dot to open it in the right column; right-click carries the task menu (open dot gets a `0 0 0 3.5px rgba(17,97,92,.65)` ring). The group's accessible name summarises the day. Historical (v1.0, E-Focus): 300 × 42.
- **Now actions (wide minimal):** row 460 wide (Mac), three buttons 40 tall, radius 20: Done (teal, white), Focus (`#E2EFEC` / `#0B4642`), Need more time? (flex 1.6, 1.5 px `#CFC6D6`, teal chevron) which opens +15 min / +30 min / Shift the rest from here (web popover: 240 wide, radius 20, `#FFFDF9`, `0 0 0 1px rgba(36,31,43,.10), 0 16px 36px rgba(36,31,43,.16)`).
- How the orb's track, centre and shadow tint derive for other task colours: **UNRESOLVED** (only indigo is drawn).

### 5.4 Overlap

- Knot glyph: 26 × 26 SVG, two strokes (3.5 px, round caps) in the two tasks' colours, drawn on the thread between the overlapping rows, with "Overlap · 10:30–11:00" (13 px `#6A6273`).
- Inline knot: 16–18 px, 2.6 px stroke, before "Overlaps Call with Sam, 10:30–11:00" in the task sheet and "Also now" rows.
- Wide grids: overlapping blocks sit side by side; a 24 px `#FFFDF9` disc with the knot sits on the shared edge (`0 0 0 1px rgba(36,31,43,.14), 0 2px 6px rgba(36,31,43,.10)`).
- Overlaps are allowed. The Android Move dialog says "overlaps Lunch" as information, not as an error.

### 5.5 Open past its end

- Drawn **only** in the minimal end-of-day inset (`E-PhonesMinimal`, 10:05 PM): "Pick up parcel · ended 3:45 PM · still open", 13 px `#6A6273`, with a 16 px ahead-style dot (3 px ring). Actions: **Tomorrow** (filled teal) and **Later** (outlined).
- The card: radius 28, `#FFFDF9`, `0 0 0 1px rgba(36,31,43,.08), 0 14px 30px rgba(36,31,43,.10)`. Header: 60 px day ring (teal 94 %, track `#EDE7DF`) around a 40 px moon cap; "Wind Down at 11:00 PM" 700 22/28; "Two things are still open." 600 14.
- How an open-past-end task looks **on the thread** during the day (for example "ended 9:15 · still open"): **UNRESOLVED**. No E board draws it.

### 5.6 Caps

- Wake Up: sun icon, `#FBEBC8` / `#9A5A0E`, label "Wake Up · 7:00 AM".
- Wind Down: moon icon, `#E6E3F7` / `#4B3FB0`, label "Wind Down · 11:00 PM".
- Caps have no done check. Tapping a cap opens the Your day dial (concept doc; not drawn). **UNRESOLVED** visually.
- A task that starts before Wake Up (Morning run 6:45) is drawn **after** the 7:00 Wake Up cap on the iPhone and Android thread. Ordering rule for tasks before Wake Up: **UNRESOLVED**.

### 5.7 Other markers

- Repeats: ~~a 12 px repeat icon after the time (phones); "· repeats" text (v1.0 E-Focus; …); "↻" (Workspace)~~ **one marker (ED-208):** the repeat icon, 12 px after the time in rows, 10 px after the title in week blocks, text colour; announced as "repeats" (via the row's label where it has one, else the icon's own name). No ↻ character, no "· repeats" suffix. Schedule sentences ("repeats on weekdays") are content.. One form is **UNRESOLVED**.
- Done tasks in minimal: folded into one "Earlier · 3 done" row with three 24 px overlapping solid dots (hypothesis, not approved).
- Selection (hold-to-select), drag in progress, and multi-select on phones: **UNRESOLVED** (not drawn). On wide, the open task is shown with a 2 px teal outline (Workspace). E-Minimal marks the row whose menu is open with `rgba(17,97,92,.06)` fill, radius 10 (Day column), and the horizon dot with a 3.5 px `rgba(17,97,92,.65)` ring; it does not draw a selected-and-open row, because an open task replaces the Day in the column. Historical (v1.0, E-Focus): `rgba(17,97,92,.08)` fill and `inset 0 0 0 1.5px rgba(17,97,92,.45)`, radius 18.

---

## 6. Iconography, sizing, spacing, touch targets

### 6.1 Icons

- Board icons are stroke icons: `stroke-width: 2`, round caps and joins, no fill.
- Sizes: tab/nav 22; menu 20 (iOS menus use stroke 1.7); dot icons 18–19 (22 in the now dot, 24 in the sheet); Add "+" 24 at stroke 2.4; chevrons 14–16 at stroke 2.6; done check 15 at stroke 3.
- **Task icons** are content: one library on every platform (ADR-0013, K9).
- **Chrome icons** may follow the platform: SF Symbols on Apple (native path needed), Material Symbols on Android. Android boards already use filled glyphs for the dropdown arrow and Day button.
- Tab icons: Today = target ring with a filled centre (full); in minimal, Now takes a target-ring icon and Today takes a list-of-dots icon. Final glyphs: **UNRESOLVED** (approximations).

### 6.2 Spacing and alignment

| Where | Value |
|---|---|
| Phone side gutter | 20 (title, thread rows, summary), 16 (chips, sheets, tip); bottom row: iPhone 21, Android 16 (§9.15) |
| Android gutter | 16 (top bar, thread), 24 (minimal Now content, sheet) |
| iPhone nav row | top 52, height 44; summary at top 100; week strip top 128, height 56 |
| Android top app bar | top 40, height 64 |
| iPhone bottom row (ED-124) | tab bar left 21, right 90, bottom 21, height 63, radius 31.5, padding 5; + 63 circle at right 21, bottom 21 (6 gap); Day ▾ row left/right 21, bottom 96, Day right-aligned, 16 above the bar |
| Android bottom row (ED-125) | floating toolbar left 16, right 80, bottom 24, height 72, radius 36, padding-top 8; + 56 at right 16, bottom 32 (8 gap); Day button left 16, 16 above the toolbar |
| Superseded 2026-11-06 | Day chip + Add row 16 from the sides, 100 above the bottom (iPhone) / 120 (Android); tab bar 16 from the sides, 26 above the bottom, 62 tall; Android NavigationBar full width, 104 tall |
| Scroll-edge fade | iPhone 200 px, `#FBF7F1` 0 → 45 % at 60 %; Android 224 px → 50 % |
| Mac window (minimal, E-Minimal) | sidebar 200 (padding 8 14; rows 32); toolbar 52; Now pane 790 (padding 22 45); right column 290 (Day thread or task screen) |
| Web window (minimal, E-Minimal) | browser chrome 82; sidebar ~~210~~ **200** (ED-207; rows 36); Now pane ~~560~~ **570** (padding 22 32); Day thread 510 (padding 14 24 0 18) |
| Mac / web (Workspace) | Mac sidebar 216, inspector 248; web sidebar 216 |
| Historical (v1.0, E-Focus) | Mac sidebar 216, toolbar 52, Now panel 356, Day 408, inspector 300; web sidebar 220, Now panel 372, Day 388 |

### 6.3 Radii

| Element | Radius |
|---|---|
| iOS sheet | 38 (top corners) |
| Android sheet / dialog | 28 |
| Day pull-down (iOS) | 26 |
| Android Day menu | 22 |
| Mac context menu | 8 (E-Minimal; v1.0 Focus) / 10 (Workspace) |
| Mac toolbar capsules, pill buttons | 21 (30 tall) |
| Task screen in the column (inset frame) / More details row | 18 / 14 |
| Everything else finder | 22; rows 10 |
| Need more time? popover (web) | 20; +5 / +15 / +30 18; Shift the rest 12 |
| Now mini window | 12 |
| Now card | 24 (iOS) / 22 (Android) |
| Action tiles | 22 |
| Add field | 22 |
| Cards, grouped rows | 20–28 |
| Workspace blocks | 18; short pills = half height |
| Pills, chips, buttons | full (height / 2) |
| Tip pill | 20 |

### 6.4 Touch targets

Rule: 44 pt on iPhone, 48 dp on Android, visual size may be smaller inside the hit area.

| Control | Visual | Hit area | Status |
|---|---|---|---|
| Done check (iPhone / Android) | 28 | 44 / 48 | OK |
| Sync, avatar | 20 icon, 32 avatar | 44 / 48 | OK |
| Day chip (iPhone) | 44 tall | 44 | OK |
| Add (iPhone) | 52 circle | 52 | OK |
| Tab items | 62-tall bar | ~85 × 52 | OK |
| Android input chips (minimal) | 32 | 48 | OK |
| iOS minimal chips | 34 | 44 | OK |
| iOS tip dismiss | 14 icon | 44 | Fixed ED-165 |
| Android tip dismiss | 16 icon | 48 | Fixed ED-165 |
| Android Day button (full) | 40 | 48 | Fixed ED-165 (hit area; drawn size unchanged) |
| iOS Add button inside the field | 40 | — | No longer drawn (Create task, ED-140) |
| iOS / Android date chips (Add modes, When picker) | 34 | 44 / 48 | Fixed ED-165 (hit area) |
| **+5 / +15 / +30 (task sheet)** | 44 | 44 | Fixed G3-11 (ED-163): 44 pt chips, the row wraps under the label at 200 % |
| Mac rows, menus, inspector fields | 22–32 | pointer | Pointer sizes; fine on Mac only |
| E-Minimal Day-column done check | 22 | 28 (Mac) / 32 (web) | Pointer sizes; below 44 if the layout reaches a touch iPad/web |
| E-Minimal web +5 / +15 / +30 | 36 | 36 | Pointer; below 44 on touch web |
| E-Minimal toolbar Add, ‹ ›, Hide column | 30 tall | 30 | Pointer (Mac) |

---

## 7. Surfaces, sheets, menus, translucency, motion

### 7.1 iOS: Liquid Glass (approximated)

> **Architecture (ED-128):** the bottom row (tab bar, +, Day ▾ and its menu) is selected to be **native UIKit** (N3, D1; F2 styles on iOS 16–25, conditional, D2; native UIMenu, D3). The top capsule, ‹ Today and Close stay **Flutter** approximations (D4). The values below remain the visual reference for both. Production implementation not authorised.

Base recipe (board approximation; the app needs the native material):

```css
background: linear-gradient(180deg, rgba(255,255,255,0.62), rgba(255,253,249,0.44));
backdrop-filter: blur(16px) saturate(190%);
box-shadow:
  inset 0 1px 0 rgba(255,255,255,0.9),
  inset 0 -1px 0 rgba(255,255,255,0.35),
  inset 0 0 0 1px rgba(255,255,255,0.45),
  0 0 0 0.5px rgba(36,31,43,0.10),
  <elevation shadow>;
```

| Element | Size | Elevation shadow |
|---|---|---|
| Tab bar | height 63, radius 31.5 (ED-124; was 62 / 31) | `0 10px 30px rgba(36,31,43,0.12)` |
| + (Add) | 63 circle, teal glass: `linear-gradient(180deg, rgba(17,97,92,0.94), rgba(17,97,92,0.88))`, `blur(16px) saturate(190%)`, the bar's inner rims; white plus 28 | `0 0 0 0.5px rgba(36,31,43,0.10), 0 10px 30px rgba(36,31,43,0.12)` |
| Selected tab "lens" | radius 26, inside the bar | not glass: `rgba(255,255,255,0.58)`, `inset 0 1px 0 rgba(255,255,255,.95), inset 0 0 0 .5px rgba(36,31,43,.06), 0 2px 6px rgba(36,31,43,.10)`; label/icon `#11615C` |
| Day chip | height 44, radius 22 | `0 6px 16px rgba(36,31,43,0.10)`; pressed/open adds `background-color: rgba(36,31,43,0.06)` |
| Sync + avatar capsule | 88 × 44, radius 22 | `0 4px 12px rgba(36,31,43,0.08)` |
| "‹ Today" capsule | height 44, radius 22, label 400 17 teal | `0 4px 12px rgba(36,31,43,0.08)` |
| Close button (task sheet) | 36 visual in a 44 hit area, icon `#3C3C43` | none (only the 0.5 px edge) |
| Day pull-down menu | width 250, radius 26 | stronger variant: gradient `rgba(255,255,255,0.66)` → `rgba(250,247,252,0.52)`, `blur(30px) saturate(190%)`, shadow `0 20px 50px rgba(36,31,43,0.24)` |

Rules:
- Glass is for **chrome that floats over content**: tab bar, +, top capsule, Day chip, Close, menus.
- **Sheets stay solid** (`#FFFDF9`). Floating glass sheets are rejected.
- The + is teal-tinted glass in the tab bar's line (ED-124); the tint never drops below 88 % so the white plus keeps ≥ 5.7:1. Reduce Transparency: solid `#11615C`. (Superseded: solid teal 52 px in the row above the bar.)
- Labels on glass are the Platform note "approximated (blur, tint, edge light); native material in the app".

### 7.2 Android: tonal, Material 3

> **Architecture (ED-128 D5):** the bottom row is built in Flutter (BackdropFilter), no platform view, no new dependency. Production implementation not authorised.

- Floating navigation toolbar (ED-125): `rgba(242,235,226,0.72)` + `blur(24px) saturate(140%)`, radius 36, elevation `0 1px 2px rgba(36,31,43,.24), 0 2px 6px 2px rgba(36,31,43,.12)`. Selected pill 64 × 32, `#CFE8E4`, icon `#062F2C`. A custom, Material 3-inspired arrangement (M3 Expressive's floating toolbar used for navigation), not a standard M3 component.
- + (FAB, icon-only): 56 × 56, radius 16, `rgba(207,232,228,0.78)` + `blur(24px) saturate(140%)`, icon `#062F2C`, `0 3px 8px rgba(36,31,43,.16), 0 1px 3px rgba(36,31,43,.12)`.
- Day button: `rgba(239,231,219,0.72)` + `blur(24px) saturate(140%)`, radius 26, M3 elevation `0 1px 2px rgba(36,31,43,0.14), 0 1px 3px 1px rgba(36,31,43,0.08)`.
- Frosted blur on Android 12+ (RenderEffect; Flutter BackdropFilter); solid tonal `#F2EBE2` / `#CFE8E4` / `#EFE7DB` on Android 11 and older.
- **No glass rims; never called Liquid Glass.** Menus and sheets stay solid.
- Superseded 2026-11-06: edge-to-edge NavigationBar `rgba(242,235,226,0.86)` 104 tall, Day `0.86`, solid extended FAB "Add".
- Sheet: `#F3EEE6`, radius 28, handle 32 × 4 `#8A8494`, no shadow. Dialog: `#F3EEE6`, radius 28, `0 8px 24px rgba(36,31,43,.2)`.
- The extended FAB "Add" is gone (ED-123/ED-125): Full and Minimal both use the icon-only + above.
- Day menu: `#F7EFF4`, radius 22, `0 3px 6px rgba(36,31,43,0.20), 0 8px 18px rgba(36,31,43,0.14)`, dividers `rgba(36,31,43,.12)`.
- Edge-to-edge; system keyboard (Gboard) shown.

### 7.3 Mac: vibrancy (approximated)

> **Approved visual direction (ED-130, light mode):** native `NSVisualEffectView` sidebar material (behind-window) with a `#EFE7DB` layer at 35 % inside it, under Flutter; genuine vibrancy visible beneath the tint. Measured: ink ≥ 12.1 : 1, selected teal ≥ 5.5 : 1, ≈ 60 % of neutral show-through (ED-129). Layout, rows, selection colours, type and interaction unchanged; no flat Flutter blur in its place. The flat values below remain the drawn reference. **PENDING:** Reduce Transparency solid fallback (proposed solid `#EFE7DB`), Increase Contrast, VoiceOver, keyboard navigation, dark mode: D1 #3B2F2A at 30 % preferred, verified natively (ED-174); selected-row label correction awaits approval.

- Sidebar: `rgba(239,231,219,.78)`, flat and full height. E-Minimal omits the blur (as v1.0 E-Focus did); Workspace adds `blur(30px)` (I14 still open across boards).
- Toolbar and inspector: solid `#F6F1EA`. Main area: `#FBF7F1`.
- Context menus: `rgba(248,245,250,0.97)`, `0 12px 34px rgba(36,31,43,.26), 0 0 0 0.5px rgba(36,31,43,.2)`, rows 22 px, highlight `#11615C` with white text. Menu-bar menus `#F8F5FA`, radius 0 0 8 8.
- Floating Now mini window (E-Minimal, Window › Show Now ⌥⌘0): 300 wide, radius 12, `#FFFDF9`, `0 0 0 0.5px rgba(36,31,43,.25), 0 18px 40px rgba(36,31,43,0.28)`; 24 px title bar `#F1EBE3` with 9 px traffic lights; 54 px progress ring (6 px stroke, track `#E4E3F7`, numeral 700 18); title 700 14; meta 12; teal Done 28 tall, radius 14. Drawn off the frame so it never covers the Day.
- Status item (E-Minimal): 14 px ring in ink on `#C9C7EE` + "18 min". Its menu: task title 600, "18 min left · Next: Call with Sam 10:30", Mark Done, Need More Time?, Show Now Window ⌥⌘0.
- Task screen in the right column (E-Minimal): same 290 width as the Day it replaces; drawn as `#F6F1EA`, radius 18, `0 0 0 1px rgba(36,31,43,.10)`, padding 16 18 18. Header "Task" 700 11 + 32 px Close (`#ECE5DC`, "Close the task and show the Day (Esc)"); 38 px now dot + title 700 17/22 + "Now, 18 min left"; Starts / Duration fields 28 tall, radius 7, 1 px `rgba(36,31,43,.14)` on `#FFFDF9`, − + stepper; Tomorrow / Later / Move… 32 tall outlined pills; a "More details" row (min-height 44, radius 14) listing alerts, repeat, subtasks, colour, icon, notes, Shift the rest, Break it down.
- Everything else finder (E-Minimal, ⌘K on Mac, `k` on web; also searches tasks): radius 22, `#FFFDF9`, `0 0 0 1px rgba(36,31,43,.10), 0 18px 40px rgba(36,31,43,.14)`; 46 px input row "Find an action, place or task" + esc; three groups (Places · Plan the day · Reflect and settings); rows 32, radius 10, selected `rgba(17,97,92,.10)` with 700 `#0B4642`; footer "↑↓ move · ↩ open · esc close · typing a task name finds it on any day".
- Historical / Workspace: command palette (⌘K) radius 22, `#F8F5FA`, selected row `rgba(17,97,92,.10)` (E-Workspace). v1.0 E-Focus used ⌘K for a search field.
- Native menus need a PlatformMenu path. The mini window is a new window type (feasibility check).

### 7.4 Web: solid

- No glass, no blur. Sidebar `#F3ECE2`; selected `#D9ECE9`/`#0B4642`.
- **Block hover and drag (G3-5 option C, ED-116; applies to every eligible Workspace block, Mac and web):**
  - *Eligible:* task blocks that can be moved by dragging (`cursor: grab`). Read-only calendar events (dashed, `cursor: default`) get no hover tint and no drag look.
  - *Resting:* flat `#FFFDF9`, no shadow, no outline (ED-022).
  - *Pointer hover:* `background: #F5F1EB` + hairline `0 0 0 1px rgba(36,31,43,.10)`; no elevation, no shadow. Drawn on Lunch in E-FullA-v2.
  - *Active drag:* the soft lift `0 0 0 1px rgba(36,31,43,.10), 0 8px 18px rgba(36,31,43,.10)`, stacked above every block it crosses, overlapping tasks included; cursor `grabbing`. Drawn on `E-G3-5` (review board), not on E-FullA-v2.
  - *Keyboard focus:* the approved teal ring `0 0 0 2px #EFE7DB, 0 0 0 4px #11615C`, unchanged; it shows with or without hover.
  - *Reduced motion:* the drag look appears at once, with no animated lift; the feedback stays the same.
  - *High contrast / forced colours:* boundaries never depend on shadows: blocks carry a transparent 1 px border so the system draws a visible edge, and hover and drag keep a visible border.
  - *Touch:* no simulated hover; a touch drag uses the drag look.
  - *Open (motion decision, §7.5):* lift timing, any scale, haptics. Not approved by G3-5.
- Focus ring: ~~`outline: 3px solid rgba(17,97,92,.45); outline-offset: 2px`~~ **one recipe (ED-174, applied ED-211):** 2 px solid ring `#11615C` (dark `#7FD6CB`) after a 2 px gap showing the surface (`outline-offset: 2px`, or `0 0 0 2px <surface>, 0 0 0 4px <ring>` where an outline can't be used). 6.8:1 light, 10.8:1 dark on the page surface.
- E-Minimal web: browser chrome drawn (tab "Now · Dottoday", address `dottoday.app/now`); sidebar 200 (ED-207) with Now · Inbox 3 · Calendar · Search, an outlined "Everything else  k" row, a keyboard hint (`n` add · `/` search · `t` today · `[ ]` days · `k` everything else · `?` help), Settings and "● Synced" in the footer. Add is an ink pill (`#241F2B`, 36 tall) in the Now pane header. The Day column header is "Day ▾" (700 17) with "Day menu" and "Hide the day thread" buttons. Hover on Lunch shows "drag to move" and an actions button. Need more time? popover is solid.

### 7.5 Motion

**UNRESOLVED.** The boards are static. What exists in writing:
- `E-Map-v1.0`: "Under reduced motion the bead glow is static and the completion pulse becomes a fade."
- `THREE_UX_CONCEPTS.md` §3.1: the thread fills with colour as time passes; completing a task fills the dot and runs a short pulse to the next dot.
- Platform notes: predictive Back shrinks the Android sheet, then closes it.

Not specified: durations, curves, sheet/detent transitions, drag lift timing and scale (the drag look itself is set by G3-5, §7.4), haptics, the bead glow itself, reduced-transparency fallbacks.

---

## 8. Navigation, creation and editing per platform

### 8.1 Destinations

| | iPhone | Android phone | Mac | Web desktop |
|---|---|---|---|---|
| **Standard (full)** | Tabs: Today · Inbox (badge) · Calendar · Search | Floating navigation toolbar: Today · Inbox (badge) · Calendar · Search | — | — |
| **Minimal** | Tabs: Now · Today · Inbox (badge) | Floating navigation toolbar: Now · Today · Inbox (badge) | E-Minimal sidebar: Now · Inbox 3 · Calendar · Search (no groups); "Routines, Review, Week and Month: View › Show Everything, or Everything else ⌘K"; Day lives in the right column (⌘2) | E-Minimal sidebar: Now · Inbox 3 · Calendar · Search · Everything else (`k`); Settings + "Synced" in the footer |
| **Focus** (wide presentation) | — | — | **No v1.1 board.** Historical (v1.0, E-Focus): Now · Day · Calendar · Inbox 3 · Search · Reviews; group Routines | **No v1.1 board.** Historical (v1.0, E-Focus): same sidebar; Settings + "Synced" in the footer |
| **Workspace** (wide) | — | — | Sidebar: Today 3/9 · Plan (Inbox, Routines, Brain dump) · Calendar views (Day, 3 days, Week, Month) · Review · Search; Lists (sketch, not in parity) | Same, solid; "Search or run Ctrl K" on top |
| **Settings** | Avatar in the top capsule | Avatar in the top app bar | Dottoday › Settings… ⌘, (own window, no sidebar row) | Sidebar footer, `/settings` |
| **Sync status** | Sync icon in the capsule, 8 px teal dot | Sync icon in the top bar, 8 px teal dot | Toolbar "● Synced" (E-Minimal; v1.0 Focus) / sidebar footer "Synced · 10:42" (Workspace) | Sidebar footer "● Synced" |

- Inbox is always a destination with a count. No tray, no handle (rejected).
- In minimal on phones, Search, past days and Routines move to Settings › Everything else. In minimal on Mac/web (E-Minimal), Search stays a sidebar row; Routines, Review, Week, Month, Go to date, Past days, Brain dump, Low-energy mode (ED-162), Export, Backups and Trash, Settings and Show everything sit in the **Everything else finder** (⌘K / `k`) and the View menu. The two minimal homes for "Everything else" differ (§14.3 N7).

### 8.2 Today chrome (phones)

- **iPhone:** nav row = date title "Tue 3 Nov ▾" (700 28/34, teal ▾ 16 px) on the left; glass Sync + avatar capsule on the right. Summary line below. Week strip: 34 px day circles; today = teal text; selected today = teal filled circle; selected other day = ink `#241F2B` filled circle.
- **Other day:** a glass "‹ Today" capsule appears left of the date title.
- **Title ▾** opens a month sheet (go to a date in 2 taps). Month grid: today teal bold; selected day ink circle 36 px.
- **Bottom (ED-124):** shortened glass tab bar with the teal glass + beside it on the same line; glass Day ▾ on the right, 16 pt above (§9.15).
- **Android:** M3 top app bar (date, Sync, avatar); M3 week strip (`#CFE8E4` selected, radius 22); floating frosted navigation toolbar with the icon-only + beside it; Day button left, 16 dp above (ED-125, §9.15).
- **Tip:** at most one, one line, never above the plan; none on an empty day. iOS pill `#F6F1EA` radius 20; Android M3 filled card `#F3ECE2` radius 18.

### 8.3 Day menu

| Group | Items (phones, full) |
|---|---|
| Replan | Need More Time… › (+5 / +15 / +30), Shift the rest (ED-162) |
| Plan | Brain dump, Drop a routine, Pick today's one thing, Duplicate day |
| Reflect | Review the day, This week |
| View | Low-energy mode, Show less, Plan / Reality |
| Share | Copy day as text |

- iPhone: native pull-down with sections (glass, §7.1). Android: M3 menu with leading icons. Mac: menu-bar **Day** menu plus a toolbar/pane button. Web: a "Day menu" button; popover contents **UNRESOLVED**.
- Minimal Day menu (phones): View › Show everything, Low-energy mode (ED-162).
- Minimal Day menu (Mac, E-Minimal, listed in a caption, menu not drawn open): Need More Time…, Shift the Rest ⇧⌘→, Brain Dump… ⇧⌘N, Drop a Routine, Duplicate Day, Copy Day as Text ⇧⌘C, Review the Day, Gentle Day. Reached from the menu bar and the Day button in the right column. Web: "Day menu" button in the Day column header (contents **UNRESOLVED**).
- ~~E-Minimal View menu (Mac): … Now ⌘1, Day ⌘2, Calendar ⌘3, Inbox ⌘4 …~~ superseded (ED-170): ⌘1 Now · ⌘2 Inbox · ⌘3 Calendar · ⌘4 Search · ⌘K Search or run (as drawn and in §11). Show Day Column is a View command; its key (⌥⌘D vs ⌥⌘I) is CR-143.

### 8.4 Task creation

| | iPhone | Android | Mac | Web |
|---|---|---|---|---|
| Entry | + in the tab bar's line, 1 tap, opens Create task (detailed) with the title focused (ED-140); hold + for Brain dump, Routine, Paste a list | + beside the toolbar → M3 FAB menu: Task, Brain dump, Routine | Toolbar + (teal, 34 × 30), ⌘N anywhere; E-Minimal also has an "Add a task · paste several lines for many" field (40 px pill) in the Now pane; Workspace capture field; ⇧⌘N Brain dump | Ink "Add" pill in the Now pane header (E-Minimal), `n`; Workspace capture field |
| Surface | Full: Create task (detailed) screen, Task · Brain dump · Routine tabs (ED-139, ED-140); Brain dump, Routine and the proposal also open full screen (large detent, Cancel / × in the header; ED-147, ED-149, ED-150). Minimal: solid page sheet (radius 38) | Full: full-screen Create task with M3 segmented buttons (ED-141, ED-142); Brain dump, Routine and the proposal full screen (ED-148 to ED-150). Minimal: M3 modal bottom sheet | Popover / capture column | Popover / capture column |
| Tab actions (ED-152) | Only the selected tab's action shows: Task = Create task (header); Brain dump = Plan it (in the body, then the proposal's Add to day); Routine = its own controls. Create task never shows on Brain dump or Routine. iPhone headers: Create task = Cancel · ⋯ · Create task; Brain dump and Routine = Cancel only, no title (ED-153). Switching tabs never writes or discards; drafts kept. No "Add another" | Same: top-bar Create only on Task; Plan it / routine controls in the body | Mac / web capture unchanged | Mac / web capture unchanged |
| Field | Full: title field focused, natural-language time; teal Create task in the header (ED-140). Minimal: `#F6F1EA` 58 px, radius 22, 34 px violet dot, input 500 19, Add in the nav bar | Outlined field 56 px, 2 px teal, label "What and when" | 36 px pill input | 36 px pill input |
| Live parsing | Chips 34 px `#E2EFEC`: "6:00 PM", "1 h", "Today"; result line "Gym · 6:00–7:00 PM, free until Read at 9:30 PM" | Input chips 32 px `#CFE8E4` radius 8 | **UNRESOLVED** (not drawn) | **UNRESOLVED** |
| Minimal additions | Two chips at most; "Lands at 6:00–7:00 PM · free, no overlap" with a horizon preview; More | Same, "More options", filled Add | — | — |
| Paste a list | Inset: list preview + "Add 4 tasks" | Same | ⌘V in Add | Paste in Add |
| Return key | Stock keyboard; neutral "return" key adds (never "done"); teal Create task in the header (Full, ED-140) / Add in the nav bar (Minimal) (G3-7 C, ED-135) | Keyboard action (check) key adds; its colour is Gboard's | Return | Enter |
| Keyboard | The system keyboard of the running iOS version (16–18 or 26); boards draw the iOS 26 look (ED-136) | Gboard / system IME | Hardware | Hardware |
| Keyboard dismissal (ED-136) | Swipe down on the sheet or drag its content hides the keyboard first (sheet and draft stay); tap outside the field; Return adds; VoiceOver scrub; hardware: Esc leaves the field | Back hides the keyboard first, then closes the sheet | — | — |

Proposal rule: Brain dump and Routine go through the proposal sheet. Nothing is written before Accept. Several lines in Add open a plan first.

### 8.5 Task editing

- **iPhone:** tap a dot → solid sheet at the medium detent: 44 px now-dot, title 700 22/28, time + "18 min left", glass Close; overlap line; four 76 px tiles (Done teal; Move and Shift the rest `#F1ECE4`; Focus `#E2EFEC`); "Need more time? +15 min +30 min" row; "Pull up to edit". The large detent is the full editor (hypothesis). Large-detent layout: **UNRESOLVED**.
- **Android:** one M3 bottom sheet: Done (filled teal), Move (tonal), Shift the rest and Focus (outlined). Move opens the M3 time picker dialog (dial, keyboard toggle, Change day, Cancel, Move).
- **iPhone Move picker** (wheels per concept doc): **UNRESOLVED** (not drawn).
- **Mac/web minimal (E-Minimal):** the task opens in the right column, replacing the Day (Mac 290; web: in the Day column, `?task=` in the URL, as on Mac). Task screen: Starts, Duration (− +), Tomorrow / Later / Move…, More details (alerts, repeat, subtasks 2 of 4, colour, icon, notes, Shift the rest, Break it down). ✕ or Esc closes it and the Day comes back; the Now pane never moves. Only the Mac task screen is drawn; the web one is described in a caption.
- **Mac/web Workspace:** inspector: Need more time? +15 +30, Done/Focus/Shift rest, Date, Time, Repeat, Alerts + Add alert, Subtasks, Overlaps, Notes.
- Historical (v1.0, E-Focus) inspector: Starts, Duration (− +), Repeat, Alerts chips, Subtasks, Move…, Shift the rest, Break it down….
- **Resize** is the duration field (ADR-0015). No edge resize is drawn anywhere. Keep it that way.
- **Swipe (phones):** leading swipe = Done (teal 92 px); trailing = Move (`#6A6273`) and Delete (`#C8322F`), 76 px each.
- **Right-click (Mac):** Open ↩, Mark Done ⌘↩, Move To… ⌘M, Shift the Rest From Here, Focus ⌘F, Duplicate ⌘D, Copy as Text, Delete ⌫ (E-Minimal, on a horizon dot; same set as v1.0 E-Focus). Workspace adds Running Late ▸ and uses Move to Trash ⌘⌫.

---

## 9. Presentations

### 9.0 Group 1 answers (2026-11-04) — read before §9.1–9.5

The owner answered Group 1 of `E_DECISION_REGISTER.md` on 2026-11-04. Where these answers overlap an AWAITING line in §9.1–9.5 below, the answer here wins. The lines below are kept as written for v1.1.

| Rule | Status | Evidence |
|---|---|---|
| E has **two presentation modes, Full and Minimal**, on every platform | DECIDED | ED-065 (G1-2) |
| **Focus is a feature** reachable from either mode. E has no wide Focus *presentation*; v1.0 `E-Focus` stays archived | DECIDED | ED-065 |
| **Workspace is advanced planning inside Full**, not a separate mode | DECIDED (structure) | ED-065 |
| **Minimal opens on Now.** Full has no Now destination; the current task shows on the Today timeline | DECIDED | ED-066 (G1-3) |
| Mac Now mini window and menu-bar status item | NEEDS VERIFICATION (feasibility) | ED-066 |
| The Full/Minimal switch is always in the **Day menu** and the **first Settings row**, plus native extras (Mac View menu). Switching keeps the open task, selected day and relevant navigation state. One per-account setting, as built | DECIDED | ED-067 (G1-4) |
| **Minimal phones:** bottom navigation Now · Today · Inbox (`E-PhonesMinimal`) | DECIDED | ED-068 (G1-5) |
| **Minimal Mac and web:** sidebar Now · Inbox · Calendar · Search, Day timeline in its own column (`E-Minimal`) | DECIDED | ED-068 |
| The two Minimal sets differ on purpose (viewport adaptation). Do not make them identical, move Calendar/Search out of the wide sidebar, or remove the phone tab bar for uniformity. Keep shared meanings, accessible paths, consistent naming and native behaviour | DECIDED | ED-068 |
| **Full phones** keep the `E-Phones` tab bar | DECIDED | ED-069 |
| **Full on Mac and web = Workspace** (sidebar, Inbox and Routines column, Day / 3 days / Week / Month grid, docked inspector), candidate `E-FullA-v2`; its sidebar is the Full wide sidebar | DECIDED | ED-073 (G1-1) |
| `E-FullA-v2`'s Day menu, increments, keys and routes | AWAITING (G2-9, G2-10, G2-11) | ED-072 |
| **`E-Workspace` is a historical/reference board.** `E-FullA-v2` is the active Full design and wins wherever the two differ | DECIDED | ED-074 |
| Keyboard shortcuts (including ⌘1–4 and ⌘K) and web routes (including `/now`) | AWAITING (G2-10, G2-11) | ED-068 |

**Superseded older specification (redesign branch only, not edited):** `docs/14-minimal-mode.md` §3 rows "Navigation bar / rail" (no tab bar or rail in minimal), "Inbox" (a "Later (3)" row) and the expanded-width row ("Today alone … no sidebar"), as adopted by ADR-0016. ED-068 supersedes them for Concept E. ADR-0016's other rules still apply: minimal hides, never removes; one standing switch; Hidden is view-only.

**Closed by Group 1 in §14:** N3 (sets differ on purpose, ED-068). N4 stays open as naming only: "Today" vs "Day" is a G3 consistency item, not a navigation change. N6 and N8 move to G2-10.

v1.1 separates four things that v1.0 blurred. **DECIDED** means the owner explicitly approved or stated it; an owner canvas edit counts only for the visual change it made. Everything else is **AWAITING OWNER DECISION**, even when a board draws it. "Built today" items exist in the shipped app and are not re-decided here.

### 9.1 Standard Today / Timeline

- **What it is:** the day as the vertical thread: Wake Up / Wind Down caps, task dots, free time, overlap knot, now card and now-bead, Day chip + Add, four destinations (Today · Inbox · Calendar · Search). The *Timeline* is the thread as a component; it also appears inside Minimal (phone Today tab, E-Minimal Day column) and inside Workspace (one thread per day behind the cards).
- **Where drawn:**

| Platform | Board / frame |
|---|---|
| iPhone (390 pt) | `E-Phones` F1–F4 + insets 1–4 |
| Android phone (412 dp) | `E-Phones` F5–F6 + insets 5–6 |
| Mac | **No board.** A-Wide (thread-only wide) was deleted by the owner and never copied into E (ED-003). The thread appears only as the E-Minimal Day column and the E-Workspace day threads |
| Web desktop | **No board** (same as Mac) |
| iPad, Android tablet, mobile web | Not drawn |

- **Relationships:**
  - Phones open on Standard Today: drawn on the owner's own boards (E v1.0 copy). The structural relocations marked Hypothesis on them (Settings out of the tab bar, one task surface, Add modes, Day menu, Calendar destination) are **AWAITING OWNER DECISION** (ED-043 to ED-051).
  - Which layout is the wide Standard (a thread-only wide board, Workspace, or something else): **AWAITING OWNER DECISION**.
  - What replaces the three-day spread on wide: **AWAITING OWNER DECISION**.

### 9.2 Minimal mode

- **What it is:** the calm version of the same app (ADR-0016, `docs/14-minimal-mode.md`; built today as Show less / Show everything). Now leads: horizon, large now-dot, Done / Need more time? (+ Focus on wide), "Also now" and "Next". The rest of today is the thread with an "Earlier · 3 done" fold. Summary shows time, not counts. Minimal hides, never removes: every hidden item has a named home (the bands on `E-PhonesMinimal` and `E-Minimal`).
- **Where drawn:**

| Platform | Board / frame |
|---|---|
| iPhone | `E-PhonesMinimal` F1–F4 (Now, Today, Add, empty day) + end-of-day inset. Tabs Now · Today · Inbox |
| Android phone | `E-PhonesMinimal` F5–F6 (Now, Add). NavigationBar Now · Today · Inbox |
| Mac (1280 × 800) | **`E-Minimal`** Mac frame: sidebar 200 (Now · Inbox · Calendar · Search) · Now 790 · right column 290 (Day thread by default; task screen when a task is open; ⌥⌘D folds it). Insets: menu bar with View menu + status item, task screen in the column, Now mini window, Everything else finder |
| Web desktop (1280 × 800) | **`E-Minimal`** web frame: sidebar 200 · Now 570 · Day thread 510 (ED-207); `/now`, `?task=`; Everything else on `k`; Need more time? popover open |
| Historical | v1.0 `E-Focus` (titled "minimal look", drawn with the full sidebar) — removed from the canvas; not a minimal source any more |

- **Relationships:**
  - **DECIDED:** `E-Minimal` is E's Mac and web minimal layout and replaces `E-Focus` in that role. Evidence: the owner removed E-Focus from the canvas (ED-062) and stated on 2026-11-04 "I have completed the redesign and replacement of Concept E's Mac and Web Minimal Layout" (ED-064). This closes v1.0's "is E-Focus the wide minimal?" question (ED-005) for the minimal role.
  - **DECIDED (product rule, not E-specific):** minimal hides, never removes; Show less / Show everything is the switch (ADR-0016, built today).
  - **AWAITING OWNER DECISION** — the choices E-Minimal itself still tags "Hypothesis · not approved": a four-row sidebar kept in minimal (doc 14 §3 shows expanded minimal as Today alone with no sidebar); Now (not the thread) as the wide entry and the `/now` route; the task screen opening in the Day column and closing back to the Day; Inbox as a sidebar row (doc 14 §3 says a "Later (3)" row); the Earlier fold; click the big dot for Focus. The owner's statement approves the layout as the replacement; it does not by itself settle these individually tagged items. The board's own header still says it "replaces neither" E-Focus nor E-Workspace (§14.3 N1).
  - **AWAITING OWNER DECISION** — the phone minimal choices (tab names, Settings location, Earlier row, tap-to-Focus, time summary, tab-label grey; ED-055), and whether phone minimal (Now · Today · Inbox) and wide minimal (Now · Inbox · Calendar · Search) should share one destination set.
  - **AWAITING OWNER DECISION** — where Show everything lands on Mac/web. E-Minimal says "Opens E-Focus", which is no longer on the canvas (§14.3 N2).

### 9.3 Focus

Two different things carry the name; keep them apart.

- **Focus, the feature (kept; not removed by v1.1):** the per-task Focus action and focus session (`/focus/:id`), reached from the phone task sheet's Focus tile, the Focus button and big-dot click on E-Minimal's Now pane, ⌘F in the Mac context menu, and the Now mini window (⌥⌘0). The focus session screen itself is **not designed on any E board** (running, paused, ended, overrun).
- **Focus, the wide presentation (v1.0 `E-Focus`; historical, names superseded by ED-162):** C's full Mac/web layout in E's look: full sidebar (Now · Day · Calendar · Inbox · Search · Reviews · Routines), Now panel + Day thread + docked inspector.
- **Where drawn:**

| Platform | Board / frame |
|---|---|
| iPhone, Android | Entry points only (`E-Phones` F3 Focus tile; `E-PhonesMinimal` big-dot tap) |
| Mac, web | Feature entry points on `E-Minimal` (Focus button, big dot, ⌘F, mini window). The wide Focus presentation: **no v1.1 board**; v1.0 copy at `references/concept-e/v1.0/E-Focus.dc.html` (archive only) |

- **Relationships:**
  - **DECIDED (visual change only):** the E-Focus board is no longer on the canvas (owner edit, ED-062), and its minimal role is taken by E-Minimal (ED-064).
  - **AWAITING OWNER DECISION:** whether E keeps a full wide Focus presentation (Now + Day + inspector with the full sidebar) at all, as the "Show everything" target on wide, as an alternative to Workspace, or not at all. Not drawn in v1.1 and not assumed here.
  - **AWAITING OWNER DECISION:** whether phones in full mode get a Now view (today Now exists only in minimal on phones).

### 9.4 Workspace / Planning

- **What it is:** B's layout in E's look: Inbox / capture column · time grid with a thread per day and time-proportional cards · docked inspector; ⌘K command palette. The planning surface (Plan: Inbox, Routines, Brain dump; Calendar views Day / 3 days / Week / Month; Review).
- **Where drawn:**

| Platform | Board / frame |
|---|---|
| Mac (1280 × 800) | `E-Workspace` Mac Week + menu-bar and ⌘K insets (byte-identical to v1.0) |
| Web desktop (1280 × 800) | `E-Workspace` web Day (byte-identical to v1.0) |
| Phones, tablets, mobile web | Not drawn |

- **Relationships:**
  - **AWAITING OWNER DECISION:** whether Workspace is E's wide full / default presentation, whether it is what Show everything opens from E-Minimal, and how its sidebar, ⌘1–4 map, ⌘K palette and Day menu reconcile with E-Minimal's (§14.2, §14.3).
  - All Workspace structure is tagged Hypothesis on the board (ED-043 to ED-051).

### 9.5 Summary

| Presentation | Phones | Mac / web | Status of its relationship to the others |
|---|---|---|---|
| Standard Today / Timeline | `E-Phones` | none (thread only inside E-Minimal and E-Workspace) | Wide Standard: AWAITING |
| Minimal | `E-PhonesMinimal` | **`E-Minimal`** | E-Minimal = wide minimal: DECIDED (ED-064). Its hypothesis-tagged internals and the Show-everything target: AWAITING |
| Focus (feature) | entry points | entry points | Kept; session screen not designed |
| Focus (wide presentation) | — | none in v1.1 (v1.0 E-Focus archive) | AWAITING |
| Workspace / Planning | — | `E-Workspace` | Default/full role: AWAITING |

## 9.6 Settings, Wake Up and Wind Down, and the night dial (approved 2026-11-04, ED-081 to ED-084)

**Settings root**
- **Order on every platform:** Account → Layout (first row, G1-4) → Search settings → six groups: Your day · Planning · Reminders · Appearance · Data and privacy · Help and about.
- **iPhone:** 30 pt tinted square tiles (8 pt corners), icons at 60% of the tile:

  | Group | Tile background / icon colour | Icon |
  |---|---|---|
  | Your day | `#FBEBC8` / `#9A5A0E` | sun |
  | Planning | `#E2EFEC` / `#0B4642` | planner |
  | Reminders | `#E6E3F7` / `#4B3FB0` | bell |
  | Appearance | `#F6E2EA` / `#9C3D63` | half circle |
  | Data and privacy | `#E3F1E7` / `#1D6436` | lock |
  | Help and about | `#EDE7DF` / `#4E4757` | question mark |

- **Android:** round tonal 40 dp icons (`#CFE8E4` / `#062F2C`) in two-line list items; segmented Layout button with a check.
- **Mac:** a Settings window with panes General (Layout first) · Your day · Planning · Reminders · Appearance · Data and privacy · Help, and search in the toolbar.
- **Web and tablets:** two panes.
- **Minimal:** keeps its nine built rows. Its Everything else… opens the six-group root.
- **⌘K / k:** called "Search or run" in both modes. "Everything else…" is only the Settings row.

**Wake Up and Wind Down** (Settings › Your day)
- **Words:** Wake Up starts the day; Wind Down is the planned end of the day; the night runs from Wind Down to the next Wake Up. There is no separate bedtime.
- **Schedules:** groups of weekdays that share times, built over the existing per-weekday values ("Different days").
  - Each day belongs to one schedule.
  - Days without a schedule use Every day.
  - "Remove" returns a schedule's days to Every day, with Undo.
- **Caps:** sun `#FBEBC8` / `#9A5A0E` for Wake Up, moon `#E6E3F7` / `#4B3FB0` for Wind Down. The night band is `#ECE8F8` with a 4 px `#8D86D2` thread.
- **Sections:** Tonight · Your week · The night (sleep target, night arc) · Wake Up alarm · Reminders.
  - Alarm options appear only when "Ring like an alarm" is on.
  - Sound and snooze are shared by every schedule. Each schedule only says whether it rings.
- **Copy:** "Matches / N min under / N min over your 8 h sleep target", in plain text, never warning colours.

**Night dial layout rule** (any 24-hour ring with a centre value)
1. **Four regions, outside in:** four hour labels (outside the band) · night band with the moon and sun handles · ticks · a reserved centre disc.
2. **Labels:** 12 AM / 6 AM / 12 PM / 6 PM, or 00 / 06 / 12 / 18 in 24-hour time. The side labels are stacked.
3. **Fit test:** the duration plus "of night" must fit the disc's inscribed box with 6 pt padding, at 34 → 30 → 28 → 26 pt × the text scale. It never goes below 26 pt.
4. **Otherwise below:** if it doesn't fit, the duration goes below the dial at full size and the disc shows a moon. It always goes below at text 135% or more, or when the dial is under 240 pt.
5. **Size:** the dial is 240–360 pt. The band is 12% of the size; handles are the band + 4 pt.
6. **Time fields:** two fields always sit under the dial. The handles are sliders (step 5 min, Shift 30 min).

**Alarm device**
- Each account has one "Alarm sounds on" device: a phone or tablet. Only that device arms Wake Up; others disarm when they sync. Mac and web never ring.
- **States:** Ready (with confirmed time) · Waiting to sync · Alarms off on the chosen device · No device rings · Offline · Switching.
- There is no backup ringing and no exactly-once claim across devices.

## 9.7 Task editor (G2-5 option D, approved 2026-11-04, ED-086, ED-087)

- **One surface:**
  - iPhone: a medium detent with a tinted header, the action tiles and Need more time?; pull up for the full editor.
  - Android: a partial M3 sheet that expands to full screen; predictive Back steps full → partial → Today.
  - iPad: the editor beside the day, in two columns.
  - Mac and web: the docked inspector, with a colour and icon popover.
- **Header:**
  - a tint of the task colour (≈12% → 4%);
  - a 60 pt state dot with a 28 pt palette badge, which is the Colour and icon button;
  - an editable title, its underline in the task colour at 33%;
  - a 28 pt done ring.
- **Order:**
  - header · tiles (Done, Move, Shift the rest, Focus) · Need more time?;
  - a date / time / alerts card with 22 pt icons;
  - Repeat and Energy pills;
  - a Steps and Notes card;
  - a More card (Sound, Pin, Travel time, Delete task → Trash with Undo), also reachable from ⋯.
- **Saving:** Done closes and edits save as you go, with Undo per change. Swiping down never discards.
- **Steps and notes in the full editor (ED-137):** the task's existing steps and notes always show below Repeat/Energy; the focused step or note line scrolls into view above the keyboard as it is focused and as it grows; the sheet stays scrollable by hand with the keyboard up.
- **Steps:** a checkbox and an editable text field; ↩ on a step with text adds the next step; ↩ on an empty new step adds nothing (the empty row is dropped and the keyboard hides; ED-136); × deletes the active one. Completion is per occurrence (R-09) and updates "N of M". The active field stays above the keyboard.
- **Notes:** multiline, with links and formatting as built.
- **Colour and icon:**
  - **Compact sheet:** a palette that swipes sideways (44 pt dots; selected = ring and check), then the current, suggested (≤2) and recent icons, then "All icons".
  - **Full browser:** the palette is pinned at the top as Liquid Glass (the only glass in the sheet; the sheet stays solid). Below it: search, category chips, Recently used, the 16 categories and a 5-column grid. The selected icon shows in its colour, and the header previews it.
- **Repeating tasks:**
  - a meaningful change opens a solid sheet: This one / This and following / All (from today; past ones stay as they were) / Cancel. The change is not written until a scope is chosen.
  - calendar series offer This one and All only.
- **Create task:** the same editor with Cancel and Create task. F2 Quick Add stays the two-tap path.
- **Large text:** the title wraps fully, the tiles go 2 × 2, and the sheet opens at the large detent.

## 9.8 Minimal task screen (G2-6, approved 2026-11-04, ED-088, ED-089)

Drawn on `E-PhonesMinimal` (Task sheet row) and `E-Minimal` (Mac inset, web column).

- **Opens from:** tapping a task on Now or Today (phones); selecting it in the Day thread (Mac and web), which puts the task screen in the right column. ✕ or Esc returns to the Day; on Android, Back closes the sheet.
- **Contents, top to bottom:** the task dot and title, "Now · N min left" or the start time; Starts and Duration; **Done** (the one filled, full-width action); Tomorrow and Later side by side; "Need more time? +5 / +15 / +30" (ED-163) only while the task is running; a More options card; Delete task last.
- **Done is first and prominent.** Tomorrow and Later are one tap away. Nothing else competes with Done.
- **Delete task** is small, separate from the other actions, and goes to Trash with Undo.
- **More options** opens the option D editor (§9.7) for the same task and date. Closing it returns to the minimal screen.
- **Not on this screen:** colour and icon, repeat, alerts, steps and notes (all in More options); Move… (in the editor; G2-7).
- **Phones:** iPhone uses E-PhonesMinimal's sheet over the dimmed day. Android uses an M3 partial sheet with the same actions.
- **Mac and web:** the same screen fits the right column (290 px Mac, 510 px web) without crowding. E-Minimal's calm column identity is kept.
- **Platform tablets:** not drawn yet. See the tablet checklist (Prompt D Round 2).

## 9.9 Add modes (G2-8 option A, approved 2026-11-04, ED-091)

Drawn on `E-Phones` (F2, the Add modes row, the FAB-menu inset) and `E-FullA-v2` (Add modes · Mac and web).

- **Three modes:** Task · Brain dump · Routine. Task is the default, with the title field focused.
- **iPhone:** a segmented control at the top of the Add sheet; also a hold on +. **Android:** the M3 FAB menu picks the mode; the sheet shows the mode as its title. **Mac:** File menu items. **Web:** a split Add button with ▾.
- **Brain dump:** the built sheet, not a copy: one thing per line, mic, Today / Tomorrow, Plan it, Earlier dumps (Use again).
- **Routine:** Drop on Today / Tomorrow / Other day…, the routine cards (name, when, steps, length, step dots); tapping one previews it. Edit routines… opens the Routines page.
- **Proposal rule:** both modes end in the one ProposalSheet; nothing is written before Add to day; Discard keeps the dump in Earlier dumps.
- **Other entries stay:** Day menu (Brain dump, Drop a routine), empty day, ROUTINES chips in Add, the Workspace sidebar rows, ⌘K.
- **Minimal:** no modes. Several lines typed into Add open Brain dump's proposal; Routines stay hidden until the hint (doc 14).
- **Keys:** shown as proposals only (G2-10).
- **Tablets:** not drawn; implications in the register (G2-8) for Round 2.

## 9.10 Day menu (G2-9 option B, approved 2026-11-05, ED-093)

Drawn on `E-Phones` (insets 3 and 6), `E-FullA-v2` (Mac menu bar Day on Tue 3 and Wed 4 Nov, web Day ▾), `E-PhonesMinimal` (Day ▾) and `E-Minimal` (Day menu, minimal, Mac and web).

- **Full, one structure everywhere:** Time · Plan · Day · Layout.
  - Time: Need more time ▸ (+5 / +15 / +30, then Shift the rest), Shift the rest from here…, Rebalance….
  - Plan: Brain dump…, Drop a routine…, Pick today's one thing….
  - Day: Duplicate day…, Copy day as text, Review the day, This week.
  - Layout: Low-energy mode, Plan / Reality, Show less.
- **Native presentation:** iPhone native UIMenu from the native Day ▾ (ED-128 D3), in fixed order so the groups read Time · Plan · Day · Layout top to bottom even when the menu opens upward (iOS reverses it otherwise, ED-129); every command, label, availability rule and entry point kept; Android M3 menu from the Day button; Mac menu bar Day plus the toolbar Day ▾; web Day ▾ popover (solid). Group titles are announced as section headers.
- **Replan:** no separate button. Time is the first group; Need more time is also on the Now card and the task screen.
- **Other days:** Time is today-only and shown disabled; Plan / Reality is disabled until a day has a reality.
- **Minimal phones:** Show everything · Low-energy mode · Settings (three items, doc 14 §4).
- **Minimal Mac and web:** E-Minimal's richer menu with aligned names: Need More Time ▸, Shift the Rest From Here…, Brain Dump…, Drop a Routine…, Duplicate Day…, Copy Day as Text, Review the Day, Low-Energy Mode, Show Everything. Minimal hides, never removes: every command stays in the menu bar for the keyboard and VoiceOver.
- **Names (G3-10 resolved, ED-162):** Low-energy mode · Brain dump · Review (singular, never Reviews) · Today = the screen, Day = the actions menu (never merged) · Need more time? as a question, Need More Time… where it opens further choices (+5 / +15 / +30 kept) · Delete on phones and web, Move to Trash ⌘⌫ in Mac menus (same workflow: Trash for 30 days, Undo for 30 s). Mac application menus use Title Case (Low-Energy Mode, Brain Dump…, New Brain Dump…). Never "Running late", "Gentle Day", "Low-energy day", "Reviews" or "Clear your head" in user-facing copy. Internal identifiers keep their names (e.g. l10n keys `runningLate`, `runningLateBy`, `snackRunningLate`; persisted values unchanged); only visible strings change.
- **Need more time amounts (G3-11 resolved, ED-163):** exactly +5, +15 and +30 minutes on every platform and mode, wherever the user chooses an extension (task sheet, Now card, inspector, Day menu, right-click, web popover). Each choice extends the task in its own task and date context, using the built extension and overlap rules, and is applied once, only on that tap or keypress; opening a menu or sheet applies nothing. ⌘K keeps one quick command, "Need more time · +15 min", and Need More Time… for the others. Phone chips are 44 pt high and wrap under the label at 200 % text; accessible names "Extend task by 5 minutes" (15, 30). Tablets: three choices required, layout decided in Prompt D Round 2.
- **Task colour pickers always offer ⋯ All colours (ED-161, owner comment 2026-11-07):** wherever a task's colour is chosen while creating or editing a task on iPhone and Android (the Colour and icon sheet, its compact state and the All icons sheet), the pinned row shows the 12 approved colours and a ⋯ button beside Done that opens the All colours half sheet. Every create and edit screen reaches colour through the dot's Change badge, which opens that sheet. Mac and web use the Colour popover, which already shows the full palette, Your colours and Custom colour…, so it needs no ⋯. Settings › Appearance › App colour stays as approved (its own swatch row and Edit palette half sheet) and is not changed by this rule.
- **Minimal accessible summaries (CR-138, ED-165):** in Minimal, spoken and visible summaries describe the current task, what is next and the Earlier section by name and time. They never give done or ahead counts, totals, planned hours or percentages. Times, durations and time left stay, because they are needed to act.
- **Low-contrast exceptions (CR-133, ED-165):** under 3:1 is allowed only for decorative (`aria-hidden`) or inert content: the faded preview, and content behind the dimmed backdrop of a modal sheet, which must be inert. A selected colour always shows a check glyph at 3:1 or better as well as its halo.
- **Earlier fold (G3-12 resolved, ED-164; approved design requirement, not built):** done tasks whose time is before now fold into one collapsible row labelled only "Earlier". No count, no "N done", no number in the row; the collapsed row may show up to three overlapping dots in the done tasks' colours (never more, so it is not a count) and Show ⌄ / Hide ⌃. Only done tasks fold: open, current and upcoming tasks always stay on the thread, even past their time. No done tasks before now: no Earlier row. Expanded rows keep title, time, icon, colour, the built done appearance and every action; reopening moves the task out of the group back to its time-ordered place, with focus following it. Expanding never changes the selected date, the current task or the scroll position; state is kept for the day while the app is open and resets when the date changes. Folding is presentation only (stored times, order and completion unchanged). Where: Minimal Today on phones, the Minimal Day column on Mac and web, and the Full Mac/web Day column (E-FullA-v2). Full phone threads and other Full screens keep done tasks in place and keep their approved counts. Accessibility: phones 48 pt / 48 dp row, VoiceOver and TalkBack "Earlier, done tasks, collapsed/expanded"; Mac and web a disclosure button (`aria-expanded`, `aria-controls`), Tab to reach, Space/Return toggles, → / ← open and close on Mac, 3 px teal focus ring at 45 % on web; reopening announces "<task> reopened"; reduced motion shows rows without sliding. Tablets: Prompt D Round 2. States: board E-Earlier. Supersedes doc 14 §4 "done task keeps its place" (amended with a superseded note).
- **Keys and routes:** shown as proposals only (G2-10, G2-11).
- **Tablets:** not drawn; implications in the register (G2-9) for Round 2.

## 9.11 Keyboard (G2-10 option B, approved 2026-11-05, ED-095)

- **Modifiers:** ⌘ on Mac and iPad keyboards; Ctrl on Android, Windows and Linux; web single keys outside text fields, plus ⌘/Ctrl K, Z, ↩ and S in the editor.
- **⌘1–4 follow the places of the mode:** Full is Today · Inbox · Week · Month (as built); minimal is Now · Inbox · Calendar · Search. ⌘2 is Inbox in both. The web uses 1–4.
- **Never bound:** OS-reserved keys (macOS ⌘M, ⌘H, ⌘W, ⇧⌘G, ⌥⌘D, ⌃⌘F; iPadOS and Android system keys) and browser keys (⌘/Ctrl N, T, W, L, D, 1–9, ⇧N, ⇧T, ⇧P, Back / Forward). Text fields keep their editing keys.
- **Built keys keep their meaning:** ⌘D Done, ⌘↩ Inbox placement, ⇧⌘P auto-plan, ⌘S save, ⌘↑↓ / ⇧⌘↑↓ nudge, Space Done, ↩ Open.
- **One key per command per menu bar.** Keys appear in menus, web tooltips, the ⌘/ sheet and ? on the web.
- **No key for** Need More Time, Shift the Rest, Rebalance or Duplicate (Day menu, context menu, ⌘K).
- **Single-key web shortcuts can be turned off** (WCAG 2.1.4).
- **Tablets:** not drawn; see the register (G2-10).

## 9.12 Web routes and links (G2-11 option A′, approved 2026-11-05, ED-097)

- **Addresses:** hash URLs as built (`dottoday.app/#/today`). Every built route and every `dottoday://` link keeps working; apps use the same paths.
- **New routes:** `/now`, `/3-days/:date`, `/week/:date`, `/month/:yyyy-mm`; `?task=<id>` on `/now /today /day /3-days /week /month /inbox /search` only (one key, one UUID v7, the signed-in user's task). No search text in any address.
- **A link never changes the mode.** It opens the closest place the current layout has (table in ED-097):
  - Full phones: day, 3 Days and Week links → Today tab on day D; Month → Calendar tab; `/now` → Today.
  - Full Mac/web: the Workspace view named; `/now` → Today.
  - Minimal phones: `/today` = Today tab (never Now); day, 3 Days and Week → Today tab on day D; Month → Today tab with the month sheet open; Search as from Settings › Everything else.
  - Minimal Mac/web: `/today` reveals and focuses the Day column on today (address stays `/today`); day, 3 Days and Week → Calendar on that month with the Day column on day D; Month → Calendar.
  - D = today when the range holds today, else its first day.
- **Task links** open on the task's current date: Inbox, `/today` or `/day/<date>`, with `?task=`; a repeating task opens its occurrence's date; unknown or not yours → `/today`, silently.
- **History:** one Back step per view, date or task the person opens; redirects, mode switches and resizes replace the entry; closing a task removes `?task=`; refresh restores view, date and task; Show Everything returns to the Full view left.
- **Unchanged:** sign-in callback (`dottoday://auth-callback`, handled before the allow-list), web sign-in code (read by Supabase before the `#`), calendar connect return, notification, widget, Live Activity, status-item, shortcut, tile and Share links.

## 9.13 One screen per job (G2-12 option A, approved 2026-11-05, ED-099)

- **Merge the screen, keep the doors.** A duplicate becomes one screen with one behaviour; every entry point that reached it still does. Presentation follows the platform; the content and rules do not change between them.
- **Day review:** one body. iPhone sheet (large detent); Android M3 bottom sheet (predictive Back closes it first); Full Mac/web: the Workspace's Review place, Day review and Week in Review side by side with their own headings; minimal Mac/web: the Day column, like a task, ✕ / Esc back to the Day; minimal phones: the sheet without the Week in review row. Doors: Day menu › Review the day, the Wind Down prompt (stays inline), the Wind Down notification (`/review`), sidebar Review, View › Review and the finder (minimal wide), ⌘K.
- **The When picker:** one picker answers "when?" for Inbox Schedule, Move, Move To… (⇧⌘M, web `m`) and the screen-reader route for drag. Order: free-time suggestions, then day chips (Today, Tomorrow, next days, Date…), then the thread for the exact time. Phones: a sheet; Mac/web: a popover with typed date and time fields. Drag still places directly; ⌘↩ still places in the first gap; overlaps allowed (ADR-0015); pinned tasks do not move; repeat scope asked first; Undo after every placement; the task keeps its length.
- **Accessibility:** suggestions are buttons that read the full time; the thread is a slider with text values; every control is reachable by keyboard on Mac and web; focus returns to the row that opened the picker.
- **Names:** the weekly reflection is **Week in review** (Mac "Week in Review"); **Week** is only the calendar view. Do not rename routes for a label change (`/review` stays).
- **Kept as several doors on purpose:** Add vs the Inbox field; Notification health; Default alerts; Account and sync; Feedback, What's new, the Wake Up explainer; Export (ED-098).

## 9.14 Switching Full ↔ Minimal mid-action (approved 2026-11-05, ED-100; clarifications approved, ED-103)

- An unfinished drag is cancelled (the block returns; nothing written). A multi-selection is cleared without applying anything.
- Kept across the switch: the selected date, the open task (reopened in that layout's task surface), every saved edit, and the Undo stack.
- Unsaved text or editing state is never dropped silently: it is carried into the new layout, or the switch asks first (Keep editing is the default).
- A proposal sheet is never accepted by a switch.
- Applies to every way of switching and to a width-class change on resize: a responsive transition never causes an unintended change, and saved data, drafts and editing context are kept. Behaviour only; not drawn.

## 9.15 Phone bottom row (G3-6 part, approved 2026-11-06, ED-124, ED-125)

The approved source boards are `E-G3-6-BottomRow` (iPhone, proposed frames) and `E-G3-6-Android` (revised option C). The active boards carry the same frames (ED-126). Glass architecture (native vs drawn) is **still open** in G3-6.

| | iPhone (ED-124) | Android (ED-125) |
|---|---|---|
| Bar | Glass tab bar, left 21, right 90, bottom 21, 63 tall, radius 31.5, padding 5; width 279 on a 390 pt phone (291 on 402). Minimal on iOS 26+: native capsule width, 6 pt from the +, larger left inset (ED-132) | Floating frosted toolbar, left 16, right 80, bottom 24, 72 tall, radius 36, items from 8 down; width 316 on 412 dp |
| + | Separate 63 pt circle, right 21, bottom 21, 6 pt from the bar, centres level; teal glass, white plus 28 | 56 dp, radius 16, right 16, bottom 32, 8 dp from the toolbar, centred on it; frosted tonal, icon-only |
| Day | Glass chip 44 tall, right 21 (in line with the +), bottom 16 pt above the bar | Frosted button (40 dp Full, 48 dp Minimal), left 16 (in line with the toolbar), 16 dp above |
| Destinations | Full: Today · Inbox (badge) · Calendar · Search. Minimal: Now · Today · Inbox (badge) | Same |
| + action | Tap: Add on Task, title focused. Hold: Brain dump, Routine, Paste a list | Tap: M3 FAB menu Task · Brain dump · Routine |
| Day action | Native pull-down Day menu, anchored to the chip (opens up and right-aligned) | M3 Day menu from the button |
| No Day button | Calendar tab | Calendar destination |
| Surface | Liquid Glass (approximated on the boards; native in N3) | Frosted blur on 12+, solid tonal on 11 and older. Not Liquid Glass |
| Reduced transparency / high contrast | Solid bar and solid teal +; solid edges with Increase Contrast | Solid tonal when blur is off or on 11 and older; contrast check on the solid colours |
| Touch targets | + 63, Day 44, tabs ≈ 70 × 63 | + 56, Day ≥ 48 (hit area), items ≈ 79 × 72 |
| Order for screen readers and keyboard | Day ▾, tabs, + (to verify) | Day, destinations, + (to verify) |
| Insets | Over the home-indicator area, where iOS puts its own tab bar | 24 dp above the edge with gesture navigation; 16 dp above the system bar with 3-button navigation; hidden while the keyboard is open |
| Text size | Tab labels fixed size with Large Content Viewer; Day ▾ grows | Labels follow font scale to 200 % (overflow handling to check) |
| Older systems | Minimum stays iOS 16. iOS 26+ for native glass buttons; iOS 16–25 fallback with the same geometry (open in G3-6) | Android 12+ blur; 11 and older solid |
| Sheets and menus | Sheets cover the row at the large detent; the row underneath keeps the new geometry; menus anchor to the moved Day ▾ | Same |

Rules:
- Do not convert Search into Apple's search-role tab; it stays a regular Dottoday tab.
- Native build rule (from N3): align the + to the glass capsule's measured frame, never to the tab bar view, and re-align on every layout change.
- Native menus (ED-131): Day ▾ UIMenu and the + hold menu use fixed element order, so G2-9 and G2-8 read top to bottom as approved when they open upward. On days other than today the Time items, including Need more time, are disabled items (a submenu header cannot be disabled).
- F2 (iOS 16–18) must switch the bar and Day ▾ to a solid appearance itself when Reduce Transparency is on; the classic tab-bar blur does not turn opaque by itself (ED-131).
- **Minimal on iOS 26+ (F1 (a), ED-132):** the + stays 21 / 21; the native three-tab capsule keeps Apple's own width and sits 6 pt left of the +, centres level, so its left inset grows (≈ 39 pt on a 402 pt iPhone; drawn 26 on the 390 pt boards). Align from the rendered capsule bounds on every layout pass; never hardcode 274. F2 (iOS 16–18) keeps 21 / 6 / 21.
- Do not describe Android's frosted surfaces as Liquid Glass, or the toolbar as a standard Material navigation component.
- The phone bottom row is **not** the tablet navigation. iPad (native tabs at the top from iOS 18, sidebar mode) and Android tablets and foldables (rail at medium and expanded widths; the toolbar only at compact width, e.g. a folded foldable) are reviewed separately in Prompt D Round 2 (G4-4).
- Implementation checks still open: listed in ED-124, ED-125, ED-128, ED-129 and `E_IMPLEMENTATION_HANDOFF.md`.
- **Architecture (ED-128):** iPhone row native (N3; F2 on iOS 16–25, conditional; native Day UIMenu); Android row Flutter. Status words: approved visual design · selected architecture direction · feasibility demonstrated · tests still outstanding · production implementation not authorised.

## 9.16 Plan panel on Mac and web (A + B, approved 2026-11-08, ED-184)
- The Plan panel (Capture, Inbox, Routines, Brain dump) is a collapsible pane between the sidebar and the calendar, 196 px (Mac) / 208 px (web), resizable 176–300.
- **Hide / show:** the toolbar's first button (pressed while shown); Mac View › Show Plan Panel ⌥⌘P; web ⌘K "Show / Hide Plan panel"; drag the edge past its minimum to hide, drag from the grid's left edge to show. The state is remembered per window (Mac) or per browser (web).
- **Automatic:** hidden when the week would show fewer than 3 days (840 × 640); shown again on widening unless the person hid it.
- **Brought out:** while hidden, the button opens the panel over the grid (no squeeze); Esc, click away or dropping a task on the grid closes it; the pin docks it. Focus returns to the button.
- **Sections:** Inbox, Routines and Brain dump headers fold with a chevron (open by default, state remembered); Capture stays on top. Not a tab control.
- **Unchanged:** ⌘N Capture, ⇧⌘N Brain dump, the sidebar items, the Day menu, ⌘K, the inspector (⌥⌘I). No timer-based hiding.
- **Accessibility:** one labelled toggle with pressed state; section headers are buttons with aria-expanded; reduced motion shows and hides without sliding.

## 10. Light and dark mode

~~**UNRESOLVED: dark mode is not designed.**~~ **Dark foundation P1 APPROVED (ED-174):** ground #171416 · surface #1F1B1E · raised #28232A · sheet #2F2A30 · popover #37313A · text #F3ECE4 · secondary #C7BEC4 · disabled #8C838A · divider #3E373D (decorative) · outline #8C838A (controls) · teal #5BC4B8 / ink #0C2523 · tonal #1E3A37 / #A3E2D9 · focus #7FD6CB with a 2 px gap · error #F2907F · warning #E9B864 · success #82CF9F · iOS switch on #2A8C83 (light keeps #11615C). Task colours in dark: the fill if it reaches 3:1 on all dark surfaces, otherwise the same hue lightened; the ring, now arc and done fill use it; checks and glyphs in ground ink; the now track at 25 % (decorative). **Dark task colours FROZEN (ED-175):** coral #E2725B, amber #D9A23A, sky #4A9BD6, indigo #7A7EDE, teal-green #2A9D8F, rose #D9668F, green #4CA36B, violet #9672E6, slate #898590, brown #A67F60, plum #B76FA9, olive #828E3C (brown, plum and olive keys unapproved). **Mac dark sidebar (ED-176):** NSVisualEffectView + #3B2F2A at 30 %; selected label #F3ECE4; teal pill; icon #A3E2D9 (I1, ED-178). **Detail tokens (ED-177, derived):** caps at 22 % (Wake icon #D9A23A, Wind Down icon #A9ACEB); now-dot centre raised, arc in the task colour, track at 25 %; now-bead #5BC4B8 with a 2 px ground border, pill teal on raised. **Final (ED-178):** Mac selected icon #A3E2D9 (I1, selected icon only); now-dot without shadow (T1); dotted ahead thread #6B6369 on the ground (T2-B, 3.15:1) and #7B7279 on surface, raised, sheet and tinted rows where measured (Q1-B, ED-179); not on popovers (2.72:1, would need its own correction); dimmed behind inert scrims. **Text (ED-179, light and dark):** placeholder text #6F6978 light / #A0999F dark (≥ 4.5:1); hex-field "#" prefix in secondary text. Stage 1 visual tokens FINAL; Stage 2 screens on E-G4-6-Dark-Frames await visual approval; not merged. Device tests PENDING.

Needed before any dark work:
- Dark values for ground, surface, sunk, tonal, ink, secondary, hairlines, scrims.
- A dark task palette (or a rule) with 3:1 rings and readable icons.
- Dark accent (teal) and accent-tonal pairs; now-bead and pill.
- Wake/Wind cap pairs; orb track, centre and shadow.
- iOS glass recipe on a dark ground (tint, rims, shadows); Android frosted toolbar, + and Day button; Mac vibrancy.
- Dotted thread visibility on dark.
- Contrast check of every text pair on glass as rendered (brief §17).
- No flash on mode switch (quality matrix §3).

**Stage 3 (ED-180, ED-181):** Stage 2 approved; the approved treatment is drawn on a dark companion of every active board. Rules added while merging:
- Blurred shadows stay dark (black, ≤ 50 %); hairline borders become light outlines. No glow.
- Scrims are black (≤ 60 %); the content behind stays dimmed and inert.
- Menus and popovers use #37313A; Mac title bars #28232A; system chrome (Safari, Chrome, keyboards, iOS switch off track #39393D, swipe grey #636366) uses the system's own dark colours.
- Custom colours (task or App colour) get a derived dark shade when drawn: ≥ 4.5:1 for text use, ≥ 3:1 for rings (e.g. olive #5E7A39 → #739646).
- Drawings that are dark in both themes (the Wake Up alarm screen) keep their drawing.

---

## 11. Platform-native interactions

| Platform | Rules drawn or noted on the boards |
|---|---|
| **iPhone** | Hold a dot to select several (hold-to-select stays; long-press never opens a menu instead). Edge swipe Back. Native pull-down for Day ▾. Cupertino sheet with detents and grabber (36 × 5 `rgba(60,60,67,.3)`). iOS segmented control and switch. SF Symbols chrome (native path). Swipe actions. Undo toast above the tab bar |
| **Android** | Long-press a dot to select several. Predictive Back: closes the dialog, then the sheet; shrinks the sheet as you swipe. Edge-to-edge. M3 top app bar, floating navigation toolbar (custom), FAB menu, dial time picker with keyboard toggle, M3 menus. Material Symbols. Snackbar Undo |
| **Mac** | Menu bar: Dottoday File Edit View Go **Day** Window Help + status item showing the live task ring and "18 min". Settings ⌘, in its own window. Right-click menus. ⌘N new task, ⇧⌘N brain dump, ⇧⌘G go to date, ⌘T today, ⌘[ ⌘] days, ⌥⌘0 Now window, ⌥⌘I inspector (Workspace), ⌘Z undo. Minimal (E-Minimal): ⌘1–4 Now / Day / Calendar / Inbox, ⌥⌘D show/hide the Day column, ⌘K Everything else, ⇧⌘→ Shift the Rest, ⇧⌘C Copy Day as Text, ⌘F Focus, Esc closes the task in the column. Traffic lights. Drag from Inbox to the grid with a teal drop target and landing time (Workspace); drag to move on the Day thread (built today) |
| **Web** | ~~Path URLs (`/now?task=…` in E-Minimal, `/plan/day/2026-11-03?task=…` in Workspace, `/today`, `/settings`)~~ superseded by ED-097: hash URLs (`/#/now`, `/#/today`, `/#/day/:date`, `<view>?task=<id>`); refresh and Back restore the open task. Compact (phone-width) web: own web bottom bar, no glass or Material imitation, no custom edge-swipe (ED-172, board E-MobileWeb). Single-key shortcuts outside text fields: `n` add, `/` search, `t` today, `[ ]` days, `?` help, `m` move, ↑↓ focus, Alt ↑↓ move block, Enter open; `k` Everything else (E-Minimal). Ctrl/⌘K palette (Workspace). Never Ctrl/⌘ N, T or W. Visible focus ring, hover actions. Solid surfaces |

Shortcut conflicts between boards are listed in §14.

---

## 12. Accessibility and responsive rules

### 12.1 Accessibility

- Targets: 44 pt (Apple) / 48 dp (Android). Six controls on the boards miss this (§6.4).
- Text to 200 %: rules in §3.4 (G3-3, ED-110). Phone Today measured at 200 % (ED-103); the orb centre (ED-106). Other layouts at 200 % are not yet drawn.
- State is never colour alone: "Now", "done", "Calendar", "repeats", the ring and the fill carry it. The dotted thread is decorative. E has no halos.
- Screen readers: the thread is a list in time order (`role="list"`); each dot exposes Done/Reopen, Move to…, Shift the rest, Select, Focus. The horizon has a full summary label. Day menu sections need announced headers. Need more time? on another day needs a spoken reason (it is today only).
- Contrast (computed on `#FBF7F1`): ink 15.07, secondary 5.45, teal 6.81. Fails: iOS inactive tab label `#8E8E93` 3.06; four task colours below 3:1 as rings; white on amber 2.29. Glass contrast as rendered: **UNRESOLVED**.
- Reduced motion: bead glow static, completion pulse becomes a fade. Reduced transparency: **UNRESOLVED**.
- Dimmed side days keep text at 4.5:1 (Map).
- No-shame copy: no streaks, no red for incomplete, no "late/missed/failed". "Still open", "ended", "free", "Need more time?" follow it. "Running late" is gone from every active board (ED-162): Need more time? as a question, Need More Time… where it opens choices.

### 12.3 Text always fits (ED-183, owner, 2026-11-08)
Text never falls out of its container, at any window size, text size (Dynamic Type / font scale up to 200 %) or zoom. Checked on every board with an automated fit check; part of done for every screen.
- **Controls** (buttons, pills, tabs, segmented controls, chips, menu items): the label stays on one line and the control sizes to it. Never wrap inside a fixed-height control and never clip it.
- **When a row of controls runs out of room**, it changes form instead of squeezing: tabs become a pop-up button (Day · 3 days · Week · Month → "Week ⌄" at 840), a search field becomes its icon with ⌘K, secondary items move into the overflow menu or the View menu. Item order and shortcuts stay the same.
- **Content text** (titles, notes, descriptions) wraps onto more lines; the container grows or scrolls. Never clip a line mid-letter.
- **Fixed geometry** (time blocks on a grid, chips with a set size): the title ends with "…" on the lines that fit (one line for short blocks, two for overlap blocks). The full text is always available: the accessible name, the tooltip on hover and the task sheet.
- **Hint bars** (the web keyboard hint): show the hints that fit and always end with "? all keys"; nothing is cut off at the edge.
- **Menus and popovers** open fully inside the window (macOS and browsers keep menus on screen); a submenu that would not fit opens the other way or is narrower.
- **Scrolling content** may be cut at the scroll edge (timeline below the fold, week columns past the visible days); that is a scroll affordance, not a fit failure.
- **At 200 % text** the layout reflows (rules §12.1–12.2); controls may stack, but labels still follow the rules above.

### 12.4 Shared states (G4-7 option A, ED-186; look and one state system approved as direction, ED-187; Q2 closed at design level, ED-188 to ED-193; Q3 Undo approved, ED-194; Q4 Keep both for notes approved, ED-195; Q4-L1 and Q5 approved, ED-196; G4-7 closed at design level)
- One kit for every platform and both themes; tablets inherit it (presentations in Round 2).
- **Truthful wording:**
  - "Saved on this device" (iPhone, Android, Mac) only after the local write succeeds. Web always says "Saved in this browser" after a successful local save, even when the browser has agreed to keep storage (ED-188); never "Saved on this device" on web.
  - Web asks the browser to keep its storage once after sign-in (ED-188); the answer never changes wording, never blocks use, and is never described as protection against data loss. Clearing this site's data can remove work not yet synced: web Sync details says so (ED-189; caution wording ED-190; approved ED-191). Not signed in: "Not signed in · saved in this browser" after a successful save; card "Only saved in this browser"; Sign in; no account-copy promise until CR-160 is verified (ED-192). Calm "In this browser" information always; a caution card only while changes wait to sync; a storage line for kept / isn't kept / can't be asked. Never "clearing browser cache", never a banner on other screens, never a re-ask button.
  - Never fake progress: only real counts ("12 of 40").
  - Loading shows still skeletons after 300 ms; tasks are never shown as gone.
- **Sync status = icon shape + words (+ badge)**, never colour alone: synced, syncing, offline, waiting (count), couldn't sync, paused (clock), needs you (conflict), couldn't save, session ended, on this device.
- **Retry vs resubmit:** Try again / Sync now resend the same saved changes (same ids); a failed save keeps the draft open and retries the same save.
- **Conflicts:** nothing is overwritten until the person chooses; the other device's value is in use meanwhile; one card per detail with Keep mine / Keep theirs of equal weight.
- **Undo after a conflict choice (ED-194):** about 10 s in the confirmation (phones: bottom confirmation; Mac/web: Sync popover, ⌘Z / Ctrl+Z only when it applies and no text field or other Undo has focus). Saves the replaced value as a new edit; never overwrites a newer remote change (opens the conflict review instead). Pauses on focus or hover; stays while a screen reader is on; dismissable; no visible countdown or animation.
- **Keep both (ED-195):** notes only. Order: this device's notes, a blank line, "— From your other device —", the other device's notes (plain text, nothing trimmed or reordered, no invented time or device). Phones stack the three choices; Mac/web show a row and stack at narrow widths and 200 %. Titles and every other field keep two choices. Combined over 10,000 characters as the app validator counts (UTF-16 `String.length`, covering both databases' code-point checks): Keep both disabled with "Keep both isn't available", Copy on each version, nothing trimmed (Q4-L1, ED-196).
- **Glyphs on amber dots (CR-162, ED-196):** the type icon and done check inside an amber #D9A23A dot use ink in both themes (light #241F2B, dark #171416).
- **Android "What is it?" placeholder (Q5, ED-196):** light #6A6473, dark #A0999F.
- **Accessibility:**
  - sync changes announced politely, once; a failed save announced assertively;
  - Reduce Transparency → solid surfaces with outlines; Increase Contrast → secondary text one step darker, stronger thread;
  - Reduced Motion → no ring or sheet animation;
  - largest text → one column, nothing truncated.

### 12.2 Responsive

- Layout follows **available width**, never the device: compact < 600, medium 600–839, expanded ≥ 840.
- Platform decides conventions (shell, controls, Back, menus). Input decides interaction details.
- Mac and web at the same width share the layout; chrome differs (traffic lights, mini window, Settings window vs sidebar row).
- ~~Inspector overlays below 1100 px and docks from 1100~~ (superseded by ED-167). **G4-2 (ED-167, approved strategy):**
  - Layout classes stay compact < 600, medium 600–839, expanded ≥ 840, measured on the app window's available width in logical pixels, never device type or physical resolution.
  - The task editor floats over Today below 1160 and docks from 1160 only if the sidebar, Today and the editor all keep their minimum widths.
  - Moving between floating and docked keeps the same editor instance. It never saves, never commits a proposal, and never loses text, fields, steps, notes, focus or scroll. The selected task and date don't change. The existing Cancel, Save and unsaved-change safeguards stay.
  - Phones keep their approved native editor (sheet).
  - **H1 (ED-168):** when usable height (after safe areas, not counting the keyboard) is under 480, use the compact layout and never dock. Platform chrome stays native (web keeps web chrome; Mac never reaches H1). Full and Minimal never switch. The keyboard never changes the layout class.
  - **M (ED-168):** Today ≥ 480, or ≥ 600 when text is above 130 %; editor 420; sidebar 216. Dock only from 1160, and only if these plus dividers, gutters and margins fit. Thresholds are computed, not hardcoded. Prefer floating to squeezing.
  - **PENDING device testing:** landscape iPhone and Android, keyboard, short desktop and browser windows, Split View, foldables, and 100 / 130 / 200 % text on both sides of every boundary.
  - Board: E-Responsive. The Inbox column from ≈ 1220 (concept doc) is unchanged.
- Mac minimum window **840 × 640** (ED-169, design only; the app still uses 960 × 640); opens at 1280 × 800. **Approved (ED-170):** Minimal Day column folds below the computed fold point (≈ 1042 at 100 % text, recomputed for larger text) to a 44 px "Day" edge button (no shortcut) that opens the same column as a non-modal panel; narrow toolbar; short-window now-dot; C1 (a), the Workspace inspector (248, docks from 1160 when ≥ 3 days fit) is a different surface from the task editor (420). **Tablets (ED-171):** width classes with native navigation, iPadOS tab bar / sidebar / split view; Android rail at medium, sidebar expanded; screens in Round 2. Drawn widths: 390 pt, 412 dp, 1280 × 800, and E-G4-3-Narrow at 840–1280. Medium, iPad, Android tablet/foldable, mobile web and narrow desktop windows: **UNRESOLVED**.
- E-Minimal at 1280: Mac 200 + 790 + 290; web 210 + 560 + 510. How the Now pane, the Day column and the sidebar give way below 1280 (Mac minimum 960 × 640), and whether the Day column folds automatically: **UNRESOLVED**. ⌥⌘D / "Hide the day thread" is the only drawn fold.

---

## 13. Checklist for designing a new E screen

1. Name the presentation (Standard, Minimal, Workspace; or the Focus feature) and the width class. A wide Focus presentation has no v1.1 board (§9.3); do not draw against v1.0 E-Focus without an owner decision.
2. Open the nearest live E board frame and copy its structure before inventing one (wide minimal: `E-Minimal`).
3. Content in Manrope; system chrome in the platform's system font (§3).
4. Colours only from §4. New colours need a log entry and a contrast check.
5. Tasks appear as dots on a thread (or a horizon) in their colour, with the right state (§4.4, §5).
6. Overlaps drawn with the knot; never blocked.
7. iOS: glass only on floating chrome; sheets solid. Android: tonal, no rims; menus, sheets, FAB solid. Mac: vibrancy approximated, native menus. Web: solid, focus ring, hover.
8. One Add and one Day menu reachable on every screen where the day is shown.
9. Keep hold-to-select on iOS and long-press-to-select on Android. Every gesture has a non-gesture route (Move to…, menu item).
10. Touch targets 44 pt / 48 dp; check contrast including on glass.
11. Copy passes the no-shame rule.
12. Minimal mode: declare the docs/14 §3 row and `FeatureId` before building.
13. Any generated change goes through the proposal sheet; nothing written before Accept.
14. Draw empty, loading, error and offline states.
15. Mark each element Built today / Design-only / Hypothesis / Platform note.
16. Update the board, this file and `E_DESIGN_DECISIONS.md` together.

---

## 14. Unresolved specifications

### 14.1 Not designed

1. Dark mode (all tokens, glass on dark, palette).
2. Motion: durations, curves, transitions, haptics, bead glow, completion pulse, drag lift, reduced transparency.
3. Open-past-end task on the thread during the day ("ended 9:15 · still open"); only the end-of-day card exists.
4. Hold-to-select / multi-select state and drag-in-progress on phones.
5. iPhone large-detent full editor; iPhone Move picker (wheels).
6. Web Day menu popover; Mac/web Add popover and live chips.
7. Medium width, iPad, Android tablet/foldable, mobile web, narrow desktop window.
8. Empty, loading, error, offline and sync-conflict states beyond the empty day.
9. Calendar destination screens (Month on phones, Week/Month wide) in E.
10. Search, Inbox screen, Settings, onboarding and Wake Up missions in E.
11. Orb colour derivation for task colours other than indigo.
12. Full task-colour list and a contrast-safe palette rule.
13. Ordering of tasks that start before Wake Up.
14. Cap tap behaviour (Your day dial) visuals.
15. Wide presentations: which one is the full/default wide layout (Workspace, a wide Focus presentation, a thread-only Standard); where Show everything lands from E-Minimal; whether a wide Focus presentation exists in E at all (§9). *v1.1: what minimal means on wide is answered — E-Minimal (ED-064).*
16. Dot "depth" and bead "glow" described in docs but not drawn.
17. Final chrome icon glyphs (SF Symbols / Material Symbols mapping).
18. Glass contrast as rendered; reduced-transparency fallback.
19. Focus session screen (`/focus/:id`: running, paused, ended, overrun) on every platform.
20. E-Minimal states not drawn: empty day, morning before the first task, evening / all done, overrun, no current task (what the large now-dot shows), Day column hidden, web task screen in the column, Day menu contents, narrow window.
21. E-Minimal's hypothesis-tagged structure (sidebar kept in minimal, Now as entry, task screen in the column, Inbox row vs doc 14's Later row, Earlier fold) — owner decision per item.

### 14.2 Inconsistencies between boards

v1.0 list, kept. Rows that E-Minimal takes a side on carry a *v1.1* note; the side it takes is the board's choice for wide minimal only, not an owner decision, and E-Phones / E-Workspace still disagree. Rows that cite E-Focus now cite a historical board.

| # | Inconsistency | Where |
|---|---|---|
| I1 | Now-bead 16 px in frames, 12 px in legends; 14 px on wide *v1.1: E-Minimal uses 14 px in frames and legend (wide only).* | E-Phones/E-PhonesMinimal legend vs frames; E-Focus |
| I2 | Now ring track `rgba(task,.2)` vs `#E4E3F7`; cut-out 5 / 4.5 / 4 px *v1.1: E-Minimal uses `#E4E3F7` for the indigo now task, task colour at 20 % for the concurrent task.* | E-Phones vs E-Focus vs legends |
| I3 | Ahead ring 4 px inset vs 3.5 px border vs 3 px | E-Phones vs E-Focus/E-Workspace vs legends |
| I4 | Calendar dot centre `#FBF7F1` / `#FFFFFF` / `#FFFDF9` *v1.1: E-Minimal follows E-Focus (`#FFFFFF`).* | E-Phones / E-Focus / E-Workspace |
| I5 | Wake Up cap 32 px (Today) vs 34 px (Empty day, minimal) | E-Phones F1 vs F4, E-PhonesMinimal F2 |
| I6 | ~~iOS inactive tab label `#8E8E93` (full) vs `#6E6E73` (minimal)~~ resolved: `#6E6E73` everywhere (ED-154) | E-Phones F1/F4 vs E-PhonesMinimal F1–F4 |
| I7 | Android Day button 40 px (full) vs 48 px (minimal) | E-Phones F5 vs E-PhonesMinimal F5 |
| I8 | Android FAB radius 22 (extended) vs 16 (minimal) | E-Phones F5 vs E-PhonesMinimal F5 |
| I9 | ~~Now card radius 24 / height 72 (iOS) vs 22 / 74 (Android)~~ resolved: heights 80 / 82 (ED-104), radius 24 both (ED-202); row heights 48/52 vs 50/54 | E-Phones F1 vs F5 |
| I10 | Add input weight 500 19 vs 600 20 vs 600 19 | E-Phones F2 vs E-PhonesMinimal F3 vs F6 |
| I11 | Orb numeral 800 (phones) vs 700 (Mac/web) *v1.1: E-Minimal 700 (76 / 64). Resolved by G3-2 (ED-106): 800 everywhere.* | E-PhonesMinimal F1/F5 vs E-Focus |
| I12 | Android Edit sheet task title in Roboto, not Manrope *Widened 2026-11-05 (ED-110): task text in system font in several phone sheets; proposed boundary in §3.7, awaiting the owner.* | E-Phones F6 |
| I13 | Android Day menu surface `#F7EFF4` vs `#F3EEE6` elsewhere; AM/PM uses the board's Hypothesis amber | E-Phones inset 6, F6 |
| I14 | Mac sidebar has `blur(30px)` in Workspace, none in Focus *v1.1: E-Minimal follows E-Focus (no blur).* | E-Workspace vs E-Focus |
| I15 | Mac context menu radius 8 vs 10; Delete ⌫ vs Move to Trash ⌘⌫; Running Late only in Workspace *v1.1: E-Minimal follows E-Focus (radius 8, Delete ⌫, no Running Late).* | E-Focus vs E-Workspace **Resolved G3-10 (ED-162).** |
| I16 | Inspector width 300 vs 248; web sidebar 220 vs 216 *v1.1: E-Minimal has no inspector (task screen in a 290 column) and a 210 web sidebar — a third value.* | E-Focus vs E-Workspace |
| I17 | Web focus ring: 3 px outline at 45 % vs 2 px gap + 2 px solid teal *v1.1: E-Minimal follows E-Focus (3 px at 45 %).* | E-Focus web vs E-Workspace web |
| I18 | Now panel Add is ink `#241F2B`; Add is teal everywhere else *v1.1: E-Minimal keeps the ink Add on web and uses a teal Add on the Mac toolbar.* | E-Focus Mac/web vs all others |
| I19 | View shortcuts: ⌘1 Now · ⌘2 Day · ⌘3 Calendar · ⌘4 Inbox vs ⌘1 Day · ⌘2 3 days · ⌘3 Week · ⌘4 Month *v1.1: E-Minimal follows E-Focus (Now / Day / Calendar / Inbox).* | E-Focus menu-bar inset vs E-Workspace menu-bar inset |
| I20 | ⌘K = Search field (Focus) vs command palette (Workspace); ⌘F = Focus (Focus context menu) vs Search (Map); Copy as Text ⌘C clashes with Copy *v1.1: E-Minimal makes ⌘K the Everything else finder (also searches) — a third meaning; ⌘F = Focus; Copy as Text has no shortcut; Copy Day as Text ⇧⌘C.* | E-Focus, E-Workspace, E-Map |
| I21 | Low-energy naming: "Low-energy mode" / "Low-energy day" / "Gentle Day" / "Low-Energy Mode" *v1.1: E-Minimal uses "Gentle Day" / "Gentle day".* | E-Phones inset 3, E-PhonesMinimal F2, E-Focus menu bar, E-Workspace menu bar **Resolved G3-10 (ED-162).** |
| I22 | Brain dump named "Clear your head" on Focus; "Brain dump" elsewhere | E-Focus vs all others |
| I23 | Running late increments +15/+30 vs +5/+15/+30 *v1.1: E-Minimal uses +15 / +30.* | E-Phones F3 vs E-Workspace menu bar **Resolved: name G3-10 (ED-162); amounts +5 / +15 / +30 G3-11 (ED-163).** |
| I24 | Destination names: Today vs Day; Reviews vs Review; Plan only in Workspace | E-Phones, E-Focus, E-Workspace **Resolved G3-10 (ED-162).** |
| I25 | Web routes: `/now`, `/today`, `/day/:date` vs `/plan/day/2026-11-03` *v1.1: E-Minimal uses `/now` and `?task=`.* | E-Focus, E-Map vs E-Workspace |
| I26 | Repeat marker: icon vs "· repeats" vs "↻" *Resolved 2026-11-09 (ED-208): the icon.* | E-Phones vs E-Focus vs E-Workspace |
| I27 | Board title "minimal look, Mac and Web" vs frame captions "full (1280 × 800)" *v1.1: historical — E-Focus removed.* | E-Focus |
| I28 | Headers say "dots with depth" and "glowing bead"; frames draw flat dots and a ringed bead | E-Phones header, THREE_UX_CONCEPTS §3.1 |
| I29 | Content type Inter in the concept doc vs Manrope on every board *Resolved by G3-3 (ED-110): Manrope.* | THREE_UX_CONCEPTS §3.1 vs all E boards |
| I30 | "Running late" in Day menus, menu bars and palette conflicts with the no-shame "no late" copy rule; Now uses "Need more time?" *v1.1: E-Minimal uses "Need More Time…"; E-Phones and E-Workspace unchanged.* | E-Phones inset 3/6, E-Focus, E-Workspace vs CLAUDE.md §11 **Resolved G3-10 (ED-162).** |
| I31 | Morning run (6:45) drawn after the 7:00 Wake Up cap | E-Phones F1, F5 |
| I32 | Glass outer shadow varies per element (tab bar, chip, capsule, Close, pull-down) — recorded as elevation tiers *Confirmed 2026-11-09 (ED-210).* | E-Phones, E-PhonesMinimal |
| I33 | E file titles still read "A · …"; E boards not registered in local `canvas.json` *v1.1: E-Minimal is titled "E · …"; live `canvas.json` registers the E boards.* | all E files |

### 14.3 New in v1.1 (E-Minimal against the other E boards and the owner's statement)

*2026-11-04:* N3 is closed by ED-068 (the different sets are the owner's design). N2 waits for G1-1. See §9.0.

| # | Inconsistency | Where |
|---|---|---|
| N1 | Board header says E-Minimal "sits beside E-Focus and E-Workspace and replaces neither"; the owner removed E-Focus and stated E-Minimal is its replacement (ED-062, ED-064). Its caption still tags "This Now + Day column layout as E's wide minimal (ED-005 open)" as Hypothesis | E-Minimal header and Mac caption vs owner statement |
| N2 | Band: "Show everything (full mode) … Opens E-Focus" — that board is no longer on the canvas, so the full-mode target on wide is undefined | E-Minimal band |
| N3 | Wide minimal sidebar Now · Inbox · Calendar · Search vs phone minimal tabs Now · Today · Inbox; doc 14 §3 says no sidebar on expanded minimal and Inbox as a "Later" row (the board marks both as differences) | E-Minimal vs E-PhonesMinimal vs docs/14 §3 |
| N4 | "Day" (wide, ⌘2, column title) vs "Today" (phones) | E-Minimal vs E-Phones / E-PhonesMinimal (continues I24) |
| N5 | Mac sidebar 200 and web sidebar 210 vs 216 (Workspace) and 220 (v1.0 Focus); the web caption says it follows E-Focus but the width differs *Resolved: Full 216 (ED-168); Minimal 200 on Mac and web (ED-207).* | E-Minimal vs E-Workspace |
| N6 | ⌥⌘D show/hide Day column (E-Minimal) vs ⌥⌘I inspector (E-Workspace, E-Map). ⌘2 = Day while the Day is a side column; what ⌘2 does when the column is hidden or a task is open is not drawn | E-Minimal vs E-Workspace |
| N7 | "Everything else" lives in a ⌘K / `k` finder on wide minimal, but in Settings › Everything else on phone minimal | E-Minimal vs E-PhonesMinimal |
| N8 | ⌘K = Everything else finder (E-Minimal) vs command palette (E-Workspace) vs search field (v1.0 E-Focus); web `k` vs Ctrl K | E-Minimal vs E-Workspace |
| N9 | "Need More Time…" (Day menu, finder) vs "Need More Time?" (status-item menu) vs "Need more time?" (Now button) in one board | E-Minimal |
| N10 | Low-energy name: "Gentle Day" (wide minimal) vs "Low-energy mode" / "Low-energy day" (phones) vs "Low-Energy Mode" (Workspace) | continues I21 **Resolved G3-10 (ED-162).** |
| N11 | Large now-dot 280 (Mac) / 240 (web), numeral 700 76 / 64, vs phones 236 / 228 at 800 84 / 80 *Resolved by G3-2 (ED-106): Mac 100, web 85, all 800.* | E-Minimal vs E-PhonesMinimal (continues I11) |
| N12 | Now card 68 px (Mac column) vs 64 px (web column) vs 72 / 74 (phones); now title 16 (Mac) vs 17 (web) *Resolved 2026-11-09 (ED-209): 68 / 16 on Mac and web; phones keep 80 / 82 (ED-104).* | E-Minimal Mac vs web vs E-Phones |
| N13 | Add on wide minimal: teal toolbar + and a Now-pane field on Mac, an ink "Add" pill on web | E-Minimal Mac vs web (continues I18) |
| N14 | Mac Day-column Day button uses the system font; the web "Day menu" button uses Manrope *Resolved 2026-11-09 (ED-206): system 13/500 on both.* | E-Minimal Mac vs web |
| N15 | Web Day column header is "Day ▾" (a view switcher) in minimal, where Week and Month are meant to be hidden | E-Minimal web |
| N16 | The Day column opens on the Earlier fold, so the Wake Up cap is not on the thread (it is only at the horizon's start); phone minimal Today shows the same fold | E-Minimal, E-PhonesMinimal F2 |
| N17 | Task screen offers Tomorrow / Later for the task that is running now; the phone task sheet offers Done / Move / Shift the rest / Focus | E-Minimal task inset vs E-Phones F3 |
| N18 | Ahead ring drawn as a 3.5 px border (Day column) and as a 3.5 px inset (Mac Next row) and 3 px inset (web Next row) | E-Minimal (continues I3) |

