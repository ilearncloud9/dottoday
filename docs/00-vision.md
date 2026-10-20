# 00 — Vision

## One sentence

A calm, visual day planner that turns a to-do list into a timeline you can actually follow — and that
gets out of the way when the day doesn't go to plan.

## Who it is for

- People who think in time blocks: students, freelancers, parents, shift workers.
- People with executive-function challenges who need "what's next" at a glance, not a backlog.
- Multi-device users: phone in the pocket, Mac on the desk, web at work.

## Product principles (decide ties with these)

1. **The timeline is the product.** Everything else (inbox, settings, calendar import) feeds it.
2. **Replanning must be one gesture.** Plans change; the app's job is to make changing them cheap. (R-04, R-05)
3. **Capture is instant.** If adding a task takes more than a few seconds, it won't be added. (R-06, R-07)
4. **Never lose data, never hide sync.** Local-first, visible sync state, export always available. (R-08, R-11)
5. **Core is free.** Recurrence, calendar import, notifications and sync are table stakes, not upsells. (R-01–R-03)
6. **Same app everywhere.** No "lite" Android or web. (R-13)
7. **Accessible by default.** Screen readers, big text, reduced motion, keyboard. (R-12)
8. **Calm UI.** Few colors, generous whitespace, no nagging. The app suggests, never scolds.

## Non-goals (v1)

- Team collaboration / shared schedules (v2 candidate).
- Project management, kanban, tags hierarchy (v2: lightweight tags only).
- AI planning (phase 2, spec'd separately after core ships).
- Habit streaks and analytics (phase 2).
- Monetization (phase 2; a Pro tier may add themes, icon packs, AI, analytics — never core features).

## Success criteria for v1

- A new user plans tomorrow in under 90 seconds in onboarding.
- Adding a task from the inbox to the timeline is ≤ 2 taps.
- "Shift the rest of my day" is one gesture.
- Zero data-loss bugs in beta; sync conflicts resolved without user intervention in 99% of cases.
- Passes platform accessibility audits (Xcode Accessibility Inspector, Android Accessibility Scanner, axe for web).
- Identical feature checklist on iOS, Android, macOS, Web at release.
