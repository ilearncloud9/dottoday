# Group 3 consistency-cleanup batch (CR-100 and the 15 register fixes, CR-135)

Owner instruction (2026-11-07): correct only clearly documented technical inconsistencies that follow existing approvals; present anything that needs a new visual choice, changes an approved dimension or adds behaviour. Historical boards untouched. Canvas after this batch: `1794083800-6a81`; snapshot `v1.36-working`.

**Legend:** APPLIED = changed on the boards; NO CHANGE = already consistent or resolved by an earlier decision; OWNER = needs your choice (recommendation given, nothing changed).

| # | Item | Problem today | Correction | Boards | Changes an approved visual? | Status |
|---|---|---|---|---|---|---|
| 1 | Now-bead size (CR-015, I1) | 16 px phones, 14 px wide, 12 px in legends | none: the per-width sizes are documented (rules §5, 16 phones / 14 wide); legends are board keys, not product UI | — | no | NO CHANGE (documented) |
| 2 | Now-ring track and cut-out (CR-016, I2) | track `rgba(task,.2)` vs `#E4E3F7`; cut-out 3–5 px | needs one recipe | EP, EPM, EM, EW, EFA2 | yes (ring drawing) | OWNER · rec.: track = task colour at 20 % everywhere (keeps the colour as the cue; `#E4E3F7` only for the indigo orb on wide), cut-out 5 phones / 4.5 wide |
| 3 | Ahead-ring width (CR-017, I3, N18) | 4 / 3.5 / 3 / 2.5 px | needs a width per size | same | yes | OWNER · rec.: 4 px on 34 px dots, 3 px on dots ≤ 28 px, 2.5 px horizon only; colour stays the `ring` token (ED-155) |
| 4 | Calendar dot centre and ring (CR-009, I4) | centre `#FBF7F1` / `#FFFFFF` / `#FFFDF9`; EM ring 2 px | needs one centre | EP, EM, EW | yes | OWNER · rec.: centre = the surface it sits on (no white disc), ring 2.5 px |
| 5 | Wake Up cap (CR-018, I5) | 32 px vs 34 px | needs one size | EP, EPM, EM | yes | OWNER · rec.: 34 px, matching task dots |
| 6a | Android Day button (I7, CR-100) | 40 dp hit area (minimal 48) | 48 dp hit area, drawn size 40 unchanged (rules §6.4) | E-Phones, E-Phones-2 | no | APPLIED (3) |
| 6b | Android FAB radius (I8) | 22 vs 16 | — the extended FAB was removed (ED-123/ED-125); every active FAB is 16 | — | no | NO CHANGE (already resolved) |
| 6c | Now card radius/height (I9) | iOS r24/72, Android r22/74 | platform difference or one value | EP, EPM | yes | OWNER · rec.: keep per platform (M3 vs iOS), document it |
| 7a | Add input type (CR-004, I10) | 500 19 / 600 20 / 600 19 | needs one weight | EP, EPM | yes | OWNER · rec.: 600 20 (minimal's, which already passed 200 % checks) |
| 7b | Android Edit title font (CR-005, I12) | Roboto | Manrope per ED-110, but G3-C1 asked for a visual comparison first | EP | yes | OWNER · comparison to be shown before merging |
| 8a | Android AM/PM selected (CR-011) | used the board's Hypothesis amber | — that control is no longer on any active board | — | no | NO CHANGE (no longer drawn) |
| 8b | Android Day menu surface (I13) | `#F7EFF4` (pink-lavender) | `#F3EEE6`, the documented Android surface token | E-Phones-2 | no (token correction) | APPLIED (1) |
| 8c | New: iPad row "Alarms off" tag | uses the board's Hypothesis amber `#FBEBD0` / `#6E4300` in product UI | needs a warning token | E-Phones | yes (new token) | OWNER · rec.: neutral surface tag with an icon, no amber |
| 9a | Mac sidebar material (CR-024, I14) | no blur on E-Minimal; `blur(30px)` on Workspace | E-Minimal's Mac sidebar drawn with the approved vibrancy (ED-130); web stays solid | E-Minimal, E-FullA-v2 (minimal reference frame) | no (follows ED-130) | APPLIED (2) |
| 9b | Mac context-menu radius (CR-025) | 8 vs 10 | native menus in the app; drawing needs one value | EM, EW | minor | OWNER · rec.: 10 (closer to current macOS) |
| 9c | Web focus ring (CR-026, I17) | 3 px at 45 % with 2 px offset vs 2 px gap + 2 px solid | one recipe | EM, EW, E-Earlier | yes | OWNER · rec.: 3 px teal at 45 %, 2 px offset (already on E-Minimal and E-Earlier) |
| 10 | Primary Add on Mac/web (CR-010, I18, N13) and Day button font (N14) | ink Add on E-Minimal web, teal elsewhere; system vs Manrope | one colour; one font rule | EM | yes | OWNER · rec.: teal Add everywhere (`accent` token); chrome buttons in the platform font |
| 11 | Pane widths (CR-023, N5) | sidebar 200 / 210 / 216; task pane 290 vs 248 | one set | EM, EW, EFA2 | yes | OWNER · rec.: sidebar 216 on Mac and web; task pane 290 (wait for G4-2 breakpoints) |
| 12 | Repeat marker (CR-012, I26) | icon / "· repeats" / "↻" | one form | EP, EW, EM | yes | OWNER · rec.: the 12 px icon with "repeats" as its accessible name |
| 13 | Touch targets (CR-100) | iOS tip dismiss 40, Android tip dismiss 44, Android Day button 40, iOS and Android date chips 34 | hit areas 44 pt / 48 dp with the drawn size unchanged (rules §6.4) | E-Phones, E-Phones-2 | no | APPLIED (tips 4 iOS + 3 Android; Day button 3; chips 20). +5/+15/+30 done in ED-163. iOS in-field Add no longer drawn (Create task replaced it). iOS nav-bar glass buttons (Done, ⋯, Create task) are native toolbar items; their 44 pt hit region is the system's (implementation check) |
| 14 | Now card and title sizes on wide (N12) | 68 Mac / 64 web; title 16 / 17 | one size | EM | yes | OWNER · rec.: 68 / 16 on both (same layout at the same width, CLAUDE.md §11) |
| 15 | Glass shadow tiers (I32) | outer shadow varies by element | confirm the tiers as intended | EP, EPM | no change if confirmed | OWNER · rec.: confirm as elevation tiers |
| 16 | CR-135 · All icons pinned row | old 9-colour row | 12 approved colours + ⋯ All colours | E-Phones | no (follows ED-161) | APPLIED (owner comment, `1794082186-50fa`) |

**Verification:** every changed board was rendered headless and compared with its pre-change copy. Board extents are unchanged, no visible text moved, and nothing is newly clipped. The only text change is the intended Minimal header (CR-138). Device behaviour is not verified.


## Reconciliation 2026-11-08 (ED-197) · read-only, nothing changed

Checked against the decision log to ED-196 and the live active boards (version `1794173275-2921`: E-Phones, -2, -3, E-PhonesMinimal, E-Minimal, E-FullA-v2, E-Earlier, E-Responsive, E-MobileWeb, E-G4-3-Narrow and dark copies). Classes: **A** resolved and verified on the boards · **B** superseded by a newer approved rule · **C** still open, needs the owner · **D** implementation or testing only.

| # | Item | Later decisions | Current boards (measured) | Class | Recommendation | Kind |
|---|---|---|---|---|---|---|
| 2 | Now-ring track and cut-out · **RESOLVED 2026-11-08 (ED-198): option A applied** | ED-174 sets the **dark** now track to the task colour at 25 %; nothing for light | Light track is `rgba(task,.2)` on phones, E-MobileWeb, part of E-FullA-v2 / E-Earlier, but fixed `#E4E3F7` for indigo on E-Minimal (11), E-FullA-v2 (11), E-G4-3-Narrow (27), E-Earlier (4), E-PhonesMinimal (3), E-MobileWeb (1); the teal arc mixes `#2A9D8F` and `#289588` | C | Task colour at 20 % in light (25 % dark, ED-174) everywhere; arc in the `ring` token; cut-out 5 phones / 4.5 wide | Subjective (small) |
| 3 | Ahead-ring width · **RESOLVED 2026-11-08 (ED-199): option A applied** | ED-155 sets the colour only | Inset 4 / 3.5 / 3 / 2.5 px and 3.5 px borders across boards | C | 4 px on 34 px dots, 3 px on dots ≤ 28 px, 2.5 px horizon | Subjective (small) |
| 4 | Calendar dot centre and ring · **RESOLVED 2026-11-09 (ED-200): option A applied** | none | Centre `#FBF7F1` (phones, E-Earlier, E-MobileWeb), `#FFFDF9` (E-FullA-v2, E-G4-3-Narrow), `#FFFFFF` with a 2 px ring (E-Minimal, E-G4-3-Narrow minimal frames) | C | Centre = the surface it sits on; ring 2.5 px | Subjective (small) |
| 5 | Wake Up / Wind Down cap · **RESOLVED 2026-11-09 (ED-201): option A applied** | none | 32 px and 34 px both drawn (E-Phones, E-Earlier) | C | 34 px, matching task dots | Subjective (small) |
| 6c | Now card radius / height · **RESOLVED 2026-11-09 (ED-202): option A, one 24 px radius** | ED-104 (G3-1) set heights per platform: 80 iOS / 82 Android | Heights match ED-104; radius 24 iOS / 22 Android remains | C (narrowed to radius) | Keep the radius per platform and document it | Subjective (confirm) |
| 7a | Add input type · **RESOLVED 2026-11-09 (ED-204): Manrope 600 20 on Android Minimal** | ED-140–142 made Create task the Add screen; G3-C1 comparison still owed (ED-112) | Remaining inputs: 500 19 system (iPhone, 1 frame), 500 20 Roboto (Android), 600 20 / 600 19 Manrope (minimal) | C | Decide with 7b in the G3-C1 comparison | Subjective |
| 7b | Android Edit title font · **RESOLVED 2026-11-09 (ED-204): Manrope 700 24/30** | ED-110 (Manrope for content), ED-112 (G3-C1 comparison first) | Android title fields 500 22 Roboto (5 frames) | C | Show the G3-C1 comparison, then decide | Subjective |
| 8c | iPad row "Alarms off" tag · **RESOLVED 2026-11-09 (ED-205): option A applied** | none | Still board amber `#FBEBD0` / `#6E4300` in product UI ("Alarms off for Dottoday · fix it on the …", E-Phones) | C | Neutral surface tag with an icon | Subjective (small) |
| 9b | Mac context-menu radius | Mac menus are native (rules §13 item 7 "Mac: … native menus"; CLAUDE.md §11 platform conventions) | Drawn 8 and 10 as approximations | D | Use native menus; no drawing change needed | Implementation |
| 9c | Web focus ring · **approved (ED-174), not yet applied to the boards; needs your OK to edit them** | **ED-174** approved the 2 px surface gap with a solid ring (dark `#7FD6CB`) | Old 3 px 45 % outline still on E-Minimal (1), E-FullA-v2 (3) and the G4-7 kit; it measures 2.0–2.1:1 (fails 3:1); the gap + solid ring measures 5.9–7.2:1 | B | Mechanical: replace the 45 % outline with the ED-174 ring where drawn (needs your OK to edit boards) | Mechanical |
| 10 | Primary Add on Mac/web; Day button font · **Day button font RESOLVED 2026-11-09 (ED-206): system 13/500; web Add teal approved (mechanical), not yet applied** | `accent` token role already lists "Add button" (rules §4.2) | E-Minimal web Add is ink `#241F2B`; others teal | C (Add colour is mechanical under the token; Day-button font is a choice) | Teal Add (token); chrome buttons in the platform font | Mixed |
| 11 | Pane widths · **RESOLVED 2026-11-09 (ED-207): Minimal sidebar 200 on Mac and web** | **ED-168** sidebar 216 (Full); E-Minimal column 290 is a different component from the 248 Full inspector | Full: 216 verified (E-FullA-v2 ×10, E-G4-3-Narrow Full ×5); Minimal: sidebar 200 Mac / 210 web | C (narrowed to Minimal Mac vs web sidebar) | One Minimal sidebar width for Mac and web (same layout at the same width) | Subjective (small) |
| 12 | Repeat marker | none | ↻ on E-FullA-v2 (25) and E-G4-3-Narrow (20); icon named "repeats" on phones, E-Earlier, E-MobileWeb; "· repeats" once on E-Phones | C | The 12 px icon, accessible name "repeats" | Subjective (small) |
| 14 | Now card and title on wide | none | E-Minimal: 68 Mac / 64 web | C | 68 / 16 on both | Subjective (small) |
| 15 | Glass shadow tiers | ED-124/ED-133: the iPhone tab bar and Day ▾ are native (system shadow) | Flutter-drawn chips, capsule, Close and pull-down shadows still vary | C (narrowed) | Confirm them as elevation tiers | Subjective (confirm) |

**Count:** A 0 · B 1 (9c) · C 13 · D 1 (9b). No item is fully resolved on the boards. Narrowed by later decisions: 6c (heights), 11 (Full widths), 15 (native bars).

**Item 2 applied (ED-198):** light now-rings use the task colour at 20 % for the track and the ring token for the arc. 105 values changed on 8 boards; the fixed lavender track is gone from every light now-ring; every thread now-dot already had the approved cut-out (5 px phones, 4.5 px wide), so no cut-out changed. Dark untouched. Remaining: 11 open (C), 1 superseded (9c, B), 1 implementation-only (9b, D).

**Item 3 applied (ED-199):** ahead rings are 4 px on standard phone dots, 3.5 px on standard wide dots and 2.5 px on dots of 16 px or less, in light and dark. 82 widths changed on 9 boards; outside diameters unchanged. Remaining: 10 open (C), 1 superseded (9c), 1 implementation-only (9b).

**Item 4 applied (ED-200):** calendar-event dots: centre = the surface directly behind (opaque, so masking is kept); ring 2.5 px on standard dots, 2 px on dots ≤ 16 px; grey ring #7A7280 light, #8C838A dark. 61 values on 8 boards. Remaining: 9 open (C), 1 superseded (9c), 1 implementation-only (9b).

**Item 5 applied (ED-201):** Wake Up and Wind Down thread caps are 34 px with 19 px icons on phones and the wide Day column, light and dark (82 caps on 16 boards, including the G4-7 review copies). Correction to the earlier count: E-Phones has 2 thread caps, not 4; the other two 32 px caps there are settings schedule rows and were left unchanged. Remaining: 8 open (C), 1 superseded (9c), 1 implementation-only (9b).

**Item 6c applied (ED-202):** the Now card radius is 24 px on iPhone and Android; heights stay 80 px iPhone / 82 px Android. 12 Android cards changed (E-Phones 1, E-Phones-2 2, their dark copies, E-G4-7-States 4, E-G4-7-Q4-KeepBoth 2). Remaining: 7 open (C), 1 superseded (9c), 1 implementation-only (9b).

**Items 7a and 7b (ED-203):** comparison drawn on E-G3-C1-Font-Comparison; nothing applied. Correction: the reconciliation's 7a readings "500 19 system (iPhone)" and "500 20 Roboto (Android)" were time labels, not Add inputs; the Add inputs that remain are Minimal only (iPhone Manrope 600 20, Android Manrope 600 19).

**Items 7a and 7b applied (ED-204):** Android Minimal Add input Manrope 600 20; Android task titles (Edit task title and Create task title field) Manrope 700 24/30, with the requirement that at large text the title scrolls inside the header with the cursor in view. 14 fields on 6 boards, light and dark. Remaining: 6 open (8c, 10, 11, 12, 14, 15), 1 superseded (9c), 1 implementation-only (9b).

**Item 8c applied (ED-205):** the iPad Air "Alarms off for Dottoday · fix it on the iPad" tag is a neutral tag (`#F1ECE4` / `#4E4757`, dark `#2F2A30` / `#C7BEC4`) with a 13 px bell-off icon in amber `#AF7E22` (dark `#D9A441`); 1 tag each on E-Phones and E-Phones-Dark. Light icon: 3.06:1 by colour, but only 54–87 % of antialiased stroke pixels reach 3:1; a darker light icon (`#A57620`, 3.43:1) is proposed separately, not applied. Remaining: 5 open (10, 11, 12, 14, 15), 9c approved but not applied (needs OK), 9b implementation-only.

**Item 10 applied (ED-206):** the Mac and web Day button is the system font 13/500 in light and dark (Mac `-apple-system` 700 → 500 on 6 buttons; web Manrope 700 → `system-ui` 500 on 4; per theme, 20 in all on E-Minimal, E-FullA-v2, E-G4-3-Narrow and dark copies). The mobile-web Day chip (Manrope 14/700) is a separate component and unchanged. Still pending in item 10: the E-Minimal web Add turns teal `#11615C` (accent token; mechanical, needs your OK to apply). Remaining: 4 open (11, 12, 14, 15), 2 approved but not applied (9c focus ring, 10 web Add teal), 9b implementation-only.

**Item 11 applied (ED-207):** the E-Minimal web sidebar is 200 px like Mac (light and dark); the web Now pane takes the 10 px (560 → 570) and the Day column stays at 770. Full 216 unchanged. Remaining: 3 open (12, 14, 15), 2 approved but not applied (9c focus ring, 10 web Add teal), 9b implementation-only.
