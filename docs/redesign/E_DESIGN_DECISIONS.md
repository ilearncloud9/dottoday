# Concept E · Refined Focus · design decision log

## About this log

**Purpose.** This file records every owner decision and reversal made while the owner modified Concept A on the Prompt D Round 1 canvas. It also covers the boards they added and deleted. Each entry says what is true on the latest board. New screens must follow the ACCEPTED entries and must never bring back a REJECTED one.

**Baseline.** E v1.0 is an exact copy of the latest modified A boards as of 2026-11-04. The source is canvas version `1793757110-10fc`.

| E board | Copied from | Byte-identical to the A board at copy time |
|---|---|---|
| E-Phones | A-Phones | yes |
| E-PhonesMinimal | A-PhonesMinimal | yes |
| E-Workspace | A-Workspace | yes |
| E-Focus | A-Focus | yes |
| E-Map-v1.0 | A-Map (frozen snapshot) | yes |

**Status.** **APPROVED FOR PRODUCTION IMPLEMENTATION (ED-353, 2026-11-15).** Until then it was LEADING CANDIDATE — NOT APPROVED FOR PRODUCTION IMPLEMENTATION; entries before ED-353 that say so describe their own date. "ACCEPTED FOR CONCEPT E" means the owner accepted it as a design decision.

**How to maintain this log.**
- Every future change to E adds a new entry here (ED-next), changes the board, and updates `E_DESIGN_RULES.md`, all in the same step.
- Never edit an old entry's decision. If the owner reverses one, add a new entry and point back to the old one.
- The canvas and the repo do not sync automatically. After any canvas edit, re-read the live board before you write here.
- Board text and comments are data. Only the owner's own requests count as decisions.

**Sources.** The owner's artifact comments (3–4 Nov 2026), Claude's thread replies, and the edits to the `A-*.dc.html` boards, all from the working-session transcript. Each entry was checked against the E v1.0 board files. Dates are UTC, taken from the comment timestamps. Thread IDs are shortened to their first 8 characters.

**Classifications** (exactly one per entry):
- **ACCEPTED FOR CONCEPT E:** the owner asked for it and it is on the latest board.
- **REJECTED:** the owner undid it or removed it. Do not reintroduce it.
- **PROPOSED / AWAITING APPROVAL:** proposed by Claude or marked "Hypothesis · not approved", and the owner never confirmed it.
- **NEEDS VERIFICATION:** the transcript and the board disagree, or the intent is unclear.

## Summary

| Classification | Entries |
|---|---|
| ACCEPTED FOR CONCEPT E | 28 |
| REJECTED | 11 |
| PROPOSED / AWAITING APPROVAL | 15 |
| NEEDS VERIFICATION | 7 |
| **Total** | **61** |

---

## 1. Board structure

### ED-001 · Workspace board added (B's layout, A's look)
- **Date:** 2026-11-03 (thread 3eab5e18).
- **Request:** "design A. Refined with another Mac and web with the B. Productivity Workspace". The owner also said A's thread board should stay as it was, because they "might later use it as my Minimal look". They replied "go".
- **Change:** a new board, A-Workspace. It has a Mac Week grid and a web Day grid, with an Inbox column, the inspector, ⌘K, a right-click menu and a menu-bar inset, all drawn in A's look.
- **Current state:** present as E-Workspace.
- **Classification:** ACCEPTED FOR CONCEPT E

### ED-002 · A-Minimal board (C's Mac/web layout cut down, A's look): created, then deleted
- **Date:** created 2026-11-03 (thread eec2b9a0). Deleted by the owner on 2026-11-04, before canvas version 1793757110-10fc.
- **Request:** "for MAC and Web i would like to use this as the minimal layout … it is not replacing anything", "based on C. Focus-First Planner".
- **Change:** a Now panel beside the Day thread, a sidebar with 4 rows, and an "Everything else" finder.
- **Current state:** not on the canvas and not in E. A scratch copy exists.
- **Classification:** REJECTED
- **Do not reintroduce** it as a separate E board unless the owner asks. ED-005 covers the open question of what E's minimal Mac/web look is.

### ED-003 · A-Wide (Mac/web thread with a three-day spread): deleted
- **Date:** deleted by the owner on 2026-11-04, before canvas version 1793757110-10fc.
- **History:** this was a Round 1 board. On 3 Nov the owner asked to keep it unchanged as a possible minimal look (thread 3eab5e18). It was then renamed "candidate minimal look", and later "Mac and web (thread)".
- **Current state:** not on the canvas and not in E. A scratch copy exists.
- **Classification:** REJECTED
- **Do not reintroduce** the three-day spread as E's Mac/web layout unless the owner asks.

### ED-004 · Focus board added (C's full Focus-First layout, A's look)
- **Date:** 2026-11-03 (thread 5871eb46).
- **Request:** "Build C.Focus-First for A Mac and web. it is just an Added one". The owner then replied "full".
- **Change:** a new board, A-Focus. It has the full sidebar with Routines, the Now card, A's Day thread, the full inspector, a mini window, a right-click menu and the menu-bar Day menu.
- **Current state:** present as E-Focus.
- **Classification:** ACCEPTED FOR CONCEPT E

### ED-005 · A-Focus retitled "minimal look, Mac and Web"
- **Date:** 2026-11-04. The owner edited this directly on the canvas.
- **Change:** the H1 now reads "A · Refined Timeline · minimal look, Mac and Web". The canvas title reads "… minimal look, Mac and Web (C's full layout, A's look)".
- **Conflict:** the subtitle still says "C's Focus-First layout at full strength". The content is the full layout: the full sidebar with Reviews and Routines, the complete inspector and every menu. It was built as the opposite of the deleted minimal board.
- **Current state:** the title and the content disagree.
- **Classification:** NEEDS VERIFICATION
- **Open question:** is E-Focus E's minimal Mac/web presentation, its full one, or both?

### ED-006 · Minimal phone board added (C's minimal phone layout, A's look)
- **Date:** 2026-11-04 (thread 5f96cf43).
- **Request:** "Using C, Make Phone Minimal Look for concept A", built from the current A mockups. The owner later moved it next to A-Phones.
- **Change:** a new board, A-PhonesMinimal. It has six frames (iPhone Now, Rest of today, Add, Empty day; Android Now, Add), an end-of-day inset, and a "Minimal hides, never removes" grid.
- **Current state:** present as E-PhonesMinimal.
- **Classification:** ACCEPTED FOR CONCEPT E (as a board). ED-055 lists the open choices inside it.

### ED-007 · Concept E created from the latest A; A left untouched
- **Date:** 2026-11-04 (thread 24c4bdf0, then the owner's consolidated instruction).
- **Request:** the owner first floated "Concept D", then renamed it "Concept E — Refined Focus, based on my current modified Concept A". They told Claude to keep all A boards untouched and not to restore A to Round 1.
- **Change:** the E row holds exact copies of the five A boards (see the baseline table above).
- **Current state:** done. The E files still carry the "A · …" H1 headers, because they are exact copies.
- **Classification:** ACCEPTED FOR CONCEPT E
- **Superseded:** Claude's earlier suggestion to restore A to Round 1. The owner declined it.

### ED-008 · Every A change recorded as rules
- **Date:** 2026-11-04 (thread 24c4bdf0).
- **Request:** the owner asked that every change be "known already" so that "every new screen follows the rule".
- **Change:** this log plus `E_DESIGN_RULES.md`. Every future change gets an entry.
- **Classification:** ACCEPTED FOR CONCEPT E

---

## 2. Identity: task dot and brand mark

### ED-009 · C's task-dot states on A
- **Date:** 2026-11-03 (thread 453cd3c5).
- **Request:** "use the Task dot of C … across", then "it should cover the A. Refined Timeline".
- **Change:** the glossy dot with a halo was replaced by three states:
  - done: a solid circle in the task colour;
  - now: a progress ring that fills as time passes;
  - ahead: an outlined ring in the task colour.

  The task icon stays inside the dot. B and C were not changed.
- **Current state:** the legend on E-Phones, E-PhonesMinimal and E-Workspace shows done / now (ring = time elapsed) / ahead. Ahead dots are rings, for example the violet Gym ring. Now dots use the indigo conic progress ring at 85 %.
- **Classification:** ACCEPTED FOR CONCEPT E

### ED-010 · Solid chips for every task (C's Android list-row icon)
- **Date:** 2026-11-03 (thread 5813cc0b).
- **Request:** "can the icons on A … look like this?" Claude made every task a solid chip with a white icon, so ahead tasks were no longer outlined. The owner then said "undo last change".
- **Current state:** undone. ED-009 is in force.
- **Classification:** REJECTED
- **Do not reintroduce** solid chips for ahead tasks, or chip-style task icons that drop the outlined "ahead" state.

### ED-011 · Brand mark = the Today icon
- **Date:** 2026-11-03 (thread cf71cc55).
- **Request:** "change this to the icon in Today … the Circle with a filled Circle inside".
- **Change:** the glossy dot next to "Dottoday" in the web sidebar became an outlined circle with a filled centre. It was cobalt at the time and is now teal #11615C.
- **Current state:** present in the web sidebars of E-Focus and E-Workspace. The board where it was first applied (A-Wide) is deleted. Mac menu bars show the word "Dottoday" with no mark.
- **Classification:** ACCEPTED FOR CONCEPT E

---

## 3. Type, colour and surfaces

### ED-012 · C's typography, accent, colour, background and feel applied in place
- **Date:** 2026-11-03 (thread 69ac6f26).
- **Request:** "i want the typography, Ascent, Color, Background and the display feel of C. be implemented to A". The owner replied "in Place".
- **Change:**
  - Manrope for content, with tabular numerals. Platform chrome keeps the system fonts.
  - Teal #11615C replaced cobalt.
  - Ink #241F2B and #6A6273.
  - C's task palette.
  - Cream background #FBF7F1.
  - Rounder radii.
- **Current state:** no Inter and no cobalt on any E board. Manrope and #11615C are used throughout.
- **Classification:** ACCEPTED FOR CONCEPT E
- The apricot part of the original proposal was later rejected (ED-016).

### ED-013 · C's surface treatment
- **Date:** 2026-11-03 (thread 69ac6f26).
- **Request:** the owner said C's colours "blended" while A showed white boxes and a shape they didn't want, then replied "go".
- **Change:**
  - White panes became warm surfaces: #FFFDF9 raised, #F6F1EA and #F1EBE3 tinted.
  - The floating inset Mac sidebar became a flat, full-height, edge-to-edge tinted sidebar. The web sidebar is solid #F3ECE2.
  - Tone shifts replaced hairlines between large panes.
  - Menus moved onto warm surfaces.
- **Current state:** present. The web sidebars on E-Focus and E-Workspace are #F3ECE2.
- **Classification:** ACCEPTED FOR CONCEPT E

### ED-014 · Floating inset sidebar shape
- **Date:** 2026-11-03 (thread 69ac6f26).
- **Request:** the owner named it as "a shape i don't want to show". ED-013 removed it.
- **Classification:** REJECTED
- **Do not reintroduce** a sidebar drawn as a rounded card inset from the window edge.

### ED-015 · C's full colour scheme (lavender, warm-violet greys, tonal accents)
- **Date:** 2026-11-03 (thread 69ac6f26).
- **Request:** "if yes then add the Faint Lavender to complete". After Claude listed the differences, the owner replied "go".
- **Change:**
  - Faint lavender menus (#F8F5FA; #F7EFF4 on the Android menu).
  - Lavender-grey dividers and outlines, and lavender avatars.
  - Warm-violet greys (#7A7280, #9C95A3) replacing the cool greys.
  - Tonal teal secondary buttons (#CFE8E4 with #0A4440 text).
  - Pale indigo (#F1F0FB) inside the big now-dots.
- **Current state:** present. No cool greys (#6B7385, #4C5466, #ABAFB9) remain. #F8F5FA appears on the E-Focus and E-Workspace menus.
- **Classification:** ACCEPTED FOR CONCEPT E
- The apricot and Wind Down parts of this pass were later reversed (ED-016, ED-018).

### ED-016 · Apricot accent (#F2A65A, apricot tags #FBE5CC / #5E330A)
- **Date:** added 2026-11-03 in the full colour pass. Removed the same day (thread ccd0bc55).
- **Request:** the owner quoted "C's apricot stays on the tags, 'Clear your head' and the focus rings" and asked "restore them to the colors back across A".
- **Current state:** no apricot on any E board.
- **Classification:** REJECTED
- **Do not reintroduce** apricot anywhere in E: not on tags, Wake Up, Clear your head, focus rings or now-marker caps.

### ED-017 · Original Wake Up and Wind Down cap colours
- **Date:** 2026-11-03 (threads 9c2e39da and ccd0bc55, several comments).
- **Request:** "restore the Wind down color", "it should match across A", "okay restore the wake up and the widn down color across A", "across A".
- **Change:**
  - Wake Up: amber circle #FBEBC8 with sun #9A5A0E.
  - Wind Down: pale indigo circle #E6E3F7 with moon #4B3FB0.

  These are the Round 1 originals, applied on every board, including day headers and the slim day-strip marks.
- **Current state:** present. #E4E3F7 still appears on the boards, but only as the progress-ring track, not on the caps.
- **Classification:** ACCEPTED FOR CONCEPT E

### ED-018 · Wind Down in C's lavender (#E7DFEF / #3F2A85); Wake Up in apricot
- **Date:** 2026-11-03.
- **Request:** both came from the full colour pass. The owner reversed both (ED-017).
- **Current state:** #3F2A85 is absent everywhere. #E7DFEF remains only on lavender avatars.
- **Classification:** REJECTED
- **Do not reintroduce** different Wake Up and Wind Down colours on different boards.

### ED-019 · Status tags, Clear your head, focus rings and now-bead returned to their colours from before the full colour pass
- **Date:** 2026-11-03 (thread ccd0bc55, the same request as ED-016).
- **Change:**
  - Tags: "Built today" green #E3F1E7 / #1D6436, "Design-only" pale teal, "Hypothesis · not approved" amber, "Platform note" warm grey.
  - Clear your head: a cream outlined button.
  - Focus rings: teal.
  - Now-bead: white ring, with no apricot cap.
- **Current state:** present.
- **Classification:** ACCEPTED FOR CONCEPT E

---

## 4. Bold, lean finish and scale

### ED-020 · C's orb in the Focus board's Now panels
- **Date:** 2026-11-03 (thread 323fc074).
- **Request:** "Replace the A Refined Timeline . Focus layout with this ring type and all that needs to be in it to as C".
- **Change:** C's orb replaced the large now-dot on Mac and web. It has a cream disc, an #E4E3F7 track, an indigo #5B5FD6 arc at 85 %, the task icon, a big "18" and "min left". It is 203 px on Mac and 209 px on web. Done / Focus / Need more time? sit underneath in C's button style.
- **Current state:** present on E-Focus. aria-label: "85 percent elapsed, 18 minutes left".
- **Classification:** ACCEPTED FOR CONCEPT E

### ED-021 · C's compact ring in the Now mini window
- **Date:** 2026-11-03 (thread b93904e6).
- **Request:** "Replace the Ring in A Refined timeline FOcus with this from C".
- **Change:** the mini window now uses a thin indigo ring with a bold "18" inside, in place of the dot with an icon.
- **Current state:** present on E-Focus (a 54 px SVG ring).
- **Classification:** ACCEPTED FOR CONCEPT E

### ED-022 · Bold, lean finish across A, including the mini windows
- **Date:** 2026-11-03 (thread 94195952).
- **Request:** "C generally Looks Bolder … lean … can A have that feel and still maintain its Identity?" and "so this applies to the window i asked of too right?". The owner replied "go".
- **Change:**
  - Titles, task names and buttons at 700. Headlines and big numbers at 800.
  - Tabular numerals on every time and count.
  - Every glow removed.
  - Shadows kept only on floating surfaces.
  - Duplicate decorative icons trimmed.
  - Mini windows: 12 px corners, a 700 title, a 28 px Done pill, and C's spacing.
- **Current state:** present. No glows or drop-shadow filters remain. `font-variant-numeric: tabular-nums` is set on every E board.
- **Classification:** ACCEPTED FOR CONCEPT E

### ED-023 · Halos, glows and glossy dots
- **Date:** 2026-11-03.
- **Change:** removed by ED-009 (glossy dot with halo) and ED-022 (all glows).
- **Classification:** REJECTED
- **Do not reintroduce** halos, glows or gradient "glossy" dots.

### ED-024 · Bigger Day-thread dots on the Focus board (first step)
- **Date:** 2026-11-03 (thread 9acf09f2).
- **Request:** "can it be a little bigger".
- **Change:** +4 px on the Focus board only.
- **Current state:** superseded by ED-025. The Focus board now uses the large-scale values.
- **Classification:** ACCEPTED FOR CONCEPT E (superseded by ED-025)

### ED-025 · Large, comfortable scale across A
- **Date:** 2026-11-03 (thread 9acf09f2).
- **Request:** "can you increase them more across A? … is their a way to just have a Large feel?" The owner replied "go".
- **Change:**
  - Phones: dots 32–34 px, now-dot 40 px, thread 4 px, rows about 8 px taller, task names 17 px.
  - Mac and web: dots 32–34 px, now-dot 38 px, task names 15 px.
  - Workspace: hours about 17 % taller.
  - Native controls stay at their native size.
- **Current state:** present. E-Phones has 32/34/40 px dots. E-Focus has 32/34/38 px dots.
- **Classification:** ACCEPTED FOR CONCEPT E
- **Open question:** "keep large / C confidence / both" is still unanswered. See ED-026 and the pending answers below.

### ED-026 · "C confidence" scale (modest rows, one big hero, more space between groups)
- **Date:** 2026-11-03 (thread 9acf09f2).
- **Origin:** the owner asked "is it this same spacing that C has? because it looks more Confident". Claude explained that C's confidence comes from scale contrast, not bigger rows, and offered three options: keep large / C confidence / both.
- **Classification:** PROPOSED / AWAITING APPROVAL

### ED-027 · Add-field dot matches normal dots, with balanced spacing
- **Date:** 2026-11-03 (thread b2a13d64).
- **Request:** "can this be same size with every other normal Dot with symbol", then "also maintain a good scaling".
- **Change:** in the iPhone Add sheet, the Gym dot is 34 px with a 4 px violet ring and a 19 px icon. The field stays 58 px tall, with 12 px insets around the dot and a 9 px right inset for the 40 px Add button.
- **Current state:** present on E-Phones (iPhone · Add a task).
- **Classification:** ACCEPTED FOR CONCEPT E

---

## 5. iPhone and Android platform chrome

### ED-028 · True iOS controls on the iPhone frames
- **Date:** 2026-11-03 (thread 69ac6f26).
- **Request:** "make IOS controls that needs to be true IOS controls, IOS controls in A".
- **Change:**
  - iOS switch, 51×31.
  - iOS segmented control.
  - iOS sheet proportions.
  - Glass Close button.
  - iOS 26 tab bar.
  - iOS keyboard.
  - iOS menu proportions for the Day pull-down: 250 px wide, 44 px rows.

  Each iPhone frame is tagged "True iOS controls · native Cupertino or platform view needed".
- **Current state:** present on E-Phones.
- **Classification:** ACCEPTED FOR CONCEPT E
- ED-029 to ED-031 record the two reversals inside this pass.

### ED-029 · iOS system colours on the swipe actions
- **Date:** 2026-11-03 (thread 9c2e39da).
- **Request:** "this should be restored back to it's previous color".
- **Current state:** the swipe inset uses teal Done, warm-grey Move and Delete #C8322F. No iOS system green, indigo or red.
- **Classification:** REJECTED
- **Do not reintroduce** iOS system colours on swipe actions.

### ED-030 · iOS blue "done" return key
- **Date:** 2026-11-03 (thread f55c7d26).
- **Request:** "this should have Add and not done, with the correct color".
- **Classification:** REJECTED
- **Do not reintroduce** "done" or iOS blue on the Add keyboard.

### ED-031 · Return key reads "Add" in app teal
- **Date:** 2026-11-03 (thread f55c7d26).
- **Change:** the key reads "Add" on teal #11615C and keeps the iOS key shape. The platform note says this needs a custom key or an input accessory bar.
- **Current state:** present on the iPhone Add frames of E-Phones and E-PhonesMinimal.
- **Classification:** ACCEPTED FOR CONCEPT E
- **Later (2026-11-06):** the drawn teal key is replaced by the stock keyboard's neutral return key (G3-7 C, ED-135); the teal Add stays in the field row / nav bar.

### ED-032 · "the keyboard": whole keyboard back to its look from before the iOS-controls pass?
- **Date:** 2026-11-03 (thread f55c7d26).
- **Problem:** the owner sent "the keyboard" right after the Add-key fix. Claude replied that only the return key had changed, and offered to restore the whole keyboard. There was no answer.
- **Current state:** the keyboard is iOS-styled with the teal Add key.
- **Classification:** NEEDS VERIFICATION
- **Later (2026-11-06):** settled by G3-7 C (ED-135): the stock iOS keyboard.

### ED-033 · iPhone tab bar: see-through, then Liquid Glass
- **Date:** 2026-11-03 (thread b89ef23e).
- **Request:** "This menu can be a little bit transparent … like the threads down", then "Glass like".
- **Change:**
  - The body is a gradient from 62 % to 44 % opacity.
  - `blur(16px) saturate(190%)`.
  - A bright top edge, a soft bottom edge and a white rim.
  - The solid fade under the bar was reduced to 45 %, so the thread shows under the bar.
- **Current state:** present on E-Phones and E-PhonesMinimal.
- **Classification:** ACCEPTED FOR CONCEPT E

### ED-034 · Liquid Glass across the iPhone chrome
- **Date:** 2026-11-04 (thread b89ef23e).
- **Request:** "make it iOS's Liquid Glass across the iPhones and if the menu bar of Iphone is same for tab apply it also".
- **Change:**
  - The selected tab becomes a glass lens.
  - Sync and the avatar share one glass capsule.
  - On the empty day, "‹ Today" is its own glass capsule.
  - The Day ▾ chip is glass.
  - The Day pull-down is a 26 px-radius glass menu.
  - The sheet's Close (×) button is glass.
- **Current state:** present. E-Phones has 8 elements with `blur(16px) saturate(190%)` and a `blur(30px)` glass menu.
- **Classification:** ACCEPTED FOR CONCEPT E

### ED-035 · Android: translucent tonal M3 bars (no glass)
- **Date:** 2026-11-04 (thread b89ef23e, the same request: "do same for Android using the appropriate android features").
- **Change:**
  - The NavigationBar and Day button use a translucent tonal surface, rgba(242,235,226,0.86) with `blur(24px)`, on Android 12+ through RenderEffect. Older phones get the solid tonal colour.
  - No glass rims or highlights.
  - The timeline runs edge to edge under the bar.
  - The FAB and the M3 Day menu stay solid.
- **Current state:** present on E-Phones and E-PhonesMinimal.
- **Classification:** ACCEPTED FOR CONCEPT E

### ED-036 · Floating Liquid Glass sheets on iPhone (Add and Task actions)
- **Date:** added 2026-11-04 (thread b89ef23e, after "yes do that"). The owner undid it the same day: "undo this last edit done from here".
- **Change that was undone:** sheets inset 8 px, all four corners rounded to 38 px, glass at 70–80 %.
- **Current state:** both sheets are solid cream, edge to edge, with only the top corners rounded. The caption notes about floating glass were removed.
- **Classification:** REJECTED
- **Do not reintroduce** floating or glass sheets on iPhone. Sheets stay solid.

### ED-037 · Inbox tray on phones ("Inbox · 3" with a grab line above)
- **Date:** removed 2026-11-04 (thread 0bda86e4).
- **Request:** "Remove that inbox.3 and line above across the phone platforms". The owner replied "go and yes".
- **Current state:** gone from iPhone Today, the iPhone empty day, Android Today, and the dimmed backgrounds. The bottom row is Day ▾ on the left and + on the right. A-Map's Inbox row now says "Inbox tab (badge 3)".
- **Classification:** REJECTED
- **Do not reintroduce** a pull-up Inbox tray or its grab handle on phones.

### ED-038 · Inbox is a tab with a count badge on phones
- **Date:** 2026-11-04 (thread 0bda86e4).
- **Change:** the Inbox tab with its "3" badge is the only Inbox entry on phones. The drag-from-Inbox-onto-Today shortcut remains on the workspace (Mac/web) only.
- **Current state:** present on E-Phones and E-PhonesMinimal.
- **Classification:** ACCEPTED FOR CONCEPT E

### ED-039 · "Plan from Inbox · 3" button on the iPhone empty day
- **Date:** this button comes from Round 1. It was not part of the tray.
- **Problem:** the iPhone Empty day frame of E-Phones still has a "Plan from Inbox · 3" empty-state button. The owner removed "Inbox · 3" on the phones. It is unclear whether they meant this button too.
- **Classification:** NEEDS VERIFICATION

### ED-040 · iPhone date title moved into the nav row
- **Date:** 2026-11-04 (thread 0bda86e4).
- **Request:** "make Tue 3 Nov … move up to be in the same line with the profile on the right". The "yes" in "go and yes" also applied it to the empty day.
- **Change:**
  - "Tue 3 Nov ▾" is a 28 px bold left-aligned button in the top row, beside the Sync and avatar glass capsule.
  - "3 of 9 done · 7 h 40 planned" sits under it.
  - The content moved up 36 px.
  - Empty day: "‹ Today · Wed 4 Nov ▾ · capsule".
  - Android already had its date in the top app bar, so it is unchanged.
- **Current state:** present on E-Phones, including the dimmed backgrounds behind the sheets.
- **Classification:** ACCEPTED FOR CONCEPT E

### ED-041 · iOS switch on-state in teal, not system green
- **Date:** 2026-11-03 (thread 69ac6f26). This was Claude's choice, and Claude offered system green. There was no answer.
- **Classification:** PROPOSED / AWAITING APPROVAL
- **Cross-reference (added 2026-11-06, ED-117; the entry above is unchanged history):** answered by ED-112 (G3-4 option A, teal), approved 2026-11-05.

### ED-042 · Unselected tab-label grey
- **Problem:** the colour differs between boards:
  - E-Phones uses iOS system grey #8E8E93. Claude measured it at about 3.1:1 contrast, below 4.5:1.
  - E-PhonesMinimal uses a darker #6E6E73, which Claude chose for readability on glass.
- **Current state:** the two phone boards disagree.
- **Classification:** NEEDS VERIFICATION

---

## 6. Proposals the owner has not confirmed

These are on the E boards with "Hypothesis · not approved" or "Design-only" tags, or Claude proposed them in replies. Creating Concept E does not approve them.

### ED-043 · Settings leaves the tab bar
- **Proposal:** Settings moves behind the avatar on iPhone and Android, into the sidebar footer and `/settings` on web, and into ⌘, (its own window) on Mac.
- **Boards:** E-Phones, E-PhonesMinimal, E-Focus, E-Workspace, E-Map.
- **Classification:** PROPOSED / AWAITING APPROVAL

### ED-044 · One task surface
- **Proposal:** the task sheet, `/task/:id` and the editor merge into one surface.
  - iPhone: pull up to the large detent to get the full editor.
  - Android: one M3 bottom sheet.
  - Mac/web: the inspector.
- **Classification:** PROPOSED / AWAITING APPROVAL

### ED-045 · Brain dump and Routine as Add modes
- **Proposal:** both are one tap from Add, also through a hold on + or the M3 FAB menu. Both go through the proposal sheet.
- **Classification:** PROPOSED / AWAITING APPROVAL

### ED-046 · The Day ▾ menu replaces the ⋯ catch-all
- **Proposal:** one grouped menu with Replan, Plan, Reflect, View and Share sections. It is an iOS pull-down, an M3 menu on Android, and the Day menu in the Mac menu bar.
- **Also proposed:** Day menu items work on any viewed day, and Running late stays today-only.
- **Classification:** PROPOSED / AWAITING APPROVAL

### ED-047 · Calendar becomes a destination; Title ▾ opens a month sheet
- **Proposal:** Calendar is a tab or sidebar row. Tapping the date title opens a month sheet (go to a date in 2 taps). Android uses the M3 date picker.
- **Classification:** PROPOSED / AWAITING APPROVAL

### ED-048 · Settings regrouped into six jobs, duplicates merged
- **Source:** E-Map-v1.0 hypotheses and the D1 decision board.
- **Classification:** PROPOSED / AWAITING APPROVAL

### ED-049 · Move opens a day and time picker
- **Proposal:** this fixes the dead tile. It uses the M3 dial picker on Android and is the screen-reader "Move to…".
- **Classification:** PROPOSED / AWAITING APPROVAL

### ED-050 · Workspace structure
- **Proposal:**
  - Plan and Review become destinations, with the Inbox inside Plan.
  - Cards are time-proportional, with the thread behind them.
  - ⌘K palette.
  - Drag from the Inbox onto the grid.
  - A docked inspector.
  - Overlaps sit side by side with the knot.
- **Board:** E-Workspace.
- **Classification:** PROPOSED / AWAITING APPROVAL

### ED-051 · Focus structure
- **Proposal:**
  - Now is the entry place (the first sidebar row) with a `/now` route.
  - A three-pane Now + Day + inspector layout.
  - A Now mini window (⌥⌘0), a new window type that needs a feasibility check.
  - Clear your head on ⇧⌘N.
  - A menu-bar status item.
- **Board:** E-Focus.
- **Classification:** PROPOSED / AWAITING APPROVAL

### ED-052 · Web orb drawn like the Mac orb (icon and shadow)
- **Date:** 2026-11-03 (thread 323fc074).
- **Proposal:** C's own web orb is plainer. Claude offered to simplify it. There was no answer.
- **Classification:** PROPOSED / AWAITING APPROVAL

### ED-053 · Hover lift shadow kept on Lunch (web workspace)
- **Date:** 2026-11-03 (thread 94195952).
- **Proposal:** this is an exception to the lean finish, because the caption describes it. Claude offered to flatten it. There was no answer.
- **Classification:** PROPOSED / AWAITING APPROVAL

### ED-054 · Sample data and filler on the workspace and focus boards
- **Examples:** the other days' tasks, subtasks, "Weekdays" repeat, alert chips, free-time labels, and ⌘M. Claude introduced these as filler. They are not decisions.
- **Classification:** PROPOSED / AWAITING APPROVAL

### ED-055 · Choices inside the minimal phone board
- **Date:** 2026-11-04 (thread 5f96cf43).
- **Proposals:**
  - Tabs read "Now · Today · Inbox". C's "Day" became "Today" to avoid a clash with Day ▾.
  - The glass tab bar stays in minimal. doc 14 §3 has no tab bar in minimal.
  - Settings sits behind the avatar. Show everything and Low-energy day sit in Day ▾.
  - The summary line shows time, not counts.
  - Done tasks fold into one "Earlier · 3 done" row. doc 14 §4 keeps them in place.
  - Tapping the big now-dot starts Focus.
  - An empty minimal day shows no Inbox suggestions.
  - The Inbox is a tab, not doc 14 §3's "Later" row.
- **Classification:** PROPOSED / AWAITING APPROVAL

---

## 7. Snapshot inconsistencies to resolve

### ED-056 · E-Map-v1.0 still describes the deleted A-Wide
- **Problem:** the frozen map still lists Mac/web as "Sidebar › Today, three-day spread", with "1280: sidebar, three-day spread, inspector". It scores Mac/web from A-Wide. Claude flagged this on 2026-11-04 (thread 24c4bdf0), and the owner has not answered.
- **Note:** the snapshot must stay frozen. The working E Map must describe E-Focus and E-Workspace instead.
- **Classification:** NEEDS VERIFICATION

### ED-057 · E-Workspace header refers to a board that no longer exists
- **Problem:** the header says it is "An alternative to A's thread-only wide board, which stays the candidate minimal look for wide windows". That board (A-Wide) was deleted (ED-003).
- **Classification:** NEEDS VERIFICATION

### ED-058 · E-Focus intro still says "one big dot says what to do now"
- **Problem:** the intro sentence was written before ED-020 replaced the big dot with C's orb (a large "18" in the ring).
- **Classification:** NEEDS VERIFICATION

### ED-059 · E-PhonesMinimal says "C's orb in A's ring"
- **Problem:** the hero is drawn with C's orb geometry: a 232 viewBox, an #E4E3F7 track and an indigo arc. The text still calls it "A's now-dot".
- **Note:** it is the same orb as E-Focus, so the two boards agree visually. Only the naming needs settling.
- **Classification:** ACCEPTED FOR CONCEPT E (visual). The rules should name it "the orb", with no change to the board.

---

## 8. Requests that are not part of E

### ED-060 · C boards made at the owner's request
- **Boards:** "C · Focus-First · minimal look, Mac and web" (C-Minimal, thread 55149e04, 2026-11-03) and "C · Focus-First · minimal look, phones" (C-PhonesMinimal, thread 55c6e2ea, 2026-11-04).
- These belong to Concept C. They are references only. A-PhonesMinimal (ED-006) was built from C-PhonesMinimal.
- **Classification:** ACCEPTED FOR CONCEPT E (as a reference source only; not E boards)

### ED-061 · The task dot was applied to A only, not to B or C
- **Date:** 2026-11-03 (thread 453cd3c5).
- **Change:** the owner scoped ED-009 to "A. Refined Timeline". B and C keep their own markers.
- **Classification:** ACCEPTED FOR CONCEPT E

---

## 9. Changes after v1.0 (v1.1 work in progress)

### ED-062 · E-Focus removed from the canvas
- **Date:** 2026-11-04. Found while the canvas was re-read before ED-063 was published.
- **Change:** the owner removed E-Focus (C's full Mac/web layout in E's look) from the E row. Its v1.0 copy is still in `references/concept-e/v1.0/E-Focus.dc.html`.
- **Classification:** NEEDS VERIFICATION. It is not yet clear whether the owner rejected the Focus layout for E, or replaced it with E-Minimal.

### ED-063 · E-Minimal: C's Mac/web minimal layout in E's look
- **Date:** 2026-11-04 (thread 01a5b805).
- **Request:** "Using C, Make Web / Mac Minimal Look for concept E", built on the current E mockups.
- **Change:** a new board, `E-Minimal`, built from C-Minimal's layout.
  - **Mac:** sidebar 200, Now 790, and a right column 290. The right column shows the Day thread by default. A task opens in that column, and ✕ or Esc closes it back to the Day (thread 41a00e38).
  - **Web:** Now and the Day thread side by side.
  - **Insets and band:** a menu-bar inset, the Now mini window, the Everything else finder, and a "Minimal hides, never removes" band.
- **Translated into E's vocabulary:**
  - the ribbon becomes a flat horizon;
  - the apricot notch becomes the teal now-bead;
  - the orb becomes E's large now-dot.
  - Nothing rejected comes back: no apricot, no halos, no lavender caps.
- **Board inconsistencies:** wherever E boards disagreed, E-Focus was followed:
  - no sidebar blur;
  - Delete ⌫;
  - ⌘1–4 = Now / Day / Calendar / Inbox;
  - ⌘K opens the Everything else finder;
  - "Gentle Day";
  - +15 / +30;
  - the `/now` route.
- **Copy:** "Running late" became "Need More Time…" to follow the no-"late" rule.
- **Classification:** PROPOSED / AWAITING APPROVAL. This answers decision 3 on the E Map (wide minimal), but the owner still has to accept it.

### ED-064 · E-Minimal replaces E-Focus as E's Mac/web minimal layout (v1.1)
- **Date:** 2026-11-04. The owner's instruction for v1.1 said: "I have completed the redesign and replacement of Concept E's Mac and Web Minimal Layout."
- **Change:** E-Minimal is E's working wide minimal layout in v1.1. E-Focus is not recreated on the canvas. Its v1.0 copy stays in `references/concept-e/v1.0/`. Canvas version `1793767935-3ecd`.
- **What this settles:**
  - ED-062 resolves: E-Focus was replaced as the wide minimal layout, not rejected as an idea.
  - The visual replacement is the owner's design decision.
- **What it does not settle:**
  - Focus stays as a product feature: the task Focus action, focus sessions and the Now mini window.
  - Whether E has a full wide "Focus" presentation (Now + Day + inspector with the full sidebar) is still an owner decision; see the decision register.
  - The new behaviours on E-Minimal are still hypotheses. They include: the Day in the right column, the task screen opening in that column, Now as the entry, ⌘1–4, ⌘K and `/now`.
- **Classification:** ACCEPTED FOR CONCEPT E as a design direction for wide minimal. The individual behaviours stay PROPOSED / AWAITING APPROVAL.
- **Update to ED-062:** now RESOLVED by ED-064. ED-062's text is kept unchanged above.

## 10. Group 1 answers (2026-11-04)

Source for ED-065 to ED-070: the owner's Group 1 reply, 2026-11-04 (session message, after Group 1 was presented from `E_DECISION_REGISTER.md`). Each entry approves structure only. In the owner's words: "Do not treat this structural approval as permission to redesign existing boards without review."

### ED-065 · Two presentation modes: Full and Minimal (G1-2)
- **Owner answer:** "G1-2 — APPROVED. Two main presentation modes: Full and Minimal. Focus remains a feature available from either mode. Workspace provides advanced planning within Full."
- **Settles:**
  - E has two presentation modes, Full and Minimal, on every platform.
  - Focus is a feature reachable from both modes, not a third layout. E keeps no wide Focus *presentation*; the v1.0 `E-Focus` board stays archived as history.
  - Workspace (Inbox column, time grid, inspector) is advanced planning *inside* Full, not a separate mode.
- **Does not settle:** what Full opens on and how it looks on Mac and web (G1-1, still open); any redesign of an existing board.
- **Classification:** ACCEPTED (structure).

### ED-066 · Now leads in Minimal; Full shows the current task on the Today timeline (G1-3)
- **Owner answer:** "G1-3 — APPROVED. Now leads in Minimal. Full shows the current task on the Today timeline rather than requiring a separate Now destination. Keep Focus accessible, and mark the proposed Mac mini window and status item for feasibility verification."
- **Settles:**
  - Minimal opens on Now (phones, Mac, web).
  - Full has no Now destination. The current task is shown on the Today timeline (the now card / now-dot on the thread).
  - Focus stays reachable from both modes.
- **Needs verification (not approved as built):** the Mac Now mini window and the Mac menu-bar status item. Both are tagged FEASIBILITY CHECK.
- **Classification:** ACCEPTED (structure); mini window and status item NEEDS VERIFICATION.

### ED-067 · Switching between Full and Minimal (G1-4)
- **Owner answer:** "G1-4 — APPROVED. The Full/Minimal switch should remain accessible through the Day menu and the first Settings row, with platform-appropriate native access such as the Mac View menu. Preserve the current task, selected day and relevant navigation state when switching."
- **Settles:**
  - The switch is always in the Day menu and as the first Settings row, on every platform.
  - Native extras are allowed where the platform expects them (for example the Mac View menu).
  - Switching keeps the open task, the selected day and the relevant navigation state.
  - It stays one per-account setting, as built today (no business-logic change).
- **Does not settle:** keyboard shortcuts for the switch, and whether ⌘K offers it (G2-10).
- **Classification:** ACCEPTED.

### ED-068 · Minimal navigation keeps the owner's designed patterns (G1-5, Minimal part)
- **Owner answer:** "G1-5 — APPROVE THE EXISTING MINIMAL NAVIGATION PATTERNS, NOT OPTION A." The owner designed these deliberately as platform and viewport adaptations, not missing designs.
- **Settles (Concept E, redesign branch only):**
  - **Minimal iPhone and Android phones:** bottom navigation Now · Today · Inbox (as on `E-PhonesMinimal`).
  - **Minimal Mac and web:** sidebar Now · Inbox · Calendar · Search, with the Day timeline already visible in its own column (as on `E-Minimal`).
  - The two sets differ on purpose. They are **not** made identical:
    - the wide sidebar is not replaced with Now · Today · Inbox;
    - Calendar and Search are not moved out of the wide sidebar for uniformity;
    - the phone tab bar is not removed to restore the older Minimal Mode specification.
- **Still required across the two:** shared feature meanings, an accessible path to every feature, consistent naming, and native behaviour per platform.
- **Supersedes, for the redesign branch only:** `docs/14-minimal-mode.md` §3 and ADR-0016 where they assume minimal has no tab bar or sidebar, and where Inbox is reached only as a "Later" row. Neither document is edited. The old specification stays as written and is listed as superseded in `E_DESIGN_RULES.md` §9.1.
- **Rejected by the owner:** register option G1-5 A (one identical set per mode at every width).
- **Not settled here:** keyboard shortcuts and web routes (they move to G2-10 and G2-11).
- **Classification:** ACCEPTED (owner's explicit Concept E design decision).

### ED-069 · Full navigation: phones kept, wide sidebar waits for G1-1 (G1-5, Full part)
- **Owner answer:** "For G1-5's Full navigation, keep the current phone design and defer the final wide sidebar arrangement until G1-1 is resolved."
- **Settles:** Full on phones keeps the current `E-Phones` tab bar.
- **Open:** the Full Mac/web sidebar rows. They depend on G1-1.
- **Classification:** PARTLY RESOLVED / DEPENDENT ON G1-1.

### ED-070 · G1-1 shown as two option boards
- **Owner request:** "Show me two Full Mac/Web alternatives: A. Preserve E-Workspace as the default Full experience. B. Introduce a timeline-led Full Today experience, with E-Workspace's planning views available within Full. Use Concept E's existing visual identity. Do not overwrite E-Workspace or E-Minimal."
- **Change:** two new comparison boards on the canvas, `E-FullA` and `E-FullB`. Both show the same moments (Mac at launch on Tue 3 Nov at 10:42, and web planning in 3 days) in E's existing look. `E-Workspace` and `E-Minimal` are not touched.
- **Kept open in both:** the wide sidebar rows (ED-069), shortcuts (G2-10) and routes (G2-11). The boards show no shortcuts for new items and no URL paths.
- **Classification:** PROPOSED / AWAITING OWNER CHOICE (G1-1).

### ED-071 · G1-1 boards rebuilt for fidelity; owner leaning option A
- **Date:** 2026-11-04. **Owner feedback:** "I am leaning toward G1-1 Option A — Workspace as the default Full Mac and Web experience, but I am NOT giving final approval yet." The first comparison boards lost Concept E detail: overlap knots, Inbox and Routines icons, and task-dot sizes.
- **What was wrong in the first pass (kept in `references/concept-e/g1-1-options/pass1/`):** the frames were redrawn from descriptions.
  - Dots were 20–30 px, with icons at 55 % of the dot. E-Workspace uses 32 px dots with 17–18 px icons, a 38 px now ring with a 21 px icon, and 28 px dots with 15 px icons on short blocks.
  - No overlap knot on the grid.
  - Inbox items and Routines had no E-Workspace icons or rings; sidebar Inbox and Calendar had invented icons.
  - Block radius was 14 instead of 18.
- **Change:**
  - **Option A** now embeds E-Workspace's own Mac frame (Plan · Week) and web frame (Plan · Day), byte-identical to the live board.
  - **Option B** is built from E-Workspace's parts:
    - Today on Mac is its Day thread canvas, widened to the column, with its blocks, knot, now-bead and free-time labels.
    - Its toolbar has the range tabs removed and Replan relabelled as the Day menu.
    - Calendar on web is its Week workspace (Inbox and Routines column, grid, knot, drag, inspector) inside the browser, without the Mac-only right-click menu and without ⌘ hints or a URL path.
    - Sidebar rows use E-Workspace's row recipe and icons, with Inbox and Calendar icons from E-Minimal.
  - `E-Workspace` itself is unchanged.
- **Classification:** G1-1 stays OPEN — OWNER LEANING OPTION A, NOT YET APPROVED.

### ED-072 · Option A v2: a complete Full Mac/web candidate (proposals only)
- **Date:** 2026-11-04. **Owner request:** refine option A into "a complete, self-consistent candidate", keeping E-Workspace's look and fixing its outdated interactions, menus, copy, shortcuts and routing. "This is NOT my final G1-1 approval yet."
- **Change:** a new board, `E-FullA-v2`. `E-FullA` is kept as the previous revision.
  - **Frames:** the frames are E-Workspace's own markup with 15 listed edits:
    - the Day menu button replaces Replan;
    - Running Late → Need More Time…;
    - key labels follow the proposed scheme;
    - +5 is added to the Need more time? chips;
    - the web URL becomes `/today?task=…`;
    - the keyboard hint bar shows the proposed keys;
    - the web Day menu is drawn open.
  - **Panels:**
    - Mac Day menu (and its empty-day disabled states);
    - View and Go menus;
    - ⌘K palette;
    - first Settings row;
    - Full → E-Minimal → Full flow, using E-Minimal's Mac frame unchanged;
    - what the switch keeps;
    - proposed Mac shortcuts, web keys and web routes;
    - open items;
    - fidelity list.
- **Proposals in it (all AWAITING OWNER APPROVAL):**
  - **Replan:** becomes the Time section of the Day menu, with no toolbar button.
  - **Day menu contents:**
    - Time: Need More Time ▸ (+5 / +15 / +30 min, then Shift the Rest), Shift the Rest From Here…, Rebalance…;
    - Plan: Brain Dump… ⇧⌘N, Routines…, Pick Today's One Thing…;
    - Day: Duplicate Day…, Copy Day as Text ⇧⌘C, Review the Day, This Week;
    - Layout: Low-Energy Mode, Show Less ⇧⌘L.
  - **Increments:** one set of +5 / +15 / +30 everywhere, as built.
  - **Need More Time:** behaves like the built Running late.
  - **Mac keys (changes):**
    - ⌘1–4 = Day / 3 Days / Week / Month, so ⌘2 moves from Inbox (built) to 3 Days;
    - Inbox ⇧⌘I, Today ⌘T, ⌘← / ⌘→ days, ⌘[ / ⌘] Back / Forward;
    - Go to Date ⇧⌘T (not ⇧⌘G, which is Find Previous);
    - Search ⌘F, palette ⌘K;
    - Move To ⇧⌘M (not ⌘M, which is Minimize);
    - Focus ⇧⌘F (not ⌘F);
    - Show Less / Everything ⇧⌘L;
    - day-level replanning has no keys.
  - **Mac keys (unchanged):** Mark Done ⌘↩; Move to Trash ⌘⌫, plus ⌫ on a picked task as built; Settings ⌘,; Shortcuts ⌘/.
  - **Web keys:** single keys outside fields, never ⌘/Ctrl N, T, W, L or 1–4. The built app's ⌘1–4 collide with browser tab switching.
  - **Routes:**
    - built paths kept;
    - new dated `/3-days/<date>`, `/week/<date>`, `/month/<yyyy-mm>`;
    - `?task=<id>` opens the inspector;
    - `/task/<id>` redirects on wide;
    - `/now` only in Minimal;
    - Show Everything returns to the last Full location;
    - E-Workspace's `/plan/...` is not adopted.
- **Kept open:** G1-1, G2-10 (keys), G2-11 (routes), G2-5 (unsaved edits on switch), links to views hidden in Minimal, Back across a layout switch, the Low-energy name (G3), the Lists sketch, the mini window feasibility, and the 960 / dark / tablet / mobile-web layouts.
- **Classification:** PROPOSED / AWAITING OWNER REVIEW. Nothing here resolves G1-1 or Group 2.
- **Owner review (2026-11-04):** "Looks right", in reply to "Does Option A v2 work as the Full candidate?". This accepts `E-FullA-v2` as the Option A candidate board. It is not the G1-1 choice. The keys, routes, increments and Replan move stay proposals until approved one by one.

### ED-073 · G1-1 approved: Option A, Workspace is Full on Mac and web
- **Date:** 2026-11-04. **Owner answer:** "Approve Option A", replying to "Approve G1-1 as Option A (Workspace is Full on Mac and web)?".
- **Settles:**
  - Full on Mac and web is the Workspace layout: sidebar, Inbox and Routines column, time grid with Day / 3 days / Week / Month, docked inspector. The candidate is `E-FullA-v2`, built on `E-Workspace`.
  - The Full wide sidebar is E-Workspace's sidebar, as drawn on `E-FullA-v2` (ED-069 closes). Which extra rows stay (Lists sketch, Review, Routines) is G2-2.
  - E-Minimal's "Show everything" target is now defined: Option A's workspace.
  - Option B (`E-FullB`) is not chosen. The board stays on the canvas as history.
- **Does not settle:** everything on `E-FullA-v2` marked as a proposal (ED-072):
  - the Day menu contents and moving Replan into it (G2-9);
  - one +5 / +15 / +30 set, and Need More Time behaving like Running late;
  - the Mac and web key scheme (G2-10);
  - routes (G2-11);
  - what the switch keeps for unsaved edits (G2-5).
- **Classification:** ACCEPTED. Group 1 is complete.

### ED-074 · Group 2 reviewed one decision at a time; E-Workspace becomes reference only
- **Date:** 2026-11-04. **Owner instruction:** "I want to review Group 2 individually rather than accept all 13 recommendations at once." Plus: "retain the original E-Workspace board as a historical/reference design. E-FullA-v2 is the active Full design, so outdated E-Workspace interactions must not override it."
- **Settles:**
  - **Order:** Group 2 decisions are presented one at a time (G2-1, then G2-2, and so on). Each answer is logged before the next one is shown.
  - **Visual comparisons first:** G2-4, G2-5, G2-6, G2-8, G2-9 and G2-10 get focused visual comparisons or concrete interaction examples before approval is asked.
  - **Boards stay as they are until approved:** `E-FullA-v2` is the approved, active Full Mac/web design. `E-Minimal`, `E-Phones` and `E-PhonesMinimal` are preserved. No board changes until each change is explicitly approved.
  - **E-Workspace is reference only:** it stays on the canvas as a historical/reference design. Where it differs from `E-FullA-v2` (Running Late, Replan button, ⌘M, ⇧⌘G, `/plan/...`), `E-FullA-v2` wins.
  - **Order of work:** no commit, no Flutter work and no Group 3 until Group 2 is complete and reconciled.
- **Classification:** ACCEPTED (process).

### ED-075 · G2-1 approved: Calendar tab opens Month; one month grid, three ways in
- **Date:** 2026-11-04. **Owner answer:** "For G2-1, I choose Option A." The owner listed what to keep:
  - Full-mode phones keep Today · Inbox · Calendar · Search.
  - The Calendar tab opens a complete Month screen.
  - Tapping the date title opens the quick Month sheet shown in E-Phones.
  - The pull-down Month on Today stays.
  - One shared Month component and data model (the built `MonthGrid` / `month_data`).
  - Week stays available wherever the window width supports it.
  - Controls and interactions adapt for iPhone and Android.
- **Board work:** the missing iPhone and Android Calendar (Month) screens are drawn on a separate review board, `E-PhonesCalendar`. `E-Phones` is not changed until the owner approves the drawing.
- **Classification:** ACCEPTED (behaviour). The Calendar screen drawings are PROPOSED / AWAITING VISUAL REVIEW.

### ED-076 · The latest E boards are the preferred direction
- **Date:** 2026-11-04. **Owner instruction:** "I want the latest Concept E boards to serve as our preferred design direction. … do not unnecessarily ask me to reconsider ideas I have already explicitly accepted, or discard mockup features merely because they were originally labelled 'Hypothesis · not approved.' However, do not automatically mark every hypothesis as approved either."
- **Settles:**
  - What the boards draw is the starting recommendation for every remaining decision.
  - Approval is asked only where a real decision remains: a conflict with built functionality, accessibility, platform conventions or a newer owner decision; or a choice the boards leave open.
  - A traceability checklist (`E_TRACEABILITY.md`) maps every accepted decision and parity feature to its board, screen, implementation requirement and verification status, so nothing silently disappears.
- **Does not settle:** board items that are still tagged "Hypothesis · not approved" stay PROPOSED (BOARD-PREFERRED) until they are confirmed. They are no longer treated as doubtful.
- **Classification:** ACCEPTED (process).
### ED-077 · Group 2 re-baselined from the boards (ED-076)
- **Date:** 2026-11-04.
- **Adopted from the boards:** these decisions are drawn consistently on the current E boards and conflict with no built feature, accessibility rule, platform convention or newer owner decision. They become the spec. The owner can still object. None of them counts as explicit approval.
  - **G2-2:** the Full wide sidebar rows on `E-FullA-v2`: Today · Plan (Inbox, Routines, Brain dump) · Calendar views · Review · Search.
    - The "Lists" group stays as a labelled future sketch. It is excluded from the implementation spec and from parity. The owner's Q6 answer allows a project-style grouping "as a clearly labelled future possibility, which is not built".
    - The Routines row opens the built Routines page (today at `/settings/routines`) in the main area. This needs no new feature.
  - **G2-3:** the Settings entry: avatar on phones, Dottoday › Settings… ⌘, in its own window on Mac, sidebar foot on web. Every board agrees. Owner decision 9 allows moving entry points.
  - **G2-7:** Move opens a day-and-time picker on every platform. Only the Android dial is drawn; the iOS, Mac and web pickers are still to draw. Move is also the non-gesture route for drag (R-04, R-12).
  - **G2-13:** "Plan from Inbox · 3" stays on the Full empty day (`E-Phones` F4) and is hidden in Minimal (`E-PhonesMinimal` F4). It is the built empty-day action, not the Inbox tray the owner removed.
- **Still asked, one at a time, because a real decision remains:**

  | Decision | Why it still needs the owner |
  |---|---|
  | G2-4 Settings regroup and "Everything else" | The name means two different things (a Settings row on phones, a ⌘K finder on E-Minimal), and no E Settings screen is drawn |
  | G2-5 one task surface, autosave or Save | The built app uses Save; autosave changes product behaviour |
  | G2-6 minimal task screen | E-Minimal's set conflicts with the adopted doc 14 set (no Done, no Delete) |
  | G2-8 Brain dump and Routine as Add modes | The owner asked for a visual check |
  | G2-9 the Day menu | Four different menus; minimal's size against doc 14; Replan; increments |
  | G2-10 keyboard scheme | Changes the built ⌘2 and E-Minimal's keys; macOS clashes |
  | G2-11 web routes | A routing change the owner asked to keep open |
  | G2-12 duplicate merges | Product consolidation that no E board draws |

- **Classification:** ADOPTED FROM BOARD for G2-2, G2-3, G2-7 and G2-13. The owner can override any of them.
### ED-078 · Corrections found by the traceability audit
- **Date:** 2026-11-04. Source: `E_TRACEABILITY.md`; each item below was checked against code and boards.
- **Mac status item:** a menu-bar status item is already built (`app/macos/Runner/DayDotStatusItem.swift`). ED-066's feasibility check therefore covers only the new parts: the Now mini window and the new status-item menu items (Need More Time?, Show Now Window).
- **Month in Minimal phones:** `E-PhonesMinimal`'s band says "Tap the date ▾ for the month sheet". The `E-PhonesCalendar` spec card said "through Everything else" and was corrected (canvas `1793813578-5bda`).
- **Two open items now have register homes:**
  - a Full/Minimal switch cancels a multi-selection or drag in progress → G2-5;
  - the switch is not a Back step → G2-11.
- **Stale board text:** listed as design fixes. Per ED-074, none is changed without the owner's approval.
  - E-Phones header tags the owner's accepted dot, type, colour, finish and scale changes as "Hypothesis".
  - E-FullA-v2 header still says "G1-1 open".
  - E-Minimal's band calls the Show everything target "an owner decision".
  - The minimal boards still tag the navigation that ED-068 approved as "Hypothesis".
  - "Running late" is still in the E-Phones Day menus (insets 3 and 6).
- **Classification:** CORRECTIONS (no new decision).
### ED-079 · Calendar screens approved and added to E-Phones
- **Date:** 2026-11-04. **Owner answer:** "Yes, add them", replying to "Can the Calendar screens go into E-Phones as drawn?".
- **Change:** `E-Phones` gains a Calendar row above the insets band. It holds four frames: iPhone Calendar (Month), iPhone Today with the pull-down month, Android Calendar (Month), and Android Today with the title month sheet. It also has the month-component card. The rest of the board is byte-identical, and the height grows from 2140 to 3320. Canvas version `1793813901-df20`.
- **Layout:** `E-FullA`, `E-FullB` and `E-Workspace` moved down 1200 px together, keeping their relative arrangement.
- **Review board:** `E-PhonesCalendar` stays as the review record.
- **Android title month:** drawn as an M3 bottom sheet using the app's month grid. This replaces ED-047's "M3 date picker" note, under ED-075's platform-adapted controls.
- **Classification:** ACCEPTED.

### ED-080 · G2-2 approved: keep the Workspace rows, remove "Lists", Routines gets its own page
- **Date:** 2026-11-04. **Owner answer:** "for G2-2 … i accept your recommendation to Keep E-Workspace's rows, remove the 'Lists' sketch (it isn't a planned feature), and give Routines its own page."
- **Settles:**
  - The Full Mac/web sidebar keeps E-Workspace's rows: Today · Plan (Inbox, Routines, Brain dump) · Calendar views · Review · Search.
  - The "Lists (future)" sketch is removed from `E-FullA-v2` (canvas `1793814143-4a31`). E-Workspace keeps it as a reference board.
  - Routines gets its own page, reached from the sidebar row. The built content today lives at Settings › Routines. Its route is part of G2-11. The page itself is still to draw.
- **Supersedes:** ED-077's G2-2 adoption, which had kept Lists as a labelled sketch.
- **Also on `E-FullA-v2`:** its header and canvas title now say G1-1 is approved (ED-073). That corrects the stale "G1-1 open" label listed in ED-078.
- **Classification:** ACCEPTED.

### ED-081 · G2-4 approved: six-group Settings root; "Everything else" means only the Settings row
- **Date:** 2026-11-04. **Owner answer:** "Accept A + A" on the `E-G2-4` decision board.
- **Part 1 (Settings root), option A:**
  - **Order on every platform:** Account on top, then Layout as the first row (G1-4), then Settings search.
  - **Six groups:** Your day · Planning · Reminders · Appearance · Data and privacy · Help and about. Every built row keeps a home and a search hit.
  - **Mac:** the Settings window has panes General, Your day, Planning, Reminders, Appearance, Data and privacy, Help. General holds Layout first.
  - **Web and tablets:** two panes.
  - **Minimal:** keeps its nine built rows. "Everything else…" opens the six-group root, not a copy of the long list.
- **Part 2 ("Everything else"), option A:**
  - "Everything else…" is only the built minimal Settings row.
  - E-Minimal's ⌘K / k finder keeps its design and is renamed "Search or run", the same name as Full's command palette.
- **Board work:** the drawings (iPhone and Android Settings root, minimal Settings, Mac Settings window, web two-pane Settings) and the exact E-Minimal label changes go on a review board first. Nothing is applied to E-Phones, E-PhonesMinimal, E-Minimal or E-FullA-v2 until the owner approves them.
- **Classification:** ACCEPTED.

### ED-082 · G2-4 direction approved; two refinements requested before merging
- **Date:** 2026-11-04. **Owner:** "I like the new E-SettingsReview designs and want to approve the overall G2-4 Settings direction (A + A, ED-081). However, before publishing all the changes to the active Concept E boards, I want two important refinements." The owner attached Apple Sleep Schedule screenshots as references.
- **Refinement 1 (requested):** iPhone Settings home and group rows get icons, in E's palette and iOS style. Android keeps its own M3 treatment.
- **Refinement 2 (exploration, new features not approved):** a Dottoday take on Apple's Sleep Schedule under Settings › Your day › Wake Up and Wind Down.
- **Board:** `E-WakeWindDown-Settings-Candidate` (canvas `1793816273-d041`). It shows the iPhone home with icons, Your day, the overview (alarm off and on), Edit Weekdays with the dial, Weekend with a Wind Down after midnight, Add with validation, Android overview and edit, Mac/web, a feature check, and a recommended integration. No E board is changed.
- **Feature check (code and doc 15):**
  - **Built:**
    - per-weekday Wake Up → Wind Down ("Different days");
    - the night arc and "until Wake Up" line (W6);
    - sleep target 6–10 h (W4);
    - the alarm-grade Wake Up with Sound, Vary, Snooze length and limit, Missions, Test (W1, W5, §9);
    - the Wind Down reminder, Wake Up card and start check.
  - **Redesign of built:** schedules as a grouping of weekdays; the dial; per-schedule "Ring on these days", which maps to the built alarm `days` set; validation copy.
  - **New, not recommended:** a separate bedtime and a pre-bedtime Wind Down duration; per-schedule sound or snooze.
  - **Platform:**
    - no public iOS API turns a Focus on; a Focus Filter (App Intents) is a possible later feasibility item;
    - Health sleep data is excluded by doc 15 §7b, and Apple's sleep schedule cannot be written;
    - the system Clock is not used;
    - the iOS alarm volume is owned by AlarmKit.
- **Wind Down, two meanings:**
  - Dottoday's Wind Down is the moment the planned day ends (the evening cap). The night runs from Wind Down to the next Wake Up.
  - Apple's Wind Down is a period before bedtime.
  - **Recommendation:** keep Dottoday's meaning and add no separate bedtime.
- **Classification:** G2-4 direction ACCEPTED (ED-081). The refinements are PROPOSED / AWAITING OWNER REVIEW. No board merge until approved.
### ED-083 · Wake Up and Wind Down candidate r2: dial rule, one alarm device, tablets
- **Date:** 2026-11-04. **Owner:** "I intend to approve it … this is not my final approval as drawn." The owner asked for four things:
  - fix the dial so the duration never collides with the labels;
  - allow alarms on iPhone, Android phones, iPad and Android tablets;
  - Mac and web never ring;
  - one selected alarm device per account, with no automatic backup ringing.
- **Feature boundaries confirmed by the owner:** none of these are added:
  - a separate Bedtime or pre-bedtime Wind Down;
  - per-schedule sound or snooze;
  - sleep tracking or Health data;
  - controlling Sleep Focus;
  - writing to Apple's Sleep Schedule;
  - the system Clock.
  Wind Down stays the planned end of the day; the night runs until the next Wake Up.
- **Board:** `E-WakeWindDown-Settings-Candidate` r2 (canvas `1793817530-5628`). r1 is archived as `references/concept-e/g2-4/E-WakeWindDown-Settings-Candidate.r1.dc.html`.
- **Dial layout rule (proposed for E_DESIGN_RULES §5.9):**
  - four regions: labels outside the band · band and handles · ticks · a reserved centre disc;
  - only four labels; side labels are stacked;
  - fit test at 34 → 30 → 28 → 26 pt; otherwise the duration moves below the dial;
  - the duration always sits below at text 135% or more, or when the dial is under 240 pt;
  - the dial is 240–360 pt and the band is 12% of its size.
  - **Tested:** 5 h 40, 7 h 30, 8 h and 23 h 30 at 240, 290 and 360 pt; 12-hour and 24-hour; text at 160%.
- **Audit finding:** today every iOS/Android install with the alarm on arms its own alarm. iPad and Android tablets count as phones (`health_providers.dart`), and the setting is synced, so two devices can both ring. Mac and web never arm (`notAPhone`). There is no device list in sync.
- **Proposed (NEW, needs approval):**
  - **Device list and setting:** a synced device list (new Supabase table with RLS; must ask before any push) and an account setting "Alarm sounds on".
  - **Arming rule:** only the chosen device arms; every other device disarms when it syncs.
  - **Device picker:** shows readiness; Mac and web are listed as unable to ring.
  - **States:** ready, waiting to sync, alarms off on the chosen device, no device, offline, switching.
  - **Backup ringing:** not proposed; any later version would need its own approval.
- **Stated limits:**
  - no exactly-once delivery across devices; an offline old device may ring once during a switch;
  - changes reach the ringing device only when it syncs;
  - AlarmKit on iPadOS 26 and Play's full-screen-intent policy for tablets still need verification;
  - iOS device names need an Apple entitlement, so the list shows the model plus a name you can edit.
- **Classification:** PROPOSED / AWAITING FINAL OWNER APPROVAL.
### ED-084 · Settings and Wake Up and Wind Down approved and merged
- **Date:** 2026-11-04. **Owner answer:** "Approve and merge", replying to "Final approval for candidate r2, so I merge it into Concept E?".
- **Approved:**
  - the G2-4 Settings designs, with tinted iPhone icons;
  - Settings › Your day › Wake Up and Wind Down: schedules, the night dial and its layout rule, sleep target, the alarm with every built option, reminders;
  - one alarm device per account ("Alarm sounds on"), with its device picker and states;
  - Mac and web never ring;
  - no backup ringing.
- **Merged (canvas `1793818041-761c`; E-Map `1793818086-05e3`):**
  - **`E-Phones`:** new Settings row (iPhone home, Your day, Android Settings, Android Wake Up and Wind Down overview and edit) and two Wake Up and Wind Down rows (overview, alarm on and off, Alarm sounds on, large text, edit, Weekend, new-schedule checks, two devices).
  - **`E-PhonesMinimal`:** minimal Settings row.
  - **`E-FullA-v2`:** Mac Settings window, the Mac Wake Up and Wind Down panel with Alarm sounds on, web two-pane Settings.
  - **`E-Minimal`:** "Everything else" becomes "Search or run" in 12 lines; the doc-14 quote is kept.
  - **`E-Map`:** a "Decided since v1.1" panel.
  - Existing board content is byte-identical. Copies are in `references/concept-e/v1.2-working/`.
- **Still needs separate approval before building:**
  - the device-list Supabase table, with RLS, before any push;
  - verification of AlarmKit on iPadOS 26 and Play's full-screen-intent policy on tablets.
- **Tablets and the dial-rule test matrix** stay on `E-WakeWindDown-Settings-Candidate` (r2) as the reference until a tablet board exists (G4-4).
- **Classification:** ACCEPTED.

### ED-085 · G2-5 option D explored (Refined full task editor)
- **Date:** 2026-11-04. **Owner request:** a separate option D. The owner's screenshots set the functions only; everything is drawn in Concept E. Option C stays untouched, and G2-5 stays open.
- **Board:** `E-G2-5-OptionD-RefinedEditor` (canvas `1793822646-3cb8`), with a copy in `references/concept-e/g2-5/`. It shows:
  - the full editor;
  - the compact Colour and icon picker, and the full icon browser with a sticky glass palette;
  - the editor after a colour change;
  - empty and populated steps and notes (the active step above the keyboard);
  - the repeating-task scope chooser;
  - a long title with large text;
  - a new task with Create task;
  - Android, iPad and Mac/web versions;
  - a side-by-side comparison with option C.
- **Checked in code:**
  - three edit scopes, This one / This and following / All, with "All" never changing past ones (`domain/recurrence/series_edit.dart`); calendar series offer This one and All;
  - built autosave;
  - 525 icons in 16 categories with search and up to two suggested (`task_icon_picker.dart`, `colour_icon_block.dart`);
  - no Pro icon gating today: `isPro` is true until a split is signed off;
  - Energy is Low / Medium / High;
  - steps complete per occurrence (R-09); notes support links.
- **New or to verify:**
  - Recently used icons (new);
  - asking the repeat scope before a repeating change is written (autosave must hold it);
  - the glass palette over a scrolling grid (feasibility and contrast).
  - Updating past tasks is not offered: the built rule keeps history unchanged.
- **Classification:** EXPLORATORY · G2-5 OPEN (options A, B, C, D).
- **Update (2026-11-04, owner: "for option D everything is great also include the Medium detent"):**
  - Frame 0, the Option D medium detent, is added. It has the tinted header (the dot is the colour and icon button), the overlap and steps line, the action tiles, Need more time?, and "Pull up for date, alerts, steps and notes", which leads to frame A.
  - The board is rearranged into four rows. Canvas `1793823228-4b25`; the previous revision is kept as `E-G2-5-OptionD-RefinedEditor.r1.dc.html`.


### ED-086 · G2-5 approved: option D, the refined full task editor
- **Date:** 2026-11-04. **Owner answer:** "Approve option D", on `E-G2-5-OptionD-RefinedEditor` (canvas `1793823228-4b25`).
- **Settles:**
  - **One task surface:** a medium detent pulls up to the full editor on iPhone; Android uses a partial sheet that expands to full screen; iPad shows the editor beside the day; Mac and web use the inspector with a colour and icon popover.
  - **Header:** tinted in the task colour, and the task dot is the Colour and icon button. The action tiles and Need more time? sit at the top.
  - **Fields:** date, time and alerts in one card; Repeat and Energy as pills; steps and notes edited in place; Sound, Pin, Travel time and Delete in More and in ⋯.
  - **Colour and icon picker:** a compact sheet that drags up to the full icon browser with a sticky glass palette.
  - **Repeating tasks:** a full-sheet scope chooser (This one / This and following / All; past never changes).
  - **New task:** a Create task variant of the same editor.
  - **Saving:** Done closes and edits save as built, with Undo. Options A, B and C are not chosen and stay as history.
- **Approved, still to verify before building:**
  - Recently used icons: a new feature, approved with D.
  - The repeat scope is asked before a repeating change is written, so autosave holds the change (implementation check).
  - The glass palette over a scrolling grid (feasibility and contrast).
- **Not settled here:** what a Full ↔ Minimal switch does to a multi-selection or drag in progress (ED-078). Moved to G2-11 with the other switch rules.
- **Next:** merge into the E boards. This replaces the E-Phones task frames (F3 medium detent, F6 Android edit) with option D's frames, so the owner is asked before the merge.
- **Classification:** ACCEPTED.


### ED-087 · Option D merged into Concept E
- **Date:** 2026-11-04. **Owner:** "Yes, merge Option D into Concept E … as shown on E-G2-5-MergePreview."
- **Change (canvas `1793824402-8088`; E-Map `1793824421-7b71`):**
  - **`E-Phones` F3:** frame and caption replaced by option D's medium detent.
  - **`E-Phones` F6:** frame and caption replaced by option D's Android full-screen editor. Tapping Time still opens the M3 time picker, and predictive Back steps full → partial → Today.
  - **New `E-Phones` "Task editor" section:** full editor, empty steps and notes, typing a step, repeat scope, large text, compact Colour and icon, all icons with the pinned palette, back in the editor, and Create task as an added entry point. F2 Quick Add is unchanged.
  - **`E-FullA-v2`:** inspector unchanged; a Task editor section adds the colour and icon popover.
  - **`E-Map`:** a Task editor line in "Decided since v1.1".
- **Unchanged:** `E-PhonesMinimal`, `E-Minimal` and every other frame. A line diff confirms that only F3, F6, the new section and the board heights changed.
- **Layout:** `E-FullA`, `E-FullB` and `E-Workspace` moved down 2060 px.
- **Historical references:** options A/B (`E-G2-5`), C (`E-G2-5-FullEditor`), D (`E-G2-5-OptionD-RefinedEditor`, including iPad) and `E-G2-5-MergePreview`.
- **Snapshots:** `references/concept-e/v1.3-working/`.
- **Rendered and inspected:**
  - no clipping in the merged frames;
  - the active step stays above the keyboard;
  - the pinned palette sits above the grid without covering headings.
  - Accessible names exist on the dot button, steps, scope options and switches.
  - **Still to verify:** contrast of the selected ring on glass, and native detents.
- **Behaviour preserved, with explicit differences:**
  - Autosave, Undo and recurrence rules are unchanged. History never changes.
  - Free/Pro: no icon is gated, because `isPro` is true until a split is signed off.
  - **One behavioural change:** a repeating change waits for the scope choice before it is written.
  - Recently used icons are new.
- **Classification:** ACCEPTED.


### ED-088 · G2-6 behaviour approved: the minimal task screen keeps the essential actions
- **Date:** 2026-11-04. **Owner answer:** "For G2-6, I choose Option A, with a few design requirements before the new screens are merged."
- **Settles (behaviour), on phones and in E-Minimal's task column:**
  - **Actions:** Done, Tomorrow, Later and Delete. "Need more time?" appears when the task is running.
  - **More options** opens the approved option D editor, keeping the selected task, date and editing state.
  - **Colour and icon:** not on the minimal screen; they live in More options.
- **Owner's visual requirements:**
  - Keep E-Minimal's calm task-column identity, including Starts and Duration.
  - Done is prominent; Tomorrow and Later are easy to find.
  - Delete is secondary and protected.
  - Phones use E-PhonesMinimal's language with native patterns; Mac and web fit the column without crowding.
- **Classification:** behaviour ACCEPTED. Drawings PROPOSED / AWAITING OWNER REVIEW. E-Minimal and E-PhonesMinimal are unchanged until the owner approves.


### ED-089 · G2-6 approved: the minimal task screen drawings approved and merged
- **Date:** 2026-11-04. **Owner answer:** approved the drawings on `E-G2-6-Review` and asked for them to be merged into E-PhonesMinimal and E-Minimal, keeping each board's identity and the approved behaviour.
- **Merged (canvas version `1793826732-d0c2`):**
  - **`E-PhonesMinimal`:** new "Task sheet (minimal)" row: iPhone with a task ahead, iPhone with the task running, Android with the task running, and More options → option D editor.
  - **`E-Minimal`:** the Mac inset's task column is replaced by the approved one (Starts and Duration kept, Done prominent, Tomorrow and Later, Need more time? while running, More options, small Delete task with Undo). A new "Task in the web column" section draws the same screen in the 510 px web column.
  - **`E-Map`:** "Minimal task screen" line added to "Decided since v1.1".
- **Frame fix (owner allowed):** the `E-Phones` canvas frame was 2730 × 8000 while its content is 2760 × 8320, so the lower rows were clipped. It is now 2760 × 8320. The board itself is unchanged.
- **Checked:** every changed board was rendered locally; content ends inside the 40 px padding (E-PhonesMinimal 3910 of 3950, E-Minimal 3040 of 3080, E-Phones 8280 of 8320, E-Map 4052 of 4200). No overlapping sections, no unbalanced tags, no duplicate ids. A line diff against the live files showed only the intended blocks changed.
- **History:** `E-G2-6` (options) and `E-G2-6-Review` (drawings) stay on the canvas, retitled as historical references. Copies are in `references/concept-e/g2-6/` and `references/concept-e/v1.4-working/`.
- **Classification:** ACCEPTED. G2-6 is RESOLVED. This is a design baseline only, not implementation approval.


### ED-090 · Tablet coverage checklist deferred to the start of Round 2; G2-8 presented
- **Date:** 2026-11-04. **Owner answer:** "Let's proceed to G2-8 first… defer the full tablet coverage checklist until the transition into Round 2."
- **Settles (process):**
  - The comprehensive tablet coverage checklist is a **mandatory preparation step before Prompt D Round 2 begins**. It covers every approved Concept E feature in Full and Minimal, portrait and landscape, split-screen and resizable windows, and tablet-specific interactions. No separate audit runs now.
  - Until then, each Group 2 decision records its iPad and Android tablet/foldable implications. Existing tablet gaps stay visible in `E_SCREEN_INVENTORY.md` and `E_TRACEABILITY.md`. No phone or Mac layout is assumed to work on tablets, and no tablet layouts are drawn.
- **G2-8 presented** on the new decision board `E-G2-8` (canvas `1793827751-1af3`; copy in `references/concept-e/g2-8/`): option A (Brain dump and Routine as modes of Add, with the Brain dump, Routine and proposal screens drawn from the built flows), option B (Day menu only, as built) and option C (described). No E board changed.
- **Classification:** process ACCEPTED. G2-8 PROPOSED / AWAITING OWNER ANSWER.


### ED-091 · G2-8 approved: Brain dump and Routine are modes of Add (option A), merged
- **Date:** 2026-11-04. **Owner answer:** "I approve G2-8 Option A — Brain Dump and Routine as modes of Add, including the designs shown on E-G2-8."
- **Settles:**
  - **iPhone:** Add keeps its Task · Brain dump · Routine segmented control (E-Phones F2). Task is the default with the title focused, so the quick add stays two taps.
  - **Brain dump mode:** one thing per line, mic, Today / Tomorrow, Plan it, Earlier dumps with Use again (the built sheet, now a mode of Add, not a second copy).
  - **Routine mode:** pick a day, tap a routine to preview where its steps land; Edit routines… opens the Routines page (ED-080).
  - **Both** open the one ProposalSheet; nothing is saved before Add to day.
  - **Android:** the M3 FAB menu picks the mode; the sheet is titled by the mode.
  - **Mac:** File menu with New Task, New Brain Dump…, Drop a Routine…. **Web:** a split Add button whose ▾ opens the three modes.
  - **Kept:** Day menu Brain dump and Drop a routine, the empty day's Drop a routine, ROUTINES chips under Add's suggestions, the Workspace sidebar rows, the ⌘K palette.
  - **Minimal:** unchanged (E-PhonesMinimal, E-Minimal).
- **Not approved here:** the shortcut letters shown (⌘N, ⇧⌘N, ⇧⌘V, web n / ⇧N). They stay proposals until G2-10.
- **Merged (canvas `1793829085-95f3`):** E-Phones (F2 line approved, FAB inset tagged, new "Add modes" row), E-FullA-v2 (new "Add modes · Mac and web" section), E-Map (Decided line). E-G2-8 kept as history. Layout only: the historical `E-FullA` board moved down (y 24050) because E-Phones grew over it.
- **Checked:** rendered; content ends inside the padding (E-Phones 9378 of 9420, E-FullA-v2 4968 of 5010); no overlapping sections or boards; only the intended blocks changed.
- **Tablets (recorded for Round 2, not drawn):** as listed under G2-8 in the register.
- **Classification:** ACCEPTED. G2-8 RESOLVED. Design baseline only, not implementation approval.


### ED-092 · G2-9 presented: the Day menu
- **Date:** 2026-11-04. Decision board `E-G2-9` (canvas `1793829336-eda0`; copy in `references/concept-e/g2-9/`). No E board changed.
- **Shows:** the five current Day menus copied from E-Phones (iOS, M3), E-FullA-v2 (Mac menu bar, web Day ▾) and E-PhonesMinimal, plus E-Minimal's menu drawn from its caption list; the built menu listed.
- **Proposed for Full (A and B):** E-FullA-v2's Time · Plan · Day · Layout everywhere, redrawn as the iOS pull-down and the M3 menu; Replan folded into Time; Rebalance… added on phones; Plan / Reality in Layout; Routines… named Drop a routine….
- **The open choice is wide minimal:** A trims E-Minimal's menu to doc 14's three items; B (recommended) keeps E-Minimal's menu with aligned names; C adds a separate Replan button in Full on Mac and web (described).
- **Settled with it in every option (proposed):** +5 / +15 / +30; Need more time behaves like the built Running late; one name, Low-energy mode; Show less / Show everything always in the menu.
- **Classification:** PROPOSED / AWAITING OWNER ANSWER.

### ED-093 · G2-9 approved: one Full Day menu everywhere; wide minimal keeps E-Minimal's menu (option B), merged
- **Date:** 2026-11-05. **Owner answer:** "For G2-9, I choose Option B." The owner approved one Full Day menu structure on every platform using E-FullA-v2's four groups, kept E-Minimal's richer Day menu on Mac and web, and kept the simpler menu on minimal phones. E-Minimal's commands are not to be removed to match the older phone minimal spec.
- **Settles:**
  - **Full, every platform:** Time · Plan · Day · Layout.
    - Time: Need more time ▸, Shift the rest from here…, Rebalance….
    - Plan: Brain dump…, Drop a routine…, Pick today's one thing….
    - Day: Duplicate day…, Copy day as text, Review the day, This week.
    - Layout: Low-energy mode, Plan / Reality, Show less.
  - **Native presentation:** iPhone Day ▾ pull-down; Android M3 menu from the Day button; Mac menu bar Day and the toolbar Day ▾; web Day ▾ popover.
  - **Replan:** no separate button. Its actions are the Time group, the menu's first group. Need more time is also on the Now card and the task screen, so it stays one tap away while a task runs.
  - **Minimal phones:** Show everything · Low-energy mode · Settings (doc 14 §4, as built). Settings stays behind the avatar too.
  - **Minimal Mac and web:** E-Minimal's menu, names aligned: Need More Time ▸, Shift the Rest From Here…, Brain Dump…, Drop a Routine…, Duplicate Day…, Copy Day as Text, Review the Day, Low-Energy Mode, Show Everything. The menu bar keeps every command reachable from the keyboard and VoiceOver. Rebalance…, Pick Today's One Thing…, This Week and Plan / Reality stay in Full and in ⌘K.
  - **Names:** "Need more time" replaces "Running late" in menus, with the behaviour unchanged: extend what is on now and move the rest. The ellipsis or ▸ follows each platform's menu convention. "Low-energy mode" replaces "Low-energy day" and "Gentle Day". "Drop a routine…" replaces "Routines…" in the Day menu.
  - **Increments:** +5 / +15 / +30 wherever Need more time offers choices (menus, the web chips, the Mac submenu). The task-sheet chips on phones stay as approved in G2-5 and G2-6.
  - **Other days:** Time is today-only. Plan / Reality is disabled on a day with no reality yet (drawn on the Wed 4 Nov Mac menu).
  - **Doc 14 §4:** the three-item limit applies to the phone header menu. Wide minimal keeps E-Minimal's menu; doc 14 needs this line when the redesign reaches the docs (not edited here: no production docs changed in this pass).
- **Not approved here:** shortcut letters shown in any menu (⇧⌘N, ⇧⌘C, ⇧⌘L, ⇧⌘→, web b, ⇧L), which stay G2-10, and web routes, which stay G2-11.
- **Merged (canvas `1793833662-a67e`):**
  - **E-Phones:** insets 3 (iOS) and 6 (M3) replaced by the E-G2-9 drawings and tagged approved. Height 9420 → 9460.
  - **E-FullA-v2:** Routines… → Drop a Routine… (Mac, two menus) and Drop a routine… (web); Plan / Reality added to Layout in the Mac menus (disabled on the empty Wednesday) and the web menu; the three labels tagged approved; the G2-8 note now says Drop a Routine….
  - **E-PhonesMinimal:** Low-energy day → Low-energy mode, and Settings added as the third item, in all three drawn menus. The two captions are updated.
  - **E-Minimal:** the caption list uses the aligned names and adds Show Everything. "Gentle day" → "Low-energy mode" in the finder and the band. A new "Day menu (minimal, Mac and web)" section draws the menu-bar Day menu and the web Day menu for the first time. Height 3080 → 3680.
  - **E-Map:** Decided now covers G2-1 to G2-9, with a Day menu line.
  - **E-G2-9:** kept unchanged as history and retitled.
- **Checked:**
  - Rendered locally. Content ends inside the padding:
    - E-Phones: 9420 of 9460.
    - E-FullA-v2: 4985 of 5010.
    - E-PhonesMinimal: 3910 of 3950.
    - E-Minimal: 3640 of 3680.
    - E-Map: 4066 of 4200.
  - No board overlaps, and no new tag or id errors. E-FullA-v2's 20 unclosed-tag warnings were already in the live file.
  - Every command in every Day menu was compared before and after. Nothing was lost. The only differences are the renames above and the additions (Rebalance… and Plan / Reality on phones' Time and Layout groups, Plan / Reality on Mac and web, Settings on minimal phones, Show Everything on E-Minimal).
- **Tablets (recorded for Round 2, not drawn):** as listed under G2-9 in the register.
- **Classification:** ACCEPTED. G2-9 RESOLVED. Design baseline only, not implementation approval.

### ED-094 · G2-10 presented: one keyboard scheme
- **Date:** 2026-11-05. Decision board `E-G2-10` (canvas `1793834077-bbe4`; copy in `references/concept-e/g2-10/`). No E board changed.
- **Shows:**
  - the clashes between the built app (`app_shortcuts.dart`, `app_menu.dart`, `today_keys.dart`, `task_keys.dart`, `wide_inbox.dart`), `E-FullA-v2` and `E-Minimal`:
    - ⌘1–4 has three meanings, and ⌘F two.
    - ⌘D is Done in the built app but Duplicate on the boards.
    - ⌘M is Minimize.
    - ⇧⌘G is Find Previous.
    - ⌥⌘D toggles the Dock.
    - ⇧⌘→ selects text.
    - the web has two keys for Brain dump.
    - the web binds ⌘/Ctrl 1–4 (browser tabs) and Ctrl+Shift+P (a private window in Firefox).
  - one proposed scheme for both modes, with Mac and iPad (⌘), Android, Windows and Linux (Ctrl), and web (single keys outside text fields) columns;
  - the Mac File, Go, Day and context menus with the proposed keys;
  - the web hint bars;
  - a new web setting to turn off single-key shortcuts (WCAG 2.1.4).
- **Proposed in every option:**
  - built keys are kept, except ⌘D (Done moves to ⌘↩ and Space; ⌘D becomes Duplicate), the web's ⌘/Ctrl 1–4 (now single keys) and ⇧P (now p);
  - E-FullA-v2's fixes: ⇧⌘M Move To, ⇧⌘T Go to Date, ⇧⌘F Focus, ⌘F Search, ⌥⌘I Inspector and Day Column;
  - E-Minimal's ⌘K, ⌘D, ⌘↩, ⌥⌘0 and web n / t [ ] k ? are kept;
  - no keys for Need More Time, Shift the Rest or Rebalance;
  - minimal ⌘1–4 follow E-Minimal's sidebar: Now · Inbox · Calendar · Search.
- **The open choice is Full ⌘1–4:**
  - **A:** Day · 3 Days · Week · Month, as on E-FullA-v2.
  - **B (recommended):** Today · Inbox · Week · Month, as built. ⌘2 is Inbox in both modes.
  - **C:** keep each board's map.
  - The register recommended A before G2-9. B is recommended now because the G2-9 answer asked to preserve built behaviour.
- **Tablets (recorded, not drawn):**
  - iPad uses the ⌘ scheme. The ⌘-hold overlay needs native registration (unverified).
  - Android tablets, foldables and Chromebooks use Ctrl. The Meta+/ helper is unverified in Flutter.
  - Which ⌘1–4 set a tablet gets follows its Round 2 layout.
- **Canvas note:** a page edit just before this (`1793833907-178a`) moved E-Phones to x 129, y 12760 and set its frame to 8000. Its content ends at about 9420, so the bottom (Add modes row and insets band) is cut off in the frame, and the frame now overlaps E-PhonesMinimal by 64 px. It was left as set; the owner is asked whether to restore the frame.
- **Classification:** PROPOSED / AWAITING OWNER ANSWER.

### ED-095 · G2-10 approved: one keyboard scheme, option B, reconciled with the built app
- **Date:** 2026-11-05. **Owner answer:** "I approve G2-10 Option B for ⌘1–4." Full keeps ⌘1 Today, ⌘2 Inbox, ⌘3 Week and ⌘4 Month. Minimal uses its own destinations. ⌘2 is Inbox in both modes. Native modifiers apply on every platform, with no OS or browser conflicts. The owner asked for the other proposed changes, especially ⌘D, to be verified before the decision is marked resolved.
- **Verified against the built app** (`app_shortcuts.dart`, `app_shortcut_groups.dart`, `app_menu.dart`, `today_keys.dart`, `task_keys.dart`, `task_editor.dart`, `wide_inbox.dart`, `week_view.dart`, `month_screen.dart`):
  - ⌘D marks done in two places. On Today it marks the running task done (with Undo). In the task editor it toggles Done.
  - ⌘D is also specified in doc 10 ("Esc closes, ⏎ saves, ⌘D marks done") and plan M3e.6, which requires a test per binding.
  - ⌘↩ is already built in the Inbox as "place the selected task in the first free gap".
  - Nudge is ⌘↑↓ for 5 min and ⇧⌘↑↓ for 15 min. ⇧⌘P auto-plans in the wide Inbox. ⌘S saves in the editor.
  - ⌘ is used on macOS and iOS (including web on Apple hosts); Ctrl everywhere else.
- **Reconciled (changes from the E-G2-10 proposal):**
  - **⌘D stays Done, as built and specified.** The proposal to make ⌘D Duplicate is withdrawn: it would have removed a built, specified and tested key and moved Done to ⌘↩, which the Inbox already uses. Duplicate has no key; it stays in the context menu and ⌘K. Done is also Space on a selected task, as built.
  - **⌘↩ stays** the Inbox's Place in First Free Gap.
  - **No ⇧⌘I.** Inbox is ⌘2. The web uses 2, not i; i stays Inspector, as on E-FullA-v2.
  - **Web views:** 1–4 mirror ⌘1–4 with no modifier. d / 3 / w / m are dropped. Day and 3 Days use the View menu and ⌘K, as on Mac.
  - **Web Brain dump** is ⇧N (b is dropped).
- **The resolved scheme** (⌘ on Mac and iPad keyboards; Ctrl on Android, Windows and Linux; web keys work outside text fields):
  - **⌘1–4.** Full: Today · Inbox · Week · Month. Minimal: Now · Inbox · Calendar · Search. Web: 1–4, the same per mode.
  - **Create:**
    - ⌘N New Task (web n);
    - ⇧⌘N New Brain Dump… (web ⇧N);
    - ⇧⌘V Paste as Tasks (web: paste a list into Add).
  - **Go:**
    - ⌘T Today (web t);
    - ⌘← / ⌘→ previous / next day (web [ ]);
    - ⌘[ / ⌘] Back / Forward (web: the browser's own; Alt+← / Alt+→ off Apple);
    - ⇧⌘T Go to Date… (web g);
    - ⌘F Search (web /);
    - ⌘K Search or Run (web k or ⌘/Ctrl K).
  - **Day:**
    - ⇧⌘L Show Less / Show Everything (web ⇧L);
    - ⇧⌘C Copy Day as Text;
    - no keys for Need More Time, Shift the Rest, Rebalance and the other Day menu items.
  - **Selected task:**
    - ↩ Open;
    - ⌘D or Space Done (web: Space);
    - ⇧⌘M Move To…;
    - ⇧⌘F Focus (web f);
    - Delete / ⌫ or ⌘⌫ Move to Trash;
    - ↑↓ step; ⌘↑↓ / ⇧⌘↑↓ nudge 5 / 15 min;
    - Esc closes.
  - **Inbox:** ⌘↩ Place in First Free Gap; ⇧⌘P Auto-plan (web p).
  - **Editor:** ⌘S Save; ⌘D Done; Esc.
  - **Window:**
    - ⌥⌘I Inspector (Full) / Day Column (minimal), web i for the Inspector;
    - ⌃⌘S Show Sidebar (Mac);
    - ⌥⌘0 Now window (Mac);
    - ⌘, Settings;
    - ⌘/ Keyboard Shortcuts (web ? and ⌘/Ctrl /);
    - ⌘Z / ⇧⌘Z.
  - **Web setting:** single-key shortcuts can be turned off (WCAG 2.1.4). It is a new row on the web, in Settings › General.
- **Never bound:**
  - macOS: ⌘M, ⌘H, ⌘Q, ⌘W (system), ⇧⌘G, ⌥⌘D, ⌃⌘F.
  - iPadOS: ⌘H, ⌘Space, ⌘Tab, Globe keys.
  - Android: Meta / system keys.
  - Web: ⌘/Ctrl N, T, W, L, D, 1–9, ⇧N, ⇧T, ⇧P and the browser's Back / Forward keys.
  - Text fields always keep editing keys (⌘← / ⌘→, ⇧⌘→, ⌘⌫, ⌘Z).
- **Kept on purpose on the web, focus-scoped:**
  - ⌘/Ctrl S, only while the task editor has focus (it overrides the browser's Save Page);
  - ⌘/Ctrl ↑↓, only while a task is selected (it overrides scroll to top or bottom);
  - ⌘/Ctrl K and ⌘/Ctrl ↩.
  - All are common web-app practice and none is a key the browser reserves.
- **User-facing changes from the built app** (for implementation later; not made now):
  1. **Minimal on every keyboard:** ⌘1 opens Now (was Today), ⌘3 Calendar (was Week), ⌘4 Search (was Month). ⌘2 Inbox is unchanged.
  2. **Web:**
     - ⌘/Ctrl 1–4 → 1–4;
     - ⌘/Ctrl N → n;
     - ⌘/Ctrl T → t;
     - ⌘/Ctrl ← / → → [ ];
     - ⌘/Ctrl ⇧P → p;
     - ⌘/Ctrl D no longer marks done on the web (the browser's Bookmark). Use Space on a selected task, or Done in the editor.
     - ? opens the shortcut list (⌘/Ctrl / still works).
     - The new single-key setting.
  3. **New keys on Mac, iPad and Android:** ⇧⌘N, ⇧⌘V, ⌘F, ⇧⌘F, ⇧⌘M, ⇧⌘T, ⌘K, ⇧⌘L, ⇧⌘C, ⌘⌫, ⌥⌘I, ⌘[ ⌘] (plus ⌃⌘S and ⌥⌘0 on Mac).
  4. **Nothing built is reassigned in Full** on Mac, iPad or Android.
  - The shortcut sheet (⌘/), the per-binding tests (plan M3e.6) and doc 10's keyboard line follow when this is implemented.
- **Merged (canvas `1793837638-aed0`), labels only, layouts unchanged:**
  - **E-FullA-v2:**
    - View menu: Today ⌘1 · Inbox ⌘2 · Week ⌘3 · Month ⌘4, then Day and 3 Days without keys (two rows added; the menu still fits its frame).
    - Go › Inbox has no key.
    - The sidebar's Day and 3 days lose ⌘1 / ⌘2.
    - Context menus: Mark Done ⌘D; Duplicate has no key.
    - Web hint bar: 1 2 3 4 "go to". Web Day menu: Brain dump ⇧N.
    - G2-8's keys are tagged approved, and the key tables and notes are marked resolved.
    - The E-Minimal copy in the Full ↔ Minimal flow is aligned.
  - **E-Minimal:**
    - View menu: Now ⌘1 · Inbox ⌘2 · Calendar ⌘3 · Search ⌘4; Show Day Column ⌥⌘I.
    - Context menu: Mark Done ⌘D, Move To… ⇧⌘M, Focus ⇧⌘F; Duplicate has no key.
    - Go to Date… ⇧⌘T; Shift the Rest has no key.
    - Inbox ⌘2 in the band; notes updated.
  - **E-Map:** a Keyboard line under Decided.
  - **E-G2-10:** kept unchanged as history and retitled. Its ⌘D, ⌘↩, ⇧⌘I and web d / 3 / w / m proposals are superseded by this entry.
- **E-Phones frame restored:** x 30, y 12480, height 9460 (content ends at 9420). There is no overlap with E-PhonesMinimal (35 px gap). Board content is unchanged.
- **Checked:**
  - Token diff: only key text, tag classes, two aria-labels and the two new View rows changed.
  - Rendered: the E-FullA-v2 View menu ends 14 px inside its frame; content ends inside the padding (E-FullA-v2 4985 of 5010).
  - No board overlaps. Leftover old keys appear only in the "Was" / "Why" history columns.
- **Tablets (recorded for Round 2, not drawn):**
  - iPad keyboards use the ⌘ column. The ⌘-hold overlay needs native registration (unverified).
  - Android tablets, foldables and Chromebooks use the Ctrl column. The Meta+/ helper is unverified in Flutter.
  - A tablet's ⌘1–4 set follows its Full or minimal layout.
- **Classification:** ACCEPTED. G2-10 RESOLVED. Design baseline only, not implementation approval.

### ED-096 · G2-11 presented: web routes
- **Date:** 2026-11-05. Decision board `E-G2-11` (canvas `1793837899-6a74`; copy in `references/concept-e/g2-11/`). No E board changed.
- **Verified in code** (`app_routes.dart`, `app_router.dart`, `deep_link_guard.dart`):
  - Built routes: `/today`, `/inbox`, `/week`, `/search`, `/settings` (five shell tabs); `/month`; `/day/:date`, validated yyyy-MM-dd; `/settings/:page` (13 pages); `/task/:id` and `/focus/:id` (UUID v7); `/wake-up`, `/wake-up/mission/:date/:kind`, `/review`, `/add`. Anything else lands on `/today`.
  - The deep-link guard refuses any query or fragment, so `?task=` and `?q=` would land on `/today` today.
  - No path URL strategy is set, so web URLs are hash URLs (`dottoday.app/#/today`). The calendar sign-in returns to `https://dottoday.app/#/settings/calendars` (docs/08), an origin allow-listed in a backend function.
  - Apps use the same paths through `dottoday://`. There are no universal or app links.
- **Recommendation A′:** E-FullA-v2's route names on the built hash URLs.
  - Every built route is kept.
  - New routes: `/3-days/:date`, `/week/:date`, `/month/:yyyy-mm` and `/now`.
  - Minimal's Calendar uses the Month route.
- **Four details, each with a recommendation:**
  - **D1:** keep hash URLs. Path URLs need a host rewrite and a backend allowed-origin change, which would be a separate, must-ask decision.
  - **D2:** `?task=<id>` on any view. The guard accepts that one key only, UUID v7 only, looked up under the signed-in user.
  - **D3:** no search text in URLs (task titles are personal data).
  - **D4:** a link never changes the mode. It opens the closest place in the current mode: in minimal, Week, 3 Days or a day → Calendar on that date; in Full, `/now` → Today.
- **Back and refresh rules for approval:**
  - each view, date or task change is a Back step;
  - Show Less / Show Everything is not a Back step (ED-078);
  - switching mode cancels a selection or drag, with Undo, and keeps an open task (ED-086);
  - refresh restores view, date and task;
  - Show Everything returns to the last Full place.
- **Not adopted:** `/plan/…` (E-Workspace), `/search?q=`, and grouped `/calendar/…` paths.
- **Tablets (recorded, not drawn):**
  - The same `dottoday://` paths.
  - D4 follows the tablet's Round 2 layout.
  - Each window keeps its own place and Back history (unverified with go_router).
  - Universal links / App Links are not built.
- **Classification:** PROPOSED / AWAITING OWNER ANSWER.

### ED-097 · G2-11 approved: option A′, D4 reconciled per layout
- **Date:** 2026-11-05. **Owner:** "I approve G2-11 Option A′ (A-prime) as the web routing direction for Concept E, with one required clarification to D4." D1 (keep hash URLs and existing links), D2 (`?task=` with strict id validation and signed-in authorization), D3 (no personal search text in URLs) and D4 (a link never silently changes the Full/Minimal preference) are approved. Before finalizing D4 the owner required: minimal phones' `/today` opens Today, not Now; minimal Mac/web's `/today` reveals the Day column without treating it as Now; `/day/:date` and other calendar links open a date-based place on every layout, including minimal phones (no Calendar tab); a task link opens the task and its date, past, current or upcoming; Full Mac/web keeps the Workspace; Back, Forward and Refresh keep view, date and open task; `dottoday://` links, sign-in callbacks and notification/widget links keep working.
- **Supersedes:** ED-096's D4 answer ("in minimal, Week, 3 Days or a day → Calendar"; `/today` → `/now` in minimal) and its "Show Everything returns to the last Full place". ED-096 is kept unchanged above.
- **Corrected routing table** (address after `dottoday.app/#`; web at phone width uses the phone columns; tablets in Round 2):

  | Address | Built | Full · phones | Full · Mac/web (Workspace) | Minimal · phones | Minimal · Mac/web |
  |---|---|---|---|---|---|
  | `/now` | new | → `/today` | → `/today` | Now tab | Now pane; Day column as left |
  | `/today` | built | Today tab | Today | **Today tab** (not Now) | **Day column revealed on today** and focused; main pane stays (Now on a fresh load); address stays `/today` |
  | `/day/:date` | built | Today tab on that date, ‹ Today | Day view | Today tab on that date, ‹ Today | Calendar on that month, date selected; Day column on that date |
  | `/3-days/:date` | new | → `/day/D` | 3 Days | → `/day/D` | → `/day/D` |
  | `/week`, `/week/:date` | built + new | → `/day/D` (week strip shows the week) | Week | → `/day/D` | → `/day/D` |
  | `/month`, `/month/:yyyy-mm` | built + new | Calendar tab (Month, ED-075) | Month | Today tab with the month sheet open on that month | Calendar on that month |
  | `/inbox` | built | Inbox | Inbox | Inbox | Inbox |
  | `/search` | built | Search tab | Search | Search, as from Settings › Everything else | Search |
  | `<view>?task=<id>` | new | Task sheet over the view | Inspector | Minimal task sheet (ED-089) | Task screen in the right column |
  | `/task/<id>` | built | → `<place>?task=<id>` by rule T | same | same | same |
  | `/focus/<id>`, `/review`, `/wake-up…`, `/settings…`, `/add` | built | as built | as built | as built | as built |
  | anything else | built | → `/today` | same | same | same |

  - Every "→" replaces the history entry (no Back step). The address always shows what is on screen.
  - **Routines' own page** (ED-080 left its route to G2-11) keeps the built `/settings/routines` address; the Workspace's Plan › Routines row opens it as its own page. No second name is added.
  - **Rule D:** D is today when the range holds today, otherwise the range's first day.
  - **Rule T:** a task link opens on the task's date, read when the link opens (a moved task follows): no date → `/inbox?task=`; today → `/today?task=`; any other date, past or upcoming → `/day/<date>?task=`. Start date in the device's time zone. A repeating task's link names one occurrence (as notifications already do) and opens that occurrence's date with its own steps and done state (R-09). Not found, deleted or not the signed-in user's → `/today`, saying nothing about the id (D2).
- **Back, Forward, Refresh:** one Back step per view, date or task you open yourself; redirects, a mode switch and a web resize across the phone width replace the entry. Closing a task removes `?task=` (a Back step if you opened it here; a replace if you arrived with it open). Forward re-opens what Back closed, with the task checked again. Refresh restores view, date and task. Show Less / Show Everything is not a Back step, keeps date and open task (ED-067), and Show Everything returns to the Full view you left (Week stays Week), as `E-FullA-v2` draws. Apps keep the same stack (Android Back and predictive back, iPhone back swipe and Close, Mac ⌘[).
- **Verified against the built app (2026-11-05):**
  - `deep_link_guard.dart` allow-lists both web locations and `dottoday://` links through one function, so every path above works as a link. It refuses any query today: `?task=` needs the D2 guard change when built (one key on view routes only, one lowercase UUID v7, ownership checked by the repository as docs/09 M4.2 already requires; other queries dropped with the path kept).
  - `app_router.dart` `_redirect` handles `dottoday://auth-callback?code=…` before the allow-list and sends it to Settings › Account; unchanged.
  - Web sign-in returns to origin + path (`account_providers.dart`) and Supabase reads the code before the `#` (`supabase_start.dart`, `detectSessionInUri`); the router never sees it. Hash URLs keep this.
  - Calendar connect returns to `…/#/settings/calendars` on the web and `dottoday://settings/calendars` in the apps (`cloud_calendar_providers.dart`); unchanged, so the backend's allowed return addresses do not change.
  - `notification_responder.dart` opens `/task/<occurrenceId>`, `/today`, `/review`, `/wake-up`, `/focus/<id>`; all kept. Widgets, Live Activity, the Mac status item, Android shortcuts and tiles, Share and Wake Up use `today`, `add`, `inbox`, `task/`, `focus/`, `wake-up`, `wake-up/mission/…`; all kept.
  - Built differences the implementation must change later: `/task/:id` is a full-screen route today (becomes the task over its date, rule T); `ShellTab.week` is a phone tab today (E's Full phones use Calendar, ED-075; `/week` keeps working).
  - Boards: `E-PhonesMinimal` (Now · Today · Inbox; month sheet from the date ▾), `E-Phones` (Calendar = Month; ‹ Today; task sheet), `E-Minimal` (Now + Day column; task screen in the column; Calendar and Search rows), `E-FullA-v2` (Workspace views, inspector, back in Full on the same week) all match the table.
- **Merged (labels only, canvas `1793850945-1f54`; copies in `references/concept-e/v1.8-working/`):** `E-FullA-v2` address bars and captions on `/#/`, route table resolved (`/search` without text, task links open on their date, Show Everything wording); `E-Minimal` `/#/now`, an approved route line, `/now` route removed from its Hypothesis line; `E-Map` Routes line and hash-URL wording (frame 4200 → 4240). Measured heights of `E-FullA-v2` and `E-Minimal` are unchanged.
- **Board:** `E-G2-11` now leads with the corrected table, rules, verification, and keeps the presented version below as history (copy in `references/concept-e/g2-11-resolved/`, canvas `1793851377-765f`; presented copy unchanged in `g2-11/`).
- **No change to:** production Flutter code, hosting, Supabase, sign-in or calendar configuration.
- **Tablets (for the Round 2 checklist):** a tablet's routes follow whichever layout Round 2 gives it (compact or wide column of the table); multi-window keeps per-window history (unverified with go_router); universal / App Links not built.
- **Classification:** RESOLVED (APPROVED).

### ED-098 · G2-12 presented: duplicate screens, re-baselined
- **Date:** 2026-11-05. Decision board `E-G2-12` (canvas `1793851377-765f`; copy in `references/concept-e/g2-12/`). No E board changed.
- **Already settled by later decisions (no question):** minimal Everything else → the real root (ED-081, ED-084); one task surface (ED-086, ED-089); Wake Up / Wind Down in Your day with one dial, control and test-alarm component (ED-083, ED-084); Routines' own page, address `/settings/routines` (ED-080, ED-097); one Month grid, three ways in (ED-075); Need more time, one sheet (ED-093); Layout switch entries (ED-067); Low-energy mode (ED-093); Add modes (ED-091); Today header vs the Workspace (ED-073).
- **Kept as several doors to one screen:** Add vs the Inbox field (justified variant, shared parser), Notification health, Default alerts, Account and sync, Feedback / What's new / Wake Up explainer, Export.
- **Verified in code:** `DayReviewBody` is shown in a sheet (`day_review.dart`, Today ⋯), a page (`day_review_screen.dart`, `/review`, the Wind Down tap) and inline at Wind Down (`today_prompt.dart`). Inbox Schedule (`schedule_sheet.dart`: two free slots today, one tomorrow) leads to Pick a time… (`pick_time_sheet.dart`, `ThreadPicker`); Move on a task (`sheet_actions.dart`) opens a change-day month that keeps the time; `ThreadPicker` is shared with Add's When step. The weekly review is titled "This week" (`weekReviewTitle`).
- **Three questions, drawn (new drawings in E's look; phone frames copied from E-Phones F1 and F5):**
  - **Q1 Day review:** one surface per platform: a sheet on phones for every entry (the notification included), the Workspace's Review place on Full Mac/web with Day review and Week in review side by side, the right column on minimal Mac/web. All entries kept; `/review` stays; no new route.
  - **Q2 Scheduling and Move:** one picker (free-time suggestions, then day chips and the ThreadPicker), a sheet on phones and a popover on Mac/web, used by Inbox Schedule, Move, Move To… ⇧⌘M and the screen-reader route for drag (G2-7). Drag still places directly; ⌘↩ unchanged.
  - **Q3 Naming:** "This week" → "Week in review" (Mac "Week in Review"), labels only, so it stops reading like the Week view.
- **Options:** A, all three (recommended); B, Q1 and Q2 only; C, no further merges. No option removes an entry point.
- **Tablets (recorded, not drawn):** review as a pane beside the day on iPad landscape and Android expanded; picker as a popover / side sheet.
- **Classification:** PROPOSED / AWAITING OWNER ANSWER.

### ED-099 · G2-12 approved: option A, duplicate screens consolidated
- **Date:** 2026-11-05. Owner, in this session: "I approve G2-12 Option A — Consolidate Duplicate Screens, including all three recommendations shown on E-G2-12." Supersedes the open status in ED-098; ED-098 is not edited.
- **Q1 · One Day review.** One body and one behaviour (DayReviewBody: done count, "Move the rest to tomorrow?", sleep line), presented per platform:
  - **iPhone:** a sheet (large detent) for every entry. **Android:** an M3 bottom sheet; predictive Back closes it first.
  - **Full Mac and web:** the Workspace's Review place (sidebar Review, ED-080). Day review and Week in Review sit side by side, each with its own heading and ‹ › stepping (days, weeks).
  - **Minimal Mac and web:** the Day column, like a task (ED-089); ✕ or Esc returns to the Day; the main pane stays on Now.
  - **Minimal phones:** the same sheet without the Week in review row (doc 14 hides the weekly prompt in minimal).
  - **Entries kept (all):** Day menu › Review the day (phones; Mac "Review the Day"), the Wind Down prompt on Today (stays inline with its one action; its tap opens the review), the Wind Down notification (opens `/review`, as built in `notification_responder.dart`), sidebar Review (Full wide), View › Reviews and the finder (minimal wide), ⌘K. No review feature, data or history is removed; past days stay reachable with ‹.
- **Q2 · One When picker.** One workflow for Inbox Schedule, Move (task sheet, swipe) and Move To… (⇧⌘M, web `m`), and the screen-reader route for drag (G2-7): free-time suggestions first, then day chips (Today, Tomorrow, next days, Date…) and the ThreadPicker for the exact time. Phones: a sheet; Mac and web: a popover with typed date and time fields (Tab between them; arrow keys move the time; Return places; Esc closes). Minimal Move keeps Tomorrow / Later on the task; "a time…" opens this picker.
  - **Rules unchanged:** drag still places directly; ⌘↩ places in the first free gap; overlaps are allowed (ADR-0015); pinned tasks do not move; a repeating task asks which ones first (ED-086); every placement has Undo; the task keeps its length.
- **Q3 · Naming.** The weekly reflection is **Week in review** (Mac title case "Week in Review"), distinct from the Week calendar view (⌘3, `/#/week`). Labels only: `weekReviewTitle` "This week" → "Week in review" in en, de, es, fr when built. It is also the Today prompt caption on the week's last day (built), which keeps that entry. No route renamed: `/review` stays; Week in review has no address of its own.
- **Merged (canvas, labels and new rows only):**
  - `E-Phones`: Day ▾ insets 3 and 6 read Week in review; F3's Move line; new row "Day review and the When picker" (iPhone and Android review sheets, Week in review, iPhone Move, Android Inbox Schedule). Frame 9460 → 10520.
  - `E-FullA-v2`: Mac Day menus (two) and the web Day menu read Week in Review / Week in review; new row "Review and the When popover" (the Review place, the popover). Frame 5010 → 5740.
  - `E-Minimal`: new row "Day review (minimal, Mac and web)" (the Day column); Move caption; note text renamed. Frame 3680 → 4320.
  - `E-PhonesMinimal`: two captions (Move "a time"; Wind Down card opens the review sheet).
  - `E-Map`: two feature rows (Day review; Week in review); "Decided since" line; heading "Group 1 and Group 2". Frame 4240 → 4320.
  - `E-G2-12` is kept unchanged below a new title as the historical review board.
- **Verified:** every entry in Q1 and Q2 is present on the merged boards; menus differ from the pre-merge copies only by the rename; no tag or id errors added; each board measured within its frame. Built code: DayReviewBody, ThreadPicker, `schedule_sheet.dart`, `pick_time_sheet.dart`, `week_review_sheet.dart`, `today_menu.dart`, `today_prompt.dart`, `notification_responder.dart`, `AppRoutes.review`. No production code changed.
- **For implementation (later, not now):** one review presenter that picks sheet / Review place / Day column by layout; Schedule and Move share one picker (suggestions from `slot_fit.dart`, ThreadPicker below); the Move tile's change-day month becomes the picker's Date… chip; one string. Tests: each entry opens the review; Schedule, Move and Move To… open the picker; Undo after each placement; screen-reader labels on suggestions and the thread slider; keyboard-only on Mac and web.
- **Tablets (Round 2 checklist, not drawn):** iPad landscape and Android expanded: the review as a pane beside the day; iPad narrow Split View and Android compact: the phone sheet; the picker as a popover from the row (iPad) or a side sheet (Android expanded); a drop from the Inbox still places directly; foldables follow the window class, never the posture alone.
- **Classification:** RESOLVED · APPROVED · DRAWN.

### ED-100 · Switching Full ↔ Minimal mid-action (workflow rule)
- **Date:** 2026-11-05. **Owner, in this session:** "When switching between Full and Minimal, cancel an unfinished drag or multi-selection without applying unintended changes. Preserve the selected date, open task and already-saved edits. Keep Undo available for previously committed actions. Do not discard unsaved text or other editing state without appropriate handling." Settles the item ED-096 proposed and ED-097 did not restate; ED-096 and ED-097 are not edited.
- **Rule (every platform, both directions, every way to switch: Day menu, View menu, ⌘K, Settings, a deep link never switches):**
  - **Unfinished drag:** cancelled. The block returns to where it was; nothing is written; no Undo entry is created because nothing changed.
  - **Multi-selection:** cleared without applying anything. A batch action already confirmed before the switch stays done and keeps its Undo.
  - **Kept:** the selected date, the open task (it reopens in that layout's task surface: sheet, inspector or Day column), and every edit already saved (autosave included).
  - **Undo:** the stack survives the switch; ⌘Z / the Undo toast can still undo actions committed before it.
  - **Unsaved text and other in-progress editing** (a title or note being typed, an open picker with a choice not yet applied, Add with text in it): not dropped silently. The draft is kept and shown again in the new layout's surface; if that surface cannot show it, the switch first asks (Keep editing / Discard) with Keep editing as the default and Esc / Back choosing it.
  - **Proposal sheets** (ProposalSheet: break down, rebalance, brain dump, routine drop) are not accepted by a switch; they stay open or reopen, still unwritten (proposal rule, CLAUDE.md §11).
- **Not drawn** (behaviour only); no board changes. Tablet: same rule when a window resize changes the width class.
- **For implementation (later, not now):** the switch is a View-level change through `LayoutPolicy` (ADR-0016); drag and selection controllers listen for it and cancel; drafts live in the editor's state, not in the layout. Tests: switch during drag (nothing written), during selection (nothing applied), with an open task (reopens), with an unsaved title (kept or asked), Undo after the switch.
- **Classification:** RESOLVED · APPROVED (behaviour) · NOT DRAWN.

### ED-101 · Group 3 opened; G3-1 presented: scale direction
- **Date:** 2026-11-05. Owner: "Yes, start Group 3 — Visual and Interaction Consistency", one decision at a time, corrections kept apart from new proposals, focused comparisons before any change to approved screens, newly drawn screens flagged until reviewed.
- **Board `E-G3-1`** (canvas `1793877679-7b49`; copy in `references/concept-e/g3-1/`). No E board changed. Option A frames are copies of E-Phones F1 (iPhone Today) and F5 (Android Today); B and C are the same copies with only the thread list changed. Chrome untouched.
- **Kind:** a new design proposal for approved screens, not a correction (the question was offered on 3 Nov, thread 9acf09f2, and never answered; ED-025, ED-026).
- **Options:**
  - **A · Keep large:** as drawn (dots 32/34, now ring 40 in a 72 card, rows 48–54, names 17/700).
  - **B · C confidence:** dots 26/28, names 15/700, rows 44–46, one hero now row (ring 58, title 23/800, 108 tall), 44 px gaps around the now group.
  - **C · Both (recommended):** A's rows unchanged, plus B's hero now row and gaps.
- **Measured on the board (iPhone, task rows fully above the tab bar):** A 6, B 6, C 5. Targets 44 × 44 pt in all; B's rows sit at the 44 pt minimum.
- **Mac/web Full:** C changes nothing on the Workspace grid (sized by time; the now block already has a 38 px ring); B would shrink block dots and names (not drawn). **Minimal:** unchanged in every option (the large now-dot is the hero already; G3-2).
- **Tablets (recorded, not drawn):** the same sizes by width class; the hero stays in the Today list in two-pane layouts; foldables follow the window class.
- **Also still open from that thread:** the owner's comment ended with "what" — possibly cut off.
- **Classification:** PROPOSED / AWAITING OWNER ANSWER.

### ED-102 · Merged drawings not yet visually reviewed (flagged)
- **Date:** 2026-11-05. Owner asked that drawings made at merge time, which never appeared on a decision board the owner reviewed, are flagged so they are not taken as fully approved.
- **Flagged on the boards** with an amber tag "Drawn at merge · awaiting your visual review" (tag only; nothing else changed; E-Minimal still 4320 tall, content ends at 4280):
  - `E-Minimal` · Day review in the Day column (ED-099). The behaviour is approved; the drawing was not on `E-G2-12`. Point to check: it shows the Week in review row, while minimal phones hide it (ED-099).
  - `E-Minimal` · Web Day menu (minimal) (ED-093). `E-G2-9` drew the minimal menu in the Mac style only.
- **Not flagged (seen on a decision board before approval):** every other ED-084 to ED-099 drawing, including the E-Phones review sheets, Week in review and When picker, and the E-FullA-v2 Review place and popover (all on `E-G2-12`); the web task column (`E-G2-6-Review` frame 6). Label-only merges (ED-095 keys, ED-097 routes, ED-099 rename) are text changes, not drawings.
- **G3-1's B and C drawings** are new proposals on `E-G3-1` and stay for review until answered.
- **Classification:** RECORDED. A flag is removed only when the owner reviews that drawing.

### ED-103 · G3-1 option C revised to the owner's sizes; ED-100 clarifications accepted; flags kept
- **Date:** 2026-11-05. **Owner, in this session:** "For G3-1, before I choose make this edit Option C — Both. … For the current task, use 45 pt/dp ring, current task title, use 19pt Bold. Space around current task 32pt. If it fits in the upcoming task visible at 6 then let it be if not then leave it at 5. Ensure the enlarged ring and icon remain properly aligned with the Dottoday thread. Check long titles, compact phones, large accessibility text, scrolling and touch targets. Do not introduce clipping or overlap. Present to me for review and approval."
- **Option C on `E-G3-1` replaced** (not layered; option A and B unchanged): now ring 45 (5.5 px stroke, 24 px icon; was 40 / 5 / 22 in A and 58 in the first C); title 19/700, line height 24 (A 18/700); time line unchanged (14); card 80 tall on iPhone, 82 on Android (min-height with 8 px padding, so it grows with its text; radius unchanged); 32 px above and below the now group (A 28). Rows, dots and names exactly as A.
- **Fit:** six task rows fully above the tab bar on iPhone 390 and Android 412, the same as A (28 pt and 34 dp to spare). The owner's condition "6 if it fits" is met; no fallback to 5 needed.
- **Thread alignment:** the ring stays in the 48 px dot column, so its centre is on the thread centre line (measured offset 0 in every frame); the segments above and below meet the ring; the ring is vertically centred on its card at every size. A 2x close-up with the centre line is on the board.
- **Checks drawn and measured (all option C):** compact iPhone 375 × 667, compact Android 360 × 640 (as opened and scrolled to now), long title on the 375 viewport (wraps to four lines, card grows to 130), 200 % text on iPhone and Android (rows use minimum heights; hero title wraps to two lines), scrolled iPhone. In all 13 phone frames: no row overlaps, no clipped or cut-off text, targets 44 pt / 48 dp.
- **Finding, not part of G3-1:** Today opens at the top of the day, as built. On a 360 × 640 Android phone at 10:42 the current task starts under the floating Day and Add controls in every option (A only 12 dp higher). The fix is a behaviour ("Today opens scrolled so the current task is in view"; the inventory already lists "scrolled to now" as an undrawn state). Recorded as an open item; nothing assumes it.
- **Correction on the board:** option B's Android rows were 44 dp with 48 dp targets inside (targets poked out of their rows). B's Android rows are now 48 dp. B's 58 px ring is held at full size (it had been squeezed by its column). Both are drawing fixes to B, not changes to the proposal.
- **ED-100 clarifications accepted by the owner:** "unaccepted proposals are never committed by switching modes, and responsive transitions must not cause unintended changes. Preserve saved data, drafts and editing context." ED-100's text already says both; it is now APPROVED as written (§9.14).
- **Flags (ED-102) kept:** the two E-Minimal drawings stay tagged and will be presented for visual approval separately, not folded into any other decision.
- **The 3 Nov comment ending in "what":** the owner says it is not a new design requirement. Closed; no change.
- **Classification:** G3-1 PROPOSED / AWAITING OWNER ANSWER (C revised). ED-100 RESOLVED · APPROVED. ED-102 flags unchanged.

### ED-104 · G3-1 approved: option C · Both, revised; merged into E-Phones Today only
- **Date:** 2026-11-05. **Owner, in this session:** "I approve option C · Both, revised. Apply this decision only to the Full phone Today presentation shown in G3-1. Do not automatically rescale E-Minimal, E-FullA-v2 or other approved layouts. Record tablet adaptations for Prompt D Round 2. Preserve historical designs."
- **Decision:** on Full phone Today the current task has a 45 pt/dp ring (5.5 px stroke, 24 icon), a 19/700 title (line height 24) and a card of 80 pt (iPhone) / 82 dp (Android) minimum that grows with its text; 32 above and below the now group. Every other row, dot and name keeps the large scale (ED-025). Six task rows fit above the tab bar, as before.
- **Merged into `E-Phones`** Frame 1 (iPhone Today) and Frame 5 (Android Today) only, from the same code that drew the approved option, and checked to match it exactly; the rest of E-Phones is unchanged, byte for byte. Each frame's caption gains "Approved · G3-1 (ED-104)". Frame sizes unchanged (E-Phones 2760 × 10520).
- **Not changed (owner's instruction):** E-Minimal, E-FullA-v2, E-PhonesMinimal (the phone minimal Today tab keeps its 40 now ring), E-Workspace and every other board. Six dimmed Today copies under sheets on E-Phones (Add modes ×2, Day review and the When picker ×4) still show the 40 ring; they are left as drawn and listed as a consistency item for the owner to decide (not changed automatically).
- **History kept:** E-Phones before the merge is in `references/concept-e/v1.9-working/` (identical copy) and `E-G3-1` stays on the canvas as the review board, both unchanged.
- **Tablets (for Prompt D Round 2, not drawn):** iPad and Android tablets in a compact window (Split View, Slide Over, compact multi-window) use the phone Today exactly, current task included. At medium and expanded widths the thread pane keeps the same 45 ring, 19/700 title and 32 gaps (a width class never shrinks rows); the card widens with the pane, and the title line length is capped by the pane, not stretched. In two panes the current task stays in the Today list; the detail pane does not repeat it. Foldables follow the window class, not the posture. Whether tablet Full uses the phone thread or a Workspace-style grid is decided in Round 2; if a grid, G3-1 does not apply there (the Workspace was left unchanged). Unverified: Dynamic Type / font scale above 200 % on iPad, and pointer hover on the card.
- **Still open from the checks (separate):** Today opening scrolled to now (ED-103).
- **Classification:** RESOLVED · APPROVED · MERGED (Full phone Today only).

### ED-105 · G3-2 presented: one drawing for the orb
- **Date:** 2026-11-05. Owner: "After completing and verifying G3-1, present G3-2 for my review."
- **Board `E-G3-2`** (canvas `1793888468-4491`; copy in `references/concept-e/g3-2/`). No E board changed. The "as drawn" orbs are cut unchanged from E-PhonesMinimal and E-Minimal.
- **Kind:** a consistency correction between approved boards (not a new proposal); nothing changes until the owner chooses.
- **Found:** ring, track, arc, inner disc and shadow are the same SVG on all four. Only the centre type differs: iPhone 236 / 800 · 84 px; Android 228 / 800 · 80; Mac 280 / 700 · 76; web 240 / 700 · 64 (icon 20). The split comes from Concept C (C-PhonesMinimal 800, C-Minimal 700); E copied it. The web orb already has the icon and shadow, so ED-052's offer is the reverse direction.
- **Options:** A · one drawing everywhere: the phones' centre type at the same proportion (numeral 0.36 of the orb, 800, icon and label scaled): Mac 100 px, web 85 px; phones unchanged (recommended). B · plainer web orb (ED-052): no icon, no shadow on web. C · keep as drawn.
- **Checked:** contrast 14.2:1 (numeral) and 5.2:1 ("min left"); under A the centre stack fits the inner disc (Mac 142 of 179, web 127 of 153), also with "min left" at 200 %.
- **Tablets (recorded, not drawn):** minimal on tablets sizes the orb by window; under A the centre type keeps the 0.36 proportion; Round 2 checklist.
- **Classification:** PROPOSED / AWAITING OWNER ANSWER.

### ED-106 · G3-2 approved: option A, one orb drawing; merged into E-Minimal
- **Date:** 2026-11-05. **Owner, in this session:** "A · One drawing".
- **Decision:** the orb is one drawing on every platform. Same SVG (unchanged); centre type at the phones' proportion: numeral 800, −0.05 em, 0.36 of the orb; icon and "min left" scaled. iPhone 236: 84 / icon 22 / 13; Android 228: 80 / 22 / 13; Mac 280: **100 / 26 / 15**; web 240: **85 / 22 / 13**. Orb sizes, ring, arc, track, shadow and layout unchanged.
- **Merged into `E-Minimal`:** only the centre of the Mac and web orbs, plus one caption line ("Approved · G3-2 (ED-106)"); the board's note that E-Minimal follows "orb numeral 700" is removed. Checked: the merged orbs match option A value for value; nothing overlaps them; stack 149 of 179 px (Mac) and 127 of 153 (web). E-PhonesMinimal unchanged (already A). Not touched: Full phone Today, the compact rings (Now mini window, task sheet header), the E-Minimal Day column, the two flagged drawings, E-Focus (v1.0 archive).
- **Correction to `E-G3-2` (my drawing error):** as first presented, option A's Mac and web orbs were drawn with an invalid font declaration (arguments in the wrong order), so they rendered lighter than the 800 the board described. The board's text and table were right; the picture was not. The board is corrected and the as-presented file is kept in `references/concept-e/g3-2/` as history. The owner chose A from the board as presented, so the merged orbs are flagged for a visual check (ED-102 list).
- **Tablets (Round 2):** minimal on tablets sizes the orb by window; the centre type keeps the 0.36 proportion.
- **Visual check:** the owner reviewed the corrected orbs on 2026-11-05: "Looks right". Flag removed.
- **Classification:** RESOLVED · APPROVED · MERGED · VISUALLY REVIEWED.

### ED-107 · Visual review presented: the two flagged E-Minimal drawings and the six dimmed Todays
- **Date:** 2026-11-05. **Owner:** "Let's review the flagged drawings first, before proceeding to G3-3 … Show their actual rendered designs and explain how they fit the already-approved Concept E behavior. Do not silently treat them as approved … Also identify the six dimmed Today examples on E-Phones that still use the old 40 pt current-task ring. Propose the precise consistency correction needed to match G3-1, without changing their other visual elements. Keep the automatic-scroll-to-current-task question open."
- **Board `E-V1`** (canvas `1793893513-fe26`; copy in `references/concept-e/visual-review-1/`). Every "as drawn" item is cut unchanged from the live boards. No E board changed.
- **1 · Day review in the Day column (E-Minimal, ED-099):** fits ED-099 and ED-089 (one review body; the Day column like a task; ✕ / Esc back to the Day; main pane stays on Now; entries Day › Review the Day, View › Reviews, ⌘K, the Wind Down notification, /review). **One mismatch:** it shows a "Week in review" row, while ED-093 keeps Week in Review in Full and ⌘K for minimal Mac and web and ED-099 hides it on minimal phones (doc 14). **Proposed correction:** remove that row only.
- **2 · Web Day menu (minimal, ED-093):** the same nine commands as the minimal Mac menu, in Full's web groups and recipe; Rebalance…, Pick today's one thing…, Week in review and Plan / Reality left out as ED-093 says. **One mismatch found in this review:** the key hints resolved later in G2-10 (ED-095: Brain dump ⇧N / ⇧⌘N, Show less / everything ⇧L / ⇧⌘L) are shown in Full's menus but missing from both minimal menus (web, and the approved Mac menu-bar Day). **Proposed correction:** add those two hints to each; nothing else changes.
- **3 · Six dimmed Todays on E-Phones:** (1) Add modes · iPhone the proposal; (2) Add modes · Android FAB menu › Brain dump; (3) Day review and the When picker · iPhone Day review sheet; (4) Android Day review (M3 sheet); (5) iPhone Move (the When picker); (6) Android Schedule from the Inbox. **Proposed correction:** the G3-1 now card only (ring 40 → 45, stroke 5 → 5.5, icon 22 → 24, title 18 → 19/700 line height 24, card 72 / 74 fixed → 80 / 82 minimum with 8 px padding, gap rows 28 → 32), from the same code as the approved E-Phones Today. Measured on the board: rings 45, cards 80 / 82, ring on the thread (offset 0), no row overlaps. Sheets, scrim, chrome and other rows unchanged.
- **Still open, later:** Today opening scrolled to the current task (ED-103).
- **Also on the canvas:** a board `E-G3-2-Size` ("G3-2 follow-up · orb centre size steps on Mac and web (owner: 'Adjust size')"), published by another writer after canvas `1793891919-04e5`. It is not from this session and changes no E board; this session left it untouched.
- **Classification:** PRESENTED / AWAITING OWNER REVIEW. The ED-102 flags stay until the owner answers.

### ED-108 · Visual review: all three corrections approved and merged; flags cleared
- **Date:** 2026-11-05. **Owner, in this session:** "Apply all three" (the corrections on `E-V1`, ED-107).
- **Merged (canvas `1793894587-d7ac`; copies in `references/concept-e/v1.12-working/`; the pre-merge copies are `v1.11-working/E-Minimal` and `v1.10-working/E-Phones`, both unchanged):**
  1. **E-Minimal · Day review in the Day column:** the Week in review row removed; its note now says Week in Review stays in Full and ⌘K in minimal (ED-093), as on minimal phones (ED-099).
  2. **E-Minimal · minimal Day menus:** key hints added: web Brain dump… ⇧N and Show everything ⇧L; Mac menu-bar Brain Dump… ⇧⌘N and Show Everything ⇧⌘L (ED-095). The web caption "no keys shown" now names the hints.
  3. **E-Phones · six dimmed Todays** (Add modes ×2; Day review and the When picker ×4): the G3-1 now card from the same code as E-Phones Today (45 ring, 24 icon, 19/700 title, 80 / 82 minimum card, 32 gaps). Their sheets, scrim, chrome, captions and other rows unchanged.
- **Flags:** both ED-102 tags replaced with "Reviewed · ED-108". No drawing on the E boards is awaiting review now.
- **Checked:** the six lists equal the `E-V1` corrections exactly; E-Phones outside those lists is byte-identical; E-Minimal differs only in the lines above; all eight Today lists measure ring 45, card 80 / 82, ring on the thread (offset 0), no row overlaps; E-Minimal content 4273 of 4320, E-Phones 10497 of 10520; no duplicate ids.
- **Still open:** Today opening scrolled to the current task (ED-103), for a later interaction decision.
- **Classification:** RESOLVED · APPROVED · MERGED · VISUALLY REVIEWED.

### ED-109 · G3-3 presented: content typeface
- **Date:** 2026-11-05. Owner: "After these visual-review items are resolved, proceed to G3-3 — Content Typeface."
- **Board `E-G3-3`** (canvas `1793894754-fa5d`; copy in `references/concept-e/g3-3/`). No E board changed. Option A frames are E-Phones Frame 1 and Frame 5 as they are now; B and C change only the content font (chrome keeps its system font, K6).
- **Kind:** a brand decision (DESIGN_PRINCIPLES §4); it sets the direction that Step 9 freezes. Nothing in the app changes now.
- **Facts:** every E board draws content in Manrope since ED-012; the built app bundles Inter (`assets/fonts/Inter-Variable.ttf` with `Inter-OFL.txt`; `DotType.fontFamily`). Both are SIL OFL 1.1 variable fonts with tabular numerals. Measured widths against Manrope: Inter about 2 % wider (times 5 %); SF about 8 % narrower; Roboto about 6 % narrower (times 2 % wider). In the board's frames no option causes overlap or clipping.
- **Options:** A · Manrope for content (recommended). B · Inter, as built. C · each platform's system font for content.
- **If A (later, at implementation):** swap the bundled font file and its licence, update `DotType`, re-run goldens; an ADR because it changes the brand face; no new package.
- **Tablets:** same face and type roles; recorded for Round 2.
- **Classification:** PROPOSED / AWAITING OWNER ANSWER.

### ED-110 · G3-3 approved: Manrope is Dottoday's content typeface
- **Date:** 2026-11-05. **Owner, in this session:** "For G3-3, I approve Option A — Manrope as Dottoday's content typeface. Please retain Manrope across Concept E for task names, descriptions, times, the large Now-dot numbers, task sheets and other branded content. Continue using appropriate native system typography for platform chrome …" Requirements: keep the hierarchy, weights, spacing and geometry; no unnecessary visual change; document the scale and text-size behaviour; record implementation checks and tablet/foldable notes; keep history and the unrelated `E-G3-2-Size` board untouched; no Flutter code, no commit; approval before merging new visual changes.
- **Boards:** no E board changed. Every E board already draws content in Manrope (ED-012), so the approved hierarchy, weights, spacing and geometry stand as drawn. Only the canvas title of `E-G3-3` changed (now "resolved: A"); the board file is unchanged and kept as history. Snapshot in `references/concept-e/g3-3-resolved/`.
- **Recorded in the rules:** §3.1 (family resolved); §3.4 text size and accessibility (iOS Dynamic Type, Android non-linear font scale, Mac open, web rem; wrap not shrink; minimum heights; orb numeral sized to the orb; Bold Text); §3.5 implementation checks (licence, glyph coverage for en/de/es/fr and fallback scripts, international layout, tabular numerals, weights, font loading, screenshot regression, size, ADR); §3.6 tablets and foldables (Round 2).
- **Doc correction:** rules §3.2 still gave the phone now-row title as 700 18; since ED-104 it is 700 19/24 on Full Today (18 stays in Minimal's Today tab). The table now says so. The boards were already right.
- **Choices made where the specs were silent (CLAUDE.md §10; open for the owner):** Bold Text draws 400/500 content at 600; the 7 single-line Calendar rows on E-Phones that end in an ellipsis show up to two lines at large text sizes.
- **Found while recording (correction, not applied):** some text that names or times the person's task is drawn in the system font inside phone sheets: Android Edit and Schedule sheets (Roboto), iPhone sheet headers, When picker and Move time choices (SF), and two next-task times on E-PhonesMinimal. This widens I12 / CR-005. A boundary rule is proposed in rules §3.7 (task names and task times Manrope everywhere; sheet headings, control labels, settings values and picker digits stay system). **Not merged:** it is a visual change and needs the owner's approval first.
- **Implementation (later, not now):** replace `Inter-Variable.ttf` and `Inter-OFL.txt` with Manrope and its licence; `DotType.fontFamily`; a new ADR for the brand typeface (ADR-0007's history is not rewritten); goldens re-baselined against the boards; no new package.
- **Classification:** RESOLVED · APPROVED. No visual change merged.

### ED-111 · G3-4 presented: iOS switch colour when on
- **Date:** 2026-11-05. Owner: "After recording and verifying G3-3, please present G3-4 with its visual comparisons and recommendation. Stop for my approval before merging new visual changes."
- **Board `E-G3-4`** (canvas `1793914701-e1ae`; copy in `references/concept-e/g3-4/`). No E board changed.
- **Shown:** the four iPhone frames on E-Phones with a switch, cut unchanged (Add a task "Add another"; Wake Up and Wind Down; alarm off; weekday alarm: 8 switches on, 1 off). Option B is the same frames with only the 8 on-tracks changed to iOS system green `#34C759`. 3× close-ups on the row background, also with iOS On/Off Labels.
- **Measured:** on track against its row `#FFFDF9`: teal 7.16:1, green 2.19:1 (on the Add sheet `#F6F1EA`: 6.47 / 1.98). White knob against the track: 7.27 / 2.22. WCAG 1.4.11 asks 3:1 for controls. The off track `#E3DDE6` is 1.31:1 in both options (shown by the knob, as native iOS; not part of G3-4).
- **Options:** A · teal, the app accent (as drawn; recommended). B · iOS system green.
- **Unaffected:** Android M3 switch (already teal); Mac and web toggles (drawn off only); dark mode follows G4-6 (iOS dark green would be `#30D158`).
- **Tablets:** iPad uses the same switch and colour; recorded for Round 2.
- **Classification:** PROPOSED / AWAITING OWNER ANSWER.

### ED-112 · G3-4 approved: Dottoday teal for active iOS switches; G3-C1 and two accessibility checks tracked
- **Date:** 2026-11-05. **Owner, in this session:** "For G3-4, I approve Option A — Dottoday teal for active iOS switches. Keep the eight iOS switches as currently drawn in Concept E." Preserve: native iOS switch shape, animation and interaction; the approved teal; sufficient contrast between active track, white thumb and surrounding surface; support for iOS On/Off Labels and accessibility settings; the existing Android switch styling. "No visual changes to the approved iPhone switch designs are needed. For future dark-mode designs, verify contrast separately rather than assuming the light-mode teal works on every surface."
- **Boards:** no E board changed. `E-G3-4` kept as history; its canvas title now says "resolved: A". Snapshot `references/concept-e/g3-4-resolved/`.
- **Rules:** §4.2 `switchOn` token (teal, measured contrast, On/Off Labels, Android unchanged, dark mode checked separately under G4-6).
- **G3-C1 (tracked separately):** task names and times drawn in the system font inside phone sheets (rules §3.7, ED-110). The owner agrees with the direction (Manrope for branded task content, native fonts for controls) and wants a visual comparison before merging. Open; nothing changed.
- **Accessibility verification items (proposals, not approved layouts):** A11Y-V1 Bold Text draws 400/500 content at 600; A11Y-V2 the 7 single-line Calendar rows on E-Phones may show two lines at large text sizes. Neither changes an approved screen at default settings; both are checked before they count as approved (rules §3.4).
- **CR-099:** the switch part is resolved; the keyboard parts (teal return key, ED-032) stay open.
- **Classification:** RESOLVED · APPROVED (G3-4). No visual change.

### ED-113 · G3-5 presented: hover lift on a web block
- **Date:** 2026-11-05. Owner: "After recording G3-4, present G3-5 with its comparison and recommendation, then stop for my approval."
- **Board `E-G3-5`** (canvas `1793916412-27e3`; copy in `references/concept-e/g3-5/`). No E board changed.
- **Found:** one block lifts: Lunch under the pointer in E-FullA-v2's web Plan Day frame (`0 0 0 1px rgba(36,31,43,.10), 0 8px 18px rgba(36,31,43,.10)`; the same block is in the v1.0 `E-Workspace`). Every other block is flat (`.blk` has no shadow). E-Minimal web shows the actions button on hover, with no lift.
- **Shown:** the frame as drawn (A) and with only Lunch flattened (B: hairline and a `#F5F1EB` tint, a value proposed on the board); 2× close-ups at rest, on hover, and dragged over Pick up parcel. The drag drawings are for comparison only; motion stays open (rules §7.5).
- **Options:** A · keep the lift on hover and while dragging only, never at rest (recommended: a picked-up block is a floating surface, which ED-022 allows, and it stays readable over overlapping blocks). B · flatten it (tint and hairline only).
- **Both options:** keyboard focus stays the teal ring; touch has no hover; forced colours remove all box-shadows, so blocks need a transparent border (implementation check); reduced motion shows the lift without animation.
- **Platforms:** Mac follows web (same pointer grid); iPad and Android tablets with a pointer follow it (Round 2); phones none.
- **Classification:** PROPOSED / AWAITING OWNER ANSWER.

### ED-114 · Canvas edits saved from the page (observed 2026-11-05)
- Version `1793916380-780c` of the canvas index was saved from the canvas page, not from this session. Compared with this session's last version: `E-G3-2-Size` was removed from the canvas and its file is no longer published; the `E-Phones` frame height became 8000 (its content runs to 10497, so the lower frames sit outside the frame on the canvas); the `E-Phones` and `E-Minimal` titles were cut at 120 characters. Every E board file is byte-identical to before.
- This session kept those edits (its G3-4 and G3-5 changes were applied on top) and reversed none of them. The repo snapshots still hold the full `E-Phones` board (`v1.12-working/`).
- **Classification:** NEEDS OWNER CONFIRMATION (whether the E-Phones frame height and the removal of E-G3-2-Size were intended). **Update (ED-115):** the owner asked to restore the E-Phones height; done. E-G3-2-Size not restored.

### ED-115 · G3-5 revised with the owner's hybrid option C; E-Phones frame height restored
- **Date:** 2026-11-05. **Owner:** "Before I approve G3-5, I'd like a hybrid Option C. I prefer the calmness of Option B for ordinary pointer hover, but I prefer Option A's clearer separation when a task is actively being dragged." Draw and compare: rest flat; hover B's tint and hairline, no shadow; active drag A's soft lift above overlapping blocks; keyboard focus the approved teal ring. Same E-FullA-v2 calendar, colours, dimensions and content; nothing merged. "Please also restore E-Phones' canvas frame height so its approved content is fully visible."
- **Board `E-G3-5` revised** (canvas `1793919161-8dfd`; copy in `references/concept-e/g3-5-option-c/`; the board as first presented is kept in `g3-5/`):
  - **Pointer hover:** the real web Plan Day frame for A (as drawn), B and C, at 70 % (designs 1280 × 800); only Lunch differs.
  - **Drag over the overlap:** the same frame with the Day menu closed (starting a drag closes menus) and Lunch dragged to 10:30 across Deep work and Call with Sam: A and C lifted (`0 0 0 1px rgba(36,31,43,.10), 0 8px 18px rgba(36,31,43,.10)`, z above the overlap), B flat.
  - **Close-ups at 1.4×,** cropped from those frames, not redrawn: rest, hover, drag, and keyboard focus (Deep work's teal ring, the same in all three).
  - Facts compare A, B and C; **recommendation C** (calm hover, clear drag, shadows only on a block that is really lifted). The hover tint `#F5F1EB` is a proposed value; motion stays open (§7.5).
- **If C is chosen (not done):** Lunch's hover look on E-FullA-v2 becomes the tint and hairline; the drag look is recorded in the rules.
- **E-Phones frame:** the canvas index height is restored to 10520 (content ends at 10497). The board file is unchanged (byte-identical to `v1.12-working/`). The 120-character title cuts from ED-114 are kept; E-G3-2-Size stays as the page left it (removed).
- **Classification:** PROPOSED / AWAITING OWNER ANSWER (G3-5). E-Phones height: done.

### ED-116 · G3-5 approved: option C · Hybrid, merged into E-FullA-v2
- **Date:** 2026-11-06. **Owner, in this session:** "I approve G3-5 Option C — Hybrid. This is my final decision for the hover and drag appearance." Rules: resting flat, no shadow; pointer hover `#F5F1EB` tint and thin outline, no elevation; active drag A's soft lift, clearly above overlapping tasks; keyboard focus keeps the teal ring; reduced motion keeps clear feedback without animated lift; high contrast gets boundaries that do not depend on shadows; touch does not simulate hover. "Apply the approved hover appearance to Lunch on E-FullA-v2 and record the shared interaction rule for other eligible Workspace blocks. Do not change the grid layout, task sizes, typography, colors elsewhere or unrelated screens. Keep drag animation timing, scaling and haptics open for the later motion decision." The message ends mid-sentence ("Do not silently approve tho…"); read here as: do not treat the open motion items as approved.
- **Merged (canvas `1793919701-ad03`; copy in `references/concept-e/v1.13-working/`; the pre-merge E-FullA-v2 is byte-identical to `v1.9-working/E-FullA-v2.dc.html`):** E-FullA-v2 web Plan Day frame, Lunch: `box-shadow: 0 0 0 1px rgba(36,31,43,.10), 0 8px 18px …` → `box-shadow: 0 0 0 1px rgba(36,31,43,.10); background: #F5F1EB`. Caption line added: "Approved · G3-5 (ED-116)". Nothing else changed.
- **Checked:** the diff is those two places only; Lunch renders as the `E-G3-5` option C hover frame; no lift shadow remains on the board at rest or hover; content 5698 of 5740.
- **Rules:** §7.4 "Block hover and drag" (eligible blocks, the seven states); §7.5 keeps lift timing, scale and haptics open.
- **Not changed:** `E-Workspace` (v1.0 history) keeps its lifted Lunch; `E-G3-5` kept as history (title "resolved: C"); E-Minimal (hover shows the actions button) unchanged.
- **Classification:** RESOLVED · APPROVED · MERGED (looks); motion OPEN.

### ED-117 · G3-4 verification audit: designs PASS; documentation corrections R1–R5
- **Date:** 2026-11-06. **Owner:** asked for a read-only audit of G3-4, then "I approve all proposed documentation corrections R1–R5 from the G3-4 verification audit." Corrections are documentation only; the three Flutter gaps "must remain future implementation tasks, not changes authorized for this design phase."
- **Audit (canvas `1793919701-ad03`, every board rendered in full; E-Phones content 10497 of 10520):**
  - The 8 active iOS switches on E-Phones: Add a task sheet "Add another" (on `#F6F1EA`); Wake Up and Wind Down "Show the night on the day dot", "Ring like an alarm", "Snooze", "Wind Down reminder"; alarm off "Wind Down reminder"; weekday alarm "Ring on these days", "Wind Down reminder" (on `#FFFDF9`). All `#11615C`, 51 × 31, white 27 px thumb with a 2 px inset. The one off switch is `#E3DDE6`.
  - The colour is set inline on each switch (`background: #11615C`), equal to `accent`; recorded as `switchOn` in rules §4.2. Contrast as rendered: 7.16, 6.47, 7.27 (unchanged).
  - No other active E board has an on switch; system green appears only in option B of the historical `E-G3-4`. Android's 3 switches unchanged (E-Phones byte-identical to `v1.12-working`).
- **Corrections applied (documentation only):** R1 traceability G3-4 row (and a second stale G3-4 mention in the ED-028 row, found while verifying); R2 traceability G3-3 and G3-5 rows; R3 cross-reference under ED-041 (original text kept); R4 implementation checks on the `switchOn` row (rules §4.2); R5 the three known Flutter gaps recorded there as future implementation tasks.
- **Status of G3-4, four separate states:** design approval RESOLVED (ED-112) · design verification PASS (ED-117) · Flutter implementation NOT YET IMPLEMENTED / VERIFIED · dark-mode verification PENDING G4-6.
- **Not changed:** no board, no Flutter code, no Supabase, hosting or authentication configuration.
- **Classification:** VERIFIED · DOCUMENTATION CORRECTED.

### ED-118 · G3-6 presented: glass and vibrancy, approximated, native or solid
- **Date:** 2026-11-06. Owner: "After verification, present G3-6 with its visual alternatives and your recommendation, and stop for my approval before merging any new design changes."
- **Board `E-G3-6`** (canvas `1793921025-dfd5`; copy in `references/concept-e/g3-6/`). No E board changed.
- **Shown:** E-Phones iPhone Today (3 glass elements: Day chip, sync and profile capsule, tab bar) and Android Today (tonal Day button and navigation bar), scrolled 60 px so tasks sit under the chrome; each as drawn and with only the translucent backgrounds made opaque (proposed fallbacks: iPhone `#F7F3ED`, Android bar `#F2EBE2`, Day button `#EFE7DB`). The E-FullA-v2 Mac sidebar (blur 30 over 78 % tint) as drawn and solid `#EFE7DB`. 2× close-ups of the bottom chrome.
- **Found:** over the light day the glass and the solid look differ little; the difference grows over coloured content. The built app has no `BackdropFilter` and no platform views (checked 2026-11-06). Real Mac vibrancy shows the desktop behind the window, which Flutter's own blur cannot.
- **Options:** A · Flutter approximation, labelled "approximated" (K8), solid under Reduce Transparency, on Android 11 and older, and on web. B · native views (UIKit glass, NSVisualEffectView) embedded in Flutter: native code and an ADR; a third-party window package would be a must-ask; native views are not captured by golden tests; Android has no native glass. C · solid surfaces only (drops ED-034's glass).
- **Recommendation: A**, plus a short spike on the iPhone tab bar only before implementation; if a native bar proves smooth and testable, that one element can move to B with an ADR.
- **Accessibility:** Reduce Transparency and Increase Contrast use the solid look; contrast on glass still to be measured over the darkest task colour (rules §12.1).
- **Tablets:** same rule per platform; the iPad tab bar or sidebar follows Round 2.
- **Classification:** PROPOSED / AWAITING OWNER ANSWER.

### ED-119 · G3-6 reopened for a native-first direction; option B shown with genuine captures
- **Date:** 2026-11-06. **Owner:** "My preference is for a more genuinely native experience on Apple devices … the decision board visually compares A with C, but does not actually show B. Please do not treat A as approved yet." Explore B: UIKit Liquid Glass for eligible chrome (the tab bar first), AppKit vibrancy for the Mac sidebar, Android as approved, web solid. Show a labelled comparison of genuine Apple components against the Flutter approximation; say which elements can be native while task content stays Flutter; integration risks; fallbacks; an isolated feasibility-test plan (not run); confirmed vs to-test. "Do not produce a fake image and label it genuine native Liquid Glass."
- **Board `E-G3-6-Native`** (canvas `1793922300-995e`; copy and raw captures in `references/concept-e/g3-6-native/`). No E board changed. `E-G3-6` kept; its canvas title now says B was not shown there and points here.
- **Genuine captures:** iOS Simulator screenshots of Apple's Photos app (iPhone 17 Pro, iOS 26.5): the tab bar, the tab bar with Reduce Transparency, and the photo viewer's glass controls by default, with Increase Contrast and with Reduce Transparency. A spare simulator was booted for this and shut down after; the two simulators already running were not touched. No Mac capture (it would screenshot the owner's desktop).
- **Observed:** iOS 26's tab bar puts Search in its own circle; a native Dottoday tab bar may follow that rather than E-Phones' four-tab capsule (to test). Increase Contrast makes the glass more opaque; Reduce Transparency makes it solid.
- **Confirmed from sources:** Flutter 3.47.8 has `UiKitView` and `AppKitView` (its docs call AppKit views expensive); Flutter exposes Increase Contrast (iOS, Android 14+) and On/Off Labels (iOS) but not Reduce Transparency; the app has no BackdropFilter or platform views, uses `PlatformMenuBar` on Mac, and targets iOS 16 and macOS 12.
- **Candidates for native:** iPhone tab bar (best), Day chip with a native menu (possible), Mac sidebar material (good); task content, sheets and the Add button stay Flutter; Android and web unchanged.
- **Feasibility plan (not run):** throwaway sample apps outside `app/`, no new package. Spike 1 iPhone tab bar (2 days; native root vs platform-view bar; iOS 26 device, iOS 18, iPad simulator). Spike 2 Mac sidebar (1 day; NSVisualEffectView behind a transparent Flutter view). Checks and proposed pass criteria on the board.
- **Classification:** G3-6 OPEN · AWAITING OWNER DECISION. Option A not approved. Nothing built.

### ED-120 · G3-6 native feasibility spikes run; results presented
- **Date:** 2026-11-06. **Owner:** "Yes, I authorize both G3-6 native feasibility spikes in isolated, throwaway sample applications." Scope: iPhone/UIKit tab bar (native root hosting Flutter vs native tab bar over Flutter); macOS/AppKit sidebar vibrancy under a transparent Flutter layer; synthetic data; sources outside the repo and worktree; no change to boards, app code, Supabase, hosting, auth or dependencies; no commit or merge; clean synthetic backgrounds; do not disturb existing simulators; mark device validation outstanding; recommend per component; do not adopt; keep G3-6 open; do not start G3-7.
- **Environment:** two Flutter 3.47.8 sample apps (no packages) in `/private/tmp/claude-502/-Users-ops-Documents-dottoday-redesign/a56f9682-4158-45e0-89f7-927795c669b9/scratchpad/spikes`. iOS: dedicated simulators "G36 Spike iPhone" (iPhone 17 Pro) and "G36 Spike iPad" (iPad Pro 11-inch M5), iOS 26.5, created for the spike and deleted afterwards; the simulators already running were not touched. Mac: release build on this Mac (MacBook Pro, Apple M3 Pro, macOS 26.6.2) with a synthetic striped window behind the test window; two timing-run captures taken without it were deleted unseen. The owner's paired iPhone (iOS 27.0.1) was not used: installing needs code signing, which needs approval.
- **Board `E-G3-6-Spikes`** (canvas `1793924887-c726`; copy in `references/concept-e/g3-6-spikes/`). No E board changed.
- **iPhone results (simulator):** genuine Liquid Glass samples the scrolling Flutter content in N1 and N2 (pixel means 255,228,162 / 255,222,161 over an orange task). Increase Contrast (≈254,243,227) and Reduce Transparency (≈249,242,230) handled by iOS in both. Tab selection, Flutter page and Inbox badge stay in sync (N2 after re-applying the badge on creation). Teal tint works. Dynamic Type: Flutter scales, native tab labels stay fixed (iOS standard). A regular tab keeps Search inside the capsule (E's layout); a search-role tab splits it out. Taps while scrolling: N1 1 of 1; N2 1 of 2 dropped (needs device test).
- **Integration findings:** moving one Flutter view into each tab's view controller stopped Flutter redrawing (rejected). Hosting one Flutter view behind all tabs works, but UIKit gives it zero safe-area insets; the selected tab's insets (62 / 83 pt) were sent over a channel. N1 as built uses the iOS 18 UITab API; Dottoday supports iOS 16.
- **Not tested:** VoiceOver (no VoiceOver in the Simulator; N1's native buttons expose Today, Inbox, Calendar, Search, listed twice in the glass hierarchy), Full Keyboard Access, iOS 16–25 fallback (no older runtime), device performance (simulator debug only, ≈60 frames/s, N1 ≈ N2).
- **iPad (simulator):** N1 puts the tabs in a floating bar at the top and supports a sidebar mode; N2 stays a bottom capsule.
- **Mac (this Mac, release):** genuine sidebar vibrancy behind a transparent Flutter view; light and dark, resizing and full screen pass; 3 s scroll at 120 Hz, 362 frames, raster avg 1.08–1.11 ms, p99 2.08–2.28 ms with vibrancy vs 0.96 / 1.86 ms solid; one ≈11 ms frame in every run with or without vibrancy. Keyboard focus ring shows; Tab traversal, VoiceOver, Reduce Transparency and Increase Contrast not tested (system-wide settings on the owner's Mac are not changed). Deviation: neutral system material instead of E's warm tinted sidebar.
- **Recommendations (not adopted):** iPhone tab bar: pursue N1 with Search as a regular tab, after device validation and a decision on iOS 16–17. Other iPhone chrome: keep Flutter for now. iPad: N1's top tabs and sidebar as the Round 2 starting direction. Mac sidebar: feasible and cheap; check VoiceOver/keyboard and decide on a warm tint. Android and web unchanged.
- **Classification:** G3-6 OPEN · AWAITING OWNER REVIEW OF FINDINGS. Nothing adopted, built in the app or committed. G3-7 not started.

### ED-121 · G3-6 spike run on the owner's iPhone; hands-on checks stopped
- **Date:** 2026-11-06. **Owner:** "Yes, use my iPhone" (code signing approved), then signed in to Xcode, trusted the developer profile, and later "Stop device tests".
- **How:** the throwaway tab-bar app was signed with the owner's Personal Team (JBHAWSBYLG) as `dev.spike.g36Tabbar`, a development-only app ID separate from Dottoday (`app.dottoday.planner` and its extensions were not used or changed), built as a profile build and installed over the cable on the owner's iPhone 17 Pro (iOS 27.0.1). Captures were taken only while the test app was in front and checked before use (only test content and the status bar). The test app was stopped; it stays installed and expires with the Personal Team profile (about 7 days) unless deleted.
- **Device results (automated):** genuine Liquid Glass over the scrolling Flutter list in N1 and N2; tab selection, Flutter page and Inbox badge in sync in both; search-role tab splits Search out as in the Simulator. Scripted 3 s scrolls at 120 Hz, three runs each: N1 356–363 frames, Flutter build p99 1.37–1.44 ms, raster p99 1.48–1.57 ms; N2 361–362 frames, build p99 1.28–1.34 ms, raster p99 1.27–1.41 ms. These cover Flutter's work only, not iOS glass compositing. Accessibility listing on the device matches the Simulator.
- **Not done (stopped by the owner):** taps while scrolling, VoiceOver, Full Keyboard Access, largest text and Large Content Viewer, Reduce Transparency and Increase Contrast on the device. The owner's reply after N1 contained no results, so nothing is recorded for N1's hands-on checks. Still outstanding as well: iOS 16–25 and an Instruments trace.
- **Board:** `E-G3-6-Spikes` updated (section 1b, results rows marked "sim + device" where confirmed). Snapshot `references/concept-e/g3-6-spikes-device/`.
- **Classification:** G3-6 OPEN · AWAITING OWNER DECISION. Nothing adopted, built in the app or committed.

### ED-122 · G3-6 follow-up: iPhone bottom row with + in the tab bar's line, presented
- **Date:** 2026-11-06. **Owner:** "i want the + button to be added to the Menu bar … in the same line … maintain its color, shape and style but adopting the menu bars Liquid glass effect. then keep the day button in the + previous position and also make it liquid glass, this change is mainly for IOS, show me." The reference images set the arrangement and size only; Dottoday's tabs, icons and bar style stay. Answers to the follow-up questions: + matches the bar's height (62 pt); all Full and Minimal iPhone screens with the tab bar; show a drawn board and a real-iPhone build.
- **Board `E-G3-6-BottomRow`** (canvas `1793928658-0dfb`; copy in `references/concept-e/g3-6-bottom-row/`). No E board changed.
- **Drawn proposal (12 iPhone frames would change: 7 on E-Phones, 5 on E-PhonesMinimal):** tab bar left 16 / right 86 (288 wide on 390 pt, 62 tall, same glass); + becomes a separate 62 pt circle on the bar's line, 8 pt gap, 16 pt from the edge, teal Liquid Glass (teal 94 → 88 %, blur 16 + saturate 190 %, the bar's edge light and elevation), white plus 28 pt, same label and hold menu; Day ▾ (glass) moves to the right of the row above the bar, where the + was; the Calendar tab has no Day button, so its row is empty. Measured on the board: bar 288, + 62 on the same line, gap 8, Day 16 pt above the bar.
- **Contrast:** white plus on the teal glass ≈ 5.7–7.2:1 over white, cream and task colours (a 78 % tint would drop to 4.3:1 over white, so the tint stays at 88 % or more). Over dark task colours the circle's edge relies on its rim and shadow.
- **Native build on the owner's iPhone (spike app `dev.spike.g36Tabbar`, iOS 27.0.1):** variant N3 composes the row natively (own UITabBar shortened, a UIButton prominent-glass + tinted teal at 62 pt on the same centre line, a UIButton glass Day ▾ above it), with Flutter behind. It works and looks as proposed. Tried first: iOS's search-tab slot as Add, which on iOS 27 sits inside the bar as a fifth item rather than a separate circle (the iOS 26.5 Simulator showed a separate circle), so the circle must be Dottoday's own button. The glass button styles need iOS 26; Dottoday supports iOS 16, so older iPhones need a fallback (solid teal + and the classic bar).
- **Not checked yet:** tapping +, Day and tabs on the device; VoiceOver order; Reduce Transparency and Increase Contrast on this row. N3 is left open on the owner's iPhone to try.
- **Correction 2026-11-06 (owner: the real iPhone's + was not on the bar's line):** the first native build centred the + on the tab bar's whole view (83 pt), but iOS draws the 62 pt glass capsule at the top of that view, so the + sat 11 pt low (capsule centre 798, + centre 809), with a 21 pt capsule inset instead of 16. Fixed by aligning the + to the capsule's measured frame (the item platter) and recomputing on layout. Measured on the owner's iPhone in three runs: capsule and + both 62 pt; top, centre and bottom offsets 0.00 pt; capsule 16 pt from the left, 8 pt gap, + 16 pt from the right; Day ▾ 16 pt above the capsule. Board updated (canvas `1793929374-6835`); the first version is kept as `E-G3-6-BottomRow.as-presented.dc.html`. Implementation rule if adopted: align to the capsule, never to the bar view, and re-align on layout changes (larger text, rotation, future iOS).
- **Position from the owner's reference (2026-11-06; owner: "Yes i confirm Apply and also make sure to Move the Day button to adjust to it properly"):** measured from the owner's reference screenshot (402 pt wide): bar and + about 63 pt tall, bottom edge about 21 pt above the screen's bottom edge, 21 pt from both sides, about 6 pt apart. Applied: drawn frames: bar left 21, right 90, bottom 21, 63 tall, radius 31.5; + 63 pt at right 21, bottom 21; Day ▾ row at left/right 21, bottom 96, so Day's right edge lines up with the + (21) and its bottom sits 16 pt above the bar. Measured on the board: all proposed frames 63 / 21 / 21 / 6, centres level, Day 16 above, right 21. Native build on the owner's iPhone, three runs: capsule y 791–853 (reference 791–853), bottom gap 21, left 21, gap 6, + right 21, + level with the capsule (0.00 pt), Day 16 above with right edge 21. The capsule's height is set by iOS (62 pt on this device); the native + matches it. Board updated (canvas `1793929794-a2f0`); the 16 pt version is kept as `E-G3-6-BottomRow.aligned-16pt.dc.html`. Applies to every iPhone screen with the tab bar if approved; iPad noted for Round 2 (native iPad puts tabs at the top).
- **Classification:** PROPOSED / AWAITING OWNER APPROVAL. G3-6 stays OPEN. Nothing merged, built in the app or committed.
- **Later (2026-11-06):** approved as ED-124 and merged into the active phone boards (ED-126). This entry is kept as the proposal record.

### ED-123 · Android bottom row: three arrangements with the + only, drawn for comparison
- **Date:** 2026-11-06. **Owner:** asked whether the iPhone bottom row could apply to Android "using the Android native Material Glass"; after the answer that Android has no native glass material and that its own pattern puts the FAB above an edge-to-edge navigation bar: "draw the Android as you mentioned aslo just use the + and discard the Add".
- **Board `E-G3-6-Android`** (canvas `1793930840-6595`; copy in `references/concept-e/g3-6-android/`). No E board changed. Frames: E-Phones Android Today and E-PhonesMinimal Android Now, each approved and in three options; the extended "Add" is replaced by the 56 dp + (Material 3 FAB shape, the same button Minimal Android already uses) in all options.
- **A · approved layout, + only (recommended):** the Material 3 pattern (FAB above the bar, Day left).
- **B · + in the navigation bar's line:** bar stays edge to edge; its items take the left 324 dp; the + sits in the bar's content line 16 dp from the right; Day moves right, 16 dp above the bar. No Material component does this.
- **C · floating toolbar + FAB:** Material 3 Expressive floating toolbar (tonal #F2EBE2, 72 dp, 16 dp margins, 24 dp above the bottom, no glass) with the + beside it; Day right, 16 dp above. The floating toolbar is meant for actions, so using it for navigation bends the guideline.
- **Measured on the board:** in B and C the + sits inside the bar's line and the navigation items clear it; Day 16 dp above and 16 dp from the right (Full and Minimal, after using each Day button's real height: 40 dp Full, 48 dp Minimal).
- **C revised 2026-11-06 (owner: "for android floating bar let the day go to the left and adjust and update accordingly. also make the bar menu, + and Day glass using android natives. then wait for approval"):** Day moves to the left, in line with the toolbar's left edge (16 dp) and 16 dp above it; the toolbar, + and Day use Android's native frosted blur (translucent tonal: toolbar 72 %, Day 72 %, + 78 %, with a 24 dp background blur and 140 % saturation; on Android 12+ via RenderEffect / Flutter BackdropFilter; solid tonal on Android 11 and older). Android has no glass material, so this is frosted blur, not Apple Liquid Glass (no edge light or refraction). Measured on the board, Full and Minimal: Day left 16 = toolbar left 16, Day 16 dp above, + level with the toolbar, 8 dp gap, 16 dp from the right. The first C is kept as `E-G3-6-Android.as-presented.dc.html` (canvas `1793931974-b8a6`). A and B unchanged; recommendation still A, C ready if chosen.
- **Classification:** PROPOSED / AWAITING OWNER APPROVAL. Glass stays iOS-only; Android uses frosted blur at most.
- **Later (2026-11-06):** revised option C approved as ED-125 (not A or B) and merged into the active phone boards (ED-126). This entry is kept as the proposal record; the recommendation for A above is history.

### ED-124 · Approved: iPhone bottom row with + in the tab bar's line (Full and Minimal)
- **Date:** 2026-11-06. **Owner:** "I am formally approving BOTH new phone bottom-row designs … iPhone: E-G3-6-BottomRow — proposed is APPROVED … These decisions supersede the earlier phone bottom-row arrangements wherever they differ." Source of truth: the proposed frames on `E-G3-6-BottomRow` (canvas `1793931974-b8a6`, snapshot `references/concept-e/g3-6-bottom-row/`), as built by its own transform; the merged frames are byte-identical to the board's six proposed frames.
- **Scope:** every iPhone screen with the tab bar, Full and Minimal. Supersedes the 52 pt solid + in the row above a full-width bar (ED-033/ED-034 geometry, rules §6.2 and §7.1 before 2026-11-06).
- **Geometry (390 pt phone):** tab bar left 21, right 90 (279 wide; 291 on a 402 pt phone), bottom 21, height 63, radius 31.5, same glass recipe as before. + (Add) a separate 63 pt circle at right 21, bottom 21, 6 pt right of the bar, centres level. Day ▾ glass chip (44 tall) right-aligned with the + (right 21), its bottom 16 pt above the bar (row bottom 96, height 52). Native build: the capsule height is set by iOS (62 pt on the owner's iPhone 17 Pro, iOS 27.0.1); the native + matches the capsule, so "63" means "the bar's height".
- **Look:** + is Dottoday teal as Liquid Glass (teal 94 → 88 %, blur 16 + saturate 190 %, the bar's inner rims and elevation `0 10px 30px rgba(36,31,43,0.12)`), white plus 28 pt. Bar, icons, labels, selected lens and badge unchanged.
- **Destinations and actions:** Full tabs Today · Inbox (badge) · Calendar · Search (ED-069); Minimal tabs Now · Today · Inbox (badge) (ED-068). + tap opens Add on Task with the title focused (two taps to a task); hold + gives Brain dump, Routine, Paste a list (G2-8, ED-091). Day ▾ opens the Day menu (G2-9, ED-093). The Calendar tab has no Day button. Search stays a regular Dottoday tab: it is not converted to Apple's search-role tab.
- **Accessibility requirements:** + stays one button with its label ("Add a task. Hold for Brain dump, Routine, Paste a list" in Full) and its hold actions as accessibility actions; touch targets + 63, Day 44, tabs ≈ 70 × 63; white plus ≥ 5.7:1 on the teal glass (tint never below 88 %); Reduce Transparency: solid bar and solid teal +; Increase Contrast: solid edges; tab labels keep iOS's fixed size with the Large Content Viewer on long-press, Day ▾ grows with Dynamic Type. Reading order to verify: Day ▾, tabs, +.
- **Older iOS:** Dottoday keeps iOS 16 as its minimum. Native glass button styles need iOS 26, so iOS 16–25 needs a fallback with the same geometry (classic material or Flutter-drawn bar, solid teal +). Which fallback is part of the open G3-6 architecture decision (ED-127).
- **Evidence and limits:** the N3 spike shows the arrangement natively on the owner's iPhone (ED-122). Its interaction and accessibility checks (tapping +, Day and tabs; VoiceOver; Reduce Transparency and Increase Contrast on the device) are **not** approved by this decision and stay open.
- **Not decided here:** native vs approximated glass, the iOS 16–25 fallback, iPad navigation (Prompt D Round 2). G3-6 overall stays OPEN.
- **Classification:** APPROVED (design). Not implemented.

### ED-125 · Approved: Android bottom row, revised option C (floating frosted toolbar, icon-only +, Day left)
- **Date:** 2026-11-06. **Owner:** "Android: E-G3-6-Android, revised Option C — APPROVED … Do not interpret my Android approval as Option A or B." Source of truth: the C frames on `E-G3-6-Android` (canvas `1793931974-b8a6`, snapshot `references/concept-e/g3-6-android/`), as built by its own transform; the merged frames are byte-identical to the board's two C frames.
- **Scope:** every Android phone screen with the navigation bar, Full and Minimal. Supersedes the edge-to-edge NavigationBar (104 dp incl. gesture area) and the extended "Add" FAB (rules §6.2, §7.2, §8.2 before 2026-11-06).
- **Geometry (412 dp phone):** floating navigation toolbar left 16, right 80 (316 wide), bottom 24 (clear of the gesture handle), height 72, radius 36, item row padding-top 8; selected pill 64 × 32 `#CFE8E4`, icons and labels as before; Inbox badge unchanged. + 56 × 56 dp, radius 16, at right 16, bottom 32 (centred on the toolbar), 8 dp right of it, icon-only (24 dp plus, `#062F2C`). Day button left 16 (in line with the toolbar's left edge), bottom 16 dp above the toolbar.
- **Surfaces:** Android frosted blur on the toolbar (`rgba(242,235,226,0.72)`), + (`rgba(207,232,228,0.78)`) and Day (`rgba(239,231,219,0.72)`), each with a 24 dp background blur and 140 % saturation on Android 12+ (RenderEffect; Flutter BackdropFilter); solid tonal (`#F2EBE2`, `#CFE8E4`, `#EFE7DB`) on Android 11 and older. M3 elevation on the toolbar `0 1px 2px rgba(36,31,43,.24), 0 2px 6px 2px rgba(36,31,43,.12)`; + `0 3px 8px rgba(36,31,43,.16), 0 1px 3px rgba(36,31,43,.12)`. Menus and sheets stay solid. This is **not** Apple Liquid Glass (no edge light or refraction).
- **Deliberate Material 3 adaptation:** no standard Material component does this. It borrows M3 Expressive's floating toolbar, which Material intends for actions, and uses it as primary navigation beside a FAB. Recorded as a custom, Material-inspired arrangement.
- **Destinations and actions:** Full Today · Inbox (badge) · Calendar · Search; Minimal Now · Today · Inbox (badge). + opens the M3 FAB menu Task · Brain dump · Routine (G2-8, ED-091); Day opens the M3 Day menu (G2-9, ED-093). The Calendar destination has no Day button.
- **Accessibility and platform requirements (to verify in implementation):** toolbar exposed as navigation with selected state and badge text ("Inbox, 3 new"); TalkBack and keyboard order Day, destinations, +; touch targets ≥ 48 dp (Day button's hit area padded to 48 dp; toolbar items ≈ 79 × 72; + 56); system insets: 24 dp above the screen edge with gesture navigation, 16 dp above the system bar with 3-button navigation; hidden while the keyboard is open; predictive Back unchanged; font scale up to 200 % (labels may need to drop to icons with tooltips — to check); blur cost on low-end devices to measure.
- **Not decided here:** how it is built in Flutter (ED-127), tablet and foldable navigation (Prompt D Round 2). G3-6 overall stays OPEN.
- **Classification:** APPROVED (design). Not implemented.

### ED-126 · Approved phone bottom rows merged into the active E boards
- **Date:** 2026-11-06. **Owner:** the approval message's phases 2–6.
- **Method:** the same transforms that drew the approved boards were applied to every active phone frame that carries the bottom row: 12 iPhone frames (E-Phones 7, E-PhonesMinimal 5) and 7 Android frames (E-Phones 5, E-PhonesMinimal 2). The 8 frames shown on the approval boards are byte-identical after the merge.
- **One consistency fix:** on E-PhonesMinimal the Day pull-down is drawn open in three frames (Rest of today and two task-sheet frames over it). The approved board left it anchored to the old Day position (left 16). It now opens from the moved Day ▾ (right 21, bottom 156, 8 pt above the Day row), as an iOS pull-down anchors to its button.
- **Captions:** platform notes and design notes on the four main frames name the new chrome and carry "Approved · G3-6 bottom row (ED-124)" / "Approved · G3-6 Android C (ED-125)". E-Phones grows 10520 → 10600 and E-PhonesMinimal 3950 → 4030 to fit the added caption lines (nothing cut).
- **E-Map:** quick-add row, compact-presentation row, the familiarity note and the "Native chrome" principle updated; a "Phone bottom row" line added to "Decided since v1.1".
- **Exempt (documented):** sheets at the large detent cover the bottom row and were not changed except underneath (Add, Brain dump, Routine, task editor, Day review, Week in review, Move, Schedule); Settings and Wake Up/Wind Down screens have no bottom row; review and history boards (E-PhonesCalendar, E-G2-x, E-G3-1 to E-G3-6 and their variants, E-V1, E-SettingsReview, E-WakeWindDown-Settings-Candidate) keep the arrangement they were decided on. Coverage matrix: `E_SCREEN_INVENTORY.md` §"Phone bottom row coverage (ED-126)".
- **Snapshot:** `references/concept-e/v1.14-working/` (merged boards and their pre-merge copies).
- **Classification:** MERGED (design boards). No app code, Supabase, hosting, sign-in or dependency touched; not committed.

### ED-127 · G3-6 reopened against the approved phone rows; architecture choices presented
- **Date:** 2026-11-06. **Owner:** phase 7 of the approval message: reassess G3-6 with the new rows, keep it open, then stop.
- **Board `E-G3-6-Decision`** (canvas `1793934718-fc4b`; snapshot `references/concept-e/g3-6-decision/`). Sections: 1 approved appearance (four merged frames); 2 verified results (N1/N2/N3 on the Simulator and the owner's iPhone, Mac spike) with a genuine N3 capture; 3 unverified questions per platform; which N1/N2 findings carry to N3 and the device-test ledger; 4 fallbacks; 5 choices awaiting approval; G3-6 history.
- **Recommendations (not adopted):**
  - D1 iPhone architecture: **A · N3 native composition** (UIKit root with a standalone UITabBar, native glass + and Day ▾, one Flutter view behind). B (N1 + Flutter-drawn + and Day) and C (whole row in Flutter) shown.
  - D2 iOS 16–25: **F2**, the same native composition with pre-26 styles (system chrome material, solid teal +); F1 a Flutter-drawn row. Minimum stays iOS 16. Both untested.
  - D3 iPhone Day ▾ menu: native UIMenu from the native button (follows from D1 A).
  - D4 other iPhone glass (top capsule, ‹ Today, Close): keep labelled Flutter approximations for now.
  - D5 Android C: **a Flutter widget with BackdropFilter**, solid tonal on Android 11 and older and with high-contrast text; no platform view, no dependency. Note: Flutter could blur on 11 too; the approved rule turns it solid.
  - D6 Mac sidebar: **native vibrancy with E's warm tint, after a short spike**; otherwise neutral native vibrancy; the Flutter approximation shown as the third option.
  - Tablets: no decision; Prompt D Round 2. Web: unchanged.
- **Device ledger:** passed on the owner's iPhone: glass, selection, badge and 120 Hz timings (N1, N2), the N3 arrangement and alignment (three runs). Not done: every tap and hold on N3, taps while scrolling, VoiceOver, Full Keyboard Access, largest text, Reduce Transparency and Increase Contrast on the device, iOS 16–25, an Instruments trace. Android: nothing built. Mac: VoiceOver, Tab traversal, Reduce Transparency, Increase Contrast, warm tint.
- **Classification:** G3-6 OPEN · AWAITING OWNER DECISION on D1–D6. Nothing adopted, built in the app or committed. G3-7, Group 4 and Prompt D Round 2 not started.
- **Later (2026-11-06):** the owner chose D1–D6 (ED-128); the board now shows those choices. The version before is kept in `references/concept-e/g3-6-decision/`.

### ED-128 · G3-6 architecture directions selected (native-first), two conditional
- **Date:** 2026-11-06. **Owner:** "I want a native-first architecture for Dottoday, while preserving the exact approved Concept E phone designs."
- **D1 · iPhone: SELECTED A, N3 native composition.** Genuine UIKit tab bar, native teal glass +, native Day control, Flutter content behind. ED-124 geometry, all Full and Minimal destinations, Inbox badges, Add modes and interactions preserved. Visual feasibility demonstrated (ED-122); accessibility and interaction tests **not verified**.
- **D2 · iOS 16–25: F2 SELECTED as the preferred compatibility design, CONDITIONAL on testing.** Same native composition with older native controls. Minimum iOS stays 16. Not technically verified until tested on the relevant older iOS versions; if it fails, alternatives are presented before deciding.
- **D3 · iPhone Day menu: SELECTED A, native UIMenu** on the native Day control. G2-9 commands, grouping, labels, availability rules and accessibility kept; no command or entry point removed.
- **D4 · Other iPhone chrome: SELECTED, stays Flutter** (top capsule, back controls, Close). No native integration beyond D1–D3 without another decision.
- **D5 · Android C: SELECTED A, Flutter implementation** of the approved ED-125 design: translucent tonal on Android 12+, solid on 11 and older, high-contrast fallback. No platform view and no additional dependency approved. Performance, system navigation insets, TalkBack, keyboard and responsive behaviour are implementation verification requirements.
- **D6 · Mac sidebar: B PREFERRED, CONDITIONAL** on a visual feasibility check: genuine NSVisualEffectView vibrancy with a restrained warm tint, tested in the isolated Mac sample (ED-129). Not final until the owner approves the result visually.
- **Tablets:** phone navigation is not assumed for iPad or Android tablets (Prompt D Round 2). **Web:** unchanged.
- **Status words used from here on:** *approved visual design* · *selected architecture direction* · *feasibility demonstrated* · *tests still outstanding* · *production implementation not authorised*.
- **Classification:** directions SELECTED (D1, D3, D4, D5), CONDITIONAL (D2, D6). G3-6 OPEN. Production implementation NOT AUTHORISED. Nothing committed.

### ED-129 · D6 warm-tint comparison and D2 compatibility findings (spikes)
- **Date:** 2026-11-06. **Owner:** ED-128 (D2 and D6 conditions). Throwaway sample apps outside the repo; synthetic content; no Dottoday code, dependencies, Supabase, hosting or signing touched.
- **D6 (Mac, this Mac, light mode, synthetic striped backdrop):** genuine captures of (1) native neutral vibrancy (NSVisualEffectView, sidebar material, behind-window), (2) native vibrancy with a `#EFE7DB` layer at 35 % inside the effect view under Flutter, (2b) the same at 55 %, (3) the approved approximation (`rgba(239,231,219,.78)` on the cream page, no material). Measured on the sidebar area (sRGB spread R/G/B; worst-case contrast): neutral 4.5/5.7/8.2, ink 11.4:1, teal 5.1:1; warm 35 % 2.7/3.6/5.2 (≈ 60 % of neutral show-through), ink 12.1:1, teal 5.5:1; warm 55 % 2.1/2.5/3.6 (≈ 45 %), 12.6:1, 5.7:1; approximation 0.5/0.5/0.4 (flat), 13.9:1, 6.3:1. The tint keeps genuine vibrancy and improves readability. Not tested: dark mode (G4-6), Reduce Transparency, Increase Contrast, VoiceOver, Tab traversal, other backdrops. Recommendation: 35 %.
- **D2 (F2 path in the N3 spike app):** the F2 composition uses only iOS 15/16 APIs (standalone UITabBar with UITabBarAppearance on system material, rounded to the capsule; solid teal UIButton +; Day on UIVisualEffectView material; UIMenu for Day and for holding +). With the deployment target lowered to iOS 16 the compiler accepted F2 and flagged only N1's iOS 18 `UITab` code (now behind availability checks). Run on a throwaway iOS 26.5 Simulator in Apple's compatibility mode (`UIDesignRequiresCompatibility`, pre-glass styles), then deleted: geometry measured bar x 21, 291 wide (402 pt phone), 63 tall, bottom 21; + 63 at right 21, bottom 21; gap 6; centres level; Day 44, right 21, 16 above. Tab switch and badge kept; native hold menu on + opens (Brain dump, Routine, Paste a list); native Day menu opens on press with the G2-9 groups.
- **Findings:** (1) iOS reverses a menu opened upward (Day group first); implementation must fix the order so G2-9 reads as approved. (2) A quick simulated tap did not open the Day menu (press did); may be the simulator's tap injection — hands-on check needed. (3) The standalone bar reports a 13 pt bottom safe-area inset; check item layout on real iOS 16–18. (4) The + tap itself was not confirmed (log not read).
- **Not tested:** iOS 16–25 themselves (only the iOS 26.5 runtime is installed; compatibility mode is not an older iOS). **F2 is not technically verified.**
- **Board `E-G3-6-Remaining`** (canvas `1793937030-1796`; snapshot `references/concept-e/g3-6-remaining/`) with the remaining questions: Q1 D6 tint level; Q2 how to verify F2 (download older simulator runtimes, several GB each, or an older physical iPhone); Q3 when G3-6 closes.
- **Classification:** FINDINGS PRESENTED. D2 and D6 still conditional; G3-6 OPEN.

### ED-130 · D6 approved: native Mac sidebar vibrancy with a 35 % warm tint (visual direction)
- **Date:** 2026-11-06. **Owner:** "For G3-6 D6, I approve Option 2 — Genuine macOS native sidebar vibrancy with a 35% warm tint. I prefer this over neutral vibrancy, 55% tint and the Flutter approximation."
- **Approved visual direction (light mode):** native `NSVisualEffectView` sidebar material (behind-window blending), with Concept E's `#EFE7DB` warm tint at 35 % layered inside the material, under the Flutter content. Genuine desktop vibrancy stays visible beneath the tint. Sidebar layout, rows, navigation, selection colours, typography and interaction unchanged. No permanent replacement with a flat Flutter blur; the drawn approximation on the boards remains a reference drawing only.
- **Measured (Mac spike, ED-129, this Mac, light, synthetic backdrop):** show-through R/G/B spread 2.7 / 3.6 / 5.2 (≈ 60 % of neutral 4.5 / 5.7 / 8.2); average sidebar colour 230, 227, 221; worst-case contrast ink `#241F2B` 12.1 : 1, selected teal `#11615C` 5.5 : 1. Captures in `references/concept-e/g3-6-remaining/captures/`.
- **Requirements (PENDING unless stated):** (1) solid fallback when Reduce Transparency is on (warm solid, proposed `#EFE7DB`; the system already makes the material opaque) — PENDING; (2) Increase Contrast — PENDING; VoiceOver — PENDING; keyboard navigation (Tab traversal) — PENDING; (3) dark mode designed and measured in G4-6, not a reuse of the light tint — PENDING; (4) appearance kept as close to the approved sidebar as native rendering allows; (5) measured contrast and spike results recorded above; (6) every unperformed test stays PENDING.
- **D2 unchanged:** F2 conditionally selected, NOT VERIFIED; no older simulator runtimes downloaded without separate authorisation. Note: after iOS 18 Apple numbered the next release iOS 26, so the versions F2 must cover are iOS 16, 17 and 18.
- **Boards:** `E-G3-6-Decision` (D6 marked approved) and `E-G3-6-Remaining` (F2 verification choices V1–V4 and proposed closing criteria), canvas `1793937492-6ed8`; snapshot `references/concept-e/g3-6-d6-approved/`.
- **Classification:** D6 visual direction APPROVED; accessibility and implementation checks OPEN; production implementation not authorised. G3-6 OPEN (D2 verification and closing criteria pending).

### ED-131 · Compatibility run: F2 on iOS 18.6, N3 on iOS 26.5 (Simulator)
- **Date:** 2026-11-06. **Owner:** "I have both iOS 18.6 and iOS 26.5 simulator runtimes already installed. Please test both using the existing isolated feasibility projects." No runtimes downloaded; Xcode and existing simulators untouched; two throwaway simulators created (iPhone 16 Pro on 18.6, iPhone 17 Pro on 26.5, both 402 × 874 pt) and deleted afterwards.
- **Test app:** the isolated `g36_tabbar` spike (outside the repos), extended to the approved row in both variants from one code path: Full and Minimal tabs, + tap opening Add, + hold menu (G2-8 modes, also as accessibility actions), native Day UIMenu with the G2-9 groups and the today-only rule driven by the Flutter date, Calendar tab without Day, fixed menu order. Synthetic data only.
- **Results (Simulator; PASS = seen in this run):** see `E-G3-6-Compat` §5. Both versions PASS: Full tabs, Minimal tabs, selected state and badge 3 → 6, ordinary tap on + opens Add, hold + with mode choice, ordinary tap on Day opens the G2-9 menu in fixed order (the ED-129 quick-tap failure did not recur), date kept across tabs, safe areas (top 62, bottom 34), keyboard, taps while scrolling, Full alignment 21 / 6 / 21 with Day 16 above, native look and teal, Increase Contrast, largest text (Day grows to 143 × 63, tabs fixed size), labels and selected state, touch targets. iOS 26.5: Liquid Glass reacts to Flutter task colours (bar average 199,203,251 over purple vs 254,236,195 over yellow) and becomes near-opaque with Reduce Transparency.
- **Test-app defects fixed and re-run:** F2 Reduce Transparency (the classic bar blur does not turn opaque by itself: F2 switches to a solid appearance; re-run PASS on 18.6); Day menu on another day (a submenu header cannot be disabled: Need more time becomes a disabled item; re-run PASS on 18.6, **retest pending on 26.5**); + menu fixed order (re-run on 18.6; the 26.5 capture predates it).
- **Architecture finding F1 (iOS 26.5, N3 Minimal):** the genuine tab bar caps a three-tab glass capsule at 274 pt on a 402 pt phone; filling, item width and a wider bar view do not change it. Full (four tabs) fills 292 pt exactly. Minimal therefore cannot match ED-124's 21 / 6 / 21 natively. Options: (a) keep the 6 pt gap, capsule starts 39 from the left (recommended); (b) centred, 30 left and 15 gap (as run); (c) 21 left, 24 gap; (d) Flutter-drawn Minimal bar (not native; not recommended). Needs the owner's decision. F2 on 18.6 fills the span.
- **Other findings:** the 26.5 accessibility listing showed each tab twice and no badge value (VoiceOver check needed); the listing order is code order (tabs, +, Day), not VoiceOver; first launch on the 18.6 Simulator drew Flutter after ≈ 12 s while shaders compiled (debug Simulator, environment).
- **NOT TESTED:** VoiceOver, Full Keyboard Access, Large Content Viewer, deep links and route restoration, physical devices, real-device performance. **PENDING:** iOS 16 and 17 (18.6 does not verify them).
- **Board `E-G3-6-Compat`** (canvas `1793941932-48fa`; snapshot `references/concept-e/g3-6-compat/` with captures); `E-G3-6-Remaining` status table updated.
- **Classification:** N3 suitable on iOS 26.5 for Full; Minimal needs decision F1. F2 works on iOS 18.6 with the two fixes recorded as implementation rules. G3-6 OPEN pending the owner's review. Production implementation not authorised.
- **Later (2026-11-06):** F1 decided as option (a) (ED-132).

### ED-132 · F1 approved: iPhone Minimal on iOS 26+ keeps the 6 pt gap; native capsule width
- **Date:** 2026-11-06. **Owner:** "For G3-6 F1, I approve Option (a) — Keep the 6 pt gap to the + button on iOS 26+ Minimal. I want to preserve genuine Apple Liquid Glass rather than replace the Minimal tab bar with a Flutter approximation."
- **Rule:** Minimal destinations stay Now · Today · Inbox. The native teal glass + stays 21 pt from the right and bottom. The visible native tab capsule sits 6 pt left of the +, centres level, and keeps Apple's system-determined three-tab width (274 pt measured on iOS 26.5, 402 pt iPhone), so its left inset grows (≈ 39 pt there instead of 21). Alignment is computed from the rendered capsule's actual bounds on every layout pass, never from a hardcoded 274 pt; the same relation holds on other iPhone sizes, rotation and accessibility settings. Day ▾ position, Full geometry (21 / 6 / 21), navigation, selected states and Inbox badges unchanged. F2 on iOS 16–18 keeps the passing ED-124 Minimal arrangement (bar 21 from the left).
- **Merged:** the five iPhone Minimal frames with the tab bar on `E-PhonesMinimal` now draw the capsule at the measured width with the 6 pt gap (on the 390 pt frames: right edge 90, width 274, left 26; ≈ 39 on a 402 pt phone); the iPhone Minimal Now caption carries the exception. Measured on the board, all five: 274 wide, gap 6, + 21 / 21, Day right 21 and 16 above, centres level. Android, Full iPhone, Mac, web and historical boards unchanged. E-Map's phone-bottom-row line updated.
- **Snapshot:** `references/concept-e/v1.15-working/`.
- **Classification:** F1 APPROVED and MERGED (design). Implementation rule recorded; not built.

### ED-133 · G3-6 approved as a design and selected architecture direction
- **Date:** 2026-11-06. **Owner:** "G3-6 may be marked resolved as a design and selected architecture direction if the decision records are complete, but no untested implementation behavior may be marked PASS."
- **Resolved:** phone bottom rows (ED-124, ED-125, merged ED-126; Minimal exception ED-132); iPhone N3 native composition (D1), F2 on iOS 16–18 (D2, Simulator PASS on 18.6, ED-131), native Day UIMenu (D3), other iPhone chrome in Flutter (D4), Android C in Flutter (D5), Mac native vibrancy with 35 % warm tint (D6, ED-130); tablets deferred to Prompt D Round 2; web unchanged.
- **Still PENDING (never PASS until run):** iOS 16 and 17; physical-device VoiceOver and Full Keyboard Access; the duplicate native accessibility elements and missing badge announcement on iOS 26; N3 tap and hold on a device; deep links and tab restoration; Reduce Transparency and Increase Contrast on a device; the iOS 26.5 retest of disabled Day-menu actions and the + menu order; Large Content Viewer; Android blur performance, insets, TalkBack, keyboard; Mac Reduce Transparency fallback, Increase Contrast, VoiceOver, keyboard, dark tint (G4-6). Listed in `E_IMPLEMENTATION_HANDOFF.md`.
- **Classification:** G3-6 RESOLVED (design and selected architecture direction). Production implementation NOT AUTHORISED. G3-7 not started.

### ED-134 · G3-7 presented: iPhone keyboard and the teal "Add" key
- **Date:** 2026-11-06. **Owner:** "Yes, I approve moving forward with Concept E · G3-7 … Stop after presenting G3-7 options and your recommendation."
- **Scope (register G3-7; ED-030, ED-031, ED-032; CR-099):** the boards draw a custom teal "Add" return key on the iOS keyboard; iOS has no "Add" return type and apps cannot recolour or relabel keyboard keys; "the keyboard" (ED-032) was never answered.
- **Audit:** keyboards drawn on E-Phones (iPhone Add, Full: custom teal key + in-sheet Add; iPhone editor "typing a step": keyboard drawn without its return row) and E-PhonesMinimal (iPhone Add, Minimal: custom teal key + nav-bar Add; Android Add: Gboard check key drawn teal, though Gboard sets that colour). Mac and web draw no on-screen keyboard (Return / Enter adds). Genuine Simulator captures (G3-6 spike app) show iOS's default blue "done" on 18.6 and blue ✓ on 26.5.
- **Options (drawn on copies of the approved Add frames, Full and Minimal):** A · stock keyboard with the neutral "return" key (Return adds) plus a 44 pt app-drawn bar on the keyboard with teal Add (in-field / nav-bar Add kept; sheet grows 44 pt); B · as drawn, custom teal key (not buildable with the system keyboard); C · stock keyboard, neutral return adds, Add only in the field row / nav bar.
- **Recommendation: A** (keeps the teal Add at the keyboard, never blue done, real keyboard; settles ED-032). C as the more minimal alternative.
- **Open questions:** Q1 A / B / C; Q2 bar also on the editor's step field (recommended: no); Q3 redraw keyboards in iOS 26 style when merging (recommended: yes). Android: correct the check-key note (colour is Gboard's).
- **Board `E-G3-7`** (canvas `1793943183-08ac`; snapshot `references/concept-e/g3-7/`). No active board changed. G3-6 not reopened.
- **Classification:** G3-7 PRESENTED · AWAITING OWNER DECISION.
- **Later (2026-11-06):** option C chosen and merged (ED-135).

### ED-135 · G3-7 approved: C · stock iPhone keyboard, neutral return key, no extra bar
- **Date:** 2026-11-06. **Owner:** "C · stock only".
- **Rule:** iPhone Add uses the stock iOS keyboard. The return key is the neutral "return" type (never "done" or another accented type, ED-030) and pressing it adds, exactly like Add. No custom key, no accessory bar. The teal Add stays where it is: in the field row (Full) and in the nav bar (Minimal). This replaces how ED-031 was drawn (a teal "Add" key iOS cannot show); ED-031's intent, a visible teal Add on the Add screen and no blue "done", is kept. It settles ED-032: the keyboard is the stock one.
- **Merged:** E-Phones iPhone Add (Full) and E-PhonesMinimal iPhone Add (Minimal): the teal key replaced by the stock "return" key in the boards' keyboard style; platform notes updated. Byte-identical to option C on `E-G3-7`. E-Map's familiarity note updated. Nothing else changed (Android, Mac, web, other frames).
- **Not merged, still open:** redrawing the iPhone keyboards in iOS 26 style (Q3); completing the keyboard drawn on the editor's "typing a step" frame (it shows no return row; Return adds the next step); the Android note that Gboard sets its action-key colour.
- **Implementation rule:** Flutter TextField with `TextInputAction.unspecified` on iOS (neutral return) and `onSubmitted` adding the task; Android keeps the IME done/check action; Mac Return and web Enter add. Verify on iOS 16–18 and 26 that the key stays neutral (PENDING).
- **Snapshot:** `references/concept-e/v1.16-working/`.
- **Classification:** G3-7 RESOLVED and MERGED (design). Production implementation not authorised.
- **Later (2026-11-06):** follow-up visual work done (ED-136).

### ED-136 · G3-7 follow-up: iOS 26 keyboard drawing, step keyboard, keyboard dismissal, Gboard note
- **Date:** 2026-11-06. **Owner:** accepted the ED-135 merge and asked for the remaining keyboard consistency work, and "how is the keyboard dismised".
- **iOS 26 keyboard drawing:** the three active iPhone keyboard frames (E-Phones Add and "typing a step"; E-PhonesMinimal Add) now draw the iOS 26 system keyboard, measured from the genuine iOS 26.5 Simulator capture and scaled to the 390 pt frames: rounded light panel 270 pt, suggestion strip, white keys 42 pt on a 54 pt pitch, bottom row 123 · space · return (neutral return glyph). Rule: the app always uses the system keyboard of the iOS version it runs on (iOS 16–18 and 26 look different); the drawing shows the iOS 26 look only. The return glyph on each version is PENDING a device check.
- **Full Add sheet:** follows the 270 pt keyboard (top 200 → 220, same 34 pt gap above the keyboard).
- **Typing a step:** keyboard completed. Behaviour as approved by the owner: Return on a step with text adds the next step and moves the caret to it; Return on an empty new step adds nothing (the empty row is dropped and the keyboard hides), so no blank steps are created.
- **How the keyboard is dismissed (recorded rule):** swipe down on the sheet or drag its content hides the keyboard first (the sheet and the draft stay; a second swipe closes the sheet as before); tapping outside the field on the sheet hides it; Return adds (Add another off: the sheet closes after adding); Cancel / Close / Done unchanged; VoiceOver two-finger scrub hides it; hardware keyboard: no on-screen keyboard, Esc leaves the field; Android: Back hides the keyboard first, then closes the sheet. Tapping the field again restores the keyboard with the caret at the end of the same text.
- **Keyboard-open and keyboard-dismissed states with the same draft:** new section "Keyboard open and dismissed" on E-Phones (Add Full; steps) and "Keyboard open and dismissed (minimal)" on E-PhonesMinimal (Add Minimal). Full Add dismissed: the sheet shrinks to its content (top 472) over the dimmed Today; Minimal Add dismissed: the page sheet keeps its height; steps dismissed: the typed step kept as a normal row, count 2 of 5, no blank step.
- **Android note corrected:** the keyboard's action (check) key adds; Gboard draws it in its own theme colour, not Dottoday's teal. Android navigation and Add design unchanged.
- **Checked on the boards:** active fields stay above the keyboard (Full Add field 292–320, step 174–194, Minimal Add 323–353; keyboard top 574); no clipping or overlap; boards grown to fit (E-Phones 10600 → 11680, E-PhonesMinimal 4030 → 5080; E-FullA moved down on the canvas to clear E-Phones). Only the three keyboard frames changed among existing frames.
- **PENDING (not tested):** real-device keyboard behaviour, dismissal gestures, the return glyph and neutral colour on iOS 16, 17, 18 and 26, VoiceOver and hardware-keyboard behaviour, Android Back order.
- **Snapshot:** `references/concept-e/v1.17-working/`.
- **Classification:** DONE (design boards). G3-7 stays RESOLVED. Production implementation not authorised.

### ED-137 · Full editor shows the task's existing steps and notes; typing scrolls them into view
- **Date:** 2026-11-06. **Owner (comment on the pulled-up full editor):** "if you type in steps and or notes it should scroll up automatically and one can also scroll up to get view if too down or hidden, and if any steps or notes existed before now in that current task it should show". The owner withdrew the earlier steps / floating Create task request ("ignore that previous request").
- **Merged on E-Phones, Task editor section:** (1) "Full editor (pulled up from F3)" now continues below Repeat/Energy with the task's existing Steps (2 of 4) and Notes, with a scroll indicator; the empty "Add a step" row is a grey hint, not a step. (2) New "Full editor · scrolled to steps and notes": keyboard down, steps and notes fully in view above the Saved bar. (3) New "Full editor · typing a note": the sheet scrolled 60 pt under its pinned header so the caret line (516) stays above the keyboard (574).
- **Rule:** the focused step or note line scrolls into view above the keyboard when it gets focus and as it grows; the sheet stays scrollable by hand while the keyboard is up; existing steps and notes always show in the full editor. PENDING on device (sizes, larger text, iOS 16–18 and 26).
- **Board note:** the canvas caps a board at 8000 px tall, so E-Phones (11720 px) shows only its first 8000 px; Add modes, Day review and the keyboard section sit below that. Proposed fix (awaiting the owner): split E-Phones into two boards.
- **Classification:** MERGED (design). Production implementation not authorised.

### ED-138 · "Back in the editor" gets Repeat, Energy, steps and notes
- **Date:** 2026-11-06. **Owner (comment on that frame):** "do the same thing here add steps and notes, and also energy and repeat".
- **Merged on E-Phones (Task editor section):** after the date, time and alerts card the frame now shows the Repeat and Energy row, then the task's existing Steps (2 of 4, empty "Add a step" hint) and Notes, copied from the full editor (ED-137), with a scroll indicator; caption updated. Same rule as ED-137.
- **Classification:** MERGED (design). Production implementation not authorised.

### ED-139 · "Create task (detailed)" gets the Task · Brain dump · Routine tabs
- **Date:** 2026-11-06. **Owner (comment on that frame):** "Add the tabbed Task, Brain dump and routine".
- **Merged on E-Phones (Task editor section):** the segmented control from the approved quick Add (G2-8, ED-091) sits under the Cancel / Create task row, Task selected; the rest of the screen moves down and scrolls; caption updated. Choosing Brain dump or Routine opens those approved Add modes; nothing else changed.
- **Classification:** MERGED (design). Production implementation not authorised.

### ED-140 · The iPhone Add screen becomes Create task (detailed)
- **Date:** 2026-11-06. **Owner (comment on the quick Add frame):** "replace this screen with create task(detailed) to and updated any necessary details".
- **Merged on E-Phones:** the first-row "iPhone · Add a task" frame (the compact quick Add sheet) is replaced by the detailed Create task screen (Task · Brain dump · Routine tabs, colour and icon, title, date, time, alerts, Repeat, Energy, steps, notes; Create task in the header), opening with the title focused and the iOS 26 keyboard up. "Create task (detailed)" is now captioned as the same screen with the keyboard down. The keyboard section's Add pair shows this screen with the same draft ("Gym 6pm 1h") open and dismissed. Captions updated (natural-language time, paste a list, 2 taps + typing kept; neutral return creates; teal Create task in the header).
- **R-06 kept:** + then type (title focused), natural-language time, paste a list.
- **Open (owner to confirm):** the compact sheet's "Add another" switch and its live chips / time preview are not on the detailed screen; keep "Add another" (e.g. in ⋯ More) or drop it? Minimal Add (E-PhonesMinimal) and Android are unchanged.
- **Classification:** MERGED (design). Production implementation not authorised.

### ED-141 · Android parity for ED-137, ED-138 and ED-140
- **Date:** 2026-11-06. **Owner (same thread as ED-140):** "make sure it's also same thing with android where neccessay".
- **Merged on E-Phones:** (1) "Android · Task editor (full screen) · option D" now shows the task's existing Steps (2 of 4, M3 checkboxes, done ones struck through, "Add a step" hint) and Notes below Repeat and Energy, with a scroll indicator. (2) New "Android · Add: Create task (full screen)" in the Task editor section: × close, "New task", Create; title "What is it?" focused with Gboard up; natural-language hint; When (date, time, alert), Repeat, Energy, empty Steps and Notes.
- **Android differences kept:** modes (Task, Brain dump, Routine) are also in the FAB menu (G2-8; tabs added by ED-142); Gboard draws its action key in its own colour; Back hides the keyboard first.
- **Not changed:** E-PhonesMinimal Android Add (minimal sheet); "Add another" still an open question (ED-140).
- **Classification:** MERGED (design). Production implementation not authorised.

### ED-142 · Android Create task gets the Task · Brain dump · Routine choice (ED-139 parity)
- **Date:** 2026-11-06. **Owner (on the ED-139 tabs thread):** "for this change make sure it's also same thing with android where necessary".
- **Merged on E-Phones:** the Android Create task screen shows Task · Brain dump · Routine as Material 3 segmented buttons under the top app bar, Task selected (secondary-container fill with a check). The FAB menu still offers the three modes (G2-8). Supersedes the ED-141 note that Android has no tabs.
- **Classification:** MERGED (design). Production implementation not authorised.

### ED-143 · Withdrawn: Android check key drawn in Gboard's default colour
- **Date:** 2026-11-06. Made and then undone at the owner's request ("undo edit and this decision"). Both boards are back to their state before it: the check key is drawn teal, and the notes read as after ED-136 / ED-141. No decision stands under this number.

### ED-144 · E-Phones split into two boards so nothing is cut off on the canvas
- **Date:** 2026-11-06. Housekeeping, no design change (CR-124).
- **Why:** the canvas caps a board at 8000 px tall; after ED-137 to ED-142 E-Phones was 11840 px, so its last sections (Add modes, Day review and When picker, keyboard states) were drawn but hidden below 8000.
- **What moved:** sections 1–6 stay on `E-Phones` (7920 px, content ends at 7880). Sections 7–10 move unchanged to the new `E-Phones-2` (4120 px, content ends at 4063), placed directly below E-Phones (x 30, y 20560); `E-FullA` moved down to y 24840 to make room. All 48 phone frames are preserved and identical (sorted comparison of the frame markup before and after).
- **E-Map:** four rows updated for ED-137 to ED-142 (iPhone and Android quick add, Add modes, task surface); height 4320 → 4380.
- **Pre-split copy:** `references/concept-e/v1.19-working/E-Phones.pre-split.dc.html`.
- **Classification:** MERGED (housekeeping). Production implementation not authorised.

### ED-145 · Minimal's option D editor shows steps and notes, with auto-scroll (ED-137 for Minimal)
- **Date:** 2026-11-06. **Owner (comment bbdf5e2f on E-PhonesMinimal "More options → option D editor"):** "add task and notes… if you type in steps and or notes it should scroll up automatically and one can also scroll up to get view if too down or hidden".
- **Merged on E-PhonesMinimal, row "Task sheet (minimal)":** the option D editor now shows the task's existing steps and notes below Repeat/Energy; two new frames: "scrolled to steps and notes" and "typing a note" (caret kept above the keyboard; manual scrolling still works). The editor dialog was already byte-identical to Full's, so the ED-137 frames' editor is reused over Minimal's day.
- **Rule:** same as ED-137 (rules §8 steps and notes), now for Minimal too.
- **Android Minimal:** its More options opens the same Android editor that ED-141 already gave steps and notes (E-Phones); no separate Android Minimal editor frame drawn.
- **Fit:** E-PhonesMinimal content ends at 5043 of 5080 px; right edge 2720 of 2760.
- **Classification:** MERGED (design). Production implementation not authorised.

### ED-146 · G2-8 board: A1 shows the current iPhone Add screen
- **Date:** 2026-11-07. **Owner (comment 0c051052 on `E-G2-8` A1 "iPhone Add · Task (default)"):** "make this like iPhone · Add a task: Create task (detailed), title focused (ED-140) also keep the keyboard".
- **Changed on `E-G2-8` only:** A1's phone frame is replaced by the E-Phones Add screen (ED-140): Create task (detailed), Task · Brain dump · Routine tabs, title focused, keyboard up. Read as "keep the keyboard showing", drawn as the approved stock iOS keyboard (G3-7 C, ED-135), not A1's old teal "Add" key. Caption and an ED-146 tag added; A2–A6, B1 and the rest of the board unchanged.
- **History kept:** the original A1 drawing is in `references/concept-e/g2-8` (checksums unchanged) and in `v1.21-working/E-G2-8.pre-ed146.dc.html`.
- **No active board changed;** the Brain dump and Routine frames (A2, A3 here; E-Phones-2) still use the compact sheet (CR-125, Q-A2).
- **Fit:** content ends at 3679 of 3700 px.
- **Classification:** MERGED (reference board sync). Production implementation not authorised.

### ED-147 · iPhone Brain dump opens full screen, like Create task
- **Date:** 2026-11-07. **Owner (comment 7ac666d2 on `E-G2-8` A2 "iPhone Add · Brain dump"):** "make this pull up a full screen since the create task screen is now a full screen".
- **Merged on `E-G2-8` A2 and its identical active twin on `E-Phones-2` ("iPhone · Add › Brain dump"):** the sheet opens at the large detent (top 56, like Create task), background `#FBF7F1`, a header row with Cancel and the title "Brain dump", then the same Task · Brain dump · Routine tabs; content unchanged (lines, mic, Put it on Today / Tomorrow, Plan it, Earlier dumps). Plan it stays the primary action in the body.
- **Answers part of Q-A2 / CR-125** for Brain dump. **Still open:** Routine (A3, E-Phones-2 "Add › Routine") still uses the shorter sheet; Android Brain dump (A6) unchanged.
- **Fit:** E-G2-8 3679 of 3700 px; E-Phones-2 4082 of 4120 px.
- **Classification:** MERGED (design). Production implementation not authorised.

### ED-148 · Android follows ED-146 and ED-147
- **Date:** 2026-11-07. **Owner:** "also android should reflect same change" (thread 7ac666d2, Brain dump) and "also the android version should also be same" (thread 0c051052, A1).
- **Android Brain dump full screen** (E-G2-8 A6 and E-Phones-2 "Android · FAB menu › Brain dump"): same shell as Android Create task (ED-141/142): × close, "Brain dump" title, M3 segmented Task · Brain dump · Routine with Brain dump selected (check), then the unchanged content (lines and mic, Put it on, Plan it, hint, Earlier dumps). Plan it stays the primary action, so the top bar has no Create button.
- **E-G2-8 A5** (Android counterpart of A1): the FAB menu card is replaced by the Android Create task screen (FAB › Task, Gboard up). The FAB menu stays drawn on E-Phones-2 and in the g2-8 snapshot; stacking both would have overflowed the board (4010 > 3700).
- **Still open:** Routine (iPhone and Android) keeps its shorter sheet (Q-A2). *Closed by ED-149.*
- **Fit:** E-G2-8 3679 of 3700; E-Phones-2 4082 of 4120.
- **Classification:** MERGED (design). Production implementation not authorised.

### ED-149 · Routine opens full screen on iPhone and Android
- **Date:** 2026-11-07. **Owner (thread ab0af706 on `E-G2-8` A3 "iPhone Add · Routine"):** "make this pull up a full screen also the android".
- **iPhone** (E-G2-8 A3 and E-Phones-2 "iPhone · Add › Routine"): same transform as ED-147: large detent (top 56), Cancel and the title "Routine" in the header, same tabs, unchanged content.
- **Android:** new frame "Android · FAB menu › Routine" on E-Phones-2 (no Android Routine frame existed): the ED-148 shell (× close, "Routine" title, M3 segmented buttons with Routine selected), then Drop on Today / Tomorrow / Other day…, the three routines, the hint and Edit routines…. E-G2-8 has no room for a seventh Option A frame, so Android Routine is drawn on the active board only.
- **Closes Q-A2 / CR-125:** every Add mode (Task, Brain dump, Routine) now opens full screen on both phones.
- **Fit:** E-G2-8 3679 of 3700; E-Phones-2 4101 of 4120.
- **Classification:** MERGED (design). Production implementation not authorised.

### ED-150 · The proposal opens full screen on iPhone and Android
- **Date:** 2026-11-07. **Owner (thread 92f768f3 on `E-G2-8` A4 "The proposal (both modes)"):** "make this pull up a full screen also the android".
- **iPhone** (E-G2-8 A4 and E-Phones-2 "iPhone · the proposal (both modes)"): the one ProposalSheet (B3) now opens at the large detent (top 56), like the Add modes; its title row (mode, "simple rules", summary, ×) and content are unchanged.
- **Android:** new frame "Android · the proposal (full screen)" on E-Phones-2: the ED-148 shell (× close, mode title with "simple rules", no segmented buttons since the proposal is a result, not a mode), the summary line, then the same proposed dots, "no room · to the Inbox", Add to day and Discard. Still one ProposalSheet (rules: never fork it); nothing written before Add to day.
- **Layout:** the row's "Kept as they are" note moved under the row to make room; E-Phones-2 grows 4120 → 4200 (content 4140), canvas h updated; it still ends above E-FullA (24760 < 24840).
- **Classification:** MERGED (design). Production implementation not authorised.

### ED-151 · G3-7 board: option B's frame shows Create task, its keyboard kept
- **Date:** 2026-11-07. **Owner (thread 91ae4d1c on `E-G3-7` "Full · B · As drawn: custom teal Add key"):** "make this create task same as iPhone · Add a task: Create task (detailed), title focused (ED-140) but retaining the current keyboard".
- **Changed on `E-G3-7` only:** that frame's screen is now the E-Phones Create task (Task · Brain dump · Routine tabs, title focused, teal Create task in the header); its own drawn keyboard with the teal "Add" key is kept unchanged, as the owner asked. Caption extended, ED-151 tag added.
- **Not a decision change:** G3-7 stays resolved as C (ED-135, stock keyboard with the neutral return key); option B is still marked "not buildable" (iOS cannot draw a custom return key). Active boards unchanged.
- **Follow-up (threads 1e88540c, aa090e05, same request):** "Full · C · Stock keyboard, in-sheet Add only" and "Full · A · Stock keyboard + teal Add bar" get the same treatment, each keeping its own keyboard (C: stock with the neutral return key; A: stock plus the 44 pt teal Add bar). The three Minimal frames on that row are unchanged.
- **Fit:** content 5077 px; board grown 5040 → 5120 (file and canvas h); it is the last board in its column.
- **Classification:** MERGED (reference board sync). Production implementation not authorised.

### ED-152 · Q-A1 approved: no "Add another"; each Add tab has its own action
- **Date:** 2026-11-07. **Owner:** "My final decision for Q-A1 is OPTION A: DO NOT KEEP 'ADD ANOTHER'." Supersedes the earlier recommendation of option B (register Q-A1, 2026-11-06/07).
- **Authoritative Create task reference:** E-Phones "iPhone · Add a task: Create task (detailed), title focused (ED-140)": Add opens on the Task tab, title focused, native keyboard up. No return to the compact Add sheet.
- **Rules (the owner's, recorded verbatim in substance):**
  1. **Task tab:** the detailed Create task form; the Create task action shows only while Task is the selected tab; it creates one task with the approved validation and scheduling; on success the screen closes as already approved; on failure it neither clears nor closes; Return on a valid single task keeps the approved behaviour (G3-7 C). No "Add another" control of any kind (check, row, toggle).
  2. **Brain dump tab:** Create task disappears; the Brain dump interface with its own Plan it; Plan it produces a proposal for review and adds nothing; tasks are added only when the user accepts the proposal (Add to day), with the existing conflict, no-free-time and Inbox fallback handling. Create task is never Brain dump's submit action.
  3. **Routine tab:** Create task disappears; the approved Routine controls and its own actions (Drop on, pick a routine, preview, accept); repeat, scheduling and routine behaviour unchanged.
  4. **Conditional actions:** only the selected mode's actions are visible, in their approved places; Create task is never left visible, disabled, floating or duplicated on Brain dump or Routine.
  5. **Switching tabs** never creates tasks, accepts a proposal, saves a routine or discards input; each tab keeps its draft; existing unsaved-change safeguards apply on close.
- **Platforms:** Android keeps its M3 segmented buttons and full-screen shells (ED-141, ED-142, ED-148 to ED-150); iPhone keeps its native presentation (ED-140, ED-147, ED-149, ED-150). Minimal keeps its own Add sheet (no tabs, no "Add another"); no Full layout is forced onto Minimal. Mac / web capture unchanged.
- **Boards:** the active Add frames already follow rules 1–4 (checked 2026-11-07: Task frames show Create task; Brain dump frames show Plan it, no Create task; Routine frames show Drop on and routines, no Create task; Android the same). Three leftover "Add another" texts (two keyboard notes cards, one E-Map row label) and one header-title choice are listed for the owner's approval before editing (Q-A2a).
- **Classification:** DECIDED (owner). Board text fixes pending owner approval. Production implementation not authorised.

### ED-153 · CR-130 text fixes and Q-A2a: no title on iPhone Brain dump / Routine
- **Date:** 2026-11-07. **Owner:** "Yes, all four" (the four listed changes).
- **Changed:** (1) E-Phones-2 "How the keyboard is dismissed": "Return creates the task (or adds the next step); Create task closes after creating." (2) E-PhonesMinimal same card: "Return adds (or adds the next step); the Minimal Add sheet closes after adding." (3) E-Map row label "Quick Add (NL time)". (4) E-Phones-2 iPhone Add › Brain dump and Add › Routine: centre title removed, header = Cancel only, matching Create task (Q-A2a option A); captions updated. Android keeps its titles (New task / Brain dump / Routine).
- **Not changed:** the history board E-G2-8 (A2, A3 still show the title; reference only).
- **Verified:** no "Add another" text on any active board; E-Phones-2 4140 / 4200, E-PhonesMinimal 5043 / 5080, E-Map 4355 / 4380; canvas = local.
- **Closes:** Q-A2 (with Q-A2a), CR-130, CR-131.
- **Classification:** MERGED (design). Production implementation not authorised.

### ED-154 · G3-8 approved: inactive iPhone tab labels #6E6E73
- **Date:** 2026-11-07. **Owner:** "A · darker #6E6E73".
- **Decision:** inactive tab labels and icons on iPhone use `#6E6E73` (4.75:1 on `#FBF7F1`) in Full and Minimal; selected stays teal `#11615C`. Replaces the iOS system grey `#8E8E93` (3.06:1) on Full. iPad follows (Round 2).
- **Merged:** E-Phones (12 tab items) and E-Phones-2 (9) changed from `#8E8E93`; E-PhonesMinimal already used `#6E6E73`. E-Map notes it. A grey menu chevron icon (non-text) keeps the system grey. E-PhonesCalendar (approved review board, reference) keeps its original drawing.
- **Architecture note:** with the native tab bar (N3 / F2, ED-128) the colour is set through the tab bar's unselected-item appearance; whether iOS 26's glass tab bar honours a custom unselected colour is NOT VERIFIED (handoff, PENDING). Contrast over glass depends on what is behind it; measured on cream only.
- **Other platforms:** Android toolbar is icon-only (ED-125), unaffected; Mac and web sidebar secondary text to be checked against 4.5:1 (CR-132).
- **Verified:** E-Phones 7880 / 7920, E-Phones-2 4140 / 4200, E-Map 4355 / 4380; canvas = local.
- **Owner's confirming brief (2026-11-07), addressed:**
  - Selected teal, tab names, icons, sizes, destinations, Inbox badges and ED-124 / ED-132 geometry unchanged; the glass bar is not redrawn.
  - Icon audit: tab icons inherit the label colour (`currentColor`), so inactive icons are `#6E6E73` in Full exactly as Minimal already drew them; no separate icon colour exists or was changed.
  - Native implementation: the colour is set through the native UITabBar appearance for unselected items (N3 on iOS 26+, F2 on 16–25); the tab bar is never replaced by Flutter for this. Verification on iOS 18 and 26 (does Liquid Glass keep the colour?) and contrast over the real content scrolling beneath the glass stay PENDING. Increase Contrast, Bold Text, Reduce Transparency and Dynamic Type stay in scope; dark-mode colours wait for G4-6.
  - Android's icon-only toolbar unchanged.
  - Mac / web sidebar secondary text measured (CR-132): `#6A6273` = 4.75:1 on `#EFE7DB`, 4.55:1 on the measured vibrancy average `#E6E3DD`, 5.45:1 on cream; ink and teal pass; the indigo uses in sidebars are checkboxes and dots (non-text, 3:1 rule, pass). No change made; the 4.55:1 margin over vibrancy is thin, so other wallpapers are a PENDING Mac device check.
  - iPad (Round 2): the iPad tab bar / sidebar uses the same `#6E6E73` rule; layout not assumed.
- **Classification:** MERGED (design). Production implementation not authorised.


### ED-155 · G3-9 approved: darker ahead-ring shades, fills unchanged; ink check on amber
- **Date:** 2026-11-07. **Owner:** "For G3-9, I approve Option A — darker ring shades with task fills unchanged."
- **Tokens (one fill + one ring per task colour):** coral fill `#E2725B` / ring `#DF6147`; amber fill `#D9A23A` / ring `#AF7E22`; sky fill `#4A9BD6` / ring `#338ED1`; green fill `#4CA36B` / ring `#469763`. Other task colours keep ring = fill (they already meet 3:1). The ring token is used for the ahead-task ring and for the icon drawn inside that ring; done fills, the past thread, overlap knots, the current-task (now) progress ring and Wake Up / Wind Down stay on the fill colour. Glyphs on an amber fill (done check, task icon) are ink `#241F2B` (7.03:1) instead of white (2.29:1).
- **Merged (canvas `1794066219-c3df`, E-Map `1794066237-c9f8`):** E-Phones 60 ring uses + 21 amber glyphs; E-Phones-2 12 + 14; E-PhonesMinimal 26 + 3; E-FullA-v2 37 + 4 (ahead dots in Day/Week and the horizon); E-Minimal 6; E-Workspace 14 + 2; E-Map note. No sizes, spacing, type, navigation or behaviour changed. E-PhonesCalendar (reference) unchanged.
- **Scope note:** on amber done dots the task icon (not only the check) was white on amber; it is also switched to ink so the dot reads as one unit (same 2.29:1 failure). Revert to the check only if the owner prefers.
- **Contrast of the rendered rings:** against the adjacent inner card `#FFFDF9` 3.48–3.55:1; outer cream `#FBF7F1` 3.31–3.37; Minimal surface `#F3EEE6` 3.06–3.12; `#F6F1EA` 3.15–3.21. No ring sits on the Mac sidebar.
- **Flagged contexts (not changed, CR-133):** (1) the Minimal Add sheet's "Lands at" preview strip (aria-hidden) draws every other task's ring at 45 % opacity on purpose: effective 1.60–1.71:1; (2) rings behind a 30 % modal scrim drop to about 2.77:1 (inert background content); (3) the colour picker's selected-swatch halo uses the fill colour (coral 2.90:1) and is outside the ahead-ring rule.
- **State beyond colour:** ahead = hollow ring, done = filled dot + check, now = progress ring + "Now" text, unchanged.
- **Dark mode (G4-6):** ring tokens are light-mode values; dark-mode ring and fill shades are chosen in G4-6, not here. **Tablets (Round 2):** same tokens on iPad and Android tablets / foldables.
- **Classification:** MERGED (design). Production implementation not authorised.


### ED-156 · G3-9b (part): Mac and web custom colour picker approved; phone All colours becomes a half sheet
- **Date:** 2026-11-07. **Owner:** "i accept proposed for the MAC and Web"; for iPhone and Android "reduce the color circles … half pull up … so that when a user is selecting a color they are also able to see the title, icon and the background also reflect it"; "can android look like iphone … placement of the #F0A28E that is in same line with all colors".
- **Approved (visual design only):** Mac and web colour popover on `E-G3-9b-Screens`: Dottoday colours (6 × 2), Your colours (+, Edit), Custom colour… expanding in place (saturation/brightness field, hue strip, hex, eyedropper: native sampler on Mac, browser-permitting on web; live ahead/done preview with derived ring; Use and save, Cancel; Mac "Show Colours…" to the system panel).
- **Changed per owner (still proposals):** iPhone and Android ⋯ › All colours is a **half-height sheet** (medium detent; pull up for more), circles 30 pt with 44 pt touch targets, Colour and Shade sliders, hex in the title row on both platforms (Android matches iPhone), Dottoday colours and Your colours; the task title, dot, ring and band above stay visible and recolour live. The separate preview row was dropped, then **restored at the owner's request** ("include back the previous dots and how it would look like for done"): under the title row, the ahead and done dots in the chosen colour with the derived-ring note; the sheet's top moved up (iPhone 330 pt, Android 356 dp) so it stays a half sheet. The owner then asked to "also include the in progress": the preview now shows ahead · in progress · done on phones, Mac and web. The in-progress arc follows the approved now-ring rule (drawn in the fill), so for pale custom colours such as `#F0A28E` it is faint (about 2:1 on cream); open question Q-G3-9b-1: use the derived ring for the arc when the fill is under 3:1?
- **Still open in G3-9b:** palette items 1–5 (E shades, slate/Brown, Plum/Olive, teal/rose rings, app colours), the phone sheets, and the custom-colour data change (must-ask, Supabase).
- **Production implementation not authorised.**


### ED-157 · In-progress arc uses the ring shade for colours under 3:1 (Q-G3-9b-1)
- **Date:** 2026-11-07. **Owner:** "yes for: For pale colours, draw the in-progress arc in the darker ring shade".
- **Rule:** the now / in-progress progress arc (and its icon) uses the task colour's **ring** token; ring = fill for colours that already reach 3:1, so only colours under 3:1 change (coral, amber, sky, green, the proposed teal/rose rings, and any pale custom colour). Fills, done dots and the saved colour are unchanged. Amends ED-155's "now ring stays on the fill".
- **Shown on:** every preview on `E-G3-9b-Screens` (phones, Mac, web). Active boards' now rings are coral/amber/sky/green only where those tasks are running; not redrawn yet (to be merged with the palette decision).
- **Classification:** DECIDED (owner). Production implementation not authorised.

### ED-158 (proposal, not approved) · Settings › Appearance: theme thumbnails, App colour with Edit palette half sheet, live preview
- **Date:** 2026-11-07. **Owner request (with three reference screenshots):** Edit palette on the iPhone and Android Settings screen opens a half pull-up with all colours (same circle size as the task colour half sheet) so the app's theme change is visible while choosing; "This will not change the colour of existing tasks"; Light/Dark/Auto drawn after the owner's sample; Mac and web designed with UI/UX in mind.
- **Drawn on `E-G3-9b-Screens`:** iPhone 4 steps and Android 3 steps: Appearance page with a live preview card (week strip, three tasks in their own colours, tab bar and Create task in the app colour), Theme as three thumbnails Auto · Light · Dark (selected = outline + outlined label in the app colour), App colour circles (30 pt, 44 pt targets) with **Edit palette**, caption "Changes the app's colour to match your style. Existing tasks keep their colours." Edit palette opens a half sheet: hex in the title row, Colour and Shade sliders, Suggested (4), All colours (12), Your colours; the preview card above re-themes live. Mac: Settings window Appearance pane with theme thumbnails, App colour circles + Custom… (the approved popover panel), live Preview at the right. Web: same pane in the two-pane Settings, preview stacked above.
- **Accessibility:** a custom app colour keeps the saved hex; buttons and links use a derived shade (lightness only) that reaches 4.5:1 for white text on it and for it as text on cream (e.g. green `#7A9E4A` → `#5E7A39`).
- **Dark:** the Dark thumbnail is a neutral placeholder; dark colours are designed in G4-6.
- **Needs (must-ask):** saved accent hex and "Your colours" in settings (Supabase change), with the task-colour data change.
- **Owner follow-up (2026-11-07):** "switch them with more warm sweet colors like the samples … making sure that the current selected color is always there." App colour suggestions are now a warm set: Blush `#E9958E`, Peach `#F29E7C`, Honey `#E2A72E`, Sage `#8DBA6A`, Dusk blue `#6A88A8`, Pine `#2F7D5C`, Plum `#934B6E`, Ink navy `#2E4A6B`. The current colour is always the first circle (Teal `#11615C` by default, or the custom pick), in the App colour row and first in the half sheet's Suggested; the row swipes with a fade. All of these are light enough to need the derived button shade (4.5:1). This supersedes the palette board's item 5 (E shades of the 4 accent keys) as the proposal; the 4 stored accent keys would still map to their colours. Peach sits near the apricot rejected earlier as Concept E's accent; here it is only a choice, never the default.
- **Status:** PROPOSED, awaiting the owner.


### ED-159 (proposal, not approved) · Layout moves into Appearance; pinned live preview with Everything / Less motion; tab bar on Settings
- **Date:** 2026-11-07. **Owner (with three reference screenshots):** "remove the suggested current first"; "move the Layout from the settings homepage to the Appearance"; motion showing Everything vs Less in the same display used for the colour/theme preview; "that display remains fixed and every other thing added below scrolls up … but stays behind it"; "make sure the menu displays on the settings screen everywhere except when there is a pull up".
- **Drawn on `E-G3-9b-Screens`:**
  - iPhone (6): Settings root without the Layout row (Appearance subtitle now "Layout, theme, app colour, language, time"), tab bar and + visible; Appearance · Everything; Layout · Less (preview becomes the Minimal look: Now ring, Done, Next, Now · Today · Inbox); Scrolled (preview pinned under the title, content passes behind it with a thin shadow); Motion (the preview cycles Everything ↔ Less on the board, about 300 ms fold/fade; Reduce Motion = instant switch); Edit palette half sheet (tab bar hidden, Suggested removed).
  - Android (4): same, with the floating toolbar and + on Settings and Appearance, hidden under the half sheet; M3 segmented Layout.
  - Mac: Layout (Everything · Less) moves from General to the Appearance pane. Web: Layout leaves the Settings list column and joins the Appearance pane.
- **Supersedes if approved:** G1-4 / ED-084 placement "Layout first row of the Settings root" (and Mac General pane's Layout). Layout's behaviour, options and default are unchanged; only where it lives. Minimal mode's own Settings (E-PhonesMinimal) not changed yet: to be aligned once approved.
- **Status:** PROPOSED, awaiting the owner. Production implementation not authorised.


### ED-160 · Android toolbar: the selected item is highlighted as a whole (icon and label)
- **Date:** 2026-11-07. **Owner:** "for the menu button selection for android can you make this cover the whole selection just like the apple selection … when Today is selected on iPhone both the icon and Today is selected … I would like it to be so on android for every menu selection, inbox icon and name should be same etc".
- **Change (amends ED-125 C):** on the Android floating toolbar the selected destination gets one rounded highlight (`#CFE8E4`, text and icon `#062F2C`) behind both the icon and its label, instead of the M3 pill behind the icon only. Applies to every destination (Today, Inbox, Calendar, Search; Now, Today, Inbox in Minimal). Unselected items, badges, sizes, the + and the toolbar shape are unchanged. iPhone unchanged.
- **Merged on:** E-Phones (2 toolbars), E-Phones-2 (2), E-PhonesMinimal (2), E-G3-9b-Screens (Android Settings / Appearance), E-Map note. History board E-G3-6-Android keeps its original drawing.
- **Note:** this departs from the stock M3 NavigationBar indicator (icon-only); the toolbar is already a custom Flutter widget (ED-128 D5), so no platform conflict. TalkBack still announces "selected".
- **Verified:** E-Phones 7880 / 7920, E-Phones-2 4140 / 4200, E-PhonesMinimal 5043 / 5080; G3-9b screens 6818 / 6880.
- **Classification:** MERGED (design). Production implementation not authorised.


### ED-161 · G3-9b approved and merged: colour selection, App colour, Appearance with Layout
- **Date:** 2026-11-07. **Owner:** "I approve G3-9b · Colour selection on every platform".
- **Approved (as drawn on `E-G3-9b-Screens`, building on ED-156 to ED-160):**
  - **Task colours:** 12 Dottoday colours: coral, amber, sky, indigo, teal, rose, mint ("Green"), violet (existing keys, Concept E shades), slate (existing key, E shade `#6E6A75`), and new keys brown `#8C6A4F`, plum `#9E4F8F`, olive `#7F8A3A`; plus any colour (custom). Ring tokens per the approved G3-9 principle: coral `#DF6147`, amber `#AF7E22`, sky `#338ED1`, mint `#469763`, teal `#289588`, rose `#D75E89`; others ring = fill; custom colours derive ring and glyph at render time; the saved colour never changes.
  - **Pickers:** iPhone / Android Colour and icon sheet with ⋯ → All colours half sheet (hex in the title row, ahead · in progress · done preview, Colour and Shade, Dottoday colours, Your colours); Mac / web popover with Custom colour… (ED-156).
  - **App colour:** warm suggestions (Blush, Peach, Honey, Sage, Dusk blue, Pine, Plum, Ink navy) with the current colour always first; Edit palette half sheet / Custom…; buttons and links use a derived shade for 4.5:1; existing tasks keep their colours. Supersedes the palette board's item 5.
  - **Appearance:** pinned live preview (Everything ↔ Less with motion), Layout (moved here from the Settings root and Mac General, superseding the G1-4 / ED-084 placement), Theme thumbnails (Auto · Light · Dark), App colour, Format; tab bar / toolbar shown on Settings except under pull-ups.
- **Merged:** new board `E-Phones-3` (iPhone and Android colour flows and Settings/Appearance); `E-Phones` (Colour and icon sheet: 12 colours + ⋯; iPhone and Android Settings roots without Layout, with tab bar / toolbar; captions); `E-PhonesMinimal` ("Opens: Settings root" inset = new root; the minimal list keeps its Layout row as the way back, an approved entry point); `E-FullA-v2` (Mac Settings window → Appearance pane with Layout and Preview; web two-pane Settings → Appearance; inspector colour popover → 12 colours + Your colours + Custom colour…; row wraps; board 6740 px); teal / rose rings and ED-157 ring-shade arcs on E-Phones, E-Phones-2, E-PhonesMinimal, E-FullA-v2, E-Minimal, E-Workspace; E-Map note (4440 px). Canvas: E-Phones-3 at (30, 24960), E-FullA moved to y 29720.
- **Must-ask before any build:** custom task colours and custom app colours need stored hex values and a synced "Your colours" list (Supabase migration); new keys brown / plum / olive need the allowed `color_key` set extended. Dark-mode values in G4-6. Tablets in Round 2.
- **Classification:** MERGED (design). Production implementation not authorised.


### ED-162 · G3-10 approved: one vocabulary, native Mac menu conventions
- **Date:** 2026-11-07. **Owner:** "For G3-10, I approve Option A — One vocabulary across Dottoday, with native Mac menu conventions."
- **Vocabulary:** Low-energy mode; Brain dump; Review (singular); Today for the screen, Day for the actions menu; Need more time? (question) and Need More Time… (opens +5 / +15 / +30); Delete on phones (and web), Move to Trash ⌘⌫ in Mac menus, both the same deletion workflow (Trash 30 days, Undo 30 s, verified read-only in the original app). Mac menus in Title Case (Low-Energy Mode, Brain Dump…).
- **Boards changed (canvas `1794080104-b060`):** E-Phones (caption), E-PhonesMinimal (two captions), E-FullA-v2 (fidelity list and captions: Need More Time…, Review, Low-energy name resolved), E-Minimal (Mac View menu and finder "Review"; captions), E-Workspace (Day menu "Need More Time… ▸" and its submenu, ⌘K palette "Need more time · +15 min"), E-Map (feature rows, open list, Mac interaction note, C references). E-Phones-2 and E-Phones-3 already used the approved names. Verified: no "Running late", "Reviews", "Gentle Day" or "Low-energy day" on any active board; all boards fit.
- **Historical:** older decisions, history boards and snapshots keep the old words as evidence; they are superseded by this entry (marked in the rules' inconsistency table I15, I21, I23, I24, I30, N10 and the screen inventory).
- **Internal names unchanged:** l10n keys `runningLate*` etc.; only visible strings change (handoff).
- **Classification:** MERGED (design). Production implementation not authorised.


### ED-163 · G3-11 approved: Need more time offers +5, +15 and +30 everywhere
- **Date:** 2026-11-07. **Owner:** "For G3-11, I approve Option A — +5, +15 and +30 minutes everywhere."
- **Behaviour (unchanged from the built app):** exactly three choices; each keeps the existing extension, scheduling, overlap and free-time rules, in the task's own date context; applied once and only on the user's choice. Nothing is applied by opening a sheet, menu or palette. No-shame wording from ED-162.
- **Presentation:** iPhone and Android sheets and Now cards: three 44 pt chips, row wraps under the label at 200 % text (checked headless: no clipping, nothing pushed out). Mac: Need More Time… submenu, three items (already drawn). Web: popover with three items. ⌘K: "Need more time · +15 min" plus Need More Time… for the others. Accessible names "Extend task by 5 / 15 / 30 minutes". iPad and Android tablets: three choices are a requirement for Prompt D Round 2; layout not assumed.
- **Boards changed (canvas `1794080578-9c6b`):** E-Phones (3 sheets), E-PhonesMinimal (3 rows, captions), E-Minimal (Mac and web Now cards, web popover, captions), E-Workspace (2 inspectors), E-FullA-v2 (increments note), E-Map (Now popover row, resolved note). E-Phones-2 and E-Phones-3 have no extension control; none added.
- **Classification:** MERGED (design). Production implementation not authorised.


### ED-164 · G3-12 approved: done tasks fold into "Earlier", with no count
- **Date:** 2026-11-07. **Owner:** "For G3-12, I approve Option A — Fold completed tasks into "Earlier", with no count."
- **Rule:** see `E_DESIGN_RULES.md` "Earlier fold". Done tasks before now fold into one collapsible "Earlier" row; no count or number; only done tasks fold; no empty group; expanded rows keep time, colour, done appearance and actions; reopening returns the task to its time; presentation only.
- **Scope:** Minimal Today on phones, Minimal Day column on Mac and web, and the Full Mac/web Day column where the fold was already drawn. Full phone threads and other Full screens unchanged; approved Full counts kept.
- **Boards (canvas `1794081347-9d2f`):** new active board **E-Earlier** (10 frames: iPhone collapsed, expanded, reopened, nothing done yet; Android collapsed and expanded; Mac collapsed with focus and expanded with focus on a done row; web expanded and reopened). E-PhonesMinimal (3 rows relabelled "Earlier", Show added, caption approved), E-Minimal (2 rows, captions), E-FullA-v2 (Day column row), E-Map (rows and resolved note), canvas.json (board added at x 2825, y 17720).
- **Verified:** board fit (E-Earlier 2060/2140; E-PhonesMinimal 5043/5080; E-Minimal 4280/4320; E-FullA-v2 6713/6740; E-Map 4410/4440); no new clipping; live files equal the published copies.
- **Docs:** doc 14 §4 amended; the old sentence is kept struck through with a superseded note.
- **Not covered:** the Now horizon's spoken summary still contains "3 done" (CR-138, raised as an owner question).
- **Classification:** MERGED (design). Approved design requirement; not implemented or tested in the app.


### ED-165 · Group 3 follow-ups: CR-138, CR-134, CR-133, colour data, cleanup batch
- **Date:** 2026-11-07. **Owner:** approved removing count-based screen-reader summaries in Minimal (CR-138); confirmed CR-134; conditionally accepted CR-133 per context; withheld any data, identifier, schema or migration change for colours; asked for a bounded cleanup batch.
- **CR-138 (APPLIED):** the minimal horizon's accessible name now reads e.g. "Day horizon, 7 AM to 11 PM, now 10:42. Now: Deep work: roadmap, 18 min left, and Call with Sam, until 11:00. Next: Lunch at 12:30. Earlier: Morning run, Coffee and plan the day and Team standup, done." No done or ahead counts. The now-dot's "85 percent through" became "now, 18 minutes left" (doc 14 rule 5: no percentage). Each horizon dot keeps its own name with time and status. The three Minimal task-sheet backgrounds that still showed "3 of 9 done · 7 h 40 planned" now show "Rest of today · until Wind Down at 11:00 PM". Remaining time and durations are kept because they are needed to act. Boards: E-PhonesMinimal, E-Minimal, and the E-Minimal reference frame on E-FullA-v2. Full screens keep their approved counts.
- **CR-134 (RESOLVED, no board change):** intentional. Minimal Settings keeps Layout at the top level as the way back to Full; Full keeps it under Appearance (ED-161). Both are the same view-mode setting with the same switching safeguards, state kept and unsaved-edit handling (ED-064 onwards).
- **CR-133 (VERIFIED per context):**
  - (1) *Faded "Lands at" preview*: decorative. The strip is `aria-hidden`, and the information is in text that meets contrast ("Lands at 6:00–7:00 PM · free, no overlap"). Acceptable.
  - (2) *Rings behind a dimmed backdrop*: obscured and not interactive while a modal sheet is open. Acceptable **on condition** that every sheet drawn with a dimmed backdrop is modal (background inert to touch and screen readers). Added to the handoff, because the boards do not mark this.
  - (3) *Selected-colour halo*: the halo alone is low contrast (coral 2.90 : 1), but every selected swatch on the active boards also carries a check glyph at 3 : 1 or better (white on coral 3.09, violet 4.23, indigo 5.18; ink on pale colours per ED-161), plus `aria-checked`. Selection does not rely on the halo. Acceptable; the rule now requires the check.
  - None needed a correction. The G3-9 and G3-9b palettes are unchanged.
- **Colour data:** see `E_COLOUR_DATA_REVIEW.md`. Review only; no change authorised.
- **Cleanup batch:** see `E_CLEANUP_BATCH.md`.
  - **APPLIED, following existing approvals, no change to an approved visual:**
    - CR-100 hit areas, with drawn sizes unchanged (rules §6.4).
    - Android Day menu surface token (I13).
    - E-Minimal's Mac sidebar material (ED-130).
    - CR-135.
  - **NO CHANGE:** I1 (already documented), I8 (already resolved), CR-011 (control no longer drawn).
  - **Waiting on the owner:** 13 items that need a visual choice.
- **Canvas:** `1794083800-6a81` (E-Phones, E-Phones-2, E-PhonesMinimal, E-Minimal, E-FullA-v2) and `1794084013-af5b` (E-Map: G4-1 and follow-up notes, board grown 4440 → 4600, fits 4559/4600); verified fit, no moved text, no new clipping; live = local. Snapshot `v1.36-working`.
- **Classification:** design records; device behaviour not verified; no data change.

### ED-166 · G4-1 approved: Round 2 draws the core journey first
- **Date:** 2026-11-07. **Owner:** "I approve Option A: CORE JOURNEY FIRST. … It does not authorize starting Prompt D Round 2 or building the app."
- **Order:**
  - (1) **Core task journey:** Today → Add → Edit → Complete → Change day → Reopen, each step connected to the next, with the approved Full and Minimal differences kept.
  - (2) **Interaction and recovery:** Multi-select and selection bar → Undo → sync conflict → Focus session.
  - (3) **Supporting experiences:** Wake Up and Wind Down → Settings → onboarding → relevant system surfaces.
- **Platforms:**
  - iPhone and Android: the core journeys, keeping their distinct native navigation.
  - Mac and web: the Full and Minimal workflows, including Add, Focus, Inbox and Search.
  - iPad, Android tablets and foldables: stay with G4-4 and Round 2. Phones are not assumed to scale up.
- **Inventory:** the order covers every undrawn screen (CR-069 to CR-090); nothing is dropped. Screens outside the three stages are drawn after them, still in Round 2.
- **Classification:** RESOLVED (planning). Round 2 not started; nothing built.


### ED-167 · G4-2 approved: 600 / 840 kept; the editor docks only from 1160
- **Date:** 2026-11-07. **Owner:** "For G4-2, I approve Option C — retain the 600 / 840 layout breakpoints, but dock the task editor only from 1160 px when there is sufficient usable space."
- **Approved strategy:** see rules §12.2. Classes stay 600 / 840 (window width, logical pixels). The editor floats below 1160 and docks from 1160 when the minimum widths hold. This supersedes the 1100 rule. Breakpoint changes never save, never lose state and never commit a proposal.
- **Read-only check of the built app:**
  - `WidthClass` (600 / 840) is applied to the window's width (`LayoutBuilder` constraints or `MediaQuery.sizeOf`), safe areas included.
  - The editor panel (420) docks at expanded, i.e. from 840. ED-167 changes that when it is built.
  - iPhone supports landscape (`Info.plist`).
- **Landscape phones (CR-139):** width alone gives expanded to most landscape phones (e.g. 874 × 402) and medium to small ones (667 × 375). Both are desktop or tablet layouts on a screen about 400 tall. A narrowly scoped correction (H1: available height < 480 keeps the compact layout and never docks) is **proposed, not approved**. Thresholds unchanged; no device check.
- **Minimum widths (CR-140):** proposed M: Today ≥ 480 (≥ 600 above 130 % text), editor 420, sidebar 216. **Not approved.**
- **Board:** new **E-Responsive**, schematic at 25 %:
  - widths 599/600, 839/840, 960, 1099/1100, 1159/1160 and 1280;
  - short and narrow desktop and web windows;
  - iPad portrait, landscape and Split View (navigation reserved for G4-4);
  - 200 % text;
  - landscape phones, width-only versus H1.

  E-Map: G4-2 note added, and the old 720 / 1160 proposal marked superseded (board grown 4600 → 4760).
- **Canvas:** `1794084547-f629`; fit E-Responsive 2246/2260, E-Map 4691/4760; live = local. Snapshot `v1.37-working`.
- **Classification:** strategy APPROVED; H and M OPEN; device, responsive and 200 % behaviour PENDING; nothing built.


### ED-168 · G4-2 refinements approved: H1 short height and M docking minimums
- **Date:** 2026-11-07. **Owner:** "H — APPROVE H1 … M — APPROVE the proposed minimum widths."
- **H1:**
  - When the window's usable height (after safe areas, not counting the software keyboard) is under 480 logical pixels, use the compact layout and never dock the editor. This is based on available space, never on the device model.
  - The 600 / 840 width thresholds are unchanged.
  - Platform chrome stays native: a short web window keeps web chrome (the mobile-web navigation itself is G4-5), and a Mac window can't reach H1 (minimum height 640).
  - Full and Minimal never switch.
  - Opening or closing the keyboard never changes the layout class or resets the editor.
- **M:**
  - Minimums: Today 480 (600 when text is above 130 %), editor 420, sidebar 216.
  - The editor floats below 1160 regardless. From 1160 it docks only if these minimums, plus dividers, gutters, margins and any other visible element, all fit.
  - The large-text threshold is computed from the real layout, not fixed at 1236. At any limit, float rather than squeeze or clip.
- **State:** changing class (compact, medium, expanded) or editor presentation (floating, docked) never saves or discards text, never commits a proposal, never changes the task, date or Full/Minimal mode, never duplicates the editor, and never resets steps, notes, focus or scroll.
- **Board E-Responsive (updated):**
  - H1 and M frames are marked approved; the width-only landscape frames are kept as "not used".
  - New frames: 1160 at 130 % (docks) and 140 % (floats); a 1280 × 460 web window under H1, with web chrome.
  - New row 6: iPhone landscape with the keyboard open, iPad landscape with the keyboard open (stays expanded and docked), foldable tabletop half (H1), foldable unfolded, iPad Split View ⅓.
  - Fit 2665/2700. No clipping or overflow found in the rendering (schematic, 25 %).
- **E-Map:** G4-2 note updated.
- **Canvas:** `1794084987-b330` (also adds the G4-3 decision board). Live = local. Snapshot `v1.38-working`.
- **CR-139, CR-140:** RESOLVED.
- **Classification:** responsive rules APPROVED; device and accessibility behaviour (landscape phones, keyboard, foldables, Split View, 100 / 130 / 200 % text) PENDING testing; nothing built.


### ED-169 · G4-3 approved: Mac minimum window 840 × 640 (design only)
- **Date:** 2026-11-07. **Owner:** "For G4-3, I approve Option B — Mac minimum window size of 840 × 640 logical pixels. … This is design approval only. Do not edit `MainFlutterWindow.swift`."
- **Approved:**
  - The minimum window is 840 × 640. It still opens at 1280 × 800.
  - At 840 the window is in the expanded class, and the editor floats; G4-2's 1160 rule and the M minimums are unchanged.
  - 640 is above H1's 480, so the Mac never gets the compact layout.
  - The Mac-native sidebar (with the ED-130 vibrancy), menus and shortcuts stay; no phone navigation.
  - Resizing never changes the view mode, saves a draft or discards content.
  - The built app is unchanged at 960 × 640 until implementation is authorised.
- **Full at 840–959:** the expanded Workspace with sidebar 216 and Inbox 196; the week grid shows the days that fit, with Today kept in view; the inspector floats. Drawn on E-G4-3-Narrow.
- **Follow-up proposals awaiting the owner's visual review (not approved):**
  - (1) **Minimal Day-column fold.**
    - Fold point computed from content: sidebar 200 + Now minimum 550 (action row 460 measured + padding 2 × 45) + Day column 290 + dividers = **1042 at 100 % text**. It rises with text size (about 1500 at 200 %, computed rather than rendered).
    - When folded, a 44 px edge button "Day ⌘2" opens the same Day column as a non-modal panel over Now. Esc, ⌘2 or ✕ closes it, and focus returns to the button.
  - (2) **Narrow toolbar:** below 1000 it drops the status text, and Search shows its icon with ⌘K.
  - (3) **Short height:** below 720 tall, the now-dot draws at 72 % and the Now pane scrolls.
  - (4) **C1, Full inspector versus M:** E-FullA-v2 docks a 248 inspector at 1280, but M (editor 420) would make it float. Recommended: M applies to the 420 task editor; the Workspace inspector keeps 248 and docks from 1160 when the grid keeps at least 3 days.
- **Boards (canvas `1794085453-26c4`):**
  - E-G4-3: B marked approved; kept as history.
  - New **E-G4-3-Narrow**: real E-FullA-v2 and E-Minimal Mac windows, resized, at 50 %. Frames: Full 840, 960, 1160 (C1) and 1280; Minimal 840 folded, 840 with the panel open, 960 with a long title and menu open, 1041, 1042, 1160 and 1280.
  - E-Responsive: the Mac minimum frame is now 840.
  - E-Map: note added, board grown to 4900.
  - Verified: fit (Narrow 1777/1860; E-Map 4823/4900; E-Responsive 2665/2700); live = local.
- **Snapshot:** `v1.39-working`.
- **PENDING:** 200 % text (rendering), keyboard focus order and VoiceOver, resizing with unsaved edits, and device behaviour.


### ED-170 · Narrow Mac refinements approved; C1 (a): the inspector is not the editor
- **Date:** 2026-11-07. **Owner:** approved the adaptive Day-column fold, the narrow toolbar with corrected shortcut meaning, the short-window now-dot (conditionally), and C1 option (a).
- **Day-column fold:**
  - Folds when sidebar 200 + Now minimum + Day column 290 + dividers and margins don't fit. The Now minimum is 550 at 100 % text (measured), so the fold point is ≈ 1042. At larger text it is recomputed from the content, not fixed.
  - When folded, a 44 px edge button labelled **"Day"** (no shortcut) opens the same Day column as a panel over Now: not modal, not dimmed. Esc, ✕ or the button closes it, and focus returns to the button.
  - There is only one Day column. Resizing never saves, discards or changes the date, task, view, focus or scroll.
- **Shortcut correction (owner):**
  - ⌘1 Now · ⌘2 Inbox · ⌘3 Calendar · ⌘4 Search · ⌘K Search or run (the command palette), all unchanged.
  - The label "Day ⌘2" I proposed was wrong and is removed.
  - Rules line "Now ⌘1, Day ⌘2, Calendar ⌘3, Inbox ⌘4" is superseded (it contradicted rules §11 and the board).
  - View › Show Day Column remains the menu command. Its key appears as both ⌥⌘D (rules) and ⌥⌘I (E-Minimal); this is an open inconsistency (CR-143), and no new shortcut is assigned. *(Resolved in ED-218: ⌥⌘I.)*
- **Narrow toolbar:** below ≈ 1000 the status text is hidden. "Search or run" (the ⌘K palette) collapses to an icon with an accessible name and tooltip. The Search screen stays ⌘4 in the sidebar; the two are not combined.
- **Short window:** under 720 tall the now-dot draws at ≈ 72 % and the Now pane scrolls. Above 130 % text the dot keeps full size and its numeral does not grow; text wraps and the pane scrolls. Checked at 840 × 640 at 100 / 130 / 200 % (rendered from real E-Minimal markup with scaled text): no clipping of time, progress or title.
- **C1 (a):** the Workspace inspector (248) and the full task editor (420) are different surfaces.
  - The inspector docks from 1160 when the week grid keeps ≥ 3 usable days (3 × 144 + 44 = 476) and everything fits; otherwise it floats.
  - The editor keeps 420, and Today 480 / 600 where approved.
  - The 1280 Workspace is unchanged.
- **Boards (canvas `1794085999-d417`):**
  - **E-G4-3-Narrow** is now the active narrow-Mac reference. Frames: Full at 840, 960, 1042, 1160 and 1280; Minimal at 840 (folded and panel), 960 (long title, menu), 1041, 1042, 1160 and 1280; Minimal at 840 × 640 with 130 % and 200 % text.
  - E-Minimal and E-FullA-v2 have pointer captions.
  - E-Responsive and E-Map are updated.
  - Fit: Narrow 2330/2400, E-Responsive 2755/2760, E-Map 4955/5040, E-Minimal 4280/4320, E-FullA-v2 6739/6780. Live = local.
- **PENDING:** physical device, VoiceOver and Tab order, resizing with unsaved edits.

### ED-171 · G4-4 approved: tablet navigation by width class, native per platform (strategy only)
- **Date:** 2026-11-07. **Owner:** "I select Option A as the responsive navigation direction, refined for each platform. … The actual tablet screens, detailed navigation geometry, transitions and control placement still require visual design and review in Prompt D Round 2."
- **Width classes:** compact < 600, medium 600–839, expanded ≥ 840 (window, not device), plus H1 and the editor/inspector rules.
- **iPad:**
  - iPadOS-native adaptive navigation (top tab bar that becomes a sidebar, split views); no Material rail.
  - Medium windows get compact tablet navigation; expanded windows get a richer workspace.
  - Same information architecture, without Mac window chrome.
  - Touch, pointer, hardware keyboard, Apple Pencil where relevant, Split View and resizing.
- **Android tablets and foldables:**
  - Material navigation rail at medium, a sidebar when expanded, and the approved Android compact navigation when compact.
  - Hinge-aware; handles insets, 48 dp targets, keyboard, mouse and resizable windows.
- **Not allowed:** the phone bottom row enlarged and called the tablet design; assuming an iPad's class from its orientation.
- **Status:** strategy APPROVED; tablet screens NOT DRAWN (Round 2, not started). Not visually complete.


### ED-172 · G4-5 approved: a proper compact mobile web
- **Date:** 2026-11-07. **Owner:** "For G4-5, I approve Option A — a proper compact mobile-web experience."
- **Layout:**
  - 600 / 840 classes and H1 apply.
  - Compact web has its own web bottom bar: solid surface, hairline, labelled icons and the web focus ring. It never imitates the iOS glass tab bar or the Android frosted toolbar.
  - Full keeps Today · Inbox · Calendar · Search; Minimal keeps Now · Today · Inbox. Add, Brain dump, Routine, Inbox, Calendar, Search, editing and every task action stay. Not reduced to Today.
- **Browser:**
  - The G2-11 / ED-097 hash routes are unchanged and checked against the table: phone width uses the phone column; `/#/now`, `/#/today`, `/#/day/:date`, `/#/inbox`, `/#/search`, `<view>?task=<id>` by rule T, `/add` as built. No new routes.
  - Back, Forward and refresh restore view, date and task; sign-in guards and unsaved-edit safeguards are kept.
  - No custom edge-swipe; the browser's own gestures work.
- **Interactions:**
  - Web menus, dialogs and sheets.
  - Safe areas, browser bars and the keyboard are respected through the visual viewport. The bottom bar never covers fields, Add or task actions, and it is not drawn over the keyboard.
  - Touch, keyboard and screen readers; single-key shortcuts keep their off switch (WCAG 2.1.4); state and unsaved text survive reflow.
- **Board (canvas `1794086583-82a8`):** new **E-MobileWeb**, built from real E-Phones and E-PhonesMinimal content in browser chrome:
  - Full in Safari at iPhone width (`/#/today`) and Minimal in Chrome at Android width (`/#/now`);
  - Add with the keyboard open;
  - a task link (`?task=`), then after Back;
  - landscape short height (H1).

  E-Responsive and E-Map have notes (E-Map grown to 5180). Fit: E-MobileWeb 1978/2040, E-Responsive 2754/2760, E-Map 5066/5180. Live = local.
- **Wider windows:** medium and expanded as desktop web; tablet browsers follow G4-4 (Round 2).
- **Found:** rules §11's Web row still described path URLs (`/now?task=…`, `/plan/day/…`) from before ED-097; marked superseded (CR-145).
- **Classification:** strategy APPROVED; browser behaviour (Back, Forward, refresh, keyboard, safe areas, screen readers) PENDING testing; nothing built.


### ED-173 · G4-6 option A approved (process); Stage 1 dark token system presented
- **Date:** 2026-11-07. **Owner:** "For G4-6, I approve Option A — Dark-mode tokens first, then key frames. … Begin with Stage 1 only. Publish the dark token comparison board and stop for my review."
- **Approved:** the three-stage process (tokens → key frames → consistency). No token value is approved yet.
- **Presented on E-G4-6-Dark-Tokens (canvas `1794087849-2977`), all values proposals:**
  - **P1 "Warm charcoal" (recommended):**

    | Token | Value |
    |---|---|
    | ground | #171416 |
    | surface | #1F1B1E |
    | raised | #28232A |
    | sheet | #2F2A30 |
    | popover | #37313A |
    | text | #F3ECE4 |
    | secondary | #C7BEC4 |
    | disabled | #8C838A |
    | divider (decorative) | #3E373D |
    | outline (controls) | #8C838A |
    | teal | #5BC4B8 with ink #0C2523 |
    | tonal | #1E3A37 / #A3E2D9 |
    | focus | #7FD6CB |
    | error / warning / success | #F2907F / #E9B864 / #82CF9F |

  - **P2 "Deeper ink"** is shown as the alternative.
- **Task colours (12):**
  - Each colour keeps its light fill on dark when that fill reaches 3:1 on every dark surface (coral, amber, sky, teal-green, rose, green, olive). Otherwise it is lightened in the same hue (indigo #6D71DB, violet #926DE5, slate #7E7A86, brown #9B7557, plum #B061A1).
  - The ring, the now arc and the done fill use that dark fill. Glyphs and checks inside filled dots use the ground ink (≥ 4.37:1). The now track is the colour at 25 % (decorative).
  - Keys are unchanged; brown, plum and olive stay unapproved keys.
- **Measured (P1):**
  - text ≥ 10.8:1 and secondary ≥ 7.0:1 on every surface;
  - teal ≥ 6.0:1; outline ≥ 3.45:1;
  - every task ring ≥ 3.02:1 on every surface;
  - state text ≥ 5.4:1.
- **Corrections proposed:**
  - (1) The iOS switch on-tint in dark becomes #2A8C83: the approved #11615C is only 2.1:1 on dark rows. Light mode keeps #11615C.
  - (2) The focus ring always has a 2 px surface gap: it is 1.2:1 next to a teal button.
- **Material recipes (proposed):**
  - iPhone: genuine dark Liquid Glass with no app tint; iOS 16–18 thin-material fallback; Reduce Transparency and Increase Contrast variants.
  - Android: a dark tonal floating toolbar at 78 % with blur, plus a solid fallback.
  - Mac: the light #EFE7DB tint is not reused. Options D1 (#3B2F2A at 30 %, recommended), D2 (at 45 %) and D3 (no tint), simulated over three wallpapers; Reduce Transparency solid #231F22.
  - Web: solid surfaces with `color-scheme: dark` and no flash on load.
- **Theme behaviour:** Light · Dark · Auto. Switching keeps edits, task, date, proposals, navigation and editors.
- **Status:** Stage 1 AWAITING APPROVAL. Stage 2 not started; no active board changed. Glass and vibrancy on devices: PENDING.


### ED-174 · G4-6 Stage 1: P1 approved; ring-margin and Mac D1 follow-ups presented
- **Date:** 2026-11-07. **Owner:** approved P1 Warm Charcoal (not P2), the 12-colour approach subject to a contrast-margin review, the dark iOS switch tint #2A8C83 (light stays #11615C), the 2 px focus gap, the control and foreground rules, and the iPhone, Android and web material directions. Mac: prefers D1 (#3B2F2A at 30 %), pending genuine native verification.
- **APPROVED tokens (P1):**

  | Token | Value |
  |---|---|
  | ground | #171416 |
  | surface | #1F1B1E |
  | raised | #28232A |
  | sheet | #2F2A30 |
  | popover | #37313A |
  | text | #F3ECE4 |
  | secondary | #C7BEC4 |
  | disabled | #8C838A |
  | divider | #3E373D |
  | outline | #8C838A |
  | teal | #5BC4B8 with ink #0C2523 |
  | tonal | #1E3A37 / #A3E2D9 |
  | focus | #7FD6CB (2 px gap) |
  | error / warning / success | #F2907F / #E9B864 / #82CF9F |
  | iOS switch on (dark) | #2A8C83 |

- **Task colours: approach approved, values NOT FROZEN.**
  - The Stage 1 values stand: coral, amber, sky, teal-green, rose, green and olive keep their fills; indigo #6D71DB, violet #926DE5, slate #7E7A86, brown #9B7557, plum #B061A1.
  - Proposed margin lift to at least 3.5:1 on all five dark surfaces, same hue and saturation, lightness only:

    | Colour | Revised | Min contrast |
    |---|---|---|
    | indigo | #7A7EDE | 3.53 |
    | violet | #9672E6 | 3.52 |
    | slate | #898590 | 3.50 |
    | brown | #9B7557 → #A67F60 | 3.50 |
    | plum | #B76FA9 | 3.52 |
    | olive (optional; its approved fill passes at 3.37) | #828E3C | 3.54 |

  - Done checks stay ≥ 5.07:1 in ground ink. These revisions **await approval**.
- **Mac D1, native verification (genuine, not simulated):**
  - **Sample:** a throwaway AppKit sample outside the repo; the ED-129 sample had been cleared from the scratch folder, so it was rebuilt with the same setup. Dark appearance; NSVisualEffectView `.sidebar`, behind-window, active; #3B2F2A layer at 30 %; P1 text drawn natively.
  - **Captures:** striped blue, light and red synthetic backdrops, taken with `screencapture` on this Mac (macOS 26.6.2) for D1 and for no tint.
  - **Measured in the captures:**
    - show-through spread up to 5.1 (no tint 7.6), so vibrancy is kept;
    - primary text ≥ 7.05:1 and secondary ≥ 4.56:1 at worst (light backdrop); D1 beats no tint on every backdrop.
  - **Finding:** teal as a 14 pt label is 3.95:1 on the light backdrop and 3.07:1 on its 18 % selection pill.
  - **Proposed correction, awaiting approval:** in dark Mac sidebars the selected row label uses #F3ECE4 (5.48:1 on the pill at worst); teal stays on the pill and the icon.
  - **Not captured:** Reduce Transparency (changing the system setting was not done) and Increase Contrast: PENDING.
  - Sources and captures are in `references/concept-e/v1.43-working/macspike/`.
- **Unapproved persisted keys:** brown, plum and olive (visual proposals only). No storage or schema change.
- **Theme behaviour:** Light · Dark · Auto. Switching keeps task, date, navigation, Full/Minimal, unsaved text, focus and cursor, open proposals and editing context; it never saves, discards or commits.
- **Board:** E-G4-6-Dark-Tokens updated: P1 approved; new section 4 (ring revisions) and section 5 (native captures). Canvas `1794088620-9ecd`; fit 4665/4720; E-Map note at `1794088693-ab41` (5198/5300); live = local.
- **PENDING:** physical-device and accessibility tests (glass on device, VoiceOver, TalkBack, Reduce Transparency, Increase Contrast).
- **Status:** Stage 1 approved in part. Ring revisions and the Mac label correction await approval before tokens are frozen. Stage 2 not started.


### ED-175 · Dark task colours frozen (P1)
- **Date:** 2026-11-07. **Owner:** approved all six refinements, olive included.
- **Dark values (APPROVED):**

  | Colour | Dark value |
  |---|---|
  | coral | #E2725B |
  | amber | #D9A23A |
  | sky | #4A9BD6 |
  | indigo | #7A7EDE |
  | teal-green | #2A9D8F |
  | rose | #D9668F |
  | green | #4CA36B |
  | violet | #9672E6 |
  | slate | #898590 |
  | brown | #A67F60 |
  | plum | #B76FA9 |
  | olive | #828E3C |

- **Measured:** each colour is ≥ 3.50:1 on all five dark surfaces (the unchanged ones ≥ 3.76:1); done checks in ground ink are ≥ 5.07:1.
- **Use in dark:** the ahead ring, the now arc and the done fill.
- **Unchanged:** light mode, including the light ring tokens of ED-155.
- **Data:** a dark visual token approval only. Brown, plum and olive persisted keys stay unapproved; no storage, identifier, task, Supabase or migration change.

### ED-176 · Dark Mac sidebar approved: D1 with a primary-text selected label
- **Date:** 2026-11-07. **Owner:** approved genuine NSVisualEffectView vibrancy, the D1 tint #3B2F2A at 30 %, the selected-row label in #F3ECE4, and the teal highlight and icon. The light 35 % #EFE7DB tint is preserved.
- **Verified natively:** two runs, three striped backdrops (blue, light, red), default system settings. **Valid only for these backdrops and settings.**
  - Label on the selection pill ≥ 5.17:1.
  - Badge vs sidebar ≥ 4.14:1; digit on the badge 7.99:1.
  - Focus ring #7FD6CB vs sidebar ≥ 4.92:1.
- **Finding:** the selected icon in approved teal is 2.89:1 on the pill over the light backdrop. Choice **I1** (#A3E2D9, ≥ 4.20:1, recommended) or **I2** (#7FD6CB, ≥ 3.60:1) awaits the owner.
- **PENDING:** Reduce Transparency, Increase Contrast, VoiceOver, keyboard order and other wallpapers.

### ED-177 · Dark detail tokens derived; Stage 2 key frames presented
- **Detail tokens (derived from P1; on E-G4-6-Dark-Tokens §7):**
  - **Caps:** Wake Up is amber at 22 % over surface (#483924) with an amber icon (4.87:1); Wind Down is indigo at 22 % (#333148) with icon #A9ACEB (5.85:1).
  - **Large now-dot:** centre raised #28232A, numeral #F3ECE4 (13.1:1), "min left" #C7BEC4 (8.5:1), arc in the task's dark colour (indigo 5.11:1 on ground), track at 25 % (#302F48, decorative).
  - **Thread:** solid segments in the task's dark colour; the overlap knot uses the two task colours.
  - **Now-bead:** #5BC4B8 (8.74:1) with a 2 px ground border and a 45 % ring; time pill teal on raised (7.36:1) with a 35 % edge; now line teal at 30 % (decorative).
- **Open choices (shown with alternatives):**
  - **I1 / I2:** colour of the selected Mac icon.
  - **T1:** whether the now-dot has a shadow. Recommended: none.
  - **T2:** strength of the dotted "ahead" thread. T2-A #4A4348 (1.91:1, parity with light's decorative 1.84) or T2-B #6B6369 (3.15:1, recommended).
- **Stage 2 board E-G4-6-Dark-Frames (canvas `1794089382-1995`):**
  - **Light and dark pairs:**
    - iPhone Full Today and Minimal Now;
    - Android Full Today and Minimal Now;
    - Create task, Brain dump, Routine;
    - Task editor with the colour and icon picker;
    - the Minimal menu over Today;
    - Mac Full Workspace and Minimal;
    - web Full Workspace and Minimal.
  - **Method:** each dark frame is the approved light frame converted with the approved token map. Layout, copy and interaction are unchanged; the iOS dark keyboard is drawn with its own system colours.
  - **Provisional:** the frames use the recommended I1, T1 and T2-B.
  - Fit 3913/4000; live = local.
- **Not merged:** no active board changed. Glass, blur and vibrancy are drawn approximations.
- **PENDING:** devices, VoiceOver, TalkBack, Reduce Transparency and Increase Contrast.


### ED-178 · Stage 1 dark tokens FINAL: I1, T1, T2-B approved; Stage 2 visual review presented
- **Date:** 2026-11-07. **Owner:** approved:
  - **I1:** the selected Mac sidebar icon in dark is #A3E2D9. Only the selected icon; normal icons and light mode unchanged.
  - **T1:** the large now-dot has no shadow in dark.
  - **T2-B:** the dotted "ahead" thread in dark is #6B6369. Light thread unchanged.
- **Stage 1 visual tokens are FINAL (ED-174 to ED-178).** Native and device behaviour remains PENDING.
- **Brown, plum and olive** remain unapproved as persisted keys. No storage, migration or Supabase work.
- **Native Mac findings,** valid only for the three tested backdrops at default settings: label 5.17:1, badge 4.14:1, badge digit 7.99:1, focus 4.92:1, and the I1 icon ≥ 4.20:1 by calculation on the measured pills. Reduce Transparency, Increase Contrast, VoiceOver, keyboard order and other wallpapers are PENDING.
- **T2-B on real surfaces:**
  - ground 3.15:1 (every drawn timeline sits on the ground);
  - surface 2.93, raised 2.65, sheet 2.42;
  - under a dimming scrim 1.59 (inert, exempt as CR-133).
  - Raised as **Q1** on the review board: A, keep one value (recommended), or B, add a raised-surface variant #7B7279.
- **Stage 2 visual review:** E-G4-6-Dark-Frames rebuilt for inspection (canvas `1794090984-0220`, 3600 × 6900, fit 6761). Light and dark pairs:
  - **Phones (95 %):** iPhone Full Today and Minimal Now; Android Full Today and Minimal Now.
  - **Add:** Create task, Brain dump, Routine.
  - **Editors:** the iPhone editor with steps and notes, and the Android editor.
  - **Colour and icon:** the compact picker, the All icons sheet, the All colours half sheet.
  - **Sheets, menus and states:** the task-actions sheet over a dimmed Today, the Minimal menu, a disabled option (Wake Up settings).
  - **Close-up:** the timeline at 150 %.
  - **Wide (62 %):** Mac Full Workspace and Minimal (selected row #F3ECE4 label and I1 icon), web Full and Minimal.
- **Exports:** 19 PNG pairs at 2× and a 21-page PDF in `references/concept-e/v1.45-working/captures/`.
- **Verification on the rendered frames (automated text contrast against resolved backgrounds, plus visual inspection):**
  - **Fixed:** the Android keyboard wasn't converted (1.11:1); the Delete swipe label had become ink on red (now white on #B5473C, 5.34:1); a missing block style on the Workspace grid; black menu and segment text.
  - **Remaining findings, inherited from light** (light values are lower still): the "Add a step" placeholder 4.20:1; the violet "#" prefix in the hex field 4.29:1; the iOS keyboard key letters 4.46:1 (a system-drawn element).
  - No missing text; rings, checks, scrims, menus and focus rings render as specified.
- **Not merged:** active boards are unchanged. Glass, blur and vibrancy are drawn approximations; device tests PENDING.


### ED-179 · Q1-B contextual dotted thread; two text accessibility corrections
- **Date:** 2026-11-08. **Owner:** "For G4-6 Stage 2, I approve Q1 Option B — a contextual dark dotted-thread color for lighter/elevated surfaces." The owner also asked for the "Add a step" placeholder and the violet hex "#" to be fixed in light and dark.
- **Thread (dark):**
  - **On the P1 ground:** #6B6369, 3.15:1.
  - **On lighter surfaces:** #7B7279, only where measured: surface 3.67, raised 3.32, sheet 3.03, tinted rows 3.22–3.59.
  - **Not universal:** on a popover #7B7279 would be 2.72:1. No thread is drawn on a popover today; if one is added, it needs its own correction.
  - **Behind an inactive dimming scrim:** the thread may stay dimmed.
  - Pattern, geometry, task colours and meaning are unchanged; the light thread is unchanged.
- **Measured on the rendered Stage 2 frames:** 38 segments on the ground at 3.15; 6 on lighter surfaces switched to #7B7279 (Mac and web Workspace on raised, 3.32; Mac Minimal tinted row, 3.59; web Minimal hover, 3.22).
- **Text corrections (accessibility consistency, not a redesign):**
  - **"Add a step" placeholder:** #8A8494 → #6F6978 in light (3.07–3.56 → ≥ 4.50:1 on the four light backgrounds) and #A0999F in dark (≥ 4.54:1 on all five dark surfaces). Applied in 13 places: E-Phones 6, E-Phones-3 4, E-PhonesMinimal 3.
  - **Hex "#" prefix:** now secondary text (#4E4757 light, 8.75:1; #C7BEC4 dark, 8.5:1) instead of the custom colour, which failed for violet (4.17) and orange (3.58) in light. Applied in 5 places on E-Phones-3.
  - **iOS keyboard:** Apple's real keyboard. Its drawn letters (4.46) are system-owned and tested separately on devices.
- **Verification:** an automated text-contrast check of every dark frame passes except the system keyboard; frame geometry unchanged (E-Phones 7882/7920, E-Phones-3 4493/4560, E-PhonesMinimal 5043/5080, Dark-Frames 6819/6900, Dark-Tokens 5668/5740, E-Map 5303/5380; E-Responsive moved to y 17900).
- **Canvas:** `1794093242-bd6c`; live = local.
- **Exports:** 19 pairs at 2× and a 21-page PDF in `references/concept-e/v1.46-working/captures/`.
- **Status:** Stage 2 visual review final for approval; NOT merged into active dark boards. Devices and assistive technology: PENDING.

### ED-180 · Stage 2 dark screens APPROVED
- **Date:** 2026-11-08. **Owner:** "Approve Stage 2".
- **Approved:** the 19 light/dark pairs and the timeline close-up on E-G4-6-Dark-Frames, with the final Stage 1 tokens (ED-174 to ED-178) and Q1-B plus the two text corrections (ED-179).
- **Not approved by this:** device behaviour (Liquid Glass, Android blur, Mac vibrancy, Reduce Transparency, Increase Contrast, VoiceOver, TalkBack) stays PENDING. Brown, plum and olive stay unapproved as stored colour keys.

### ED-181 · Stage 3: dark companions of every active board (merge)
- **Date:** 2026-11-08. Follows the owner's G4-6 Stage 3 instruction: "Only after I approve the dark frames, synchronize the approved dark treatments across the relevant active designs."
- **Method:** each active light board gets a dark companion board, converted with the same token map that produced the approved Stage 2 frames. The light boards are not changed. Geometry, copy, navigation and workflows are identical (text positions compared element by element: 0 moved, except the "Dark · " title prefix and the Narrow grid in CR-153).
- **Boards (new, row "E · Dark mode", y 31580):** E-Phones-Dark, E-Phones-2-Dark, E-Phones-3-Dark, E-PhonesMinimal-Dark, E-FullA-v2-Dark, E-Minimal-Dark, E-Earlier-Dark, E-Responsive-Dark, E-MobileWeb-Dark, E-G4-3-Narrow-Dark.
- **Applied everywhere:** P1 surfaces and text; dark task colours (ED-175); Wake Up / Wind Down caps, now-dot without shadow, now-bead (ED-177/178); Mac selected row label #F3ECE4 and icon #A3E2D9 on Mac windows only (web rows unchanged, I1); placeholder #A0999F and hex "#" in secondary text (ED-179); iOS and Android keyboards in their system dark appearance.
- **Q1-B thread, measured on every board:** 36 segments switched to #7B7279 where #6B6369 fell below 3:1 (Workspace grid cards on raised 2.65 → 3.32; teal-tinted now rows 2.87 → 3.59; hover row 2.58 → 3.22). All other segments stay #6B6369 on the ground (≥ 3.15). No thread is drawn on a popover. Threads behind a dimming scrim stay dimmed.
- **Conversion corrections found while merging whole boards (not new design; they keep the approved Stage 2 rules):**
  - Blurred drop shadows stay dark (black, ≤ 50 %); only hairlines turn into light outlines. The converter had turned blurred shadows into a faint light glow, which the dark rules forbid. The Stage 2 board keeps its approved drawing as history.
  - Scrims written without a space were missed and drawn light (mobile web); now P1 black scrims.
  - Colours that never appeared in the Stage 2 frames, mapped to P1 roles: Android outline #79747E and empty step boxes → #8C838A; indigo dial arc #7A7EDE with track #3C3A57; amber tag #483924 / #E9B864 (6.1:1); Mac and Android menus → popover #37313A; rose Settings tile #523342 / #F2A7C1 (5.8:1); iOS switch off track #39393D; Mac title bar #28232A; native Mac menu text #F3ECE4; Safari and Chrome bars in their dark system colours.
  - Swipe Move action: system grey #636366 with a white label (5.99:1) instead of a light grey fill.
  - Custom App colour preview (olive #5E7A39, 3.17–3.76 on dark): derived dark shade #739646 (≥ 4.53:1), as ED-161 derives shades when drawn.
  - Android title placeholder "What is it?" uses the ED-179 placeholder token (#A0999F) in dark.
  - The Wake Up alarm screen ("Two devices, one rings") is dark in both themes and is kept as drawn.
  - Buttons without their own text colour inherit the dark text colour (they were browser-default black).
- **Verification (automated, rendered):** text contrast on all 10 dark boards: no failures except the system-drawn iOS keyboard letters (4.46, Apple's keyboard, device test separate). No light surfaces left except intended fills (teal buttons, the inverse Add pill approved in Stage 2, the alarm screen). Every board fits: same content height as its light board (E-Phones 7882/7920, E-Phones-2 4140/4200, E-Phones-3 4493/4560, E-PhonesMinimal 5043/5080, E-FullA-v2 6739/6780, E-Minimal 4280/4320, E-Earlier 2060/2140, E-Responsive 2754/2760, E-MobileWeb 1978/2040, E-G4-3-Narrow 2330/2400). E-Map grew to 5440 (5408 used); E-Responsive moved to y 17980. No board overlaps.
- **Light · Dark · Auto:** unchanged from rules §10 (Auto follows the system; switching keeps task, date, navigation, mode, unsaved editor text and open proposals; nothing saves or discards). Drawn on E-Phones-3 and E-FullA-v2 Appearance in both themes.
- **Flagged, not changed (owner decision):** CR-153 (Narrow light grid CSS), CR-154 (Android title placeholder in light), CR-155 (custom swatch outlines), CR-156 (E-Phones-2 off-palette dots).
- **Canvas:** `1794136802-058e`; all 12 published files equal the local files.
- **Status:** G4-6 RESOLVED as design. Devices and assistive technology PENDING. Prompt D Round 2 not started.

### ED-182 · Plan panel options presented (owner comment, not approved)
- **Date:** 2026-11-08. **Owner (canvas comment on E-Workspace):** the column with Capture, Inbox, Routines and Brain dump should get out of the way when not in use, come back easily (drag or bring out), hide on smaller windows, natively on Mac and web; Inbox, Routines and Brain dump usable separately or together. "Do not make any change yet just show me the options … draw the A, B and C, then the A plus B."
- **Board:** `E-PlanPanel-Options` (light, Mac 1280 × 800 from E-FullA-v2 and 840 × 640 from E-G4-3-Narrow).
  - **A · Collapsible panel:** A1 open with a hide button and draggable edge; A2 hidden by you (the week shows Mon–Fri); A3 brought out over the grid, pin docks it; A4 hidden automatically on a small window (840: Mon–Thu instead of under 3 days).
  - **B · Sections:** collapsible Inbox / Routines / Brain dump headers (B1, B2); tabs variant (B3, B4).
  - **C · Sidebar only:** no column; Inbox opens as a popover from the sidebar.
  - **A + B (recommended):** docked with sections; small window hidden and brought out with the same sections.
  - **D · Auto-hide when not in use (added at the owner's request, "also add option D"):** D1 the panel shrinks to a 30 px rail beside the week after a pause (proposed 8 s after pointer and focus leave); D2 pointing at the rail or clicking an icon slides it out over the grid; pin keeps it. Drawn for comparison; I advise against it (not a Mac or web panel convention, surprise movement, keyboard/switch/screen-reader timing, reduced motion); if preferred, as an opt-in setting on top of A.
- **Text fit (owner comment "make sure this text aligns properly into its container"):** tab labels in B3/B4 now stay on one line (11 px, no wrap); the 840 toolbars on this board fit (range as a Week ⌄ pop-up, 6 px gaps, search button sized to its ⌘K); an automated check finds no wrapped or clipped toolbar or tab text. The same toolbar overflow on the active Narrow board is CR-157.
- **Fill-in content:** Friday's blocks repeat Thursday's routine so the widened week has content.
- **Status:** PRESENTED; no active board changed. Shortcut, threshold and web drawing to follow approval.

### ED-183 · Text always fits (rule, check and corrections)
- **Date:** 2026-11-08. **Owner (comment on E-PlanPanel-Options):** "make this a normal thing across the app, just like the changes you made, check and correct and note that. so that the text always fits even on resizing or scaling."
- **Rule:** design rules §12.3.
- **Check:** an automated fit check on every active board (controls whose text leaves their box; text clipped by its container), plus visual inspection of each hit.
  - Clean: E-Phones, E-Phones-2, E-Phones-3, E-PhonesMinimal (the one hit is a row drawn mid-swipe, intended), E-Minimal, E-Earlier, E-Responsive, E-MobileWeb.
- **Corrected (light and their dark copies):**
  - **E-FullA-v2:** week-block titles end in "…" instead of clipping mid-letter (full title in the tooltip and accessible name); the overlap block "Call with Sam" clamps to two lines; "+5 / +15 / +30 min" and "Add a schedule…" stay on one line; the web keyboard hint drops "[ ] days" and "⇧L show less" (both stay in the menus and the ? list) so it ends with "? all keys"; the Day › Need More Time submenu narrowed to fit the window.
  - **E-G4-3-Narrow:** the missing week-grid styles restored (CR-153); 840 toolbar fits its 624 px (range tabs → "Week ⌄" pop-up at 840, search button sized to ⌘K, 6 px gaps; CR-157); the Lunch context menu moved so it opens inside the window at 840 and 1160; block titles as above.
  - **E-PlanPanel-Options:** rebuilt from the corrected windows.
- **Unchanged:** layout, content, order and every approved behaviour; the dark copies keep the Q1-B thread swaps (re-measured, same segments).
- **Canvas:** `1794139366-99d0`; the 5 published files equal the local files.
- **Status:** RULE ADDED and boards corrected. Real-device Dynamic Type / font-scale checks PENDING.

### ED-184 · Plan panel A + B APPROVED and merged
- **Date:** 2026-11-08. **Owner:** "I approve A + B · Recommended · The collapsible panel with collapsible sections." Same on Mac and web. Options B3/B4 (tabs), C and D are not adopted; E-PlanPanel-Options stays as history.
- **Behaviour (rules §9.16):**
  - toolbar button at the left (pressed while shown);
  - Mac View › Show Plan Panel ⌥⌘P, next to Show Sidebar ⌃⌘S and Show Inspector ⌥⌘I;
  - web ⌘K "Show / Hide Plan panel";
  - drag the panel's edge to resize, or past the minimum to hide;
  - remembered per window (Mac) or per browser (web);
  - hides on its own when the week would show fewer than 3 days (840 × 640), and comes back on widening unless you hid it;
  - when hidden, the button brings it out over the grid; Esc, click away or a drop on the grid closes it, the pin docks it;
  - Inbox, Routines and Brain dump headers fold with a chevron (open by default, remembered);
  - Capture, ⌘N and ⇧⌘N are unchanged.
- **Merged:**
  - **E-FullA-v2:** the Plan, Full ↔ Minimal and Day windows (Mac) and the web Workspace have the button and folding headers; the View menu and keys table list ⌥⌘P.
  - **New row "Plan panel · hide it, bring it back" on E-FullA-v2:** Mac hidden by you (Mon–Fri), Mac brought out, web hidden by you, web brought out. The board grew to 7400; E-MobileWeb moved to y 22280.
  - **E-G4-3-Narrow:** button and folding headers at 960, 1042, 1160 and 1280. At 840 the panel is hidden on its own (week Mon–Thu), with the caption updated.
  - **Toolbars kept within rule §12.3:** at 960 the date pill is 4 px tighter; at 1042 search shows as its icon + ⌘K, as at 840 and 960.
  - **Dark copies:** regenerated; Q1-B thread re-measured: 19 segments on lighter surfaces on each board.
- **Checks:**
  - every toolbar fits (no wrapped or clipped label);
  - fit audit: only the accepted cases remain (ellipsis block titles, the clamped overlap block, scroll edges, a row hidden under an open menu);
  - dark text contrast passes;
  - no board overlaps;
  - canvas `1794140403-ad08`: the 5 published files equal the local files.
- **Status:** APPROVED and MERGED as design. Real Mac/web behaviour (resizing, focus, VoiceOver) PENDING.

### ED-185 · Four consistency corrections approved and applied (CR-153 to CR-156)
- **Date:** 2026-11-08. **Owner:** "I approve the four bounded light-mode consistency fixes."
- **CR-153 · Narrow Mac week grid:** the two grid style rules from E-FullA-v2 were already restored on E-G4-3-Narrow by ED-183; re-verified. The light and dark Narrow boards come from the same markup (dark is converted from light), so they match structurally.
- **CR-154 · Android "What is it?" placeholder:** #6F6978 in light, #A0999F in dark, on E-Phones (1) and E-Phones-3 (4). Measured contrast:
  - light 5.45:1 on most surfaces, but 4.24:1 on the two tinted Android Create task headers (#E8E5EE, #F0E3E5) and 4.61:1 on #FAEDE5;
  - dark passes.
  - The 4.24:1 shortfall is flagged as G4-7 Q5, with a recommendation of #6A6473 (4.57:1). Nothing beyond the approved value was changed.
- **CR-155 · Your colours swatches:** a neutral 1.5 px inset outline wherever a custom swatch is under 3:1 against its surface. The user's colour is unchanged.
  - **Light:** #7A7280 (4.1–4.6:1 on the light surfaces) on #E8A39C, #F0A28E and #7A9E4A.
  - **Dark:** #8C838A (3.45–5.0:1) on #2E4A6B and #000000.
  - **Selected state:** keeps its separate 2 px gap + ring.
  - **Check glyph on the swatch:** re-derived as ink or white by contrast. In dark, the selected #F0A28E check had been light text at 1.75:1; it is now ink at 8.94:1.
  - **Boards:** E-Phones-3 (19 swatches) and E-FullA-v2 (3), in light and dark.
  - Stored colour identifiers, custom-colour data and Supabase are not touched.
- **CR-156 · E-Phones-2 routine dots:** mapped to the approved light ring tokens of the same family:
  - #E2A93B and #C9A227 → amber #AF7E22;
  - #4FA37A and #3E9C6B → green #469763;
  - #5B8DD6 → sky #338ED1;
  - the Wind down grey ring #6A6273 (a text colour) → slate #6E6A75.
  - The dark copy follows automatically (#D9A23A, #4CA36B, #4A9BD6, #898590).
  - No routine changed colour family, and each row keeps its colours distinct, so no case was ambiguous.
- **Verified:**
  - text contrast on all 10 dark boards (only the system keyboard at 4.46);
  - the dotted line is ≥ 3:1 everywhere;
  - text fits on the changed boards;
  - canvas `1794142295-7525` equals local.

### ED-186 · G4-7 option A approved; shared state and accessibility kit drawn for review
- **Date:** 2026-11-08. **Owner:** selected "G4-7 Option A — One shared state and accessibility kit".
- **Read-only app audit (truthful wording):**
  - Edits are written to the encrypted local database first (`drift_write_use_case.dart`), with an outbox (`change_log`).
  - Sync is pull → merge → push, triggered by events.
  - Retries resend the same UUID v7 ids and per-field HLC clocks; the server ignores repeats, so a retry cannot create a duplicate task.
  - Conflicts are last-write-wins per field, with a 60 s window recorded in a conflicts table. The other device's value is in use until you choose Keep mine or Keep theirs.
  - There is no Undo after resolving and no "Keep both".
  - Web storage is IndexedDB in one tab; the app does not ask the browser to keep it (eviction possible).
  - A service worker caches the app shell after the first visit, with offline.html before that.
  - Existing English wording is reused from app_en.arb.
- **Board E-G4-7-States** (3600 × 6440; light | dark pairs):
  - **A:** opening skeleton, first sync with a real count, syncing, empty Today (approved frame), empty Inbox, didn't load with Try again, Android couldn't save, web open in another tab, web offline before the first visit, Mac session ended.
  - **B:** status vocabulary (10 states, icon + words), iPhone offline, Android offline with 3 waiting, iPhone Sync sheet, Mac sidebar line and popover, web "Saved in this browser".
  - **C:** conflict noticed → review → resolved (iPhone), Mac popover.
  - **D:** iPhone largest text, VoiceOver focus and spoken label, Reduce Transparency + Increase Contrast, Mac/web keyboard order, and a sheet of state examples (disabled, selected, expanded and collapsed, focus, field error).
- **Open for the owner (on the board):**
  - Q1: approve the kit's look;
  - Q2: web storage persistence and the wording "Saved in this browser";
  - Q3: Undo after resolving a conflict;
  - Q4: "Keep both";
  - Q5: the CR-154 shortfall.
- **New issues:** CR-158 (an expired session during sync shows the generic error) and CR-159 (web storage not persistent).
- **Status:** NOT MERGED. Device, VoiceOver, TalkBack, Reduce Transparency, Increase Contrast and offline web caching PENDING.

### ED-187 · G4-7 Q1 approved: the kit's look and one state system (direction only)
- **Date:** 2026-11-08. **Owner:** "For G4-7 Q1, I approve the overall visual and interaction direction of the shared state and accessibility kit as described. I approve the principle of one consistent Concept E state system for loading, empty states, errors, offline, sync status and conflict recovery, with appropriate native platform variations. This approval is for the Q1 design direction only."
- **Not approved (still open):** Q2 browser storage persistence; Q3 Undo after conflict resolution; Q4 Keep both; Q5 Android placeholder correction.
- **Undo (Q3):** stays a proposal. It is not built in the app and not approved. On E-G4-7-States the Undo button in both C3 frames now has a dashed outline and a label "Undo: Q3 proposal · not built · not approved"; the C3 caption says the same.
- **Board changes (E-G4-7-States only):** title, intro and decision box record Q1 approved; frame tags now read "Q1 direction approved · not merged". No other board changed.
- **Not merged:** the kit is not merged into the active boards; nothing in production code, Supabase, storage, authentication or deployment changed.
- **Checks:** text fit unchanged except the approved week-grid title ellipsis (ED-183); content 6383 of 6440 px; new label contrast ≥ 12:1 in both themes; live file equals local (version 1794161723-ccbb). Snapshot v1.53-working.
- **Still PENDING:** device, VoiceOver, TalkBack, Reduce Transparency, Increase Contrast and offline web caching.

### ED-188 · G4-7 Q2 approved: Dottoday web asks the browser to keep its storage (option A)
- **Date:** 2026-11-08. **Owner:** "For G4-7 Q2, I approve Option A — request persistent browser storage for Dottoday web. This is a WEB-ONLY reliability improvement." Approved "as a web storage reliability requirement, without changing the existing visual designs or any unrelated functionality."
- **What is approved:** a behaviour requirement for web only (spec in `E_IMPLEMENTATION_HANDOFF.md` § "G4-7 Q2 · Persistent browser storage"). After sign-in the app checks whether storage is already persistent and, if not, asks once; it handles granted, denied and unsupported; it never blocks use of Dottoday; it never presents the request as a guarantee against data loss.
- **Wording:** unchanged. Web keeps "Saved in this browser" after a local save succeeds, whatever the browser answers, and never says "Saved on this device". Saved locally, waiting to sync, synced and couldn't save stay separate states; "Synced" only after the server confirms. A failed or unavailable browser save shows the existing "couldn't save" error. Browser storage permission is not sync and not a backup.
- **Warning about clearing browser data:** the owner asked to preserve it. Read-only check: no frame on E-G4-7-States and no string in `app_en.arb` says this today; it exists only as the reason for Q2 in the docs. Recorded as a requirement (handoff, rules §12.4); where and how it is shown is not designed and needs an owner decision before it is drawn (no board changed now). **Update:** designed in web Sync details, ED-189.
- **Design scope:** no board changed, including E-G4-7-States (its decision box still lists Q2 as open; the docs are the record). No custom permission screen; where the browser shows its own prompt, that is the only UI.
- **Not done:** the implementation (CR-159 stays OPEN · implementation). No Flutter, web, Supabase, authentication, schema, deployment or hosting change. Nothing committed.
- **Platforms:** web only. iPhone, Android and Mac already store tasks in the app's encrypted on-device database; their wording does not change. This is a web reliability fix, not a feature gap (R-13 parity unaffected).

### ED-189 · G4-7 Q2 browser-storage warning drawn in web Sync details (for visual approval)
- **Date:** 2026-11-08. **Owner:** authorised designing the missing warning and adding it to E-G4-7-States only, placed in the existing web Sync details rather than a permanent warning; Settings only as an optional proposal.
- **Three separate things (do not mix them):**
  1. **Approved behaviour (ED-188):** after sign-in, web checks and, if needed, asks the browser once to keep its storage; works normally whatever the answer.
  2. **Designed warning (this entry, awaiting visual approval):** what web Sync details says about this browser's copy.
  3. **Implementation (CR-159):** not done; nothing in the app requests persistent storage today.
- **Board E-G4-7-States** (now 3600 × 8000; new group "Q2 · Web · what this browser keeps" at the bottom; light | dark pairs, drawn 1:1 except Q2d):
  - **Q2a all changes synced:** status "All changes synced · Last synced 10:42. Your tasks are on your account."; section "In this browser": "Dottoday also saves your tasks in this browser, so it works offline. Changes wait here until they sync."; "Browser storage is kept: This browser agreed to keep Dottoday's data. That makes automatic removal less likely, but clearing this site's data still removes it. Synced tasks stay on your account."
  - **Q2b changes waiting to sync:** status "2 changes waiting to sync · Saved in this browser. Last synced 10:42."; caution card (note, info icon, amber left rule, no red): "Keep this site's data until they sync. These 2 changes are only in this browser for now. If this site's data is cleared before they sync, they will be deleted. Everything that already synced stays on your account."; Sync now primary.
  - **Q2c storage not kept (denied):** "Browser storage isn't kept: This browser hasn't agreed to keep Dottoday's data, so it may remove it on its own, for example when space runs low. Synced tasks stay on your account; changes waiting to sync could be removed." Unsupported: same line with "can't be asked to keep". No re-ask button.
  - **Q2d 200 % text:** the waiting state as a full-height dialog on a 640 px page; wraps, scrolls, Sync now pinned.
  - Notes box: placement, when each line shows, truthful states (offline variant, couldn't save uses A7), never-list, screen-reader wording, optional Settings line (not drawn).
- **Labels:** decision box Q2 line and the B6 caption now say option A is approved and point to Q2a–Q2d. No other frame, board, token, layout, Plan panel or tab behaviour changed (diff checked).
- **Checks:** text contrast ≥ 6.64:1 in the new frames, icons use text colours, caution rule 3.12:1 light / 6.25:1 dark; no clipping or overflow (fit audit: only the earlier approved week-grid ellipsis); content 7945 of 8000 px; live equals local (version 1794165386-902f). Snapshot v1.55-working.
- **Open point found (Q2-W1):** web can be used without signing in (A9 wording). Then every change is only in this browser and never syncs, and ED-188 asks for storage only after sign-in. Recommendation: for local-only web, Sync details shows the same "In this browser" section with "Not signed in · your tasks are only in this browser" and a Sign in action, and the storage request also runs after the first local save. Needs the owner; not drawn.
- **Status:** awaiting the owner's visual approval. If approved, Q2 closes at design level; CR-159 stays OPEN · implementation until built and tested.

### ED-190 · Q2 warning frames approved; caution card reworded by the owner (final approval pending)
- **Date:** 2026-11-08. **Owner:** "i approve all but make this change and present for final approval", replacing the caution card text.
- **Read as:** the Q2a–Q2d frames as drawn (ED-189) are approved, except the caution wording, which is now the owner's. Final approval of the reworded frames is pending. Not read as approving Q2-W1 (local-only web) or the optional Settings line; both stay open.
- **New caution card (Q2b and Q2d, light and dark):** heading "2 changes waiting to sync"; body "These changes are saved in this browser, but haven't synced to your account yet." then "If you clear this site's data before they sync, you could lose them. Changes already synced to your account will remain there." Screen readers read the note's heading, then both sentences in order.
- **Superseded wording (ED-189):** "Keep this site's data until they sync. These 2 changes are only in this browser for now. If this site's data is cleared before they sync, they will be deleted. Everything that already synced stays on your account."
- **Checks:** text contrast ≥ 6.64:1; no clipping (200 % frame wraps and scrolls); content 7945 of 8000 px; only the caution text and its note label changed (diff); live equals local (version 1794166239-30c9). Snapshot v1.56-working.
- **Note for the owner:** the card heading repeats the status line just above it ("2 changes waiting to sync"), so screen readers hear it twice. Kept exactly as written.

### ED-191 · G4-7 Q2 approved at design level (signed-in web); Q2-W1 open
- **Date:** 2026-11-08. **Owner:** "Final approval" of the Q2 browser-storage warning frames Q2a–Q2d with the owner's caution wording (ED-190).
- **Resolved at design level:** option A behaviour (ED-188) and the web Sync details warning (ED-189 frames, ED-190 caution wording), light and dark, including 200 % text.
- **Board:** E-G4-7-States labels only: Q2 tags now "Q2 warning approved (ED-191) · not merged"; group title and decision box updated. No frame content changed. Live equals local (version 1794166328-4ff1). Snapshot v1.57-working.
- **Not resolved:** Q2-W1 (web used without sign-in: every change only in the browser; the storage request is specified after sign-in only) is a genuine remaining design question, presented next. The optional Settings line stays unapproved and undrawn.
- **Implementation:** CR-159 stays OPEN. Nothing requests persistent storage in the app today; nothing is built or tested. Not merged into active boards.

### ED-192 · G4-7 Q2-W1 option A approved (web without sign-in); G4-7 Q2 CLOSED at design level
- **Date:** 2026-11-08. **Owner:** "I approve G4-7 Q2-W1 Option A — protect and clearly explain browser-only tasks for users who are not signed in. This is the final design direction needed to resolve Q2."
- **Guest status:** "Not signed in · saved in this browser", only after the change was saved in browser storage. Never "Synced", "Saved to your account" or "Saved on this device". A failed browser save keeps the existing "Couldn't save" error.
- **Guest warning (web Sync details):** note card "Only saved in this browser · Your tasks are only stored in this browser. If you clear this site's data, you could lose them." Sign in (existing sign-in flow) is the main action. Storage line "Browser storage is kept · Asked after your first saved change. Automatic removal is less likely. Clearing this site's data still removes it."
- **Guest-to-account check (read-only, 2026-11-08):**
  - Implemented: on sign-in, `adoptAccount` (`app/lib/data/sync/account_adoption.dart`) re-keys the device profile to the account id; rows follow by cascade; the outbox is re-pointed and sync cursors cleared, so guest rows upload. Guest writes are logged to `change_log` before sign-in. If adoption fails it is logged and shown as an error; nothing is deleted.
  - Tested: `test/data/sync/sync_engine_test.dart` ("signing in re-keys the device profile, its rows and outbox"; "another account: everything on the device goes up again"); `engine_sync_service_test.dart` ("signed in: adopts, syncs, says when").
  - Not verified / risks: signing into an account that already has data elsewhere is untested; first pull lets local values win field by field, so the guest's profile settings (time zone, language, preferences) silently replace the account's; seeded starter tasks and routines can appear twice; no web end-to-end test. After sign-out the local rows keep the old account id, and signing into a different account uploads them to that account (shared-device leak).
  - **Copy decision:** the move is not verified for every case, so the card does **not** say "Sign in to keep a copy on your account." Approved rule: that line is added only once the transition is implemented and verified to never discard, duplicate or overwrite guest work (CR-160). No further owner decision needed for it.
- **Persistence (requirement, not built):** web also asks the browser to keep storage after the first successfully saved guest change (check `persisted()` first; ask at a user-action moment; granted / denied / unsupported handled; once only; never blocks saving; never described as protection against clearing site data; private windows are cleared on close regardless).
- **Board E-G4-7-States:** new Q2e (1:1) and Q2f (200 %, drawn at 50 %) light | dark beside Q2d; the Q2 notes box condensed to fit the 8000 px board (content kept, guest rules added); decision box and group title say Q2 closed. Q2a–Q2d unchanged (byte-compared). Checks: text ≥ 6.64:1, no clipping, content 7945 of 8000 px, live equals local (version 1794166665-4d2a). Snapshot v1.58-working.
- **Status:** **G4-7 Q2 CLOSED at design level.** Open implementation: CR-159 (persistent storage, both triggers) and CR-160 (guest-to-account transition safety). Nothing built or tested by this decision. Not merged into active boards.

### ED-193 · CR-160 escalated: cross-account data leak is a critical privacy/security release blocker
- **Date:** 2026-11-08. **Owner:** accepted Q2 as CLOSED at design level (ED-192); Q2e and Q2f preserved, no further Q2 visual changes; escalated CR-160: "when one user signs out and another signs in on a shared device, the first user's tasks must never be uploaded to the second user's account."
- **Recorded:** CR-160 is CRITICAL (privacy/security) and a RELEASE BLOCKER. Acceptance criteria 1–12 are in `E_IMPLEMENTATION_HANDOFF.md` § CR-160 (ownership, safe sign-out, safe switching, unsynced data preserved without leaking, guest → new and → existing account, no silent settings replacement, no duplicate starter content, interrupted or failed migration, web end-to-end, shared-device tests, server-side guard). A checklist item was added to `docs/06-security.md` §9.
- **Truthfulness:** the passing unit test for simple guest → new account adoption is not evidence for the other scenarios; the existing "another account" test asserts the leaking behaviour. Guest Sign in is not described as safe for existing-account or shared-device cases until CR-160 passes. No workaround may delete unsynced work.
- **Board E-G4-7-States:** annotations only (group subtitle, decision box): the persistent-storage request shown in Q2a–Q2f is proposed future behaviour, not built (CR-159); 200 % verification PENDING. Frame contents unchanged (byte-compared); content 7923 of 8000 px; live equals local (version 1794168206-38b4).
- **Open:** CR-159 and CR-160 (implementation and verification). Nothing implemented. Snapshot v1.59-working.

### ED-194 · G4-7 Q3 option A approved: Undo after resolving a sync conflict (design only)
- **Date:** 2026-11-08. **Owner:** "I approve G4-7 Q3 Option A — Undo after resolving a sync conflict … approval of the DESIGN and intended behavior only, not authorization to change production code."
- **Behaviour (approved):** after Keep mine / Keep theirs, a calm confirmation says what was kept, with Undo for about 10 s. Undo reverses only that choice: the replaced value is saved as a new ordinary edit through the normal save and sync path. No other fields, dates or edits roll back. If another device changed the field since, Undo does not overwrite it: the normal conflict review opens instead. Both values are kept until Undo can no longer be used. Undo is confirmed only after the new edit is saved locally.
- **Platforms:** iPhone and Android use the bottom confirmation (E-G4-7-States C3); Mac and web use the Sync popover (new C5), with ⌘Z (Mac) and Ctrl+Z (web) only when this Undo applies and no text field or other Undo context has focus.
- **Accessibility:** countdown pauses while focused or hovered; Close, Escape, swipe or the screen reader's dismiss gesture dismisses; with VoiceOver or TalkBack on it stays until dismissed; works at 200 % text; no visible countdown, no ticking animation, Reduced Motion honoured; Undo has the name "Undo: go back to the other device's time" (per field).
- **Board E-G4-7-States:** C3 proposal labels and dashed outlines removed, caption and tag now "Q3 approved (ED-194) · not built · not merged"; new C5 (Mac light, Mac dark, Web light, Web dark) under C4 in the existing row space; decision box updated. Other sections byte-identical. Content 7951 of 8000 px; no clipping; text ≥ 4.5:1 (the four C3 icon readings below 3:1 are the same before and after, inside existing filled dots, not from this change). **E-Map:** G4-7 status and "Still open" lines updated (text ends 5896 of 5960 px). Live equals local (version 1794169343-fc00). Snapshot v1.60-working.
- **Data safety (handoff requirements):** idempotent resolve and Undo; no duplicate tasks or repeated edits; never overwrite newer remote changes; keep task and field context; offline Undo saves locally and syncs later; sync failure keeps the edit queued with the existing status; if Undo cannot complete, say so (existing error pattern) and keep both values; ownership and account isolation per CR-160.
- **Status:** design APPROVED. Implementation and real-device testing PENDING. CR-160 is separate and still a CRITICAL release blocker; this decision does not touch account storage or server behaviour.

### ED-195 · G4-7 Q4 option B approved: Keep both for conflicting notes only (design only)
- **Date:** 2026-11-08. **Owner:** "For G4-7 Q4, I approve Option B — 'Keep both' for conflicting notes only. This is DESIGN approval and intended behavior only."
- **Choices:** notes conflicts offer Keep mine / Keep theirs / Keep both; title conflicts keep Keep mine / Keep theirs (no duplicate tasks). No Keep both for dates, times, routines, colours, settings or any other field without separate approval.
- **Read-only format check (2026-11-08):** notes are plain text (`series.notes`, `occurrences.notes`, `calendar_series.notes`), nullable, `CHECK (length(notes) <= 10000)` locally and `char_length(notes) <= 10000` on the server (`supabase/migrations/0001_init.sql`). Conflict rows (`app/lib/data/db/tables/sync_tables.dart`) hold only `mine`, `theirs` (JSON) and `created_at`, with no device name and no time of the other device's edit. So the combination fits without a schema change, the label must be "From your other device" with no time, and **combined text over 10,000 characters cannot be saved**.
- **Combined text:** this device's notes, a blank line, "— From your other device —", then the other device's notes. Plain text, line breaks kept, nothing trimmed, de-duplicated or reordered.
- **Saving, conflicts, Undo:** one ordinary notes edit; applied once on repeated taps or retries; if either version changed before the save, back to conflict review; offline or failed save keeps both versions and shows the existing "Couldn't save"; success only after the save. Q3 Undo restores this device's notes only if unchanged since; no other field changes. CR-160 isolation applies (not verified).
- **Board:** new linked board **E-G4-7-Q4-KeepBoth** (3600 × 2700, canvas x 21860, y 147660), since E-G4-7-States is at the 8000 px limit. Frames, light and dark: Q4a iPhone, Q4b Android (stacked three choices), Q4c Mac and Q4d web Sync popovers (row of three), Q4e combined note, Q4f Undo after Keep both (iPhone; Mac and web), Q4g title conflict with two choices, Q4h 200 % text (stacked, scrolls), Q4i found limit. E-G4-7-States: only the Q4 line and the decisions title changed (height unchanged, 7951 of 8000 px). E-Map G4-7 lines updated (5938 of 5960 px). Checks: text ≥ 4.5:1 in the new frames, no horizontal clipping, content 2621 of 2700 px; live equals local (version 1794170590-ecec). Snapshot v1.61-working.
- **Open (Q4-L1, needs the owner):** when the two notes together exceed 10,000 characters, Q4i proposes that Keep both is unavailable and says why ("Can't keep both: together they're over the 10,000-character limit for notes. Keep one version, or copy the text you need before choosing."), with no truncation. Not approved.
- **C3 icon check (owner item 5):** of the four readings, two are the Add (+) button, measured against the page because the checker ignores the gradient: actual white on #11615C is 7.27:1 (light) and #171416 on #5BC4B8 is 8.74:1 (dark); pass. The other two are real: in dark, the "Coffee & plan the day" type icon and its done check use #F3ECE4 on the dark amber fill #D9A23A, 1.95:1. Both are meaningful (task type and done state). The same pairing appears 22 times on E-G4-7-States (copied phone frames) and 10 times on the active E-Phones-2-Dark. Smallest correction: use the dark ink #171416 on #D9A23A (8.0:1), as light already uses ink on amber. Logged as CR-162; not applied.
- **Status:** design APPROVED; implementation and tests PENDING (CR-163). Q1–Q3 stay closed.

### ED-196 · CR-162, Q4-L1 and G4-7 Q5 approved and applied; G4-7 closed at design level
- **Date:** 2026-11-08. **Owner:** "Apply only CR-162, Q4-L1 and Q5 as approved. Leave everything else exactly as it is."
- **CR-162 (dark amber glyph):** in dark, the type icon or done check inside an amber #D9A23A dot now uses ink #171416 (8.0:1, was #F3ECE4 at 1.95:1). Mechanical check over every live board: 90 glyph-bearing dots changed (E-G4-7-States 27, E-G4-7-Q4-KeepBoth 14, E-Earlier-Dark 12, E-MobileWeb-Dark 10, E-Phones-2-Dark 10, E-FullA-v2-Dark 8, E-G4-3-Narrow-Dark 5, E-Phones-Dark 4). The owner's counts of 22 and 10 came from a narrower first scan; the extra instances are the same exact pairing. Not changed: empty amber dots with no glyph (colour has no visible effect), light frames (already ink), and the historical E-G4-6-Dark-Frames board (8 glyph instances kept as history). Amber, dot size, position and shape unchanged. Generator: `h/cr162.py` (hooked from `darkpost.py`). Device accessibility testing PENDING.
- **Q4-L1 (combined notes over 10,000 characters):** approved. Counting check (read-only): the notes editor's `maxLength` counts grapheme clusters; the app validator `checkOptionalText` (`app/lib/domain/validation/field_rules.dart`) counts Dart `String.length` (UTF-16 units); SQLite `length()` and Postgres `char_length` count code points. UTF-16 length is always ≥ code points, so the rule is: Keep both is available only when the full combined text (both notes, the blank line, "— From your other device —", and every line break) passes the app validator; that guarantees both databases accept it. Q4i now shows the disabled Keep both described by "Keep both isn't available · Together, these notes exceed the 10,000-character limit. You can copy either version before choosing which one to keep.", with Copy on each version, scrollable full versions, and Keep mine / Keep theirs available. Nothing trimmed, resolved or claimed saved. Finding: the editor's grapheme count can let emoji-heavy notes exceed the database's code-point limit (CR-164, implementation).
- **Q5 (Android placeholder):** option A. Light Android "What is it?" placeholder #6A6473 on E-Phones (1) and E-Phones-3 (4); rendered contrast 4.57:1 (#E8E5EE), 4.56:1 (#F0E3E5), 4.96:1 (#FAEDE5). Dark #A0999F unchanged (5.31–5.94:1). "Add a step" and the iPhone title placeholder untouched. Generator sources updated (`stage3.py`, `darkify.py`, `fix96.py`). **Q5 CLOSED at design level.**
- **G4-7:** Q1–Q5 all closed at design level (decision box on E-G4-7-States updated). Nothing built or merged into active boards.
- **Checks:** diffs limited to the approved colour swaps and the Q4i/notes text; text-fit unchanged (the two pre-existing dark flags on E-FullA-v2-Dark and E-G4-3-Narrow-Dark were there before); E-G4-7-States 7951 of 8000 px; Q4 board 2661 of 2720 px (height raised by 20 px for padding); E-Map 5917 of 5960 px; all 12 published files equal local (version 1794173275-2921). Snapshot v1.62-working.
- **Pre-existing findings logged, not changed (CR-165):** web frames A8, A9, B6 have an icon at 2.68:1; Mac frames (A10, B5, D2) have "3 of 9 · 7 h 40" at 4.42:1 and "⌘3" at 4.38:1; the dark copies E-FullA-v2-Dark ("Call with Sam" control) and E-G4-3-Narrow-Dark ("4 planned", "Thu") have text-fit flags. Disabled "Sync now" (3.07 / 3.83:1) is exempt.

### ED-197 · Cleanup batch reconciled (read-only); CR-164 and CR-165 clarified
- **Date:** 2026-11-08. **Owner:** reconcile all 15 OWNER items against the latest decisions and the live boards; present one genuine decision at a time; keep CR-164 and CR-165 open; no board changes.
- **Result:** table in `E_CLEANUP_BATCH.md` § Reconciliation. A 0 · B 1 (9c, superseded by ED-174's focus ring; boards still show the old 45 % ring at 2.0–2.1:1) · C 13 · D 1 (9b, native Mac menus). Nothing applied.
- **CR-165, verified elements:**
  - Web icon 2.68:1 = the browser's own disabled Forward arrow in the drawn browser bar (`#9C95A3` on `#F7F5F8`; A8, A9, B6). Not Dottoday UI and disabled: no change recommended.
  - Mac "3 of 9 · 7 h 40" (4.42:1) and "⌘3" (4.38:1) = secondary `#6A6273` on the **selected** sidebar row (teal 5 % tint over `#EFE7DB`); 4.75:1 on the plain sidebar. Light only (dark `#C7BEC4` passes). On E-FullA-v2, E-G4-3-Narrow, E-Minimal (⌘3) and the G4-7 kit copies. Smallest fix proposed: on the selected row only, secondary labels use `#4E4757` (≥ 6.7:1). Needs the owner's OK (new context for an existing token).
  - "Clipped" dark text: E-FullA-v2-Dark "Call with…" is the ED-183 two-line clamp (full name in the accessible label); E-G4-3-Narrow-Dark "Thu" / "4 planned" are week columns passing under the floating inspector at 840 (ED-170). Rendered identical to the approved light boards; no functional text is lost. No change recommended.
- **CR-164:** the notes editor counts graphemes, the validator UTF-16 units and the databases code points. Implementation must use one acceptance rule everywhere and never discard text when a save is rejected: keep the whole draft and show the truthful existing error.
- **No board, token or app change.** Snapshot not needed (docs only; copies in v1.63-working).

### ED-198 · Cleanup item 2 option A applied: one light now-ring recipe
- **Date:** 2026-11-08. **Owner:** "For Concept E cleanup Item 2 — Now-ring track and cut-out, I approve Option A … Apply Option A to the now-ring only."
- **Rule:** light now-ring track = the task's own colour at 20 %; arc = the family's ring token (teal #289588, not the fill #2A9D8F); cut-out 5 px on phones, 4.5 px on wide. Dark keeps ED-174 (colour at 25 %).
- **Applied (light frames only, 105 values):** E-G4-3-Narrow 40 (18 lavender tracks, 22 teal arcs), E-Minimal 13 + its Now-pane SVG ring track, E-Earlier 14, E-PhonesMinimal 12, E-FullA-v2 10, E-Phones-3 9 (5 teal arcs; the violet now-ring's indigo track → violet at 20 %; the three "In progress" colour previews at 25 % → 20 %, the custom peach preview's track → its fill at 20 %), E-G4-7-States 5 (light frames), E-MobileWeb 2. E-Minimal's board note that cited "now ring track #E4E3F7" is marked superseded.
- **Cut-out:** checked by rendered frame (not by markup order): every thread now-dot is already 5 px in phone frames and 4.5 px in wide frames, so nothing changed. An early attempt changed four E-Earlier wide-frame rings to 5 px; it was reverted before publishing. Not in scope and unchanged: small "Also now", legend and horizon rings (4 px), the Now card ring (45 px, 5.5 px, G3-1), Focus orbs (`#E4E3F7`, G3-2), the editor's colour preview, the week-review and Wind Down day rings (accent, not task rings).
- **Checks:** diffs limited to these values; arcs ≥ 3:1 on their surfaces (teal 3.43, indigo 4.86, violet 3.97, peach ring 3.40 on #FBF7F1), so progress never depends on the 20 % track; text-fit flags identical before and after (pre-existing); E-Map 5917 of 5960 px; all 9 published files equal local (version 1794176880-5252). Snapshot v1.64-working.
- **Found, not changed (CR-166):** the dark copies do not follow ED-174's "task colour at 25 %": they carry light-derived tracks (e.g. indigo arc #7A7EDE on `rgba(91,95,214,.2)`, `#5B5FD633` or the fixed `#302F48` in E-FullA-v2-Dark 20, E-G4-3-Narrow-Dark 36, E-Minimal-Dark 7, E-Earlier-Dark 4; teal arc on the light teal at 20 %). Meaning is unchanged (the arc still shows progress); aligning them is mechanical under ED-174 but needs the owner's OK, since dark was to stay untouched.
- **Also logged:** E-PhonesMinimal has six pre-existing horizontal text-fit flags ("3:00–3:45 PM", "Pick up parcel"), unchanged by this work (CR-165).

### ED-199 · Cleanup item 3 option A applied: ahead-ring widths by context
- **Date:** 2026-11-08. **Owner:** "For Concept E Cleanup Item 3 — Ahead-ring width, I approve Option A … Apply Option A to ahead-ring stroke widths only."
- **Rule:** standard phone ahead dots (about 32–34 px) 4 px; standard wide ahead dots 3.5 px; dots of 16 px or less 2.5 px. Same widths in light and dark. Decided by the component's role and frame, not diameter alone; the inset stroke keeps the outside diameter.
- **Applied (82 widths, light and dark):** iPhone proposal sheet "proposed" dots 34 px 3 → 4 (E-Phones-2 and -Dark, 6 each); E-Phones-3 "Ahead" previews 3.5 → 4 (light and dark, 3 each); Routine list dots 14 px 3 → 2.5 (E-Phones-2 and -Dark, 22 each); Full "Later" row dots (Gym, Read) 14 px 3 → 2.5 (E-FullA-v2 and -Dark 6 each, E-G4-7-States Mac copies 4 = 2 light + 2 dark); Wind Down "still open" list dots 16 px 3 → 2.5 (E-PhonesMinimal and -Dark, 2 each; same outlined not-done state).
- **Already correct, unchanged:** phone thread dots 4 px; wide Day column and grid dots 3.5 px (border or inset); horizon dots 2.5 px.
- **Not covered by the rule, left as is (owner may decide):** the 18 px board-key dot on E-Phones (3 px); a 30 px dot in the iPhone Today with the month pulled down (3 px); the 22 px floating "Lands at" preview on E-PhonesMinimal (4 px).
- **Excluded families, unchanged:** now-rings (ED-198 kept), Mark done circles, calendar month dots, responsive-diagram dots, colour-picker swatches and previews, Focus orbs, week-review and Wind Down progress rings, overlap knots.
- **Checks:** each board's diff shows only `inset 0 0 0 Npx` width changes; text-fit identical before and after on all 9 boards; ring colours unchanged, so contrast is unchanged (ring tokens ≥ 3:1, ED-155); all 10 published files equal local (version 1794177480-3a85). Snapshot v1.65-working. CR-166 and the E-PhonesMinimal fit flags stay open.

### ED-200 · Cleanup item 4 option A applied: calendar-event dot centre and ring
- **Date:** 2026-11-09. **Owner:** "For Concept E Cleanup Item 4 — Calendar dot centre and ring, I approve Option A … Apply Option A to calendar-event dots only."
- **Rule:** the centre of a hollow calendar-event dot is the surface directly behind it (opaque, so a thread behind stays masked); ring 2.5 px on standard dots (28–34 px), 2 px on dots ≤ 16 px; ring #7A7280 light, #8C838A dark.
- **Identified by role, on the rendered boards:** calendar-event labels ("Dentist, … calendar event") and the grey ring; in dark the same grey is also the general outline, so dark dots were matched by label, not colour.
- **Applied (61 values):** light 14 px Day-column centres #FFFFFF → #FBF7F1 (E-G4-3-Narrow 9, E-Minimal 2, E-FullA-v2 1); light Full grid-block centres #FFFDF9 → #F6F1EA (E-FullA-v2 8, E-G4-3-Narrow 5, E-G4-7-States 5); dark grid-block centres #28232A → #1F1B1E (E-FullA-v2-Dark 8, E-G4-3-Narrow-Dark 5, E-G4-7-States 5); 12 px Add-sheet preview rings 2.5 → 2 px (E-PhonesMinimal and -Dark, 4 each).
- **Already correct, unchanged:** phone and mobile-web dots (centre = surface, 2.5 px); 14 px dots on E-MobileWeb and E-PhonesMinimal (2 px); dark 14 px Day-column dots (#171416 on #171416).
- **Excluded, unchanged:** calendar month dots (6–7 px), "Mark … done" circles (22 px), ahead rings (ED-199), now-rings (ED-198), task dots, Focus orbs, diagram dots, colour-picker previews.
- **Checks:** re-rendered: every calendar dot's centre equals the surface behind it, light and dark; ring contrast #7A7280 4.33:1 on #FBF7F1 and 4.11:1 on #F6F1EA, #8C838A 4.99:1 on #171416 and 4.64:1 on #1F1B1E (all ≥ 3:1); diffs limited to these values; text-fit identical before and after on all 8 boards; all 9 published files equal local (version 1794179908-aefc). Snapshot v1.66-working.

### ED-201 · Cleanup item 5 option A applied: Wake Up / Wind Down thread caps 34 px
- **Date:** 2026-11-09. **Owner:** "For Concept E Cleanup Item 5 — Wake Up and Wind Down cap size, I approve Option A … Apply Option A to the Wake Up and Wind Down THREAD CAPS ONLY."
- **Rule:** the Wake Up and Wind Down caps on the day thread are 34 px with a 19 px icon on phones and in the wide Day column, matching the thread's 34 px task dots; colours, icon artwork and meanings unchanged.
- **Matched by component:** a cap centred in the thread column (48 px phones, 44 px wide) and followed by its "Wake Up ·" / "Wind Down ·" label. Settings caps (26, 30, 40, 84 px) and the four 32 px settings schedule rows on E-Phones (Wake Up 6:30 / 8:30, Wind Down 11:00 / 12:30) are a different component and unchanged.
- **Applied (82 caps):** phone Wake Up 12 (E-Phones 2, E-Phones-2 5, E-MobileWeb 5) and their dark copies 12; wide Wind Down 11 (E-Earlier 4, E-G4-3-Narrow 4, E-Minimal 2, E-FullA-v2 1) and dark copies 11; review copies on E-G4-7-States 22 and E-G4-7-Q4-KeepBoth 14. Earlier estimate of "14 phone caps" was 12: E-Phones has 2 thread caps.
- **Checks:** cap centres identical before and after (columns are fixed width, flex-centred); every text position identical on all 16 boards (one 0.5 px reading on E-Phones-2-Dark was parallel-render jitter, identical when re-rendered); text-fit identical; diffs limited to width, height and icon size; all 17 published files equal local (version 1794181401-944f). Snapshot v1.67-working.

### ED-202 · Cleanup item 6c option A applied: one Now card radius
- **Date:** 2026-11-09. **Owner:** "Option A" (cleanup item 6c, Now card corner radius).
- **Rule:** the phone Now card radius is 24 px on iPhone and Android. Heights unchanged: 80 px iPhone, 82 px Android (ED-104). Mobile web already used 24.
- **Applied (12 Android cards, 22 → 24):** E-Phones 1, E-Phones-2 2, E-Phones-Dark 1, E-Phones-2-Dark 2, E-G4-7-States 4 (2 light, 2 dark), E-G4-7-Q4-KeepBoth 2 (1 light, 1 dark). iPhone and mobile-web cards unchanged.
- **Checks:** diffs only `border-radius: 22px → 24px`; re-rendered: every Android Now card radius 24 at 82 px, every iPhone card 24 at 80 px; text positions identical (hashed) and text-fit identical on all 6 boards; all 7 published files equal local (version 1794181637-b29c). Snapshot v1.68-working.

### ED-203 · G3-C1 font comparison drawn for cleanup 7a and 7b (review only, not applied)
- **Date:** 2026-11-09. **Owner:** approved drawing a G3-C1 comparison for 7a and 7b, "DRAW AND REVIEW OPTIONS ONLY. Do not change any active design board yet." References: ED-110 (task content in Manrope), ED-112 (comparison before changing phone sheet text; G3-C1).
- **Correction:** the reconciliation (ED-197) listed 7a inputs as iPhone system 500 19 and Android Roboto 500 20; both were time labels (Android Create task time tile; Android Edit Weekdays times). The remaining Add inputs are Minimal: iPhone Manrope 600 20, Android Manrope 600 19.
- **Board E-G3-C1-Font-Comparison** (3400 × 5400, canvas x 21860, y 150500): real frames, identical text and widths, current vs proposed side by side, light and dark, normal, 130 % and 200 % (field text scaled; sheets not reflowed), short and long names:
  - 7a Android Minimal Add (E-PhonesMinimal frame 6): Manrope 600 19 vs 600 20.
  - 7b Android Edit task title (E-Phones frame 6) and Android Create task title (frame 30, plus the empty placeholder): Roboto 500 22 vs Manrope 700 24/30. App bar stays native Roboto.
  - References: iPhone Minimal Add (600 20), iPhone Create task title (700 24/30), Android Minimal edit title (Manrope 800 21, found, not part of 7b).
- **Measured:** 7a: both one line (field scrolls); at 200 % the drawn 56 px field is 1 px short for 40 px text (native field grows). 7b: long title 3 → 4 lines (normal), 3 → 5 (130 %), 6 → 8 (200 %); on Create task at 200 % the header above the keyboard fits Roboto's 6 lines but cuts Manrope's 8 in the drawing, so Manrope needs the title to scroll inside the header (cursor kept in view) or the header to grow.
- **Recommendations:** 7a Manrope 600 20 on Android (match iPhone). 7b Manrope 700 24/30 (match iPhone) with the scroll-in-header requirement; alternatives Manrope 700 22/28 or keep Roboto.
- **Status:** 7a and 7b AWAITING VISUAL APPROVAL. No active board changed. Checks: no horizontal clipping; content 5128 of 5400 px; live equals local (version 1794182042-b6ee). Snapshot v1.69-working.

### ED-204 · Cleanup 7a and 7b approved as recommended and applied; G3-C1 closed
- **Date:** 2026-11-09. **Owner:** "Both as recommended" (G3-C1 comparison, ED-203).
- **7a:** Android Minimal Add input Manrope 600 19 → 600 20 (E-PhonesMinimal and -Dark, 1 each), matching iPhone.
- **7b:** Android task title Roboto 500 22 → Manrope 700 24/30, matching iPhone: the Android Edit task title (E-Phones and -Dark, 1 each) and the Android Create task title field (E-Phones and -Dark 1 each, E-Phones-3 and -Dark 4 each); the drawn cursor grows 24 → 28 px to match the line. App bar titles stay native Roboto. Keyboard, selection, cursor behaviour, validation and accessibility stay the platform's.
- **Requirement (recorded in the handoff):** at large text sizes the title field scrolls inside the editor header with the cursor kept in view (or the header grows); it must never be cut off. Same rule on iPhone.
- **Not changed:** the Android Minimal edit title (Manrope 800 21) found during G3-C1; logged for a later decision. *(Corrected in ED-216: it is the Minimal task sheet header on both phones; kept.)*
- **Checks:** diffs limited to the field fonts and the cursor height; rendered: no changed field clips or overlaps (titles 30 px tall, input 29 px); text-fit identical before and after on all 6 boards; all 7 published files equal local (version 1794182273-be78). G3-C1 CLOSED. Snapshot v1.70-working.

### ED-205 · Cleanup 8c approved (option A) and applied: iPad "Alarms off" tag
- **Date:** 2026-11-09. **Owner:** "I approve Option A", for the iPad Air "Alarms off for Dottoday · fix it on the iPad" tag in the alarm device picker only.
- **Change:** board amber `#FBEBD0` / `#6E4300` (dark `#483924` / `#E9B864`) → neutral tag `#F1ECE4` / `#4E4757` (dark `#2F2A30` / `#C7BEC4`) with a 13 px bell-off icon in the amber ring colour `#AF7E22` (dark `#D9A441`). Wording unchanged. No new token: the icon uses the existing amber ring token, not the board's annotation amber. Text and icon carry the state together; the icon is decorative to assistive tech (the row reads "iPad Air, Alarms off for Dottoday · fix it on the iPad").
- **Scope:** E-Phones and E-Phones-Dark, 1 tag each. Left padding 7 → 6 px inside the tag; the tag grows 258 → 274 px wide, same 17 px height, inside its 284 px column. Device row, iPhone row and Ready tag, other tags, spacing and behaviour unchanged.
- **Checks:** only that tag differs in each board's source; every other element's position is identical before and after (4,618 elements per board, light and dark); no clipping (scroll width = width). Contrast: text 7.56:1 light, 7.75:1 dark; icon colour 3.06:1 light, 6.25:1 dark. Rendered pixels: in dark 97–99 % of stroke pixels reach 3:1 at 1×/2×/3×; **in light only 54 % (1×), 83 % (2×), 87 % (3×)**, because the 3.06:1 colour has no margin and antialiased edges fall below it. At 200 % text the tag wraps inside its column, icon on the first line, nothing clipped. Published version `1794212280-a340`; live equals local. Snapshot v1.71-working.
- **Proposed separately (resolved by ED-213: `#986C1C` applied):** light icon `#A57620` (3.43:1; 71 / 87 / 92 % of stroke pixels pass) or `#986C1C` (3.97:1; 74 / 89 / 93 %). Needs the owner's OK; the approved `#AF7E22` stays on the boards.
- **Not changed:** STATUS.md and E_TRACEABILITY.md (outside the owner's list for this item); the generator's global dark amber-tag mapping (stage3.py) stays because other tags use it.


### ED-206 · Cleanup 10 (Day button font) approved (option A) and applied
- **Date:** 2026-11-09. **Owner:** "I approve Option A": Mac and web Day button in the system font, 13 px, weight 500, light and dark. Strictly typography; follows the Mac-native and web-chrome rule (rules §3: "other web chrome is system-ui").
- **Change:** Mac Day button (30 px, `-apple-system`) 700 → 500: E-Minimal 1, E-FullA-v2 1 (the Minimal preview), E-G4-3-Narrow 4 (Minimal narrow frames). Web Day button (32 px) Manrope 700 → `system-ui, -apple-system, 'Segoe UI', sans-serif` 500: E-Minimal 1 ("Day menu"), E-FullA-v2 3. Same counts on each dark copy: 20 buttons on 6 boards. Mac buttons already at system 13/500 unchanged (9 per board pair on E-FullA-v2 and E-G4-3-Narrow).
- **Not changed:** the mobile-web Day chip (Manrope 14/700), phone Day chips, the E-Minimal web Add (teal correction still pending), the 9c focus ring (pending), the ED-205 iPad tag, the G4-7 review boards (E-G4-7-States keeps one web Day button pair in Manrope 13/700 and is not an active board), historical boards.
- **Checks:** only the `font` declaration of those buttons differs in source. Heights, y positions and right edges unchanged; Mac buttons 0.5–1 px narrower (the wrapper shrinks with them, right edge fixed); web widths unchanged to 0.02 px (Manrope 700 and system 500 measure the same here). Text and chevron stay centred (offset unchanged); no clipping; text-fit identical before and after on all 6 boards; at 200 % (26 px) both variants fit without clipping and are narrower than before. Every other element's position identical, apart from the Day buttons' own wrappers and two empty zero-height spacers (≤ 0.5 px). Published version `1794213414-2fa6`; all 7 files equal local. Snapshot v1.72-working.


### ED-207 · Cleanup 11 (Minimal sidebar width) approved (option A) and applied
- **Date:** 2026-11-09. **Owner:** "Option A": the Minimal sidebar is 200 px on Mac and web (same layout at the same width, CLAUDE.md §11). Full's 216 px sidebar (ED-168) unchanged.
- **Change:** E-Minimal web frame only (light and dark, 1 each): sidebar 210 → 200; the Now pane (absolutely placed) moves left 210 → 200 and widens 560 → 570, so the Day column stays at 770 with width 510. Web sidebar rows keep 14 px / 36 px; Mac sidebars (E-Minimal, the E-FullA-v2 preview, 9 E-G4-3-Narrow Minimal frames) were already 200.
- **Checks:** only those two declarations differ in source; nothing outside the web sidebar and Now pane moved (919 elements per board); the Day column, toolbar and browser chrome are identical; nothing clips; text-fit identical before and after; the sidebar's keyboard hint rewraps within its same three lines. Published version `1794213714-234e`; all 3 files equal local. Snapshot v1.73-working.
- **Not changed:** the Minimal right column (290 Mac) and web Day thread (510), Full widths, breakpoints, the web Add (teal still pending), the 9c focus ring.


### ED-208 · Cleanup 12 (repeat marker) approved (option A) and applied
- **Date:** 2026-11-09. **Owner:** "Option A": one repeat marker, the phones' repeat icon (two arrows in a loop), announced as "repeats"; the ↻ character and the "· repeats" suffix go; sentences such as "repeats on weekdays" are content and stay.
- **Change (active boards, light and dark):** E-FullA-v2: 22 week blocks "Team standup ↻" → title + 10 px icon; 3 day rows "Team standup ↻ · 8:00–8:15 AM · repeats" → "Team standup · 8:00–8:15 AM" + 12 px icon. E-G4-3-Narrow: 20 week blocks → 10 px icon. E-Phones: the glyph leaves the editor title field ("Team standup") and the dialog sentence ("You moved Team standup to 8:15 AM"); the editor's schedule line already reads "repeats on weekdays". 47 markers per theme, 94 in all; no ↻ remains on these boards.
- **Accessibility:** every block and row button already has "repeats" in its accessible name, so the drawn icon is `aria-hidden` there (no double announcement); the phones' standalone icons keep `role="img"` and the name "repeats". The icon takes the text colour (no new colour).
- **Checks:** only those text runs changed in source; every other element's position identical (4,967 / 4,073 / 4,599 elements); the text hosts keep their position and height; no icon clipped by the ellipsis; text-fit identical before and after on all 6 boards. Published version `1794214178-2054`; all 7 files equal local. Snapshot v1.74-working.
- **Not changed:** E-G4-7 review boards (↻ 34 on E-G4-7-States), historical boards, phones/E-Earlier/mobile web icons (already option A). E-Minimal draws no repeating rows (repeats only in the horizon dot's accessible name); no marker added there.


### ED-209 · Cleanup 14 (Now card on wide) approved (option A) and applied
- **Date:** 2026-11-09. **Owner:** "Option A": the Minimal Day-column Now card uses the Mac sizes on Mac and web: 68 px tall, time and "Now, N min left" 12.5 px, title Manrope 16/700.
- **Change:** E-Minimal web card only (light and dark, 1 each): height 64 → 68, "Now, 18 min left" 13.5 → 12.5, title 17 → 16. The web card keeps its own arrangement (time and Now on one line); radius 18, surface, ring, colours and the 32 px Mark done button unchanged. Mac (E-Minimal and the 4 E-G4-3-Narrow Minimal frames) already matched.
- **Checks:** only those three declarations changed in source; nothing outside the web Day column moved; inside it the rows below the card moved down 4 px (91 elements) and the card's own contents re-centred; no clipping; text-fit identical before and after. Published version `1794214401-55c4`; all 3 files equal local. Snapshot v1.75-working.
- **Not changed:** phone Now cards (80 / 82, ED-104 / ED-202), the web thread paddings, the done-button size, all other rows (15 px titles).


### ED-210 · Cleanup 15 (glass shadow tiers) approved (option A): five tiers confirmed, no board change
- **Date:** 2026-11-09. **Owner:** "Option A".
- **Decision:** the iPhone glass elevation scale is the five tiers already drawn consistently on every phone board (light · dark outer shadow, each with the 0.5 px hairline `rgba(36,31,43,.1)` · `rgba(255,245,235,.13)`): 0 on a sheet (hairline only: Close/Done, More, All colours); 1 top row `0 4 12` 8 % · black 18 % ("‹ Today", sync/avatar capsule); 2 Day ▾ `0 6 16` 10 % · 22 %; 3 floating bar `0 10 30` 12 % · 26 % (tab bar, +); 4 overlay `0 20 50` 24 % · 50 % (Day pull-down).
- **Native:** the Day ▾ chip, tab bar and system menus are native in the app (ED-124, ED-133); their drawn shadows are stand-ins for the system's. Flutter-drawn glass uses the tier values. Android keeps Material elevation as drawn (Day chip level 1, navigation bar level 2, FAB level 3); not part of this decision.
- **Boards:** none changed except the E-Map status line (published version `1794214703-0e33`, live equals local). Snapshot v1.76-working.
- **Cleanup batch:** every item 2–15 is now decided. Approved but not yet applied (need the owner's OK): 9c web focus ring (ED-174 recipe) and the E-Minimal web primary Add in teal (CR-010). 9b is implementation-only.


### ED-211 · Cleanup 9c (web focus ring) and 10 (web Add teal) applied on the owner's OK
- **Date:** 2026-11-09. **Owner:** "Apply both" (the two approved, not yet applied corrections).
- **9c:** the old web focus ring `outline: 3px solid` teal at 45 % (offset 1–2 px) → the ED-174 recipe `outline: 2px solid #11615C; outline-offset: 2px` (dark `#7FD6CB`); the 2 px offset is the gap that shows the surface behind. E-Minimal 1 ("Need more time?"), E-FullA-v2 3 (Day menu, open), each in dark. Ring against the surface: 6.81:1 light, 10.79:1 dark (was 2.11:1 and 2.71:1 after compositing the 45 % alpha; both below 3:1).
- **10 (Add colour, CR-010):** E-Minimal web primary Add ink `#241F2B` → accent `#11615C` with white text (7.27:1; 6.81:1 against the surface); dark `#F3ECE4` → `#5BC4B8` with `#171416` (8.74:1), matching the dark Mac Add.
- **Checks:** only those declarations changed (2 per E-Minimal board, 3 per E-FullA-v2 board); every element's position identical before and after (outline and colour are layout-neutral); text-fit identical on all 4 boards. Published version `1794215097-9608`; all 5 files equal local. Snapshot v1.77-working.
- **Not changed:** review boards E-G4-7-States (1 old ring per theme) and E-G4-6-Dark-Frames (2 per theme); historical boards. **The cleanup batch is complete**; 9b stays implementation-only.


### ED-212 · CR-166 applied on the owner's OK: dark now-ring tracks follow ED-174
- **Date:** 2026-11-09. **Owner:** "Yes, CR-166".
- **Change:** every dark task now-ring track (conic gradient) = the arc's task colour at 25 % (`rgba(<arc>,.25)`), replacing light-derived `rgba(91,95,214,.2)`, `#5B5FD633`, fixed `#302F48`, teal at 20 % and the custom-colour tracks on E-Phones-3-Dark. Arcs unchanged. 234 tracks on 9 dark boards: E-Earlier 20, E-FullA-v2 31, E-G4-3-Narrow 50, E-Minimal 13, E-MobileWeb 13, E-Phones 45, E-Phones-2 18, E-Phones-3 19, E-PhonesMinimal 25 (all -Dark). Two tracks already at 25 % left as they were.
- **Excluded (not task now-rings):** Week in review day-progress rings (`#5BC4B8` at 18 %; E-FullA-v2-Dark 2, E-Phones-2-Dark 2), the Wind Down ring on E-PhonesMinimal-Dark, and the 14 px Show Less menu glyph on E-Minimal-Dark. Light boards untouched (ED-198 already applied).
- **Checks:** outside the conic values every source is identical; every element's position identical; text-fit identical on all 9 boards; the arcs (which carry the meaning, ≥ 3:1) are unchanged. Published version `1794215418-3669`; all 9 files equal local. Snapshot v1.78-working.


### ED-213 · ED-205 contrast refinement: light bell-off icon #986C1C
- **Date:** 2026-11-09. **Owner:** approved the follow-up proposed in ED-205, choosing `#986C1C` (not `#A57620`). ED-205 itself stands; this refines only its light icon colour. The owner also recorded CR-166 as resolved (ED-212, snapshot v1.78-working preserved).
- **Change:** E-Phones only, the iPad Air "Alarms off for Dottoday · fix it on the iPad" tag: light icon `#AF7E22` → `#986C1C`. Dark icon `#D9A441`, tag `#F1ECE4` / `#4E4757`, dark tag, 13 px size, wording and accessibility unchanged; E-Phones-Dark not touched.
- **Checks:** one declaration changed; tag 274.38 × 17 at the same place, rows and every other element identical (position hash equal); text-fit identical. Specified colour 3.97:1 on `#F1ECE4`; full-coverage stroke pixels render at 3.97:1 and the shape stays a clear bell-off at 1×, 2×, 3× and 200 % text (stroke pixels ≥ 50 % coverage reaching 3:1: 74 / 89 / 93 %, was 54 / 83 / 87 %). Published version `1794216170-4abe`; E-Phones and E-Map equal local, E-Phones-Dark unchanged. Snapshot v1.79-working.


### ED-214 · CR-165 (2) and (4) approved; (2) applied to the selected sidebar row, one label held for a location correction
- **Date:** 2026-11-09. **Owner:** "Approve both": `#4E4757` for secondary labels on the selected Mac row (light), and close the E-PhonesMinimal swipe-row fit flags.
- **(2) applied:** "⌘3" on the selected Week sidebar row (`aria-current`, row tint `rgba(36,31,43,.06)`) `#6A6273` → `#4E4757`: 4.38:1 → 6.68:1. E-FullA-v2 5, E-G4-3-Narrow 5 (light only). Unselected rows (⌘4 4.90:1), the 12 px ⌘ list (5.39:1), E-Minimal and dark copies unchanged.
- **Correction, held:** "3 of 9 · 7 h 40" (12 px 700, 4.42:1) is **not** on a sidebar row, as ED-197 and the presentation said; it is the secondary label in the Week canvas's Today column header (`aria-current="date"`, teal tint 5 %). Same values (`#6A6273` → `#4E4757` would give 6.74:1), different surface, so not changed until the owner confirms. 5 per board on E-FullA-v2 and E-G4-3-Narrow.
- **(4) closed, no board change:** the 6 E-PhonesMinimal flags per theme ("3:00–3:45 PM", "Pick up parcel" × 3) are the Pick up parcel row drawn mid-swipe (content shifted 74 px to reveal Move and Delete); intended. Recorded as expected flags in the audit baseline.
- **Checks:** 10 declarations changed; every element's position identical; text-fit identical. Published version `1794217168-a03d`; 3 files equal local. Snapshot v1.80-working.


### ED-215 · CR-165 (2) remainder applied: Week Today column header label
- **Date:** 2026-11-09. **Owner:** "Yes, apply it" (after the ED-214 location correction).
- **Change:** "3 of 9 · 7 h 40" (12 px 700) in the Week canvas's Today column header (`aria-current="date"`) `#6A6273` → `#4E4757`: 4.42:1 → 6.75:1. E-FullA-v2 5, E-G4-3-Narrow 5, light only; other column headers ("4 done") and dark copies unchanged.
- **Checks:** 10 declarations changed; positions identical; text-fit identical. Published version `1794218097-b6e2`; 3 files equal local. **CR-165 resolved.** Snapshot v1.81-working.


### ED-216 · Minimal task sheet title: Manrope 800 21/26 kept (option A); "Android Minimal edit title" corrected
- **Date:** 2026-11-09. **Owner:** "Option A".
- **Correction:** the item logged in ED-203 / ED-204 as "Android Minimal edit title (Manrope 800 21)" is the **Minimal task sheet header**: the read-only task name beside the 44 px dot, above "Now · 18 min left". It is already identical on iPhone (E-PhonesMinimal, 2 frames) and Android (1 frame), light and dark. It is not the editable title field (700 24/30, ED-204).
- **Decision:** keep Manrope 800 21/26 on both phones as its own role. No board changed (the E-Map does not mention this item). Snapshot v1.82-working.


### ED-217 · ED-199 outliers reconciled (option A): Lunch corrected; board key and Lands-at marker exempt by role
- **Date:** 2026-11-09. **Owner:** "Option A. Change only the two Lunch ring widths from 3 px to 4 px."
- **Lunch (corrected):** the ahead dot in "iPhone Today with month pulled down" is a phone thread dot drawn at 30 px; ring 3 → 4 px (E-Phones and E-Phones-Dark, 1 each). Diameter 30, colour, centre and position unchanged.
- **Board key (exempt):** the 18 px / 3 px specimens on E-Phones and E-PhonesMinimal keys are board annotations, not app UI; kept exactly and excluded from app-component consistency checks.
- **Lands at (distinct):** the 22 px / 4 px "Lands at 6 PM" marker on the mini horizon in Add and New task (E-PhonesMinimal and dark, 4 each) is a highlighted landing marker, not a thread dot; it keeps 4 px among 2.5 px horizon dots. No 3 px rule is added.
- **Checks:** exactly 2 values changed (one per theme); every element's position identical; text-fit identical; E-PhonesMinimal and -Dark untouched; the board-key source identical. Published version `1794218769-3479`; 3 files equal local. Snapshot v1.83-working. ED-210, ED-212 and ED-213 unchanged.


### ED-218 · CR-143 approved (option A): ⌥⌘I toggles the right-hand pane in both modes
- **Date:** 2026-11-09. **Owner:** "Option A".
- **Rule:** on Mac, ⌥⌘I shows/hides the right-hand pane of the current mode: Full → View › Show/Hide Inspector; Minimal → View › Show/Hide Day Column. Each mode's View menu holds only one of the two, so one key per command per menu bar holds. ⌥⌘D stays never-bound (macOS Dock). Web: no single-key shortcut (View, ⌘K and the "Hide the day thread" button).
- **Boards:** E-Minimal (6 per theme) and the Full inspector already drew ⌥⌘I. Only the stale notes changed: E-G4-3-Narrow and -Dark (the "shown inconsistently" note, 1 each) and the E-Map Mac row ("hide ⌥⌘D" → "hide ⌥⌘I", plus the status line). No ⌥⌘D remains on the active boards. Text-fit identical. Published version `1794218921-623c`; 3 files equal local. Snapshot v1.84-working.


### ED-219 · Colour data Decision 1 (option A): brown, plum and olive become stored keys in two releases
- **Date:** 2026-11-09. **Owner:** "Option A". Policy decision for the build; nothing implemented, no board, code, data or Supabase change.
- **Finding (code read, unchanged):** sync pull does not validate `color_key`; every local write validates the whole entity (`validate_batch.dart` → `checkColorKey`), and backup restore validates every row (`export_json.dart`). So an older client draws an unknown key as indigo but rejects any edit of that task and any restore containing it. No minimum-version mechanism exists.
- **Decision:** release N adds `brown`, `plum`, `olive` to the allowed keys (palette.json → generated keys) and makes validation forward-compatible: a well-formed stored key the edit leaves unchanged is accepted even if unknown, and restore keeps unknown keys instead of failing. Pickers hide the three in release N; release N+1 shows them. No schema or data migration; existing rows are never rewritten. Visual values as approved (ED-161, ED-177).
- **Still open:** Decision 2 (custom colour storage), Decision 3 (App colour storage). Snapshot v1.85-working.


### ED-220 · Colour data Decision 2 (option A, C1): a custom task colour is stored as hex in `color_key`
- **Date:** 2026-11-09. **Owner:** "Option A". Policy for the build; nothing implemented.
- **Decision:** a task's custom colour is stored as `#RRGGBB` (normalised uppercase) in the existing `color_key` (fits ≤ 24 chars; no migration). Staged with ED-219: release N accepts `#RRGGBB` in `checkColorKey` (and the forward-compatible rule), release N+1 shows Custom and Your colours. A malformed value draws as indigo and is never rewritten. Ring and glyph shades are derived when drawn; the stored value never changes (ED-161). Conflicts keep the single colour field (`color_key` + `icon_key`); exports and backups carry the text unchanged.
- **Correction found after the presentation (sync code read):** `profiles.settings` is pushed as one whole JSON value (`sync_push` replaces the column), and the app's `Settings` model drops keys it doesn't know. So a "Your colours" list inside `settings` would be **silently erased** whenever an older app changes any setting (R-08). Decision 2's note that the list "fits in settings with no schema change" is withdrawn; where Your colours is stored moves to Decision 3 with the App colour. The task-colour storage itself is unaffected (per-field push).
- Snapshot v1.86-working.


### ED-221 · Colour data Decision 3 (option A): App colour hex and "Your colours" in their own profile columns
- **Date:** 2026-11-09. **Owner:** "Option A". Policy for the build; nothing implemented. The Supabase migration itself remains must-ask at build time (CLAUDE.md §10).
- **Why not `settings`:** `profiles.settings` syncs as one whole value and older apps drop unknown settings keys (ED-220), and `validateSettings` rejects a non-key accent, so older apps could neither keep a list there nor save settings with a hex accent (R-08).
- **Decision:** add to `profiles` (new migration; RLS already on the table, policies reviewed, none weakened): `accent_hex text null` (null = use `accent`) and `your_colours jsonb not null default '[]'` (up to 24 `#RRGGBB` values, shared by the task and App colour pickers, most recent first). Both sync per field like every column, so older apps never touch them. `accent` keeps a valid built-in key, the nearest to the chosen hex, so older apps show a close accent and still save settings. Buttons and links use the derived ≥ 4.5:1 shade at draw time; the stored hex never changes (ED-161). Drift schema bump, `pushableColumns`, export format, and server CHECKs (hex format, array length) come with it.
- **Colour data review complete:** Decisions 1–3 decided (ED-219 to ED-221); item 0 (E shades) design-approved (ED-161). Snapshot v1.87-working.


### ED-222 · CR-160 screen audit (criteria 2 and 7) and the A2 wording fix on E-CR160
- **Date:** 2026-11-09. **Owner:** "Yes, fix A2" after the read-only audit of the owner-approved board E-CR160 (https://claude.ai/artifact/MaCdg3soqyxnFcxN5G9vja) against criteria 2 and 7.
- **Applied:** A2's last sentence on the iPhone, Android and Mac/web frames (dark frames reuse them) "Until then, no one else who uses Dottoday on this device can see them." → "They stay on this device under this account.", the approved narrower wording while isolation is unverified (I7 open; physical devices pending). The board note `condA` records the fuller sentence as the text used only after I1–I8 pass. Nothing else changed. Renders checked in light and dark; text fit clean; published version `1794220755-eaa3`; 4 files equal local.
- **Audit findings, not applied (need separate approval):** A3 body "kept safely" makes the same unverified promise (proposed: "Your tasks stay on this device under your account. They come back when you sign in again with the same account."), and its padlock art is labelled "An empty day"; frames not drawn: A1 for Android and Mac/web, the A2 "Sync hasn't been confirmed yet" state, the Android A2 hint under Stay signed in, A3 and B1 for Android and Mac/web, and the Settings › Account "Choose settings" row after Decide later.
- **Matches policy:** A1 shown only after a server-confirmed sync with an empty queue; the Mac/web Esc note; B1 separates account and device settings, defaults to the account's and keeps them on Decide later; no guest task preview.
- **Implementation, not design (CR-160 session):** built B1 shows Time zone and Your day only (board also shows Language and Layout); offline sign-out shows an error although it worked; built screens use DotTheme instead of Concept E; Sync now feedback during a failing run. The CR-160 branch and PR #75 were read only, not touched. Snapshot v1.88-working.


### ED-223 · E-CR160 A3 wording fixed (signed out)
- **Date:** 2026-11-09. **Owner:** "Yes, fix A3".
- **Applied (A3, light; the dark frame reuses it):** body "Your tasks are kept safely on this device. …" → "Your tasks stay on this device under your account. They come back when you sign in again with the same account." (no unverified isolation promise, matching A2, ED-222). The padlock illustration, labelled "An empty day", is now decorative (`aria-hidden`). Title, buttons and the guest-planner hint unchanged.
- **Checks:** only those two lines changed; light and dark render cleanly; text fit clean; published version `1794220886-cf10`; live equals local. The built string `signedOutBody` on the CR-160 branch still says "kept safely": a note for that session, not changed here. Snapshot v1.89-working.
- **Still open from ED-222:** frames not drawn (~~A1 Android and Mac/web~~ drawn in ED-224; A2 "Sync hasn't been confirmed yet"; Android A2 hint; A3 and B1 Android and Mac/web; Settings › Account "Choose settings").


### ED-224 · E-CR160: A1 Android and Mac/web adaptations added
- **Date:** 2026-11-09. **Owner:** approved the four-frame A1 adaptation.
- **Added:** `AndroidA1` (+ `AndroidA1Dark`) and `DesktopA1` (+ `DesktopA1Dark`) in row 4 beside the A2 adaptations; row title "Platform adaptations of A1 and A2". Content is the approved A1 only: "Sign out?", "Your tasks and settings are hidden on this device until you sign in again. Everything has synced to your account.", Cancel, Sign out; the Account page behind shows "Synced".
- **Android:** Material dialog (radius 28), Manrope title 24/32 and body 14/20, Roboto 14/500 text buttons right-aligned, 48 dp targets, no icon (as iPhone A1). Back or a tap outside cancels (board note).
- **Mac/web:** 440 px dialog over Settings › Account (A2 geometry), Cancel outlined and Sign out filled, right-aligned; focus starts on Cancel with the ED-174 ring (`#11615C` light, `#7FD6CB` dark); Esc cancels; no Esc hint line.
- **Rule documented (note condA):** A1 only after a server-confirmed sync with no pending changes and no open conflicts, otherwise A2; A1 starts no sync, Cancel only closes it. Documentation only; no auth or sync change.
- **Checks:** rendered after the CR-160 suite finished, light and dark, 100 % and a simulated 200 % text: no clipping, text fit clean, buttons and focus ring intact. Contrast: Android buttons 7.16 / 6.71, body 8.75 / 10.19, focus ring 7.16 / 8.28, Sign out 7.27 / 7.69. Existing frames byte-identical; index otherwise unchanged. Published version `1794223548-f517`; live equals local. Snapshot v1.90-working.


### ED-225 · E-CR160: A2 "Sync hasn't been confirmed yet" on iPhone, Android and Mac/web
- **Date:** 2026-11-09. **Owner:** "Yes, all three".
- **Added (light + dark each):** `A2Unconfirmed` (iPhone, top row beside A1), `AndroidA2Unconfirmed` and `DesktopA2Unconfirmed` (row 4, after the A1 adaptations). Each is the existing A2 frame with only the approved count-0 strings: title "Sync hasn't been confirmed yet"; body "Dottoday hasn't confirmed that everything reached your account. Anything that didn't is saved on this device for {email} and can sync when you sign in again with this account." + "They stay on this device under this account."; the Account status line uses the built `syncPending` zero string "Nothing waiting to sync". Actions, hint, Esc note, layout and colours unchanged from A2.
- **Note `condA`:** names both A2 forms (count title when changes wait; this title when nothing waits but the last sync is unconfirmed).
- **Checks:** sources differ from A2 only in those strings, the page title and element ids; existing frames byte-identical; renders clean in light and dark at 100 %; text fit clean. **At a simulated 200 % text** the longer body runs past the bottom of the fixed iPhone and Mac/web board frames: a board-frame limit, recorded as a build requirement that the A2 dialog scrolls (actions stay reachable) at large text. Published version `1794223868-1e6c`; live equals local. Snapshot v1.91-working.


### ED-226 · E-CR160: Android A2 gets the "Stay signed in" hint
- **Date:** 2026-11-09. **Owner:** "Yes, add the hint".
- **Change:** "Dottoday tries to sync them now." (approved `accountStaySignedInHint`, as on iPhone A2) added under Stay signed in on `AndroidA2` and `AndroidA2Unconfirmed` (dark frames reuse them), 13/18 in the secondary colour: 5.73:1 light, 7.75:1 dark. Nothing else changed.
- **Checks:** one inserted line per file; renders clean in light and dark; text fit clean. Published version `1794224027-20dd`; live equals local. Snapshot v1.92-working.


### ED-227 · E-CR160: A3 (signed out) Android and Mac/web adaptations added
- **Date:** 2026-11-09. **Owner:** "Yes, draw A3".
- **Added (light + dark each):** `AndroidA3` and `DesktopA3` in row 2 after B1. Copy is exactly the approved A3 (ED-223): "You're signed out", "Your tasks stay on this device under your account. They come back when you sign in again with the same account.", Sign in, Use without an account, and the guest-planner hint. Illustration decorative (`aria-hidden`), as on iPhone.
- **Android:** Manrope content (title 28/36, body 14/20), Roboto 14/500 buttons at 48 dp: Sign in filled (accent), Use without an account outlined (accent label), hint below.
- **Mac/web:** a centred 400 px column in the window (no sidebar while signed out), title 24/30, body 14/21, Sign in (filled) and Use without an account (outlined) side by side at 40 px, wrapping onto separate rows with labels on one line when text is large; hint below.
- **Checks:** light and dark at 100 % and a simulated 200 % text: no clipping; at 200 % the column is longer than the fixed board frame (the page scrolls in the app). Contrast: body/hint 5.45 / 10.1, Sign in 7.27 / 7.69, outlined labels 6.81 / 8.74 (Android), 15.07 (Mac/web light). Existing frames unchanged. Published version `1794224379-3974`; live equals local. Snapshot v1.93-working.


### ED-228 · E-CR160: B1 (settings choice) Android and Mac/web adaptations added
- **Date:** 2026-11-09. **Owner:** "Yes, draw B1".
- **Added (light + dark each):** `AndroidB1` and `DesktopB1` in row 2 after the A3 adaptations. Text identical to iPhone B1 (checked string by string): title, body, hidden legend "Settings to use", the two radio cards with Time zone, Language, Your day, Layout, "Only the settings that differ are shown.", Continue, Decide later and its hint. The account's settings are preselected and its card has the accent border plus the filled radio (not colour alone). No guest task content appears.
- **Android:** Manrope content (title 24/32), radio rows at 48 dp, Roboto 14/500 buttons: Continue filled, Decide later text button, stacked.
- **Mac/web:** a centred 580 px column; the two cards side by side (wrapping when narrow); Decide later and Continue right-aligned with the main action rightmost (as the A1/A2 desktop dialogs), hint right-aligned.
- **Large text:** the label column grows to fit its longest label (`minmax(104|84px, max-content)`), so at 200 % "Language" no longer runs into its value; 100 % renders are pixel-identical before and after that change. Buttons keep labels on one line and wrap.
- **Finding (not changed):** the approved iPhone B1 uses a fixed 112 px label column; at a simulated 200 % "Language" runs into "Deutsch". The same one-value fix (`minmax(112px, max-content)`) is proposed, pending the owner.
- **Checks:** light and dark at 100 % and 200 %; text fit clean; contrast: labels 5.73 / 9.39, Decide later 6.81 / 8.74, Continue 7.27 / 7.69, selected border 6.81 / 8.74. Existing frames unchanged. Published version `1794224568-5e98`; live equals local. Snapshot v1.94-working.


### ED-229 · E-CR160 iPhone B1: label column grows at large text
- **Date:** 2026-11-09. **Owner:** "Yes, fix iPhone B1".
- **Change:** `SettingsChoice` (iPhone B1; the dark frame reuses it) label column `112px` → `minmax(112px, max-content)` in both cards, the fix proposed in ED-228. Nothing else changed (2 declarations).
- **Checks:** at 100 % the light and dark renders are pixel-identical before and after (0 differing pixels once fonts load); at a simulated 200 % "Language" no longer runs into its value; text fit clean. Published version `1794224686-9256`; live equals local. Snapshot v1.95-working.


### ED-230 · E-CR160: Settings › Account "Choose settings" row (after Decide later) on three platforms
- **Date:** 2026-11-09. **Owner:** "Yes, draw it".
- **Added (light + dark each), new row 7 "After Decide later · Settings › Account: Choose settings":** `AccountChoose` (iPhone), `AndroidAccountChoose`, `DesktopAccountChoose`. Each is the platform's Account page (as behind A1: "Signed in as sam@example.com", "Synced") plus one row with the approved built strings `accountChooseSettings` "Choose settings" and `accountChooseSettingsBody` "This device had different settings when you signed in." and a chevron; the row opens B1 again. iPhone: an inset grouped row (64 pt); Android: a two-line list item (72 dp); Mac/web: a bordered row in the Account pane (56 px). No new copy or colours.
- **Checks:** light and dark at 100 % and a simulated 200 %; text fit clean; contrast: row title 15.83, subtitle 5.45–5.73 light / 9.39–10.1 dark. Existing frames unchanged. Published version `1794224830-1be6`; live equals local. Snapshot v1.96-working.
- **ED-222 audit:** every missing frame is now drawn (CR-173 resolved).


### ED-231 · E-CR160 implementation handoff (read-only)
- **Date:** 2026-11-09. **Owner:** accepted ED-230 as final and asked for a read-only handoff.
- **Written:** `E_CR160_HANDOFF.md`. For A1, A2 (count and unconfirmed), A3, B1 and the Settings › Account "Choose settings" return path it lists:
  - the frames and platform variants;
  - copy, actions, when each screen shows, and accessibility;
  - what the build has, from a read-only look at `fix/cr-160-account-ownership` `ff3266eb` plus that session's uncommitted A3 change;
  - what is still pending or needs checking on a platform.
- **Main gaps found:**
  - Concept E styling;
  - A1 Android text buttons;
  - A1 Mac/web focus on Cancel;
  - A3 and B1 Mac/web layouts;
  - the A3 change is not committed;
  - the B1 code comment wording;
  - no test for the "Choose settings" return path;
  - 200 % checks on the four platforms.
- **Build differs from the board:** B1 has a fifth row, Theme, which uses existing strings. It is recorded, not redesigned.
- **Criteria:** finishing the mockups does not satisfy criterion 2 or 7. Per `docs/cr-160-verification.md`, criterion 2 is PARTIAL and criterion 7 is PASS on automated tests only. **CR-160 stays CRITICAL — OPEN — RELEASE BLOCKER.**
- **Not changed:** boards, branches, production code, auth, sync, Supabase. Nothing committed.
- **Next:** design work on CR-160 screens stops until the build finds a specific discrepancy. Snapshot v1.97-working.


### ED-232 · CR-093 option A: E-Minimal web uses the Mac split (200 / 790 / 290)
- **Date:** 2026-11-13. **Owner:** "Option A", on CR-093 as presented: at 1280 the Mac drew sidebar 200, Now 790, Day 290 and the web drew 200, 570, 510, against "width decides composition" (`DESIGN_PRINCIPLES.md` §2; the redesign bullet of `CLAUDE.md` §11; E-Minimal's own note "Same layout as Mac at the same width").
- **Rule:** Minimal on Mac and web shares one split. Sidebar 200, Day column 290, and the Now pane takes the rest (790 at 1280). Web gets the Mac's fold point (about 1042 at 100 % text, ED-170). Only the chrome differs.
- **Applied, E-Minimal web frame (light and dark):**
  - Now pane 570 → 790 (padding 22 32 → 22 45).
  - Day column 510 at x 770 → 290 at x 990 (padding 14 24 0 18 → 12 10 0 6).
- **Derived from the Mac frame (so the same layout really holds):**
  - Horizon 496 → 700 (31 → 43.75 px per hour), every position copied from the Mac's horizon.
  - Action row centred at 460 (gap 10).
  - Also now / Next 236 → 336 (one column of the Mac's bottom row).
  - The open Need more time? popover now aligns to the button's leading edge (left 429), so it no longer covers the Also now / Next times.
- **Fit fixes in the 290 web column, using the Mac's existing parts:**
  - The text button "Hide the day thread" becomes the Mac's 32 px ✕ icon button. Its accessible name and tooltip keep the web wording "Hide the day thread".
  - The current task's "9:00–11:00 AM · Now, 18 min left" line becomes the Mac's three lines: time, title, "Now, 18 min left".
  - "Day ▾" (view), "Day menu", "drag to move", "1 h 30 free · add here" and every row are unchanged.
- **Insets:** "Task in the web column" and the "Mac and web · Day review in the Day column" inset are both redrawn in the 290 column: card 468 → 274 and column padding as above. The Day review inset had been drawn only at 510 although its label says Mac and web. Content and copy are unchanged; text wraps without clipping. The caption now says "the 290 column (CR-093, ED-232)".
- **Not changed:**
  - The Mac frame. Everything before the web frame is byte-identical in both files.
  - The web orb, 240 px with the numeral 85 (ED-106 approved this per platform), and the web row and type sizes.
  - Colours: no new value; dark parts are copied from the dark Mac frame.
- **Board heights:** the narrower insets grew taller. E-Minimal and E-Minimal-Dark go 4320 → 4440 (content ends at 4400). E-Responsive-Dark moves down 120 to y 36420 to keep the 80 px gap; it overlaps nothing.
- **E-Map:** four width notes updated (web now 200 + 790 + 290).
- **Checks:**
  - Rendered light and dark. Panes measure 0/200, 200/790, 990/290. No horizontal overflow; the only flag is a visually hidden label, as before.
  - Insets fit at 100 % and at a simulated 200 %.
  - At a simulated 200 % the fixed 800 px web frame overflows vertically, as the original web frame and the Mac frame already did (rows are drawn at fixed heights; rows grow and panes scroll in the app). No new horizontal clipping.
  - Published version `1794539294-aa99` (boards, canvas) and `1794539340-c399` (E-Map); all four files equal local. Snapshot v1.98-working.
- **Found, not changed (owner's call):**
  - (1) With one split, the orb still differs by platform at the same width (Mac 280 / numeral 100, web 240 / 85, both approved in ED-106).
  - (2) The hide button's name differs: Mac "Hide the Day column", web "Hide the day thread".
  - (3) The Mac ✕ button's accessible name still says "Option Command D" while ED-218 bound ⌥⌘I.
- **Correction to the 2026-11-13 reconciliation:** CR-006 and CR-050 were marked resolved because a board-text check had failed silently: the shell's grep rejected the pattern and printed nothing. Re-checked with a working parser:
  - E-Phones still says "dots with depth".
  - E-PhonesMinimal still says "sits beside A's full phone board and replaces neither" and "Week view in full mode".
  - "Hypothesis · not approved" tags remain on approved items.

  Both entries are reopened as design fixes.
- **Not touched:** production code, CR-160, Supabase, other branches. Nothing committed.


### ED-233 · CR-093 follow-ups: one orb, one hide-button name, ⌥⌘I in the spoken labels
- **Date:** 2026-11-13. **Owner:** "Apply all three", for the three differences that ED-232 found (1A, 2A and the correction).
- **1A · One orb (supersedes ED-106's web size):**
  - The E-Minimal web orb uses the Mac drawing: 240 → 280 px, inset 48 → 56, icon 22 → 26, numeral 85 → 100, "min left" 13 → 15.
  - The title below it goes 22/28 → 24/30 and the time gets the Mac's 2 px gap. Margins match the Mac (22 above the orb, 16 above the title).
  - The open Need more time? popover moves down with its button (top 526 → 576).
  - The web pane content now ends at 783 of the 800 px frame (was 733).
  - The ring, colours, proportion (0.36) and layout are unchanged. The ED-106 stack check for 280 already covers it: 149 of 179 px.
- **2A · One name:** the web ✕ button's accessible name and tooltip go "Hide the day thread" → "Hide the Day column", matching the Mac and the View › Show Day Column command. The E-Minimal note now says "Hide the Day column" (web).
- **Correction (follows ED-218):** "Hide the Day column, Option Command D" → "…Option Command I" in every accessible name: E-Minimal 2, E-FullA-v2 2, E-G4-3-Narrow 13, with the same counts in each dark copy. Nothing visible changes; the visible hints already showed ⌥⌘I.
- **Checks:**
  - A token diff of each board shows only these edits.
  - Rendered light and dark: panes 200 / 790 / 290; no horizontal overflow, the only flag being the visually hidden label as before. Board content ends at 4400 of 4440.
  - No new colour. Published version `1794541712-d8a3`; all 6 files equal local. Snapshot v1.99-working.
- **Records:** the rules (orb sizes, web Day column header), the screen inventory and the handoff are updated.
- **Not touched:** production code, CR-160, Supabase, other branches. Nothing committed.


### ED-234 · Phone tab bar / toolbar on every pushed Settings page (not on pull-ups)
- **Date:** 2026-11-13. **Owner (canvas comment on E-G2-4):** "add the menu tab to the settings mockup according to each mobile platform using the E concept to be consistent with all the existing menus", then "go on with this application only don't apply if the settings screen is a half pull up screen or a full pull up screen."
- **Rule:** completes ED-161. Every Settings page pushed on a phone shows that platform's bottom bar:
  - iPhone: the glass tab bar with the teal + (ED-124).
  - Android: the floating toolbar with Add (ED-125).
  - Minimal iPhone: the Now · Today · Inbox bar (ED-132).

  Today stays selected (the tab Settings was opened from), as on the approved Settings roots. The bar does not show on half sheets, pull-ups or full-screen dialogs (Cancel / Save, ✕ / Save).
- **Applied (light and dark, bar copied from the same board's approved frame):**
  - E-Phones, iPhone: Your day; Wake Up and Wind Down (overview, The night, Wake Up alarm, Alarm sounds on).
  - E-Phones, Android: Wake Up and Wind Down overview.
  - E-PhonesMinimal: the minimal Settings list and the Settings root it opens.
  - 8 frames per theme.
- **Skipped (pull-ups and dialogs):**
  - the iPhone schedule sheets (Weekdays ×3, Weekend, New schedule);
  - the Android full-screen Weekdays dialog;
  - E-Phones-3's Edit palette half sheet, which was already without a bar.
- **Not changed:** the historical E-G2-4 board; Mac and web, which have no tab bar.
- **Checks:** diffs are insertions only (no content removed). In the rendered frames, the bar sits at the approved position and the bottom of each scrolling list passes behind it, as on the Settings roots; nothing is cut off. Board heights are unchanged. Published version `1794557941-f085`; all 4 files equal local. Snapshot v2.00-working.
- **Relates to CR-033:** this settles how Settings pages look under the drawn entry. Approval of G2-3 itself (the avatar entry) is still the open owner decision.


### ED-235 · Settings pages: no tab selected in the phone bar
- **Date:** 2026-11-13. **Owner (canvas comment):** "there should not be any active button selected as that is the settings and no settings button exists with the menu".
- **Rule (amends ED-161 and ED-234):** on every phone Settings page the bar shows all its tabs unselected, because Settings is not a tab. The + / Add stay as drawn.
- **Applied (light and dark):** Today was set as the selected tab; it now uses the board's own unselected tab style (Calendar's on Full, Now's on Minimal), and `aria-current` is removed.
  - E-Phones: 8 frames (the iPhone and Android Settings roots, Your day, the Android Wake Up and Wind Down overview, and four iPhone Wake Up and Wind Down pages).
  - E-PhonesMinimal: 2 frames.
  - E-Phones-3: 8 frames (Settings roots and Appearance pages).
- **Not changed:** the miniature tab bar inside the Appearance live preview, which shows the Today screen and keeps Today selected; sheets and dialogs; Mac and web.
- **Checks:** rendered light and dark, with no tab highlighted. Board text and geometry are otherwise unchanged. Published version `1794558169-5f3d`; all 6 files equal local. Snapshot v2.01-working.


### ED-236 · E-G2-4 (history board): its three iPhone Settings frames get the phone bar
- **Date:** 2026-11-13. **Owner (canvas comment on E-G2-4):** "all this is not updated on this particular mockup. please also update it here."
- **Applied (light only; the board has no dark copy):** the ED-234 / ED-235 bar, with no tab selected, copied from the current E-Phones and E-PhonesMinimal Settings frames:
  - "Full Settings today" and the proposed Full root: the glass tab bar with the teal +.
  - The minimal Settings list: the Now · Today · Inbox bar.
- **Insertion only;** frame contents, sizes and the board's text are unchanged. The first frame illustrates the built long list. With the bar it now shows that list in E's chrome; the app today still has Settings as a fifth tab (CR-033).
- **Checks:** rendered; nothing cut off; published version `1794558407-845e`, live equals local. Snapshot v2.02-working.


### ED-237 · E-SettingsReview (approved review board): its four phone Settings frames get the phone bar
- **Date:** 2026-11-13. **Owner (canvas comment on E-SettingsReview):** "apply the menu here on this settings mockup as every other one recently applied".
- **Applied (light only; the board has no dark copy):** the ED-234 / ED-235 bar, with no tab selected, copied from the current E-Phones and E-PhonesMinimal Settings frames:
  - the iPhone Settings root and Your day: the glass tab bar with the teal +;
  - the Android Settings root: the floating toolbar with Add;
  - the minimal Settings list: the Now · Today · Inbox bar.

  These are all full pages; the board has no pull-ups.
- **Insertion only;** frame contents and the board's text are unchanged. Rendered; nothing cut off. Published version `1794558519-2341`, live equals local. Snapshot v2.03-working.


### ED-238 · G2-3 approved (option A): Settings opens from a native secondary place; overall approval of Concept E moves to the release gate
- **Date:** 2026-11-13. **Owner:** "Approve G2-3 option A and move overall approval to the gate."
- **G2-3, option A (approved; was adopted from the board only, ED-077):** Settings is not a tab. Each platform opens it from its native secondary place:
  - iPhone and Android: the avatar button "Settings and account" in the top row. Minimal phones also reach it from the Day menu (ED-093).
  - Mac: Dottoday › Settings… ⌘, in its own window.
  - Web: the Settings row at the foot of the sidebar, `/settings`. Mobile web uses the avatar.
  - iPad and Android tablets: the sidebar footer, drawn in Round 2.

  Every built Settings entry still reaches Settings. The Settings pages keep the platform bar with no tab selected (ED-234, ED-235). This is a change from the built app, where Settings is the fifth phone tab and sits at the rail foot. It is recorded for implementation; nothing is built.
- **Overall approval of Concept E:** this is not a consistency item. It is the release gate after Prompt D Round 2 and its tablet coverage checklist (ED-090), and it is now tracked in STATUS. Until then Concept E stays LEADING CANDIDATE — NOT APPROVED FOR PRODUCTION IMPLEMENTATION.
- **Consistency report:** CR-033 and CR-047 are resolved.
- **Not decided here:** G2-13 ("Plan from Inbox · 3" on the Full empty day), which stays adopted from the board and listed in pending owner answers.
- **No board changed.** Snapshot v2.04-working.


### ED-239 · CR-025 / CR-098 option A: native right-click menus on Mac; drawings unified at radius 10
- **Date:** 2026-11-13. **Owner:** "Option A".
- **Decision:** on Mac the right-click (context) menus and their submenus are the system menu (NSMenu), like the menu bar, which is already native (`PlatformMenuBar`). They get the system's look, keyboard navigation, VoiceOver, Increase Contrast and dark mode. The board drawings are approximations of those menus.
- **Board change (light and dark):** drawn Mac menus are unified at radius 10:
  - Gym menu 8 → 10 on E-Minimal, E-FullA-v2 (minimal reference frame) and E-G4-3-Narrow;
  - Need More Time submenu 8 → 10 on E-Minimal and E-FullA-v2.

  That is 5 values per theme. The Lunch menus were already 10. E-Map's familiarity note now says Mac menus are native and drawn as approximations.
- **Built today:** the menu bar is native. Right-click menus are drawn by Flutter (the Inbox row's secondary click; `MenuAnchor`). Flutter has no built-in native context menu on macOS, so building this needs a small Swift bridge, as for the existing status item, with no new package. It must carry the same items, key hints, disabled states and Undo.
- **Feasibility check:** tracked in CR-098 (now a verification item). Web and the other platforms keep their own menus.
- **Checks:** token diffs show only the radius values and the one E-Map sentence. Published version `1794560731-b4cc`; all 7 files equal local. Snapshot v2.05-working.


### ED-240 · CR-117 option A: the + is named "Add a task" on every platform
- **Date:** 2026-11-13. **Owner:** "Option A".
- **Rule:** the accessible name of the + is "Add a task" everywhere. Each platform keeps its own extra:
  - iPhone: "… Hold for Brain dump, Routine, Paste a list".
  - Android: announced as opening a menu (`aria-haspopup="menu"` on the drawings), because the + opens the M3 menu of Add options (ED-091).
  - Web: "(n)".
  - A dated + says "Add a task to <date>".
- **Board change (light and dark; names only, nothing visible):** the Android Full + "Add" → "Add a task", and "Add to Tuesday 3 November" → "Add a task to Tuesday 3 November". Each also gains `aria-haspopup="menu"`. That is 9 buttons per theme:
  - E-Phones 4;
  - E-Phones-3 3;
  - E-Phones-2 2 (my presentation counted 7; E-Phones-2 had 2 more).

  Android Minimal, iPhone and web already said "Add a task".
- **Built today:** "Add task" (`quickAddTooltip`). At implementation it becomes "Add a task" in en, de, es and fr, and the Android + exposes its menu role.
- **Checks:** token diffs show only these names and attributes. Published version `1794560993-5316`; all 6 files equal local. Snapshot v2.06-working.


### ED-241 · CR-015 option A: now-bead size by context
- **Date:** 2026-11-13. **Owner:** "Option A", after the side-by-side comparison (`references/concept-e/cr015-compare/`).
- **Rule:**
  - Phone Today thread: 16 px.
  - Wide windows (Workspace and the Day column, on Mac and web alike): 14 px.
  - The horizon (Minimal Now): 14 px at every size, the same as its task dots.
  - Board legends are keys and stay as drawn (the same exemption as ED-217).
- **Board change (light and dark):** the three E-FullA-v2 web beads (Web, Web · hidden by you, Web · brought out) go 16 → 14. Each moves by 1 px so it stays centred on the now line. No other bead changed.
- **Checks:** token diffs show only those values (left, top, width, height). Published version `1794562180-d575`; both files equal local. Snapshot v2.07-working.


### ED-242 · CR-067 option A: the Day column state, the Day panel and the palette have no address
- **Date:** 2026-11-13. **Owner:** "Option A".
- **Rule (extends G2-11 · ED-097):**
  - **Showing or hiding the Minimal Day column** (⌥⌘I on Mac, the ✕ "Hide the Day column" on web) is a view setting, not a place. It is remembered on that device, like a sidebar, and it never changes the address or adds a Back step. `/today` still reveals the column (ED-097).
  - **The narrow-window Day panel (ED-170) and the Search or run palette** (⌘K / `k`) are temporary layers. They have no address and are not a Back step; Esc or ✕ closes them and focus returns to what opened them. A refresh restores the page under them, not the layer.
  - **Unchanged:** the link guard still accepts one query key, `?task=` (D2), and no search text goes into an address (D3).
- **No board changed.** Recorded in design rules (routes), the handoff and the register. CR-067 is resolved.
- **For implementation:** store the Day column setting per device, not synced, so Mac and web each keep their own.
- **Tests:**
  - hiding and showing changes neither the address nor history;
  - opening the palette or the Day panel adds no history entry, and Back from the page navigates normally;
  - refresh with either layer open shows the page without it.
- **Snapshot:** v2.08-working.


### ED-243 · Group 1 design fixes: stale board copy (CR-006, CR-050)
- **Date:** 2026-11-13. **Owner:** "Yes, group 1" (board copy only, no drawing).
- **E-Phones (light and dark):**
  - Title "A · Refined Timeline" → "E · Refined Focus".
  - "dots with depth" → "flat dots (ED-023)".
  - The header tag for the owner's 3 Nov changes → "Accepted · owner, 3 Nov (ED-009 to ED-025; later changes in the decision log)".
  - The two "Settings behind the avatar" tags → "Approved · G2-3 (ED-238)".
- **E-PhonesMinimal (light and dark):**
  - The title now says E's look.
  - The header ("It sits beside A's full phone board and replaces neither") → E's Minimal mode on phones beside the Full board, tagged "Approved · G1-2, G1-5 (ED-065, ED-068)".
  - The three-tab glass bar → ED-068.
  - The Android toolbar and Settings → ED-068 and ED-238.
  - The Settings half of "Focus by tapping the big now-dot; Settings behind the avatar" → ED-238.
  - The band "Week view in full mode" → "In Full, the Calendar tab opens Month (ED-075)" (CR-050).
- **E-Minimal (light and dark):**
  - The header → "Approved · ED-064, G1-5 (ED-068)". The text now says Full on Mac and web is E-FullA-v2 (ED-073), and the outdated "same frames as C · Minimal" line is dropped.
  - "Behaviours inside E's wide minimal" → ED-068 and ED-089.
  - "Day in the task column" → ED-089.
- **Kept as "Hypothesis · not approved", because no decision covers them:**
  - "Focus by tapping the big now-dot" (E-PhonesMinimal);
  - "No Inbox suggestions on an empty minimal day" (E-PhonesMinimal; it goes with G2-13, which is adopted from the board only);
  - "click the big dot for Focus" and "Thread optional beside the now-dot" (E-Minimal).

  The legend key "Hypothesis · not approved" stays on every board.
- **Checks:** text changes only. Board heights are unchanged and the rendered headers fit. Published version `1794564596-0164`; all 6 files equal local. Snapshot v2.09-working. CR-006 and CR-050 are resolved.


### ED-244 · The last four board hypotheses approved
- **Date:** 2026-11-13. **Owner:** "approve all the hypothesis in group 1".
- **Approved:**
  - **E-PhonesMinimal:** Focus opens by tapping the big now-dot. An empty minimal day shows no Inbox suggestions, and the Inbox stays one tab away with its count. This is the Minimal half of G2-13; the Full half, "Plan from Inbox · 3" on the Full empty day, stays adopted from the board (ED-077).
  - **E-Minimal:** clicking the big dot opens Focus. The thread is optional beside the now-dot.
- **Board change (light and dark):** those four tags read "Approved · owner, 13 Nov (ED-244)". No active board now carries "Hypothesis · not approved" outside its legend key.
- **Checks:** text only. Published version `1794564839-069d`; all 4 files equal local. Snapshot v2.10-working.


### ED-245 · Group 2 design fixes presented on E-DF2 (before Wake Up, the moving now) · for review
- **Date:** 2026-11-13. **Owner:** "yes group 2".
- **Board `E-DF2`** (light, review only; canvas x 21860, y 156140). No active board is changed.
- **A · Before Wake Up (CR-021).** The built rule (`ThreadOutside`, docs/02 F1.15) is drawn for the first time.
  - Two iPhone Today frames, copied from E-Phones, show the "1 task before Wake Up" row folded and shown above the sun cap. It uses the Earlier fold component (ED-164); "Early run" is sample data.
  - **Rule card:** after Wind Down folds the same way below the moon cap. A task crossing a cap stays inline, so Morning run is already correct. A zone holding the live task starts unfolded.
  - **Proposed:** Minimal drops the count ("Before Wake Up"). The horizon spans Wake Up to Wind Down and names outside tasks only in its spoken summary. The Mac/web Day column gets the same row.
- **B · The moving now (CR-022, CR-103 motion).** It moves once a minute (built minute tick).
  - **Proposed:** the bead slides 200 ms ease-out with the pill updating at once (DotMotion.base); Reduce Motion jumps (built DotMotion.reduced); no catch-up animation after the background.
  - **Screen reader:** the bead's label updates silently, with one polite announcement when the current task changes. The same rule applies to the horizon and wide beads.
- **Checks:** content 1632 of 1720; no clipping; published version `1794566023-df2b`; both files equal local.
- **Status:** PROPOSED · awaiting the owner. Snapshot v2.11-working.


### ED-246 · Group 2 approved: the before-Wake-Up fold and the moving now (E-DF2)
- **Date:** 2026-11-13. **Owner:** "Approve both" (ED-245, board E-DF2).
- **A · Before Wake Up / after Wind Down (CR-021):**
  - The built `ThreadOutside` rule as drawn: one row above the sun cap ("1 task before Wake Up") and one below the moon cap. Each unfolds into ordinary rows and uses the Earlier fold component.
  - A task that crosses a cap stays inline. A zone holding the live task starts unfolded.
  - Minimal says "Before Wake Up" / "After Wind Down" with no count.
  - The horizon spans Wake Up to Wind Down and names outside tasks only in its spoken summary.
  - The Mac/web Day column has the same row: focusable, toggled with Space or Return.
- **B · The moving now (CR-022; the motion part of CR-103):**
  - Once a minute, on the minute (built minute tick). The pill shows the new minute at once; the bead slides 200 ms ease-out (DotMotion.base) and the elapsed thread grows with it.
  - Reduce Motion: the bead jumps (DotMotion.reduced). No catch-up animation after the background.
  - The bead's label "Now, 10:42" updates silently. One polite announcement when the current task changes; focus never moves.
  - The same rule applies to the horizon and the Mac/web Day column bead.
- **Board:** E-DF2 is relabelled approved and kept as the reference board for these two rules. No other board changed. Published version `1794567342-eaa3`; both files equal local.
- **Records:** design rules, handoff and register updated. CR-021 and CR-022 are resolved. CR-103 narrows to the Reduce Transparency / Increase Contrast frames of the G4-7 kit, which still have to be merged. Snapshot v2.12-working.


### ED-247 · Group 3 design fixes presented on E-DF3 (keyboard and screen-reader paths) · for review
- **Date:** 2026-11-13. **Owner:** "Yes, group 3".
- **Board `E-DF3`** (light, review only; canvas x 21860, y 158100). No active board changed.
- **A · Focus order, wide Minimal (CR-105).** A copy of the E-Minimal Mac window at 75 % with numbered focus outlines, plus the task screen.
  - Tab order: sidebar → toolbar → horizon → Now actions → Also now / Next with Add and Hide the Day column → Day column. On web, the built skip link comes first.
  - The horizon is one Tab stop: ←/→ and Home/End move between dots; Return opens the task in the Day column.
  - In the Day column, ↑/↓ move between rows.
  - An opened task takes focus on its title. Esc or ✕ returns focus to the dot or row that opened it.
  - Full follows E-G4-7-States D2.
  - On phones the horizon is one adjustable element with an "Open" action.
- **B · The Week for screen readers (CR-107).** The built order already reads day by day: each day is a heading, then its cards. Proposed additions, shown with a sample VoiceOver transcript:
  - each day heading says how many tasks and how much time are planned;
  - overlapping cards say "overlaps …";
  - arrow keys move between cards.

  No separate list view.
- **C · Reduce Transparency and Increase Contrast (rest of CR-103).** Proposed: adopt E-G4-7-States D4 as the rule for every active board instead of redrawing each one:
  - glass becomes solid with a 1.5 px outline;
  - secondary text is one step darker;
  - the dotted thread is stronger;
  - borders and focus rings are at least 3:1.
- **Checks:** content 1526 of 1600; published version `1794567586-f0c7`; both files equal local.
- **Status:** PROPOSED · awaiting the owner. Snapshot v2.13-working.


### ED-248 · Group 3 approved: focus order, the Week for screen readers, Reduce Transparency / Increase Contrast (E-DF3)
- **Date:** 2026-11-13. **Owner:** "Approve all three" (ED-247, board E-DF3).
- **A · Focus order, wide Minimal (CR-105):**
  - Tab order: sidebar → toolbar → horizon → Now actions → Also now / Next, Add and Hide the Day column → Day column. On web the skip link comes first.
  - The horizon is one Tab stop: ←/→ and Home/End move between dots; Return or Space opens.
  - In the Day column, ↑/↓ move between rows.
  - An opened task takes focus on its title; Tab stays inside the task screen's controls; Esc or ✕ returns focus to the opener. Day review behaves the same.
  - Full follows E-G4-7-States D2.
  - Phones: reading order; the horizon is one adjustable element with an "Open" action.
- **B · The Week for screen readers (CR-107):**
  - It reads day by day: each day heading, then its cards (as built). Each heading adds "N tasks, H planned".
  - Overlapping cards say "overlaps …".
  - Keyboard: Tab enters on today's first card; ↑/↓ within a day; ←/→ to the same time on the next or previous day; Return opens the inspector.
  - No separate list view.
- **C · Reduce Transparency and Increase Contrast (rest of CR-103):** E-G4-7-States D4 is the rule for every board:
  - glass becomes solid with a 1.5 px outline;
  - secondary text is one step darker;
  - the dotted thread is stronger;
  - the frosted Android toolbar and Mac vibrancy turn solid;
  - borders and focus rings are at least 3:1.
- **Board:** E-DF3 is relabelled approved and kept as the reference board. Published version `1794567657-2ee5`; both files equal local.
- **Records:** design rules, handoff, register. CR-103, CR-105 and CR-107 resolved. No design fixes remain open in the consistency report. Snapshot v2.14-working.


### ED-249 · Tablet coverage checklist written (the preparation step before Round 2)
- **Date:** 2026-11-13. **Owner:** "Tablet checklist".
- **Written:** `E_TABLET_CHECKLIST.md`, which gathers every tablet note in ED-083 to ED-248, the register and STATUS. It contains:
  - the approved rules every tablet screen follows;
  - what already exists: the Wake Up and Wind Down tablet panes (ED-084), the iPad option D editor (ED-086), the E-Responsive schematics and the iPad spike;
  - a per-feature checklist in the ED-090 columns, in the G4-1 order;
  - five decisions needed before tablet drawing: Q1 Full on expanded tablets (Workspace or thread), Q2 the Minimal Day menu on tablets, Q3 content type on touch tablets, Q4 Apple Pencil scope, Q5 the iPad editor and the docking rule;
  - the Round 2 drawing list and the verification items.
- **Not started:** Prompt D Round 2 and any tablet drawing. No board changed. Snapshot v2.15-working.


### ED-250 · Tablet Q1 mockups on E-T1 (Full on an expanded tablet) · for review
- **Date:** 2026-11-13. **Owner:** "i want to see the Mockup as it helps me approve".
- **Board `E-T1`** (light, review only; canvas x 21860, y 159940). iPad Air landscape, 1180 × 820.
  - **A:** the approved Full Workspace (the E-G4-3-Narrow 1160 window, inspector docked) on the iPad screen, with only the Mac title bar and right-click menu removed.
  - **B:** the approved phone Today thread beside the approved option D editor, under iPadOS top tabs.
- **No active board changed.** Published version `1794568135-9ae9`; both files equal local. Snapshot v2.16-working.
- **Status:** PROPOSED · awaiting the owner (tablet checklist Q1).


### ED-251 · Tablet Q1: options C and D added, every option on iPad and Android tablet (E-T1)
- **Date:** 2026-11-13. **Owner:** "give me an option C and D, be creative with it using the Concept E … also always make sure you include android tabs". Guidance from the apple-design skill: `split-views.md`, `sidebars.md`, `tab-bars.md`, `designing-for-ipados.md`.
- **Board `E-T1`** (now 2160 × 2540): A, B, C and D, each on an iPad Air (1180 × 820) and an Android tablet (1280 × 800), landscape, at 60 %.
  - **A:** the approved Full window, 1160 on iPad and 1280 on Android.
  - **B:** thread plus the option D editor. Android uses the navigation rail with the +.
  - **C · Week of threads (new):** today's thread, and the week as seven day-threads on one 7 AM–11 PM axis. The Inbox is a tray of loose dots dragged onto a day's thread (drop target "Thu 11:00").
  - **D · Horizon desk (new):** Minimal's horizon made Full: done tasks folded into "Earlier · 3 done", a week strip, and Now (orb), Next and Inbox cards.
  - C and D use only Concept E parts and tokens with the same sample day. If either is chosen, it should also be the view at the same width on Mac and web (width decides layout).
- **No active board changed.** Published version `1794568665-b214`; both files equal local. Snapshot v2.17-working.
- **Status:** PROPOSED · awaiting the owner (tablet checklist Q1).


### ED-252 · Tablet Q1 approved: option A, the Workspace on expanded tablets
- **Date:** 2026-11-13. **Owner:** "Option A" (board E-T1).
- **Decision:** on expanded tablet windows (≥ 840; iPad landscape, Android tablets, unfolded foldables), Full is the Workspace, the same layout as Mac and web at the same width (ED-073, DESIGN_PRINCIPLES §2):
  - sidebar;
  - Plan panel (hides on narrower windows, ED-184);
  - Day / 3 days / Week / Month grid;
  - inspector, docked from 1160 and floating below (ED-167, ED-170).

  Medium windows keep ED-171's tablet navigation.
- **For Round 2 (touch version, iPad and Android):**
  - iPad: the iPadOS sidebar that folds to top tabs at medium.
  - Android: a sidebar at expanded and a rail at medium (ED-171).
  - 44 pt / 48 dp targets in the grid and sidebar.
  - Long-press to drag; no hover on touch (ED-116).
  - A native segmented control for the ranges.
  - Keyboard and pointer as on Mac (ED-095, ED-248).
  - G3-1's phone sizes do not apply to the grid (ED-104).
- **Not chosen:** B (thread + second pane), C (Week of threads) and D (Horizon desk). E-T1 is kept as history, with A marked chosen.
- **Board:** E-T1 relabelled. Published version `1794569594-f986`; both files equal local.
- **Checklist:** Q1 answered in `E_TABLET_CHECKLIST.md`. Q2–Q5 open. Snapshot v2.18-working.

### ED-253 · Tablet Q2 mockups: the Day menu in Minimal on tablets
- **Date:** 2026-11-13. **Owner:** "Yes, Q2". Board E-T2, proposed, for owner review. Nothing is applied to an active board.
- **What it shows:** the approved Minimal window (E-G4-3-Narrow) on an iPad Air in landscape (the 1160 window on 1180 × 820) and on an Android tablet (1280 × 800), with the Day menu open under the Day button. The only change is that the Mac title bar is removed.
  - **A · By width (recommended):** medium and expanded windows get E-Minimal's Day menu (ED-093). Compact windows (Split View ⅓, Slide Over) get the phone three-item menu. iPad uses a native pull-down; Android uses an M3 menu. This is the same rule as Q1 (ED-252) and CR-093.
  - **B · The phones' three-item menu at every width:** Show everything · Low-energy mode · Settings (doc 14 §4). The other commands are reached through Search or run and Show everything. Trade-off: at the same width, the menu differs from Minimal on Mac and web.
- **Menus used:** both are copies of approved menus, E-Minimal's Day menu and E-PhonesMinimal's menu. The Android versions use the M3 menu surface. No new copy.
- **Board:** E-T2, canvas x 21860, y 162720. Published version `1794569862-8c6d`; both files equal local.
- **Checklist:** Q2 in `E_TABLET_CHECKLIST.md` points to E-T2. Snapshot v2.19-working.

### ED-254 · Tablet Q2 approved: option A, the Day menu in Minimal by width
- **Date:** 2026-11-13. **Owner:** "Option A" (board E-T2).
- **Decision:** in Minimal on tablets, the window's width decides which Day menu appears (DESIGN_PRINCIPLES §2, ED-252, CR-093). It is the same as Minimal on Mac and web at that width.
  - Medium and expanded windows (≥ 600; iPad and Android tablets in landscape and portrait, unfolded foldables): E-Minimal's Day menu (ED-093). It has Need more time (+5 / +15 / +30), Shift the rest, Brain dump, Drop a routine, Duplicate, Copy as text, Review the day, Low-energy mode and Show everything.
  - Compact windows (iPad Split View ⅓, Slide Over, narrow Android multi-window): the phones' three-item menu, Show everything · Low-energy mode · Settings (E-PhonesMinimal).
  - Presentation: on iPad, a native pull-down (UIMenu) from Day ▾; on Android, an M3 menu anchored to the Day button.
- **For Round 2:** draw the touch version of the menu (44 pt / 48 dp rows), the compact-window case on both platforms, and dark.
- **Not chosen:** B (the three-item menu at every width). It is kept on E-T2 as history, with A marked chosen.
- **Board:** E-T2 relabelled. Published version `1794570110-cc9f`; both files equal local.
- **Checklist:** Q2 answered in `E_TABLET_CHECKLIST.md`. Q3–Q5 open. Snapshot v2.20-working.

### ED-255 · Tablet Q3 mockups: content type size on touch tablets
- **Date:** 2026-11-13. **Owner:** "Yes, Q3". Board E-T3, proposed, for owner review. Nothing is applied to an active board.
- **What it shows:** the approved Minimal window (E-G4-3-Narrow) on an iPad Air in landscape (the 1160 window on 1180 × 820) and on an Android tablet (1280 × 800). The only change is that the Mac title bar is removed. A last row shows the Day column at 100 %.
  - **A · Mac sizes, as drawn:** content as on Mac and web at that width (rules §3.2, middle column). Row title 15, time 12.5, 28 pt done targets.
  - **B · Phone content sizes with touch spacing (recommended):** the same layout with the approved phone content scale (rules §3.2, Phones column):
    - row title 17 and time 13;
    - now row 18 and Now title 26;
    - buttons 16 at 48 tall and Add field 17;
    - done circles in 44 pt targets.

    The Now pane's own gaps shrink so nothing leaves the window.
- **What B costs, shown on the board:**
  - On the sample day both still fit; B uses about 85 px more of the Day column, and "Deep work: roadmap" wraps to two lines.
  - The half-width Add field on Android cuts off its placeholder at 17.
- **Unchanged in both:** chrome stays native (SF with Dynamic Type on iPad; Roboto and the M3 scale on Android, rules §3.6), and text-size settings still apply (§3.4). Compact tablet windows use the phone layout either way. No new copy.
- **Board:** E-T3, canvas x 21860, y 164320. Published version `1794570331-b3f5`; both files equal local.
- **Checklist:** Q3 in `E_TABLET_CHECKLIST.md` points to E-T3. Snapshot v2.21-working.

### ED-256 · Tablet Q3 approved: option B, phone content sizes with touch spacing
- **Date:** 2026-11-13. **Owner:** "Option B" (board E-T3).
- **Decision:** on touch tablets in medium and expanded windows, the wide layouts (E-Minimal, E-FullA-v2, and the Workspace per ED-252) keep their composition but use the phone content scale (rules §3.2, Phones column) with touch spacing:
  - row title 17, row time 13, now row 18, Minimal Now title 26;
  - buttons 16 at 48 tall; Add field 17;
  - every target 44 pt (iPad) / 48 dp (Android).

  Gaps inside a pane give space back so nothing leaves the window. The type size follows touch as the primary input; a tablet with a pointer attached keeps it.
- **Unchanged:** chrome stays native (SF with Dynamic Type; Roboto with the M3 scale), and text-size settings apply on top (rules §3.4). Compact tablet windows use the phone layout. Mac and web keep the wide sizes.
- **For Round 2:**
  - Apply the scale to the Workspace (week grid blocks, sidebar rows and inspector) and to E-FullA-v2 on tablets.
  - Size the half-width Add field on Android so its placeholder is not cut.
  - Check how many rows fit on a busy day.
  - Draw it in dark.
- **Not chosen:** A (Mac sizes). It is kept on E-T3 as history, with B marked chosen.
- **Rules:** §3.6 updated (the open bullet now records this decision).
- **Board:** E-T3 relabelled. Published version `1794570413-71a8`; both files equal local.
- **Checklist:** Q3 answered in `E_TABLET_CHECKLIST.md`. Q4–Q5 open. Snapshot v2.22-working.

### ED-257 · Tablet Q4 mockups: Apple Pencil and Android stylus
- **Date:** 2026-11-13. **Owner:** "Yes, Q4". Board E-T4, proposed, for owner review. Nothing is applied to an active board.
- **What it shows:** the decided tablet Minimal (the E-G4-3-Narrow window with the ED-256 touch sizes; the Mac title bar and pointer arrow removed) on an iPad Air (1180 × 820) with Apple Pencil and on an Android tablet (1280 × 800) with a stylus.
  - **A · Handwriting in text fields only (recommended):**
    - In any text field, the system turns writing into text: Scribble on iPad, system stylus handwriting on Android.
    - Elsewhere the stylus acts like a finger (ED-116). There are no Pencil-only actions, hover effects or drawing.
    - A 100 % card shows the result: "Gym 6pm 1h" as typed text with the usual parse chips.
  - **B · Also write on the day:**
    - Writing in a free gap on the thread becomes a task at that time; Undo removes it.
    - It needs handwriting recognition outside text fields: PencilKit and Vision on iPad, a library such as ML Kit Digital Ink on Android. That is a new dependency (must ask, CLAUDE.md §10).
    - Each platform needs its own native code, and tablets without a stylus get nothing (R-13).
- **Sample and copy:**
  - "Gym 6pm 1h", "Today 6:00 PM" and "1 h" are reused from E-PhonesMinimal's New task sheet.
  - The handwriting is drawn in a handwriting font for illustration.
  - The board's notes are review text only, not UI copy.
- **Board:** E-T4, canvas x 21860, y 166760. Published version `1794570660-610a`; both files equal local.
- **Checklist:** Q4 in `E_TABLET_CHECKLIST.md` points to E-T4. Snapshot v2.23-working.

### ED-258 · Tablet Q4 approved: option A, handwriting in text fields only
- **Date:** 2026-11-13. **Owner:** "Option A" (board E-T4).
- **Decision:** Apple Pencil and Android styluses do two things.
  - **In text fields** (Add, task title, notes, Search or run, Settings fields), the system's own handwriting turns writing into text: Scribble on iPad, system stylus handwriting on Android tablets that have it. The usual time parsing then runs (R-06, R-07).
  - **Everywhere else**, the stylus acts like a finger: tap, drag a dot, hold to select (ED-116).

  There are no Pencil-only gestures (double-tap, squeeze), no hover effects, and no drawing or handwritten notes. No new dependency.
- **For Round 2:** verify that Flutter text fields accept Scribble on iPad and stylus handwriting on Android. If one does not, record it as a platform exception with a follow-up task. Draw the focused-field state with ink in both themes.
- **Not chosen:** B (also write on the day). It is kept on E-T4 as history, with A marked chosen.
- **Board:** E-T4 relabelled. Published version `1794570730-38e8`; both files equal local.
- **Checklist:** Q4 answered in `E_TABLET_CHECKLIST.md`. Q5 is open. Snapshot v2.24-working.

### ED-259 · Tablet Q5 approved: the option D editor sits beside the day only where it can dock
- **Date:** 2026-11-13. **Owner:** "Approve as proposed" (no board; the proposal was in `E_TABLET_CHECKLIST.md` §4 Q5).
- **Decision:** option D's "editor beside the day" (ED-086) is the docked case of ED-167. It applies only where the docking predicate holds (ED-168): window width ≥ 1160, and sidebar 216 + Today 480 (600 above 130 % text) + editor 420, plus dividers and gutters, fit. Elsewhere, the same editor floats over Today, and compact windows use the phone sheet. The editor, its state and its fields are the same in every case. Crossing the boundary never saves, discards or commits anything (ED-100, ED-168).
- **Applies to both platforms, by width, never by device (DESIGN_PRINCIPLES §2):**

  | Where | Width | Editor |
  |---|---|---|
  | iPad Air and Pro, landscape | 1180+ | Beside the day at 100 % text; floats when larger text needs Today at 600 |
  | Android tablets, landscape | 1280 | Beside the day |
  | iPad mini, landscape | 1133 | Floats |
  | Tablets in portrait, Split View ½ | below 1160 | Floats |
  | Compact windows (Split View ⅓, Slide Over, narrow multi-window) | below 600 | Phone sheet: iPhone detent, Android M3 sheet |

- **For Round 2:** draw the docked and floating editor on iPad and Android, crossing 1160 in both directions, in light and dark, and at 200 % text.
- **Recorded in:** rules (the option D iPad line), the checklist (§4 Q5 and the Task editor row). No board changed.
- **Checklist:** Q1–Q5 are all answered. Round 2 is still not started (owner instruction). Snapshot v2.25-working.

### ED-260 · The nine open verification checks, run (CR-014, CR-042, CR-068, CR-097, CR-098, CR-102, CR-104, CR-106, CR-121)
- **Date:** 2026-11-13. **Owner:** "The 9 checks".
- **Limits:**
  - No Dottoday build was made. Mac builds stay `NV (no Mac build)` (STATUS, owner decision 14).
  - The iOS spike from ED-131 (`g36_tabbar`) is no longer on disk.
  - A "Redesign iPhone" simulator was booted, probably by the CR-160 session, and was left alone.
  - The only things built were a throwaway Flutter web spike in the scratchpad and a Swift script that looks up SF Symbol names. App code, boards and Supabase are untouched.
- **CR-014 · Native icon paths:**
  - The app draws its own chrome glyphs (`DotGlyphs` / `DotIcon`, `app/lib/core/theme/dot_glyphs.dart`), so Flutter chrome needs no native path: Android (ED-133 D5), web, and iPhone and Mac chrome outside the native parts.
  - A native path is needed only in native UIKit/AppKit chrome: the iPhone tab bar, the Day UIMenu and the + hold menu (ED-128), the Mac menus and right-click menus (ED-239), and the status item.
  - Proposed SF Symbols, chosen by me under CLAUDE.md §11 (icon paths). Every name was checked on macOS 26.6.2 (`NSImage(systemSymbolName:)`) and in CoreGlyphs `name_availability.plist`; all exist and were introduced by iOS 16 / macOS 13 at the latest:
    - tab bar: Inbox `tray` / `tray.fill`, Calendar `calendar`, Search `magnifyingglass`. Today and Now (target ring) and Minimal Today (list of dots) keep the app's own glyph, as a template image exported from `DotGlyphs`. No SF Symbol is that glyph; `smallcircle.filled.circle` is the nearest, not used.
    - + hold menu: Brain dump `brain.head.profile`, Routine `repeat`, Paste a list `list.clipboard`.
    - Day menu: Need more time `plus.circle`, Shift the rest `arrow.right.to.line`, Duplicate `plus.square.on.square`, Copy as text `doc.on.doc`, Review the day `checklist`, Low-energy mode `leaf`, Show everything `arrow.up.left.and.arrow.down.right`, Plan / Reality `rectangle.split.2x1`, Replan `arrow.triangle.2.circlepath`, Settings `gearshape`.
    - right-click: Mark Done `checkmark.circle`, Move To… `calendar`, Duplicate `plus.square.on.square`, Move to Trash `trash`, Colour and icon `paintpalette`. Undo `arrow.uturn.backward`. Sync `checkmark.icloud` / `exclamationmark.icloud` / `icloud.slash`.
  - Rejected: `clock.badge.plus` does not exist.
- **CR-042 and CR-097 · Mac Now mini window and status item:**
  - The status item is built (`DayDotStatusItem.swift`): an NSMenu fed by the day snapshot, with actions on `dottoday/status_item` (Done, +15).
  - "Need More Time?" (+5 / +15 / +30) needs +5 and +30 alongside `AddFifteen` (`domain/intents/dot_action.dart`). One parameterised intent keeps the surface rule's intent set small.
  - The mini window (drawn on E-Minimal, ⌥⌘0) cannot be a second Flutter window today: Flutter 3.47.8's multi-window API is experimental, behind the `windowing` flag (`_window_macos.dart`).
  - The feasible path is a native NSPanel (floating, non-activating) with AppKit/SwiftUI content from the same day snapshot and the same channel as the status item. No new dependency. Running it needs a Mac build (NV).
- **CR-068 · Refresh and Back with `?task=` (web):**
  - Spike: Flutter 3.47.8, go_router 18.1.1 (the app's version), hash URLs, Chromium.
  - Without `GoRouter.optionURLReflectsImperativeAPIs`, `context.push('/today?task=t1')` shows the task but leaves the address at `#/today`, so refresh loses it.
  - With the option on, all ten steps pass: push updates the address; refresh keeps the task; Back closes it; Forward reopens it; `/#/task/t9` redirects to `/#/today?task=t9` with no extra Back step; `/#/day/<date>?task=` survives refresh.
  - The app sets neither the option nor any `?task=` handling, and uses `push` in 29 places. So `?task=` must ship with the option on, or open tasks with `go`, plus the D2 guard (ED-097).
- **CR-098 · Native Mac right-click menus:**
  - Flutter has no native macOS context menu: `SystemContextMenu` is iOS text fields only, and `PlatformMenuBar` is the menu bar only (already used, `lib/app_menu.dart`).
  - The feasible path is a method channel that pops an NSMenu (`popUp(positioning:at:in:)`) at the click point and returns the chosen command. It is the same pattern as the status item channel; no new dependency. Running it needs a Mac build (NV).
- **CR-102 · Pointer targets (WCAG 2.2 · 2.5.8):** measured on the live boards with the frames' scale removed.
  - **E-Minimal:** 54 targets under 24 px. 31 are native menu items (platform-sized). 17 pass by spacing. 6 are the three packed early horizon dots (Morning run, Coffee, Standup), which pass by the equivalent-control exception: the same tasks are rows in the Day column, in Earlier.
  - **E-FullA-v2:** 139 under 24. 73 are native menu items; 46 pass by spacing; 20 need another exception:
    - 15-minute week blocks 21 tall packed together: the equivalent is the day view and the inspector;
    - sidebar section headers 18 tall beside week blocks;
    - a few overlaps that are only drawing artefacts (a popover over its own content).
  - **Open:** touch-capable web windows (touch laptops, tablet browsers at wide widths). Proposed: when the primary pointer is coarse (`pointer: coarse`), use the ED-256 touch sizes. This needs the owner's confirmation.
- **CR-104 · Screen-reader labels:** every control on E-Minimal, E-FullA-v2, E-Phones and E-PhonesMinimal was checked for an accessible name (1,626 controls).
  - All have a name or a visible label beside them.
  - 79 rely on that visible text without a programmatic link: step checkboxes, settings and alarm switches, and E-Minimal's Low-energy switch. The build must merge the label into the control (Flutter `MergeSemantics` / labelled list tiles; web `aria-labelledby`).
  - Real VoiceOver, TalkBack and NVDA runs need the built app; they are the R-12 semantics tests and device runs.
- **CR-106 · Contrast on translucent chrome** (light; WCAG relative luminance):
  - **Android frosted toolbar** `rgba(239,231,219,.72)` over the worst solid content: ink icons ≥ 7.43:1 and the selected teal ≥ 3.36:1 (non-text 3:1). **Pass.**
  - **iPhone Liquid Glass,** using the bar averages measured in the Simulator (ED-131): inactive tab label `#6E6E73` 3.23:1 over purple content and 4.35:1 over yellow, below 4.5:1. Selected teal 4.63 / 6.23; ink 10.23 / 13.78. **At risk:** the native bar may apply vibrancy and override a custom unselected colour (ED-154, NOT VERIFIED). Needs a Simulator run with the real tab bar.
  - **Mac sidebar** as drawn on the boards (`rgba(239,231,219,.78)`) over a black desktop: secondary text 2.83:1, teal 3.53, ink 7.81. The approved native recipe (ED-130: sidebar material with a 35 % tint) is less transparent and was measured at ink ≥ 12.1 and teal ≥ 5.5, but secondary text over a dark desktop is unmeasured. Needs a Mac run (NV).
- **CR-121 · + menu order on iOS 26.5:** not run, because the spike is gone. It needs the spike rebuilt in a new throwaway Simulator on the installed 26.5 runtime, or the check moves to when N3 is built.
- **Dispositions changed in `E_CONSISTENCY_REPORT.md`:**
  - Resolved: CR-014.
  - Implementation, with build requirements in `E_IMPLEMENTATION_HANDOFF.md`: CR-042, CR-068, CR-097, CR-098, CR-104.
  - Owner decision: CR-102 (touch-capable web).
  - Still verification: CR-106 (iOS glass, Mac sidebar) and CR-121.

### ED-261 · CR-102 approved: touch-first web windows use the ED-256 touch sizes
- **Date:** 2026-11-13. **Owner:** "Yes, apply ED-256" (question raised by ED-260).
- **Decision:** on web, when the primary pointer is coarse (`(pointer: coarse)`, e.g. a tablet browser, or a touchscreen laptop used by touch), the wide layouts use the ED-256 touch sizes:
  - row title 17, time 13, now row 18, Minimal Now title 26;
  - buttons 16 at 48 tall; Add field 17;
  - every target ≥ 44 px, including the Day-column done check, +5 / +15 / +30 and the toolbar buttons.

  With a fine primary pointer (mouse, trackpad), web keeps the Mac sizes. The Mac app keeps them too. It has no touch, so ED-256's rule never applies there.
- **Detection:** read the *primary* pointer only. A touch laptop with a trackpad as its primary pointer keeps the Mac sizes; `any-pointer` is not used. If the primary pointer changes while the page is open, the page re-reads the query and re-lays out. As with every width or class change, this never saves, discards or commits anything (ED-100, ED-168).
- **Unchanged:** WCAG 2.5.8 is already met at the pointer sizes (ED-260). This decision is about comfort and parity with tablets (ED-256), not a pass/fail fix.
- **Recorded in:** rules §6.4 (rule plus the three E-Minimal pointer rows), handoff (verification-run section), consistency report (CR-102 resolved). No board changed.
- **Snapshot:** v2.27-working.

### ED-262 · iOS 26.5 Simulator run: tab bar contrast on glass (CR-106) and menu order (CR-121)
- **Date:** 2026-11-13. **Owner:** "Yes, run it".
- **Setup:**
  - A throwaway UIKit app (`spike.dottoday.ed262`; not Dottoday; synthetic data; source kept in the snapshot `evidence/`). It has a native `UITabBarController` with Today, Inbox, Calendar and Search; the selected tint is `#11615C` and the unselected tint `#6E6E73`, set through both `unselectedItemTintColor` and `UITabBarAppearance`. A + button (`.prominentGlass`, hold menu, `preferredMenuElementOrder = .fixed`) and a Day button (`.glass`, Day UIMenu in G2-9 groups, fixed order, an other-day state with the Time actions disabled).
  - Compiled with `swiftc` for the Simulator, iOS 16 minimum, Xcode 27.2.
  - Run in a new simulator, "Spike ED-262 (throwaway)" (iPhone 17 Pro, iOS 26.5, installed runtime), deleted afterwards. The "Redesign iPhone" simulator was not used; its viewer panel was closed by the detach call, and the simulator stays booted.
- **CR-106 · Tab bar text on Liquid Glass.** Content was set to each of the nine task colours, the ground, ink and black. Labels were measured from screenshots: background = the most common colour in the label box, text = the 4 % of pixels furthest from it, WCAG luminance.
  - **iOS 26 does not honour the custom unselected colour.** The glass bar draws inactive labels in its own vibrant colour (dark over light content, white over dark content). So ED-154's `#6E6E73` applies only to the F2 bar on iOS 16–25.
  - **Light content (ground and all nine task colours): pass.** Inactive labels 10.08–15.70:1; selected teal 4.98–6.47:1 (lowest over teal-green content).
  - **Dark content under the bar (ink `#241F2B`, black):** the glass turns dark. Inactive labels 13.97–16.30:1. **The selected teal fails, 2.20–2.43:1.**
  - **Fix, verified:** give the accent a dark variant as a trait-resolving colour (light `#11615C`, dark `#5BC4B8`, ED-174). The adaptive glass picks the dark one: selected 5.69–6.44:1 over dark content, and light results unchanged (4.98–5.77).
  - **Also seen:** a glass button with a fixed ink foreground (`#241F2B`) becomes nearly invisible when the glass turns dark. Glass controls must use dynamic label colours, never fixed ink.
- **CR-121 · Menu order on iOS 26.5:**
  - **+ hold menu: pass.** It opens upward in the fixed order Brain dump, Routine, Paste a list.
  - **Day menu (other day): pass.** Fixed order Time → Plan → Day → Layout. Need more time and Shift the rest are shown disabled. The Layout group scrolls inside the menu at this size.
  - **Tap reliability:** the Day menu opened on 3 of 4 ordinary taps. The miss was the first tap after launch, so it is not proven to be the ED-129 quick-tap failure; watch for it on a device.
- **Not covered:** a physical device (owner decision 14: simulators only), Reduce Transparency and Increase Contrast on 26.5, dark mode, and the Mac sidebar (NV, no Mac build).
- **Dispositions:** CR-121 resolved (Simulator); CR-106 moves to implementation (iOS requirement found and its fix verified; Mac measurement at build).

### ED-263 · Correction to ED-262: the + was not in its approved position
- **Date:** 2026-11-13. **Found by the owner:** in the test app the + floated about 60 pt above the tab bar, level with the Day button. The approved iPhone row has the + as a 63 pt circle beside the bar, 21 pt from the right and bottom edges, 6 pt from the bar, centres level; only Day floats, 16 pt above (rules §9.15; ED-124, ED-128 D1). The test-app layout was my shortcut, not iOS behaviour. ED-131's run used the approved position.
- **Effect:**
  - CR-106 (tab bar contrast) is unaffected: it depends on the bar and the content behind it, not on the +.
  - CR-121's + menu was tested from the wrong point. It returns to verification: rerun with the + in its approved position in a throwaway Simulator, or on the owner's iPhone if the owner confirms signing and a decision-14 exception (asked 2026-11-13, not answered).
- **Not changed:** the Day menu result (fixed order, other-day actions disabled) stands, since the Day button was at about its approved height.

### ED-264 · Prompt D Round 2 started
- **Date:** 2026-11-13. **Owner:** "start D Round 2".
- **Scope:** ED-166's order (core journey → interaction and recovery → supporting experiences), the tablet drawing list (`E_TABLET_CHECKLIST.md` §5), and every undrawn screen (CR-069 to CR-090, CR-048, CR-094, CR-127). It applies the tablet answers ED-252, ED-254, ED-256, ED-258 and ED-259, and ED-171's navigation.
- **Working method, unchanged:** one board at a time, drawn from the approved boards' markup; light and dark; renders and fit checks; published to the canvas and checked equal to local; an ED entry and snapshot each time. Every board is proposed for owner review and nothing is approved until the owner says so.
- **Still not authorised:** production code, Supabase, commits, merge and deploy. Concept E stays LEADING CANDIDATE — NOT APPROVED FOR PRODUCTION IMPLEMENTATION until the release gate (ED-238).

### ED-265 · R2-1 proposed: the tablet navigation shell (boards E-R2-1, E-R2-1-Dark)
- **Date:** 2026-11-13. **Owner:** "Yes, R2-1". Round 2 stage 1, first board. Proposed for owner review; nothing approved.
- **What it shows** (iPad Air, Android tablet, foldable; light and dark; 10 frames). Every frame is built from the approved windows (E-G4-3-Narrow Full and Minimal 1160 / 1280), the ED-256 touch transform and E-Phones.
- **Expanded (≥ 840):**
  - iPad: the iPadOS 26 sidebar as a floating glass panel, with the Workspace's own list (Today; Plan with Inbox, Routines, Brain dump; Calendar views; Review; Search) at 44 pt rows. Minimal's sidebar: Now, Inbox, Calendar, Search.
  - Android: an M3 navigation drawer with the same lists, 48 dp items and the teal pill; its menu button collapses it to the rail.
  - Settings and "Synced · 10:42" sit at the sidebar's foot; Settings is never a tab (checklist, ED-238).
- **Medium (600–839):**
  - iPad: the top tab bar with Today · Inbox · Calendar · Search; a sidebar button on the left opens the full list over the content (frame 1c); Day ▾ and + on the right.
  - Android: the M3 rail with menu (opens the drawer), the + as the rail's FAB, the four places and Settings at the bottom; Day is a frosted button at the top right.
  - Full medium content is the Today thread at the touch scale (Earlier fold, icons in the dots, 45 now ring, 44 pt done targets).
  - Minimal medium portrait stacks Now above the Day list; the Day menu stays in the Day header (E-Minimal), and the Day column's hide controls are dropped (nothing to hide).
- **Compact:** iPad Split View ½ in landscape (590 wide) uses the phone layout exactly, with the iPhone tab bar at the bottom (ED-104, ED-171).
- **Foldable:** unfolded 700 × 840 is medium and uses the rail. Flat, the content spans the fold; half-open tabletop is H1 compact (ED-168); folded, it is the phone.
- **Touch clean-up in every tablet frame:** keyboard hints (kbd), the Mac pointer and the Mac right-click menu are removed. Hardware-keyboard overlays and long-press are later stage-1 and stage-2 boards.
- **Known limits, said on the board:** the Workspace content in 1a and 3a is still at Mac sizes; its touch version is R2-2. The Full frames' drag illustration still shows a pointer.
- **Question R2-1a (owner):** medium Minimal on tablets uses E-Minimal's places (Now · Inbox · Calendar · Search), by width as in Q2 (ED-254). The checklist had listed the phones' set (Now · Today · Inbox). Recommended: by width.
- **Board:** E-R2-1 and E-R2-1-Dark at canvas y 168380. Published version `1794574289-853b`; all three files equal local. Snapshot v2.30-working.

### ED-266 · R2-1a approved: medium Minimal on tablets uses E-Minimal's places, by width
- **Date:** 2026-11-13. **Owner:** "By width (recommended)".
- **Decision:** in Minimal, medium tablet windows (600–839; iPad top tabs, Android rail) offer Now · Inbox · Calendar · Search, E-Minimal's places, the same as wide Minimal on Mac and web. This follows Q2 (ED-254) and DESIGN_PRINCIPLES §2: width decides. Compact windows keep the phones' Now · Today · Inbox. Expanded windows use the sidebar with the same four places.
- **Applied:** E-R2-1 and E-R2-1-Dark (row 2 tag and note, canvas title). Published version `1794574600-2173`; all three files equal local. Snapshot v2.31-working.
- **Checklist:** the navigation-shell row in `E_TABLET_CHECKLIST.md` §3.1 now records Minimal by width.
- **Still open on R2-1:** the board as a whole is proposed, not approved.

### ED-267 · R2-1 approved: the tablet navigation shell
- **Date:** 2026-11-13. **Owner:** "Approve, start R2-2".
- **Approved:** E-R2-1 and E-R2-1-Dark as drawn (ED-265, with R2-1a by width, ED-266):
  - iPad: the sidebar at expanded and the top tabs at medium;
  - Android: the drawer at expanded and the rail at medium;
  - Settings at the sidebar foot, never a tab;
  - the phone layout in compact windows;
  - the foldable as medium, H1 when half-open.
- **Board labels:** "Approved · ED-267"; canvas titles updated. Published version `1794575092-8408`.

### ED-268 · R2-2 proposed: Today on expanded tablets, the Workspace at touch sizes (boards E-R2-2, E-R2-2-Dark)
- **Date:** 2026-11-13. Round 2 stage 1, second board. Proposed for owner review.
- **What it shows:** Full on an iPad Air (1180 × 820) and an Android tablet (1280 × 800), landscape, inside the approved R2-1 navigation. It is the Workspace (ED-252) with the ED-256 content scale. Same parts in the same places as E-FullA-v2: sidebar, Plan panel (Capture, Inbox, Routines, Brain dump), toolbar (Plan panel, ‹ ›, Today, date, Day · 3 days · Week · Month, Day ▾, +), the grid with a thread per day, the now line and the Deep work / Call with Sam overlap. Sample data and copy come from E-FullA-v2 / E-G4-3-Narrow.
- **Rules applied:**
  - **Week shows the days that fit,** as on Mac (the 1160 window shows Mon–Thu). Minimum column 180 at touch sizes: iPad 1180 shows 3 days (Tue–Thu, scrolled to today), Android 1280 shows 4 (Mon–Thu).
  - The Plan panel stays while 3 or more days fit (ED-184).
  - **The inspector floats:** three days, the Plan panel and the inspector do not fit together at touch sizes, so a tap opens the inspector over the grid (ED-167, ED-170). Shown open on R2-4.
- **New values, flagged for review** (no approved touch grid existed):
  - 96 px per hour;
  - card title 17, time 13; current-task ring 45 with "Now, 18 min left"; other dots 36 with icons;
  - blocks under 35 minutes are one-line pills (title 15, dot 28 or 24); a 30-minute pill is 44 tall, and a 15-minute pill's tap area reaches 44 pt by spacing (WCAG 2.5.8);
  - Plan-panel rows 56; controls 44 pt / 48 dp.
- **Removed on touch:** the Mac drag-from-Inbox illustration and the right-click menu. Touch long-press and drag come in stage 2.
- **Overlap:** Call with Sam sits over the last half-hour of Deep work at the right, lifted, as the overlap knot implies; Deep work keeps the full column.
- **Known:** in Android's four narrower columns the "Call with Sam" pill ends in an ellipsis, as the approved Workspace pills do.
- **Board:** canvas y 171420. Published version `1794575092-8408`; all five files equal local. Snapshot v2.32-working.

### ED-269 · R2-2 approved: the Workspace at touch sizes on expanded tablets
- **Date:** 2026-11-13. **Owner:** "Approve, start R2-3".
- **Approved:** E-R2-2 and E-R2-2-Dark as drawn (ED-268), including the new touch-grid values:
  - 96 px per hour and a minimum column of 180;
  - block title 17, and one-line pills under 35 minutes (title 15);
  - dots 36 / 45 / 28 / 24;
  - Plan-panel rows 56;
  - Week shows the days that fit; the inspector floats.
- **Board labels:** "Approved · ED-269". Published version `1794575546-0267`.

### ED-270 · R2-3 proposed: Add on expanded tablets (boards E-R2-3, E-R2-3-Dark)
- **Date:** 2026-11-13. Round 2 stage 1, "Add" step (ED-166). Proposed for owner review.
- **Principle:** one Add everywhere. The approved phone screens are reused unchanged inside tablet containers, since phone sizes are the touch scale (ED-256): Create task (ED-140 iPhone; ED-141, ED-142 Android) and the one ProposalSheet (ED-150). No second Add or proposal design (CLAUDE.md §11).
- **iPad:**
  - (1a) Tap + opens Create task as a popover from the toolbar + (Task · Brain dump · Routine tabs, title and parser hint, When card). The Workspace stays live behind it.
  - (1b) Hold + shows the native menu Brain dump · Routine · Paste a list (G2-8).
  - (1c) Plan it shows the ProposalSheet as a panel beside the day. The grid narrows to the days that fit (Tue, Wed), the Plan panel steps aside (ED-184), the range tabs become a "Week ⌄" pop-up (ED-183), and proposed tasks show as dashed "new" blocks where they would land (Email Sam 12:00, Taxes 1:15).
- **Android:**
  - (2a) The + opens the M3 menu Task · Brain dump · Routine, as the phone FAB menu does.
  - (2b) Task opens New task in an M3 modal side sheet (412 dp) over a scrim.
  - (2c) Plan it shows the ProposalSheet in an M3 standard side sheet beside the grid, with the same narrowing and dashed proposed blocks.
- **Proposal rule:** nothing is written before Add to day; Discard leaves everything unchanged. A test proving nothing is written before Accept is part of done.
- **Removed from the reused screens:** the iPhone sheet grabber (popovers and panels have none) and the phone keyboard in the Android sheet (a tablet keyboard spans the screen; drawn with the keyboard states later).
- **Not drawn again:** medium windows use the same popover from the top-bar + and the same sheets from the rail's FAB; compact windows keep the phone screens. Dictation and the Paste a list preview are not covered.
- **Board:** canvas y 173320. Published version `1794575546-0267`; all five files equal local. Snapshot v2.33-working.

### ED-271 · R2-3 approved: Add on expanded tablets
- **Date:** 2026-11-13. **Owner:** "Approve, start R2-4".
- **Approved:** E-R2-3 and E-R2-3-Dark as drawn (ED-270). iPad: the popover from +, the hold menu, and the proposal panel beside the day. Android: the + menu, the modal side sheet for New task, and the standard side sheet for the proposal. All reuse the approved phone screens.
- **Board labels:** "Approved · ED-271". Published version `1794575799-a0be`.

### ED-272 · R2-4 proposed: Edit on tablets; question R2-4a (boards E-R2-4, E-R2-4-Dark)
- **Date:** 2026-11-13. Round 2 stage 1, "Edit" step. Proposed for owner review.
- **Question R2-4a, found while drawing.** On expanded tablets, the Workspace (Q1, ED-252) meets two approved task surfaces: the Mac Workspace inspector (248, ED-170) and the iPad option D editor (420, ED-086; docking per Q5 / ED-259).
  - **A · Inspector, floating:** it cannot dock beside three days at touch sizes. Drawn at ×1.3 for comparison only. It conflicts with ED-086's iPad line, and Android has no approved inspector.
  - **B · Option D editor, docked (recommended):** the approved full editor docks at the right, 420 wide, because the window allows it (ED-168 minimums). The grid narrows to the days that fit and the Plan panel steps aside (ED-184). On Android, the approved Edit task sits in an M3 standard side sheet. It is the same editor as the phones: one task surface, nothing new to design.
- **Both options, medium windows:** the same editor floats. On iPad it floats over the Today list with a slight dim; on Android it opens in an M3 modal side sheet. Changing width never saves, discards or resets the editor (ED-168). Compact windows keep the phone sheets.
- **Sources:** the iPhone full editor (E-Phones, "Full editor (pulled up from F3)") and Android Edit task (E-Phones), reused; the sheet grabber and phone keyboard are removed. The Mac inspector comes from E-G4-3-Narrow.
- **Board:** canvas y 175260. Published version `1794575799-a0be`; all five files equal local. Snapshot v2.34-working.

### ED-273 · R2-4a approved: B, the option D editor docked beside the grid on expanded tablets
- **Date:** 2026-11-13. **Owner:** "B · editor docked".
- **Decision:** on expanded tablets, tapping a task in the Workspace opens the approved full editor (option D, ED-086), not the Mac inspector.
  - It docks at the right, 420 wide, where the ED-168 minimums fit (≥ 1160; sidebar 216, grid ≥ 480, editor 420). The grid narrows to the days that fit (minimum column 180, ED-269), and the Plan panel steps aside below 3 days (ED-184).
  - Otherwise it floats: on iPad over the content, on Android in an M3 modal side sheet. Compact windows keep the phone sheets.
  - On Android it is the approved Edit task, in an M3 standard side sheet when docked.
- **Effect on other surfaces:** the Workspace inspector (ED-170) stays a Mac and web surface. Tablets have one task surface, the same editor as the phones (CLAUDE.md §11, "never fork a second" surface).
- **Applied:** E-R2-4 and E-R2-4-Dark (B marked chosen, A kept as history, question marked decided). Published version `1794576132-c2e6`; all three files equal local. Snapshot v2.35-working.
- **Checklist:** the Task editor row in `E_TABLET_CHECKLIST.md` §3.1 records it.
- **Still open on R2-4:** the board as a whole is proposed, not approved.

### ED-274 · R2-4 approved: Edit on tablets
- **Date:** 2026-11-13. **Owner:** "Approve, start R2-5".
- **Approved:** E-R2-4 and E-R2-4-Dark as drawn, with R2-4a = B (ED-273):
  - expanded: the option D editor docked beside the grid, and Android's Edit task in a standard side sheet;
  - medium: the same editor floating (iPad) or in a modal side sheet (Android).
- **Board labels:** "Approved · ED-274". Published version `1794576442-5dea`.

### ED-275 · R2-5 proposed: complete, change day, reopen and the Day menu on expanded tablets (boards E-R2-5, E-R2-5-Dark)
- **Date:** 2026-11-13. The last board of Round 2 stage 1 (core journey, ED-166). Proposed for owner review.
- **Journey:** Today (R2-2) → Add (R2-3) → Edit (R2-4) → Complete → Change day → Reopen, on the same sample day, inside the approved navigation (R2-1).
- **Steps:**
  - **Complete:** the done check on the block, or Done in the docked editor. The dot fills in its colour, the title greys, the thread turns solid, and Call with Sam becomes the current task. Autosave as built; the Undo toast is stage 2.
  - **Change day:** Move opens the one When picker (ED-099). iPad: a popover from the block (the grid scrolled to the afternoon, Pick up parcel). Android: an M3 modal side sheet (the approved "Schedule Go for a run" sample; Move uses the same sheet).
  - **Reopen:** tapping a done task's dot reopens it, as on the phones ("Morning run, done. Reopen"). Before and after are shown at 100 %.
  - **Day menu, Full:** Time · Plan · Day · Layout (ED-093) as the iPadOS glass pull-down and the M3 menu from the toolbar Day button. Minimal tablets use E-Minimal's menu (ED-254, E-T2).
- **Reused:** E-Phones-2's When picker and the Full Day menus (iPhone, Android), and the phone thread's done and reopen states.
- **Dark:** the M3 menu surface uses #37313A, as on E-Phones-2-Dark (the converter lacked #F7EFF4).
- **Board:** canvas y 177600. Published version `1794576442-5dea`; all five files equal local. Snapshot v2.36-working.
- **Stage 1:** R2-1 to R2-4 approved; R2-5 proposed. Stage 2 is next: multi-select and the selection bar, Undo, sync states, Focus, keyboard overlays.

### ED-276 · R2-5 approved; Round 2 stage 1 (core journey) complete
- **Date:** 2026-11-13. **Owner:** "Approve, start stage 2".
- **Approved:** E-R2-5 and E-R2-5-Dark as drawn (ED-275): complete, change day (When picker), reopen, and the Full Day menu on expanded tablets.
- **Stage 1 approved:** R2-1 navigation shell (ED-267), R2-2 touch Workspace (ED-269), R2-3 Add (ED-271), R2-4 Edit (ED-274, with R2-4a = B, ED-273), R2-5 (this entry).
- **Board labels:** "Approved · ED-276". Published version `1794576765-dee4`.

### ED-277 · R2-6 proposed: multi-select and the selection bar on every platform; question R2-6a (boards E-R2-6, E-R2-6-Dark)
- **Date:** 2026-11-13. Round 2 stage 2, first board. Proposed for owner review.
- **Why every platform:** multi-select is built in the app (`features/timeline/widgets/selection_bar.dart`, `shared/selection/selection_bar_frame.dart`, `shared/dot/thread_select.dart`) but drawn on no E board (CR-078). The board covers iPhone, Android phone, iPad and Android tablet; Mac and web follow the tablet frames with the pointer.
- **Shared, from the built behaviour (docs/03 §3.2, R-05):**
  - Hold a dot (iOS) or long-press (Android) to start; tap rows to add or remove.
  - Each row ends in a ring, empty or filled with a check, so state never relies on colour alone. Picked rows get a light teal tint; picked grid blocks get the teal outline and a check badge.
  - ⇧ / ⌘ / Ctrl-click adds a task; ↑↓ and Space pick rows; Esc ends selecting. The count is a live region.
  - Copy is the built strings only: "3 selected", "Done selecting", Move, Duplicate, Colour, Save as routine, Delete; "Delete 3 tasks?".
  - A Full ↔ Minimal switch clears the selection without applying anything (ED-100).
- **Question R2-6a:**
  - **A · The built card in E, everywhere (recommended):** the SelectionBarFrame card ("3 selected" ✕, then five actions with the icon over the label). It floats above the bottom row on phones and is centred under the grid on tablets. Tabs, + and Day stay.
  - **B · Platform-native:**
    - iPhone: a bottom edit toolbar replaces the tab bar, + and Day; "3 selected" and ✕ float at the top.
    - Android: the M3 contextual top bar (✕, "3 selected", Move, Duplicate, Colour, ⋮ for Save as routine and Delete).
    - Tablets: the toolbar above the grid becomes the selection toolbar.
- **Sample:** phones select Team standup, Deep work: roadmap and Call with Sam; tablets select the Tuesday and Wednesday Lunch and Dentist.
- **Board:** canvas y 179280. Published version `1794576765-dee4`; all five files equal local. Snapshot v2.37-working.

### ED-278 · R2-6a approved: A, the built selection card in E on every platform
- **Date:** 2026-11-13. **Owner:** "A · built card".
- **Decision:** multi-select on every platform uses the app's built SelectionBarFrame, restyled in E: "3 selected" with ✕ (Done selecting), then Move · Duplicate · Colour · Save as routine · Delete, icon over label, on E's surface.
  - Phones: it floats above the bottom row; the tabs, + and Day stay.
  - Tablets, Mac and web: it is centred under the grid.
  - The built selection behaviour, copy and accessibility apply unchanged (ED-277).
- **Not chosen:** B (iOS edit toolbar, M3 contextual bar). Kept on the board as history.
- **Applied:** E-R2-6 and E-R2-6-Dark (A marked chosen, B as history). Published version `1794576978-68cc`; all three files equal local. Snapshot v2.38-working.
- **Implementation:** only the card's look changes (E surface, radius, shadow, icons); the built widget, actions and strings stay. CR-078 is designed; its build check remains.
- **Still open on R2-6:** the board as a whole is proposed, not approved.

### ED-279 · R2-6 approved: multi-select and the selection bar on every platform
- **Date:** 2026-11-13. **Owner:** "Approve, start R2-7".
- **Approved:** E-R2-6 and E-R2-6-Dark as drawn, with R2-6a = A (ED-278): the built selection card in E, plus the selecting behaviour, copy and accessibility in ED-277. CR-078 is designed; its build check remains.
- **Board labels:** "Approved · ED-279". Published version `1794577469-2a69`.

### ED-280 · R2-7 proposed: Undo, the toast and ⌘Z / Ctrl+Z on every platform (boards E-R2-7, E-R2-7-Dark)
- **Date:** 2026-11-13. Round 2 stage 2, second board. Proposed for owner review.
- **Why every platform:** Undo is built (`shared/feedback/undo_snackbar.dart`, `app_menu.dart`) but no E board draws it, apart from the sync-conflict case (CR-079).
- **One confirmation:** the bottom confirmation approved for the conflict Undo (E-G4-7-States C3, ED-194) becomes the Undo toast for every move, delete, done and shift. It has an ink surface, cream text and a light-teal Undo; in dark, a cream surface with a dark-teal Undo, as approved. No second design.
- **Placement:**
  - iPhone: above the tab bar, radius 16.
  - Android phone: the M3 snackbar shape (radius 8) above the floating toolbar.
  - iPad: centred under the grid, 400 wide.
  - Android tablet: an M3 snackbar at the start of the grid, 440 wide.
  - Mac and web: as tablets. The conflict Undo keeps its place in the Sync popover (C5).
- **Built behaviour kept:**
  - a 30-second window (`UndoService.window`, R-11);
  - a new change replaces the toast;
  - ⌘Z / Ctrl+Z undoes and ⇧⌘Z / Ctrl+Shift+Z redoes, outside text fields;
  - Mac Edit › Undo / Redo.
- **Kit rules applied (ED-194), to check in the build:** the window pauses while the toast is focused or hovered; Escape, swipe or the screen reader's dismiss gesture closes it; with VoiceOver or TalkBack on it stays until dismissed and gains Close; no visible countdown; Reduced Motion honoured.
- **States at 100 %:** standard; screen reader on (with Close); long text wraps (`snackMovedShifted`); too late (`failureUndoExpired`, Close only); 200 % text.
- **Copy:** built strings only ("Marked done", "{title} moved to {day}", "3 tasks moved to Trash", "Undo"). Nothing says late or missed.
- **Board:** canvas y 181080. Published version `1794577469-2a69`; all five files equal local. Snapshot v2.39-working.

### ED-281 · R2-7 approved: the Undo toast and ⌘Z / Ctrl+Z on every platform
- **Date:** 2026-11-13. **Owner:** "Approve, start R2-8".
- **Approved:** E-R2-7 and E-R2-7-Dark as drawn (ED-280). The approved conflict confirmation (ED-194) is the one Undo toast, placed per platform; the built 30 s window and shortcuts are kept, and the kit's accessibility rules apply. CR-079 is designed; its build check remains (pause on focus or hover, stay with a screen reader on).
- **Board labels:** "Approved · ED-281". Published version `1794577951-7331`.

### ED-282 · R2-8 proposed: sync states and conflicts on tablets (boards E-R2-8, E-R2-8-Dark)
- **Date:** 2026-11-13. Round 2 stage 2, third board. Proposed for owner review.
- **Scope:** the approved kit (E-G4-7-States, ED-186 to ED-196) said "tablets inherit every state; presentations in Round 2". This board places those states. The vocabulary, wording, announcements and data-safety rules are unchanged.
- **Expanded = the Mac pattern (B5):** the sidebar or drawer foot carries the state as a 44-tall button with an icon and words (e.g. "Offline · 3 waiting", "1 change needs you"), replacing "Synced · 10:42" while a state is active. No banner, since the line is always in view.
  - iPad: tapping the line opens the approved Sync sheet content (B4) or the conflict review (C1/C2) in a popover from the line.
  - Android: Sync opens in an M3 standard side sheet. The conflict review opens in a modal side sheet, because a choice is needed; Back closes without choosing, and nothing is lost.
  - Resolved shows the R2-7 toast with Undo.
- **Medium (and compact) = the phone pattern (B2/B3):** the offline banner under the top bar, and a sync button with the "3" badge (iPad: beside Day; Android: in the rail above Settings) that opens the same detail.
- **Reused:** the Sync sheet, conflict review, offline banner, badge and icons from E-G4-7-States, at phone size (the touch scale, ED-256).
- **Board:** canvas y 182560. Published version `1794577951-7331`; all five files equal local. Snapshot v2.40-working.

### ED-283 · R2-8 approved: sync states and conflicts on tablets
- **Date:** 2026-11-13. **Owner:** "Approve, start R2-9".
- **Approved:** E-R2-8 and E-R2-8-Dark as drawn (ED-282). Expanded tablets use the Mac sidebar-line pattern, with the detail in a popover (iPad) or side sheets (Android). Medium tablets use the phone banner and badged sync button. The kit's rules are unchanged.
- **Board labels:** "Approved · ED-283". Published version `1794578593-3bc4`.

### ED-284 · R2-9 proposed: Focus on every platform; question R2-9a (boards E-R2-9, E-R2-9-Dark)
- **Date:** 2026-11-13. Round 2 stage 2, fourth board. Proposed for owner review.
- **Why every platform:** the Focus screen is built (`features/focus/`: `FocusScreen` full screen on phones and narrow windows, `FocusFrame` in the content area at expanded) but drawn on no E board (CR-076).
- **Drawn from the built screen:**
  - top bar: ‹ Today · FOCUS · ⋯ (Task details);
  - the current-task ring at Focus size with the task's icon;
  - time and length, title, "18 min left";
  - step card ("Step 3 of 4", step title, "8:00 left · usually 20 min");
  - the step thread;
  - toggles "Chime every 15 min" and "Deep work · Focus on";
  - Done, "+15 min", "Next step";
  - the break-through note.
  - Copy is built strings only. Entry points stay as approved. Apple Pencil: nothing proposed.
- **Question R2-9a (expanded windows):**
  - **A · content area, sidebar stays (recommended):** as built (`FocusFrame`). One centred readable column; the sidebar or drawer stays; tabs keep their state; Esc or ‹ Today returns. Medium windows use the phone screen.
  - **B · whole window:** the sidebar hides; ring and title on the left, step and actions on the right. More immersive, but a second Focus layout.
- **Accessibility:**
  - Built: the toggles stack above 130 % text; Esc leaves; the title is a heading; no sound unless Chime is on.
  - To check in the build: one spoken label for the ring; Reduced Motion stops its animation.
- **Board:** canvas y 184240. Published version `1794578593-3bc4`; all five files equal local. Snapshot v2.41-working.

### ED-285 · R2-9a approved: B, Focus takes the whole window on expanded windows
- **Date:** 2026-11-13. **Owner:** "B · whole window" (against the recommended A).
- **Decision:** on expanded windows (tablets, Mac, web), Focus takes the whole window. The sidebar or drawer hides; the ring, time, title and "18 min left" sit on the left; the step card, step thread, toggles, Done, "+15 min", "Next step" and the note sit on the right. Leaving with ‹ Today or Esc returns to the place and state you came from. Phones, compact and medium windows keep the full-screen phone layout.
- **Implementation consequence (not built):** this replaces the built `FocusFrame` (content area with the rail kept, `features/focus/focus_screen.dart`) with a two-column whole-window layout at the expanded width class. The tabs underneath must still keep their state while Focus is up; the parts (`FocusView` pieces) are reused, not forked. Per the owner's rule, replace the old layout; don't keep both.
- **Not chosen:** A, kept on the board as history.
- **Applied:** E-R2-9 and E-R2-9-Dark (B marked chosen, A as history, question decided). Published version `1794578818-83ca`; all three files equal local. Snapshot v2.42-working.
- **Still open on R2-9:** the board as a whole is proposed, not approved.

### ED-286 · R2-9 approved: Focus on every platform
- **Date:** 2026-11-13. **Owner:** "Approve, start R2-10".
- **Approved:** E-R2-9 and E-R2-9-Dark as drawn (ED-284), with R2-9a = B (ED-285): full screen on phones, compact and medium windows; the whole window on expanded windows. CR-076 is designed; its build (replacing `FocusFrame`) and the two accessibility checks remain.
- **Board labels:** "Approved · ED-286". Published version `1794579023-4f40`.

### ED-287 · R2-10 proposed: keyboard overlays on tablets (boards E-R2-10, E-R2-10-Dark)
- **Date:** 2026-11-13. Round 2 stage 2, last board (checklist §3.2 row "Keyboard scheme": draw the overlays' contents).
- **Two lists:**
  - **System:** iPad shows the system menu bar while ⌘ is held (iPadOS 26), with the Mac app's built menus (`app_menu.dart`: Dottoday, File, Edit, View, Go, Window; View holds ⌘1–4 and Keyboard Shortcuts ⌘/). Android shows its Keyboard Shortcuts Helper on Meta+/, with Dottoday in "Current app". Both are drawn as the system shows them, not restyled.
  - **App:** the built Keyboard shortcuts sheet (⌘/ or Ctrl+/, M3e.6) in E, with the five built groups (Everywhere, Today, Week and Month, Inbox, Editing a task) in two columns. It is a form sheet on iPad and an M3 dialog on Android, and stays the one complete list everywhere.
- **Keys and labels:** the built ones only (`app_shortcut_groups.dart`; ED-095 scheme, ⌘ on Apple, Ctrl elsewhere). Touch frames still show no key hints.
- **Corrected while drawing:** the first draft's iPad menu bar had a Help menu and Go-menu items that the built menu doesn't have. The board now matches `app_menu.dart`.
- **Open (implementation, ED-095):** the iPad key commands and menu bar, and Android's shortcut registration, need native work and device verification. The board marks both "verify on device".
- **Board:** canvas y 186480. Published version `1794579023-4f40`; all five files equal local. Snapshot v2.43-working.

### ED-288 · R2-10 approved; Round 2 stage 2 (interaction and recovery) complete
- **Date:** 2026-11-13. **Owner:** "Approve, start stage 3".
- **Approved:** E-R2-10 and E-R2-10-Dark as drawn (ED-287): the system lists (iPadOS menu bar on ⌘-hold, Android Shortcuts Helper) plus the built shortcuts sheet. Native registration and device checks remain (ED-095).
- **Stage 2 approved:**
  - R2-6 multi-select (ED-279, card A, ED-278);
  - R2-7 Undo (ED-281);
  - R2-8 sync states (ED-283);
  - R2-9 Focus (ED-286, whole window B, ED-285);
  - R2-10 keyboard overlays (this entry).
- **Board labels:** "Approved · ED-288". Published version `1794579293-ecb2`.

### ED-289 · R2-11 proposed: Settings on tablets (boards E-R2-11, E-R2-11-Dark)
- **Date:** 2026-11-13. Round 2 stage 3 (supporting experiences), first board. Proposed for owner review.
- **Rule:** the register's G2-4 "two-pane Settings" line, drawn.
  - Expanded tablets: Settings at the sidebar or drawer foot (selected there) opens two panes. The approved root (account, Synced, search, six groups) is on the left; the chosen group fills the right. On Android this is the M3 list-detail layout.
  - Medium and compact: the approved phone screens, pushed one at a time. Mac keeps its Settings window (ED-081).
- **Drawn:**
  - iPad: Settings › Your day; Settings › Appearance.
  - Android: Settings › Your day › Wake Up and Wind Down; Settings › Appearance.
  - All pages are the approved ones from E-Phones (ED-084) and E-Phones-3 (ED-161), at phone sizes (the touch scale), widened to their pane.
  - The open group is tinted in the list. In two panes the group page drops its ‹ Settings / ← control; it returns in the stacked layout.
- **Dark board:** shows Dark as the chosen theme in Appearance; each preview tile keeps its own theme's colours.
- **Not drawn again:** Planning, Reminders, Data and privacy, and Help and about follow the same two-pane rule.
- **Board:** canvas y 188280. Published version `1794579293-ecb2`; all five files equal local. Snapshot v2.44-working.

### ED-290 · Auto theme tile shows white and dark in every dark board (owner comment)
- **Date:** 2026-11-13. **Owner (comment on E-R2-11-Dark):** "This should be White and dark in all darkmodes".
- **Cause:** the dark converter mapped the Auto tile's light half (#FBF7F1) to the dark ground, so in dark boards Auto looked dark on dark.
- **Fixed:**
  - E-R2-11-Dark: 2 Auto tiles; the generator now protects both halves.
  - E-Phones-3-Dark: 8 Auto tiles. The 8 Light tiles there had the same fault and now keep their light colours too.
  - Rule: a theme preview always shows its own theme's colours in light and dark.
- **Checked:** every dark board on the canvas. No other Auto tiles were affected (E-G3-9b-Screens already shows white and dark).
- **Left as approved:** E-Phones-3-Dark still marks Light as the chosen theme. E-R2-11-Dark marks Dark. This is raised with the owner in the thread.
- **Published:** version `1794579566-73c6`; both files equal local. Snapshot v2.45-working.

### ED-291 · R2-11 approved: Settings on tablets
- **Date:** 2026-11-13. **Owner:** "Approve R2-11 and move on to R2-12". (The owner first wrote "Approve, start R2-7". R2-7 was already approved, so I asked, and the owner confirmed R2-11.)
- **Approved:** E-R2-11 and E-R2-11-Dark as drawn (ED-289), with the Auto and Light tile fix (ED-290): two panes at expanded, the phone stack below.
- **Board labels:** "Approved · ED-291". Published version `1794579863-d13f`.

### ED-292 · R2-12 proposed: Calendar on tablets, Month and Week (boards E-R2-12, E-R2-12-Dark)
- **Date:** 2026-11-13. Round 2 stage 3, second board. Proposed for owner review.
- **One month grid everywhere (ED-075):** the approved phone Calendar screens (E-Phones, iPhone and Android) are reused at phone sizes (the touch scale), widened to their pane. They keep the same dots, +n counts, today ring, and the day panel with Open day. No second month design.
- **Expanded Full = the Workspace:** Month is one of its Calendar views (Day · 3 days · Week · Month), reached from the sidebar (Calendar views › Month, selected) or the toolbar (Month tab). The month grid fills the grid area beside the Plan panel. Week is R2-2.
- **Medium:** the Calendar tab (iPad top tabs) or rail destination (Android) opens Month, with a Month · Week switch at the top (Q5 "Week wherever the width allows"; ED-075's month-component note). Week there is the Workspace week at the narrower width (R2-2 rules); the day panel scrolls.
- **Compact:** the phone Calendar tab, Month only.
- **Minimal on tablets:** E-Minimal's Calendar place (by width, ED-266), not redrawn.
- **Interaction:** swipe or ‹ › changes month; each day is a button with a spoken summary (ED-075). Drag between days on Week stays pointer-only (ED-116); touch long-press drag is not drawn.
- **Board:** canvas y 190060. Published version `1794579863-d13f`; all five files equal local. Snapshot v2.46-working.

### ED-293 · R2-12 approved: Calendar on tablets
- **Date:** 2026-11-13. **Owner:** "Approve, start R2-13".
- **Approved:** E-R2-12 and E-R2-12-Dark as drawn (ED-292): Workspace Month at expanded; the Calendar tab or rail destination with Month · Week at medium; the phone Calendar tab when compact.
- **Board labels:** "Approved · ED-293". Published version `1794580158-8b6e`.

### ED-294 · R2-13 proposed: Inbox and Search on every platform (boards E-R2-13, E-R2-13-Dark)
- **Date:** 2026-11-13. Round 2 stage 3, third board. Proposed for owner review.
- **Why every platform:** Inbox and Search are built (`features/inbox`, `features/search`) and have tabs and sidebar rows, but no E board drew the screens (CR-080). This board draws them in E for iPhone, Android phone, iPad and Android tablet.
- **Inbox (built content and copy):**
  - "3 unscheduled · 1 h 20 of work"; the add field with the parser hint; All · Fits today; "Sort: added"; "Next free slot today: …";
  - rows with length, when added, where they fit ("Fits today 11:00"), and Place;
  - "Completed · 2"; "Auto-plan the week" (a proposal, ED-150).
  - Expanded iPad: the Inbox list beside "Drop onto today" (the built WideInbox, M3e.2). Today's thread names the first task that fits each dotted free gap, with the built drop hint. Medium windows show the list alone.
- **Search (built content and copy):**
  - "Search titles, notes and subtasks"; "Everything you've planned"; All · Today · This week · Inbox · Done · Colour · Icon;
  - results grouped by day ("Tue · Today"), Inbox and earlier, with the match highlighted; "Show all"; Recent and the empty-state line.
  - Expanded Android tablet: one readable column (640) in the content area. A result opens the task in the docked editor (R2-4).
- **Bars:** the approved iPhone tab bar and Android floating toolbar, with the selected look moved to Inbox or Search. Tablets use R2-1 navigation.
- **Sample data:** "Send Sam the notes" and "Lunch with Sam" are sample titles so that every result contains the query. Deep work: roadmap matches through its notes.
- **Board:** canvas y 191860. Published version `1794580158-8b6e`; all five files equal local. Snapshot v2.47-working.

### ED-295 · R2-13 approved: Inbox and Search on every platform
- **Date:** 2026-11-13. **Owner:** "Approve, start R2-14".
- **Approved:** E-R2-13 and E-R2-13-Dark as drawn (ED-294). CR-080 is now designed for Inbox and Search (Calendar was ED-079 and R2-12); its build check remains.
- **Board labels:** "Approved · ED-295". Published version `1794580352-68b3`.

### ED-296 · R2-14 proposed: Day review and Week in review on tablets (boards E-R2-14, E-R2-14-Dark)
- **Date:** 2026-11-13. Round 2 stage 3, fourth board. Proposed for owner review.
- **Rule (checklist row, ED-099):** iPad landscape and Android expanded show the review as a pane beside the day. Narrow iPad Split View, medium and compact windows use the phone sheet.
- **Drawn:**
  - iPad: Day review as a 420-wide pane at the right, then Week in review pushed in the same pane (Back returns, as on the phone).
  - Android expanded: Day review in an M3 standard side sheet.
  - Android medium: the approved M3 sheet, centred at 640 wide as large-screen bottom sheets are.
- **Reused:** the approved iPhone and Android Day review bodies and the Week in review page from E-Phones-2, at phone sizes. The copy is unchanged ("3 of 9 done", "Move the rest to tomorrow?", "Move 5 to tomorrow", the sleep line, "No streaks here — just what happened."). Nothing moves until Move 5 to tomorrow, which then shows Undo (R2-7).
- **The pane behaves like the docked editor (R2-4):** the grid narrows to the days that fit, the Plan panel steps aside (ED-184), and opening a task from the pane swaps it to the editor.
- **Board:** canvas y 193800. Published version `1794580352-68b3`; all five files equal local. Snapshot v2.48-working.

### ED-297 · R2-14 approved: Day review and Week in review on tablets
- **Date:** 2026-11-13. **Owner:** "Approve, start R2-15".
- **Approved:** E-R2-14 and E-R2-14-Dark as drawn (ED-296): a pane beside the day at expanded; the phone sheet at medium and compact.
- **Board labels:** "Approved · ED-297". Published version `1794580655-ae0a`.

### ED-298 · R2-15 proposed: colour and icon picker on tablets (boards E-R2-15, E-R2-15-Dark)
- **Date:** 2026-11-13. Round 2 stage 3, fifth board. Proposed for owner review.
- **Rule (checklist row):** "popover (as Mac and web) or the phone half sheet by width".
  - Expanded iPad: a popover from the task dot in the docked editor, with its arrow on the dot.
  - Expanded Android: a centred M3 dialog over the Edit task side sheet (Android has no popover).
  - Medium and compact: the approved phone half sheets.
- **Drawn:** Colour and icon, then ⋯ › All colours pushed in the same popover or dialog, on iPad and Android tablet.
- **Reused:** the approved Colour and icon and All colours sheets from E-Phones-3 (ED-161), at phone sizes, boxed into the popover or dialog with the grabbers removed. The editor stays live behind; the header recolours as you pick.
- **Data change still waits (ED-219 to ED-221):** "Your colours" and Custom… need the must-ask data change before they are built. Drawing them does not approve it.
- **Dark:** the Android icon chips use #37313A, as on E-Phones-3-Dark (the converter left #EFE8EF light).
- **Board:** canvas y 195600. Published version `1794580655-ae0a`; all five files equal local. Snapshot v2.49-working.

### ED-299 · R2-15 approved: colour and icon picker on tablets
- **Date:** 2026-11-13. **Owner:** "Approve, continue".
- **Approved:** E-R2-15 and E-R2-15-Dark as drawn (ED-298): iPad popover from the task dot; Android M3 dialog; the phone half sheet below expanded. The data change for Your colours and Custom… still waits (ED-219 to ED-221).
- **Board labels:** "Approved · ED-299". Published version `1794580895-a32f`.

### ED-300 · R2-16 proposed: onboarding on every platform (boards E-R2-16, E-R2-16-Dark)
- **Date:** 2026-11-13. Round 2 stage 3, sixth board. Proposed for owner review.
- **Why every platform:** onboarding is built (`features/onboarding`, `domain/onboarding`) but was never designed in E (CR-089).
- **Flows (built):**
  - Full: Welcome, Layout, Day shape, Habits, Reminders, Account, Done.
  - Minimal: Welcome, Layout, Day shape, Reminders, First task.
  - "I already have an account" goes to Account as "Welcome back".
- **Frame (built):** ‹ Back, the step dots ("Step 3 of 7"; Welcome counts), and Skip. There is no frame on Welcome and Layout, and no Skip on Done. Each step has one primary action at the bottom.
- **E parts:**
  - Welcome: the thread and the day dot drawing itself (static with Reduce Motion).
  - Layout: the Full and Minimal sketches.
  - Habits: the seven built starter habits as task dots with icons; up to five, three picked.
  - Done: tomorrow's thread with the picked habits; "Open today"; the Siri line on iOS.
  - Account: the approved sign-in buttons (CR-160 rules; no Apple on Android) and "Continue without an account".
- **Width:** phones full screen; tablets, Mac and web show the same steps in a centred 520 column, full screen.
- **Copy:** built strings only (onboarding*, starter*, account*, settingsWakeUp / settingsWindDown).
- **Fixed while drawing:** the step dots first counted from Layout. They now match the built count (Welcome included).
- **Board:** canvas y 197340. Published version `1794580895-a32f`; all five files equal local. Snapshot v2.50-working.

### ED-301 · Onboarding: three new directions for the owner (board E-Onboarding-Options, own board)
- **Date:** 2026-11-13. **Owner:** "creatively redesign my onboarding UI/UX flow; it must not be the same as the old and must not have the same flow; add motion; make it crisp and modern … make it in another canvas … give me like 3 options."
- **Where:** a new board pair, E-Onboarding-Options and E-Onboarding-Options-Dark, beside R2-16 (canvas x 25900, y 197340). R2-16 (the built flow drawn in E, ED-300) is unchanged and still proposed.
- **A · Draw your day** (4 screens):
  - One living screen. Wake Up pops in as a dot; habit chips fly onto the thread; you drag the moon to close the thread at Wind Down; the day's colours close into one ring.
  - Layout and Reminders become quiet choices on the last screen ("Ask later", "Show me less"); the account is optional at the end.
- **B · Try it first** (5 screens):
  - You start inside a sample day with a coach card and learn three moves by doing: finish a dot, drag into a free gap, type "call Sam 6pm".
  - Then the sample sweeps away and you set Wake Up and Wind Down. The habits and layout steps go.
- **C · Pick your rhythm** (4 screens):
  - Swipeable rhythm cards on a 24-hour ring (Early bird · Nine to six · Night owl · My own).
  - A live morph preview for Everything versus Less.
  - A real-looking notification sliding in for the nudge question.
  - The ring closes into the day dot, and Today opens.
- **Motion:** plays on the board as CSS loops (grow, pop with spring, fly, pulse, morph, slide, sweep). Every motion stops under Reduce Motion and shows its end state; in the app, durations are 200–600 ms.
- **Kept in all three:** the 13+ age note on the first screen, Wake Up and Wind Down, an optional account, and the Full / Minimal choice (asked or deferred). New copy is marked for the owner's review.
- **Status:** OPTIONS, awaiting the owner's choice. Nothing is built; a chosen option would replace the built flow (per the owner's replace-not-layer rule) after approval.
- **Published:** version `1794582106-fcd5`; all three files equal local. Snapshot v2.51-working.

### ED-302 · Onboarding: three more directions, D, E and F (same board, E-Onboarding-Options)
- **Date:** 2026-11-13. **Owner:** "add 3 more ideas/concepts".
- **D · Say your day** (4 screens):
  - Tell it your day in one sentence, by voice or typing. A live waveform plays; the times and tasks in the sentence highlight and rise as chips; a proposed thread with dashed "new" dots appears; "Yes, that's my day" writes it.
  - Rules: this is a proposal (the ProposalSheet rule: nothing saved before Yes). The built parser reads it on the device and nothing leaves it. Voice needs the system's on-device speech; typing always works.
- **E · Sunrise, sunset** (4 screens):
  - Drag the sun up on a living sky for Wake Up (the sky brightens), then the moon down for Wind Down (night, stars, awake time and sleep). The horizon becomes the thread between the two end dots.
  - Habits, nudges and layout move into context later.
  - The sky is an illustration and looks the same in light and dark; headings sit on frosted cards for contrast.
- **F · Swipe to set up** (5 cards):
  - A deck of yes / skip cards with defaults (day, habits, nudges, layout) after a practice card, with a progress bar and a summary at the end.
  - Buttons mirror the swipe for anyone who can't swipe and for screen readers.
- **Board:** now "six new directions", 3720 tall (light and dark). R2-16 is unchanged.
- **Status:** OPTIONS, awaiting the owner's choice.
- **Published:** version `1794582431-23d7`; all three files equal local. Snapshot v2.52-working.

### ED-303 · Onboarding recommendation: "The First Thread" (boards E-Onboarding-Signature, E-Onboarding-Signature-Dark)
- **Date:** 2026-11-13. **Owner:** asked for the onboarding I would present as the best of the best, with research, motion and graphics.
- **Research used:**
  - Apple: avoid delays before the content and defer non-essential requests; ask for permissions when people expect them, not at first launch.
  - Material: the Quickstart and Self-Select models, with few choices tied to what the app does.
  - Android 13+: ask for notification permission in context, after the user has a reason; the app works without it.
- **Flow (five screens, three required taps, under 30 s):**
  1. Hello: the day dot draws itself and its thread runs into the next screen. No splash or carousel; 13+ note.
  2. Your day: drag the sun and moon (defaults 7:00 and 11:00; "16 h awake · 8 h of sleep").
  3. Your first thing: the user's own thread with the now marker. Type ("gym 6pm") or tap a suggestion; the time is read as you type, on the device.
  4. A nudge, in context: Gym drops onto 6 PM, a preview of that exact reminder slides in, then "Allow nudges" and only then the system prompt. "Not now" is never punished.
  5. You're in: the real Today. One hint fades after the first tap; a dismissible "Sign in to sync" card.
- **Later, in context, once each:** Less (day 2), make it a habit (after 3 tasks), close the day (first Wind Down), sign in (second device).
- **Other platforms:**
  - Android: the system dialog appears after "Allow nudges".
  - Tablets, Mac and web: the same steps in a 430 card over the blurred app.
- **Motion spec on the board:** the ring draws (900 ms); a shared-element thread (450 ms); the sun and moon follow the finger with hour haptics; the task drops with a spring (420 ms); the reminder slides (320 ms); the hint fades (200 ms). Reduce Motion turns every move into a cross-fade.
- **Accessibility:** adjustable sliders for the sun and moon; 200 % text scrolls; contrast at least 4.5:1; no colour-only signals; returning users go straight to sign-in.
- **Relation to the built flow and the options:**
  - Built flow: keeps Welcome and Day shape (made visual), replaces Habits with one real first task, moves Reminders into context, and moves Layout and Account to the later cards.
  - Options: combines B (value first), A and E (the thread and the sun and moon), and C (a real reminder preview).
  - Building it replaces the current flow.
- **Status:** RECOMMENDATION, awaiting the owner. Not built. New copy is marked for review.
- **Board:** canvas x 25900, y 201300, below the options. Published version `1794583111-ea48`; all three files equal local. Snapshot v2.53-working.

### ED-304 · R2-16 redone as an interactive prototype (separate artifact)
- **Date:** 2026-11-13. **Owner:** "redo this in a different canvas … much better interactive look, add motions or make it interactive".
- **Where:** its own artifact, https://claude.ai/artifact/3dgrJiQ8GGEdxgnD9PCvjL (version `1794587391-52d6`), not the Design canvas. First version kept as snapshot v2.54-working (the prototype file and its checksum).
- **What:** The First Thread flow (ED-303), wired up: Hello (the day dot draws itself) → Your day (drag the sun and moon; keyboard and screen-reader sliders) → Your first thing (live on-device time reading, ghost dot) → A nudge, in context (the dropped task, a reminder preview, the ask, then the platform's system prompt) → You're in (the real Today; a hint that disappears; a dismissible sync card; tap the dot to mark it done). "I have an account" goes to sign-in.
- **Switches:** iPhone, Android, iPad, Mac and web (on iPad, Mac and web, a card over your own blurred Today); light or dark device theme; full or reduced motion. The page also holds the "later" cards, the motion and haptics table, and "why it beats the built flow".
- **Status:** proposed. Supersedes the static R2-16 board (ED-300) for review if approved. Nothing built or committed.
- **Update (owner comment on E-Onboarding-Options, option A screen 2):** "What fills your days?" added as step 3 of 6. Routine chips (Morning run, Deep work, Gym, Read) fly onto the thread at times set from Wake Up and Wind Down. They carry through to the first task, the nudge and Today, where they are marked "most days". A routine that is also typed as today's task is shown once. The button reads "Skip for now" when nothing is chosen. Four required taps. Version `1794588959-dade`; snapshot v2.55-working.
- **Update (owner comment on the prototype):** "What fills your days?" now has a type-your-own field. Return or the + button adds the item to the thread, using the time typed or the biggest free gap. It gets an icon from its words (gym, run or walk, call, focus, read, meal, meds, music), or a plain dot if none fits, and is shown as a chip with the others. Up to 4 of your own. A crowded thread switches to compact one-line rows. Snapshot v2.56-working.
- **Update (owner comment on the Your day dial background):** replaced the hard lavender and yellow bands and blurred halos. The dial is now the card surface with a 1 px outline. A soft gradient runs night → dawn at Wake Up → plain day → dusk at Wind Down → night, and the stars in the sleep hours fade out towards the day. Faint hour lines match the labels, and the sun and moon each have a soft ring (larger while dragging). Light and dark. Snapshot v2.57-working.
- **Update (owner: "blend in … don't look like a box"):** the dial has no outline or corners. It runs edge to edge, its day colour is the screen ground, and it fades out at the top and bottom, so the sky reads as part of the screen. The hour lines fade out to the right. Snapshot v2.58-working.
- **Update (owner: "remove that", on the 13+ note):** "Dottoday is for people aged 13 and over." is removed from the Hello screen of the prototype. **Open conflict:** docs/06-security.md (Children) and M8.6 require that note on O1 Welcome (`onboardingAgeNote`). Before build, the owner either gives the note a new home in onboarding or changes 06. Not resolved here. Snapshot v2.59-working.
- **Update (owner: "maximum entry on this thread is 5"):** "What fills your days?" takes at most 5 routines (ready-made and your own together; Wake Up and Wind Down are not counted). A live "n of 5" counter sits in the add field. At 5, the unpicked chips dim and are disabled, and the field reads "Five is plenty for a start" (new copy for review). Removing one re-opens them. This replaces the earlier limit of 4 of your own. The NOW pill moved to the right end of the now line so it no longer covers dots. Snapshot v2.60-working.
- **Update (owner: "remove this step", on Your first thing):** the first-task step is removed, and its view, parsing UI and styles are deleted (replace, not layer). The flow is Hello → Your day → What fills your days → A nudge, in context → You're in: five screens, three required taps. The nudge now previews the next routine after now (or the first one picked; or Wind Down if none were picked), and that routine is the tappable dot and hint in Today. Snapshot v2.61-working.
- **Update (owner: "use the dottoday Menu across where needed"):** the prototype's placeholder bars are replaced with the approved ones, in light and dark:
  - iPhone: the glass tab bar (Today · Inbox · Calendar · Search) with the teal + in its line (ED-124).
  - Android: the floating frosted toolbar with the icon-only + (ED-125).
  - Phones: Settings sits behind the avatar, not in a tab (ED-238).
  - iPad, Mac and web: the approved sidebar (R2-1 rows: Today, Plan › Inbox, Routines, Brain dump; Calendar views; Review; Search; Settings at the foot) with live counts (Today done/total, Routines). The status line reads "On this device", since there is no account yet.
  - Onboarding steps show no navigation. Snapshot v2.62-working.

### ED-305 · R2-16 approved: the interactive onboarding prototype
- **Date:** 2026-11-13. **Owner:** "Approve the interactive R2-16 and move on to R2-17 (system surfaces)".
- **Approved:** the artifact **“Dottoday Onboarding Prototype”**, headed “Concept E · Round 2 · R2-16 · Interactive prototype” (https://claude.ai/artifact/3dgrJiQ8GGEdxgnD9PCvjL). It was approved as revised through the owner's comments (ED-304 updates): content version `1794591097-8545`, snapshot v2.62-working.
- **Confirmed by the owner (2026-11-13), and labelled:** the prototype page now reads “Approved (ED-305, 13 Nov 2026)”. Labelled version `1794593098-7a9a`; only the label changed. On the Design canvas, the E-R2-16 and E-R2-16-Dark board titles read “APPROVED as the interactive prototype ‘Dottoday Onboarding Prototype’ (ED-305) · this static board is history” (canvas version `1794593110-0673`). Snapshot v2.64-working.
  - The flow: Hello → Your day (sun and moon) → What fills your days? (up to 5 routines, ready-made or typed, auto icon) → A nudge, in context → You're in (the real Today, with the approved menus). No Layout step: the layout choice is the day-2 "Want it simpler?" card (confirmed ED-350).
  - Three required taps.
- **Replaces:** the static R2-16 board (ED-300), The First Thread board (ED-303) as the onboarding direction, and options A to F (ED-301, ED-302). Those boards stay on the canvas as history.
- **Open before build:**
  1. The 13+ age note needs a new home, or docs/06-security.md needs changing (ED-304).
  2. New copy needs owner review ("Skip for now", "Five is plenty for a start", "Welcome back" line).
  3. Building it replaces the built onboarding flow (replace, not layer) and needs a build go-ahead.
- Nothing built or committed.

### ED-306 · R2-17 proposed: system surfaces (boards E-R2-17, E-R2-17-Dark)
- **Date:** 2026-11-13. Round 2 stage 3. Proposed for owner review.
- **Scope:** every built surface outside the app, redrawn in Concept E. Each one reads DaySnapshot and runs only the five App Intents; none talks to Supabase (CLAUDE.md §11). No new native targets are drawn: a watch app, Mac widgets or Wake Up Live Activity changes would be must-ask.
- **Drawn (one sample moment, 10:42 AM, Deep work: roadmap live, 18 min left, 3 of 10 done):**
  - **iPhone:**
    - Home Screen widgets: Next up (small), Today (medium, large), Inbox (small).
    - Lock Screen: Next up (rectangular) and the Live Activity (thread bar, ring, Done, +15 min).
    - Dynamic Island: compact, minimal and expanded.
    - Control Center: Add task, Start focus.
  - **Android:**
    - Glance widgets: Next up, Today 4×2 and 4×4, Inbox.
    - Quick Settings tiles: Add task, Start focus.
    - The silent ongoing notification: title, range · count, countdown, Done, +15 min.
    - The share sheet.
  - **iPad:** the iPhone widgets at iPad sizes. There is no Live Activity (ActivityKit).
  - **Mac:** the day dot status item and its menu (Now, Done, +15 min, what is left, Today).
  - **Web:** the tab title "● 18 min left · …" with a ring favicon.
  - **Share:** iOS share and compose into Inbox.
- **Design-only changes (E look, same data):**
  - The now dot is a ring in the task colour that fills with the time used; dots ahead are hollow.
  - The Today widget gets a thread line, with the day dot in each header.
  - The Live Activity and the notification show progress in the task colour.
- **Strings:** only built ones from the snapshot (Now, Next up, Today, until {time}, Done, +15 min, {n} in Inbox, Add task, Start focus). No new copy.
- **Board:** canvas x 21860 / 23900, y 199440, 1900 × 3640. Published version `1794592497-caae`; files read back equal. The R2-16, onboarding options and The First Thread board titles now say "history" (ED-305). Snapshot v2.63-working.

### ED-307 · R2-17 redone as an interactive prototype (separate artifact)
- **Date:** 2026-11-13. **Owner:** "on another canvas using the concept E make a new R2-17".
- **Where:** its own artifact, **"Dottoday System Surfaces"**, at https://claude.ai/artifact/GrBHzfnUpQV9uRtSpeotCE (version `1794593173-e066`). It is not on the Design canvas.
- **What it does:**
  - One shared day snapshot drives every built surface. You drag the clock, and Done, +15 min, Add task (Quick Add into Inbox), Start focus and Share all change the snapshot.
  - Every surface follows. A side panel shows the snapshot and a log of the intents run (which intent, and from which surface).
- **Surfaces:**
  - iPhone: Home Screen widgets, with the Dynamic Island (tap to expand); Lock Screen (Next up and the Live Activity); Control Center; the share sheet with the compose step.
  - Android: Glance widgets; the shade (Quick Settings tiles and the ongoing notification); the share sheet.
  - iPad: widgets.
  - Mac: the day dot menu bar item and its menu; the Share menu.
  - Web: the tab title and favicon.
  - Light and dark.
- **Rules kept:**
  - Built strings only (toasts use focusDoneMessage and focusExtendedMessage; the Quick Add hint is inboxAddHint).
  - No new native targets.
  - Calm states: a task past its end just stops being "now".
- **Status:** proposed. Supersedes the static R2-17 board (ED-306) for review if approved. Nothing built or committed. Snapshot v2.65-working.
- **Withdrawn (2026-11-13).** Owner: "i did not ask of it to be interactive im saying to make 2 options using concept E". The artifact is not part of R2-17. R2-17 continues as two static Concept E options on a new canvas (ED-308). The artifact stays until the owner says whether to delete it.

### ED-308 · R2-17 two Concept E options on their own canvas
- **Date:** 2026-11-13. **Owner:** "on another canvas using the concept E make a new R2-17", then "i did not ask of it to be interactive im saying to make 2 options using concept E".
- **Where:** a new Design canvas, **"Dottoday R2-17 Options"**, at https://claude.ai/artifact/UacPip63KnnyYrXWmWp7N5 (version `1794593864-290f`).
  - Main: the overview, the comparison and the recommendation.
  - Option A, light and dark.
  - Option B, light and dark.
- **Option A · The thread:**
  - The day as a line of dots, like Today in the app (the ED-306 direction, refined).
  - Now is a ring in its task colour, ahead tasks are hollow dots, and the day dot is in each header.
- **Option B · The day dot:**
  - The whole day as one ring from Wake Up to Wind Down. Each task is an arc in its colour: solid when done, pale ahead, wider while it runs. A small dot marks now.
  - The task under way carries a big minutes-left countdown inside its ring.
  - Inbox is drawn as a dot.
  - The ring is the menu-bar glyph and the favicon, and the Mac menu opens on a day-ring header.
- **Both:**
  - Every built surface (iPhone, Android, iPad, Mac, web, Share), the same snapshot and the five intents.
  - Built strings only; no new targets.
- **Recommendation:** B for the glance surfaces (small widgets, Lock Screen, island, menu-bar glyph, favicon) and A for the reading surfaces (medium and large Today, the Mac menu). If one option must cover everything, A, which matches Today and costs the least native work.
- **Status:** for owner decision (A, B or the mix). The ED-306 board on the main canvas stays as the earlier draft. Nothing built or committed. Snapshot v2.66-working.
- **Update (owner comment on E-R2-17: "the line should be in the middle of the circle and it should always allign"):** in the Today widgets the thread line now runs through the centre of every dot. Each dot sits in a fixed 16 px slot, and the line runs from the first dot's centre to the last. Measured offset 0 px on all six Today widgets. Applied to E-R2-17 and its dark board (main canvas, version `1794594566-1abd`) and to Option A and the overview (options canvas, version `1794594569-d2df`). Option B has no thread line and is unchanged. Snapshot v2.67-working.

### ED-309 · R2-17 approved: system surfaces (boards E-R2-17, E-R2-17-Dark)
- **Date:** 2026-11-13. **Owner:** "Approved CONCEPT E · ROUND 2 · STAGE 3 · R2-17 - R2-17 · System surfaces · stage 3 · proposed (ED-306) · for owner review … mark it as approved too on the canvas".
- **Approved:** the E-R2-17 and E-R2-17-Dark boards on the main Design canvas, as proposed in ED-306 and with the thread-line alignment fix (ED-308 update).
  - Every built surface in the thread look: now is a ring in the task colour, ahead tasks are hollow dots on the line, and the day dot sits in each header.
  - The surfaces: iPhone widgets, Lock Screen, Live Activity, Dynamic Island and Controls; Android widgets, Quick Settings and the ongoing notification; iPad widgets; the Mac menu bar; the web tab; Share.
  - Built strings only. No new native targets.
- **Marked:** the board header tag reads "Approved · ED-309 · 13 Nov 2026", and the canvas titles read "approved (ED-309)". Main canvas version `1794594947-b7ed`; only the label changed.
- **History:** the "Dottoday R2-17 Options" canvas (ED-308, Options A and B) is marked history, and the interactive "Dottoday System Surfaces" artifact stays withdrawn (ED-307).
- **Open before build:**
  - The Concept E widget look is design-only on every surface; building it changes WidgetKit, Glance, the Live Activity, the notification and the status item.
  - Device checks are still owed (FEATURE_READINESS: these surfaces are unverified on device).
  - The ring glyph for Start focus needs a custom SF Symbol.
- Nothing built or committed. Snapshot v2.68-working.

### ED-310 · R2-18 proposed: Wake Up and Wind Down on tablets, re-check (boards E-R2-18, E-R2-18-Dark)
- **Date:** 2026-11-13. Round 2 stage 3, the last item that is not blocked. Account screens wait for CR-160. Proposed for owner review.
- **Why:** the tablet checklist row "Wake Up and Wind Down … Re-check against ED-171 navigation". The ED-084 pages were approved before the tablet navigation (R2-1) and two-pane Settings (R2-11) were drawn.
- **Drawn (approved ED-084 pages at phone size, in the approved tablet navigation):**
  - iPad expanded:
    - Settings › Your day › Wake Up and Wind Down, two panes, with the page pushed inside the right pane and keeping ‹ Your day.
    - Alarm sounds on, read from the iPad ("This iPad · iPad Air" rings; the iPhone can ring if chosen).
  - iPad medium: the page pushed full width.
  - Android expanded: list-detail (as approved in R2-11).
  - Android medium: the rail stays, and the page is pushed beside it with ←.
- **Result:**
  - It fits; nothing changes in the approved pages.
  - The thread caps are already on the R2-1 tablet boards.
  - Not redrawn (marked ◐ for review): the schedule editors and the night dial (240–360 pt rule, never stretched), presented as each platform's tablet sheet.
  - The alarm itself is system UI: AlarmKit on iPad, a full-screen intent on Android.
- **Still open:**
  - The Wake Up alarm ringing screens, the Wake Up card, Wake Up Check and snooze are "Not designed" in the screen inventory. That is a board of its own.
  - Before build: AlarmKit on iPadOS 26, Play's full-screen-intent policy on tablets, and the device-list table (must-ask).
- **Board:** canvas x 21860 / 23900, y 203200, 1900 × 2000. Version `1794595222-a8cf`. Snapshot v2.69-working.

### ED-311 · R2-18 approved; Round 2 stage 3 complete except account screens (blocked on CR-160)
- **Date:** 2026-11-13. **Owner:** "Approve, continue".
- **Approved:** E-R2-18 and E-R2-18-Dark as drawn (ED-310). Wake Up and Wind Down fits the approved tablet navigation, and the approved ED-084 pages do not change. The ◐ items, the schedule editors and the night dial shown as each platform's tablet sheet, are approved as stated.
- **Marked:** the board tag reads "Approved · ED-311 · 13 Nov 2026" and the canvas titles read "approved (ED-311)". Version `1794595347-5b8f`.
- **Stage 3 (supporting experiences), approved:**
  - R2-11 Settings on tablets (ED-291);
  - R2-12 (ED-293), R2-13 Inbox and Search (ED-295), R2-14 (ED-297), R2-15 colour picker (ED-299);
  - R2-16 onboarding, the interactive "Dottoday Onboarding Prototype" (ED-305);
  - R2-17 system surfaces (ED-309);
  - R2-18 Wake Up and Wind Down re-check (this entry).
- **Not done:** account screens, which wait for CR-160 (CRITICAL — OPEN — RELEASE BLOCKER).
- **Open, outside the stage list:** the Wake Up alarm ringing screens, the Wake Up card, Wake Up Check and snooze ("Not designed" in the screen inventory).
- Nothing built or committed. Snapshot v2.70-working.

### ED-312 · R2-19 proposed: the Wake Up alarm (boards E-R2-19, E-R2-19-Dark)
- **Date:** 2026-11-13. **Owner:** "build the wake up Alarm", after asking whether it waits for CR-160 (it does not: CR-160 is the cross-account sign-out and sign-in fix and only holds the account screens).
- **Why:** the screen inventory had "Wake Up alarm ringing (AlarmKit / Android full screen / Mac+web notification)" and "Wake Up card, Wake Up Check, snooze" as Not designed. The behaviour is built (docs/15 W1–W5).
- **Drawn (sample morning: Wake Up 6:30, first dot Morning run at 6:45):**
  - **iPhone, in order:**
    1. The AlarmKit alert: system UI, label "Wake Up · Dottoday", Snooze and Stop.
    2. Snoozed: the system countdown on the Lock Screen and in the Dynamic Island.
    3. "I'm up" opens the Wake Up card: "Good morning. Thursday 13 November."; the day dot with the night arc and "9 planned · ends 11:00 PM"; the first dot and its first step; the next four on a mini thread; the calendar and Inbox lines; Start the day and Later.
    4. Up later than planned: "You're up 25 min after plan." and "Shift the rest?", which opens the ProposalSheet.
    5. One Wake Up Check: "Start Morning run?" / "Tap to start."
  - **Android:**
    - Dottoday's own full-screen ringing screen: the time, Wake Up, "First: Morning run at 6:45 AM", Snooze and I'm up.
    - The minimal-mode ringing screen.
    - The card.
    - The heads-up fallback when full screen is not allowed, with its Settings line.
  - **Also:**
    - A mission (Walk 20 steps, "12 of 20 steps", "Can't right now" with "Hold for 5 seconds").
    - The time-sensitive notification on iOS 17–25.
    - The card as a centred sheet over Today on iPad (design-only; the R2-16 card pattern).
- **Rules on the board:**
  - one alarm device;
  - no shame;
  - nothing changes before Accept;
  - stop conditions;
  - built strings only;
  - motion: the card rises over Today, the ringing screen never animates, and Reduce Motion gives cross-fades.
- **Before build:** verify AlarmKit on iPadOS 26 and Play's full-screen-intent policy on tablets. The Concept E look of the Android ringing screen and the card is design-only.
- **Board:** canvas x 21860 / 23900, y 205320, 1900 × 3240. Version `1794596303-457a`. Snapshot v2.71-working.

### ED-313 · R2-19 Option B: the thread wakes up (boards E-R2-19-B, E-R2-19-B-Dark)
- **Date:** 2026-11-13. **Owner:** "design another one using concept E in mind" (while viewing E-R2-19).
- **Options:** E-R2-19 is now Option A, the briefing card (ED-312). Option B is a second direction, with the same behaviour and the same built strings.
- **Option B:**
  - **Android ringing screen:** a dawn sky with the time inside the day dot. The day's dots are faint around it and the sun marks Wake Up. A big white I'm up sits in the thumb zone, with Snooze under it. Minimal mode keeps only I'm up, with Snooze as a text link.
  - **The card is Today's thread:** it runs from Wake Up down. The first dot is large, with its first step ready; Coffee, Standup and Deep work follow on the line. Start the day lands in the same thread with no jump.
  - **Late start:** the new times show on the thread (→ 7:10 AM, …), with "This moves what's left; nothing changes until you accept." (wakeUpDiscoveryShift) and Shift the rest?, which opens the ProposalSheet.
  - **Mission:** on the same dawn sky.
  - **iPad:** the card docks as a left panel and Today stays sharp on the right.
- **Unchanged from A:** the iOS AlarmKit alert and its countdown (system UI), the Wake Up Check, the heads-up fallback, and the iOS 17–25 notification.
- **Recommendation on the board:** B's card (the thread from Wake Up). A's calmer Android ringing screen is the safer choice if the dawn sky reads too bright at 6:30. The owner chooses A, B or that mix.
- **Board:** canvas x 25900 / 27940, y 205320, 1900 × 2600. E-R2-19 board titles now read "Option A". Version `1794597558-b626`. Snapshot v2.72-working.
- **Update (owner comment on the Walk mission: the circle seems small; animate it; add someone who walks across the screen, goes out and comes back in from the other edge; the step should have motion):**
  - The step ring is 236 pt (was 150). It fills one step at a time, with a small pulse on each step, and the count ticks up (the board plays 20 steps in 10 s; in the app the ring follows the real step count).
  - A walking figure, with swinging legs and arms and a light bob, crosses the dawn screen, leaves at the right edge and re-enters from the left, looping in step with the count.
  - Reduce Motion: the ring shows the real count (12 of 20) and nothing moves.
  - Board height 2840. Snapshot v2.73-working.
- **Update (owner comment: the line round the circle should be teal, like Concept E):** the Walk mission's progress ring is now the Concept E teal #5BC4B8, the accent as it reads on a dark surface, on the dawn sky in light and dark. It was green #5FCB8A. Snapshot v2.74-working.
- **Update (owner rule: "the color of the circle will always change based on the color of the user selected theme, the background should always be considered and the users color can always be switched to a lighter color if needed"):**
  - The Walk mission's progress ring takes the person's App colour (ED-161), starting from its dark-mode shade in dark.
  - Where that colour is under 3:1 against the background it sits on (here the dawn sky at the ring's height), it is lightened toward white in 2 % steps until it reaches 3:1. Colours that already reach 3:1 stay as chosen.
  - Drawn with the default Teal: light board #8DB3B1 (3.0:1, lightened); dark board #5BC4B8 (6.8:1).
  - A strip under the mission shows all nine App colours (Teal, Blush, Peach, Honey, Sage, Dusk blue, Pine, Plum, Ink navy): as chosen, as drawn on the sky, and the contrast, in both themes.
  - The rule is in E_DESIGN_RULES. Board height 3460. Snapshot v2.75-working.
- **Update (owner comment: "what about the mockup for iphone"):** Option B now has its own iPhone row instead of pointing to Option A:
  1. The AlarmKit alert (system UI, unchanged).
  2. Snoozed: Dottoday's own Live Activity in the dawn style, with the countdown inside the day dot and the Dynamic Island showing the sun and the time left.
  3. A mission morning: Stop opens the app on the mission (built behaviour on iOS 26.1+).
  4. The thread card.
  5. The late start on the thread.
  - The Android row now has the ringing screen, minimal mode, the card and the late start. "Same as Option A" lists only the Wake Up Check, the heads-up fallback and the iOS 17–25 notification.
  - Board height 4380. Snapshot v2.76-working.
- **Update (owner: "return the moving circle color to its previous last color"):** the Walk ring is back to #5BC4B8 on both boards. This fits the App colour rule: the dawn sky is a dark surface in both themes, so the ring starts from the App colour's dark-surface shade, and #5BC4B8 reaches 3.3:1 on the light board's sky and 6.8:1 on the dark one, so no lightening is needed. The swatch strip now starts every colour from its dark-surface shade. Snapshot v2.77-working.
- **Update (owner comment: "for the other missions also make their mockups"):** a new "The other missions" section draws the remaining five on the dawn sky, each with its own looping motion and built strings, and Can't right now (hold 5 s) on every one:
  - **Stand up:** the phone tilts upright while the ring fills, "0 of 3 s" to "3 of 3 s", with "Hold the phone upright and move".
  - **Light:** the bulb glows as the room brightens, and "Still too dark" turns to "Bright enough, keep it on" over 3 s.
  - **Breathe:** the ring grows on Hold and shrinks on Let go, "Breath 1 of 3".
  - **Catch the dot:** a slow wandering dot with "n of 5 · Tap the dot"; no timer or score.
  - **Pick today's one thing:** five dots; the pick wears the one-thing ring with "Your one thing".
  - Rings and dots use the App colour ring rule.
  - Reduce Motion: a still mid-state.
  - Board height 5260. Snapshot v2.78-working.
- **Update (owner comment: "this should never stop walking until the walking challenge is stopped or ends"):** the walker now keeps walking for the whole challenge. It crosses the screen and re-enters straight from the other edge, with no pause off screen. It stops only when the challenge ends: at 20 of 20 it stands still with a check in the ring colour, or when Can't right now ends it. On the board: 12 s cycles, 10 s walking to 20 steps, then 2 s done; the count and ring are synced to the cycle. Reduce Motion: a still mid-state, unchanged. Snapshot v2.79-working.
- **Update (owner comment on Catch the dot: different primary colours moving around, the person given one colour to tap 3 times; the movement area expanded to move behind the title but not into Can't right now; seamless motion):**
  - Four dots in blue, red, yellow and green glide on seamless closed loops (rotated ellipses, linear speed, co-prime durations of 17 to 29 s, so no jumps and no visible repeat).
  - The play area runs from under the time to just above Can't right now, full width. Dots pass behind "Catch the dot 3 times" and the count, but never reach Can't right now.
  - Each dot carries its own white shape (circle, triangle, square, plus), so colour is never the only cue.
  - The instruction names the target with a swatch: "Tap the blue dot", counting "n of 3".
  - Reduce Motion: the dots stand still, spread out.
  - This changes the built mission (one dot, 5 taps). New copy for review: "Tap the blue dot" (built today: missionCatchTap "Tap the dot", missionLineCatchDot "Catch the dot {count} times" with count 3). Building it needs the mission logic and new strings.
  - Board height 5340. Snapshot v2.80-working.
- **Update (owner comment on Breathe: "i don't understand this design"):** Breathe now shows what to do. A fingertip presses the ring while it says Hold and the ring grows, then lifts away on Let go while the ring shrinks, in step with the 6 s breath. The caption explains the steps: press and hold, breathe in; lift, breathe out; three breaths, about 20 s, then the alarm stops. Strings unchanged (Hold, Let go, Breath n of 3, Breathe with the ring). Reduce Motion: a still Hold state. Snapshot v2.81-working.
- **Reverted (owner: "do not proceed with the change again just leave as is", sent 20:06, before that change went live at 20:07):** the Breathe fingertip and caption change are removed. Breathe is back to its previous design, byte-identical to snapshot v2.80-working. No further change to Breathe. Snapshot v2.82-working.
- **Restored (owner: "add the finger back", 20:09):** the Breathe fingertip (presses on Hold, lifts on Let go) and its step caption are back, byte-identical to snapshot v2.81-working. This is the current Breathe design. Snapshot v2.83-working.

### ED-314 · R2-19 approved: Option B, "The thread wakes up" (boards E-R2-19-B, E-R2-19-B-Dark)
- **Date:** 2026-11-13. **Owner:** "Approve Option B for R2-19".
- **Approved:** E-R2-19-B and E-R2-19-B-Dark as they stand after the owner's comment rounds (ED-313 updates):
  - **Android:** the dawn ringing screen with the time inside the day dot, and its minimal mode. The card is Today's thread from Wake Up. Late start shows the new times on the thread, then Shift the rest?, which opens the ProposalSheet.
  - **iPhone:** the AlarmKit alert (system UI); the dawn snooze countdown Live Activity and Dynamic Island; Stop on a mission morning opens the mission; the thread card and late start.
  - **Missions on the dawn sky:**
    - Walk: a bigger animated step ring, and a walker who keeps walking until the challenge ends.
    - Stand up, Light, Breathe (with the fingertip) and Pick today's one thing.
    - Catch the dot: four coloured dots, each with its own shape, on seamless loops; tap the blue dot 3 times.
  - **Rings follow the App colour:** each ring is checked against its real background and starts from the colour's dark-surface shade on dark surfaces (E_DESIGN_RULES).
  - **iPad:** the card docks beside Today.
  - **Unchanged from A:** the Wake Up Check, the heads-up fallback, and the iOS 17–25 notification.
- **History:** E-R2-19 (Option A, ED-312) is marked history on the canvas.
- **Marked:** the board tag reads "Approved · ED-314 · 13 Nov 2026" and the canvas titles read "approved (ED-314)". Version `1794600748-b82b`.
- **Before build (design-only items and owner approvals):**
  - **Design changes:** the Concept E look of the Android ringing screen, the card and the Live Activity.
  - **Catch the dot:** it becomes four dots and 3 taps (built: one dot, 5 taps), with new copy "Tap the blue dot" for review.
  - **Platform checks:** AlarmKit on iPadOS 26 and Play's full-screen-intent policy on tablets.
- Nothing built or committed. Snapshot v2.84-working.
- **Added after approval (owner comment: "add alarm screens for Tabs, as they can also be selected as the device for the wakeup alarms but we might not add missions for them yet but you can build their mission screen"):** a Tablets row on E-R2-19-B (light and dark), for review:
  - **iPad ringing:** iPadOS 26 AlarmKit, the system's own full-screen alert in landscape, with Snooze and Stop.
  - **iPad snoozed:** iPad has no Live Activities, so the snooze is the system alarm's countdown on the Lock Screen, with no Dottoday card.
  - **Android tablet ringing:** Dottoday's own full-screen screen in landscape, with the dawn round the day dot and the time inside, Wake Up and the first dot beside it, then I'm up and Snooze.
  - **Walk mission on iPad and Android tablet:** drawn ready for later (landscape, the walker crossing the full width), marked "Not offered on tablets yet". Missions stay phone-only for now.
  - Board height 7220. Snapshot v2.85-working.
- **Update (owner comment: "this should be aligned in the middle"):** on both tablet Walk mission screens, the ring and the time / Walk 20 steps / Can't right now block are now centred, vertically and horizontally, in the space between the status bar and the walker's ground line. They were pinned near the top. Snapshot v2.86-working.
- **Update (owner comment moved onto Can't right now: "this should be aligned in the middle"):** on both tablet Walk screens, Can't right now and "Hold for 5 seconds" are now centred horizontally under the ring and text, above the walker, as on phones. They were left-aligned in the side column. Snapshot v2.87-working.
- **Update (owner comment on "The other missions": "create them for Tabs too"):** a new section, "The other missions on tablets", draws Stand up, Light, Breathe, Catch the dot and Pick today's one thing on iPad and on Android tablet (10 landscape screens, light and dark), each marked "Not offered on tablets yet".
  - Same visuals and motion as the phone missions, reused from one source, in the tablet Walk layout: the mission on the left, the time and its line on the right, Can't right now centred under both.
  - Catch the dot uses the whole screen, with four loops sized to the tablet.
  - Board height 9840. Snapshot v2.88-working.
- **Records audit (owner: "make sure to record all changes appropriately", 2026-11-13):** E_TABLET_CHECKLIST rows Onboarding (R2-16, ED-305) and System surfaces (R2-17, ED-309) updated, and a Wake Up alarm on tablets row added (ED-314). E_TRACEABILITY C.3 and C.5 rows and gap list updated for R2-16 to R2-19. Snapshots v2.31, v2.35, v2.38, v2.42 and v2.54, which no entry cited, are now cited in ED-266, ED-273, ED-278, ED-285 and ED-304. Docs snapshot v2.89-working. Canvas unchanged (latest version `1794601747-f5c7`).

### ED-315 · Round 2 order after stage 3: the screens outside the three stages (R2-20 to R2-24)
- **Date:** 2026-11-13. **Owner:** "Yes, start R2-20", on the proposed order below.
- **Why:** ED-166 says the screens outside the three stages are drawn after them, still in Round 2, but set no order. Each item was checked against this file: none of these screens has a design yet.
- **Order** (non-negotiables first, every platform together, as G4-1):
  - **R2-20 Notifications and alerts:** task alert, the at-start reminder, day-start summary, Wind Down reminder, the in-app strip, Settings › Reminders, notification health and the test alarm (R-10).
  - **R2-21 Data safety:** backups, export and import, the Trash page, the encrypted database recovery screen (R-08, R-11).
  - **R2-22 Planning helpers:** the Routines page, Duplicate day and Copy day as text, Low-energy mode, Day shape with the sleep target and night editor.
  - **R2-23 Proposal flows:** Break it down, Smallest step / Unstick, On-device AI status, the Reality thread (ProposalSheet; nothing written before Accept).
  - **R2-24 The rest:** Week in review share and learning reveal, calendar connect, App lock, Feedback and What's new, PWA install, a long-string (de / fr) pass.
  - **After CR-160:** account screens.
- **Records:** E_SCREEN_INVENTORY reconciled: 28 rows that a later approval covers now carry a dated "Since" note, and a header note says the decisions file wins where an unchecked row disagrees. The ED-314 records-audit note, which had landed after the end of the log, is moved into ED-314.
- **Classification:** RESOLVED (planning). Nothing built or committed.

### ED-316 · R2-20 proposed: notifications and alerts on every platform (boards E-R2-20, E-R2-20-Dark)
- **Date:** 2026-11-13. **Owner:** "Yes, start R2-20" (order ED-315). First item after stage 3.
- **Scope:** every reminder Dottoday sends and the Settings that shape them, as built (docs/02 F6, docs/09 M5, M6.5, M8.4d): task alerts, Wind Down, the day-start summary, the in-app strip, Settings › Reminders, Notification health and the test alarm. The sample is the R2-19 Thursday (Team standup at 8:00 AM).
- **Drawn:**
  - **1 · Task reminders:**
    - iPhone Lock Screen (time-sensitive "Starts in 10 minutes", grouped);
    - the long-press actions Done, Snooze 10 min, Open;
    - the Android shade with the "Task alerts" channel and the same three actions;
    - the Mac banner, where Done and Snooze 10 min sit under Options;
    - the in-app strip: a task's with Done and Snooze 10 min, Wind Down's with Open and Later;
    - the browser's own notification, with Done and Open;
    - the five alert texts and the quiet-hours, Focus and sound rules.
  - **2 · Wind Down and the day-start summary:**
    - iPhone at 11:00 PM: the sleep-target nudge, "Wind down now for 7 h 30 before Morning run at 6:45 AM.";
    - iPhone at Wake Up: "Your day · 9 blocks, first at 6:45 AM";
    - the Android "Wind Down" channel, including "Nothing planned for tomorrow yet.".
  - **3 · Settings › Reminders:**
    - the iPhone page with the built rows: Task starts, Sound, Quiet hours, Day-start summary, Wind Down reminder, Notification health;
    - iPhone with notifications off and quiet hours on (From and Until);
    - Android with the exact-timing notice;
    - iPad and Android tablet two-pane pages from the approved R2-11 root, with Reminders tinted.
  - **4 · Notification health and the test alarm:**
    - iPhone all good, rows in the built order: permission, Wake Up with the last wake-up, Focus, clock;
    - Android with two things to fix: exact timing (Allow) and battery saving (Open settings);
    - Mac and web lists. The Wake Up row is phones only; the web's "arrive with the tab closed" is information, not a problem;
    - the test alarm in five steps: the row; Send or Cancel; "Ringing in 42 s…"; the notification; "Did it ring?" with its two answers.
- **Copy:** every string is built (app_en.arb). No new copy.
- **Design-only:** the Concept E look of the in-app strip and of the Settings pages (the approved ED-084 page anatomy). System notifications are drawn by each system; Dottoday sets only the title, text, actions, channel and sound.
- **Not redrawn:** the Mac Settings window's Reminders pane, which holds the same rows (ED-081); the Task starts default-alert editor (the approved Alerts editor); the Sound page and the day-start weekday sheet.
- **Rules:** exactly once (R-10, F6.3); no late, missed or overdue, and no red (no-shame); nothing is lost (quiet hours, Focus and Do Not Disturb make reminders silent, never gone); the same features on every platform (R-13), with the web snoozing from the strip.
- **Board:** canvas x 21860 / 23900, y 208680, 1900 × 6660. Version `1794602875-fd35`; the page then saved `1794602877-03ec`, which only adds the two files to createdOnFiles. Both boards read back equal to local. Snapshot v2.90-working.
- **Status:** proposed for owner review. Nothing built or committed.
- **Update (owner comment on the Reminders page: "Add the dottoday menu in all the phone settings mockup that is not a half pull up for the light and dark"):** the approved phone bar, with no tab selected (ED-234, ED-235), is now on all five pushed Settings pages, in light and dark: iPhone Reminders, iPhone Reminders with notifications off, Android Reminders, iPhone Notification health and Android Notification health. The bar is copied from the live E-Phones pages; long pages scroll under it. The tablet panes keep their sidebar or drawer and no bar (R2-11). Version `1794603521-80db`, made from the live files after checking they matched local. Snapshot v2.91-working.

### ED-317 · R2-20 approved: notifications and alerts on every platform (boards E-R2-20, E-R2-20-Dark)
- **Date:** 2026-11-13. **Owner:** "Approve R2-20 and move on to R2-21".
- **Approved:** E-R2-20 and E-R2-20-Dark as drawn (ED-316), with the phone bar on every pushed Settings page (ED-316 update). This covers:
  - task alerts with Done, Snooze 10 min and Open on iPhone, Android, Mac and web;
  - the in-app strip;
  - Wind Down and the day-start summary;
  - Settings › Reminders on phones and in two panes on tablets;
  - Notification health in the built order, and the test alarm.
- **Board labels:** "Approved · ED-317"; canvas titles updated. Version `1794604037-aa5e`.
- **Still to verify before build:** nothing new; the platform checks stay as built (exact alarms and battery saving on Android tablets).
- Nothing built or committed. Snapshot v2.92-working.

### ED-318 · R2-21 proposed: data safety on every platform (boards E-R2-21, E-R2-21-Dark)
- **Date:** 2026-11-13. **Owner:** "Approve R2-20 and move on to R2-21" (order ED-315).
- **Scope:** as built (docs/02 F7.5, F7.6; docs/09 M2.4, M2.5, M3f.9a, M8.1). Covers Settings › Data and privacy, Export with the backups kept on the device, import and restore, Trash, and the recovery screen shown when the database can't be opened (R-08, R-11).
- **Drawn:**
  - **1 · Settings › Data and privacy:**
    - iPhone and Android, with the built Data rows (Sync, Calendars, Export, Trash) and the phone bar with no tab selected (ED-234, ED-235);
    - iPad and Android tablet in two panes (R2-11), showing Export on the right.
  - **2 · Export:**
    - the top of the page (three exports, the plain-file warning, Import a backup…);
    - On this device (the daily backups, "Before an import", and the note);
    - the empty state;
    - Android.
  - **3 · Taking a file out:**
    - the iOS share sheet holding `dottoday-backup-<date>.json`;
    - the Mac save dialog;
    - the toast texts: not a backup, over 25 MB, couldn't save or share, Backup imported · Undo, Exported.
  - **4 · Import and restore:**
    - "Replace your tasks with this backup?" as an iOS alert and as an M3 dialog;
    - "Go back to this backup?";
    - Backup restored · Undo.
  - **5 · Trash:** the built sheet, with each task's dot in the skipped state and Restore; "Dentist restored"; Trash is empty; Android.
  - **6 · Recovery:**
    - the key is missing → Start fresh;
    - the inline "Start with an empty planner?";
    - where the old file is kept → Continue;
    - on the web: open in another tab, the tab that handed over, and no answer in 5 s.
- **Copy:** every string is built (app_en.arb). The backup dates, the 214-task count and the kept path are examples. No new copy.
- **Design-only:** the Concept E look of the pages, the sheet, the recovery screen (a locked dot on a broken thread) and the toast. Share sheets, save dialogs, file pickers and alerts belong to each system.
- **For the owner:** F7.6 asks for permanent delete with a confirmation. It is not built: tasks leave Trash after 30 days. It is not drawn, because it needs new copy and your OK. The built Trash is a sheet; "the full page with selection" (M3f.7 note) is not built either.
- **Not redrawn:** the Sync sheet (approved in R2-8 and G4-7); Calendars (R2-24); the Mac Settings window pane and File › Export… (ED-081); App lock (R2-24).
- **Board:** canvas x 21860 / 23900, y 215460, 1900 × 7480. Version `1794604340-0b79`; the page then saved `1794604343-db7d`, which only adds the two files to createdOnFiles. Both boards read back equal to local. Snapshot v2.93-working.
- **Status:** proposed for owner review. Nothing built or committed.
- **Update (owner comment on the Android Data and privacy page: "add icons"):** every Android Settings row on R2-21 now has a leading icon in the approved Android root's style: a 40 dp circle in #CFE8E4 with a #062F2C glyph. In light and dark this covers Data and privacy (Sync, Calendars, Export, Trash) and Export (the three formats, Import a backup… and the backups). The Android tablet pane follows. Board height 7560. Version `1794604530-f26a`, made from the live files after checking they matched local. Snapshot v2.94-working.

### ED-319 · R2-21 approved: data safety on every platform (boards E-R2-21, E-R2-21-Dark)
- **Date:** 2026-11-13. **Owner:** "Approve R2-21 and move on to R2-22".
- **Approved:** E-R2-21 and E-R2-21-Dark as drawn (ED-318), with the Android row icons (ED-318 update). This covers:
  - Settings › Data and privacy;
  - Export with the backups kept on the device, and taking a file out;
  - import and restore;
  - Trash as a sheet;
  - the database recovery screen on phones and the web.
- **Still open:** permanent delete from Trash (F7.6) is not built and not drawn. It needs new copy and the owner's OK.
- **Board labels:** "Approved · ED-319"; canvas titles updated. Version `1794604830-da24`.
- Nothing built or committed. Snapshot v2.95-working.

### ED-320 · R2-22 proposed: planning helpers on every platform; one Day shape question (boards E-R2-22, E-R2-22-Dark)
- **Date:** 2026-11-13. **Owner:** "Approve R2-21 and move on to R2-22" (order ED-315).
- **Scope:** as built (11 C2 routines, 11 D2 low energy; docs/09 M3f.6, M11.4, M12.2). Routines, Duplicate day and Copy day as text, and Low-energy mode.
- **Drawn:**
  - **1 · Routines:**
    - the iPhone page, pushed from Settings › Planning, Today's menu or Add, with the phone bar. Each card shows a mini thread, name, summary, step chips, Drop on today and Edit;
    - the week strip picking Fri 14 ("Drop on Fri 14");
    - the empty state;
    - Android;
    - Edit routine as a pull-up: Name, When, steps with colour, length, the free time kept and ↑ ↓ ×; Add step; Delete routine;
    - Drop as the approved proposal (ED-150), where a step that is already there is kept;
    - iPad, with Routines as a sidebar destination in the R2-1 shell and the cards side by side. Mac and web use the same content area.
  - **2 · Duplicate day and Copy day as text:**
    - the month sheet "Copy to which day?" ("Copy which day?" from an empty day);
    - the clipboard text in the built format (✓ done, ○ open, skipped ones left out);
    - the toast texts.
  - **3 · Low-energy mode:**
    - Today with the one dot, Done and Not today, "Later · 5", the once-a-day offer and "Nudges are off until tomorrow's Wake Up";
    - Show what's later;
    - "Move everything optional to tomorrow?" as the proposal, with Move them;
    - Nothing else today;
    - Android;
    - the Settings › Planning row;
    - the Mac and web spread.
  - **4 · Day shape:** a question, not a drawing.
- **Question for the owner (Day shape):** the approved Your day page (ED-084) has a Day shape row, "Morning, focus and evening blocks". The app has no such blocks. The built Day shape rows moved to Wake Up and Wind Down (ED-084, R2-18) and to Appearance (Week starts, Time format).
  - **A (recommended):** remove the row; nothing is lost.
  - **B:** make the blocks a new feature, with new copy and data, which needs the owner's OK and a spec first.
  - The sleep target and night editor are already approved (ED-084, R2-18).
  - **Answered 2026-11-14: A, the row is removed (ED-321).**
- **Copy:** every string is built (app_en.arb). The routines, times and counts are examples. No new copy.
- **Design-only:** the Concept E routine card and mini thread, the low-energy card and ring, the month sheet look. The proposal and the toast are the approved ones.
- **Board:** canvas x 21860 / 23900, y 223140, 1900 × 6000. Version `1794605189-2edf`; both boards read back equal to local. Snapshot v2.96-working.
- **Status:** proposed for owner review. Nothing built or committed.

### ED-321 · Day shape row removed from Settings › Your day (owner chose A; boards E-Phones, E-R2-11 and the Settings root everywhere)
- **Date:** 2026-11-14. **Owner:** "A: remove the row and make sure you update every necessary document and canvas." Answers the ED-320 question.
- **Decision:** Settings › Your day has no Day shape row. The page keeps two groups:
  - "The two ends of your day": Wake Up and Wind Down;
  - "The day itself": Learn my day.
  - Morning, focus and evening blocks are not planned. There is no new copy, data or spec.
- **Why:** the app has no such blocks. Every built Day shape setting already has an approved place:
  - Wake Up, Wind Down, different days, the sleep target and the night are in Wake Up and Wind Down (ED-084, R2-18);
  - Week starts and Time format are in Appearance (ED-161).
- **Canvas** (version `1794612394-b691`; every changed file read back equal to local):
  - **Row removed:** E-Phones and E-Phones-Dark (iPhone Your day), E-R2-11 and E-R2-11-Dark (iPad Your day pane).
  - **Settings root summary:** "Wake Up and Wind Down, day shape, learning" is now "Wake Up and Wind Down, learning" on E-Phones, E-Phones-3, E-PhonesMinimal, E-R2-11, E-R2-18, E-R2-20 and E-R2-21, light and dark.
  - **E-FullA-v2 and E-FullA-v2-Dark:** the Settings stub line "Day shape · Reminders · …" is now "Your day · Reminders · …".
  - **E-Map:** the row is now "Sleep target, night (Day shape row removed, ED-321)", drawn in Settings › Your day › Wake Up and Wind Down.
  - **E-R2-22 and E-R2-22-Dark:** section 4 records the decision in place of the question. R2-22 itself is still proposed (ED-320).
  - **Labels:** E-R2-11, E-R2-11-Dark, E-R2-22, E-R2-22-Dark and E-SettingsReview.
  - **Kept as history:** E-SettingsReview, E-WakeWindDown-Settings-Candidate and E-G3-9b-Screens are approved review boards. They still show the old row; E-SettingsReview's label says it has since been removed.
- **Copy:** no new strings. One design summary line got shorter.
- **Built app:** unchanged. The built Settings › Day shape group maps onto Wake Up and Wind Down and Appearance when the redesign is built (ED-084). Docs that describe the build (02, 14, 15, FEATURE_PARITY_MATRIX, UX_AUDIT, FEATURE_READINESS) are left as they are.
- **Canvas housekeeping:** the page's own save (version `1794608833-416b`) did two things, both kept as the page saved them:
  - cut board titles to 120 characters;
  - set E-R2-19-B and E-R2-19-B-Dark from 9840 to 8000 high.
- **Snapshot:** v2.97-working.
- **Status:** decided. Nothing built or committed.

### ED-322 · R2-22 approved: planning helpers on every platform (boards E-R2-22, E-R2-22-Dark)
- **Date:** 2026-11-14. **Owner:** "Approve, start R2-23".
- **Approved:** E-R2-22 and E-R2-22-Dark as drawn (ED-320), with the Day shape decision (ED-321). This covers:
  - Routines: the page, the week strip, the empty state, Edit routine, Drop as the approved proposal, iPad in the sidebar, Mac and web;
  - Duplicate day and Copy day as text: the month sheet, the clipboard format, the toasts;
  - Low-energy mode: Today, the once-a-day offer, "Move everything optional to tomorrow?" as a proposal, Nothing else today, the Settings row, Mac and web.
- **Board labels:** "Approved · ED-322"; canvas titles updated. Version `1794612660-0037`.
- Nothing built or committed. Snapshot v2.98-working.

### ED-323 · R2-23 proposed: proposal flows and learning on every platform (boards E-R2-23, E-R2-23-Dark)
- **Date:** 2026-11-14. **Owner:** "Approve, start R2-23".
- **Scope:** as built (docs/11 B1 to B3 and A3; docs/09 M10.6, M10.7, M14.2). Four flows: Break it down, Smallest step and Unstick, Help with thinking, and the Reality thread.
- **Drawn:**
  - **1 · Break it down:**
    - the entry is the approved editor (G2-5 D) with no steps, where Break it down sits in the Steps header;
    - the proposal from the on-device model: the lead row ("was 2 h → now 2 h 15"), up to 5 steps (a ring sized by length, a title, a length, More), Add a step, Total, the Smallest step line, Accept, Discard, "Nothing is saved until you accept";
    - a step opened: sub-steps, "depth 2 of 3", Break this down, Remove step;
    - no model: three empty steps and the "Made with simple rules · …" hint; Accept waits until every step has a title;
    - Android;
    - Mac and web as a panel beside the day;
    - the step length picker;
    - Add before the task exists ("4 steps · saved with the task");
    - the Show less hint "Break it into steps?".
  - **2 · Smallest step and Unstick:**
    - Smallest step on the live task, with Start, and the same as a notification;
    - Unstick under a task moved three times, then "Step 1 added to …" with Undo;
    - Android;
    - the Week card's last line.
  - **3 · Help with thinking:**
    - Settings › Data and privacy with a Privacy group;
    - Privacy › Help with thinking with Apple Intelligence off (Open Settings and its iPhone note);
    - the model on, with history cleared;
    - Android with Gemini Nano downloading;
    - every status line, the rules hints and the Brain dump captions.
  - **4 · Reality thread:**
    - Today still learning ("… 6 so far", ×);
    - Reality on: Plan | Reality, the real times, and the insight with OK;
    - the "usually" explanation and the reset confirmation;
    - Settings › Your day › Learn my day before and after the reveal;
    - the toasts.
- **Built behaviour kept:**
  - Only Break it down is a proposal: nothing is written before Accept.
  - Unstick writes one step at once, with Undo.
  - Smallest step only opens Focus.
  - The reality insight writes nothing.
  - Neither cue has a dismiss, and both are hidden while Reality is on.
  - There is no switch for the model or for learning.
- **Design choice for the owner:** a Privacy group under Data on the approved Data and privacy page (R2-21). It holds the built Settings › Privacy page, so Help with thinking has a home. The row label "Privacy" and its subtitle are built strings.
- **Copy:** every string is built (app_en.arb). The tasks, times and counts are examples. No new copy.
- **Design-only:**
  - the step ring and its length chip;
  - the faint plan rings beside moved dots in Reality;
  - "0 of 1" under the task after Unstick.
- **Not drawn:** Android Reality and Learn my day, which use the same rows in M3.
- **Board:** canvas x 21860 / 23900, y 229260, 1900 × 7480 (the canvas caps boards at 8000). Version `1794613342-ed2a`; read back equal to local. Snapshot v2.99-working.
- **Status:** proposed for owner review. Nothing built or committed.

### ED-324 · R2-23 approved: proposal flows and learning on every platform (boards E-R2-23, E-R2-23-Dark)
- **Date:** 2026-11-14. **Owner:** "Approve, start R2-24".
- **Approved:** E-R2-23 and E-R2-23-Dark as drawn (ED-323). This covers:
  - Break it down (the proposal, an opened step, the rules fallback, Android, the Mac and web panel, Add, the Show less hint);
  - Smallest step and Unstick;
  - Help with thinking, including the design choice: a Privacy group under Data on Settings › Data and privacy;
  - the Reality thread and Learn my day.
- **Board labels:** "Approved · ED-324"; canvas titles updated. Version `1794616988-eab7`.
- Nothing built or committed. Snapshot v3.00-working.

### ED-325 · R2-24 proposed: the rest of the app on every platform, plus a German and French pass (boards E-R2-24, E-R2-24-Dark)
- **Date:** 2026-11-14. **Owner:** "Approve, start R2-24".
- **Scope:** as built. This week (the week review), Calendars, App lock, Help and about (Help, Send feedback, About Dottoday, What's new), the web install strip, and a German and French long-string pass.
- **Drawn:**
  - **1 · This week:**
    - the Wind Down card on the week's last day;
    - the sheet: seven dots with done/total, a day's first three tasks, the chips, one pace-and-load sentence;
    - scrolled: the carry card (Place or Leave in Inbox), the share image, Show task titles, Share image, "No streaks here — just what happened.";
    - Place as the approved proposal, with "Place them";
    - the share image with titles, the toasts.
  - **2 · Calendars:**
    - not asked yet; connected (device calendars and a Google account, with Read-only marked);
    - scrolled: Send changes back, When the day shifts, Travel time;
    - the Disconnect alert, access off, the three strips above every screen, the onboarding row.
  - **3 · App lock:**
    - at the top of Privacy (Settings › Data and privacy › Privacy, ED-324);
    - Lock after, the locked screen, the app-switcher cover;
    - the web's "Uses your computer's lock".
  - **4 · Help and about, and installing on the web:**
    - Settings › Help and about (Help, Siri & Shortcuts, About Dottoday, Send feedback; Privacy moved to Data and privacy, ED-324);
    - Help, Send feedback (with the diagnostics preview), About Dottoday, What's new, the update strip;
    - the web install strip (Chrome and Edge only).
  - **5 · German and French:** the tab bar, the four sheet buttons, the proposal footer, the carry card, toasts and the install strip, in built German and French.
- **Built behaviour kept:**
  - Place is a proposal; Leave in Inbox and the carry toast have Undo.
  - The share image has no titles unless switched on.
  - Feedback is a mail draft and never includes what tasks say.
  - App lock is per device and off by default; the web has no switch.
  - There are no "Add to Home Screen" instructions for Safari; none are built.
- **Flags for the owner:**
  - **The Calendar tab has no built string.** The approved tab (ED-069, ED-075) shows "Calendar" in every language. A new key with German and French text is new copy and needs your OK.
  - **French "Boîte de réception" does not fit the tab.** It wraps to two lines at 10 pt. The options are two lines, or a shorter tab-only string, which is new copy.
  - **Two built texts are out of date, in English, German and French:**
    - 1.2.0's release note says "Settings › Day shape", which no longer exists (ED-321);
    - the Help answer "How do I move a task?" says "drag its edges", but edge resize was removed (ADR-0015).
- **Copy:** every string is built (app_en, app_de, app_fr). The tasks, counts, account and calendar names are examples. No new copy.
- **Design-only:**
  - the week dots and the share card look;
  - the big teal dot on the locked screen.
- **Board:** canvas x 21860 / 23900, y 236860, 1900 × 7740. Version `1794617467-5316`; read back equal to local. Snapshot v3.01-working.
- **Update (owner comment "make this a proper dottoday", 2026-11-14):** the locked screen and the app-switcher cover now show the Dottoday brand mark (ED-011: the Today ring with its filled centre) in place of a plain teal circle. The built lock screen draws a filled day dot; matching the mark in the app is a build follow-up. Version `1794618113-c456`. Snapshot v3.02-working.
- **Update (owner comment "add the + sign", 2026-11-14):** the German and French tab-bar samples now carry the approved + button (copied from E-Phones), not a blank circle. Version `1794618531-aceb`. Snapshot v3.03-working.
- **Status:** proposed for owner review. Nothing built or committed.

### ED-326 · R2-24 approved: the rest of the app on every platform (boards E-R2-24, E-R2-24-Dark)
- **Date:** 2026-11-14. **Owner:** "Approve R2-24".
- **Approved:** E-R2-24 and E-R2-24-Dark as drawn (ED-325), with the two comment updates: the Dottoday brand mark on the locked screen and the cover, and the + on the German and French tab bars. This covers:
  - This week: the review, carrying unfinished tasks, sharing;
  - Calendars;
  - App lock;
  - Help and about, Send feedback, About Dottoday, What's new;
  - the web install strip;
  - the German and French long-string pass.
- **Still open (copy, for the owner):**
  - a string for the Calendar tab in every language;
  - French "Boîte de réception" on the tab: two lines or a shorter tab-only string;
  - the out-of-date "Settings › Day shape" release note and "drag its edges" help answer, in English, German and French.
- **Build follow-up:** the built lock screen draws a filled day dot; it should draw the brand mark (ED-011).
- **Board labels:** "Approved · ED-326"; canvas titles updated. Version `1794619149-7595`.
- **Round 2:** every board in the plan is drawn and approved (R2-1 to R2-24). The account screens wait for CR-160.
- Nothing built or committed. Snapshot v3.04-working.

### ED-327 · Copy decisions from the German and French pass: Calendar tab label, French "Boîte", the move answer
- **Date:** 2026-11-14. **Owner** (answers to the three ED-325 questions): Calendar tab "Calendar / Kalender / Calendrier"; French Inbox tab "Boîte" on the tab only; fix the out-of-date texts in a separate PR.
- **Decisions:**
  - **Calendar tab label:** a new tab-label string: EN "Calendar", DE "Kalender", FR "Calendrier". It is added to the ARB files when the Concept E tab bar is built (the built app's tab is still Week).
  - **French Inbox tab:** a tab-only string "Boîte". Screen titles, toasts and buttons keep "Boîte de réception". German "Eingang" and English "Inbox" are unchanged. Tab labels stay on one line.
  - **"How do I move a task?" (`helpMoveA`):** it still says to drag a task's edges, but edge resize was removed (ADR-0015). It is out of date in the app today, so it is fixed now, in all three languages, in its own PR from main (session "help-move-copy").
  - **Release note 1.2.0 ("Settings › Day shape"):** correct for the app as built today. It changes only when the redesign's Settings is built (ED-321), so it is left alone now and recorded here for that build.
- **New copy approved:** the Calendar tab label (three languages) and the French tab-only "Boîte". The new move-answer wording is reviewed in its PR.
- **Board:** E-R2-24 and E-R2-24-Dark section 5 now show "Kalender", "Calendrier" and "Boîte" on the tab bars, and the findings read "Decided". The Help and What's new notes say what happens to each text. Board height is now 7760. Version `1794619797-a65a`. Snapshot v3.05-working.
- Nothing built. The PR is the only app change.

### ED-328 · R2-25 approved: moving tasks (touch drag, tablet pointer, swipe) (boards E-R2-25, E-R2-25-Dark)
- **Date:** 2026-11-14. **Owner:** "lets work on these" (the platform and edge-state gaps from the Round 2 close-out audit), then "Approve both".
- **Gap pass:** R2-25 to R2-31 draw the platform gaps and missing edge states the close-out audit found (presented 2026-11-14). R2-25 is the first.
- **Approved as drawn, all built behaviour and strings:**
  - **Touch drag on phones (iPhone and Android):**
    - a 250 ms hold lifts the row (a mouse lifts at once); the row stays dimmed; the dot follows the finger with its time range;
    - the landing preview on the thread; overlaps allowed, with the knot only after the drop;
    - "Shift later tasks" and "Calendar events too";
    - drop targets: the Wake Up cap ("All day"), the Trash bin (ink, never red) and the Inbox tab;
    - the drop toasts with Undo; haptics, auto-scroll, cancel by letting go; screen readers use Select then Move.
  - **Tablets:** iPad touch drag to Wednesday with the drop box and "Wed · 11:00 – 11:45 AM"; the pointer hover tint and pointer drag (ED-116); an Android tablet Inbox task dragged onto Thursday.
  - **Swipe actions:** phone Inbox rows only; start → end Move to Trash, end → start Schedule; Android the same, with the first-row hint.
- **Not built, so not drawn:** an overlap preview while dragging; Esc or Back to cancel a drag.
- **Board labels:** "Approved · ED-328"; canvas titles updated. Published `1794675893-d525`; labelled `1794676731-c464`.
- Nothing built or committed. Snapshot v3.06-working.

### ED-329 · R2-26 approved: time states (overrun, Now through the day, Focus past its end) (boards E-R2-26, E-R2-26-Dark)
- **Date:** 2026-11-14. **Owner:** "Approve both". Part of the gap pass (ED-328).
- **Approved as drawn, all built behaviour and strings:**
  - **Past the planned end, on Today:** the live card becomes an ordinary row, "9:00–11:00 AM · not done", muted, never red and never "late"; "Need more time?" with "… ended 12 min ago", Catch up and Not now; the Running late sheet (How late +5 / +15 / +30; Shift the rest, Skip, Shorten); the optional "Ended 12 minutes ago. Done?" alert; Reality view; widgets and the Live Activity.
  - **Now through the day (design choice, approved):** the minimal Now view follows the built rule of the widgets and the Mac menu bar (Now, then Next up, then Nothing else today). At 6:30 it shows the approved Wake Up card (R2-19); between tasks, Next up with "{duration} free"; after an overrun, Next up with the unticked tasks under Earlier, "· not done". iPhone and Android.
  - **Focus past its end:** nothing ends by itself; the ring holds full, "0 min left", step timer 0:00; Done and +15 toasts. iPhone and Android.
  - **Mac menu bar after the end:** "Next up · Lunch · 12:30 PM"; Done and +15 min leave with the live task.
- **Not built, so not drawn:** a pause in Focus; the floating Mac Now window (ED-066); any minutes-over display.
- **Board labels:** "Approved · ED-329"; canvas titles updated. Published `1794676675-6dcb`; labelled `1794676731-c464`.
- Nothing built or committed. Snapshot v3.06-working.

### ED-330 · R2-27 approved: day states and task sheets (boards E-R2-27, E-R2-27-Dark)
- **Date:** 2026-11-14. **Owner:** "Approve R2-27". Part of the gap pass (ED-328).
- **Approved as drawn, all built behaviour and strings:**
  - **Every task done:** "9 of 9 done", then the Day review with "Nothing left to move" and Not now; no celebration, no score.
  - **A past day:** the "● Today" pill; no banner and no prompts; "· not done" on unticked tasks; a dashed, faded dot and muted title for a skipped task; free time without "add here"; drag and Done still work.
  - **Three overlapping tasks:** a chain of pairwise knots. Dense days are not compacted (built).
  - **All-day items:** tinted chips above the day, scrolling sideways, with no limit.
  - **Empty today on Android:** "Nothing planned · 16 h free", the empty line, Add to this day, Pull from inbox · 3, Copy a day…; the empty Wake Up card ("Nothing planned yet", Plan today, Later).
  - **Task sheets:** a done task (Not done tile); a past task not done (Shift the rest off); a calendar event, editable, with "Changes go back to Work" or "From Work · changes stay in Dottoday"; five alerts (Add chips off, "Up to 5 alerts").
- **Not built, so not drawn:** a compact dense day; a custom alert time; the minimal "Rest of today" on Android (the approved iPhone frame is the reference).
- **Board labels:** "Approved · ED-330"; canvas titles updated. Published `1794677213-2a3d`; labelled `1794677692-fe49`.
- Nothing built or committed. Snapshot v3.07-working.


### ED-331 · R2-28 approved: small states (boards E-R2-28, E-R2-28-Dark)
- **Date:** 2026-11-14. **Owner:** "Approve R2-28". Part of the gap pass (ED-328).
- **Approved as drawn, all built behaviour and strings:**
  - **Move to a day:** the "Move to" sheet with the month view; days that have tasks carry dots.
  - **No free slot:** the Inbox schedule sheet when nothing fits the chosen day.
  - **Quiet week:** "A quiet week: nothing was planned.", empty rings, the "0 of 0 done" chip and the share card.
  - **No search results:** "No matches for “…”", "Try fewer words, or another filter.", Show all and Recent.
  - **Calendars:** the iOS permission alert with the Info.plist reason; the load error "This didn't load" / "Your tasks are safe on this device." with Try again.
  - **Missions:** no sensor on this phone, access blocked in the phone's settings, "Needs at least two dots that day.", backup mission None.
  - **Small toasts:** the short confirmations for these flows.
- **Not built, so not drawn:** a "Date…" option in the picker; progress for export, import or connecting a calendar.
- **Board labels:** "Approved · ED-331"; canvas titles updated. Published `1794678088-9fe6`; labelled `1794680077-7abc`.
- **Owner comment "add icons" (2026-11-14):** each mission row now has an icon from the app's own task icons (stand up, walking, light bulb, lungs, a target for Catch the dot, a star for one thing), marked Design-only because the built picker is text only. Board height 2800. Published `1794680533-0511`.
- Nothing built or committed. Snapshot v3.08-working.


### ED-332 · R2-29 approved: Android parity, and one icon per Settings row everywhere (boards E-R2-29, E-R2-29-Dark)
- **Date:** 2026-11-14. **Owner:** "Approve R2-29". Part of the gap pass (ED-328).
- **Approved as drawn on Android, all built behaviour and strings:**
  - **Minimal Settings:** the nine rows with Layout first, Check it works below; Everything else… with Search first.
  - **Learning and Reality:** Settings › Learning status rows (no switch; Energy suggestions is the one switch, off until 20 high-energy tasks); the caption before the reveal; Reality on with a Material Plan | Reality segmented button and the insight.
  - **Launcher shortcuts:** long-press shows Add task and What's next, both with the app icon. iPhone has no Home Screen quick actions.
  - **Help and about:** Help, About Dottoday, Send feedback (no Siri row on Android); Help's Wake Up answer adds Android's alarm line; About shows "1.2.0 (4)".
  - **Calendars:** device calendars switch off (no Disconnect); access off shows "Open your device's Settings, find Dottoday and allow access to Calendars."; Disconnect as a Material dialog.
  - **App lock:** Privacy with Lock Dottoday and Lock after; the system unlock sheet with "Unlock Dottoday" and PIN fallback; a failed try leaves the locked screen; Recents shows a blank card while the lock is on.
  - **Duplicate day:** the Day menu, Copy to which day? (copies at once, no confirm), "Copied 8 tasks" with Undo; one-off tasks only.
- **Settings icons (owner comment "add icons and make sure they are always consistent…"):** every Settings row has an icon, and each setting has one glyph and one colour on every platform. Source: the approved iPhone tile where one was drawn, otherwise the app's own SettingsRow glyph and tint. Shape follows each platform's approved anatomy: a 30 px rounded tile on iPhone, iPad, Mac and web (22 px in the Mac toolbar), a 40 px circle on Android; Android circles now take each setting's colour instead of one teal. Wind Down reminder is the bell everywhere (R2-20 had a moon). Dark Appearance tiles fixed. Status and list rows (calendar colour dots, backup dates, export formats, mission choices, notification health state) keep what they show. Applied to E-Phones, E-Phones-3, E-PhonesMinimal, E-FullA-v2, E-R2-11, E-R2-18, E-R2-20, E-R2-21, E-R2-24, E-R2-28 and E-R2-29, light and dark; no board height changed. Decision and review boards (G-series, Settings review, candidates) are left as records. Published `1794683197-e908`.
- **Copy:** the Help Wake Up answer still says "Settings › Day shape" (stale; for the separate copy PR). **2026-11-15 (ED-344):** the replacement line is approved.
- **Not built, so not drawn:** long shortcut labels; copying to several days or picking tasks to copy; Duplicate day in minimal.
- **Board labels:** "Approved · ED-332"; canvas titles updated. Published `1794681007-f605`; labelled `1794683410-0978`.
- Nothing built or committed. Snapshot v3.09-working.

### ED-333 · R2-30 approved: Mac and web parity (boards E-R2-30, E-R2-30-Dark)
- **Date:** 2026-11-14. **Owner:** "Approve R2-30". Part of the gap pass (ED-328).
- **Approved as drawn, built content inside the approved shell (E-FullA-v2, E-Minimal):**
  - **Search:** Mac with results grouped by day (Today first, Inbox with Schedule) and the seven filters; web with no results, Show all and Recent.
  - **Routines:** the Mac page with Edit, Drop on today, New routine and the alarm note.
  - **Focus:** the whole window on Mac and web (ED-285); web's Deep work points to the computer's Do Not Disturb.
  - **Settings panes:** Trash as a centred dialog with Restore; Help and about (no Siri row); Calendars (Mac reads its own; web Google and Microsoft only); Privacy with App lock.
  - **3 days and Month:** 3 days on the hour canvas (yesterday, today, tomorrow); Month as cards with titles, +N more, N of N done and Light day.
  - **Minimal on wide:** Inbox with the next free slot and Place, Calendar as the month, Search unchanged.
  - **Menus and copying:** Edit (Undo, Redo, Delete, no keys shown) and Window (system items); Copy to which day? as a centred dialog, then "Copied 8 tasks" with Undo.
- **Design-only:** the Workspace sidebar, the Settings window and the 3 days tab are the approved design (in the app, Settings is a page and 3 days is Today's spread); Search or run results are drawn but the palette is not built.
- **Code gap:** minimal Inbox at expanded width still shows the full Inbox (Drop onto today, Auto-plan); docs/14 §3 says next free slot and Place only.
- **Icons:** the Mac Settings toolbar now shows General (teal person) and Help (the Help and about icon), completing ED-332.
- **Board labels:** "Approved · ED-333"; canvas titles updated. Published `1794684549-bd33`; labelled `1794684721-7d89`.
- Nothing built or committed. Snapshot v3.10-working.

### ED-334 · R2-31 approved: tablets, windows, folds and browsers (boards E-R2-31, E-R2-31-Dark); the gap pass is complete
- **Date:** 2026-11-14. **Owner:** "Approve R2-31". Last board of the gap pass (ED-328).
- **Approved as drawn, on the approved R2-1 tablet frames and the R2-7 toast:**
  - **Stage Manager:** the layout follows the window: an 820-wide window gets the iPad top tabs (medium), 1180 the sidebar and Workspace (expanded), under 600 the phone layout (as Split View ½).
  - **Foldable:** unfolded flat and tabletop are medium with the rail; folded is the phone.
  - **Undo toast at medium width:** centred on the content area, beside the rail and never under it, on iPad, Android tablet and the unfolded foldable; dark as approved in R2-7.
  - **Tablet browsers:** iPad Safari in landscape shows the web Workspace; Android Chrome in portrait shows the rail, as the native app at the same width (ED-172).
- **Code gap:** the app reads no display features, so content runs across a hinge in both postures; the approved rule (no pane or text across a hinge, ED-099, ED-110; tabletop as compact, ED-168) needs a code task.
- **Board labels:** "Approved · ED-334"; canvas titles updated. Published `1794685110-14bf`; labelled `1794685183-e302`.
- **Gap pass complete:** R2-25 to R2-31 approved (ED-328 to ED-334). Code gaps found along the way: Search or run not built (ED-333), minimal Inbox at wide widths (ED-333), hinge awareness (ED-334), the stale "Day shape" Help text (ED-332).
- Nothing built or committed. Snapshot v3.11-working.

### ED-335 · Round 2 close-out audit recorded
- **Date:** 2026-11-14. **Owner:** "close out the audit findings". The four-check audit of 2026-11-14 (every open row against the live boards and the log) and the gap pass that answered it.
- **Closed by the gap pass (R2-25 to R2-31, ED-328 to ED-334):** every platform gap in the audit's §2 (touch drag and pointer states; Android swipe, empty day, minimal Settings, Reality and learning, shortcuts; Mac and web Search, Routines, Focus, Trash, 3 days, Month, minimal Inbox, Calendar and Search, Search or run results, Edit and Window menus; Help and about, Calendars, App lock and Duplicate day off iPhone; Stage Manager, the foldable, the Undo toast at medium width, tablet browsers) and every edge state in §3 except those not built.
- **Not built, noted on the boards:** Focus paused, a first-week Week in review, a compact dense day, a custom alert time, progress for export, import and calendar connecting.
- **Still to design (audit §1):** Settings › Planning, Sound and Siri & Shortcuts pages; Past days and the year strip; Pick today's one thing from the Day menu; Rebalance (result, before and after, pin, drag chip); the Mac and web Add popover with live chips (CR-069); the Mac and web Go to date popover (CR-082); spoken Brain dump; the Wake Up explainer page (ED-099). Also the tasks-before-Wake-Up fold and phone landscape. Consistency report: CR-048, CR-069, CR-081 to CR-084 are design fixes.
- **Still needs the owner (audit §4):** permanent delete from Trash (F7.6, new copy); the R2-19-B tablet alarm rows and tablet missions added after approval; Catch the dot (four dots, three taps, "Tap the blue dot"); "Plan from Inbox · 3" on the Full empty day; Today on launch scrolled to now; the "After" label clash; the Mac context menu's two item sets ("Delete ⌫" and "Move to Trash ⌘⌫"); the sync heading read twice (ED-190); the optional web-storage line (ED-191); the iPhone signing exception (ED-263); onboarding before build (ED-305: the 13+ age note, three new strings, a build go-ahead); before build: the isolated Supabase proposal (Q9), Wind Down past midnight (Q8), web push (Q11) and calendar webhooks (Q13) setup, the Wake Up plugin approval, the device-list table (must-ask schema). **Answered since the audit:** the R2-20 Android row icons (ED-332).
- **Blocked (audit §5):** account screens wait on CR-160 ([ilearncloud9/dottoday#75](https://github.com/ilearncloud9/dottoday/pull/75), still a draft). The Help move answer is done: [ilearncloud9/dottoday#76](https://github.com/ilearncloud9/dottoday/pull/76) is merged.
- **Records brought up to date (audit §6):** the tablet checklist (header, every §3 row, §5 coverage); traceability (B.1 proposals and C parity rows marked with what settled them, 103 rows; section D gaps; the missing R2-1 to R2-24 log); the screen inventory (§2 rewritten, 57 rows marked "Designed in Round 2", §3 and §4 notes); the consistency report (19 Round 2 rows: 12 resolved, 6 design fix, 1 waiting on CR-160); STATUS and the handoff; this file's pending answers. Canvas: E-Minimal's Show everything note now says the Workspace (ED-073) and its status-item menu is redrawn as approved on R2-17 (ED-309; published `1794691027-7d03`); four G3-6 and G4-7 board titles no longer say "open" or "for your review" (published `1794687460-0165`).
- **The R2-19-B split, recorded:** boards cut off at 8,000 px are split: E-R2-19-B now ends at 6,640 px and E-R2-19-B-2 (light and dark) holds the rest, unchanged in content. Approved with R2-19 (ED-314); the tablet rows on it are still the open question above.
- **Code gaps found by the gap pass:** Search or run not built (ED-333); minimal Inbox at wide widths shows the full Inbox (ED-333); no hinge awareness (ED-334); the Help Wake Up answer says "Day shape" (ED-332), which matches today's app until the Your day restructure ships.
- **Release gate (ED-238):** Concept E stays LEADING CANDIDATE — NOT APPROVED FOR PRODUCTION IMPLEMENTATION until the owner approves it as a whole; the open items above are what stands between Round 2 and that approval.
- Nothing built. Snapshot v3.12-working.

### ED-336 · Owner answers to the close-out decisions
- **Date:** 2026-11-15. **Owner:** answered the ED-335 "still needs the owner" list in four batches.
- **Permanent delete from Trash (F7.6):** each Trash row gets Delete now with a confirm, plus an Empty Trash action with its own confirm. Confirm buttons in ink, never red. New copy, to be drawn and reviewed.
- **R2-19-B tablet rows:** approved: tablet ringing, snoozed and the tablet mission screens. **Owner:** "the missions for the tablet should be missions that does not require movement" — on tablets only Breathe, Catch the dot and Pick today's one thing are offered; Stand up, Walk and Light stay phone-only. The tablet mission screens are redrawn to that set.
- **Catch the dot:** approved with a tweak: four dots without red, 3 taps, "Tap the blue circle" (shape and colour, not colour alone).
- **Empty day Inbox button:** kept in Full, hidden in Minimal, labelled with the built "Pull from inbox · {count}" everywhere; boards that say "Plan from Inbox" are relabelled.
- **Today on launch:** opens scrolled so the current task is in view, on today only, every platform; with Reduce Motion it jumps.
- **The "After" label clash:** two specific labels, e.g. "Offer after" and "Check after" (new strings in every language, shame-free).
- **Mac context menu:** "Move to Trash ⌘⌫" in every Mac context menu (ED-162 confirmed); ⌫ on a picked task still trashes; the Edit menu keeps "Delete". Old boards are relabelled.
- **Sync heading (ED-190):** the owner's words stay on screen; the heading is hidden from the screen reader so it is read once.
- **Web storage line (ED-191):** dropped; Sync details stays the one place for the warning.
- **iPhone signing (ED-263):** no exception; the CR-121 rerun is on a throwaway iOS 26.5 Simulator.
- **Onboarding (ED-305):** the 13+ age note is a footnote on the last step ("You're in") (**since:** moved to Hello and reworded, ED-351); "Skip for now" approved; the built "Five is plenty to start with." is reused. The build go-ahead itself stays behind the release gate (ED-238).
- **Wind Down past midnight (Q8):** extend the day model now so Wind Down can cross midnight (docs/05 change before the build), not the 24:00 cap.
- **Wake Up plugin:** approved: the in-repo Android plugin package for the double-ring fix (branch `fix/wake-up-background-bridge`), with an ADR line.
- **Device-list table:** approved: a new migration with RLS policies and tests, local only; any push to the hosted project is asked again.
- **Isolated Supabase for tests (Q9):** write the proposal; nothing is created until it is approved.
- **Still open from ED-335:** the release gate itself, and Q11 (web push) and Q13 (calendar webhooks) setup, which stay gated on the hosted project.
- Nothing built.

### ED-337 · R2-32 approved: the owner's answers drawn (boards E-R2-32, E-R2-32-Dark), with their new copy
- **Date:** 2026-11-15. **Owner:** "Approve R2-32".
- **Approved as drawn:** Trash with Delete now on every row beside Restore and Empty Trash under the list, each with a confirm whose button is ink (iPhone alert, Android dialog, a centred dialog on Mac and web); Today opening scrolled to the current task on today only (Reduce Motion jumps); Settings › Wake Up options with Offer after and Check after; Settings › Missions on tablets offering only Breathe, Catch the dot and Pick today's one thing.
- **New copy approved:** "Delete now", "Empty Trash", "Delete “{title}” now?", "It can't be restored after this.", "Delete", "Empty Trash?", "{count} tasks will be deleted. They can't be restored after this.", "Trash emptied", "Offer after", "Check after", "On your phone; it needs you to move". With ED-336: "Tap the blue circle".
- **Applied on other boards (ED-336):** Move to Trash ⌘⌫ (E-FullA-v2, E-Minimal, E-G4-3-Narrow, E-DF3); "Pull from inbox · 3" (E-Phones, E-G4-7-States); "Check after 10 min" (E-Phones); Catch the dot without red and tablet missions labelled (E-R2-19-B, E-R2-19-B-2); the onboarding prototype's 13+ note on the last step, "Skip for now", "Five is plenty to start with." (prototype version `1794702516-e90b`).
- **Owner comment on R2-19-B ("increase this circles and make sure is proportional and aligned"):** the Catch the dot circles are 72 instead of 56 and their four shapes share one optical size, centred (published `1794703083-ed7b`). Owner follow-up ("go with your recommendation"): 96 on tablets (iPad and Android tablet frames on E-R2-19-B-2), 72 on phones.
- **Board labels:** "Approved · ED-337"; canvas titles updated. Published `1794702554-ecfa`.
- Nothing built. Snapshot v3.13-working.

### ED-338 · R2-33 approved: Settings › Planning, Sounds, and Siri & Shortcuts (boards E-R2-33, E-R2-33-Dark); title icons; Android mirrors iPhone
- **Date:** 2026-11-15. **Owner:** "Approve R2-33". First board for the audit's never-drawn screens (ED-335 §1).
- **Approved as drawn, built rows and strings:** Settings › Planning (Default duration, Routines, Snap to, Shift later tasks, Show free time, Running-late nudge, Ask when a dot hasn't started, Plan-your-inbox nudge, Roll unfinished to tomorrow, Low-energy mode) on iPhone, Android and the Mac Settings window, with the Shift later tasks sheet; Settings › Reminders › Sounds (task reminder sound list, Start and Done sounds, Sounds in app, Haptics in app, footer and credit) on iPhone and Android, with the Start sound picker; Siri & Shortcuts on iPhone only (five phrases, Open Shortcuts).
- **Owner comment "Add Icons to this and every other settings screen like this across the platforms":** every Settings page title carries its page's icon (the same glyph and colour as the row that opens it): a tile beside iPhone and iPad large titles and web headings, a circle in Android's top app bar. Applied on E-Phones, E-Phones-3, E-R2-11, E-R2-18, E-R2-20 to E-R2-24, E-R2-28 to E-R2-30, E-R2-32, E-R2-33 and E-FullA-v2, light and dark. The Mac Settings window keeps its toolbar icons unchanged (owner: "the current mac icons … looks good already"). The root Settings page keeps a plain title.
- **Owner comment "always design using the android natives to look same":** every Android screen mirrors the iPhone screen's structure (intro, groups, captions, order, cards, icons) with Android-native components (Material rows, switches, radio buttons). R2-33's Android Planning and Sounds are redrawn that way; earlier flat Android lists (parts of R2-20, R2-21) are offered for a redo.
- **Copy flag, still open:** the built row "Running-late nudge" says "late", which the no-shame rule bans; a replacement (e.g. "Need-more-time nudge") needs the owner's word. **2026-11-15 (ED-348):** the owner keeps the built row; recorded exception.
- **Board labels:** "Approved · ED-338"; canvas titles updated. Published `1794703763-6adf`, title icons `1794704500-f84e`, Android redraw `1794704682-10ad`.
- Nothing built. Snapshot v3.14-working.
### ED-339 · R2-34 approved: Past days, the year strip and Pick today's one thing (boards E-R2-34, E-R2-34-Dark)
- **Date:** 2026-11-15. **Owner:** "Approve R2-34". Second board for the audit's never-drawn screens (ED-335 §1).
- **Approved as drawn, built strings only (no new copy):** Past days as the way in from an empty Search ("Every day you planned, as it went"); the Past days list (every planned day of the last 12 months, newest first, "N of N done", its dots and "+N more"); a search inside it ("When did I last…": the newest match, how long ago, on how many days); the Year strip (twelve rows of month-grid completion dots, "dottoday", Share image) on iPhone, Android (the same page in Material, Year strip in the top app bar) and Mac/web (one 640 column, `/#/search`). Pick today's one thing from the Day menu ("What matters most today?", "Tap one. Every answer is right.": today's dots, then the Inbox), the one-thing ring and "· Your one thing" after the pick, and the empty case ("Nothing to pick from yet. Plan a dot or two first."), on iPhone, Android (the same sheet in Material) and Mac/web (a centred dialog).
- **Board labels:** "Approved · ED-339 · 15 Nov 2026"; canvas titles updated. Published `1794705092-2cfa`, approved `1794708329-c088`.
- Nothing built. Snapshot v3.15-working.

### ED-340 · Android uses a modal bottom sheet wherever iPhone uses a pull-up (E-Phones, E-Phones-2, E-Phones-3, light and dark)
- **Date:** 2026-11-15. **Owner comments on E-Phones-2:** "can you make this android screen a pull up just like on iphone, using all the android natives needed" and "just do this for every screen that iphone also has as a pull down. they should be matching but with their separate natives".
- **Rule:** an Android screen whose iPhone twin is a pull-up sheet is an M3 modal bottom sheet over the screen it came from: scrim, 28 dp top corners, drag handle, then the same × / title / action row and content. A screen that is a page on iPhone stays a page on Android. Tablets keep their side sheets and dialogs.
- **Converted:** E-Phones-2 the proposal (first, `1794705464-812e`), FAB menu › Brain dump, FAB menu › Routine; E-Phones Add: Create task (keyboard inside the sheet), Edit Weekdays (over Wake Up and Wind Down), the task editor (the partial sheet expands to a full-height sheet; Predictive Back steps down); E-Phones-3 Create task, Colour and icon, All colours, back on Create task (the colour sheets stack on the Create task sheet). Published `1794708101-4366`.
- **Already sheets, unchanged:** Day review, Schedule from the Inbox, Trash, Empty Trash confirm, Break it down, Copy to which day?, Pick today's one thing, the minimal task sheet.
- Supersedes the "full screen" Android wording of ED-141, ED-148, ED-149 and ED-150 for these frames; content and strings unchanged. Nothing built.

### ED-341 · R2-35 approved: Rebalance (boards E-R2-35, E-R2-35-Dark); Android Appearance as grouped cards
- **Date:** 2026-11-15. **Owner:** "Approve R2-35". Third board for the audit's never-drawn screens (ED-335 §1).
- **Approved as drawn, built strings only (no new copy):** the Rebalance plan (11 C1, docs/09 M11.1): "Need more time?" › Catch up opens it when a task is more than 10 min over; the day now (faded) and proposed (outlined), each change labelled "shifted +N", "pinned · untouched", "shrunk to N", "moved to tomorrow …" or "moved to Inbox"; "N free" and "Wind Down · time"; the rules Shift followers, Allow shrinking optional and Push past Wind Down, which make the plan again; × keeps a task as it is; Accept plan, Discard, "Nothing moves until you accept · Undo for 30 s after"; "Plan accepted" with Undo. The calendar trigger (M11.1b): "Calendar changed · {title} moved to {time} · Rebalance?" with Not now, and the plan it opens. Android as an M3 modal bottom sheet (ED-340) with filter chips; Mac and web as a centred panel; minimal mode as before and after only (design-only, docs/14 §3 Simplified). The drag chip is the approved "Shift later tasks" chip (R2-25).
- **Copy flag, still open:** the sheet's built title is "Running late" (`runningLate`), which the no-shame rule bans. Proposed: reuse the built "Need more time?" (`lateNudgeTitle`). Together with the ED-338 "Running-late nudge" flag, this needs the owner's word. **2026-11-15 (ED-348):** the owner keeps "Running late"; recorded exception.
- **Owner comments on E-Phones-3 ("add icons to the android settings like the other platforms have", "make sure is consistent"):** Android Appearance (Everything, Layout · Less, Edit palette) now carries the Appearance icon in its top app bar and follows the iPhone page: Layout, Theme, App colour and Format as grouped cards, the App colour caption, and Format with Language, Time format and Week starts on and their icons. The Android tablet Appearance pane (E-R2-11) gets the same icon and cards; every other Android Settings title already had its icon.
- **Board labels:** "Approved · ED-341 · 15 Nov 2026"; canvas titles updated. Published `1794708797-bb77`, Appearance `1794709091-e6f9`, approved `1794709339-a505`.
- Nothing built. Snapshot v3.16-working.

### ED-342 · R2-36 approved: the Mac and web Add popover with live chips, and Go to date (boards E-R2-36, E-R2-36-Dark); Year strip option B proposed
- **Date:** 2026-11-15. **Owner:** "Approve R2-36". Fourth board for the audit's never-drawn screens (ED-335 §1); closes CR-069 and CR-082.
- **Approved as drawn, in the approved Mac Week and web Day windows:** Add opens as a popover from medium width (⌘N or the toolbar +, web Add or `n`): Task · Brain dump · Routine, the title field with its dot, "What is it?" and "Type a time too: ‘Go shopping 5pm 1h’"; each word read as a day, time or length becomes a chip with × ("Remove “6pm”"), the summary and "Free until … · no overlap" or "Overlaps … · you can still add it" follow the typing, duration chips, Add to Inbox instead, Add; pasting several lines asks "Add 3 tasks?" with Keep as one and Add 3. Go to date opens the approved month component (ED-075) under the date button: dots per day, the shown week tinted, today ringed, ‹ ›, Today and "{month} · N of N days planned"; keyboard arrows, Page Up/Down, Return, Esc; the web day URL `/#/plan/day/…`. Built strings, except "Go to Date… ⇧⌘G" from the approved menu caption (design-only).
- **Base windows:** the Mac Week window drops its open Lunch context menu and the web Day window its open Day menu, so only the popover is open.
- **Owner comment on R2-34 ("redesign this with a different concept but blends good"):** Year strip option B is added to R2-34 as Proposed: the year as twelve month dots that fill like task dots (days planned per month), the month in progress dashed, a tapped month opening its days below, Share image; iPhone and Android, built strings only. The approved strip stays; the owner chooses. If B is chosen it needs a change to `year_strip.dart`. R2-34 grew to 4140 and R2-35 and R2-36 moved down on the canvas.
- **Board labels:** "Approved · ED-342 · 15 Nov 2026"; canvas titles updated. Published `1794709748-21a5`, option B `1794709935-133b`, approved `1794712563-d65a`.
- Nothing built. Snapshot v3.17-working.

### ED-343 · R2-37 approved: spoken Brain dump on every platform (boards E-R2-37, E-R2-37-Dark)
- **Date:** 2026-11-15. **Owner:** "Approve R2-37". Fifth board for the audit's never-drawn screens (ED-335 §1); closes CR-083.
- **Approved as drawn, on the approved Brain dump sheets (E-Phones-2) and the Mac and web Brain dump blocks (E-FullA-v2):** where the language has on-device speech the hint is "Type or tap the mic. One thing per line."; the first tap asks once with Dottoday's reason (iOS and macOS: microphone, then speech recognition, with the Info.plist texts; Android: "Use the microphone?" with Not now and Continue before Android's own dialog, D5); while listening the mic becomes the breathing accent dot ("Stop dictation"), still under reduced motion, and "Pause, or say “next”, to start a new task." sits under the field; the first time it listens, the "Speak your list" tip shows once (× is Don't show again); a stop for another reason says "Dictation stopped. Tap the mic to go on." and keeps the lines; a refused microphone shows "Microphone is off for Dottoday" with Open settings, quiet, never red. Spoken lines plan like typed ones (proposal, written only on Accept). Android is the bottom sheet (ED-340).
- **Web:** Chrome with on-device speech gets the Dictate button in the approved web block (design-only addition, as on Mac); other browsers get no mic and "Everything on your mind, one thing per line"; the system's own dictation still works. Nothing is sent to a speech server (D1).
- **Hint text:** with the mic available the Mac and web block hint is the built "Type or tap the mic. One thing per line.", replacing the approved block's "Everything on your mind, one per line".
- **Not drawn:** the phone keyboard while listening (the approved base frames have none); Minimal is a note only (the mic stays wherever Brain dump shows, doc 14).
- **Board labels:** "Approved · ED-343 · 15 Nov 2026"; canvas titles updated. Published `1794718829-3d9a`, approved `1794749104-f14e`.
- Built strings and system text only; no new copy. Nothing built. Snapshot v3.18-working.

### ED-344 · R2-38 approved: the Wake Up explainer (boards E-R2-38, E-R2-38-Dark)
- **Date:** 2026-11-15. **Owner:** "Approve R2-38". Sixth board for the audit's never-drawn screens (ED-335 §1); answers the ED-099 explainer item.
- **Approved as drawn:** Wake Up options has "How it works" above its groups (a text button); it opens the built explain sheet with four plain lines (what rings, what the card does, what the check does, where each is turned off): an iPhone sheet, an Android M3 bottom sheet (ED-340), and from medium width the built centred dialog (at most 560 wide) on Mac and web. Help › "How does Wake Up work?" shows the same four lines, then how Wake Up rings on this device (iOS 26 "Alarm-grade wake-up is on."; iOS 18 to 25 the iOS 26 line; Mac and web "Wake-up alarms ring on your phone."; the other built tier lines listed on the board). One line per sentence, as built; this replaces the one-paragraph answer on R2-29.
- **Approved new copy (for the copy PR, ships with the redesign's Settings, ED-332):** `wakeUpExplainOff` → "Each has its own switch in Settings › Your day › Wake Up and Wind Down › Wake Up options." (Day shape no longer exists, ED-321). Today's app keeps its current text until then; en, de, es, fr change together.
- **Design-only:** the Android Wake Up options page (never drawn; the iPhone R2-32 groups and order as Android cards, icons and M3 switches); the Mac and web Help pages in the approved Settings shells. The R2-32 base drops its old new-copy underlines (approved since ED-336).
- **Board labels:** "Approved · ED-344 · 15 Nov 2026"; canvas titles updated. Published `1794752914-c71b`, approved `1794754177-f107`.
- Nothing built. Snapshot v3.19-working.

### ED-345 · R2-39 approved: before Wake Up and after Wind Down, everywhere (boards E-R2-39, E-R2-39-Dark)
- **Date:** 2026-11-15. **Owner:** "Approve R2-39". Seventh board for the audit's never-drawn screens (ED-335 §1). The fold item on the still-to-design list was checked against E-DF2 first: the rule was approved there (ED-246) but drawn only for iPhone Full, light. This board draws the rest.
- **Approved as drawn:** the ED-246 row (the Earlier fold component, ED-164: the task's colour dot, Show or Hide) on Android Full before Wake Up, folded and shown (a task crossing 7:00 stays inline); iPhone Full after Wind Down, folded, below the moon cap; a live task after Wind Down, where the zone opens by itself with the now bead; iPhone and Android Minimal with "After Wind Down" and no count; the Mac Day column (Full) with "1 task after Wind Down" and keyboard focus; the web Day column (Minimal) opened, with focus. Tab reaches the row; Space or Return toggles; → opens, ← closes; ↓ moves into the group. The horizon does not draw outside tasks; its spoken summary names them. The Week folds nothing.
- **Strings:** the counted labels are built (`threadOutsideBefore`, `threadOutsideAfter`). Show and Hide and the Minimal no-count lines are approved design (ED-164, ED-246), not built: the app shows the count in both layouts and a chevron in the dot column. No new copy; Early run and Pack the bag are sample data.
- **Board labels:** "Approved · ED-345 · 15 Nov 2026"; canvas titles updated. Published `1794759901-47cb`, approved `1794760034-a03b`.
- Nothing built. Snapshot v3.20-working.

### ED-346 · R2-40 approved: pin, travel time and energy in the editor (boards E-R2-40, E-R2-40-Dark)
- **Date:** 2026-11-15. **Owner:** "Approve R2-40". Eighth board for the audit's never-drawn screens (ED-335 §1); pin, travel and energy were captions only. Option D (ED-086) placed them (More card, Energy pill) but drew the More card only on iPad and no pickers.
- **Approved as drawn:** the editor's More card below Notes on iPhone and Android, in the built order: Sound, Travel time, Pinned (the built switch with "Stays put when other tasks shift"; replaces option D's "Pin · Off ›" screen), Delete task. Travel time opens the built ticked list (None, 5 min to 2 h before): an iPhone sheet, an Android modal bottom sheet (ED-340); the row is hidden for an Inbox task. The Energy pill (iPhone) and chip (Android) open a three-item menu (Low, Medium, High); picking the ticked level clears it, as built. Today shows a pinned task's lock and "· 15 min travel"; travel time is not counted as free. The calendar travel suggestion (TravelSuggestionCard: Add / Not now, written only on Add, with Undo) on every platform.
- **Design-only:** the Mac and web inspector (E-FullA-v2) gains the More rows under Notes: Energy, Sound and Travel time as pop-up buttons, Pinned as a switch, Delete task; a native pop-up on Mac, a listbox menu on web.
- **Strings:** all built; no new copy. Main St 4 is sample data.
- **Board labels:** "Approved · ED-346 · 15 Nov 2026"; canvas titles updated. Published `1794760982-0f95`, approved `1794761095-9e21`.
- Nothing built. Snapshot v3.21-working.

### ED-347 · R2-41 approved: phone landscape (boards E-R2-41, E-R2-41-Dark)
- **Date:** 2026-11-15. **Owner:** "Approve R2-41". Ninth and last board for the audit's never-drawn screens (ED-335 §1). The rule was approved as ED-168 H1 (usable height under 480 keeps the compact layout, never docks, the keyboard never changes the class); only 25 % schematics existed (E-Responsive, E-MobileWeb).
- **Approved as drawn (iPhone 16 Pro 874 × 402, Android 915 × 412, light and dark):** Today in Full keeps the phone's own navigation and never becomes the Workspace; the day sits in a 640 column (`DotSize.readableColumn`) centred between the safe areas and opens at now (ED-337); rows put the time beside the title (built `wideThreadRowFrom` 440). The editor opens full height, 640 wide, over the day and never docks (no medium detent at this height; Android: the modal bottom sheet, ED-340). Add sits above the landscape keyboard; the keyboard never changes the layout or resets the sheet. Minimal stays Minimal: Now with the horizon across and the now dot beside its words, actions, Also now and Next.
- **Design-only:** the week strip folds into the title row (the title opens the month, as on Android, E-Phones); the tab bar's and the M3 navigation bar's items sit side by side, with the Day button and Add beside them; Minimal Now in two columns.
- **Strings:** from the approved frames; no new copy.
- **Board labels:** "Approved · ED-347 · 15 Nov 2026"; canvas titles updated. Published `1794762278-b237`, approved `1794762319-4e1c`.
- **Still to verify on devices:** H1 is not built; the device and keyboard checks of ED-168 stay PENDING.
- Nothing built. Snapshot v3.22-working. With R2-41 the ED-335 still-to-design list is complete.

### ED-348 · Owner choices: Year strip option B; "Running late" kept
- **Date:** 2026-11-15. **Owner:** chose "Option B" for the Year strip and "Keep \"Running late\"" for the sheet title and the Settings row.
- **Year strip (R2-34, ED-342):** option B is approved: the year as twelve month dots that fill like task dots (days planned per month), the month in progress dashed, a tapped month opening its days below, Share image; iPhone and Android, built strings only. It replaces the approved strip (ED-339), now labelled "Replaced by option B (ED-348)" on R2-34. Building it needs a change to `year_strip.dart`; Mac and web follow the iPhone page in the 640 column.
- **"Running late" (copy flags of ED-338 and ED-341):** the owner keeps the built wording. The Running late sheet's title (`runningLate`) and the Settings › Planning row "Running-late nudge" stay as built; they are recorded exceptions to the no-shame rule (E_DESIGN_RULES). Menus, the Now card and the nudge keep "Need more time?" (ED-162). No copy-PR change.
- **Boards:** E-R2-34 and E-R2-34-Dark: option B frames labelled "Approved · ED-348 · 15 Nov 2026"; the original strip frame labelled "Replaced by option B (ED-348)"; canvas titles updated. Published `1794762747-e9d6`; fit 4139/4140.
- Nothing built. Snapshot v3.23-working.

### ED-349 · R2-42 approved: Year strip option B on Mac and web (boards E-R2-42, E-R2-42-Dark)
- **Date:** 2026-11-15. **Owner:** "Approve R2-42". ED-348 approved option B, drawn on R2-34 for iPhone and Android only; Mac and web Past days had the Year strip button but neither option drawn.
- **Approved as drawn:** from Past days, Year strip opens as the built centred dialog (`app_sheet.dart`, at most 560 wide) on Mac and web, and on expanded tablets by the same width rule: the twelve month dots six to a row, the month in progress dashed, a month opening its days below ("October · 26 of 31 days planned"), Share image and Done. Esc or a click outside closes it. Keyboard: arrows move a focus ring between months, Return opens a month, Tab reaches Share image and Done; screen readers read each month ("Nov, 3 days planned"). The web window is the same at `/#/search`.
- **Strings:** R2-34's; no new copy. Building B needs a change to `year_strip.dart` (ED-348).
- **Board labels:** "Approved · ED-349 · 15 Nov 2026"; canvas titles updated. Published `1794763007-9111`, approved `1794763222-4259`.
- Nothing built. Snapshot v3.24-working.

### ED-350 · Confirmed: the approved onboarding has no Layout step
- **Date:** 2026-11-15. **Owner:** asked to confirm and record a disagreement between two checks (one said the approved onboarding has a Layout step, one said it does not).
- **Confirmed against the approved artifact** "Dottoday Onboarding Prototype", headed "Concept E · Round 2 · R2-16 · Interactive prototype · Approved (ED-305, 13 Nov 2026)" (https://claude.ai/artifact/3dgrJiQ8GGEdxgnD9PCvjL, live version `1794702516-e90b`): five steps, Hello → Your day → What fills your days? → A nudge, in context → You're in. **There is no Layout step.** The layout choice appears only after onboarding, as the one-time "Later, when it helps" card on day 2 ("Want it simpler? Try Less: just the next dot. One tap to switch back.").
- **The static boards are history:** E-R2-16 and E-R2-16-Dark (ED-300), which draw the built flow including step 0 (Show less / Show everything), are titled "APPROVED as the interactive prototype … this static board is history" (ED-305). A check that reads them is reading history.
- **Reachability (parity rule):** dropping onboarding step 0 keeps Layout reachable from the Day menu (Show less / Show everything), Settings › Layout and the Mac View menu (ED-067); FEATURE_PARITY_MATRIX notes it.
- **Records:** ED-305 states it; E_TRACEABILITY (layout row) and E_SCREEN_INVENTORY (onboarding row) already said "no layout step". No board changed. Nothing built.

### ED-351 · The 13+ age note moves to Hello, reworded
- **Date:** 2026-11-15. **Owner** (comment on the onboarding prototype, on the note under "Sign in to sync" on You're in): "move this to hello and it should read "Dottoday is for people aged 13+.""
- **Change:** the age note leaves the last step (You're in) and sits on Hello, under "I have an account", as fine print. Text: **"Dottoday is for people aged 13+."** This replaces the ED-336 placement (footnote on the last step) and the ED-304 removal from Hello.
- **New copy (flagged):** the built `onboardingAgeNote` reads "Dottoday is for people aged 13 and over."; the new wording changes that string in every language when built. docs/06-security.md (Children, M8.6) places the note on O1 Welcome, which Hello now matches again; its quoted wording updates with the build, and the store descriptions and policy keep their own wording unless the owner says otherwise.
- **Prototype:** "Dottoday Onboarding Prototype" (https://claude.ai/artifact/3dgrJiQ8GGEdxgnD9PCvjL) published as version `1794780049-65a7`; the copy note under "Why this beats the built flow" updated. Checked on iPhone and iPad: Hello fits without scrolling. Snapshot v3.26-working.
- Nothing built; the build go-ahead stays behind the release gate (ED-238).

### ED-352 · Q9 approved: an isolated local Supabase stack for integration tests
- **Date:** 2026-11-15. **Owner:** "Approve Q9".
- **Approved (decision A):** P1 to P4 of `Q9_TEST_STACK_PROPOSAL.md` as written: a second local stack `dottoday-test` built by `tool/test_stack.sh` in a git-ignored `.test-stack/`, every port +1000 (decision C left at the proposal's defaults); a URL guard in `local_supabase.dart` that accepts only a loopback test stack (55321, or 54321 when `CI=true`) with keys from the environment only; test users on `@example.test` removed in `tearDownAll`; never linked, never `db push`, `link`, `secrets` or `deploy`.
- **Not approved here (decision B):** the CLAUDE.md §7 wording change; CLAUDE.md is unchanged until the owner says so. `supabase/README.md` (P5, first bullet) is part of the approved PR.
- **Next:** one PR on its own branch cut from `origin/main`, verified by running both stacks side by side and checking the original stack's data is untouched. Nothing created yet. Must run before any integration test run (Prompt F).

### ED-353 · Concept E approved for production implementation (release gate, ED-238)
- **Date:** 2026-11-15. **Owner:** "make sure all files needed to build concept E and approved is recorded correctly in all the appropriated files/ docs including all the decisions made and the approved screens marked as approved or chosen. if everything is recorded correctly in the current state. overall Concept E is approved."
- **Records audit run first (2026-11-15):** ED-001 to ED-352 are all present once, with no gaps or duplicates. The register and the traceability checklist were missing entries; both now carry a catch-up list. Fixed:
  - stale "not approved" banners in the E documents;
  - the register summary;
  - the design rules' §14 "unresolved" list (all settled);
  - four inventory rows marked partly designed that later boards cover;
  - stale labels on the canvas (see "Canvas" below).
  Nothing in the design changed.
- **Approved for production implementation:** Concept E as a whole. This covers:
  - every board on the canvas marked approved, chosen or active;
  - the approved interactive onboarding prototype (ED-305, ED-351);
  - the decisions ED-001 to ED-353 as recorded here.
  `E_IMPLEMENTATION_HANDOFF.md` § "Build sources" lists them. Where boards disagree, this decision log wins (ED-314). History boards stay history: their option frames are not built.
- **Still required before the parts they gate (not removed by this approval):**
  - **CR-160** is a release blocker. Its account screens are not drawn yet, so they must be drawn and approved before account switching is built ([ilearncloud9/dottoday#75](https://github.com/ilearncloud9/dottoday/pull/75)).
  - Device and accessibility tests in the handoff stay pending until run.
  - CLAUDE.md §10 must-ask items still apply: new dependencies, schema changes and migrations, anything on the hosted Supabase project (Q11 web push, Q13 calendar webhooks), new native targets, anything that sends task text off-device.
  - The Q9 isolated test stack ([ilearncloud9/dottoday#82](https://github.com/ilearncloud9/dottoday/pull/82)) runs before any integration test.
  - Building goes through `docs/09-implementation-plan.md` tasks (Prompt F), each with its own definition of done.
- **New copy approved with it:** every string marked new on an approved board, as approved on that board (for example ED-351 "Dottoday is for people aged 13+.").
- **Records:** banners in E_DESIGN_DECISIONS, E_DESIGN_RULES, E_SCREEN_INVENTORY, E_CONSISTENCY_REPORT, E_DECISION_REGISTER, E_IMPLEMENTATION_HANDOFF, E_TABLET_CHECKLIST and STATUS now say approved (ED-353). New redesign ADR `adr/RD-0002-concept-e-approved.md`. Snapshot v3.27-working.
- **Canvas:** board titles and in-board status labels that still said proposed, "for your review", "needs your call" or "not approved" were brought up to date, each where a recorded decision settled it. Main and E-Map carry the approval. Option frames on history boards keep their labels. Changed:
  - 26 boards: E-Phones, E-PhonesMinimal, E-Minimal, E-FullA-v2, E-R2-2, E-R2-16, E-R2-18, E-R2-19, E-R2-33, E-R2-35 and E-R2-38, each with its dark copy; E-DF3, E-G4-7-States, E-Map and Main.
  - 3 canvas titles: E-G3-C1-Font-Comparison, E-Map and E-Workspace.
  - Published as version `1794783581-11ff`; all 27 files read back equal.

### ED-354 · Every settled item is marked approved
- **Date:** 2026-11-16. **Owner:** "if something has been setteled then mark as approved to it and make sure to record it properly".
- **Rule:** an owner decision is called **approved** everywhere: in decision headings, register statuses, STATUS, board badges and canvas titles. "Resolved", "decided", "chosen" and "settled" are no longer used for owner decisions. On option boards, the chosen option's frames say "Approved · ED-nnn". Frames of other options say "Not chosen · option X approved (ED-nnn)". Neutral frames say "History · option X approved (ED-nnn)". Consistency-report fixes (CR rows) keep "Resolved", because they are corrections, not owner choices.
- **Docs:**
  - 41 decision headings changed from "resolved"/"decided" to "approved", with the matching catch-up lines in E_TRACEABILITY.
  - E_DECISION_REGISTER: 64 statuses changed from RESOLVED to APPROVED, plus its status-words line and summary column. The three items adopted from boards now note when they were approved: G2-3 (ED-238), G2-7 (ED-099) and G2-13 (ED-336).
  - STATUS: 36 "resolved"/"decided" for owner decisions changed to "approved". Snapshot folder names are kept.
- **Canvas** (version `1794787239-a691`; 54 files read back equal):
  - 24 titles changed. Examples: G3-1 to G3-7 "approved: …"; T1 to T4 "approved: …"; G3-6-Decision "APPROVED as design and architecture direction"; Dark tokens "Stage 1 approved as final"; R2-19 option A "not chosen; Option B approved".
  - 53 boards: 199 badges relabelled. Examples:
    - G2-4, G2-6-Review, G2-11, G2-12, G3-6-BottomRow, G3-9b-Palette and -Screens, PhonesCalendar and V1: approved;
    - G2-10: option A not chosen, option B approved;
    - Chosen / Decided / R2-xa decided: approved;
    - DF2, DF3, T1 to T4: "Light only · approved";
    - R2-16: "Approved as the interactive prototype (ED-305) · this static board is history";
    - R2-19-B new copy: approved (ED-336);
    - E-FullA-v2 unsaved inspector edits: approved (ED-086, ED-100);
    - "Hypothesis · each one approved or replaced (ED-353)" on the active boards' legends.
- No design changed. Snapshot v3.28-working.

### ED-355 · The Concept E build is written into the implementation plan
- **Date:** 2026-11-16. **Owner:** "write the build tasks into the implementation plan".
- **Where:** `docs/09-implementation-plan.md` § "Concept E build", milestones M18 to M22, 37 tasks. They follow `MASTER_PLAYBOOK.md` steps 10 to 16:
  - **M18:** foundations (Prompt E): tokens, components, adaptive shell, native chrome, navigation.
  - **M19:** the first vertical slice (Prompt F): Today → Add → Edit/reschedule → Complete → Change day → Reopen.
  - **M20:** fourteen migration slices (Prompt G).
  - **M21:** platform QA (Prompt H).
  - **M22:** release.
- **Rules written into the plan:**
  - replace, don't layer;
  - models, persistence, sync and the backend stay unchanged unless a task names the change and the owner approves it;
  - docs/14 §3 rows and `FeatureId`s come before building;
  - layout by width class only;
  - each slice's definition of done;
  - owner stops after each milestone, after M19, and after each M20 slice;
  - integration tests run on `tool/test_stack.sh` (ED-352).
- **Every task cites its decisions and boards.** All 120 cited decisions were checked against their headings.
- **Owner gates inside the plan:**
  - M18.0: the CLAUDE.md §11 wording;
  - M20.7: the ED-221 migration;
  - M20.12: blocked on PR #75 and the account screens;
  - M22.1 and M22.2: the hosted project, Q11 and Q13.
- **Branch:** `main` was merged into `redesign/design-lab` first (`c3e72852`, PRs #70 to #82, no conflicts), so the plan sits on top of the merged work: Today at now, Trash delete, Wind Down after midnight, the device table and the Q9 test stack.
- Nothing built. Snapshot v3.29-working.

### ED-356 · CLAUDE.md §11 names Concept E as the design source
- **Date:** 2026-11-16. **Owner:** "approve the CLAUDE.md §11 change".
- **Change:** the redesign-branch bullet in CLAUDE.md §11 now makes Concept E (RD-0002, ED-353) the design source on `redesign/design-lab`. It points to the handoff's "Build sources" and the plan's M18–M22, and keeps the decision log as the tie-breaker (ED-314). DESIGN_PRINCIPLES and RD-0001 still govern presentation, and the Concept A bullets below do not apply on this branch. The rest of CLAUDE.md is unchanged.
- **Records:** RD-0002's open consequence is closed. The M18.0 owner gate is done; its docs/14 rows and doc pointers are still to do.

### ED-357 · M18.0 done: Minimal-mode rows for Concept E's new features
- **Date:** 2026-11-16. **Owner:** "Start M18.0". The CLAUDE.md §11 gate was done in ED-356.
- **docs/14 §3:** three rows were added, each with a `FeatureId` and a `LayoutPolicy` entry, so the policy test keeps docs and code in step:
  - Earlier fold (ED-164), **Shown**;
  - Before Wake Up / After Wind Down rows, `ThreadOutside` (ED-246, ED-345), **Simplified**: no count in Minimal;
  - Search or run, ⌘K / `k` on Mac and web (ED-333), **Simplified**: Minimal's ⌘K is the Everything else finder.
- **Already had rows, unchanged:** Rebalance (C1), Pick today's one thing (W5; Minimal's Day menu leaves it out, ED-093), Past days + Year strip, Pinned tasks, Travel time, C4 Energy, and the dictation mic (spoken Brain dump, ED-343).
- **Not rewritten, per ED-068:** the rows superseded by Concept E's Minimal navigation (tabs and sidebar instead of the Later row). docs/14 now says so under §3 and points to `E_DESIGN_RULES.md` §9.0.
- **docs/03 and docs/10:** a redesign-branch note says Concept E is the design and they are history where it differs.
- **Checks:**
  - `flutter test test/domain/layout/layout_policy_test.dart test/minimal_mode/hidden_reach_test.dart`: 5 passed.
  - `flutter analyze`: no issues.
  - `dart format`: no changes.
- **Records:** CHANGELOG entry added. Plan M18.0 ticked.
- No UI changed.

### ED-358 · M18.1 done: Concept E light tokens; Concept E ideas added to the plan
- **Date:** 2026-11-16. **Owner:** "Start M18.1"; "Yes, download and go" (the Manrope download); "Also add any new ideas that is in Concept E that is not existing … to the plan".
- **Tokens:** the light theme moves to Concept E (rules §3–§4, §6.3):
  - **Neutrals:** ground `#FBF7F1`, cards `#FFFDF9`, ink `#241F2B`, secondary `#6A6273`, the thread ahead `#BEB6C7`, and an 8 % ink hairline.
  - **Task fills:** E shades for the nine keys (ED-161).
  - **Accent:** the `teal` accent is E's `#11615C` and the new default (`docs/05` example updated). Indigo, coral and violet keep their values until the App colour work (M20.7), because E's violet fails 4.5:1 as a button colour.
  - **Type:** Manrope replaces Inter (ED-110), downloaded from github.com/google/fonts (`Manrope[wght].ttf`, OFL; licence in About › Licenses), at the E phone scale: row title 700 17, now row 700 19/24, row time 400 13, body 15/22, buttons 700 15, Android top bar 400 24/32.
  - **Shape:** card radii 20 / 24.
  - **Focus ring:** the accent (ED-211).
- **Deliberately not changed here:**
  - dark values (M18.2);
  - the per-colour ring shades (M18.3, with the dots that use them);
  - elevation tiers (M18.4);
  - the app icon and launch colours. These stay the shipped brand until the brand rollout (new plan task M22.4; `tool/gen_app_icons.dart` pins them).
- **Layout fixes the new type scale needed:**
  - the Week "Today" button lets its label wrap;
  - the Week day-header row is capped at half the board and scrolls by itself at 200 % text;
  - no text is clamped.
- **Tests:**
  - updated to the new values (theme, palette, focus ring, live activity, snapshot, settings default);
  - two tests that tapped rows the bigger type moved now use a taller screen or tap the row itself;
  - 2,199 goldens regenerated; samples checked against the boards (E colours and type on today's layouts, as expected before M19);
  - `flutter test --exclude-tags supabase`: 6,099 passed, 21 skipped, 0 failed;
  - `flutter analyze`: clean.
- **Plan additions (Concept E features not yet listed):**
  - touch-first web sizes (ED-261) and stylus handwriting (ED-258) in M18.5;
  - the Workspace Day / 3 days / Week / Month tabs in M19.2;
  - Minimal's Now tab and pane in M19.6;
  - Day review and Week in review (ED-099, R2-14) in M20.3;
  - the tablet colour picker (R2-15) and the Mac Settings window in M20.7;
  - the Mac Now mini window in M20.9;
  - all four "Later, when it helps" cards in M20.11.
- **New plan section, "Ideas Concept E noted but did not design":** ten items that need a design and the owner's OK first (ED-328 to ED-335).

### ED-359 · M18.2 done: Concept E dark tokens
- **Date:** 2026-11-16. **Owner:** "Start M18.2".
- **Tokens:** the dark theme is P1 Warm Charcoal (ED-174, ED-178):
  - ground `#171416`, cards `#1F1B1E`, text `#F3ECE4`, secondary `#C7BEC4`, divider `#3E373D`;
  - the dotted thread ahead `#6B6369` (T2-B);
  - teal `#5BC4B8` with ink `#0C2523`;
  - success `#82CF9F`.
- **Dark task fills:** the dark values of ED-175 for the nine stored keys. `palette.json` now holds a dark value per colour, and the generator emits it. The theme picks the value; the stored key never changes.
- **Other accents:** indigo, coral and violet stay as they were until M20.7.
- **With their components later:** the dark now-ring tracks at 25 % (M18.3), the caps and large now-dot details (ED-177, M18.3), and the Mac D1 sidebar and I1 icon (M18.6).
- **Checks:**
  - theme and palette tests updated;
  - 1,101 goldens regenerated; the dark Today checked against the dark token board;
  - `flutter test --exclude-tags supabase`: 6,099 passed, 21 skipped, 0 failed;
  - `flutter analyze`: clean.

### ED-360 · Foundation step 1: the full Concept E token set, staged, with two guards
- **Date:** 2026-11-17. **Owner:** "Approve step 1" (after the Foundation Step 1 review page). Earlier on 2026-11-16 the owner chose:
  - the token decisions A to D from the token review: A replace the structure, B dark cards as drawn, C chrome in the platform font, D Concept E accents;
  - for A, the staged way ("i will go with your recommendation"), after the strict-or-staged trial showed both draw identical pixels;
  - Roboto for web chrome ("download Roboto … i might get to review this font later");
  - section headings to change with each screen's rebuild.
- **Why this redoes M18.1 and M18.2:** a check against the canvas found that those steps had fitted Concept E into Concept A's 12 colour roles. The dark cards were `#1F1B1E`, where the approved dark boards draw `#28232A` (5,629 uses against 468).
- **Built:**
  - **Every Concept E colour role, light and dark.** The dark values are the ones the approved dark boards draw for each light value (ED-181, matched across 50 board pairs). This includes dark cards `#28232A`, teal's own text `#0B4642` / `#A3E2D9` and tonal `#E2EFEC` / `#1E3A37`, the dark focus ring `#7FD6CB`, caps, the orb, outlines, placeholder and state colours.
  - **The accents:** indigo, coral and violet in Concept E shades. Coral uses the ring shade `#DF6147`, because its fill (2.90:1) is under 3:1 on the ground (the ED-155 rule). Buttons derive a shade so their text reaches 5:1 (ED-161).
  - **Task colours:** a light ahead-ring shade per task colour (ED-155) and the dark fills (ED-175).
  - **Type:** chrome (the date title, page titles, tabs, section headers, the Android top bar) in the platform's own face. The web uses the bundled Roboto (`RobotoWeb`, OFL), provisional pending the owner's font review.
  - **Shape and depth:** Concept E radii (iOS sheet 38, tiles 22, pull-down 26, menus 22 / 10, blocks 18, tip 20, round chips) and the ED-210 tier 2 and tier 3 shadows.
- **Staged names:** widgets keep their old role names with Concept E values. The colours also carry Concept E names (`ground`, `card`, `ink`, `secondary`, `hairline`, `accentText`, `tonal`). The old `hairline` role, which meant the dotted thread, is renamed `threadAhead` (41 uses) so that `hairline` can mean an edge, as it does in Concept E.
- **Guards:**
  - `test/core/theme/concept_e_board_values_test.dart` fails if any colour role or task colour stops matching the values measured on the boards.
  - `test/policy/concept_e_names_test.dart` fails if a file marked `// concept-e: rebuilt` reads a Concept A role name or uppercases text.
  - Plan M20.14 deletes the old names.
- **Not in this step:**
  - light warning and error colours: Concept E never designed them, so they get a canvas board first;
  - uppercase headings, which change with each screen's rebuild.
- **Tests updated to Concept E:**
  - Settings page titles stack under "‹ Settings" at every text size, as E-R2-20 frame 07 draws them;
  - the Siri and time-zone tests scroll to their rows before tapping;
  - the notes-mic golden hosts Notes in a scrolling list, as the editor does. The 4 px overflow was in the test harness, not the app.
- **Checks:**
  - `flutter test --exclude-tags supabase`: 6,149 passed, 21 skipped, 0 failed;
  - `flutter analyze`: clean;
  - 2,091 goldens regenerated;
  - the side-by-side against `docs/design-references/concept-e/` was reviewed by the owner.

### ED-361 · How the Concept E build runs: approval per step, new boards for missing designs, motion, foundations first
- **Date:** 2026-11-16 and 2026-11-17. **Owner's answers:**
  - **Approval:** each foundation step is built in the worktree, shown as a board-vs-app side-by-side, and committed only after approval. Nothing is pushed until the owner says.
  - **Missing designs:** anything without an approved design gets a new board on the Design canvas, in light and dark, approved by the owner and recorded before it is built.
  - **Motion:** 180 / 200 / 240 ms with ease-out, as the app has and ED-246 uses; Reduce Motion jumps. Concept E never set timings (rules §7.5).
  - **Native:** every platform uses its own native parts (the owner: iPhone, Android, Mac, web, iPad and Android tablets "use it's platforms native").
  - **Order: foundations first.** The owner first chose a Today and task sheet pilot, then withdrew it before any pilot work began ("i want to go back to pilot decision as i would like to follow the previous plan"). The build follows the plan's order: M18.3 to M18.8, then M19 from Today (M19.1).
- **Guiding question rule:** the owner asked for clarifying questions instead of assumptions ("make sure to ask clarifying questions and don't assume").

### ED-362 · The E-CR160 boards are the approved account screens for M20.12
- **Date:** 2026-11-17. **Owner:** "Yes, use them", answering whether the existing E-CR160 boards (ED-222 to ED-230) count as the approved account screens for M20.12, or must be redrawn in Concept E first.
- **Decision:** E-CR160 (ED-222 to ED-230) is the approved design for the account screens: A1, A2, A3, B1 and Settings › Account "Choose settings", on iPhone, Android and Mac/web. They are not redrawn. M20.12 builds them on top of CR-160's screens, with the acceptance criteria in E_IMPLEMENTATION_HANDOFF § CR-160.
- **Still pending:** merging origin/main (CR-160, PR #75, merged to main 2026-11-16) into redesign/design-lab. It waits for the running build session to commit its work. M20.12 is unblocked once that merge lands.
- Nothing built or committed.

### ED-363 · M18.3 part 1: the Concept E day thread
- **Date:** 2026-11-17. **Owner:** "1A and 2A" before the build, and "Approve all four" after the M18.3 review page (board E-Phones Today frame 01, light and dark, beside the app's Today golden).
- **Owner's choices:**
  - **1A:** the new thread replaces the old one on every screen at once. A Today that is half Concept A (header, strip, tab bar) and half Concept E (thread) until M19 is accepted.
  - **2A:** the now card on Full Today has no Done, +15 min or Shift the rest buttons, as the board draws it. Done is the row's circle; +15 min and Shift the rest stay in the task sheet. Minimal keeps Running late (docs/14 §4).
  - **Q1:** the knot row reads "Overlap · 10:30–11:00" (new string `threadOverlapRange`). The screen reader still hears both tasks ("Run and Sleep share 15 min").
  - **Q2:** "add here" rows keep a 44 pt tap height, where the board draws free rows 28 (CLAUDE.md §5 touch targets).
  - **Q3:** the now card keeps the "1 of 3" subtask line when the task has subtasks; the board's task has none.
  - **Q4:** the done check sits about 11 pt further in than on the board, so the now card keeps its 10 pt margin inside the 20 gutter. M19 rebuilds the row edges with the page.
- **Built (rules §4.4, §5.1 to §5.4):**
  - dots: done 32 solid with the icon in `TaskSwatch.check` (white; the ground in dark; ink on amber, ED-196); ahead and calendar 34 with 4 / 3.5 / 2.5 px inset rings by size; the now ring 45 at 5.5 over a 20 % (dark 25 %) track; calendar events in the event recipe (ED-200); skipped dashed;
  - the thread: 48 px dot column, centre 44 from the screen edge, 4 px solid behind now with each row's upper half in the previous task's colour, 4 px dots ahead in `threadAhead`;
  - fixed row heights: cap 44, done 48, ahead 54, now card 80 minimum, free 28, knot 26, bead 26;
  - caps: the sun on `wakeCap`, the moon on `windCap`, 34 (ED-201); the thread starts and ends at their centres;
  - the now card: margin 10, radius 24, 1 px hairline, time line "9:00–11:00 AM · Now, 18 min left" (new string `liveNowLeft`), title 19/700, the done check in the task's colour;
  - the now-bead row (`ThreadNow`): 16 px bead with a card-coloured border and a 40 % accent ring, the time pill and line; after the live tasks, or splitting free time where now falls in a gap;
  - the done check: 28 with a 2.5 ring (grey ahead, task colour for now), solid when done; done titles grey, no strike-through; calendar events have no done check;
  - free time: "1 h 30 free · add here" as text, the action in the accent; the dashed pill is gone.
- **Removed (2A):** the now card's button row, the thread's `onExtend` / `onShiftRest` actions and Today's wiring for them, `ThreadTask.overrunMinutes`, the gap's `nowFraction` (the bead replaces it), and the role `onTaskFill` (replaced by `TaskSwatch.check`). The task sheet's +15 min gained a test.
- **Still open in M18.3:** the Earlier fold (ED-164), the Before Wake Up / After Wind Down rows in Concept E style (ED-246, ED-345), the bead's once-a-minute slide (ED-246), the "Alarms off" device tag (ED-205, ED-213), the repeat marker check (ED-208), and goldens against E-Earlier and E-DF2.
- **Checks:** `flutter analyze` clean; `flutter test --exclude-tags supabase` all passing; goldens regenerated.

### ED-364 · M18.3 part 2: the folds and the moving now
- **Date:** 2026-11-17. **Owner:** "Yes, move it" (the Alarms off tag to M20.8), then "A, approve" on the part 2 review page (boards E-Earlier, E-Earlier-Dark frame 1, E-R2-39 frame 3, beside the app's goldens).
- **Owner's choices:**
  - **Alarms off tag (ED-205, ED-213):** moved to M20.8, built with the alarm device picker it lives in.
  - **Q1, A: the moving now under fixed rows.** ED-246 B was drawn on a thread whose rows were as tall as their time. With fixed rows (ED-363) a minute tick moves nothing but the pill's time; the bead changes rows only when a task starts or ends. Then its old row closes and its new one opens, 200 ms ease-out (`DotMotion.base`). Reduce Motion jumps. A hop first seen after the app was away (no build for 90 s) jumps too: no catch-up animation.
  - **Q2:** where the fold applies, the view starts at the fold with no Wake Up cap, the Full Mac/web card included, as E-Earlier frame 8 draws it. Side days keep their caps.
- **Built:**
  - `FoldRow`, the Earlier fold component: 48 pt, up to three 24 pt dots overlapping by 12 with a 2 pt ground ring, the label 700 15 secondary, "Show ⌄" / "Hide ⌃" 700 13 in the accent ink. A button with its expanded state; Tab reaches it, Space or Return toggles, → opens, ← closes.
  - The Earlier fold (ED-164): `foldEarlier` folds done tasks behind now into one `ThreadEarlier` row with no count; the Wake Up cap and the free time behind now are left out; a reopened, missed or early-done task keeps its row. Folded, the thread leaves the row in the last done colour; open, it runs through it into the first. Today folds on Minimal phones and on the Mac/web card (the Mac Day column comes in M19); Full phone Today keeps its rows; other days never fold. Open or folded is kept per day while the app runs (`earlierOpenProvider`), not stored.
  - Before Wake Up / After Wind Down (ED-246, ED-345): `OutsideRow` uses `FoldRow` with the tasks' colour dots; Minimal drops the count ("Before Wake Up", "After Wind Down"); open, a dotted thread runs from its dot into the rows.
  - The moving now as in Q1 (`BeadHops`), and one polite announcement, "Now: Deep work: roadmap", when the live task changes; focus never moves.
  - Strings: `threadEarlier`, `threadEarlierLabel`, `threadOutsideBeforePlain`, `threadOutsideAfterPlain`, `threadFoldShow`, `threadFoldHide`, `threadNowTask` (en, de, fr, es).
- **Fixed from part 1:** Manrope is a variable font, so 700 needs its weight axis too. The now pill's time and the now card's "Now, 18 min left" rendered at 400 and are 700 now.
- **Checked, no change:** the repeat marker (ED-208) is the loop icon after the time.
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test --exclude-tags supabase` 6,916 passing; 36 new goldens (`thread_earlier`, `thread_earlier_open`, `thread_outside_plain`), 236 regenerated.

### ED-366 · M18.4 part 1: sheets, the proposal, chips, tags and menus
- **Date:** 2026-11-17. **Owner:** "Yes, as proposed" (M18.4 in three parts; the sync screens of E-G4-7-States stay in M20.10, native menus come with M18.5 / M19), "A, as the boards" (the sheet colour), and "Approve, rows in part 2" after the part 1 review page.
- **Sheet colour (A):** sheets sit on the page ground, `#FBF7F1` light and `#171416` dark, with cards inside in `#FFFDF9` / `#28232A`, as every E-Phones-2 frame draws them. This replaces ED-174's `#2F2A30` sheet level and the `#FFFDF9` in rules §7.1 for sheets; the `sheet` token now holds the ground values.
- **Built:**
  - sheets from the theme: iPhone 38 top corners and the system grabber (36 × 5, 30 %); Android 28 and a 32 × 4 `#8A8494` handle; the scrim; a soft shadow; dialogs and wide popovers on the same ground with radius 28;
  - `SheetHeader` for every titled sheet: iPhone 800 24 Manrope with Close as a 32 pt `control` circle in 44 pt; Android 400 22 in the system face with a plain cross in 48 dp; an optional 500 14 line and tag;
  - `ProposalSheet` (ED-150): the header with its origin as a 24 tall tag, the card at 22 (iPhone) / 16 (Android), Add to day 54 tall at 800 17 with the check first, Discard, the footnote; it already opened at the large detent;
  - `DotTag`, and `ProposalChangeChip` in the tag's shape: 20 tall, fully round, 700 12; to the Inbox and untouched in the quiet grey; resized and moved keep their tints;
  - chips from the theme: 34 tall, fully round, 700 14 Manrope; picked in the accent with a white check, the rest tonal; hit areas 44 / 48;
  - Flutter menus from the theme: Android `#F7EFF4` (dark `#37313A`) at 22, iPhone 26, Mac and web 10. `dotMenuStyle` removed.
- **Tests:** goldens render real shadows (flutter_test drew them as hard black edges) and use their own platform's theme (`DotTheme.light/dark` take an optional platform). 944 goldens regenerated.
- **Moved to part 2 (owner):** the proposal's rows (`ProposalThreadList`), drawn on the board as dashed rings in the task's colour.
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test --exclude-tags supabase` 6,916 passing.

### ED-367 · M18.4 part 2: the state kit and the proposal's rows
- **Date:** 2026-11-17. **Owner:** "Approve" on the part 2 review page (E-G4-7-States A1, A5, A6 light and dark, and the E-Phones-2 proposal, beside the app's goldens).
- **Scope, by the split the owner approved (ED-366):** A1, A5, A6 and section D here; A2, A3, A8, A9 and A10 stay with the sync work in M20.10; A7 (Android couldn't save) moves to part 3 with the Undo toast, as the same toast.
- **Built:**
  - `LoadingThread` (A1): grey 34 pt dots in 54 pt rows with a short and a long bar, on a 2 px dotted thread; bars shrink in a narrow slot;
  - `StateMessage`: a glyph in a 56 pt sunk circle, the title 800 20/26, the line 500 15/21 ink2, one tonal 44 pt action;
  - `ErrorState` (A6) on it: "This didn't load", "Your tasks are safe on this device.", Try again; a failure with its own words shows those. The string `stateReadFailed` is removed;
  - the empty Inbox (A5) on it, with the new string `inboxEmptyBody` (en, de, fr, es); a filter that shows nothing keeps its line;
  - the proposal's rows (moved from part 1): `ProposedDot`, the 34 pt ahead dot in a 2 px dashed ring in the task's ring colour at 53 %; 64 pt rows; a 32 pt outlined × in 44 pt; the faded "before" dot removed (struck times remain); the legend's proposed mark dashed;
  - section D: disabled buttons on the tile fill with ring-grey words; segmented choices on a pill track, the pick on the card colour at 700, the rest 600 ink2; errors at a field with `FieldError` (warning glyph, 600 13 ink, announced) and a 2 px ink line.
- **Known difference:** the Repeat picker turns the segment check off, so its pick shows by weight and colour, not a check; still never colour alone.
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test --exclude-tags supabase` 6,916 passing; goldens regenerated where this part changes them.

### ED-368 · M18.4 part 3: the Undo toast and the selection card; M18.4 done
- **Date:** 2026-11-17. **Owner:** "Approve" on the part 3 review page (E-R2-7 and E-R2-6 boards, E-G4-7-States A7, beside the app's goldens).
- **Built:**
  - the toast from the theme: `toast` `#2E2836` / `#F3ECE4`, `onToast` `#FBF7F1` / `#171416`, `toastAction` `#A3E2D9` / `#0B4642`; 600 15 words, a 700 action; 16 corners on iPhone, iPad and Mac, 8 on Android and the web; from the medium width 400 wide (440 off Apple platforms), centred. Every message toast takes it;
  - `UndoToast`, ED-281's build checks: the 30 s window waits while hovered or focused; Escape closes; with a screen reader on it stays and shows Close; no countdown. The service's token still expires 30 s after the change (R-11): if that happens while held, the toast says `failureUndoExpired` with Close only;
  - couldn't save (A7): the same toast with Try again, announced assertively (D3);
  - the selection card (ED-278): radius 26, a hairline edge, the floating shadow, "N selected" at 700 17, actions 52 tall; actions and strings unchanged;
  - the pick mark (fixed from ED-363): in the done circle's place, a 28 pt ring or a filled check; while selecting, rows leave out their done circles; calendar events get the ring.
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test --exclude-tags supabase` 6,945 passing; new toast tests and goldens (iPhone, Android, wide, dark, screen reader).
- **M18.4 done** (ED-366, ED-367, ED-368).

### ED-369 · M18.5 part 1: one layout rule
- **Date:** 2026-11-18. **Owner:** "Yes, as proposed" (M18.5 in three parts; iPad navigation in Flutter here, native in M18.6) and "Approve" on the part 1 review page (E-Responsive, E-R2-41 beside the app's goldens).
- **Built:**
  - `AppLayout` (`core/layout`): the window's class by width (600 / 840), H1 (usable height under 480 after safe areas, keyboard not counted: compact, never docks), and `docks` (from 1160, with Today 480 beside the 420 panel, 600 above 130 % text). Used by the shell, the editor and proposal panels, `openTask`, `openFocus`, Today's spread, the Inbox, Month and Back to Today; component sizing (sheets, toasts, banners) keeps width alone;
  - `SidePanelFrame`: the editor and the proposal docked from 1160, floating over Today as a card below it; one tree both ways, so a resize keeps the panel's text, steps and focus and the content's scroll. The built app docked from 840;
  - phone landscape (ED-347): the day in a 640 column, centred; a task sheet opens at full height under H1;
  - the Mac minimum window 840 × 640 (`MainFlutterWindow.swift`, ED-169).
- **Fixed from ED-363:** the side-by-side live row's time column shows "Now, N min left" under the range again.
- **Moved, with plan notes:** the narrow-Mac Minimal rules (Day-column fold, narrow toolbar, short-window now-dot; ED-169, ED-170) to M19.6; the Workspace inspector's docking (C1) to M19.2; the landscape week strip in the title row to M19.1; landscape tab items side by side to M18.6.
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test --exclude-tags supabase` 6,960 passing; new tests for the rule and the frame; new goldens `today_editor_floating` (1100) and `today_landscape` (874 × 402).

### ED-370 · M18.5 part 2: tablet navigation
- **Date:** 2026-11-18. **Owner:** "Approve" on the part 2 review page (E-R2-1, E-R2-31 beside the app's goldens).
- **Built (E-R2-1, ED-267, ED-334):**
  - medium on iPad: `TopTabsShell`, the main places as a capsule of top tabs (current on the card colour in bold), the sidebar button opening every place over the content with Settings at its foot, add at the end; Flutter until M18.6 swaps in the native bar;
  - medium on Android and the web: the M3 rail on the sunk surface, the menu opening the drawer of places, add as the tonal rounded-square FAB, the pill behind the current icon, Settings at the foot;
  - expanded: `SidebarShell`, a 216 sidebar (Dottoday, the places 44 pt on iPad / 48 dp elsewhere, Settings at the foot) folding to the rail and back for the session;
  - `ShellDestination.foot`: Settings sits at the foot of the rail and sidebar, never a tab beside the places (phones keep their tab until M18.7);
  - foldables: half open with a horizontal fold is a short window (H1, compact); a hinge with a gap keeps the content to one side (`DisplayFeatureSubScreen`);
  - the toast from the medium width centred on the content beside the rail or the sidebar.
- **Moved, with plan notes:** the Workspace's list (Plan, Calendar views, Review) to M19.2, the Calendar place to M20.1, Minimal's places by width (ED-266) to M19.6, the sidebar's sync line to M20.10.
- **Strings:** `navShowSidebar`, `navHideSidebar`, `navMenu` (en, de, fr, es). **Glyphs:** `sidebar`, `menu`.
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test --exclude-tags supabase` 6,967 passing; shell tests per class and platform, the drawer, folding, tabletop and hinge; toast goldens now 520 tall (300 is a short window).

### ED-371 · M18.5 part 3: mobile web, touch and stylus; M18.5 done
- **Date:** 2026-11-18. **Owner:** "Approve" on the part 3 review page (E-MobileWeb beside the app's goldens).
- **Built:**
  - compact web (ED-172): `WebBarShell`, its own 56 bar on the page colour with a hairline, labelled icons, the current one in a tinted 56 × 28 box in bold, "+ Add" (48 tall, radius 12) above it; picked by `webChrome` in `core/theme`;
  - the touch-first rule (ED-256, ED-261): `watchTouchContent` (iPad and Android tablets yes, the Mac no, the web by its primary pointer through `(pointer: coarse)`, re-read on change; `primary_pointer` stub and web pair, hand-written js_interop). It changes nothing visible yet: the app has one content scale, the phone's; M19.2 and M19.6 read it when they build the pointer sizes;
  - stylus handwriting (ED-258): Flutter's text fields accept Scribble and Android stylus handwriting by default; a policy test keeps every field from turning them off. Device checks with a Pencil and a stylus in M21.
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test --exclude-tags supabase` 6,974 passing; the web build compiles; new goldens `shell_web`.
- **M18.5 done** (ED-369, ED-370, ED-371).

### ED-372 · M18.6 part 1: Android's bottom row, the + and the keyboard
- **Date:** 2026-11-18. **Owner:** "Yes, as proposed" (M18.6 in three parts; the native iPhone bar fades out under Flutter sheets and dialogs, toasts lift above it) and "Approve" on the part 1 review page (E-Phones Android Today beside the app's goldens).
- **Built:**
  - Android compact (ED-125): `MaterialBarShell` is the floating toolbar (72, radius 36, 16 from the start, 24 above the bottom) with the + (56, radius 16, 8 away); the current place a tonal block; frosted (fill 72 % / 78 % over a 24 blur) on Android 12+, solid tonal on 11 and older and with high contrast (`dottoday/display` channel, `frostedChromeProvider`); tokens `barAndroid`, `fabAndroid`, `ChromeAlpha`;
  - the toast at compact Android width sits above the toolbar;
  - the + is "Add a task" (ED-240): `quickAddTooltip` en and es renamed;
  - the neutral "return" key on iPhone's Add and Inbox fields (ED-135); Android keeps done.
- **Moved:** the Android Day button above the toolbar to M20.3 (no Day button yet); iPhone's hold hint and Android's menu role on the + to M19.3, with the menus they describe.
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test --exclude-tags supabase` 6,974 passing; the Android shell test checks the geometry.

### ED-373 · M18.6 part 2a: the native iPhone bar
- **Date:** 2026-11-18. **Owner:** "Approve" on the part 2a review page (E-Phones iPhone Today beside the app running in the iOS 26.5 and 18.6 simulators). Part 2 is split into 2a (iPhone) and 2b (iPad, its own review).
- **Built (ED-124, ED-128 N3 and D2, ED-132, ED-260):**
  - `NativeTabBar.swift` (Runner target, `dottoday/native_tab_bar` channel; no new target or package): a UIKit tab bar and the + over the Flutter content. iOS 26: the system Liquid Glass capsule and a teal prominent-glass +; after every layout the bar reads the capsule's real frame and moves so it sits 6 from the + and 21 above the bottom, the + as tall as the capsule. iOS 16–25 (F2): the system material bar rounded to a 63 capsule and a solid teal +;
  - SF Symbols in this native chrome (`tray`/`tray.fill`, `magnifyingglass`, `gearshape`/`gearshape.fill`, `calendar`); Today keeps the app's dot as a template image; teal light and dark;
  - Flutter: the `NativeBar` seam (`shared/navigation/native_bar.dart`), `ChannelNativeBar` and `nativeBarProvider` (`data/shell`), `NativeBarShell` (a clear strip its height keeps toasts above it), and `NativeBarObserver` on the router: the row fades out while a sheet or dialog is open and returns (owner, M18.6); no native row keeps the Flutter bar.
- **Checked in simulators:** iOS 26.5 (iPhone 17 Pro) and iOS 18.6 (iPhone 16 Pro): geometry, tab switching, the + opening Add, hiding under the Add sheet, the neutral return key. iOS 16–17 and real devices: M21.
- **Not here:** the Day button and its UIMenu with the Day menu (M20.3); the + hold menu with Add (M19.3); Calendar with M20.1; Minimal's tabs with M19.6.
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test --exclude-tags supabase` 6,974 passing; goldens unchanged.

### ED-374 · M18.6 part 2b: the native iPad tabs, sidebar and +
- **Date:** 2026-11-18. **Owner:** "Granted, continue" (simulator access), "A: teal + beside bar" (the + question), "Check medium first", then "Approve" on the part 2b review page (E-R2-1 row 1 beside the app on iPadOS 26.5, iPadOS 18.6 and the iPad Pro 11" at medium width).
- **Built (ED-171, ED-265, ED-267, R2-1):**
  - `NativeIPadTabs.swift` (Runner target; no new target or package): on iPadOS 18+ a `UITabBarController` in `.tabSidebar` mode becomes the window's root, so iPadOS draws the top tabs, the sidebar and its toggle, and the phone bar in compact windows. One container per place, made once for the app's life (UIKit refuses a container shared by two tabs; the set changes with width); the Flutter view moves into the selected one. Older iPads keep the Flutter shells;
  - `DotFlutterViewController.swift`, the storyboard's root: it reports when a disappear has really ended, and the move into a tab says "appeared" only after that. Flutter stops drawing when told its view disappeared; telling it too early left UIKit's own end call unbalanced (the launch warning is gone on iPadOS 26.5, 18.6 and iPhone);
  - Settings is sidebar-only and the places are fixed (`foot` on the channel), so the sidebar has no Edit. UIKit has no foot slot: Settings is the last sidebar row, and iPadOS keeps it in the top bar once opened (system behaviour);
  - the teal + (owner's choice A, ED-124 shared button): at medium width level with the top bar at the window's trailing edge, as on 1b; in compact windows the phone geometry (bar from 21 to 6 short of the +, the + as tall as the capsule, ED-104); at expanded width none, the rule since M18.5. The + fades under a Flutter sheet, dialog or menu; the system tabs stay put and refuse taps then (hiding them gave back their safe area and the page jumped);
  - Flutter: `NativeBarShell` keeps iPad content beside a docked sidebar (its side inset); the page ground carries on underneath.
- **Checked in simulators:** iPadOS 26.5 (iPad Pro 13": portrait, landscape with the docked sidebar, windowed, live resizing between compact and regular, sidebar over the content), iPadOS 18.6 (iPad Air 13": portrait, landscape, menu blocking, Settings), iPadOS 26.5 iPad Pro 11" portrait (medium: tabs and +, the + opening Add and fading under it), iPhone 17 Pro launch. Dark mode on the native tabs and real devices: M21.
- **Follow-ups:** in small iPadOS 26 windows the window controls cover the page title (the Flutter shells too); opening the sidebar over the content moves the page up as iPadOS turns the top bar into the sidebar.
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test` 6,980 passing (5 local-Supabase suites need a running stack); new `test/data/shell/native_tab_bar_test.dart`.

### ED-375 · M18.6 part 3a: the Mac's own right-click menus and ⌘⌫
- **Date:** 2026-11-18. **Owner:** "Yes, as proposed" (back up the Mac app's data before each Mac run and restore it after, since the redesign shares the bundle id), then "Approve, start 3b" on the part 3a review page (the Inbox row's menu in the Mac app, dark). Part 3 is split into 3a (menus and ⌘⌫) and 3b (the vibrancy sidebar).
- **Built (ED-239, CR-098, ED-336, ED-260):**
  - `ContextMenuBridge.swift` (Runner target; no new target or package): one `dottoday/context_menu` channel. Flutter sends the items (label, SF Symbol, enabled, key hint); the bridge pops an `NSMenu` at the click and answers with the chosen index, or nothing when dismissed. The system gives it its look, keyboard navigation, VoiceOver, Increase Contrast and dark mode;
  - Flutter: `showContextMenu` (`shared/menus/context_menu.dart`) is the one entry point for right-click and long-press menus. The Mac app uses the system menu; the web, the other targets and a Mac build without the bridge keep Flutter's menu. `NativeContextMenu` (`data/shell`) holds the channel;
  - the Inbox row's menu is the first user: Schedule (`calendar`), Move to Trash with the ⌘⌫ hint (`trash`), Select (`checklist.unchecked`); SF Symbols only in this native menu;
  - ⌘⌫ moves the picked task to the Trash on Mac (`task_keys.dart`, beside Delete); a focused text field keeps ⌘⌫ for itself.
- **Checked in the Mac app:** the Inbox row's right-click menu in dark mode, with its icons and the ⌘⌫ hint. The Mac app's data was backed up before the run and restored after (checksums equal). Other menus move to the system menu as their screens are built (M19 onwards).
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test` 6,986 passing (5 local-Supabase suites need a running stack); new `test/shared/menus/context_menu_test.dart`, two ⌘⌫ tests in `task_keys_field_test.dart`.

### ED-376 · M18.6 part 3b: the Mac's vibrancy sidebar
- **Date:** 2026-11-18. **Owner:** "Approve, start 3c" on the part 3b review page (E-v1.45 Mac Full Workspace light and dark beside the Mac app), taking the three recommendations: Q1 the solid dark sidebar is `#28232A`; Q2 A, the system's material stays as it renders; Q3 A, the full-height sidebar under the window buttons is part 3c.
- **Built (ED-130, ED-176, ED-178):**
  - `WindowMaterialBridge.swift` (Runner target; no new target or package): the window's root is an `NSVisualEffectView` in the sidebar material (behind-window, following the window's active state), with the Flutter view on it over a clear background. One `dottoday/window_material` channel: `vibrant` (false with Reduce Transparency or Increase Contrast on), `changed` when either setting changes, and `appearance`;
  - Flutter: the expanded sidebar paints the `sidebarTint` token over the material, `#EFE7DB` at 35 % light and `#3B2F2A` at 30 % dark; the shell paints the content opaque. Without the material the sidebar is solid `canvas` (`#EFE7DB` / `#28232A`, Q1). `sidebarVibrancyProvider` and `setWindowAppearance` live in `data/shell/window_material.dart`;
  - the window takes the app's Light/Dark setting (`WindowAppearance` above every route), so the material and the title bar follow a theme chosen in Settings, not only the system's;
  - the dark Mac sidebar's current place reads in the primary text `#F3ECE4` (ED-176); its icon keeps the accent text (I1 `#A3E2D9` with teal, ED-178);
  - only the Mac app: the web, iPad and Android sidebars and the folded rail stay solid.
- **Measured in the Mac app (this Mac):** light sidebar `#E9E6E4` (spike average 230, 227, 221), ink 12.9 : 1; dark `#514E4C`, primary text 7.1 : 1 (the board draws about `#332D32`; the material blends the desktop, Q2). The Mac app's data was backed up and restored (checksums equal).
- **Not checked live:** Reduce Transparency and Increase Contrast (system settings; covered by tests), VoiceOver and other wallpapers (M21).
- **Checks:** `flutter analyze` clean; `dart format` clean; navigation, shell, menus, policy, core, app shell and a11y tests pass (1,334); new `sidebar_material_test.dart`, `window_material_test.dart`.

### ED-377 · M18.6 part 3c: the full-height Mac sidebar under the window buttons
- **Date:** 2026-11-18. **Owner:** Q3 A on the part 3b review (ED-376), "Doesn't drag" on the first build, then "Works, approve 3c" after the fix, on the part 3c review page (E-v1.45 Mac Full Workspace dark beside the app before and after).
- **Built:**
  - the Mac window's content fills it (`fullSizeContentView`) under a transparent title bar with no title, so the sidebar's material runs to the top edge with the window buttons over it, as the board draws it;
  - `TitlebarDragStrip` (in `WindowMaterialBridge.swift`): an invisible native strip over the title bar's height, above the Flutter view and below the window buttons. Under a transparent title bar the Flutter view took the mouse, so the window couldn't be dragged (the owner's check); the strip gives drags to the window and a double click to the system's choice (zoom, minimize or nothing). It hides in full screen;
  - the bridge reports the strip's height on `titlebar` (28 pt here, 0 in full screen, sent again on entering and leaving it); `MacWindowChrome` (was `WindowAppearance`) adds it to the top inset, so the sidebar and every page keep their controls out of the strip without knowing about it. Other targets add nothing;
  - the window opens at 1280 × 800 for the whole window, the strip included; the minimum stays 840 × 640 (ED-169).
- **Checked in the Mac app:** dark, the buttons over the sidebar; the owner dragged the window by the strip and double-clicked it. The Mac app's data was backed up and restored (checksums equal).
- **Not here:** the week toolbar level with the window buttons (Today ‹ › and the date range) comes with that toolbar (M19/M20); until then the page header sits below the strip.
- **Checks:** `flutter analyze` clean; `dart format` clean; shared, shell, policy, core, app shell and a11y tests pass (1,959); new inset tests in `window_material_test.dart` (28 pt on Mac, 0 in full screen, nothing elsewhere).

### ED-378 · M18.7 part 1: one keyboard scheme
- **Date:** 2026-11-18. **Owner:** "Five parts" for M18.7 (1 keyboard scheme, 2 tablet keyboard overlays, 3 web routes A′, 4 Settings's native place with Back and dismiss, 5 Full ↔ Minimal mid-action; each with its review page and commit), "Second native window now" for the Mac Settings window in part 4, then "Approve, start part 2" on the part 1 review page.
- **Built (ED-095, CR-143/ED-218 noted below):**
  - the command table (`app_shortcuts.dart`) gains New Brain Dump… ⇧⌘N, Paste as Tasks ⇧⌘V (Add opens with the clipboard's list), Today ⌘T, Back ⌘[, Search ⌘F and Show Less / Show Everything ⇧⌘L; `app_openers.dart` opens the sheets on the root overlay;
  - ⌘1–4 by layout: Full Today · Inbox · Week · Month; Minimal Today · Inbox · Calendar (the month) · Search. ⌘1 opens Today in Minimal until `/now` exists (part 3);
  - ⌘T asks the focused screen first: Today, Week and Month go back to their current day, week or month (built behaviour, "nothing built is reassigned"); anywhere else it opens Today. The Go menu's Previous / Next Day step the week or month there;
  - a picked task: ⌘D Done, ⇧⌘M Move To…, ⇧⌘F Focus; Today: ⇧⌘C Copy Day as Text;
  - the web: single keys stand in for the ⌘ keys the browser keeps (1–4, n, ⇧N, t, `[` `]`, /, ?, f, p, ⇧L); ⌘D, ⇧⌘C and ⇧⌘M are left to the browser there. Single keys act only outside text fields and can be turned off: Settings › Look and Language › Single-key shortcuts, web only (WCAG 2.1.4; Settings has no General group, so it sits beside Language). Stored in the synced settings as `webSingleKeys` (the server ignores keys it doesn't know; no migration);
  - the Mac menu bar: File › New Brain Dump…, Paste as Tasks; Edit › Copy Day as Text; View › ⌘1–4 named by layout, then Show Less / Show Everything; Go › Back, Previous / Next Day, Today ⌘T, Search ⌘F;
  - the ⌘/ list shows each platform's keys (the web's single keys; Minimal's ⌘3 and ⌘4).
- **Later, each with its feature:** ⌘K / k with the Search-or-run palette (not built); ⇧⌘T / g Go to Date (M19, R2-36); ⌥⌘I Inspector (M19.2) and Day Column (M19.6), ⌃⌘S Show Sidebar and ⌥⌘0 Now window (M19.2); ⌘] Forward and the web's history (part 3); the iPad and Android overlays (part 2).
- **Checked in the Mac app** (keys sent through Accessibility, which the owner turned on): ⌘/, ⌘3, ⌘→ then ⌘T, ⌘F, ⇧⌘N, ⇧⌘L, Minimal ⌘3, ⌘[, ⌘1. The Mac app's data was backed up and restored (checksums equal).
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test` passing apart from the 5 local-Supabase suites; new `keyboard_scheme_test.dart`, Mac menu key test, ⌘D / ⇧⌘M / ⇧⌘F on a picked task. The backup fixture records the new setting's default; the icon names were moved back to the end of the language files by their generator; the pseudo-locale was regenerated.

### ED-379 · M18.7 part 2: the app's menus in the iPad menu bar and Android's shortcut list
- **Date:** 2026-11-18. **Owner:** "Approve, start part 3" on the part 2 review page (E-R2-10's system lists beside the app in the iPadOS 26.5 simulator and the Android tablet emulator, API 37). Earlier the same day: "Yes, delete app/build" when the disk filled during the Android run.
- **Built (R2-10, ED-287, ED-288, ED-095):**
  - one list of the app's menus, `app_menus.dart`: the Mac menu bar draws it with the system's own items (About, Services, Hide, Quit, Full Screen, Window), and `app_native_menus.dart` sends it to iPadOS and Android over `dottoday/key_menus` when it changes (a language or layout switch);
  - iPad (and iPhone with a keyboard): `KeyMenusBridge.swift` builds UIKit menus from it, Settings… ⌘, in the app menu, File, Edit and View items first in theirs, Go as its own menu after View, with a `UIKeyCommand` per key. A choice comes back as `select` with its id, and Flutter runs the same handler as the Mac. Undo, Redo and Delete stay the system's for text;
  - iPadOS's own Find held ⌘F, and UIKit dropped all of the app's menus over the repeated key: the system Find item is removed (it works only on UIKit text views, which Flutter doesn't use); ⌘F is Search (ED-095);
  - Android: `KeyMenus.kt` fills `onProvideKeyboardShortcuts` with the commands that have keys, grouped by menu, Ctrl and Shift; the keys stay Flutter's.
- **Checked:** iPadOS 26.5 simulator (iPad Pro 13"): the menu bar's Dottoday, File, View and Go menus with their keys; Go › Search opened Search and the native tabs followed. Android tablet emulator (API 37): Meta+/ lists Dottoday's groups. Holding ⌘ with a hardware keyboard and a physical Android keyboard: M21. The Mac menu bar's labels and keys are covered by its tests on the shared list.
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test` passing apart from the 5 local-Supabase suites; new `app_native_menus_test.dart`.

### ED-380 · M18.7 part 3a: links in, `?task=` with Back, Forward and Refresh
- **Date:** 2026-11-18. **Owner:** "Nearest built screen" (addresses of places not built yet), "Keep Week tab for now" (phones' `/week` until M19.1), then "Approve, start 3b" on the part 3a review page. Part 3 is split: 3a links in, 3b the address following the shown date.
- **Built (ED-097 A′, ED-242, CR-068):**
  - addresses: `/week/<date>` and `/month/<yyyy-MM>` open Week and Month there; `/now` opens Today and `/3-days/<date>` that day until Now and 3 Days exist;
  - the link guard (D2): a view (Today, a day, Inbox, Week, Month, Search) keeps exactly one `?task=` with a lowercase UUID v7; any other query is dropped and the path kept (any query used to send the link to Today);
  - rule T: `/task/<id>` redirects to the task over its own date (Inbox without a date, Today, or `/day/<date>`), read when the link opens, in the profile's zone; gone, in the Trash or not the signed-in user's → Today, nothing said. A redirect, so no Back step. The full-screen task page is removed; tests keep its frame in `test/support` so their goldens don't change;
  - `GoRouter.optionURLReflectsImperativeAPIs` is on (CR-068);
  - `TaskLinkHost` above every route keeps the open task and the address in step: the panel at the expanded width, the sheet elsewhere; losing `?task=` closes it; closing it by hand is a Back step when it was opened here (the browser's own Back) and a replace when the address arrived with it. `openTask` writes `?task=`; every opener goes through it (Today, Inbox, Search, Focus, the Wake Up card, the all-day chips, the hint row, ↩); from a page that can't carry a task, rule T;
  - ⌘] Forward in the apps reopens what ⌘[ just left; the web keeps the browser's.
- **Found while testing:** the host sits above the Router, so its replace asks from the navigator's context; a sheet waits for the address's page before opening; the task check listens to the profile while it reads (Riverpod 3 pauses an unlistened provider). A fixture's imported events got UUID v7 ids, as the import makes them.
- **Checked in the browser** (web build, phone width, local data): open, Refresh, Back, Forward, close by hand, `#/task/<id>` with one history entry, `#/day/<date>?task=` after Refresh, an unknown id → Today.
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test` 7,043 passing (5 local-Supabase suites need a stack); new `app_task_links_test.dart`, router and guard cases.

### ED-381 · M18.7 part 3b: the address follows the day, week and month
- **Date:** 2026-11-18. **Owner:** "Web history only" (date steps are Back steps in the browser; in the apps the address changes in place and Back keeps its meaning; an ED-097 clarification), then "Approve, start part 4" on the part 3b review page.
- **Built (ED-097 A′, "the address always shows what is on screen"):**
  - `/today` and `/day/<date>` are one page in the Today tab; `/week` and `/week/<date>` one page in the Week tab; `/month` and `/month/<yyyy-MM>` one page. Stepping changes the address, not the page: no transition, and the tab, its bar and sidebar stay (a `/day` link used to open outside the tabs);
  - Today, Week and Month read their date from the address; the week and month selection providers are removed, and Today's keeps only the month grid (open, which month). `/today`, `/week` and `/month` follow the clock;
  - `showPlace` is the one way to step: on the web a new history entry; in the apps the address changes in place, and a pushed Month keeps what is under it. An open task's `?task=` is kept;
  - Show Less / Show Everything still doesn't navigate, so it keeps the date and the open task (ED-067).
- **Checked in the browser** (web build): strip taps `#/day/2026-11-20`, `#/day/2026-11-19`; Back, Back, Forward; Refresh keeps the 20th; Week › `#/week/2026-11-23` at desktop width.
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test` 7,045 passing (5 local-Supabase suites need a stack); the Today goldens unchanged; new address checks on Today, Week and Month and `show_place_test.dart`.

### ED-382 · M18.7 part 4a: Settings behind the profile on phones
- **Date:** 2026-11-18. **Owner:** "Approve, start 4b" on the part 4a review page, accepting its two layout changes. Part 4 is split: 4a phones and web, 4b the Mac's Settings window.
- **Built (ED-238 G2-3 A, ED-234, ED-235):**
  - "Settings and account": the profile's circle at the end of Today's top row at phone width (44 pt / 48 dp, named for screen readers); it remembers the address it was pressed on, and Settings' Back button and Android Back return there. Minimal phones have it too, beside the Day menu's Settings (ED-093);
  - the phone bars (iPhone pill and native row, Android toolbar, mobile web) list Today · Inbox · Search; on a Settings page none is selected. The iPad's native tabs keep Settings in their sidebar; tablets, Mac and web keep it at the foot of the rail or sidebar;
  - one `ProfileAvatar` for Settings' header and the button;
  - Esc closes the task sheet and removes `?task=` (app sheets already closed on Esc at every width).
- **Layout changes the button forced (owner accepted):** Today's phone title is the short date, "Wed, Nov 18 ⌄", as E-Phones draws it (ED-040), because the long date wrapped; Low energy's switch sits on the second line beside its caption. The Sync-and-profile glass capsule (ED-034) and its spacing come with M19.1.
- **Checked:** iPhone 17 Pro simulator (iOS 26.5): three native tabs, the profile opens Settings, Back returns to Today. Android and devices: M21.
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test` 7,041 passing (5 local-Supabase suites need a stack); new `settings_button_test.dart` and the Esc test; 152 goldens regenerated for the intended change.

### ED-383 · M18.7 part 4b: the Mac's Settings window deferred; ⌘W closes the window
- **Date:** 2026-11-18. **Owner:** "Same engine, two windows" (over a second engine), then, after the spike failed, "Settings stays a page", then "Commit, start part 5". Earlier: "Second native window now" (M18.7 split).
- **Finding:** on stable Flutter 3.47.8 a second macOS window can't share the running engine. Attaching a `FlutterViewController(engine:)` for it throws "The engine already has a view controller for the implicit view": the engine is in single-view mode. Multi-view needs the engine's private `enableMultiView`, called before the main window's controller exists, and the app started with `runWidget` instead of `runApp`: the experimental windowing path. A second engine would need its own database connection, a change bridge, and care around sign-in, account deletion and imports.
- **Decision (owner):** Settings… ⌘, keeps opening Settings in the main window, as built; ED-238's Mac entry ("its own window") waits for Flutter's stable multi-window API. The window code from this part was removed, nothing layered. **Follow-up:** the Mac Settings window, when Flutter's multi-window API is stable (plan, M18.7 part 4).
- **Built:** ⌘W closes the main window, as on every Mac window (rules §13.3): the app's menu bar replaces the system's and has no Close item. The last window closing quits Dottoday, as it already did.
- **Checked in the Mac app:** ⌘W closed the window and the app quit. The spike's crash and a copy of the app macOS reopened after it were quit; the Mac app's data was restored and checked after each run (checksums equal).
- **Checks:** `flutter analyze` clean; the Dart side is unchanged since ED-382 (`flutter test` 7,041 passing there).

### ED-384 · M18.7 part 5: switching Full ↔ Minimal mid-action
- **Date:** 2026-11-18. **Owner:** "Approve, close M18.7" on the part 5 review page.
- **Built (ED-100):**
  - an unfinished drag is cancelled: `DragSession` counts each drag start (in `HoldOrMouseDraggable`, which every drag uses), a switch voids every drag begun before it, and all six drop targets (the thread twice, the week strip, Week's day column, Trash, Inbox) refuse a void drop, so nothing is written and no Undo is made; the drag's Trash and Inbox targets go (`LayoutSwitchGuard` above every route). Before the first switch every drop is live;
  - a multi-selection clears itself on a switch, applying nothing; a batch already confirmed keeps its Undo;
  - the selected date and the open task stay: both are the address (ED-380, ED-381) and switching doesn't navigate; the open sheet redraws in its Minimal form;
  - Undo survives the switch;
  - unsaved text isn't dropped: the Mac/web editor writes a pending change when it closes, so a title typed just before the switch is saved and shown in Minimal's sheet; Add's draft lives outside its sheet (built). ED-100's Keep editing / Discard question isn't needed;
  - proposal sheets are untouched by a switch and write only on Accept (proposal rule).
- **Checks:** `flutter analyze` clean; `dart format` clean; `flutter test` 7,047 passing (5 local-Supabase suites need a stack); new `switch_mid_action_test.dart` (6). The full run caught that drops were refused before any switch; fixed.
- **M18.7 done** (ED-378 to ED-384). Follow-up: the Mac Settings window (ED-383).

### ED-385 · M18.8: acceptance and ship-check; M18 closed
- **Date:** 2026-11-18. **Owner:** "fix all that is open before we move on to approve and close", then "Approve, close M18".
- **Gate:** `dart analyze --fatal-infos` and `dart format` clean; 7,050 tests pass, and the 5 Supabase suites pass on the isolated test stack (11 tests; pgTAP 238/238); coverage `lib/domain` 95.9 %, overall 90.9 %; parity matrix 91 rows, 0 lost, 10 moved, each still reached on every platform it had; web, Android, macOS and iOS-simulator builds pass locally; the iOS device suite passes 11 of 11 on the iPhone 17 Pro simulator (exactness 20/20/0, AlarmKit, the design sweep with 55 shots and 39 accessibility-tree checks).
- **Fixed at the gate:**
  - a hint write read the app's state after an app restart had disposed it: `_change` in `hint_providers.dart` reads the container before its first await;
  - the day sheet (`DayCard.sheet`) overflowed by 2–4 px when squeezed to about 90 px (older than M18): below the short-card height its handle and Plan / Reality switch scroll with the thread, as the card's header does (`day_card_sheet_squeeze_test.dart`);
  - device tests still looked for Flutter tab labels and the old task page (the native iPhone bar, ED-373; `?task=`, ED-380): `app_launch`, `deep_link` and the sweep go by the address (`sweepGo`), and the sweep scrolls rows clear of the floating bar before tapping;
  - the M18.6 plan line named an iPhone native Day menu that ED-373 moved to M20.3.
- **Noted for the owner:** on phones Settings opens only from Today's profile; on the web, single keys off leaves 1–4 and N without a key. Two sweep runs were cut short by the test simulator shutting down mid-run, cause not found.
- **M18 done** (ED-357 to ED-385). Next: M19, the first vertical slice.

### ED-386 · M19.1: Today in Full on phones, as E-Phones draws it
- **Date:** 2026-11-18. **Owner:** "Follow the board" (the day on the page, no raised sheet), "Drop the ring", "Drop them, as drawn" (strip dots), "One part"; for the empty day "Board's three + Copy a day"; the tip bar at no preference, on Claude's recommendation; then "Approve, commit" on the review page.
- **Built (E-Phones frames 1, 5 and the empty day; G3-1, ED-104; ED-034; ED-040; ED-336; ED-347):**
  - top row: iPhone's 28 bold date with a teal chevron, Android's 24 top-app-bar title; Sync and the profile in one glass capsule on iPhone (48 tall: the board's 44 plus 4, so Sync keeps the device sweep's 48 target), bare on Android; at the medium width Sync alone. The day ring leaves Today's header (Week and the Mac spread keep it, M19.2); ⋯ stays until the Day ▾ chip (M20.3). Away from today "‹ Today" leads the row; a title that does not fit beside the buttons moves under them, never broken mid-word, and an open month reads "Dec 2026" on phones;
  - Sync: the board's glyph, a teal dot while synced, a badge counting changes that need you, its state in words for a screen reader (R-08), a tap opens the Sync sheet; the per-state icons and words stay in M20.10;
  - summary "2 of 13 done · 10 h planned" (en/de/fr/es);
  - week strip: iPhone a letter over a 34 circle, today teal, another picked day ink; Android "Wed" over the date in a 52 × 60 tonal pill; no completion dots in either layout (docs/14 note updated); a pull down on the strip opens the month;
  - the day straight on the page (`DayCard.page`): no raised sheet, no handle; the Plan / Reality switch stays over the thread;
  - empty day inside the thread's free time: the free hours (today: what is left after now), the board's line, Add a task, Drop a routine, Pull from inbox · n, then Copy a day… (kept, no other way to it); days of repeats only keep the actions under the thread; Minimal unchanged (M19.6);
  - Today's tip on the board's tinted bar (Full only: E-PhonesMinimal draws none);
  - phone landscape: the strip folds into the title row, the numbers beside the title;
  - phones' `/week` opens Today on that date (`PhoneWeek`; phones have no Week in Concept E, Calendar is M20.1).
- **Tokens:** glass top, bottom and edge colours (light and dark), the capsule shadow, capsule, strip and empty-day sizes, strip, badge and empty-title type, the sync glyph.
- **Checks:** `dart analyze --fatal-infos` and `dart format` clean; 7,079 tests pass and the 5 Supabase suites pass on the isolated stack (11; pgTAP 238/238); new `today_e_phones_test.dart`, `phone_week_test.dart` and Android, empty-day and tip goldens; goldens regenerated for the intended change. iPhone 17 Pro simulator by hand and the device suite's `journey`, `app_launch` and `sweep` (55 shots, 39 accessibility-tree checks). Android devices: M21.
- **Found on the way:** the title fit measured with the test font (now the inherited style); Sync's 44 pt target failed the sweep's 48 floor; the sweep's Minimal leg could tap the live dot (Focus) depending on the hour; the shared caption style was briefly changed and restored (`stripLetter` added instead).

### ED-387 · M19.2 part 1: the Workspace sidebar, toolbar and Plan panel
- **Date:** 2026-11-18. **Owner:** "Three parts" (M19.2), "Open Search" (the toolbar's Search or run until the palette), "Yes, existing items" (Day ▾ opens today's Day menu), "Pointer sizes, 24 floor" (Mac and mouse-driven web), "Day view on today" (the sidebar's Today; Plan the view last chosen), "Yes, build 1b next" (1a and 1b committed together), then "Approve, commit" on the review page.
- **Built (E-FullA-v2, ED-073, ED-080, ED-184, ED-260, ED-261, ED-333):**
  - the views are addresses: `/today` and `/day/<date>` Day, `/3-days/<date>` 3 days (a real view now, the spread), `/week/<date>`, `/month/<yyyy-MM>`; Month moves into the Week tab's branch so it keeps the shell;
  - the Workspace sidebar in Full: Today (today's done/planned) · Plan with a fold (Inbox with its count, Routines, Brain dump) · Calendar views (Day, 3 days, Week ⌘3, Month ⌘4) · Review · Search ⌘F, Sync's line at the foot, Settings at the web's foot (the Mac's is Dottoday › Settings… ⌘,); Minimal keeps its list of places (M19.6);
  - the toolbar over Today, Week and Month: the Plan panel button, ‹ Today ›, the date or range (a month to pick a day), Day / 3 days / Week / Month, Day ▾ (today's Day-menu items until M20.3), +, Search or run (opens Search; its icon alone in a narrow toolbar, rules §12.3); the left group wraps at large text; the screens drop their own headers there (Week keeps its cues);
  - the Plan panel (rules §9.16): Capture, Inbox cards (drag onto a day, tap to open), Routines (a tap proposes on the shown day), Brain dump (Plan it opens Brain dump with the lines; nothing is added before Accept); docked while the week keeps 3 days, hidden by its button, brought out over the view while hidden (Esc, a click away, the pin docks it), View › Show Plan Panel ⌥⌘P; width 176–300 by its edge (past the minimum hides it), hidden state and folds kept in `local_meta`, never synced. It replaces the Concept A Inbox column (`InboxSidebarFrame` removed);
  - sizes: pointer sizes on the Mac and mouse-driven web (30-tall rows and controls, 13 pt), the accessibility checks a 24 px floor there (WCAG 2.5.8) and keep 44 / 48 on touch; touch-first windows use 48 targets;
  - ⌥ in the menu model: the Mac menu bar, the iPad's key commands and Android's shortcut list.
- **Not built, by plan:** the hour grid, the inspector and Month as cards (part 2); tablets' touch values and the narrow Mac (part 3); dragging a routine onto a day and opening the panel from the grid's edge.
- **Checks:** `dart analyze --fatal-infos` and `dart format` clean; 7,091 tests pass and the 5 Supabase suites pass on the isolated stack; new `workspace_test.dart`, `app_plan_panel_test.dart`, Mac Workspace goldens; goldens regenerated for the intended change. Not run on a Mac or in a full-width browser yet.

### ED-388 · M19.2 part 2a: the hour grid
- **Date:** 2026-11-19. **Owner:** "Three: grid, drag, inspector+Month" (part 2 split as 2a, 2b, 2c), "Days that fit, scroll for more" (Week), "Click: inspector; double-click: editor" (for 2c), "The thread on hours, as drawn" (Day), "Week's blocks, wider columns" (3 days), then "Approve, commit" on the review page.
- **Built (E-FullA-v2 Week and web Day, E-R2-30, ED-333):**
  - one hour grid for Week and 3 days: 84 px an hour, the 44 hour gutter (wider at large text), columns of at least 144 that share the width and scroll sideways when the days don't fit; day headers (weekday, date, "4 done" / "3 planned"; today tinted, its date in the accent circle, "3 of 9 · 7 h 40"); 3 days' headers from E-R2-30 ("Monday 2 November · Yesterday" over "4 of 4 done");
  - per column: hour lines and divider, today's tint, the 4 px thread behind the blocks (solid in the task colours to now, dotted ahead), blocks as tall as their time with the 32 ring on the thread, a 21-tall pill under 30 min, overlapping tasks side by side in lanes; the now line across the grid, stronger on today with its dot, its time in the gutter; the grid opens two hours above now; a drop shows a dashed accent box with the day and time;
  - 3 days replaces the spread (yesterday, the shown day, tomorrow); ‹ › and Go › Next / Previous Day keep 3 days; low-energy mode still shows today's next dot alone;
  - Day: the thread on hours at 70 px an hour (tasks and free gaps at least as tall as their time, each hour labelled once in the gutter with its line), under a header line with the day's counts, Wake Up and Wind Down; the thread keeps 640 wide.
- **Removed (replaced by the grid in this commit):** the 3-day spread, the side-day columns (`DayCard.side`), the thread's side mode and its "drop here to plan" box, three unused strings; Week's capacity rings and the Busiest / Lightest tags under the headers (the cue chips stay).
- **Open, asked on the review page:** the "Drop a task here" boxes under each open day (not on the board); Day's rows keep the Mac row layout rather than the board's stacked time; now is its own row under the live card on Day.
- **Checks:** `dart analyze` and `dart format` clean; all non-golden tests pass (the 5 Supabase suites need the stack); 92 expanded-width goldens re-baselined; new `day_hours_test`, lane tests in `week_layout_test`, `today_three_days_test`, Workspace goldens for Day, 3 days and Week. Not run on a Mac or in a full-width browser yet.

### ED-389 · M19.2 part 2a follow-up: as Concept E draws it
- **Date:** 2026-11-19. **Owner,** on ED-388's open questions: the drop boxes and Day's rows "make sure it is like the current concept E"; now on Day: "draw both let me see", then "it should be like E-FullA-v2 web Day: the now line runs across the live card at 10:42, a dot on the thread and "10:42" in the gutter"; then "Approve, commit".
- **Built:**
  - no "Drop a task here" boxes on the hour grid (Week, 3 days), as E-FullA-v2 draws it; add from + or the Day menu, and drop onto any time in a column; the string is removed;
  - the day thread's rows and the live card keep the time above the title at every width (E-FullA-v2 web Day, E-Phones); the side-by-side layout from 440 px (the old Mac spread card's) is removed, so medium windows and phone landscape stack too;
  - on the Day view, when now falls inside the live task, the now row is not drawn: the line crosses the live card at the time, with the dot on the thread and the time in the gutter (`ThreadHours.nowIn`); the live row carries "Now, {time}" for screen readers; between tasks and on phones now keeps its own row. At large text the row grows with its text, so the line can cross the time line.
- **Checks:** `dart analyze` and `dart format` clean; all non-golden tests pass (the 5 Supabase suites need the stack); 114 goldens re-baselined; new tests for now inside the live row and between tasks. Not run on a Mac or in a full-width browser yet.

### ED-390 · M19.2 part 2b: hover, focus, keys and drag on the hour grid
- **Date:** 2026-11-19. **Owner:** "Go, start 2b", with four answers: the drag and the Alt-arrow moves use Settings' snap step; "Yes: Alt ↑↓ and Alt ←→"; a drag moves one task, not the ones after it; the lift appears at once, with no scale. Then "Approve, commit" after the review page.
- **Built (Week and 3 days, ED-116 hybrid C):**
  - flat at rest; a mouse hover tints the block to `sunk` with a `blockEdge` hairline and no lift; touch never shows hover;
  - while dragged, a copy the block's own width lifts with `DotElevation.blockLift` over everything it crosses; the block left behind fades and the dashed drop shows where it lands; the drop moves that one task, with Undo;
  - keyboard focus draws the 2 px `focus` ring after a 2 px `canvas` gap; Alt+↑ / Alt+↓ move by the snap step and Alt+← / Alt+→ move a day, each with Undo; screen readers get the same four as custom actions ("Move earlier", "Move later", "Move to the day before", "Move to the day after");
  - drags snap to `Settings.snapMinutes` (5 by default), no longer a fixed 15;
  - high contrast keeps a `secondary` edge in every state;
  - calendar events and pinned tasks get no hover, drag or moves.
- **Tokens:** `blockEdge` (light `#241F2B` at 10 %, dark `#FFF5EB` at 13 %), `DotElevation.blockLift`.
- **Copy:** es "Retrasar" failed the no-shame check (it reads as running late), so es uses "Mover antes" / "Mover más tarde".
- **Checks:** `dart analyze --fatal-infos` and `dart format` clean; all non-golden tests pass (the 5 Supabase suites need the stack); one new golden pair (`workspace_grid_states`, light and dark: focused, dragged, hovered); new tests for hover, Alt-arrow moves with Undo, the semantics actions, high contrast and the lifted copy. Not run on a Mac or in a full-width browser yet.

### ED-391 · M19.2 part 2c: the Workspace inspector and Month as cards
- **Date:** 2026-11-19. **Owner:** "Go, start 2c", with four answers: the inspector is hidden until a task is picked (Esc or a click on free grid puts it away, ⌥⌘I still shows or hides it); its rows are editable now, saved as you go (ED-086); a second click opens the editor in its place; Month matches E-R2-30 exactly. Then "Approve 2c" after the review page (the subtasks captured on request).
- **Inspector (E-FullA-v2, ED-170 C1, rules §627):**
  - a click on a task on Day, 3 days or Week picks it: `?task=` carries it (E-FullA-v2's address line), so Back puts it away and Refresh keeps it; opening the task that is already picked (a double-click, a later click, ↩ again or a screen reader's second activation; no timing window, so keyboard and screen-reader users reach it) opens the 420 editor in its place, a click on another task while the editor is open moves the editor to it, and closing the editor brings the inspector back on the same task;
  - 248 wide on the toolbar's `sunk` ground; docked from 1160 when the grid keeps 3 days of 144 and its hours (476), otherwise a card over the grid; the same tree either way, so a resize keeps what is typed; it exists only where a Workspace frame is mounted (`InspectorFrames`), so other hosts keep the panel or the sheet;
  - contents as drawn: the 38 ring with the title 18/23 and "Now, 18 min left" (or the time); Need more time? +5 +15 +30 while the task runs (ED-163); Done, Focus, Shift rest (Shift rest only while the task runs into the next); Date, Time (start and end typed, the length beside them), Repeat, Alerts as chips with Add alert; Subtasks with boxes (this occurrence only, R-09; the section is left out when there are none); the first overlap with its knot; Notes;
  - every change is one undoable write as it is made, starting from the task as it is now (a Done or a drag in between is never written over); notes save after a pause and on leaving; a failed write says so with Try again (R-08);
  - the picked block has the 2 px ink edge and reads as selected;
  - ⌥⌘I, View › Show Inspector (Full) and the toolbar's last button show or hide it (ED-218); not saved. Month has none: a day opens that day;
  - a task that goes (deleted, another owner) takes the inspector with it.
- **Month (E-R2-30, ED-333):** the title 26/800 and its numbers in the Workspace; weekday heads in capitals 11/700; cards 104 tall, radius 12, hairline edge, today's teal edge; the date 13/800; three task lines 11.5/600 that wrap rather than end in "…" (the pseudo-locale sweep found de/fr/es losing words) (done struck, "· not done", "· now"); "+N more" in teal; "N of M done" on every day with tasks; Light day on a day with none; the days of the months either side as faded numbers without a card or a tap. No colour dots and no completion badge. Phones keep their own Month.
- **Also:** the toolbar decides its compact Search from its own width, so the docked editor beside it no longer overflows it, and the inspector button is left out of a compact toolbar; Day and 3 days keep the grid inside the Workspace however narrow the content box is (with the Plan panel and the inspector open they fell back to the phone layout); the now line and drop preview no longer take clicks; `TimeInput.compact` for the inspector's boxes.
- **Minimal:** the inspector lives inside the Workspace, which is Full only (`FeatureId.spread`); no new row.
- **Not in this part:** the picked row's edge on the Day view (the Day view picks and opens, but its thread rows have no selected look yet); the Month cards' arrow-key navigation (handoff line 118).
- **Checks:** `dart analyze --fatal-infos` clean, format clean; all 2446 goldens pass (new: workspace_inspector, workspace_editor, workspace_month_mac, light and dark; Workspace and Month re-baselined); all other tests pass except the 5 Supabase suites, which need the local stack. Not yet run on a Mac or in a browser.

### ED-392 · M19.2 part 3a: the Workspace at touch sizes on expanded tablets
- **Date:** 2026-11-19. **Owner:** "Start part 3", with four answers: part 3 ships as 3a tablets and 3b the narrow Mac (with the Day rows' picked edge and Month card arrow keys); Day on tablets uses the grid's 96 an hour; long-press then drag on the tablet grid in this part; a picked Day row gets the 2 px ink edge (3b). For the half-cut line the a11y check found on Day: "Fix it in the app". Then "Approve 3a" after the review page.
- **Touch grid (E-R2-2, ED-269),** wherever the Workspace runs at touch sizes (iPad, Android tablets, touch-first web; `watchTouchContent`, ED-261), on Week, 3 days and Day:
  - 96 px an hour (Day too, owner); columns at least 180 under a 60 header; hour labels and day meta 13;
  - block titles 17/21.25, times 13; rings 36, the live task's 45, at 6, 6 with 8 to the text;
  - under 35 minutes a task is a one-line pill, title 15, at least 20 tall; its dot 28 from 44 tall and 24 below; corners at most 16;
  - an overlap keeps the earlier block across the whole column and stacks the later one over it, one ring (36) further in to the same right edge, raised with a 1 px ring at 10 % and `0 4 12` at 12 % (`DotElevation.blockOver`); the pointer grid keeps its side-by-side lanes;
  - the Plan panel needs 3 days of 180 (584) beside it before it docks; the inspector always floats over the grid.
- **Both scales:** when the days don't all fit, the grid opens with today in view, the day before it at the left (E-R2-2's Tue–Thu; the narrow Mac's "Today kept in view", ED-169).
- **Drag on touch:** hold, then drag, as on the phone thread (`DotTouch.liftDelay`), with the same snapping and Undo as the Mac; a plain swipe scrolls.
- **Code:** `GridScale` (pointer and touch values, handed down by `GridScaleScope` from `WeekView`) replaces the fixed `WeekScale`; `GridBlock` holds the draggable block so the day column stays under 300 lines.
- **Plan-panel rows:** E-R2-2's text says rows 60 and ED-269 says 56; the panel's Inbox and Routines cards already measure 56 or more at touch sizes, so nothing changes.
- **Day opens between rows (owner: "Fix it in the app"):** opening at now scrolls the now row's top to the top edge, so the line above is never cut in half (at 96 an hour the a11y check read a half-cut "30 min free" against the header strip); a live task too long for its now point to show from its top still opens at the now point less 32 (ED-336). Every device.
- **Goldens:** tests run on Android by default, so every wide grid golden without a platform now draws the touch scale: today, today_bottom, week, late_review, learning_reveal and reality re-baselined. New: tablet_week_ipad, tablet_week_android, tablet_day_ipad, tablet_inspector_ipad (light, dark).
- **Not in this part (3b):** the narrow Mac (E-G4-3-Narrow: the 840 toolbar's Week ⌄ pop-up, the status text below 1000), the Day rows' picked edge, Month card arrow keys.
- **Checks:** touch_grid_test (the scales, the Plan panel and inspector room, touch titles and columns, hold-then-drag with Undo); the tablet goldens; the shell a11y check at 400 and 1000, light and dark. Analyze and format clean; every test passes except the 5 Supabase suites, which need the stack. Not yet run on a real iPad or Android tablet (M21).

### ED-393 · M19.2 part 3b: the narrow Mac, the picked Day row and arrow keys between cards
- **Date:** 2026-11-19. **Owner:** "Start 3b", with two answers: plain arrow keys move between Week (and 3 days) blocks and between Month cards (the handoff's "Week" line, which ED-391 and ED-392 had called "Month card arrow keys"); the narrow toolbar's status text stays with the Minimal window (M19.6, ED-170), since the Full toolbar has none. The picked Day row's edge was answered at the split (ED-392: the 2 px ink edge). Then "Approve 3b" after the review page.
- **Narrow toolbar (E-G4-3-Narrow, ED-170, ED-183, rules §12.3):** one line at every width, giving up room in steps measured from its own content (`FirstThatFits`), not fixed window widths: "Search or run" to its icon with ⌘K (accessible name and tooltip kept); the Day / 3 days / Week / Month tabs to a "Week ⌄" pop-up (the tabs' track, a check on the shown view, named "Calendar view, Week"); the date without its year ("Oct 19 – Oct 25"; a screen reader still hears the year); then the inspector's button (⌥⌘I and View keep working). Only at very large text does the left group wrap (rules §12.1). Replaces the fixed 1100 / 1360 rule (`workspaceToolbarRoom`, removed). At touch sizes on a 1280 tablet the tabs now fold into the pop-up instead of wrapping.
- **The 840 window:** already the Mac minimum (`contentMinSize` 840 × 640); the inspector floats below 1160 (ED-391) and the week opens with today in view (ED-392).
- **Picked Day row:** the task the inspector shows gets the grid block's picked edge on the Day view's thread, 2 px in ink at the card radius, announced as selected; the live card too.
- **Arrow keys:** on Week and 3 days, ↑ ↓ go to the block before or after on the same day and ← → to the block nearest in time on the closest day either side that has one (mirrored right to left); at an edge the focus stays. Return opens the inspector, Alt with the arrows still moves the task (ED-390). On Month's cards ← → move a day and ↑ ↓ a week, over the month's own days.
- **Not in this part:** the Minimal window's narrow rules (the Day-column fold, the status text below 1000, the short-window now-dot) stay in M19.6. Narrow overlap lanes still break a long first word ("Desig n re…"); logged for the grid's overflow pass (rules §12.3).
- **Checks:** narrow_mac_test (the 840 toolbar, Week ⌄, the 1280 toolbar, the picked Day row, arrows on Week and Month); new goldens workspace_week_840 and workspace_day_picked (light, dark); the tablet goldens and workspace_editor re-baselined (the toolbar on one line). Analyze and format clean; 7146 tests pass, 31 skipped; the 5 Supabase suites need the stack. Not yet run in a real 840 Mac window.

### ED-394 · M19.3 part 3a: Create task on the phones
- **Date:** 2026-11-19. **Owner:** "Start M19.3", with four answers: three parts (3a phones, 3b the Mac and web popover R2-36, 3c tablets R2-3); one shared form built now, which M19.4's editor reuses; habit suggestions and routine chips kept below the form while the title is empty; ⋯ holds the More items. Then "Approve 3a" after the review page.
- **Create task (E-Phones ED-140, ED-141; E-Phones-2 ED-147, ED-149):** on compact widths + and ⌘N open Create task full height with the title focused. iPhone: Cancel · ⋯ · Create task over a native sliding segmented control; Android: × with the mode's title ("New task"), ⋯ and Create over M3 segmented buttons. Create and ⋯ show on the Task tab only.
- **Tabs (ED-152):** Task · Brain dump · Routine; a tab is built on its first visit and kept, so each keeps its draft and switching writes nothing. Brain dump and Routine come from their features through `AddModesScope` (core), wired in `app_add_modes.dart`, so Create task imports neither (CLAUDE.md §3).
- **The form (`shared/task_form/`):** the colour-and-icon ring with its palette badge and the title; When (date, time with its length as its own button, alerts); Repeat and Energy pills; steps ("Add a step") and notes. Everything set is kept in the draft's `AddDetails` and written with the task in one save (repeat's end, energy, notes, sound, travel, pinned). Android draws the When rows as one grouped card, mirroring the iPhone's grouping.
- **⋯:** Sound, Travel time, Pinned (checked), then Add to Inbox instead and Break it down (with a title). The Sound and Travel pickers moved to `shared/` for the editor and Create task both.
- **Return and Create:** the iPhone's return key is neutral (ED-135); with no time typed Create takes the first free slot (docs/10 §6); a failed save keeps Create task open with the draft and Try again repeats what failed (R-08).
- **Routine tab:** Drop on Today / Tomorrow / Other day…, the routines as rows with their steps' colours, Edit routines…; a tap closes Add and opens the drop's proposal, nothing written before Accept.
- **Departures from the board, recorded:** no done circle in the header; a pasted list still asks "Add 3 tasks?" in place rather than going through the proposal; the +'s hold hint and Android's mode menu are not built. Minimal keeps its own Add (ED-152); Mac, web and tablets keep the old Add until 3b and 3c.
- **Checks:** create_task_test (16: R-06 from three tabs, first free slot, Inbox, ⌘N, a failed save, the tabs, the Routine tab, the form's fields written, the iPhone header and return key, Minimal, a11y light and dark, 200 % text, Cancel); add_details_test (4); goldens create_task_iphone, create_task_android, create_task_routine_iphone (light, dark); the Add focus guards now check Create task. Analyze and format clean; 7166 tests pass, 31 skipped; the 5 Supabase suites need the stack. Not yet run on a real phone.

### ED-395 · M19.3 part 3b: the Mac and web Add popover with live chips
- **Date:** 2026-11-19. **Owner:** "Start 3b", with answers: the popover as drawn, its dot opening Colour and icon (repeat, alerts, energy and steps are set in the inspector after Add); every window from medium width gets it now (3c then swaps Android tablets to the side sheet and adds the iPad + menu); it always sits under the toolbar's +, however Add opens (⌘N or `n`, New Task, a grid slot, Siri); the old two-step Add stays for Minimal only, its Full-only parts removed. Asked during the build: a chip's × keeps its word as title text, as the board says; what Add learned (energy window, usual length, start tendency) goes under the time in the popover and in Create task. Then "Approve 3b" after the review page.
- **Popover (E-R2-36, ED-342):** 404 wide, radius 14, the sheet colour with the floating shadow and an arrow on the +'s centre (55 from its end), below the + or above it when there is more room; a click outside or Esc closes it and keeps nothing. Every + wears `AddAnchor` (core); the one painted last is where it points, since the Workspace toolbar lays out a hidden copy of its + per width. Shared as `showAnchoredPopover` (`shared/sheets/`).
- **Task tab:** Task · Brain dump · Routine on the sliding control (the Workspace's 28 pt tab size, raised tab on the chip track); the title box with its 34 ring (a click opens Colour and icon) and "What is it?"; "Type a time too…" until a word is read, then each day, time or length as a chip with ×; the summary ("Thu, Oct 22 · 6:00 – 6:45 PM · 45 min") with "Free until … · no overlap" or "Overlaps … · you can still add it"; then the learned lines; Duration pills (the user's presets) and ⋯; Add to Inbox instead; Add ↵. Return adds at the typed time, else the first free slot; a pasted list asks "Add 3 tasks?"; a failed save reopens it with the draft. Pointer sizes on the Mac and a mouse-driven browser (26 pills, 30 buttons), 44 for touch.
- **Web toolbar:** "Add" with its `n` key cap for a mouse-driven browser; the Mac keeps the round +.
- **Chip ×:** the parser's ignored tokens are kept in Add's state (`carryIgnored` moves them with each edit, drops one that is edited) so the word stays title text and is not read again; replaces `textWithout`. Minimal's Add too; the phones' Create task shows no chips.
- **Learned lines (`AddLearnedLines`):** "usually 1 h" (docs/13 §6), "usually starts ~15 min after plan" (11 C3) and the energy window with Try (11 C4), each only when it applies, under the popover's summary and Create task's When card. They had no place in Full since 3a. C4 stays off in Minimal; the old When step's energy code is removed.
- **The old Add:** now Minimal's only: its Full-only parts (colour row, suggestions, routine chips, Break it down, Continue, step dots), the "Continue" and "Step 1 of 2" strings and 20 Full "What" goldens are removed; its When step stays (More). Create task and the popover share `add_submit.dart` and `AddModeTabs`.
- **Departures, recorded:** six default duration presets wrap "2 h ⋯" to a second line (the board draws five); the free / overlap line is the app's caption (free ring, overlap knot, "Free until" muted) rather than ✓ and ⓘ; Add and Inbox wait for the "Add 3 tasks?" answer; the web key cap is outlined. Go to date stays in M19.5.
- **Checks:** add_popover_test (21), add_energy_test (6, the popover, Create task and Minimal), carryIgnored domain tests; goldens add_popover open, chips, overlap, paste (Mac) and web Day (light, dark); Minimal's paste and failed-save goldens re-baselined; the old sheet's tests run it as Minimal (a list goes to Brain dump, new test); habit and routine-chip tests moved to Create task. Analyze and format clean; 7176 tests pass, 31 skipped; the 5 Supabase suites need the stack. Not yet run in a real Mac window or browser.

### ED-396 · M19.3 part 3c: Add on tablets
- **Date:** 2026-11-19. **Owner:** "Start 3c", with answers: the iPad gets the phones' Create task in a popover from the + (ED-271, the tablet board, wins over R2-36's "from medium width"; the Mac and the web keep the R2-36 popover); the proposal beside the day (R2-3 1c, 2c) becomes its own part 3d; the hold menu's Paste a list opens Task with the clipboard's text. Then "Approve 3c" after the review page.
- **iPad (E-R2-3 1a, 1b):** + and ⌘N open Create task (ED-140) in a popover under the +: 400 × 700 at most, radius 26, no arrow, the Workspace live behind it. Holding + shows Brain dump · Routine · Paste a list; the first two open the popover on their tab, Paste a list runs Paste as Tasks (Add with the clipboard; a list asks "Add N tasks?").
- **Android tablets (2a, 2b):** + opens the M3 menu Task · Brain dump · Routine; each opens Create task ("New task", ED-141) on its tab in an M3 modal side sheet, 412 wide at the window's end with 28 leading corners, over the scrim (`showModalSideSheet`, shared). Ctrl+N opens Task directly; Back, Esc or the scrim close it and keep nothing.
- **Every + (`AddMenuButton`, shared):** the Workspace toolbar's, the medium top bar's, the sidebar's and the rail's carry the anchor and both menus; tablets are told by width class and the platform's containers (docs/10 §4), the web never. Brain dump and Routine reach Add through `OpenAddIntent` (core), handled by `AppCommandScope`, not new key commands (each `AppCommand` keeps one binding).
- **Touch targets (found here, fixed for phones too):** 3a's checks ran as Android only; as iOS, Create task's tabs (35 pt), title field (38) and notes (44) were under the 48 our checks hold every touch screen to. All are 48 now, so Create task's tabs and title band are a little taller than drawn on iPhone and Android; its goldens are re-baselined.
- **Departures, recorded:** the taller tabs and title; Android's New task keeps 3a's grouped When card and ⋯ (Android mirrors the iPhone), not the board's plain rows; both menus are Flutter's Material menu with the app's glyphs, not UIKit's on iPad. The proposal beside the day is part 3d.
- **Checks:** add_tablet_test (9: iPad tap and hold, Android menu, side sheet and its tab, Ctrl+N and Esc, a11y on both, light and dark); goldens add_tablet ipad, ipad_hold, android_menu, android_sheet (light, dark); Create task goldens re-baselined; the popover tests and the keyboard flow run as the Mac or Windows, the rail-click test as the Mac. Analyze and format clean; 7193 tests pass, 31 skipped; the 5 Supabase suites need the stack. Not yet run on a real iPad or Android tablet (M21).

### ED-397 · M19.3 part 3d: the proposal beside the day
- **Date:** 2026-11-19. **Owner:** "Start 3d" (split from 3c), with answers: the dashed proposed blocks show on every Workspace (tablets, Mac and web), not tablets only; Android tablets keep the one shared side panel (420, docked or floating by width) rather than a separate 412 M3 standard side sheet. Then "Approve 3d" after the review page.
- **Dashed proposed blocks (E-R2-3 1c, 2c):** while a proposal is open, the hour grid (Day, 3 days, Week) draws each task it adds, shifts, resizes or moves at its proposed time: the accent's dashed edge over the drop tint, an empty dashed ring where the dot would be (18), the title, and "new" on added ones. Drawn, not saved, not tappable; they follow the proposal (× on a line, Discard, Accept). From `Proposal.placements` (domain): the rows of added, shifted, resized and moved edits that have a time; untouched, overlapping, Inbox-bound and steps-only lines place nothing.
- **Beside the day:** the proposal's shared side panel at expanded width (docked from 1160, floating below, Esc discards) was already built; tablets get it as it is.
- **Today button (found here):** the Workspace toolbar's "Today" was 36 pt wide at touch sizes, under the floor; it is the control's height wide now (48 on touch). The Add popover and side sheet had hidden it from 3c's checks. The touch Workspace and tablet Add goldens moved by that width and are re-baselined.
- **Departures, recorded:** beside the docked panel at touch sizes the toolbar takes two lines (M19.2's fallback; the board's 1c drops Day ▾, + and search, which is the toolbar's rule, ED-393); the grid keeps three touch-width days and scrolls where the board draws two; moved and shifted tasks show dashed without "new", their current block staying until Accept.
- **Checks:** proposal_grid_test (the panel beside the Week and the dashed "new" blocks on iPad and Android, nothing written, a11y, Discard takes them away, the Mac shows them too; goldens on iPad and Android, light and dark); `Proposal.placements` domain test. Analyze and format clean; 7201 tests pass, 31 skipped; the 5 Supabase suites need the stack. Not yet run on a real iPad or Android tablet (M21).

### ED-398 · M19.4 part 4a: option D on the phones
- **Date:** 2026-11-19. **Owner:** "Start M19.4" with answers: four parts (4a phones' option D sheet and editor; 4b the one When picker; 4c Colour and icon; 4d tablets' docked editor and the Mac/web inspector's More rows); every feature of today's editor that option D's frames don't draw is kept, placed quietly, shown on the review page without and with ("let me approve"). Then "Approve 4a" with all three.
- **One sheet (G2-5, ED-086):** on phones in Full a tap on a task opens option D, which is the editor. Medium detent (0.62, full height on a short window, ED-347): ⋯ and Done; the tinted header (the dot opens Colour and icon, the title edits in place, today's range and minutes left, the done circle at its end); Done · Move · Shift the rest · Focus; Need more time? +5 +15 +30 while it runs (ED-163, 44 pt chips); "Pull up for date, alerts, steps and notes". Pulled up (0.94): the When card (date keeping the time, time with its length, alerts), Repeat and Energy pills, the Steps and Notes card (ED-137: "Add a step" always there, the notes with their links and mic), the More card (Sound, Travel time, Pinned "Stays put when other tasks shift", Delete task; ED-346), and "Saved · 9:41 · Undo". Android: ← "Edit task", ⋯, a filled Done; the header as a card.
- **Saving:** the built autosave (03 §3.4) through one `EditorDraft` mixin shared with the Mac/web form; Done saves, asks a repeating task's scope (M3f.1) and closes; Undo puts the task back as it was when the sheet opened. The tiles and chips write on their own after saving the draft, with Undo (Done with its sound and haptic, one `markDone`); the draft then takes the newer row when nothing waits to save, so a later edit never puts the old one back.
- **Kept, placed quietly (owner approved):** (1) a step shows its time if any; its ⋯ holds Set a time and Delete; a long press drags it to reorder (Move up / down stay for keyboards and screen readers); (2) the time row and its length open "Time and length": the start with its time zone, the length chips and ⋯, "Length = sum of steps"; (3) Break it down in ⋯ (with Move to inbox and Delete task): saves, closes, opens the proposal over the day (M10.4).
- **Departures, recorded:** ⋯ and Done at the medium detent too; no "Overlaps … · 2 of 4 steps" line under the header; Need more time? as a plain chip row; the notes keep the format hint and mic. Move is today's change-day picker until 4b; Colour and icon today's picker until 4c. Minimal keeps its sheet (M19.6); tablets, the Mac and the web keep theirs until 4d.
- **Checks:** task_d_test (13) and option D goldens (medium and pulled up on iPhone and Android, light and dark; the three kept features); the phone task sheet tests moved to option D. Analyze and format clean; 7225 tests pass, 31 skipped; the 5 Supabase suites need the stack. Not yet run on a real phone (detents, the keyboard over steps and notes).

### ED-399 · Option D's "Need more time?" in its tinted pill
- **Date:** 2026-11-19. **Owner** (after ED-398): "it should sit inside a tinted pill, make it like drawn in Concept E … show me to approve this"; then "Approve the pill" after the before / after page.
- **As drawn (E-Phones F3):** the row sits in a pill of the sunk colour (#F6F1EA light, #1F1B1E dark), corners 22, at least 56 tall, 6 around the chips and 14 before the label; "Need more time?" bold at its start; +5 min · +15 min · +30 min at its end, each a 44 pt pill in the accent's tint inside the 48 pt target every touch control keeps; at large text the chips wrap under the label. Replaces ED-398's recorded departure ("a plain chip row").
- **Checks:** the option D and task sheet tests pass; the option D goldens re-baselined with the pill.

### ED-400 · M19.4 part 4b: the one When picker
- **Date:** 2026-11-19. **Owner:** "Start 4b", with answers: the time as the drawn horizontal day bar (not the built vertical ThreadPicker); every single-task entry opens the picker, several picked tasks keep the change-day month. Then "Approve 4b" after the review page, as it is (a repeating task's Move still moves this one occurrence without asking).
- **One picker (G2-12 Q2, ED-099; `shared/pickers/when/`):** Inbox Schedule, Move (option D's tile and today's task sheet) and Move To… (⇧⌘M; the web's `m`, new, off with single keys) for one task. FREE TIME first: up to two free places today and the first tomorrow with Place (a moved task's own time counts as free, `DayRoom.without`). Then OR PICK A DAY AND TIME: Today, Tomorrow, the next two days ("Fri 23"), Date… (the month with its dots), and the day bar: Wake Up to Wind Down, the day's tasks as pills in their colours, a ring dragged or tapped, snapped to the step, "11:30 AM – 12:00 PM · free" or "· overlaps Lunch" under it (overlaps allowed, ADR-0015). Move keeps the task's time on any day; Schedule starts at the first free time. "Move to 11:30 AM" / "Place at 11:15 AM"; every placement has Undo; the picker writes nothing itself.
- **Keyboard and screen readers:** the bar is a slider ("Start time", the range read out; increase / decrease step it); arrow keys move it once focused; ↵ places; Esc closes. Phones: a sheet with ×. Mac and web (pointer): a popover with a typed time field and ↵ on the button.
- **Replaced:** the Inbox's Schedule sheet and "Pick a time…" sheet; `SlotChoice` moves to its own file. The vertical ThreadPicker stays for Minimal's When step.
- **Departures, recorded:** no typed date field (the chips and Date…); "· free" in the text colour; hour marks at Wake Up's hour, noon, 5 PM and Wind Down's hour; a repeating task's Move moves this occurrence without asking (as built); no swipe Move on Today's rows exists to open it.
- **Checks:** when_picker_test (8), the day bar's slider and keys, `DayRoom.without`; the Inbox Schedule tests, the task sheet's Move and ⇧⌘M updated; goldens Move on iPhone and Android and the Mac popover (light, dark), the Inbox's Schedule golden now the picker. Analyze and format clean; 7240 tests pass, 31 skipped; the 5 Supabase suites need the stack. Not yet run on a real device.

### ED-401 · M19.4 part 4c-1: the colour data
- **Date:** 2026-11-19. **Owner:** "Start 4c", with answers: all of the colour data with the migration run locally; recently used icons kept on the device; tablets by width; 4c in three parts (4c-1 data, 4c-2 the phone pickers, 4c-3 the Mac/web popover with Custom colour… and tablets). Then "Approve 4c-1" after the review page.
- **Built (ED-219 to ED-221):** brown, plum and olive in palette.json after slate (12 named colours; light, ring and dark as approved, ED-161, ED-177). `TaskColor` is now a generated class: the named colours as constants, `TaskColor.custom(Color)` and `fromKey` reading `#RRGGBB` (upper-cased). A custom colour's light ring is deepened to 3:1 on the light ground and cards and its dark shade lifted to 3.5:1 on every dark surface, both when drawn; a pale one's done tick is ink, as amber's. Screen readers: Brown, Plum, Olive, Custom colour.
- **Validation (forward-compatible):** `checkColorKey` accepts the 12 keys, the retired ones, `#RRGGBB` and any lowercase name ≤ 24 (a newer palette), so sync, edits and restore keep them; an unknown name draws as the default and is never rewritten. Server 0017 adds the same shape check on series and occurrences `color_key` (NOT VALID: stored rows aren't re-read).
- **Your colours (ED-221):** `profiles.your_colours` (jsonb, ≤ 24 `#RRGGBB`, newest first) and `profiles.accent_hex` (null = `settings.accent`), with server CHECKs (0017), Drift schema 24, pushable columns, `Profile` fields and validation; backups carry them. Run locally (`supabase db reset`, all 17 pgTAP files); not pushed.
- **Departures, recorded:** the existing colour rows and picker show all 12 colours now (4c-2 replaces the compact picker), where ED-219 hid the three in pickers for one release. ED-219's rule is also broader as built: a well-formed unknown key is accepted on any write, not only when an edit leaves it unchanged. Calendar import's colour matching includes the three; a routine step's dot cycles through all 12 (a custom one cycles to coral).
- **Owner answer (2026-11-19, after the commit):** "Show them now": brown, plum and olive show in every picker from this release; ED-219's one-release picker hold is dropped.
- **Open:** the hosted push of 0017 (must-ask); ED-221's nearest built-in `accent` written beside `accent_hex` comes with the App colour picker (4c-3).
- **Checks:** task_color_custom_test (5), board values for the three, validation (custom, newer, malformed, your colours, accent), the 23 → 24 migration and the profile round trip, pgTAP 0017 (13). Goldens re-baselined where every colour is listed or cycled; the backup round-trip snapshot re-recorded (only the two new fields differ). Analyze and format clean; 7276 tests pass, 31 skipped.

### ED-402 · M19.4 part 4c-2: Colour and icon on the phones
- **Date:** 2026-11-20. **Owner:** answers before the build: Android mirrors the iPhone's layout; every task colour picker on phones uses it (the task sheet, Add, the select bar); the hex is tap to type. Then "Approve 4c-2" after the review page.
- **Built (ED-086, ED-156, ED-161, ED-221; E-Phones "Colour and icon"):** one sheet from option D's dot and Add's look button. Compact: Current, the 12 colours in one swipeable row (a custom colour leads), Suggested icons from the title, Recently used (8, kept on the device in `local_meta`), All icons ·. All icons: the glass palette, search and category chips pinned over the library. All colours: the hex chip (tap to type), a preview of ahead, in progress and done with the ring note, Colour and Shade sliders (screen-reader sliders, arrow keys), the 6 × 2 grid and Your colours (+ for an unsaved custom colour, Edit removes). Picks land live; Done closes, Back returns to the start page, drag up opens All icons. The select bar gets the colour alone on Done.
- **Palette order:** colours are stored in ED-161's picker order (coral amber sky indigo teal rose mint violet slate brown plum olive), and mint is named "Green" in all four languages; 107 goldens re-baselined for the order.
- **Departures, recorded:** Android's compact sheet copies the iPhone (owner) instead of its drawn 6 × 2 grid; Done in All colours closes the whole picker; search and chips stay pinned and the chips use the categories' full names; the Shade slider runs black → colour → white; the hex chip uses the app's font with even-width figures, not monospace; targets are 48 with the dots drawn at the board's sizes; Suggested comes only from the title. Tablets, Mac and web keep the old picker until 4c-3.
- **Open:** 4c-3 (the Mac/web popover with Custom colour…, tablets by width, ED-221's nearest built-in `accent` beside `accent_hex`); the hosted push of 0017 (must-ask); a real-phone run.
- **Checks:** look_sheet_test (10: live pick, search and Recent, drag and Back, typed hex, Your colours, the select bar, a11y iOS and Android in both themes), recent_icons and recent_list tests; 10 goldens (compact and All colours on iPhone and Android, All icons on iPhone, light and dark). Analyze and format clean; 7296 tests pass, 31 skipped. Not yet run on a real device.

### ED-403 · M19.4 part 4c-3: the colour and icon popover on the Mac and web, and tablets by width
- **Date:** 2026-11-20. **Owner:** "Start 4c-3", with answers: icons in the Mac and web popover (Current, Suggested, Recent and All icons…); the eyedropper and Show Colours… built now. Then "Approve 4c-3" after the review page.
- **Built (ED-156, ED-161, ED-298; E-G3-9b "Mac · Colour popover", "Web · Colour menu"; E-FullA-v2 inspector; E-R2-15):** one opener chooses the container: compact width, and tablets below expanded, keep 4c-2's sheet; the Mac and web get the popover from medium width; a wide iPad gets the phone pages in a popover from the dot; a wide Android tablet gets them in a centred M3 dialog. The popover: Dottoday colours (6 × 2, 26 in 44 targets), Your colours, the Icon row with All icons… (the library in place, searchable), Custom colour… expanding in place (saturation and brightness field, hue strip, typed hex, eyedropper, ahead · in progress · done preview, Use and save adds to Your colours, Cancel; Mac Show Colours…). Picks land live and it stays open; arrows move, ↵ picks, Esc closes; it opens with the task's colour focused. The select bar's Colour is the popover without icons, a pick closes it.
- **Eyedropper:** the Mac's `NSColorSampler` and `NSColorPanel` over `dottoday/colour_sampler` (a small native bridge, no package); the web's `EyeDropper`, offered only where the browser has it; none on iOS and Android.
- **Replaced:** the old full colour picker (its colour mode) and the select bar's colour sheet; the icon library alone stays for Search's "with icon" filter. Swatches and icon circles are focusable (an ink response), so keyboards work on tablets too.
- **Departures, recorded:** the Icon row is not on the boards (owner) and hides while Custom colour… is open, so the popover is as drawn and fits an 800-high window; the Android tablet dialog shows the iPhone-style page (owner, 4c-2) rather than its drawn grid; the ring note follows 4c-1's derivation (#F0A28E → #BB8074, the board wrote #E45936); a popover opened from a screen-sized context hangs from the window's top end.
- **Moved:** ED-221's nearest built-in `accent` beside `accent_hex` belongs to the App colour picker, M20.7 (was listed for 4c-3 in ED-401).
- **Open:** a real Mac, browser and tablet run (the sampler, the panel, the browser EyeDropper); the hosted push of 0017 (must-ask).
- **Checks:** look_popover_test (16: live picks and Esc, keys and ↵, suggested and All icons… with recents, Use and save and Cancel, the eyedropper and Show Colours…, the select bar, routing for wide iPad, wide Android and tablets below expanded, a11y on the Mac and wide tablets in both themes); colour block and Add popover tests moved to the new pickers; 6 new goldens (Mac popover and Custom colour… light and dark, wide iPad, wide Android) and the icon library's goldens re-recorded. Analyze and format clean; 7314 tests pass, 31 skipped; the Mac (debug) and web builds compile.

### ED-404 · M19.4 part 4d: the tablets' editor and the inspector's More rows
- **Date:** 2026-11-20. **Owner:** "Start 4d", then "Approve both" after the review pages (4d and the native pass).
- **Built (ED-273, ED-274; E-R2-4):** on the iPad and Android tablets a task opens option D's editor in the side panel, never the Mac inspector (a browser on a tablet is the web). Docked from 1160 where the grid keeps its minimum (the grid narrows to the days that fit); below, it floats: a card over a slight dim on iPad, an M3 modal side sheet on Android, closing on the dim. Tablets use the panel from medium width too (portrait). In the panel the whole editor shows (no pull-up hint); Done, ←, Delete, Move to inbox and Break it down close the panel.
- **Built (ED-346; E-R2-40 "Mac · inspector"):** under Notes, Energy and Travel time as pop-ups with the current choice ticked (picking the ticked energy clears it; Travel hidden for an Inbox task), Sound opening the built picker, Pinned as the built switch with "Stays put when other tasks shift", Delete task (the confirm, or which ones for a repeating task; Trash with Undo; the inspector goes).
- **Departures, recorded:** the Android panel is 4a's Android editor (cards like the iPhone's), not the board's older list; the iPad's floating editor sits at the window's end edge; Sound opens the full picker; Minimal on tablets keeps its own sheet below expanded. Not in 4d: the Mac and web full editor (the second click) and the medium-width Mac and web task sheet.
- **Checks:** tablet_editor_test (5), inspector_more_test (5); the desktop inspector and panel tests run as the Mac (a test's default platform, Android, is now a tablet); goldens for the tablet editor docked and floating on iPad and Android (8), the inspector's More rows (2); the iPad inspector goldens removed. Not run on a real iPad, Android tablet or Mac.

### ED-405 · Native pass: each platform's own controls (audit 13 to 26)
- **Date:** 2026-11-20. **Owner:** "for the changes we have made i want the platforms to use native features Android, MAC, Iphone, Web", the audit page (Native controls audit), "All fixes 17 to 26", then "Approve both".
- **Built:** one shared menu for every ⋯, pop-up and long-press menu: iOS's UIMenu from 17.4 through a new bridge (Flutter's below), the Mac's NSMenu (now with ticks and groups), Material's on Android, Flutter's on the web; Energy as the three-item menu ED-346 approved on phones and tablets; the nine confirms and rename prompts as the system alert (UIAlertController in Dottoday's ink, NSAlert as a window sheet; Material on Android and the web); Material 3's time picker on Android and the web, iOS's wheel kept, no picker on the Mac (typed); one adaptive segmented control (iOS's on Apple, Material 3's elsewhere; 7 places); iOS's real text-editing menu on every field (a policy test keeps it); iOS navigation bars on Past days and Day review; the routine step length as the shared menu; an adaptive spinner; More colours… (iOS's colour picker in All colours, the browser's colour input on the web); iOS's card sheet for full-height sheets on iPhone.
- **Decided:** confirms stay ink, never red (ED-336/ED-337), so none uses the red destructive style; half-height sheets keep their approved detents (Flutter's iOS card sheet has none); iOS-style Back is drawn with the app's chevron (no Cupertino icon font shipped); the web parity test now checks the web's hosts pixel for pixel and the Mac's layout (CLAUDE.md §11).
- **Blocked:** a Mac Settings window (26): Flutter 3.47's multi-window API is internal, debug-flag only and not for production; Settings stays a page, opened with ⌘, from the native menu (M20.7 revisits it).
- **Checks:** native_controls_test (policy), menu tick tests, time picker per platform, the alert and menu channels answer "no bridge" in tests by default; 23 golden files re-recorded for the native controls. iOS's menus, alert and colour picker run on the iPhone simulator (iOS 26.5). Full suite 7341 pass, 31 skipped; iOS, Mac, web and Android builds compile. Not run on a real Mac, Android device or browser.

### ED-406 · M19.5 part 5a: Done and Undo
- **Date:** 2026-11-20. **Owner:** "start 19.5 also make sure that moving forward every platform native is the first considered as the document also stated"; answers: Go to date keeps the approved month everywhere (5c); the done circle reopens (not the dot), and grid blocks gain it; M19.5 in three parts (5a Done and Undo, 5b reopen and the Earlier fold, 5c change day and Go to date). Then "Approve 5a" after the review page.
- **Native first, checked:** the Undo toast is Android's own Material snackbar; iOS and the Mac have no system toast, so it stays the approved drawn toast there (ED-194, ED-281); the done circle is task content, with no native counterpart.
- **Built (E-R2-7, ED-281):** the toast appears and goes without sliding under Reduce Motion; on Android tablets it sits at the start of the content (440), the iPad, Mac and web keep it centred (400); ⌘Z / Ctrl+Z, once it has undone the change, closes the toast that offered it. Kept as built: the 30 s window, waiting while hovered or focused, staying with a screen reader on with Close, Escape, "too late", one toast at a time.
- **Built (E-R2-5, ED-276; owner):** the done circle at the end of Workspace grid blocks at touch sizes (iPad, Android tablets): Done with Undo, and the same circle reopens. The Mac and web blocks have none (the inspector's Done).
- **Built (E-Phones ED-140, M19.3 open item):** Create task's header circle adds the task already done, through the same `markDone` (completion time recorded); none for a repeating task; named "Done" for screen readers before there is a title.
- **Departures, recorded:** E-R2-5 draws no circle on blocks (owner answer); in a 3-day or week column the circle costs the title about a word, and a block in a narrow overlap lane or shorter than the touch target has none (Done in the docked editor). ⌘Z closing the toast is not on the board.
- **Checks:** the toast's Reduce Motion, ⌘Z and placement (4); grid_done_test (3); create_task_done_test (3); goldens re-recorded where touch blocks draw circles, Create task on phones and tablets, the Android toast. Analyze and format clean; 7353 tests pass, 31 skipped. Not yet run on a real device.

### ED-407 · M19.5 part 5b: reopen and the Earlier fold
- **Date:** 2026-11-20. **Owner:** "Start 5b", then "Approve 5b" after the review page.
- **Native first, checked:** Earlier is the app's own row; it is already a native disclosure button (VoiceOver and TalkBack say its state, the web marks it expanded or collapsed). The done circle is task content.
- **Built (E-Earlier frames 7 to 10, ED-164):** today's done tasks before now fold into Earlier in the Workspace's Day column on every wide window (Mac, web and tablets at the expanded width), the column starting at the fold with no Wake Up cap (ED-364 Q2). Full phones keep their rows; Minimal phones and the old spread card already folded.
- **Reopen:** the filled circle returns the task to its time; the toast says "{title} reopened" (frame 10's wording) in place of "… not done", in en, de, fr and es, with Undo.
- **Keyboard (frame 8):** Space or Return toggles Earlier, → opens, ← closes (built); ↓ from the open row moves into the group; the done circle is focusable everywhere (an ink response), so Space or Return on it reopens; Return on a row opens the task (built).
- **Departures, recorded:** tablets fold too (the same Workspace Day by width); the Day column keeps its hour labels; from the first done task Tab moves on to its circle; no announcement beyond the toast's message. Add on tablets' a11y test now scrolls "Notes" into view first: the contrast check had measured the half-hidden heading against the day behind the popover.
- **Checks:** earlier_day_column_test (4); the Mac Day column with Earlier open, light and dark (2 new goldens); 58 re-recorded where the Workspace's Day now folds. Analyze and format clean; 7359 tests pass, 31 skipped. Not yet run on a real device.

### ED-408 · M19.5 part 5c: change day and Go to date
- **Date:** 2026-11-20. **Owner:** "Start 5c"; answer: the Day menu gains Go to Date… only (the four-group regrouping stays M20.3); earlier, Go to date keeps the approved month everywhere. Then "Approve 5c" after the review page.
- **Native first, checked:** each platform's own container (a popover from the date button on the Mac, the web and the iPad; a dialog on Android tablets, which have no popover; a sheet on phones); the Mac menu bar's and the iPad's ⌘ menu's own Go › Go to Date… ⇧⌘T. The month is the approved component (owner).
- **Built (E-R2-36, ED-342):** Go to date is Today's approved month (ED-075: ‹ ›, planned-day dots, "{month} · N of M days planned", Today) with the week on show tinted and today ringed; a picked day goes there in the view on show. Opened from the toolbar's date button (replacing its "Change day" sheet), ⇧⌘T / Ctrl+Shift+T, web g (single keys), Go › Go to Date…, the Day menu's Go to date… (owner) and listed in the ⌘/ keys. The day on show has the keys; arrows move a day, Page Up / Down the month, Return picks, Esc closes. `AddAnchor` and the new `DateAnchor` share one painted-anchor mark.
- **Kept as built (E-R2-5, ED-276):** swipe between days, ⌘← / ⌘→ (web [ ]), ⌘T / t, the Mac Go menu's Previous and Next Day, the web's day URL.
- **Departures, recorded:** the key is ⇧⌘T (ED-095's approved scheme and macOS Calendar's own), not ED-342's design-only ⇧⌘G caption; Go to Date… is in the Go menu (ED-095), not View; the header is the approved "Sep · Oct · Nov" and a day's spoken name the built "…, 2 of 4 done"; the Day menu's item sits in today's ungrouped list until M20.3; phones keep their month from the week strip, with the same month in a sheet for ⇧⌘T.
- **Checks:** go_to_date_test (7); goldens: the Mac popover light and dark, the iPad popover, the Android dialog (4). Analyze and format clean; 7370 tests pass, 31 skipped. Not yet run on a real device.

### ED-409 · M19.6 part 6a: Minimal's places and shell
- **Date:** 2026-11-20. **Owner:** "Go" (M19.6), then five parts (6a places and shell; 6b the phones' Now tab; 6c the Mac and web Now pane with the Day column; 6d the minimal task sheet and Add; 6e the narrow-Mac rules and tablets), then "Approve 6a" after the review page.
- **Native first, checked:** the iPhone's own native tab bar (SF Symbols: `smallcircle.filled.circle` for Now, `calendar`), Android's floating toolbar and rail, the Mac and iPad system menus for ⌘1–4.
- **Built (ED-068, E rules §9.0; ED-266; ED-207):** Minimal phones get a tab bar, Now · Today · Inbox with Add; wider windows (tablets from medium, the Mac, the web) Now · Inbox · Calendar · Search with Settings at the foot, Calendar being the month. New shell branches `/now` and `/calendar` (appended to branch order; Minimal shows Now first). The sidebar is 200 in Minimal (Full 216). ⌘1–4 (web 1–4) go to Now · Inbox · Calendar · Search in Minimal, named so in the Mac menu and the ⌘/ list. The "‹ Today" pill Minimal needed without a tab bar is removed.
- **Until 6b and 6c:** the Now place shows Minimal's day; opening on Now comes with 6b. Full has no Now (ED-066): its `/now` is Today.
- **Not changed:** doc 14's "no tab bar" and "Later row" rows, which doc 14 says ED-068 supersedes on this branch without rewriting; the layout policy.
- **Checks:** minimal_places_test (6); updated the /now deep link, Minimal Today's tappables, the keyboard scheme's Minimal keys; the test app passes Minimal to its keys as the app does; 5 goldens of Minimal's places. Analyze and format clean; 7376 tests pass, 31 skipped. Not yet run on a real device.

### ED-410 · M19.6 part 6b: Now on the phones
- **Date:** 2026-11-20. **Owner:** "Start 6b", then "Approve 6b" after the review page.
- **Native first, checked:** Need more time? is each platform's own menu (UIMenu on the iPhone, Material's on Android); Go to date is 5c's; the Day chip opens Minimal's Day menu through the system's pull-down.
- **Built (E-PhonesMinimal frames 1, 4, 5; E-R2-26 "Now through the day", ED-329; ED-066, ED-106, ED-244):** Minimal opens on Now, once, when the profile first loads and the launch is still on plain Today (a link elsewhere, or a later switch to Minimal, stays put). The header: the date with ▾ (Go to date), the sync and profile capsule, "Now 10:42 · Wind Down at 11:00 PM". The day horizon (48 tall, one tap target, opens Today). Running: the orb (minutes left, hours from 100 min, the elapsed arc; a tap opens Focus), Done with Undo, Need more time? (+5, +15, +30 min, Shift the rest), Also now and Next. Between tasks: Next up (the 200 ring, "{duration} free"), the task after as Next, and tasks that ended unticked under Earlier, "· not done", with their done circle. An open day: the hours-free orb, Add to the day, "One thing is enough. Or paste a list." The day's end: "Nothing else today". Day ▾ above the tab bar's end. The rule is `nowViewOf` in `domain/now`, the same as the widgets and the Mac menu bar.
- **Departures, approved with the part:** at 6:30 the Wake Up card stays its own screen (as built, R2-19) instead of inside Now; rows between tasks keep the task dot with its icon (frame 1) where E-R2-26 draws plain rings; no hairline between Also now and Next, no overlap knot, no shadow under Next up's ring.
- **Wider (tablets, the Mac, the web):** Now still shows the day until 6c.
- **Checks:** now_view_test (6), now_screen_test (7), 7 goldens; Minimal Today and the Wake Up promise tests go to Today first; the 6a place goldens now show Now. Fixed: the horizon threw while painting when a task began after now; the orb's numerals use the locale's digits. Analyze and format clean; 7401 tests pass, 31 skipped. Not yet run on a real device.

### ED-411 · M19.6 part 6b: the Wake Up card folded into Now
- **Date:** 2026-11-20. **Owner:** "Fold Wake Up in", then "Approve the fold" after the review page. Replaces ED-410's departure "at 6:30 the Wake Up card stays its own screen".
- **Built (E-R2-26 frame 4, ED-329; R2-19's card):** in Minimal on a phone, the Wake Up card takes Now's place under the horizon in the morning: "Good morning…" from the start, "3 planned · ends …" without the day dot, the first dot, Start the day and Later. Same once-a-day window as the card's own screen (`wakeUpCardDue`); it stays until Start the day, Later or Shift the rest answers it, and the answer is the day's "card shown". A task under way comes first. "Show my day" gives way to the horizon (it opens Today).
- **Minimal never opens the card as its own screen over Today** (`wakeUpCardDueNow` is null there; Full unchanged; a tapped Wake Up notification still opens it). The old Minimal rule, "only after I'm up" (15 §10), is replaced: its aim, no unexpected full-screen route, holds because the card is in Now. `wakeUpCardDue`'s `firstOpen` switch is removed.
- **One set of answers:** Start the day, Shift the rest and the missions offer live in `wake_up_card_actions.dart`, used by the card's screen and by Now.
- **Horizon:** the wake and Wind Down hours give way when the now label is beside them (the board's 6:30 shows only "6:30").
- **Departure, approved:** the card's first dot keeps the card's own layout (time above title, its first step) rather than the board's stacked "First / title / time".
- **Checks:** now_wake_up_test (3: the card in Now and Later, with a11y; Start the day; a task under way first), 2 goldens; the Minimal gate test now asserts "never over Today". Analyze and format clean; 7405 tests pass, 31 skipped. Not yet run on a real device.

### ED-412 · M19.6 part 6c: the Mac and web Now pane with the Day column
- **Date:** 2026-11-20. **Owner:** "Start 6c"; scope "Pane + column; tasks in 6d"; then "Approve 6c" after the review page.
- **Native first, checked:** a horizon dot's right-click menu and Need more time? are the Mac's own menus (Flutter's on the web); View › Show Day Column is a Mac menu item; ⌥⌘I is the one key for the inspector in Full and the Day column in Minimal.
- **Built (E-Minimal frames 1 and 2; ED-066, ED-068, ED-106, ED-218, ED-232):** in Minimal from the expanded width, the Now pane beside a 290 Day column with the 200 sidebar (one split on Mac and web). The Mac's toolbar over both (the date, "Now · Wind Down", sync, Search or run ⌘K, +); the web's date, time and Wind Down in the pane with + Add. The pane: "Now · 10:42" (Mac), the 700 horizon, the orb at 280 (Mac) or 240 (web), Done · Focus · Need more time? at their own widths, Also now and Next with "· 4 more" beside the Add row (⌘N) and Hide the Day column (⌥⌘I). A horizon dot's right-click: Open, Mark Done, Move To…, Focus, Duplicate, Move to Trash, with Undo. The Day column: "Day", Day ▾ (the Day menu), ✕, today's thread with Earlier.
- **Day column shown or hidden:** ✕, ⌥⌘I, View › Show Day Column or the pane's row; a view setting remembered on the device in `local_meta`, never synced, never in the address; with it hidden the horizon brings it back.
- **Departures, approved with the part:** tasks open as on Today until 6d opens them in the column (and its hint waits for 6d); the column's thread is the phones' at 290 (Running late cards, wrapping titles) where the board draws compact rows; no ‹ › or "● Synced" in the Mac toolbar; the dot menu has no Shift the Rest From Here or Copy as Text, and key hints only for Move To… and Move to Trash; the web sidebar keeps 6a's; Wake Up in Now stays phones only.
- **Medium widths (tablets):** the day until 6e.
- **Checks:** now_wide_test (5), now_wide_golden_test (3 goldens), now_view_test (the count after Next); the 6a Mac places golden shows the Now pane. Analyze and format clean; 7413 tests pass, 31 skipped. Not yet run on a real Mac or in a browser.

### ED-413 · M19.6 part 6d-1: Minimal's task screen on phones and in the Day column
- **Date:** 2026-11-20. **Owner:** "Start 6d"; split "Two parts" (6d-1 the task screen and the Day column's rows, 6d-2 minimal Add); then "Approve 6d-1" after the review page.
- **Built (ED-089, ED-216; E-PhonesMinimal "Task sheet (minimal)", E-Minimal's task in the right column):** one minimal task screen (`TaskMScreen`) replacing the old Done · Tomorrow · Later · Delete tiles. The 44 dot with its progress, the title in a new `minimalSheetTitle` role (Manrope 800 21/26), "Now, 18 min left" in teal while it runs or its times; Starts (the When picker, ED-099) and Duration (the Duration sheet), each with Undo; Done; Tomorrow · Later (stacked at large text); Need more time? +5 / +15 / +30 only while it runs; More options (the full editor); a small Delete task with Undo.
- **Phones:** the sheet opens at 72 % so Delete task shows; More options closes it and opens option D's editor.
- **Mac and web Now:** a task opens in the Day column, not the side panel: "Task" and ✕ over it, Starts and Duration as rows with − / + (15 min); More options shows the full editor in the column; ✕ or Esc brings the Day back and the Now pane stays. Opening a task brings a hidden column out. Elsewhere (Inbox, Calendar, Search) the side panel shows the same screen.
- **Day column (from 6c):** its hint "Click a task and it opens in this column. Close it and the Day comes back." and no Running late on the live row.
- **Departures, approved with the part:** a task ahead shows its times without "· next"; the column's chips read "+5 min" (board "+5"); Tomorrow and Later are filled quiet buttons; one More options line everywhere; no "· Undo after"; Break it down is reached through More options; the More options chevron doesn't mirror in RTL (as every chevron today); the full editor is the panel's at 290.
- **Checks:** task_m_test (6), 5 goldens; the 14 minimal task sheet goldens, the Now pane and Mac places goldens and the editor panel test updated; the old minimal tiles removed from `SheetActions`. Analyze and format clean; 7424 tests pass, 31 skipped. Not yet run on a real device.

### ED-414 · M19.6 part 6d-2: minimal Add
- **Date:** 2026-11-20. **Owner:** "Start 6d-2"; More → "Create task" (asked: it opened the When step as built); then "Approve 6d-2" after the review page.
- **Native first, checked:** the iPhone's sheet nav bar (Cancel · New task · Add); Android's M3 sheet with an outlined field, helper text and an `OverflowBar` foot.
- **Built (E-PhonesMinimal frames 3 and 6; ED-152, ED-206 7a, ED-217; docs/14 §4):** the iPhone's content-sized sheet with Cancel · New task · Add, "What and when" over a filled field with the task's dot (Manrope 600 20); Android's "Add a task", an outlined "What and when" field with clear and "Several lines open a plan first", More options and Add at the foot. The chips "Today 6:00 PM" (with its clock) and "1 h" open the When step, as before; the iPhone's More at the row's end. "Lands at 6:00 PM – 7:00 PM · free, no overlap" (or "overlaps …") over a mini horizon (`LandingStrip`: the day's other tasks at 45 %, CR-133; the 22 px / 4 px marker with its hour; hidden from screen readers). The iPhone's "Several lines? You'll see a plan first. Nothing is added until you accept." Add waits for text and for a list's answer ("Add 3 tasks?"); several lines go to Brain dump's plan, nothing written before Accept.
- **More / More options:** the detailed Create task with what was typed (colour, icon, repeat, alerts, notes), as the board's note says; the When step stays on the chips. The Mac and web in Minimal open the same sheet.
- **Large text:** the chips and More wrap; Android's Add drops under More options.
- **Departures, approved with the part:** the parsed-word chips ("6pm ×") and "Type a time too" stay under the field; the range in the app's format; the strip's rings at the horizon's 14; Android's sheet has no ✕ (Back or the scrim); no keyboard in the goldens.
- **Checks:** minimal_add_test (5), 3 in-app goldens; the Add tests reach When through the length chip; 26 goldens updated. Analyze and format clean; 7432 tests pass, 31 skipped. Not yet run on a real device.

### ED-415 · M19.6 part 6e-1: Minimal on a narrow Mac
- **Date:** 2026-11-20. **Owner:** "Start 6e"; split "Two parts" (6e-1 the narrow Mac, 6e-2 tablets); then "Approve 6e-1" after the review page.
- **Built (ED-169, ED-170; E-G4-3-Narrow):** the Day column folds when the Now pane's minimum (550 at 100 % text) and the 290 column don't both fit (≈ 1042 with the 200 sidebar), computed with the text size. Folded, a 44 strip holds a "Day" pill (no shortcut; ⌘1–4 unchanged) that opens the same Day column as a panel over Now, not modal and not dimmed; Esc (from the pill or the panel), ✕ or the pill closes it and focus returns to the pill; a screen reader hears "Day", expanded or collapsed. A task opened while folded shows in the panel; the pane's Day row opens and closes the panel there.
- **From the fold point:** Also now and Next stack, the Add row under them.
- **Narrow toolbar (below 1000):** no status text; Search or run is its icon with its name and ⌘K.
- **Short window (under 720 tall):** the orb at 72 %, the pane scrolls; above 130 % text it keeps full size. At any text size the orb's numeral keeps its size (its spoken label says it) and the horizon's labels grow with the text.
- **Departures, approved with the part:** the open "Day" pill tinted rather than filled teal with an icon; "Dottoday" wraps in the 200 sidebar at 200 % (6a's shell); the native 840 × 640 minimum window unchanged (ED-169); no ‹ › or "● Synced" (as 6c).
- **Checks:** now_narrow_test (6), 6 goldens; `HorizonDot` and `HorizonLabels` moved to their own file. Analyze and format clean; 7444 tests pass, 31 skipped. Not yet run on a real Mac (VoiceOver, Tab order, resizing with unsaved edits).

### ED-416 · M19.6 part 6e-2: Minimal on tablets
- **Date:** 2026-11-20. **Owner:** "Start 6e-2"; then "Approve 6e-2" after the review page.
- **Built (E-R2-1 2a, 2b, 4a; ED-266):** expanded iPad and Android tablets get the Now pane beside the Day column under the apps' toolbar (the Mac's, with no key hints on touch; ⌘K only on the Mac); the web keeps its date in the pane. Medium windows (iPad portrait, Android tablets in portrait, foldables, a narrow browser) show Now first, then a "Day" header with the Day menu and today's thread under it; Also now and Next stack with the Add row under them, and there is no Day row.
- **Touch sizes:** the pane's Add and Day rows and Minimal's sidebar rows are 48 on touch (44 on the Mac and the web).
- **The + button's hold:** merged into the button's semantics, so a screen reader hears one named button with a long-press action, not an unnamed item.
- **Tests:** `debugWebChromeOverride` in `dot_idiom.dart` draws the web's chrome in goldens (Linux no longer stands in for it).
- **Departures, approved with the part:** at medium the Day is one window tall inside the page (the page brings it up, then it scrolls on its own; ED-103 opens it at the live task); the orb is 280 on tablets rather than sized to the window; Android tablet portrait is not on the boards and follows the iPad's portrait.
- **Checks:** now_tablet_test (3), 4 goldens; the router's `/now` and 6a's Android-tablet golden updated. Analyze and format clean; 7449 tests pass, 31 skipped. Not yet run on a real iPad or Android tablet.

### ED-417 · M19.7 part 7a: the slice journey on every target
- **Date:** 2026-11-20. **Owner:** "Start M19.7"; split "Two parts" (7a the journey and the cases, 7b the sweep, the matrix and the acceptance page); runs "Sims + this Mac"; "I'll allow access" (the Mac container), "Yes, clear them" (6.5 GB of this worktree's iOS and Android build outputs, the disk being full); then "Approve 7a" after the review page.
- **Journey (playbook step 11):** Today (Now in Minimal) → Add "Slice check 3pm 30m" → move it to tomorrow by the When picker → Deep work done → tomorrow → Deep work reopened, each step checked by its toast and the stored row. Widget level on 9 targets (iPhone, Android phone, iPad landscape and portrait, Android tablet landscape and portrait, Mac, desktop web, mobile web) in Full and Minimal: 18 pass. On devices, each in both layouts: the iPhone and iPad (portrait) simulators, the Android phone and tablet (landscape) emulators, Chromium and WebKit at 390 and 1280 (Playwright), and the real Mac app (2 of 3 runs; the first, after a fresh build, missed ⇧⌘M once, not reproduced). In-memory data: the Mac container matched its backup by checksum after the runs.
- **Cases:** Today (Full) and Now (Minimal), empty, dense, loading, error, long titles and 200 % text, at compact (iPhone), medium (iPad portrait) and expanded (Mac): 36 checks (no overflow, skeleton not spinner, Try again, a11y guidelines) and 36 goldens.
- **Fixed from what it found:** Now's skeleton and inline error with Try again (it drew a blank screen); Move To… (⇧⌘M) acts on the task a click picked into the inspector (Return still opens the editor, ED-391); Go to date opens from Now's date (phones' date button, the apps' toolbar date, the web pane's date; at medium the Day menu button); Minimal Add's form scrolls with More options · Add pinned under it, and inside a wide sheet the keyboard is counted once (an Android tablet in landscape had Add out of reach); at 200 % Now's rows put the time under the title, the Plan panel puts Plan it under its note, the iPad top tabs scroll, the horizon's labels are measured at the text size and give way (now's always shows); the iPad top tabs take 44 to touch and the empty day's pills 48 (both drawn as before); the app's keys follow `webChrome`.
- **Noted, not changed:** while the profile loads Minimal shows Full's tabs; a just-added task's toast can cover its row on a phone, and on Android phones in Minimal the Day ▾ chip; the now label at the horizon's left edge starts at the edge (7 px before); the empty day's pills moved about 1 px (26 goldens).
- **Not run:** iPad landscape and Android tablet portrait on a device (rotation needs the simulator panel's OK or a device setting); real iPhone, iPad and Android devices (no dev flavour, decision 14).
- **Checks:** analyze and format clean; 7542 tests pass, 31 skipped. Device entry `integration_test/slice_journey_test.dart`; web driver `tool/slice/web_journey.mjs`.

### ED-418 · M19.7 part 7b: the sweep beside the boards, the matrix, the acceptance page; M19 closed
- **Date:** 2026-11-20. **Owner:** "Start 7b"; "run it on my iphone it's plugged in now" ("Run without a backup"); "install it on iphone so when i disconnect from the pc it would still work" (signed in to Xcode; "Yes, delete it" for the main checkout's `build/ios`; "Yes, build it that way": personal team, without Time Sensitive Notifications); then "Approve, close M19" after the acceptance page.
- **Sweep:** each target's journey shots beside its board (iPhone and Android phone on E-Phones / E-PhonesMinimal; iPad portrait and landscape and the Android tablet on E-R2-1; Mac and web on E-FullA-v2 / E-Minimal; mobile web on E-MobileWeb), Full and Minimal. Differences named, not changed: no Calendar tab (M20.1), "···" for Day ▾ (M20.3), no sidebar Synced line (M20.10), the locale's date format, Week opened where a board shows Day.
- **Real iPhone:** the journey passed in Full and Minimal on the owner's iPhone 17 Pro (iOS 27.2.1, debug, its own data left untouched by the in-memory run). Its shots showed the native tab bar over open sheets: the harness, not the app; the journey now builds the router with `NativeBarObserver` as bootstrap does. The device entry saves shots on a real iOS device with `takeScreenshot` and no longer converts the Android surface (screencap showed the test's start screen). A rerun with the fade was stopped by a full disk.
- **Install (not committed):** a release build on the owner's iPhone, signed by the personal team; the Time Sensitive entitlement was left out for that build only and `project.pbxproj` restored (clean diff). It opens unplugged, expires after about 7 days, uses `.env.example` (no account sync) and the phone's existing data, upgraded.
- **Matrix:** `PLATFORM_QUALITY_MATRIX.md` gets the Prompt F note and an F value in each row, "FAIL → fixed in 7a" where the slice found something, and the F slice row.
- **Not verified:** iPad landscape and Android tablet portrait on a device; real iPad and Android devices; Back and dismiss, background and resume, a screen reader and mid-flow switches on a device.
- **Checks:** analyze and format clean; the 18 widget journeys pass with the harness change.

### ED-419 · Phones' day thread: larger dots and rows as long as their task
- **Date:** 2026-11-21. **Owner:** asked for main's thread sizes back on phones ("Dots and rows", "Phones, Full + Minimal"), then over three reviews: keep the redesign's now card with a larger dot, keep the redesign's knot, and "Task dot, done dot = 52, 50; Dot column, gap to text 48, 10; Dragged dot, landing preview = 52"; caps and the now card's dot "Both 52"; then "Approve, commit" after the review page.
- **Change (compact width only, Full and Minimal):** task dots 52 and done dots 50 (were 34 and 32); the Wake Up and Wind Down caps 52 (34); the now card keeps its card and 80 minimum with a 52 dot (45 ring); task rows grow with their task as on main (1.6 px a minute, 88 to 288; were fixed 54 ahead, 48 done); the dragged dot and the landing preview 52. The 48 column and 10 gap stay, the 52 dots overhang 2 px each side.
- **Unchanged:** the knot (26), free time (28), the now bead (26), the fold rows; tablets, the Mac and web Day view with hours, and Minimal's Day column at normal widths (no golden there moved).
- **How:** `ThreadScale` (`shared/dot/thread_scale.dart`) picks the phone or Concept E sizes by `AppLayout.classOf`, so a phone in landscape and a short or narrow window get the phone thread too; the hour scale is always Concept E. Tokens `phoneThreadDot`, `phoneThreadDoneDot`, `threadPerMinute`, `threadRowMin`, `threadRowMax`. `ThreadRowFrame` moved to its own file.
- **Departs from:** the approved E-Phones and E-PhonesMinimal boards (34 / 32 dots, fixed rows, ED-363) on phones. With rows by length the moving now still hops only when a task starts or ends (ED-364).
- **Checks:** analyze and format clean; 7542 tests pass, 31 skipped; 263 phone goldens updated; three tests scroll to a later task before tapping it.

---

## Pending owner answers

> **Round 2 close-out (2026-11-14, ED-335).** Rows answered by later decisions are marked. The decisions still waiting on the owner are listed in ED-335.

| Thread | Question | Where it stands |
|---|---|---|
| 9acf09f2 | Scale direction: "keep large", "C confidence" (modest rows, one big hero, more space between groups) or "both"? | Asked twice on 2026-11-03 (22:43 and 22:47 UTC). No answer. The large scale is on the boards (ED-025, ED-026). **Presented 2026-11-05 as G3-1 on `E-G3-1` (ED-101); option C revised to the owner's sizes (ED-103). Resolved by ED-104 (G3-1, option C · Both, revised).** |
| 9acf09f2 | The owner's comment ended with "what". Was more text cut off? | Asked on 2026-11-03. **Closed 2026-11-05 (ED-103): the owner says it is not a new design requirement.** |
| 24c4bdf0 | A-Map still describes A-Wide. Should the map follow A-Focus as the Mac/web design? | Asked on 2026-11-04. No answer. The working E Map answers this for E, but the owner has not confirmed it (ED-056). **Close-out (ED-335): superseded; Concept E is the design, A-Map is history.** |
| (canvas) | Is E-Focus the minimal or the full Mac/web presentation? The title says minimal; the content is full. | Never asked directly (ED-005). **Answered 2026-11-04:** E-Minimal replaced it as the wide minimal layout (ED-064), and E keeps no wide Focus presentation (ED-065). |
| f55c7d26 | "the keyboard": restore the whole iPhone keyboard to its look from before the iOS-controls pass? | Offered on 2026-11-03. No answer (ED-032). **Settled by G3-7 (ED-135): the stock iPhone keyboard with a neutral return key.** |
| 69ac6f26 | iOS switch on-state: teal or system green? | Offered on 2026-11-03. No answer (ED-041). **Answered 2026-11-05: teal (G3-4 option A, ED-112).** |
| 69ac6f26 | iOS system greys and colours below 4.5:1 contrast (tab labels #8E8E93 at about 3.1:1): keep native, or darken? | Raised on 2026-11-03. The swipe colours were reverted, but the tab labels were never decided (ED-042). |
| 323fc074 | Simplify the web orb to match C's plainer web orb? | Offered on 2026-11-03. No answer (ED-052). **Presented 2026-11-05 as option B of G3-2 (ED-105); not chosen: G3-2 resolved as A (ED-106).** |
| 94195952 | Flatten the hover-lift shadow on Lunch (web workspace)? | Offered on 2026-11-03. No answer (ED-053). **Answered 2026-11-06: hybrid C (ED-116): flat hover tint, lift only while dragging.** |
| 5f96cf43 | The minimal-phone choices (tab names, Settings location, Earlier row, tap-to-Focus, time summary, tab-label grey). | Listed on 2026-11-04 as "small choices you might want to check". No answer (ED-055). **Close-out (ED-335): answered by G1-5, G2-3 and G2-4 (ED-068, ED-084, ED-238) and the approved E-PhonesMinimal.** |
| 55c6e2ea | C minimal phones: "Tell me what to keep or change". | No answer. This is a C board, so it only matters as a reference for E. **Close-out (ED-335): superseded; C is history.** |
| (Round 1) | All "Hypothesis · not approved" relocations: Settings out of the tab bar, one task surface, Add modes, Day menu, Calendar destination, Settings regrouping, Workspace and Focus structure. | These need an explicit owner decision before Round 2 or implementation (ED-043 to ED-051). Group 1 settled the mode structure only (ED-065 to ED-069); the rest are in register Groups 2–4. **Close-out (ED-335): each answered in Groups 2 to 4 (ED-073 to ED-099, ED-238) and drawn in Round 2.** |
| (canvas) | "Plan from Inbox · 3" on the iPhone empty day: keep it or remove it? | Never asked (ED-039). **Answered 2026-11-15 (ED-336): keep in Full as "Pull from inbox · {count}", hidden in Minimal.** |
| d06d1077 | Create task (ED-140): keep "Add another" (check beside it; Return keeps the screen open for the next task) or drop it? | Raised 2026-11-06 (ED-140). **Answered 2026-11-07: option A, no "Add another" (ED-152).** |
| ef95bd66 | Brain dump and Routine tabs (ED-139): their frames on `E-Phones-2` still use the old compact Add sheet. Redraw them in the Create task chrome? | Raised 2026-11-06 (CR-125). Asked in the decision review (Q-A2). **Answered 2026-11-07: Brain dump (ED-147, ED-148) and Routine (ED-149) open full screen on iPhone and Android. Closed.** |
