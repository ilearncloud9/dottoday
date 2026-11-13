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

**Status.** LEADING CANDIDATE — NOT APPROVED FOR PRODUCTION IMPLEMENTATION. "ACCEPTED FOR CONCEPT E" means the owner accepted it as a design decision. It does not approve implementation.

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

### ED-073 · G1-1 resolved: Option A, Workspace is Full on Mac and web
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

### ED-075 · G2-1 resolved: Calendar tab opens Month; one month grid, three ways in
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

### ED-081 · G2-4 resolved: six-group Settings root; "Everything else" means only the Settings row
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


### ED-086 · G2-5 resolved: option D, the refined full task editor
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


### ED-089 · G2-6 resolved: the minimal task screen drawings approved and merged
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


### ED-091 · G2-8 resolved: Brain dump and Routine are modes of Add (option A), merged
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

### ED-093 · G2-9 resolved: one Full Day menu everywhere; wide minimal keeps E-Minimal's menu (option B), merged
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

### ED-095 · G2-10 resolved: one keyboard scheme, option B, reconciled with the built app
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

### ED-097 · G2-11 resolved: option A′, D4 reconciled per layout
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

### ED-099 · G2-12 resolved: option A, duplicate screens consolidated
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

### ED-104 · G3-1 resolved: option C · Both, revised; merged into E-Phones Today only
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

### ED-106 · G3-2 resolved: option A, one orb drawing; merged into E-Minimal
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

### ED-110 · G3-3 resolved: Manrope is Dottoday's content typeface
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

### ED-112 · G3-4 resolved: Dottoday teal for active iOS switches; G3-C1 and two accessibility checks tracked
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

### ED-116 · G3-5 resolved: option C · Hybrid, merged into E-FullA-v2
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

### ED-132 · F1 decided: iPhone Minimal on iOS 26+ keeps the 6 pt gap; native capsule width
- **Date:** 2026-11-06. **Owner:** "For G3-6 F1, I approve Option (a) — Keep the 6 pt gap to the + button on iOS 26+ Minimal. I want to preserve genuine Apple Liquid Glass rather than replace the Minimal tab bar with a Flutter approximation."
- **Rule:** Minimal destinations stay Now · Today · Inbox. The native teal glass + stays 21 pt from the right and bottom. The visible native tab capsule sits 6 pt left of the +, centres level, and keeps Apple's system-determined three-tab width (274 pt measured on iOS 26.5, 402 pt iPhone), so its left inset grows (≈ 39 pt there instead of 21). Alignment is computed from the rendered capsule's actual bounds on every layout pass, never from a hardcoded 274 pt; the same relation holds on other iPhone sizes, rotation and accessibility settings. Day ▾ position, Full geometry (21 / 6 / 21), navigation, selected states and Inbox badges unchanged. F2 on iOS 16–18 keeps the passing ED-124 Minimal arrangement (bar 21 from the left).
- **Merged:** the five iPhone Minimal frames with the tab bar on `E-PhonesMinimal` now draw the capsule at the measured width with the 6 pt gap (on the 390 pt frames: right edge 90, width 274, left 26; ≈ 39 on a 402 pt phone); the iPhone Minimal Now caption carries the exception. Measured on the board, all five: 274 wide, gap 6, + 21 / 21, Day right 21 and 16 above, centres level. Android, Full iPhone, Mac, web and historical boards unchanged. E-Map's phone-bottom-row line updated.
- **Snapshot:** `references/concept-e/v1.15-working/`.
- **Classification:** F1 APPROVED and MERGED (design). Implementation rule recorded; not built.

### ED-133 · G3-6 resolved as a design and selected architecture direction
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

### ED-135 · G3-7 resolved: C · stock iPhone keyboard, neutral return key, no extra bar
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

### ED-152 · Q-A1 resolved: no "Add another"; each Add tab has its own action
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

### ED-154 · G3-8 resolved: inactive iPhone tab labels #6E6E73
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


### ED-155 · G3-9 resolved: darker ahead-ring shades, fills unchanged; ink check on amber
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


### ED-162 · G3-10 resolved: one vocabulary, native Mac menu conventions
- **Date:** 2026-11-07. **Owner:** "For G3-10, I approve Option A — One vocabulary across Dottoday, with native Mac menu conventions."
- **Vocabulary:** Low-energy mode; Brain dump; Review (singular); Today for the screen, Day for the actions menu; Need more time? (question) and Need More Time… (opens +5 / +15 / +30); Delete on phones (and web), Move to Trash ⌘⌫ in Mac menus, both the same deletion workflow (Trash 30 days, Undo 30 s, verified read-only in the original app). Mac menus in Title Case (Low-Energy Mode, Brain Dump…).
- **Boards changed (canvas `1794080104-b060`):** E-Phones (caption), E-PhonesMinimal (two captions), E-FullA-v2 (fidelity list and captions: Need More Time…, Review, Low-energy name resolved), E-Minimal (Mac View menu and finder "Review"; captions), E-Workspace (Day menu "Need More Time… ▸" and its submenu, ⌘K palette "Need more time · +15 min"), E-Map (feature rows, open list, Mac interaction note, C references). E-Phones-2 and E-Phones-3 already used the approved names. Verified: no "Running late", "Reviews", "Gentle Day" or "Low-energy day" on any active board; all boards fit.
- **Historical:** older decisions, history boards and snapshots keep the old words as evidence; they are superseded by this entry (marked in the rules' inconsistency table I15, I21, I23, I24, I30, N10 and the screen inventory).
- **Internal names unchanged:** l10n keys `runningLate*` etc.; only visible strings change (handoff).
- **Classification:** MERGED (design). Production implementation not authorised.


### ED-163 · G3-11 resolved: Need more time offers +5, +15 and +30 everywhere
- **Date:** 2026-11-07. **Owner:** "For G3-11, I approve Option A — +5, +15 and +30 minutes everywhere."
- **Behaviour (unchanged from the built app):** exactly three choices; each keeps the existing extension, scheduling, overlap and free-time rules, in the task's own date context; applied once and only on the user's choice. Nothing is applied by opening a sheet, menu or palette. No-shame wording from ED-162.
- **Presentation:** iPhone and Android sheets and Now cards: three 44 pt chips, row wraps under the label at 200 % text (checked headless: no clipping, nothing pushed out). Mac: Need More Time… submenu, three items (already drawn). Web: popover with three items. ⌘K: "Need more time · +15 min" plus Need More Time… for the others. Accessible names "Extend task by 5 / 15 / 30 minutes". iPad and Android tablets: three choices are a requirement for Prompt D Round 2; layout not assumed.
- **Boards changed (canvas `1794080578-9c6b`):** E-Phones (3 sheets), E-PhonesMinimal (3 rows, captions), E-Minimal (Mac and web Now cards, web popover, captions), E-Workspace (2 inspectors), E-FullA-v2 (increments note), E-Map (Now popover row, resolved note). E-Phones-2 and E-Phones-3 have no extension control; none added.
- **Classification:** MERGED (design). Production implementation not authorised.


### ED-164 · G3-12 resolved: done tasks fold into "Earlier", with no count
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

### ED-166 · G4-1 resolved: Round 2 draws the core journey first
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


### ED-167 · G4-2 resolved: 600 / 840 kept; the editor docks only from 1160
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


### ED-169 · G4-3 resolved: Mac minimum window 840 × 640 (design only)
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

### ED-171 · G4-4 resolved: tablet navigation by width class, native per platform (strategy only)
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


### ED-172 · G4-5 resolved: a proper compact mobile web
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

### ED-191 · G4-7 Q2 resolved at design level (signed-in web); Q2-W1 open
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


### ED-218 · CR-143 resolved (option A): ⌥⌘I toggles the right-hand pane in both modes
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


### ED-252 · Tablet Q1 decided: option A, the Workspace on expanded tablets
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

### ED-254 · Tablet Q2 decided: option A, the Day menu in Minimal by width
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

### ED-256 · Tablet Q3 decided: option B, phone content sizes with touch spacing
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

### ED-258 · Tablet Q4 decided: option A, handwriting in text fields only
- **Date:** 2026-11-13. **Owner:** "Option A" (board E-T4).
- **Decision:** Apple Pencil and Android styluses do two things.
  - **In text fields** (Add, task title, notes, Search or run, Settings fields), the system's own handwriting turns writing into text: Scribble on iPad, system stylus handwriting on Android tablets that have it. The usual time parsing then runs (R-06, R-07).
  - **Everywhere else**, the stylus acts like a finger: tap, drag a dot, hold to select (ED-116).

  There are no Pencil-only gestures (double-tap, squeeze), no hover effects, and no drawing or handwritten notes. No new dependency.
- **For Round 2:** verify that Flutter text fields accept Scribble on iPad and stylus handwriting on Android. If one does not, record it as a platform exception with a follow-up task. Draw the focused-field state with ink in both themes.
- **Not chosen:** B (also write on the day). It is kept on E-T4 as history, with A marked chosen.
- **Board:** E-T4 relabelled. Published version `1794570730-38e8`; both files equal local.
- **Checklist:** Q4 answered in `E_TABLET_CHECKLIST.md`. Q5 is open. Snapshot v2.24-working.

### ED-259 · Tablet Q5 decided: the option D editor sits beside the day only where it can dock
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

### ED-261 · CR-102 decided: touch-first web windows use the ED-256 touch sizes
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

### ED-266 · R2-1a decided: medium Minimal on tablets uses E-Minimal's places, by width
- **Date:** 2026-11-13. **Owner:** "By width (recommended)".
- **Decision:** in Minimal, medium tablet windows (600–839; iPad top tabs, Android rail) offer Now · Inbox · Calendar · Search, E-Minimal's places, the same as wide Minimal on Mac and web. This follows Q2 (ED-254) and DESIGN_PRINCIPLES §2: width decides. Compact windows keep the phones' Now · Today · Inbox. Expanded windows use the sidebar with the same four places.
- **Applied:** E-R2-1 and E-R2-1-Dark (row 2 tag and note, canvas title). Published version `1794574600-2173`; all three files equal local.
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

### ED-273 · R2-4a decided: B, the option D editor docked beside the grid on expanded tablets
- **Date:** 2026-11-13. **Owner:** "B · editor docked".
- **Decision:** on expanded tablets, tapping a task in the Workspace opens the approved full editor (option D, ED-086), not the Mac inspector.
  - It docks at the right, 420 wide, where the ED-168 minimums fit (≥ 1160; sidebar 216, grid ≥ 480, editor 420). The grid narrows to the days that fit (minimum column 180, ED-269), and the Plan panel steps aside below 3 days (ED-184).
  - Otherwise it floats: on iPad over the content, on Android in an M3 modal side sheet. Compact windows keep the phone sheets.
  - On Android it is the approved Edit task, in an M3 standard side sheet when docked.
- **Effect on other surfaces:** the Workspace inspector (ED-170) stays a Mac and web surface. Tablets have one task surface, the same editor as the phones (CLAUDE.md §11, "never fork a second" surface).
- **Applied:** E-R2-4 and E-R2-4-Dark (B marked chosen, A kept as history, question marked decided). Published version `1794576132-c2e6`; all three files equal local.
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

### ED-278 · R2-6a decided: A, the built selection card in E on every platform
- **Date:** 2026-11-13. **Owner:** "A · built card".
- **Decision:** multi-select on every platform uses the app's built SelectionBarFrame, restyled in E: "3 selected" with ✕ (Done selecting), then Move · Duplicate · Colour · Save as routine · Delete, icon over label, on E's surface.
  - Phones: it floats above the bottom row; the tabs, + and Day stay.
  - Tablets, Mac and web: it is centred under the grid.
  - The built selection behaviour, copy and accessibility apply unchanged (ED-277).
- **Not chosen:** B (iOS edit toolbar, M3 contextual bar). Kept on the board as history.
- **Applied:** E-R2-6 and E-R2-6-Dark (A marked chosen, B as history). Published version `1794576978-68cc`; all three files equal local.
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

### ED-285 · R2-9a decided: B, Focus takes the whole window on expanded windows
- **Date:** 2026-11-13. **Owner:** "B · whole window" (against the recommended A).
- **Decision:** on expanded windows (tablets, Mac, web), Focus takes the whole window. The sidebar or drawer hides; the ring, time, title and "18 min left" sit on the left; the step card, step thread, toggles, Done, "+15 min", "Next step" and the note sit on the right. Leaving with ‹ Today or Esc returns to the place and state you came from. Phones, compact and medium windows keep the full-screen phone layout.
- **Implementation consequence (not built):** this replaces the built `FocusFrame` (content area with the rail kept, `features/focus/focus_screen.dart`) with a two-column whole-window layout at the expanded width class. The tabs underneath must still keep their state while Focus is up; the parts (`FocusView` pieces) are reused, not forked. Per the owner's rule, replace the old layout; don't keep both.
- **Not chosen:** A, kept on the board as history.
- **Applied:** E-R2-9 and E-R2-9-Dark (B marked chosen, A as history, question decided). Published version `1794578818-83ca`; all three files equal local.
- **Still open on R2-9:** the board as a whole is proposed, not approved.

---

## Pending owner answers

| Thread | Question | Where it stands |
|---|---|---|
| 9acf09f2 | Scale direction: "keep large", "C confidence" (modest rows, one big hero, more space between groups) or "both"? | Asked twice on 2026-11-03 (22:43 and 22:47 UTC). No answer. The large scale is on the boards (ED-025, ED-026). **Presented 2026-11-05 as G3-1 on `E-G3-1` (ED-101); option C revised to the owner's sizes (ED-103).** |
| 9acf09f2 | The owner's comment ended with "what". Was more text cut off? | Asked on 2026-11-03. **Closed 2026-11-05 (ED-103): the owner says it is not a new design requirement.** |
| 24c4bdf0 | A-Map still describes A-Wide. Should the map follow A-Focus as the Mac/web design? | Asked on 2026-11-04. No answer. The working E Map answers this for E, but the owner has not confirmed it (ED-056). |
| (canvas) | Is E-Focus the minimal or the full Mac/web presentation? The title says minimal; the content is full. | Never asked directly (ED-005). **Answered 2026-11-04:** E-Minimal replaced it as the wide minimal layout (ED-064), and E keeps no wide Focus presentation (ED-065). |
| f55c7d26 | "the keyboard": restore the whole iPhone keyboard to its look from before the iOS-controls pass? | Offered on 2026-11-03. No answer (ED-032). |
| 69ac6f26 | iOS switch on-state: teal or system green? | Offered on 2026-11-03. No answer (ED-041). **Answered 2026-11-05: teal (G3-4 option A, ED-112).** |
| 69ac6f26 | iOS system greys and colours below 4.5:1 contrast (tab labels #8E8E93 at about 3.1:1): keep native, or darken? | Raised on 2026-11-03. The swipe colours were reverted, but the tab labels were never decided (ED-042). |
| 323fc074 | Simplify the web orb to match C's plainer web orb? | Offered on 2026-11-03. No answer (ED-052). **Presented 2026-11-05 as option B of G3-2 (ED-105); not chosen: G3-2 resolved as A (ED-106).** |
| 94195952 | Flatten the hover-lift shadow on Lunch (web workspace)? | Offered on 2026-11-03. No answer (ED-053). **Answered 2026-11-06: hybrid C (ED-116): flat hover tint, lift only while dragging.** |
| 5f96cf43 | The minimal-phone choices (tab names, Settings location, Earlier row, tap-to-Focus, time summary, tab-label grey). | Listed on 2026-11-04 as "small choices you might want to check". No answer (ED-055). |
| 55c6e2ea | C minimal phones: "Tell me what to keep or change". | No answer. This is a C board, so it only matters as a reference for E. |
| (Round 1) | All "Hypothesis · not approved" relocations: Settings out of the tab bar, one task surface, Add modes, Day menu, Calendar destination, Settings regrouping, Workspace and Focus structure. | These need an explicit owner decision before Round 2 or implementation (ED-043 to ED-051). Group 1 settled the mode structure only (ED-065 to ED-069); the rest are in register Groups 2–4. |
| (canvas) | "Plan from Inbox · 3" on the iPhone empty day: keep it or remove it? | Never asked (ED-039). |
| d06d1077 | Create task (ED-140): keep "Add another" (check beside it; Return keeps the screen open for the next task) or drop it? | Raised 2026-11-06 (ED-140). **Answered 2026-11-07: option A, no "Add another" (ED-152).** |
| ef95bd66 | Brain dump and Routine tabs (ED-139): their frames on `E-Phones-2` still use the old compact Add sheet. Redraw them in the Create task chrome? | Raised 2026-11-06 (CR-125). Asked in the decision review (Q-A2). **Answered 2026-11-07: Brain dump (ED-147, ED-148) and Routine (ED-149) open full screen on iPhone and Android. Closed.** |
