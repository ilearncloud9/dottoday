# Open product decisions (from Prompt A)

Each decision is something the code or docs can't settle and a concept or fix depends on. Labels: *Fact* = from the audit (see `FEATURE_READINESS.md`); *Rec* = Claude's recommendation, not a decision. Nothing here is implemented, and nothing changes until the owner answers.

## Owner answers (2026-11-02)

| Q | Answer | What follows |
|---|---|---|
| Q1 | **Snooze stays reminder-only.** | PRD F6.4 is corrected in the docs PR (Q14). No code change |
| Q2 | **Keep overlap-on-add and the knot.** No bump on Add. | Bump-on-insert is dropped from the spec (`docs/04:120`) in the docs PR. `InsertPolicy` stays for drags |
| Q3 | **Concepts decide** the homes for Brain dump, Routines, Pick one thing, Low-energy, Duplicate/Copy day and This week. | No fixed rule. Each concept must still keep every feature reachable (parity matrix) and say where each one lives |
| Q4 | **Concepts may merge duplicates**, keeping every current entry point. | Parity matrix §7 is the checklist |
| Q5 | **Week wherever the width allows**, tablets included. | `docs/10 §3` is updated in the docs PR to match the code |
| Q6 | **iPad is iPhone-class** for alarms and Siri, with its own layouts from the shortlisted concepts. | D7 comment fix in the docs PR |
| Q7 | **Fix the stabilise-first defects on `main` first**, through PRs, then merge them here and log in `SYNC_LOG.md`. | Before Prompt F. Each fix needs your go-ahead |
| Q8 | **The dial may cross midnight; concepts aren't limited to ≤ 23:59.** | Building it needs a domain/settings change (`DayShape`, `docs/05`) with its own approval before Prompt F touches it |
| Q9 | **Propose the isolated Supabase test stack before Prompt F.** | Nothing is created until approved |

Q10–Q15 can wait (below).

## Needed before the UX concepts (Prompt C)

| Q | Decision | Fact | Options | Rec |
|---|---|---|---|---|
| Q1 | **Snooze shifts the following tasks?** | PRD F6.4 says yes. The code only re-reminds and its comment says that's intended (`notification_responder.dart:22`) | (a) keep snooze as reminder-only and update the PRD · (b) build "snooze shifts followers" later · (c) offer both as a choice at snooze time | (a). Shifting the day is already one gesture (Shift the rest, Running late); a notification action that silently moves the plan works against "in control" |
| Q2 | **Insert-bump when adding into a busy slot?** | Exists in the domain (`InsertPolicy`), but Add never bumps; overlaps are allowed by design (ADR-0015) | (a) keep overlap-on-add and the knot, and drop bump from the spec · (b) add bump as an opt-in setting | (a). It matches the overlap look you listed as must-keep |
| Q3 | **Primary homes for features now buried in Today ⋯** (Brain dump, Pick one thing, Low-energy, Routines, Duplicate/Copy day, This week) | *Fact:* 6 features are reachable only (or mainly) from ⋯ | This is decided per concept in Prompt C. The question is what constraint to give the concepts | Every concept must give **Brain dump and Routines a first-level entry** (no more than 1 tap from Today or Add). The rest may stay in an organised menu |
| Q4 | **Three forms of the day review, two Months, three test-alarm cards: consolidate?** | *Fact:* each pair or triple shares a body widget, so merging them is cheap | (a) the concepts may merge them freely · (b) keep them as they are | (a), with each merged screen keeping every current entry point (parity matrix §7) |
| Q5 | **Week view on tablets** | Docs: Mac/web only. Code: any expanded width, so large iPads and Android tablets get it | (a) Week wherever width allows (match the code, update the doc) · (b) Mac/web only | (a). It serves your tablet decision and parity |
| Q6 | **iPad as its own experience vs "a big iPhone"** | No tablet-specific code. iPad gets alarm-grade Wake Up, Siri page and missions like an iPhone; Live Activity probably doesn't apply | (a) treat iPad as iPhone-class for alarms and Siri, with its own layouts from the shortlisted concepts (Q7) · (b) tone down phone-only features on iPad | (a) |

## Needed before the first production slice (Prompt F)

| Q | Decision | Fact | Options | Rec |
|---|---|---|---|---|
| Q7 | **Fix the "stabilise first" defects on `main` now?** | Sync pull stall (confirmed by reading the code), dead Move tile, `/day` date mismatch, stale-ID taps; Android time-zone re-plan (inferred) | (a) fix them on `main` with PRs before Prompt F, then merge into this branch · (b) fix them inside the redesign branch · (c) defer | (a). The sync stall can silently lose changes for current testers, and all of these sit under screens the redesign rebuilds |
| Q8 | **Circular Wake Up dial crossing midnight** | Model can't express a Wind Down after midnight (`DayShape.on`, `docs/05`) | (a) dial limited to the current model (Wind Down ≤ 23:59) · (b) extend the domain to allow after-midnight Wind Down (schema/settings change → separate approval) | (a) for the concepts, dial shold not be limited. (b) separately if you want night owls supported |
| Q9 | **Isolated local Supabase for integration tests** | Only one local stack, shared with the original worktree; tests leave users behind; env vars could point tests at the hosted project | Proposal to follow (open item in `STATUS.md`). Nothing is created until approved | Ask for the proposal before Prompt F |

## Can wait (not needed for concepts or the first slice)

| Q | Decision | Fact | Rec |
|---|---|---|---|
| Q10 | **Signing into a second account uploads the first account's local data** | `account_adoption.dart` `requeueAll` | Decide before public release; out of the redesign's scope |
| Q11 | **Web push delivery** | The cron job is gitignored and not in the repo | Owner setup step; document it when web goes public |
| Q12 | **Cloud AI backend** | Interface stub only; off by flag | Stays off (privacy rules, decision 11). Concepts show on-device only |
| Q13 | **Calendar change webhooks** | Not built; needs hosted project and provider consoles | Unchanged owner gate |
| Q14 | **Doc fixes D1–D7** (Wake Up status, two ADR-0015s, Week scope, minimal row count, snooze, duplicate `maxAlerts`, iPad Siri) | `FEATURE_READINESS.md` § Documentation inconsistencies | Fix in one docs PR on `main` once Q1, Q5 and Q6 are answered |
| Q15 | **Phase 2 ideas** | Future only (decision 11) | Concepts may leave unlabelled space at most; no Phase 2 UI |
