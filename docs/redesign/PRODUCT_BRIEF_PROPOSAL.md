# Product Brief — proposal for owner review

**Status:** proposal, not the brief. The playbook (Step 4) says the owner writes `PRODUCT_BRIEF.md`. This file pre-fills each template field with what the project docs already state, so you can confirm, edit or overrule it. Nothing here is invented.

**How to read it**
- **Docs say:** quoted or summarised from a repo doc, with the path. It shows the doc's intent, not proven code behaviour; Prompt A checks the code.
- **OWNER:** a decision only you can make. Where I offer options, they come from the docs or the playbook, not new features.
- Two prompts below (*Things I like about Structured*, *Ideas I'm unsure about*) have nothing in the docs to pre-fill, and I left them blank on purpose.

---

## 0. Two facts that change how the playbook applies

1. **The app is further along than the playbook assumes.** `docs/09-implementation-plan.md` has milestones M0–M17 almost all ticked. The open items are device checks, native-speaker passes, missing renders, ~90 icons, and owner-gated work (cloud calendar webhooks, store accounts). See § Known incomplete. The playbook's "feature-incomplete" framing mostly means *unverified on devices* and *open product decisions*, not missing code. Prompt A should confirm this from the code.
2. **The visual system is the product's own language.** `docs/10-ui-concept-a.md` §1: a day is a *thread* from Wake Up to Wind Down, every task is a *dot*, and the app icon, Today tab icon and day header all reuse the dot. The app name is *Dottoday*. Making the dot optional under the redesign (decision 2) is a **brand** decision, not only a UI one. See § Branding.

---

## 1. Product / working name
**Docs say:** Dottoday. Identifiers are final as of 2026-10-25: `app.dottoday.planner`, scheme `dottoday://`, domain `dottoday.app` (`docs/release-beta.md` §0). Version `1.2.0+4` (`app/pubspec.yaml`).
**OWNER:** keep the name for the redesign? (Identifiers stay unchanged in any case, per decision 6.)

## 2. Who it is for
**Docs say** (`docs/00-vision.md`):
- People who think in time blocks: students, freelancers, parents, shift workers.
- People with executive-function challenges who need "what's next" at a glance. Minimal mode names ADHD users directly (`docs/14-minimal-mode.md` §1).
- Multi-device users: phone, Mac at the desk, web at work.

**OWNER:** is this still the audience, and which group is *primary* for the redesign? The three concepts serve them differently: Focus-First suits executive-function users, Workspace suits desk users.

## 3. The three most important user jobs
**Docs suggest** (from the vision principles and v1 success criteria):
1. See what's next and follow the day as a timeline ("The timeline is the product").
2. Capture a task instantly: ≤ 2 taps plus typing, natural-language time, paste a list (R-06, R-07).
3. Replan cheaply when the day slips: shift the rest of the day in one gesture (R-04, R-05).

**OWNER:** confirm, reorder or replace. This choice drives the concept comparison more than any other.

## 4. What users should feel (3–5 words)
**Docs say:** "Calm UI… The app suggests, never scolds" (`00-vision.md` §8). No-shame rule: no streaks, no red for incomplete, no "late/missed/failed" (`CLAUDE.md` §11). Minimal mode: "No number that judges" (`14` §2).
**OWNER:** pick the words. The docs point to something like *calm, unjudged, in control*, but that's my reading, not a decision.

## 5. What the current app does well
**OWNER.** The docs only list what users love about *Structured* (`01-research-complaints.md` § Things users love), not about Dottoday. The baseline screenshots (Step 3) should come first so this answer is based on how the app looks today.

## 6. What feels unpolished or frustrating
**OWNER.** No doc records owner frustration with the current UI. The playbook's reason for redesigning has to come from you.

## 7. Things I like about Structured (principles, not copies)
**OWNER.** Intentionally blank. Context only: the research lists what users praise there (timeline filling as the day passes, colour + icon per block, inbox, subtasks, widgets, wake/sleep boundaries). The playbook forbids copying its assets.

## 8. Things I do NOT want the app to feel like
**Docs say:**
- Not a project manager, kanban or tag hierarchy (v1 non-goals).
- Not shaming: no streaks or red.
- Not a hub for other tools: "Keep the Inbox the door; never become a hub" (`11-standout-roadmap.md` F2).
- Not a lite tier: minimal mode is "not a beginner mode that nags you to upgrade".

**OWNER:** add your own. Concept B (Productivity Workspace) pulls toward the "project tool" non-goal, so say how far it may go.

## 9. Absolute must-keep features
**Docs say:** the non-negotiables (`CLAUDE.md` §8):
- Recurrence, calendar import, custom notifications and export are free (R-01–R-03, R-11).
- Drag to move, long-press multi-select, *shift everything after this* in one gesture (R-04, R-05). Resize happens in the task sheet, not by dragging edges (ADR-0015).
- Quick add in ≤ 2 taps, natural-language time, paste a list (R-06, R-07).
- Visible, conflict-safe sync; local backups; export (R-08, R-11).
- Occurrence-scoped subtask completion (R-09).
- Notifications fire exactly once, with lead time and multiple alerts (R-10).
- Screen-reader semantics tested in CI (R-12).
- Same features on all platforms in the same release (R-13).

Also adopted and built: minimal mode as a standing view choice (ADR-0016), the proposal rule (nothing generated is written before Accept), and AI that runs on the device first.
**OWNER:** confirm all of these carry into the redesign unchanged. The parity rule (R-13) now covers six experiences, not four.

## 10. Known incomplete features
**Docs say** (open `- [ ]` items in `docs/09-implementation-plan.md`, not yet code-verified):
- Physical mid-range Android perf run (M5.9b, deferred to M8.5 QA).
- Sounds (M15): app-size measurement, native-speaker pass, device ear check.
- Minimal mode (M16): native-speaker pass, three missing Set C renders, real-device cold-install timing.
- Wake Up (M17): real-device alarm gates (iOS force-quit/Silent, Android Doze). Doc 15 status is "proposed (needs ADR-0017)", but ADR-0017 exists — Prompt A should reconcile this.
- Task icon library: ~90 names still undrawn.
- Event-driven sync: Google/Microsoft calendar webhooks, waiting on owner access to the hosted project and provider consoles.
- Store and beta release: every OWNER step in `docs/release-beta.md` (developer accounts, signing, uploads).

**OWNER:** has any build reached real users (TestFlight, Play internal, public web)? That decides how careful the redesign must be about upgrades and existing data.

## 11. Features planned with confidence
**Docs say:** v1 plus the standout roadmap (M6.5–M17) are planned *and marked built*. Nothing new is committed beyond the open items above.
**OWNER:** anything you're *sure* you'll build next that the redesign must leave room for? The playbook asks for these before concepts, because they can change navigation.

## 12. Ideas I am still unsure about
**Docs say:** Phase 2 is "ideas, not committed — the owner decides later" (`02-prd.md` § Beyond v1): Windows/Linux, integrations (Reminders, Google Tasks, Todoist, Notion), body double, wallpaper/watch face, Apple Watch app, paper plan, shared/household threads. Also the **free/Pro split is a draft awaiting your review**; `isPro` is true in all builds and there's no paywall (`11` § Free/Pro split).
**OWNER:** which of these (if any) the concepts should leave a slot for, and whether pricing is in scope for the redesign at all.

## 13. Core workflows that must become effortless
**Docs suggest** (the success criteria in `00-vision.md`):
- Plan tomorrow in < 90 s during onboarding.
- Inbox → timeline in ≤ 2 taps.
- Shift the rest of the day in one gesture.
- Minimal mode: app open → saved task in two taps.

The playbook's vertical slice is Today → Add → Edit/reschedule → Complete → Change day → Reopen.
**OWNER:** confirm this list, or name the workflow that feels hardest today.

## 14. Navigation changes I would consider
**Docs say** (current, `10-ui-concept-a.md` §3–4):
- Today · Inbox · [Week, Mac/web only] · Search · Settings, plus Add.
- Pill tab bar on iPhone, Material NavigationBar on Android, rail at medium and expanded widths.
- At expanded width: a 300 px Inbox sidebar and a three-day spread.

Minimal mode replaces tabs with *‹ Today* back links.
**OWNER:** which of these are open to change: tab set and order, Week as a tab, Inbox as a tab vs a sidebar, Search's place, minimal mode's shell? Concept B and C may need to move them.

## 15. Branding: retain, refresh or rename
**Docs say:**
- Icon = the day dot on its thread, white on indigo `#3B6CF6`, derived without a reference render; "the owner may replace the design" (`docs/store/README.md`).
- Four user-selectable accents, nine task colours, Inter bundled.
- Store listings exist in en/de/fr/es.

**OWNER:**
- Keep the dot/thread as the brand mark even if a concept moves away from the thread UI, or refresh both together?
- Is the name open to change? (The playbook defers renaming to Step 15.)

## 16. Apple-native details I care most about
**Docs say** (built, per plan):
- iPhone: Live Activity / Dynamic Island, widgets, Control Center and Action button controls, five App Intents, Siri & Shortcuts listing, AlarmKit for Wake Up.
- macOS: menu-bar "next up".

**OWNER:** which native *interactions* matter most in the redesign (sheets, context menus, haptics, Mac menus and shortcuts, iPad multitasking/Stage Manager)?

## 17. Android behaviour I care most about
**Docs say:** Material 3 NavigationBar, ongoing notification for the live dot, widgets, exact alarms and full-screen alarm for Wake Up; no Material You wallpaper accent (`02-prd.md` F8.3, for R-13 parity).
**OWNER:** keep the no-Material-You stance? Which tablet behaviours matter (split screen, keyboard and pointer)?

## 18. Web behaviour I care most about
**Docs say:** web = the Mac layout at expanded width and the Android layout at compact width (`10` §4). Safari iOS PWA is on the device list (`08` §3).
**OWNER:** how important are deep links, Back/Forward, refresh state and PWA install for the redesign?

## 19. Platforms I personally use and test most
**OWNER.** Context: your decision 1 adds iPad and Android tablets as full experiences. The QA device list has iPad only as "(compat)" and no Android tablet (`08-testing-qa.md` §3). `TARGETED_DEVICE_FAMILY = "1,2"`, so iPad is enabled in the build.

## 20. Accessibility expectations
**Docs say:**
- Semantics labels, 44 pt targets (48 on Android), Dynamic Type to 200 %, reduced motion, keyboard operable (`CLAUDE.md` §5).
- Platform audits: Accessibility Inspector, Android Accessibility Scanner, axe (`00-vision.md`).
- Semantics tests in CI (R-12).

**OWNER:** keep these as the floor? Add anything (for example a WCAG level target)?

## 21. Non-negotiable privacy / security constraints
**Docs say** (`06-security.md`, `CLAUDE.md` §11):
- Titles and notes are sensitive and never logged.
- Local DB encrypted (SQLCipher).
- RLS on every table; the client uses the anon key only.
- Notification bodies carry title and time only.
- AI on-device first. A cloud model, or anything that sends task text off-device, is a must-ask.
- Feedback is a `mailto:` the user sends; the app sends nothing itself.

**OWNER:** confirm these stand. The redesign shouldn't introduce analytics, cloud AI or design fixtures built from real data.

---

## Decisions needed from you, in order of impact

1. **Primary audience and the top three jobs** (§2–3). This frames all three concepts.
2. **Is the dot/thread the brand or just the current UI?** (§15, §0.2)
3. **Has any build reached real users?** (§10). This sets how careful upgrades must be.
4. **Navigation elements that may move** (§14).
5. **Feelings, what works today, what frustrates you, and Structured principles** (§4–7). Only you can answer these, ideally after the Step 3 screenshots.
6. **Phase 2 ideas and pricing:** slot for them, or out of scope (§11–12).
7. **Platform priorities and tablet depth** (§16–19).

Recommended order: answer 1–4 now, do Step 3 screenshots, then answer 5–7 with the screenshots in front of you, then write `PRODUCT_BRIEF.md`.
