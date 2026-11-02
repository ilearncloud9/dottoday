# Product Brief — Dottoday redesign

**Status: APPROVED by the owner (2026-11-02).** Labels: *Owner* = your words or decision; *Fact* = from repo docs or your screenshots (doc intent, not verified code; Prompt A verifies); *Rec* = Claude's recommendation, not accepted until you say so. Background: `PRODUCT_BRIEF_PROPOSAL.md`. Decisions log: `STATUS.md`.

---

## 1. Name
*Owner:* **Dottoday** stays. No rename in this redesign. App identifiers (`app.dottoday.planner`, `dottoday://`, `dottoday.app`) do not change.

## 2. Who it is for
*Owner:* all three groups, none ranked above the others:
- People who plan in time blocks: students, freelancers, parents, shift workers.
- People with executive-function challenges, such as ADHD, who need to see "what's next" at a glance rather than a backlog.
- People who use several devices: a phone in the pocket, a Mac on the desk, the web at work.

## 3. The three most important jobs
*Owner:*
1. **See the day as a timeline and know what's next.** "The timeline is the product."
2. **Replan in one gesture:** Shift the rest, Running late, drag.
3. **Capture instantly:** quick add with natural-language times, paste a list, Brain dump, or speak a brain dump and let the app plan it.
4. Wake up and alarm to drag you out of the bed, to start or plan your day.

Core journey for the first production slice (playbook): Today → Add → Edit/reschedule → Complete → Change day → Reopen. Measured against `00-vision.md`: Inbox → timeline in ≤ 2 taps, shift the rest in one gesture, plan tomorrow in < 90 s.

## 4. What users should feel
*Owner* (Q3):

| Feeling | Meaning |
|---|---|
| **Calm** | Feel at ease, not overwhelmed |
| **Unjudged** | Never feel shamed, criticised or inadequate |
| **Supported** | Feel encouraged, even when they struggle or fall behind |
| **Capable** | Believe they can make progress |
| **In control** | Feel empowered, never pressured |
| **Focused** | Know what matters and what to do next |

Every concept is judged against all six.

## 5. What the current app does well
*Owner:* Brain dump and Routines are great features (but hidden, see §6). Wake Up alarms are a good idea that needs better form.
*Fact* (`01-research-complaints.md`): the research behind the app values a timeline that fills as the day passes, colour + icon per block, an Inbox, subtasks, widgets, and wake/sleep boundaries.

## 6. What feels unpolished or frustrating
*Owner*, with your screenshots in `references/baseline/owner-ios-2026-11-02/`:

| # | Problem | Evidence |
|---|---|---|
| P1 | **Settings is busy and unorganised.** Too many settings scattered around | `01`, `02` (Day Shape alone has ~10 rows; Planning continues below) |
| P2 | **The iOS app doesn't feel like an iOS app.** No Liquid Glass or material effects; buttons and controls look basic | `01`–`04` |
| P3 | **Strong features are buried in the Today ⋯ menu.** Brain dump, Routines etc. should be handy; the menu holds too many unrelated functions | `03` (10 items: Show less, Running late, Review the day, Brain dump, Pick today's one thing, Low-energy mode, This week, Duplicate day, Copy day as text, Routines) |
| P4 | **Screens are duplicated** where some could be combined | Owner observation; Prompt B maps where |
| P5 | **Wake Up / Wind Down time picking:** wants a circular dial you turn to set the time, instead of the linear slider | `01` (Day Shape slider) |
| P6 | **Visuals look basic overall** | `01`–`05` |
| P7 | **Motion is missing where it matters.** The Wake Up missions (e.g. "Catch the dot") lack motion and graphic quality and don't use the screen well; text and image layout feels basic | `05` |

*Fact* (visible in the screenshots, for Prompt B to check):
- In `03` the ⋯ menu covers the date header and clips it.
- In `04` the header shows "2 of 3 · 17 h 20 planned", and a task before Wake Up shows as "2 tasks before Wake Up".

## 7. What I want instead (design goals)
*Owner:*
- **Well-organised screens** where every feature stays clear and reachable (fixes P1, P3, P4).
- **Native look on every OS**, yet **consistent** as one Dottoday (fixes P2).
- **Richer graphics and purposeful motion**, every neccessary place e.g in Wake Up missions, which should fill the screen (fixes P6, P7).
- **A circular time dial** for Wake Up / Wind Down, to be explored in the concepts (fixes P5).

*Rec:* treat the four goals as acceptance criteria every concept is scored against in Step 8.

## 8. Structured principles I like
*Owner:* none stated beyond the jobs above. *Rec:* leave it at that. The playbook forbids copying Structured; §3's jobs already capture the principle (a clear, quick daily timeline).

## 9. Must not feel like
*Fact:*
- Not a project manager / kanban / tag hierarchy (v1 non-goals).
- Not shaming: no streaks, no red, no "late/missed/failed".
- Not a hub for other tools.
- Not a lite tier that nags.

*Owner* (from §6): not busy, not generic or "basic", not a phone UI stretched onto other platforms.

*Owner* (Q6): Concept B **rearranges existing features only** and adds no project or tag features. It **may sketch** project-style grouping as a clearly labelled future possibility, which is not built and not part of parity (decision 11).

## 10. Must-keep features
*Fact* (`CLAUDE.md` §8): free recurrence,the overlaping task look, calendar import, custom notifications and export; drag to move, multi-select, shift the rest; quick add in ≤ 2 taps with natural language and paste-a-list; visible conflict-safe sync, backups and export; occurrence-scoped subtasks; notifications exactly once with lead time and multiple alerts; screen-reader tests in CI; same features on every platform.
Also built: minimal mode as a standing choice, the proposal rule (nothing generated is written before Accept), AI on the device first.

*Owner:* every existing feature stays reachable. The interface around it may change completely.

## 11. Known incomplete features
*Owner:* ticked plan checkboxes are not proof. Prompt A classifies each feature from the code as completed, partially implemented, unverified or planned.
*Fact:* open plan items are in `PRODUCT_BRIEF_PROPOSAL.md` §10. The Wake Up doc/ADR mismatch is logged for Prompt A.

## 12. Release state
*Owner:* **internal testers only.**
*Rec:* treat upgrades as real anyway. Testers have data, so the redesign must not change the local schema or identifiers, and it must keep their settings.

## 13. Planned features, unsure ideas, pricing
*Owner:*
- Nothing new is committed.
- Phase 2 ideas are future possibilities unless approved.
- Free/Pro logic and pricing don't change without separate approval.

## 14. Navigation and layout
*Owner:* everything is open — tabs, menus, Settings placement, task editing, screen arrangement. Existing structure is not kept just because it's built.

## 15. Brand per concept
*Owner:* the name stays Dottoday in all three.
- **Concept A, Refined Timeline:** keep and refine the dot/thread.
- **Concept B, Productivity Workspace:** may evolve the identity substantially.
- **Concept C, Focus-First Planner:** may explore a completely different identity.

## 16. Platforms and conventions
*Owner:* iPhone, iPad, Mac, Android phones, Android tablets, web. One brand, each platform's own conventions:
- **Apple:** native sheets, context menus, haptics, Mac menu bar and keyboard shortcuts, iPad pointer and keyboard, and the current iOS material/glass look (P2).
- **Android:** system back, edge-to-edge insets, tablet split-screen.
- **Web:** working deep links, Back/Forward, refresh keeps state.
- **Accent:** keep the "no Material You wallpaper accent" rule (parity, no new dependency).

*Owner* (Q7): all three concepts cover iPhone, Mac, Android phone and web. Only the shortlisted concepts get full iPad and Android-tablet layouts (portrait, landscape, split screen). Your own test devices are not stated yet; the baseline so far is iPhone, from your screenshots.

## 17. Accessibility and privacy
*Fact:*
- Accessibility: 44 pt targets (48 Android), Dynamic Type to 200 %, reduced motion, keyboard operable, semantics tests in CI.
- Privacy: titles and notes never logged; encrypted local DB; RLS everywhere; anon key only; notifications carry title and time only; on-device AI first; cloud AI is must-ask.

*Owner* (Q10): keep both as above, and add **WCAG 2.2 AA contrast** as a target, checked against glass and translucent surfaces as they actually render. Richer motion (§7) still collapses under reduced motion.
