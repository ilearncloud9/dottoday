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

## Amendment (owner, 2026-10-30, second pass)
- **Header on one line.** The greeting is gone. The title is the date, "October 25, 2026 ⌄",
  all in the text colour at `dayTitle` size, and it opens the month. The day dot (or "● Today"
  away from today) and ⋯ sit on the same line, with the day's numbers under it. The Mac/web
  spread keeps "Good morning, Kody" (the weekday away from today), as the owner asked: it has
  the room for both.
- **The sheet runs under the tab bar.** It has no outline, just a soft shadow, and goes to the
  screen's bottom edge behind the floating bar and + button. Its list ends with the bar's
  height as clearance.
- **Bold nav icons.** The Inbox tray and Settings gear are solid, Search and Week use the bold
  stroke, and Today is a solid dot (14 px, 16 when selected). This is the same on the pill
  bar, the Material bar and the rail.
- **Drag, as Structured** ([help article](https://help.structured.app/en/articles/338306)):
  - The task's dot follows the finger with the time it would get.
  - A landing preview shows on the thread where it would land, like the Mac week board's hover
    card.
  - Holding over a week-strip day for 700 ms pages to that day. A quick drop keeps the task's
    time.
  - Letting go on Wake Up makes the task all day. An all-day chip dragged onto the thread gets
    a time, with the default length.
  - Dragging the + button onto the thread starts Add at that time.
  - Letting go on the Inbox tab unschedules the task.
  - While a task is dragged, a Trash target shows above the + button. Dropping on it moves the
    task to Trash with Undo; it is never deleted outright (R-08, R-11). It is drawn in the text
    colour, never red.
  - Pinned tasks never lift.

## Amendment (owner, 2026-10-31): the knot
- The joined capsules made two overlapping tasks' dots stop looking like dots. The owner asked
  for an overlap that is Dottoday's own and the same everywhere, and chose the knot from three
  mockups (knot, linked rings, two-colour stretch).
- **The dots never change.** Overlapping tasks keep their round tinted dots, segments and done
  circles exactly as when they don't overlap.
- **The knot.** Between the two dots the thread splits into two strands, one in each task's
  colour, that cross once and join again (`OverlapPiece`, painted by `paintKnot`). The earlier
  strand is the task that ends last, so a task inside a long one names the long one.
- **The line says what is shared**, concretely: "Run and Sleep share 15 min", with "share 15
  min" in the later task's ink. It is never a warning colour (11 §D no shame).
- **The same mark everywhere else** (`OverlapKnot`, 20 × 14 px): the time picker's caption (in
  place of the warning glyph), the Add sheet's "Lands on" line (in place of the colour bar) and a
  proposal's "overlaps" chip (this task's strand, the other muted). The Mac week board still
  moves an overlapping block below the other, so it draws no knot.
- Rejected: the linked rings (quieter, but a second symbol beside the thread rather than the
  thread itself) and the two-colour stretch (busiest on a small phone).

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
