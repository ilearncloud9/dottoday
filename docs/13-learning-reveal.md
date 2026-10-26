# 13 · Learning reveal: "it learns how long things really take you"

Status: **adopted** (owner, 2026-10-26; ADR-0012 for the one storage change). This document extends `11-standout-roadmap.md` §B1, §C3 and §C4 and `10-ui-concept-a.md`; it does not replace them. It is a retrofit: the learning built in M11.3 and M11.5 stays, and this document decides **when** a learned value shows, **how** it arrives and **how** it explains itself. Every screen here is built with the Concept A components (§3 of doc 10) and meets doc 10 §7.

Tags: **built** = exists on main; **changed** = built, and this document changes it; **new** = this document adds it.

---

## 1. Principle

- **A promise from day one.** Learning is visible before it has anything to say: Settings › Learning names each feature and how far along it is, and Today's card says the reality thread is coming. Nothing else shows a learned value until it has one.
- **Soft reveal, in place.** A learned value appears where it is used (the Add chip, the ThreadPicker caption, the day card header, a Focus timer). There is no modal, no popup, no badge, no "new" sheet and no notification. The one exception is a single ~2 s accent tint the first time the Plan / Reality toggle appears.
- **Explainable on demand.** Tapping any learned value opens one inline line: how many times it came from and how it was worked out, plus "Reset for this task on this device".
- **Per task, so gradual.** Durations, start offsets and step lengths reveal **per task title** (per step). A user with ten tasks sees them one at a time as each one crosses its threshold, never all at once. This is intended: each reveal is small enough to go unnoticed until it helps.
- **No shame.** Learned copy says "usually", "after plan", "finished". Never "late", "missed", "failed", "behind", "overdue", and never error red (11 §D, `no_shame_copy_test.dart`).
- **Independent of marketing.** Release announcements for data features are marketing and happen outside the app (§10). The in-app reveal depends only on each user's own data and never waits for, or links to, an announcement.

## 2. Thresholds: one `LearningThresholds` value

**changed.** Every learning number found by the M13 audit moves into one immutable value object, `domain/scheduling/learning_thresholds.dart`, injected through `learningThresholdsProvider` (keepAlive, `data/scheduling/learning_providers.dart`; tests override it). No widget and no domain function keeps a literal. Domain functions take the value as a parameter; widgets read it from the provider.

| Field | Value | Was | Meaning |
|---|---|---|---|
| `taskMinSamples` | **4** | `learningMinSamples` 3, `ThinkingService.trustedSamples` 3 | Finished runs of a title (or its series) with a real actual start and end before its usual length and start offset show. |
| `window` | 10 | `learningWindow` | Most recent runs a median is taken over, per task and per step. |
| `historyDays` | 90 | `learningHistoryDays` | How far back the history stream reads. |
| `realityMinRuns` | **10** (new) | none (the toggle showed on the first day with any actual) | Finished tasks app-wide with an actual start **and** end before the Plan / Reality toggle appears. |
| `stepMinSamples` | **3** (new) | none (not built) | Finished runs of a step (§5) before a Focus timer uses its usual length. |
| `energyMinCompletions` | 20 | same | Finished high-energy tasks with real times before the energy switch can be turned on. |
| `energyWindowHours` | 2 | same | Length of the suggested energy window. |
| `insightFromMinutes` | 15 | same | The Reality insight strip shows only when the usual length is at least this far from the plan. |
| `tendencyFromMinutes` | 5 | `_tendencyFrom` | The ThreadPicker start-offset caption shows only from this many minutes either way. |

`LearningThresholds.standard` is the shipped value. Changing a number is a one-line change in that file plus its tests.

**One derivation.** `LearningIndex` is the only place a learned duration is computed. `LocalThinkingMemory.pastLengths` and `medianLength` (which mixed planned lengths into the median and needed only one sample) are deleted. `RulesThinkingBackend.suggestDuration` and `ThinkingService.suggestDuration` read `LearningIndex.forTask` and treat `usualMinutes == null` as "no history". The `ThinkingMemory` interface loses `pastLengths`.

**What counts as a run.** This is unchanged from M11.3 for tasks: an occurrence not deleted, with `actualStartUtc` and `actualEndUtc`, the end after the start, 1–1440 min, never inferred (B1). The app-wide reality count (`realityMinRuns`) and energy count also require `status == done`.

## 3. The four features

| Feature | Before threshold | At threshold | Explained by |
|---|---|---|---|
| **Reality thread** (11 §C3) | Today's card header shows the learning caption (§4.2). No toggle. | The Plan / Reality toggle appears in today's header on a day that has an actual (as built), with the one-time highlight (§4.3). Nothing else changes. | Settings › Learning row. |
| **Task length and start offset** (11 §C3) | Add shows no usual line and pre-selects nothing learned. ThreadPicker shows no tendency caption. Reality's live row, its insight strip and the Running late sheet show no "usually". There are no placeholders. | **Add:** the duration chip pre-selects the usual length (after an explicit or typed length, as built) with "usually 2 h 20" under the chips. **ThreadPicker:** "usually starts ~15 min after plan" (or "before"), from `tendencyFromMinutes`. **Running late:** the default amount and its reason. **Reality:** the live-row "usually" and the insight strip. | Inline explanation (§6). |
| **Step lengths** (11 §B1, new) | The Focus step timer uses the step's own `durationMin`, or shows no countdown without one (as built). | A step with no `durationMin` of its own counts down from its usual length, and the step card shows "usually 15 min". "My usual breakdown" offers the saved steps with their usual lengths in place of the saved minutes, still as a proposal (B3: edited, then Accept). A length the user set on the step always wins. | Inline explanation on the step card (§6). |
| **Energy suggestions** (11 §C4) | The switch is off and **locked**: "After 20 finished high-energy tasks · 7 so far". Add shows nothing. | The switch becomes **enabled, still off**, with "ready — based on 20 completed tasks". Suggestions appear in Add only after the user turns it on (that writes `energySuggestions: true`). | Settings caption, and the inline explanation on Add's energy line (§6). |

**Energy default change.** **changed.** A stored `null` for `Settings.energySuggestions` now means **off**. `energySuggestionsOn` becomes `completions >= energyMinCompletions && settings.energySuggestions == true`. Users already past 20 with `null` lose suggestions **once**, the next time they open Add, and see the "ready" caption in Settings. Users who explicitly chose `true` or `false` keep their choice. There is no data migration and no change to `validate_settings`.

## 4. Before threshold: the promise

### 4.1 Settings › Learning

**new.** A `SettingsGroup` captioned **LEARNING**, directly under PLANNING on the Settings page. The Energy suggestions row moves from PLANNING into it, so the switch and its status live in one place. That gives four rows and a footer:

| Row | Glyph / tint | Subtitle before | Indicator | Subtitle after |
|---|---|---|---|---|
| Reality thread | `DotGlyphs.dottedLine` / accent ink | "Dottoday is learning how your days really go. Your reality thread appears after about 10 finished tasks." | ring + 7/10 under the text | "Ready · Plan / Reality is in Today's header" |
| Task lengths | `DotGlyphs.clock` / accent ink | "Dottoday is learning how long your tasks really take. Each task shows its usual length after about 4 finished times." | value: "Ready for 3 tasks" (none at 0) | same subtitle, value keeps counting |
| Step lengths | `DotGlyphs.timer` / mint ink | "Dottoday is learning how long each step takes. A step's timer uses its usual length after about 3 finished times." | value: "Ready for 2 steps" (none at 0) | same |
| Energy suggestions | `DotGlyphs.bolt` / amber ink (as built) | "After 20 finished high-energy tasks · 7 so far" (locked switch) | ring + 7/20 under the text | "ready — based on 20 completed tasks" (enabled, off). Once on: the built `settingsEnergyDetail` |

Footer (the group's caption-style note, muted 12/500): **"Learning happens on your device. Your actual start and end times sync with your account like the rest of your plan; the learned numbers themselves are never uploaded."** This is accurate for the current sync design: `actual_start_utc`/`actual_end_utc` (0004) and `subtasks.done_at` (0008, ADR-0012) are synced columns; every learned value is derived on read from the local database, and resets and reveal state live in `local_meta`, which is never synced or exported.

**Indicator.** `CapacityRing` (doc 10 §3) gains a named constructor `CapacityRing.count(done:, of:, label:)`: the same 38 px conic ring, filled `done / of`, with nothing inside. There is no new component. The ring and its "7/10" sit **under** the row's subtitle (`LearningStatus`), not inside the ring or at the row's end (amended in M13.5: at 200 % text "10/10" overflows 38 px, and a value beside the title squeezed it until words broke). The per-task rows show "Ready for 3 tasks" there instead of a fraction because there is no single "of" for features that reveal per task.

The data comes from one provider, `learningProgressProvider`, derived from the existing 90-day `learningHistoryProvider` plus `LearningMeta` (§8). It returns `({int realityRuns, int tasksReady, int stepsReady, int energyCompletions, bool realityRevealed})`. It is not a second stats mechanism: it reads the same stream and `LearningIndex`.

### 4.2 Day card header caption (Reality thread only)

**new.** Under today's `DayCard` header, while the reality thread is not yet revealed (§4.3): one muted line, **"Your reality thread appears after about 10 finished tasks · 7 so far"**, with a trailing × (44 px target, Semantics button "Hide until tomorrow").

- It shows on **today's** card only: the phone `DayPager` and the Mac/web spread's today card.
- It shows at most once per day. × stores the local date in `local_meta` (`learning_caption_day`, same shape as `InboxNudgeSeen`), and the caption returns the next day until the threshold is crossed. It is never shown again after the reveal.
- It is hidden in low-energy mode (11 §D2 hides counts) and in minimal mode (§9).
- The Add chip, ThreadPicker, Focus and energy line have **no** before-threshold caption.

`DismissedInsights` (the insight strip's OK) stays session-scoped. It dismisses one occurrence's strip, not a promise, so the two are not unified.

### 4.3 At threshold: the toggle reveal

- **Gate.** **changed.** `offerReality = isToday && side == null && hasActuals(blocks) && realityRevealed`. `realityRevealed` is true once `realityRuns >= realityMinRuns` has been seen on this device, and is stored in `local_meta` (`learning_reality_revealed`). A user who stops for three months doesn't lose the toggle when the 90-day window empties.
- **Highlight, once per device.** The first time the toggle renders after `learning_reality_revealed` is set, the segmented control sits on an `accentTint` pill for `DotMotion.reveal` (new token: hold 2 s, then fade over `slow`). Then `learning_reality_highlighted` is stored and it never runs again. Under reduced motion `DotMotion.reveal` is zero: no tint. Either way, screen readers get one polite announcement, "Plan and reality view is now in the day header".
- Nothing else: no sheet, no tooltip, no notification. A second device computes the same crossing from synced occurrences and shows its own one highlight; that is accepted.

## 5. Learned step lengths (11 §B1)

**new**, and needs ADR-0012.

- **Data.** `subtasks.done_at`: a nullable ms epoch on the client, `timestamptz` on the server (migration 0008). It is synced and exported like `duration_min`. It is set to now when a step is ticked done (Focus, task sheet, editor) and cleared when it is unticked. It is never backfilled: steps ticked before 0008 have none and don't count (B1, never inferred).
- **Focus without the stand-in.** `focusAt` stops reading `Subtask.updatedAt`. The current step starts at the latest `done_at` among the steps before it, else the task's `actualStartUtc`, else its planned start.
- **A step run** = a done step with `done_at`, whose start (the previous step's `done_at`, else the task's `actualStartUtc`) exists, with a span of 1–1440 min. Ticks outside Focus count when the task really started. "In Focus" in 11 §B1 is read as "ticked with a real start before it", which is the only case where a span is real.
- **Identity.** A step is keyed by (normalised task title, normalised step title). `LearningIndex.forStep(taskTitle:, stepTitle:)` returns a `Learned` (median over `window`, null under `stepMinSamples`, rounded to 5 min, at least 5).

## 6. Explain on demand

**new.** One shared widget, `LearnedLine` (`shared/learning/learned_line.dart`, no business logic), wraps a learned caption. Tapped, it expands in place (no sheet, no dialog) to one more line and one action:

> usually 2 h 20
> based on your last 6 times · median   **Reset for this task on this device**

- **Hosts** (seven, all built captions that become `LearnedLine`s):
  1. Add, the "usually" line under the duration chips.
  2. ThreadPicker, the start-offset caption.
  3. Running late sheet, the "usually takes" reason.
  4. Reality live row, the "usually" caption.
  5. Reality insight strip.
  6. Focus step card, "usually 15 min" (§5).
  7. Add's energy line. Its explanation is "based on your last 20 finished high-energy tasks · where most started", with **no** reset, because the energy window is not per title.
- **Touch and a11y.** The whole line is one 44 px (Android 48) target: Semantics button, label = the visible value plus "learned from your history", hint "Shows how this was worked out". Expanded, it announces the explanation. Keyboard: Enter/Space toggles, Esc collapses. Collapsing happens on a second tap or when the host closes.
- **Numbers.** N = `Learned.samples` for lengths, the count of runs with a planned start for offsets, and the step's samples for steps. The method word is always "median" for these.
- **Reset for this task.** It writes `{normalisedTitle: nowUtcMs}` into `local_meta` `learning_resets` (a JSON map, local only, **never synced**, so the copy says "on this device"). `LearningIndex.forTask` and `forStep` ignore runs that started before the reset of the queried title; the cutoff also covers that task's series runs. The line collapses and the value disappears at once. A snackbar says "Learning for Deep work reset on this device" with the built **Undo** (`undoAction`, 30 s), which removes the key. The reset uses accent ink, never error red, and it doesn't ask for confirmation, because it is undoable and local.
- After a reset the task starts again from zero and reveals again at `taskMinSamples`.

## 7. Strings (new or changed ARB keys; English source in `app_en.arb`, de/es/fr updated in the same commit)

| Key | English | Notes |
|---|---|---|
| `settingsLearning` | LEARNING | group caption |
| `settingsLearningReality` | Reality thread | row title |
| `settingsLearningRealityPending` | Dottoday is learning how your days really go. Your reality thread appears after about {total} finished tasks. | `total` int |
| `settingsLearningRealityReady` | Ready · Plan / Reality is in Today's header | |
| `settingsLearningDurations` | Task lengths | |
| `settingsLearningDurationsPending` | Dottoday is learning how long your tasks really take. Each task shows its usual length after about {min} finished times. | `min` int |
| `settingsLearningTasksReady` | {count, plural, =0{} one{Ready for 1 task} other{Ready for {count} tasks}} | empty at 0 hides the value |
| `settingsLearningSteps` | Step lengths | |
| `settingsLearningStepsPending` | Dottoday is learning how long each step takes. A step's timer uses its usual length after about {min} finished times. | |
| `settingsLearningStepsReady` | {count, plural, =0{} one{Ready for 1 step} other{Ready for {count} steps}} | |
| `settingsLearningProgress` | {done}/{total} | ring centre, tabular |
| `settingsLearningProgressLabel` | {done} of {total} so far | ring semantics |
| `settingsLearningPrivacy` | Learning happens on your device. Your actual start and end times sync with your account like the rest of your plan; the learned numbers themselves are never uploaded. | group footer |
| `settingsEnergyLocked` | After {total} finished high-energy tasks · {count} so far | **changed**: `total` placeholder replaces the literal 20 |
| `settingsEnergyReady` | ready — based on {count} completed tasks | enabled, off |
| `learnCaption` | Your reality thread appears after about {total} finished tasks · {done} so far | day card header |
| `learnCaptionHide` | Hide until tomorrow | × semantics |
| `learnRealityReady` | Plan and reality view is now in the day header | one-time announcement |
| `learnStartsAfter` | usually starts ~{minutes} min after plan | **changed** wording (was "you tend to start this …") |
| `learnStartsBefore` | usually starts ~{minutes} min before plan | **changed** wording |
| `learnBasedOn` | based on your last {count, plural, one{time} other{{count} times}} · median | explanation line |
| `learnEnergyBasedOn` | based on your last {count} finished high-energy tasks · where most started | energy explanation |
| `learnFromHistory` | learned from your history | appended to the semantics label |
| `learnExplainHint` | Shows how this was worked out | semantics hint |
| `learnReset` | Reset for this task on this device | action |
| `learnResetDone` | Learning for {title} reset on this device | snackbar; `title` String |

Kept as built: `learnUsually`, `learnInsight`, `learnInsightOk`, `lateUsually`, `settingsEnergy`, `settingsEnergyDetail`, `undoAction`.

**No-shame audit.** Every string above was checked against 11 §D: no "late", "missed", "failed", "streak", "overdue", "behind". The rewording of `learnStartsAfter` drops "you tend to", which framed it as a habit of the user's. No string or state uses error red, and the reset action is accent ink. `no_shame_copy_test.dart` already covers every English string; M13 adds these keys to its fixture so a future edit fails CI.

## 8. Storage (local only unless stated)

| Key / column | Where | Synced | Shape |
|---|---|---|---|
| `subtasks.done_at` | server + Drift | **yes** | nullable ms epoch / `timestamptz` (ADR-0012, migration 0008, Drift schema 7) |
| `learning_resets` | `local_meta` | no | JSON `{normalisedTitle: utcMs}` |
| `learning_caption_day` | `local_meta` | no | `YYYY-MM-DD` |
| `learning_reality_revealed` | `local_meta` | no | ISO date of the crossing |
| `learning_reality_highlighted` | `local_meta` | no | `"1"` |
| `Settings.energySuggestions` | profile settings JSON | yes (as built) | `null`/`false` = off, `true` = on (**changed** meaning of `null`) |

The four `local_meta` keys sit behind one notifier, `LearningMeta` (`data/scheduling/learning_meta.dart`), following `InboxNudgeSeen`. Writes persist before state is published, every write is awaited, and failures surface as `AppFailure`. None of them are exported, matching the other `local_meta` keys (06 §5).

## 9. Minimal mode

One forward rule, for doc 12 (committed separately by the owner): **Settings › Learning section shown; day-card caption and reveal highlight hidden.** Learned values themselves (Add chip, ThreadPicker, Focus, energy) behave as in normal mode. The rule is one predicate, `showLearningPromptsOnToday`, and both the caption and the highlight read it.

## 10. Release announcements (marketing, outside the app)

Release notes, store text, posts and emails about a data feature (Reality thread, learned lengths, step lengths, energy suggestions) go out only when **≥ 50 % of active users** have crossed that feature's threshold. "Active" means at least one occurrence with an actual start in the last 30 days.

- It is measured by an owner-run aggregate count over the synced `occurrences`/`subtasks` columns, with no titles read. Running it touches the hosted project, so it is a must-ask (CLAUDE.md §10).
- The in-app reveal (§3–§4) is independent: it happens for each user on their own data, whether or not an announcement has gone out.
- The in-app "What's new" never announces a learning feature before that user's own reveal.

## 11. Goldens and tests (part of done for M13)

**Goldens.** Each in light and dark, at text scale 1.0 and 2.0 (the largest), LTR and RTL (`TextDirection.rtl`), at compact width; the Settings ones also at expanded width.

1. Settings › Learning at 0/10, 7/10 and ready (reality ready, 3 tasks ready, energy ready-but-off).
2. Today day card header with the learning caption.
3. Header toggle highlight, mid-hold frame (and the reduced-motion frame: no tint).
4. Add duration chips with the learned value pre-selected and "usually 2 h 20".
5. The explanation line expanded, on the Add host and on the Focus step card.

**Tests.** Threshold unit tests on synthetic history for every `LearningThresholds` field at n−1 and n. A `LearningThresholds` override test proves no literal is left. A reset test covers title, series and Undo. A step-run test covers no `done_at`, untick, and the first step from the actual start. There are widget tests for the learning, ready, revealed and explanation states of each host, the caption at most once per day, the highlight once only, the energy switch staying off at 20 until tapped, and the minimal-mode and low-energy predicate. There is a semantics test for all seven `LearnedLine`s and the no-shame fixture update.
