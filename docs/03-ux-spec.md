# 03 — UX Specification

Goal: a calm, legible, fast interface that feels native on every platform while sharing one design
system. "Flawless" here means: no dead ends, no ambiguous gestures, every action undoable, every
state (empty, loading, error, offline) designed.

## 1. Design tokens (implement in `lib/core/theme/`)

### Colour
Semantic roles only in code; never raw hex outside `app_colors.dart` and the generated
`block_palette.gen.dart`.

| Token | Light | Dark | Use |
|---|---|---|---|
| `surface` | #FAFAF8 | #121214 | page background |
| `surfaceRaised` | #FFFFFF | #1C1C20 | cards, sheets |
| `surfaceSunken` | #F1F1EE | #0C0C0E | timeline gutter |
| `onSurface` | #1A1A1C | #F2F2F0 | primary text |
| `onSurfaceMuted` | #6B6B70 | #9A9AA0 | secondary text (≥ 4.5:1 on surface) |
| `outline` | #E2E2DE | #2C2C32 | hairlines |
| `accent` | #3B6CF6 | #7FA0FF | primary actions, now-line, focus ring |
| `onAccent` | #FFFFFF | #0B1020 | |
| `success` | #1F9D55 | #4CCB86 | done state |
| `warning` | #D98A00 | #FFB547 | overdue (never red — overdue is normal) |
| `danger` | #D33F49 | #FF6B73 | destructive only |

Block palette (user-selectable, 12): coral, tangerine, amber, lime, mint, teal, sky, indigo, violet,
magenta, rose, slate. Each has `base` (fill at 18 % alpha in light / 28 % in dark), `strong` (text/icon),
and a 3:1 minimum contrast against surface for the strong variant. Keep palette JSON in
`assets/design/palette.json` and generate Dart via build step (`dart run tool/gen_block_palette.dart`;
a test fails when the generated file is stale). Strong is additionally held to 4.5:1 on the
composited block fill, since block titles are body text.

### Typography
Inter (bundled) with platform fallback. Sizes scale with system text size up to 200 %.
`display 28/34 600`, `title 20/26 600`, `body 16/22 400`, `label 13/18 500`, `mono 13` for times.
Minimum rendered body size 16 on mobile; never below 11 in widgets.

### Spacing & shape
4-pt grid. `xs 4, s 8, m 12, l 16, xl 24, xxl 32`. Radii: `block 10`, `card 14`, `sheet 20`. Touch
targets ≥ 44×44 pt (48 dp Android). Hairlines 1 px at `outline`.

### Motion
Durations `fast 120 ms`, `base 200 ms`, `slow 320 ms`; curve `easeOutCubic`. All motion disabled or
cross-faded when the OS reduced-motion flag is on. Haptics: light on pick-up, selection tick on snap,
success on complete.

## 2. Information architecture

Mobile: bottom bar — **Today · Inbox · Week · Search · Settings**; FAB = Quick Add.
Desktop/Web: left rail with the same five; Quick Add via ⌘/Ctrl+N and a persistent field in the header.
Month view opens from the Today date header. The current date is always one tap away ("Today" chip).

## 3. Screens

### 3.1 Today (timeline)
- Header: date (tap → month), weekday, "Today" chip when away from today, sync pill, overflow menu
  (Running late, Plan inbox, Duplicate day, Export day).
- Optional all-day strip (imported all-day events and dateless-but-dated tasks).
  Clarified in M3.2: an item is all-day when it starts at the day's local midnight and lasts the
  maximum 24 h (there is no separate flag). The strip is pinned above the scrolling timeline (capped
  at a third of the screen, scrolling on its own) so all-day items stay visible at any scroll.
- Outside-hours zones (clarified in M3.2): the time before the weekday's day start and after its
  day end is drawn at a quarter of the core density, with a "Before 07:00" / "After 22:00" toggle
  that expands it to full density for the session. Hour labels that would collide are skipped.
  Density (96 px/h core) scales with the text size up to 2×; blocks are never shorter than 44 pt
  × text scale, and overlap columns are computed on drawn heights so blocks never cover each other.
- Timeline: hour gutter left (mono labels), blocks right. Now-line with a dot in `accent`, animates once
  per minute. Past area tinted `surfaceSunken`. Gaps show a faint "+" on hover/long-press.
- Block anatomy: colour fill, icon circle, title (1–2 lines), time range `08:00–08:45`, subtask progress
  ring, badges: pinned (lock), calendar (small source icon), recurring (↻), alerts (bell with count).
- Done: fill desaturates, title strikethrough at 60 % opacity, checkmark in icon circle.
- Overdue: thin `warning` left bar; no sound, no badge spam.
- Empty day: illustration-free, a single line "Nothing planned. Add something or pull from your inbox", two buttons.

### 3.2 Gestures (timeline)
| Intent | Mobile | Desktop/Web |
|---|---|---|
| Scroll | 1-finger drag | wheel/trackpad |
| Open | tap | click / Enter |
| Complete | tap icon circle | click circle / Space |
| Move | long-press 250 ms → drag | drag |
| Resize | handles appear on selected block; drag edge | drag top/bottom edge |
| Multi-select | long-press then tap others | Shift/⌘-click |
| Shift followers | chip appears during drag: "Shift later blocks: On/Off" | same + hold Alt to invert |
| Quick add at time | long-press empty gap | double-click gap |
| Context menu | long-press done block / ⋯ | right-click |
Drag uses a lifted ghost with shadow and shows the live snapped time in a floating label. If the drop
would overlap a pinned block, the block settles after it and a toast explains.

### 3.3 Quick Add sheet
Bottom sheet (mobile) / popover (desktop). One text field with live token chips (time, date, duration,
repeat). Row of duration chips. "More…" expands to the full editor inline (no new screen). Buttons:
Add · Add another. Enter adds; Shift+Enter adds and keeps open. Pasting multi-line text shows "Add 5
tasks?" confirmation inline.

### 3.4 Task editor
Full-height sheet. Sections in order: Title & icon/colour row · When (date, time input, duration,
end time shown) · Repeat · Alerts · Subtasks (reorderable, add inline) · Notes · More (pin, travel
buffer, energy, calendar write-back status). Destructive actions at the bottom: Move to inbox · Delete
(trash). Every change autosaves; sheet closes with swipe/Esc; nothing is lost on dismiss.

### 3.5 Inbox
List grouped "Unscheduled" and "Snoozed". Swipe right → Schedule (suggestions sheet), swipe left →
Trash. Drag handle to reorder. Drag an item onto the Today tab to drop it on the timeline (mobile) or
drag directly onto the timeline (desktop).

### 3.6 Week / Month
Week: 7 narrow columns, blocks as compact chips, drag between days. Month: grid with up to 3 colour
dots per day + count; tap opens Today at that date.

### 3.7 Settings
Grouped list. Changes apply immediately. Dangerous actions (delete account, empty trash) require a
typed confirmation on desktop/web and a second tap on mobile.

### 3.8 States
Every screen has designed: empty, loading (skeletons, no spinners > 300 ms), offline (banner, full
functionality), error (inline, retry), permission-denied (calendar/notifications: explain + deep link
to system settings).

## 4. Accessibility (ship gate, R-12)
- Semantics labels on every block: "Gym, 7:00 to 7:45 AM, 2 of 3 subtasks done, recurring, pinned".
- All drag actions have a non-drag equivalent (editor time field, context-menu "Move to…").
- Focus order follows visual order; visible focus ring (`accent`, 2 px).
- Dynamic Type 200 % does not clip; block height grows with text.
- Colour never the sole signal (icons + text for status).
- Reduced motion, reduced transparency, high-contrast honoured.
- Screen-reader smoke test (VoiceOver, TalkBack, NVDA) in the release checklist; semantics widget tests in CI.

## 5. Copy rules
Short, plain, friendly, never shaming ("Not done yet" not "You missed this"). Sentence case. No
exclamation marks in system copy. All strings in ARB files; placeholders typed.

## 6. Platform adaptation
Shared layout, native affordances: iOS/macOS use cupertino-style sheets and context menus; Android
Material 3 with predictive back; macOS menu bar (File/Edit/View with shortcuts) and window min size
900×600; Web responsive from 360 px, keyboard-first, PWA installable.
