# ADR-0007 · Visual identity: Concept A, "the thread and the dot"

Status: Accepted · Date: 2026-10-21 · Supersedes the visual parts of `03-ux-spec.md` §3

## Context

Milestones 0–2 shipped the data, sync and shell layers with a placeholder Material look. Before building the timeline UI (M3) the product owner evaluated four visual concepts on a design canvas (A thread & dot, B now-first stack, C day ring, D ledger) across iPhone, Android, Mac/web and Watch, and iterated on A through review comments (day pager instead of a Week tab on phones, month pulled open from the week strip, task sheet on tap, Mac three-day spread, Mac capacity-board week, Wind Down/Wake Up naming, a two-step Add with suggestions and a thread picker, one icon set).

## Decision

Adopt **Concept A** as the only visual language, specified in `docs/10-ui-concept-a.md` with reference renders in `docs/design-references/`. Key choices:

1. The day is a vertical **thread** (sun cap at Wake Up, moon cap at Wind Down); tasks are **icon dots** whose fill encodes state (outline → conic → filled-check). No hour grid on phones; a time axis appears only in pickers and in the Mac/web week.
2. Phones: Today is a **day pager** that opens on the current date; the week is the 7-dot **strip** above it; the month **pulls open** from the strip. There is **no Week tab** on phones. Mac/web keep Today · Inbox · Week · Month in the rail.
3. One nav icon set and one order on every platform: Today (dot) · Inbox (tray) · [Week, expanded only] · Search · Settings, plus the accent add button.
4. Adding a task is two steps (What with Suggestions → When with the ThreadPicker), never a blind time wheel. Mac/web edit in a right-hand panel, never a sheet.
5. Wake Up and Wind Down are first-class settings ("Day shape") and drive the day dot, thread caps, free-time maths and the Wind Down reminder.
6. Platform idioms differ only in chrome (bar/sheet/switch/chip shapes, FAB shape, keyboard shortcuts); geometry, states, copy and colour are identical. Layout adapts by width class, not by platform checks.

## Consequences

- `03-ux-spec.md` §3 (tokens/components) is replaced by `10-ui-concept-a.md`; interaction rules in §4+ remain.
- M3 (timeline UI) is re-planned against the screen inventory in `10-ui-concept-a.md` §5; onboarding (O1–O6) becomes its own milestone before release.
- `lib/theme/` gains `DotTheme` and the `DotIcons` set; the placeholder Material shell is replaced.
- Golden tests are generated against the reference renders; the design-review sweep matrix gains every screen in §5.
- Concepts B, C and D are archived on the canvas and not referenced by code.
