# ADR-0015 · Structured-style day thread: tinted dots, a done circle, a full-width sheet

Status: Accepted · Date: 2026-10-30 · Amends docs/10 §1, §3, §6, ADR-0007; CLAUDE.md §8 (R-05 resize)

## Context
The owner compared Today with Structured on the same phone. Dottoday's dots were thin outlines
until a task was done, the dot itself was the done toggle, and the day sat on an inset card with
neighbour days peeking, a title row and page dots. Together these left about half the screen
for the thread. The owner asked for bold dots that look the same everywhere, a separate done
control that stays visible, and the room Structured gives the timeline. Concept A's language
(the thread, the dot, the colours and the nav) stays.

## Decision
- **Dot.** Every `TaskDot` is a tint of the task colour (`TaskSwatch.tint`) with the icon in the
  colour itself, drawn at a bold 2.8 stroke. The icon colour is the spec hue, moved toward the
  text colour only as far as 3:1 against the tint needs (`TaskSwatch.glyph`). The dot looks the
  same upcoming, done or missed. A live dot adds its progress ring inside the edge, and a skipped
  one fades its icon inside a dashed ring. This applies everywhere `TaskDot` is used. Home-screen
  widgets and the Live Activity keep their native drawing for now (owner, 2026-10-30).
- **Done.** Tapping the dot opens the task (Focus for the live one). The `DoneCircle` at the row's
  end marks a task done: a ring in the task colour that fills with a white tick, and tapping it
  again undoes it. A done task keeps its place and its struck title. The circle carries the
  semantics (button, checked, "Mark done" / "Mark not done").
- **Today layout.**
  - The header keeps two lines, bolder (`dayCaption` 13/700, `dayTitle` 30/800), and gains the
    day's numbers under the title ("0 of 15 · 22 h 55 planned").
  - The week strip is tighter, and its selected day is filled in the text colour in its rounded
    shape.
  - `DayPager` pages are full width, with no peek and no page dots. Each day is a
    `DayCard.sheet`: top corners rounded, the month pull handle at its top, no title row. A
    medium-width window caps the sheet at `DotSize.readableColumn`. The Mac/web spread is
    unchanged.
- **Rows.** Day-thread rows use a 56 px dot (`DotSize.threadDot`), a 20/700 title and a 15/500
  time. A row stretches with its task at 1.6 px a minute, between 88 and 288 px, so short tasks
  keep a readable row and long ones read long.
- **Drag.** A lifted task can drop anywhere on the day. Free gaps keep a task inside them when it
  fits. A task's row accepts the drop where it was let go, so the two tasks overlap. Overlapping
  tasks draw as two tinted capsules that overlap slightly, the lower one notched, beside
  "Tasks are overlapping" with the last word in the lower task's ink. It never uses a warning
  colour (no-shame).
- **Resize.** Dragging a row's edge to resize is removed from the day timeline, at the owner's
  request (2026-10-30). Length is changed in the task sheet's duration. The Week board is
  unchanged.

## Consequences
- R-05 still holds for drag-to-move, 5-min snapping, multi-select, haptics and "shift everything
  after". Its "drag-edge resize" on the day thread is withdrawn by the owner. CLAUDE.md §8 and
  docs/10 §6 say so.
- The Concept A renders in `docs/design-references/png/` (`Main`, `A-ios-*`, `A-android-today`)
  no longer match the dot, the done circle or the card. Where they disagree with this ADR, this
  ADR wins and the goldens are the reference.
- Lists that show a done task only by its dot (Past days' journal row) now show it by the struck
  title or the row's counts.
- The Mac spread's side days have no done circle. Their tasks are marked done from the sheet.
- Rejected:
  - Solid dots with a white icon (the owner's first ask, replaced by the tint before work began).
  - Evenly spaced rows (they would have hidden free time and made edge resize meaningless).
  - A resize handle on the dot (the owner chose the sheet's duration instead).
