# ADR-0016 · Minimal layout is a View-layer flag read through one LayoutPolicy

Status: Accepted · Date: 2026-10-30 · Spec docs/14-minimal-mode.md · Built in M16 · Amends
docs/10 §3 (`LaterRow`, `BackToToday`), CLAUDE.md §11 (every feature declares its §3 row)

## Context
By M15 Dottoday ships the thread plus widgets, Focus, routines, the reality thread, energy
learning, reviews, a journal, Brain dump, dictation and a sound library. The owner's research
(docs/14 §1) says ADHD users leave planners that ask for decisions before they give anything. They
want a second presentation of the same app: the thread, the next dot, Add and Done. The other
features stay one tap away, and nothing is lost by switching. The risks are a second app growing
inside the first (forked widgets, forked data), and `if (minimal)` spreading into repositories, sync
and notifications, where a flip could change what gets stored or what rings.

## Decision
- **One flag, in the synced settings.** `Settings.uiLayout` is `minimal | full`. A missing key
  reads as `full`. Schema 9 and Supabase `0010` write `"full"` into every existing profile, so an
  upgrade changes no one's app. A new install starts minimal: Get started preselects it, and
  onboarding step 0 shows it chosen.
- **One policy, mirroring the doc.** `FeatureId` has one value per docs/14 §3 row, carrying that
  row's Feature cell verbatim. `LayoutPolicy.visibility(id)` returns `shown` for everything in full,
  and in minimal the §3 state (`shown | simplified | hidden | off`). A policy test parses §3 and fails
  on any difference, so the matrix and the code cannot drift.
- **Views ask the policy, never the flag.** Views call `watchFeature` / `watchOnScreen` /
  `watchSimplified`, which are `ref.watch(layoutPolicyProvider.select(...))`, so a flip rebuilds only
  what changes. A boundary test fails if anything outside the entity, the schema-9 migration and the
  policy's three folders names `uiLayout`.
- **Hidden is View-only; Off goes through the feature's own switch.** Alarms, timestamps, learning,
  Smallest step and the snapshot run untouched in every state. The only `off` row (C4 energy
  suggestions) is passed into the feature's existing check by the View
  (`energySuggestions: false` in Add), and the stored choice is never written.
- **Subtraction, not new screens.** Minimal Today, Add, the task sheet, Settings and onboarding step
  0 are the Concept A widgets with parts removed. The only new components are two small rows:
  - `LaterRow`: the Inbox as one quiet row at the end of the thread, which also takes a dragged task.
  - `BackToToday`: "‹ Today" on pages reached from Today when there is no tab bar.
  Several lines typed into minimal Add go to Brain dump's `ProposalSheet` through a pending request,
  as routines do. Nothing is written before Accept.
- **Hints are data plus a pure scheduler.** `reveal_hints` is a synced entity with one row per user
  and hint (a UUID v5 id). It is UNIQUE per user and hint, its hint id must be one of the six, and its
  count is at most 2. RLS is in the same migration. `pickHint` is pure over the signals, the
  records, the injected Clock's now and the profile zone. It shows one hint per local day, each at
  most twice. Not now retires a hint forever. No hint shows in Focus, after Wind Down or in
  low-energy mode. The row is the existing `StatusHint`.
- **Where it lives.** docs/14 §6 named `features/layout/`. CLAUDE.md §3 forbids
  feature-to-feature imports, and on engineering questions CLAUDE.md wins. So:
  - `FeatureId` and `LayoutPolicy` are in `domain/layout/` (pure Dart);
  - the providers and `watchFeature` are in `data/layout/`;
  - the switch's write-and-report is in `shared/layout/layout_switch.dart`;
  - `BackToToday` is in `shared/navigation/`.

## Consequences
- Switching is one settings write, with no confirmation (docs/14 §5). A property test proves
  full → minimal → full leaves every table byte-identical for 25 seeded databases. Only the
  profile's write stamps and one outbox entry (profiles, settings) move.
- Every new feature spec declares its §3 row before it is built, and adds its `FeatureId`. The policy
  test enforces it, and CLAUDE.md §11 says so.
- `reveal_hints` is not in export or backups. Like `field_seen`, it is UI bookkeeping, and docs/14 §6
  keeps the export format unchanged.
- The widget hint (Live Activity dismissed → Next-up widget) has its trigger, but the app has no OS
  signal for a user dismissing a Live Activity yet. It cannot fire until one is added (M16
  follow-up; it touches the native extension, a must-ask).
- Two screen-reader gaps surfaced by the tappable-set sweep (Today's date title, the new Later row)
  and two 200 % text breaks (Settings rows, the minimal sheet's tiles) were fixed in the same
  milestone.
- Rejected:
  - A per-device layout (the owner chose one layout per account).
  - Separate minimal widgets (a parallel component set, CLAUDE.md §11).
  - Branching in repositories or the notification planner (a flip could change what rings).
  - Keeping the policy in `features/layout/` with a boundary exception (it would loosen the check
    rather than fix the code).
