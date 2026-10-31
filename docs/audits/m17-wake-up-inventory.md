# M17 Wake Up: pre-build inventory

Audit of `docs/15-wake-up.md` §1 against `main` at `82b4c26a` (2026-10-31). Read-only: no feature code
changed. Paths are relative to `app/` unless they start with `docs/`, `ios/`, `android/` or `macos/`
(those are under `app/` too).

**Numbering.** The addendum was drafted as doc 14 / M15 / ADR-0010. The real state is:

- M13 is the learning reveal: done.
- M14 is voice + AI clarity: done, and it bumped the app to 1.1.0.
- M15 is sounds: done, with device checks still open.
- M16 is minimal mode: landed, follow-ups open.

So Wake Up is **M17**, doc **15** (`docs/15-wake-up.md`) and **ADR-0017**. ADR-0010 is
`watch-never-authenticates`, and there are two ADR-0015 files.

## 1. The §1 checklist

| # | Item | Found at | Matches spec? | Gap |
|---|---|---|---|---|
| 1 | **Day shape** | `Settings.dayBoundaries: Map<Weekday, TimeWindow>` (`lib/domain/entities/settings.dart:31`) is stored in the JSON column `profiles.settings` (`lib/data/db/tables/profiles.dart:15`) and synced. The fallback is 07:00–22:00 (`:98`). Per-weekday overrides are built: `commonWindow` / `withDayWindow` / `withCapAt(everyDay:)` in `lib/domain/time/day_boundaries.dart`. Today uses `DayShape.on(...)` to get `wakeUtc`/`bedUtc` (`lib/domain/time/day_shape.dart:18`), and `threadEntries` builds the thread (`lib/shared/dot/thread_day.dart:50`). | Partly | The spec says "first dot" is a concept. In code it is just the first task sorted inside the day; there is no helper for it. The only "first dot of the day" rule is the alarm one (row 2). |
| 1a | **Sleep block after Wind Down** | `FeatureId.windDown` ("Wind Down sleep block", `lib/domain/layout/feature_id.dart:18`) is only a hidden row in the layout policy (`layout_policy.dart:70`). | n/a | **It does not exist.** There is no duration, buffer or drawn segment, and the thread ends at the Wind Down cap. `docs/14-minimal-mode.md` contradicts itself: the §3 row at `:43` says "built" while `:134` says "Not built". |
| 2 | **Notification scheduler (A0)** | The port is `NotificationGateway` (`lib/domain/notifications/notification_gateway.dart:6`, with `pending()` and `apply(diff)`). It is implemented by `OsNotificationGateway`, which calls a lower port `NotificationPlatform` (`lib/data/notifications/notification_platform.dart:87`), implemented by `FlnNotificationPlatform`. The sync entrypoint is `NotificationSync.resync(userId)` (`notification_sync.dart:54`); there is no `syncNotifications()`. | Partly | (a) Four files import `flutter_local_notifications`, all in `lib/data/notifications/`: `fln_notification_platform`, `fln_notification_permission`, `fln_exact_alarms` and `notification_providers`. The import is confined to the data layer, but not to one class. (b) The **alarm-loud rule** is `loudStartIds()` in `lib/domain/notifications/alarm_policy.dart:20`. It covers the earliest dot per local day, loud only while still planned, plus routine starts (`notification_planner.dart:82-91`), and plays `startSoundId` (default `dot_alarm`). **Today's alarm anchors on the first dot, not on the Wake Up time.** (c) **Quiet hours** (`day_reminders.dart:155`) make a notification silent rather than dropping it; loud starts and the test alarm are exempt. Low-energy mode drops every non-loud notification. (d) **Android:** channel `alarms` (importance max, `AudioAttributesUsage.alarm`, raw `dot_alarm`) and `dottoday.alarm.<id>` per Start sound; loud notifications set `fullScreenIntent: true` (`fln_notification_platform.dart:218`); the schedule mode is `exactAllowWhileIdle` or `inexactAllowWhileIdle`, **not `alarmClock`**. (e) **iOS:** the interruption level is `timeSensitive` for loud starts *and* for every ordinary at-start alert (`planned_notification.dart:84`), so on iOS only the sound tells the alarm apart. Critical alerts are never used. The time-sensitive entitlement is in `Release.entitlements` only, not in Debug `Runner.entitlements`. |
| 3 | **Health panel + O4 test alarm** | Domain: `lib/domain/notifications/notification_health.dart`, using enums `HealthCheckKind` and `HealthLevel{ok,problem,info}`, the row class `HealthCheck`, and `notificationHealth()`. Page: `lib/features/settings/pages/notification_health_page.dart`. Test alarm: `TestAlarmStore` (`local_meta` key `test_alarm_at`, 60 s) and the `TestAlarm` notifier in `lib/data/notifications/test_alarm.dart`. UI: `TestAlarmCard` (`lib/shared/notifications/test_alarm_card.dart`, `enum TestAlarmStep {idle, explain, waiting, ask, rang, notRang}`), embedded in onboarding `reminders_step.dart:77` and the health page. | Yes | A Wake Up row is a new `HealthCheckKind` plus its inputs; the model is enums, not sealed. Goldens: `settings_health_{all_good,android_off,clock_off,permission_off}_*`, `settings_health_sounds_{0,1,3}_*`, `settings_test_alarm_{ask,waiting}_*`, `onboarding_reminders{,_allowed}_*`. The test alarm goes through `resync` and the planner (loud + time-sensitive), so W1 must reroute it to `AlarmGateway`. |
| 4 | **Sound library** | `sound_catalogue.gen.dart` has 48 sounds: dottoday 4, start 10, quiet 5, clear 15, play 8, done 6. The user picks a default, a Start sound (`startSoundId`, which the loud first dot always uses), a Done sound and a per-task sound (normal tier only). Assets: `ios/Runner/Sounds/` holds 43 `.caf`; `assets/sounds/` holds `dot_alarm.caf`, 4 `.wav` and 44 `.m4a` (web); Android `res/raw` holds `.m4a`/`.wav`. | Yes | **Every Apple file is `.caf` (IMA4) or `.wav` and under 30 s**: Start sounds run 3.6–20.0 s and `dot_alarm` is 9.0 s. So **AlarmKit can use the catalogue as-is**, with no trimming. Separate mismatch: `docs/12-sounds.md` §2.3 lists 12 Start sounds but code has 10 (`rise`, `arpeggio` and `direct` are missing). |
| 5 | **B5 snapshot + app group** | `DaySnapshot` (`lib/domain/snapshot/day_snapshot.dart:85`) holds `wakeUtc`, `bedUtc` and `dots` (now→+24 h, max 20, ended dots dropped), plus inbox, done and total counts. It is written by `DaySnapshotWriter` after every write, at the daily refresh, after intents, and by `WindDownSnapshot` (an in-process timer at Wind Down). Sinks: home_widget (app group `group.app.dottoday.planner`), Live Activity, the macOS status item and web Cache Storage. | Partly | The day's first occurrence **cannot be derived** from the snapshot once that dot has ended. The snapshot has no tomorrow Wake Up / first dot, which W4 and W6 need. iOS and Android native models don't decode `wake_ms`/`bed_ms`; only macOS does. The W2 card is a Flutter route, so it can read providers directly; the snapshot gap matters only for native surfaces. |
| 6 | **B6 intents** | `sealed class DotAction` (`lib/domain/intents/dot_action.dart`) has `AddTask(text,{note,inbox})`, `MarkDone(occurrenceId)`, `AddFifteen(occurrenceId,{plannedEndUtc})` and `StartFocus(occurrenceId)`, plus `DotIntents.whatsNext()`. On the Swift side, `ios/Shared/DotIntents.swift` has the five intents, plus `OpenQuickAddIntent` for Control Center. | Yes | **There is no `MarkStarted`**, and the roadmap fixes the set at exactly five (`docs/11:20`, `:77`). W2's "MarkStarted (sets `actualStartUtc` on the day row)" must be an in-app write to `wake_up_days`, not a new App Intent. |
| 7 | **B3 ProposalSheet + C1 triggers** | `ProposalSheet` (`lib/shared/proposals/proposal_sheet.dart:17`) is hosted by `proposal_view.dart` through `activeProposalProvider`. There is **no trigger type**: every trigger calls `openRebalance(container, l10n, {today, fromUtc, deltaMin, subtitle, keep, title})` (`lib/features/timeline/state/rebalance_flow.dart:36`). The callers are Running late +5/+15/+30, overrun > 10 min, Shift the rest, and a moved calendar event. Accept goes through `ProposalAcceptor.accept`, one batch with a 30 s Undo. | Yes | `lateStart(offsetMin)` is `openRebalance(fromUtc: now, deltaMin: offset, subtitle: …)` plus one ARB string, with no new structure. The nothing-before-Accept helper `expectNothingWrittenBeforeAccept` already exists (`test/support/proposal_harness.dart:80`). |
| 8 | **B1 timestamps + B2 Smallest step** | `Occurrence.actualStartUtc` is set only by `markStarted` (`lib/domain/scheduling/task_progress.dart:38`), reached through the `StartFocus` intent, opening Focus, and the queued surface starts. Smallest step is built: `noStartAt(o, afterMin: 10)` (`lib/domain/scheduling/start_nudge.dart:18`) and the planner's `_smallestSteps` (`notification_planner.dart:166`). | Partly | **The A0 start escalation is not built.** Smallest step fires only for dots *with* steps. The shared trigger `noStartAt` exists and its comment says the escalation "will reuse it" (`start_nudge.dart:12`). `docs/09:227` and `:298` record the deferral. |
| 9 | **Wind Down review** | `TodayPrompt` (`lib/features/timeline/widgets/today_prompt.dart:56-84`) shows it on today, outside low-energy, once `now >= bedUtc`, and only when `reviewOf(blocks).hasRest`. "Not now" lasts for the session only. The body is `DayReviewBody` (`day_review.dart:28`). | Partly | The trigger input is `shape.bedUtc`; W4 swaps it for `effectiveWindDown(D)`. It does **not** show on a day with nothing left, which matters for the §11 existing-user offer (see answer 7). |
| 10 | **Entitlements** | `Entitlements.isPro => true` (`lib/domain/entitlements/entitlements.dart:9`). | Yes | Nothing reads it, so W-features stay ungated by default. |
| 11 | **M13 learning-reveal components** | Promise: the Today caption `todayLearning(...)` returns `TodayLearning` (`today_learning.dart:16`), with gates in `reality_gate.dart`. Soft reveal: `RevealHighlight({child, active, announcement, onDone})` (`lib/shared/motion/reveal_highlight.dart:13`). Explain: `LearnedLine({text, explanation})` with `LearnedExplanation({why, reset, …})` (`lib/shared/learning/learned_line.dart`). Thresholds: `LearningThresholds.standard`. Learned values are derived on read, never stored. | Partly | There is **no "promise card" widget and no "explain sheet"**: the promise is a caption line and the explain is an inline line. Closer to §11's needs is the **M16 hint scheduler**: `pickHint` in `lib/domain/reveal/`, the synced `reveal_hints` table, `hintMaxShows = 2`, and "Not now" retiring a hint forever. That is almost exactly "once; reappears once more after 7 days". **§11 discovery should be built on M16 hints**, with `RevealHighlight` for the soft reveal. `medianDismissOffsetMin` belongs beside `LearningIndex`, derived on read from `wake_up_days`. |
| 12 | **Minimal mode** | Landed (M16.0–M16.11 ticked). The flag is `Settings.uiLayout` (`UiLayout.full | minimal`, `settings.dart:79`), synced. It is read only through `layoutPolicyProvider` and `watchFeature` / `watchOnScreen` / `watchSimplified(ref, FeatureId.x)` (`lib/data/layout/layout_providers.dart`). `test/policy/layout_flag_boundary_test.dart` enforces that boundary. | Yes | Every W-surface needs its own `FeatureId` row in `layout_policy.dart` and a `docs/14` §3 row. The spec's "doc 12 / M14" references are now fixed to doc 14 / M16. |
| 13 | **Native targets** | **iOS:** targets Runner, DottodayWidgets (WidgetBundle + Live Activity `DotLiveActivity.swift`, `NSSupportsLiveActivities`), DottodayShare and RunnerTests. App Group `group.app.dottoday.planner`; deployment target iOS 16.0. **Android:** `minSdk 26`; `targetSdk` and `compileSdk` come from Flutter (36 on 3.47.8). The manifest declares `USE_FULL_SCREEN_INTENT`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED` and `ACCESS_NOTIFICATION_POLICY`, the plugin's boot receiver, and the app's own `TimeChangeReceiver` (TIMEZONE_CHANGED, TIME_SET). | Partly | The widget extension and Live Activity exist, so the AlarmKit countdown view is one more view in **DottodayWidgets** with no new target. Missing: `NSAlarmKitUsageDescription`; `canUseFullScreenIntent()` (checked nowhere); `setAlarmClock` (unused); any `FOREGROUND_SERVICE*` permission (needed for the ringing service); `ACTIVITY_RECOGNITION` (W5). The app **already uses full-screen intent today** for loud starts on targetSdk 36, so the Play full-screen-intent declaration is a live store question now, not only an M17 one. The spec's iOS 15–16 row: the minimum is 16, so 15 never happens. |
| 14 | **Plugin policy** | `flutter_local_notifications ^18.0.0`, locked at 18.0.1 from pub. It is held below 19 by `device_calendar` through `timezone` (`pubspec.yaml:21`). Nothing is vendored: there is no `third_party/`, no `path:` dependency and no override, and no ADR covers vendoring. | Partly | FLN 18.0.1 already offers `AndroidScheduleMode.alarmClock`, `fullScreenIntent` and `requestFullScreenIntentPermission()`, but **no `canUseFullScreenIntent()` query**. That needs a small Kotlin channel, the same pattern as `focus/DeepWork.kt`. The AlarmKit decision is in answer 8. |
| 15 | **Strings** | `test/policy/no_shame_copy_test.dart` walks every non-`@` key in all four ARBs. The English regex is `late|missed|miss|failed|fail|failure|streaks?|overdue|behind`, with per-locale stems and allow-lists (`_runningLateAction`, `_noStreakPromise`). Parity: `l10n_parity_test.dart`. Config: `l10n.yaml` (`nullable-getter: false`). | Partly | (a) The spec's dotted keys (`wakeUp.alarm.label`, `wakeUp.discovery.*`) are **not valid here**: all 1,936 keys are flat camelCase and gen-l10n makes each one a getter. The build should use `wakeUpAlarmLabel` and similar, and amend doc 15 §11/§12 to match. (b) The regex lacks `overslept`, `again`, `short`, `debt` and `score`, plus de/fr/es stems for them. Check for collisions first: "again" and "short" may already appear in neutral strings. |

**Spec-to-code naming that the build must translate:**

| Spec name | Code name |
|---|---|
| `syncNotifications()` | `NotificationSync.resync` |
| `lib/services/alarm/`, `lib/native/` | `lib/domain/notifications/` for the port, `lib/data/notifications/` or `lib/data/alarm/` for implementations (CLAUDE.md §3 layout) |
| `B-ios-*` renders | set B rules in `docs/design-references/README.md` |

## 2. Stale "Bedtime" (report only, not fixed)

**User-visible text is clean.** No ARB *value* in en/de/fr/es contains Wind Down. The one French
hit is `taskIconSunset` ("coucher de soleil"), which is a false positive. The 349 hits, outside
generated files and the CHANGELOG, are identifiers, comments and history:

- **ARB keys (values already say Wind Down):**
  - `durationFitsWindDown`, `durationPastWindDown`
  - `settingsBedtime`, `settingsBedtimeReminder`, `settingsBedtimeReminderDetail`
  - `alertsBedtime`, `alertsBedtimeDetail`
  - `onboardingWindDown`, `onboardingWindDownDetail`
  - `notifWindDownTitle`, `notifWindDownFirst`, `notifWindDownFree`
  - `rebalancePastWindDown`

  These are mirrored in `app_{de,fr,es}.arb`, the generated `app_localizations*.dart` and `test/support/pseudo/pseudo_localizations.g.dart`.
- **Synced data key:** `Settings.bedtimeReminder` (`settings.dart:62`; `docs/05-data-model.md:169,197`). It is a JSON key inside `profiles.settings`, so renaming it needs a read-old-key step. It is not a free rename.
- **Dart identifiers:**
  - `ThreadCap.Wind Down`, `bedUtc` (in `DayShape` and the snapshot), `NotificationPurpose.Wind Down`, `DayReminders.Wind Down`, `WindDownSnapshot`
  - `FeatureId.wakeWindDown` / `bedtimeReview` (`feature_id.dart`, `layout_policy.dart`)
  - `slot_fit.dart`, `rebalance.dart`, `hint_scheduler.dart`, `thread_models.dart`, `thread_day.dart`, `thread.dart`, `thread_pieces.dart`, `thread_outside.dart`, `planned_notification.dart`, `notification_planner.dart`, `day_reminders.dart`, `notification_content.dart`, `snapshot_providers.dart`
  - `alerts_editor.dart` (18), `reminders_step.dart` (8), `reminders_group.dart`, `day_shape_group.dart`, `day_shape_step.dart`, `weekday_sheet.dart`, `cap_time_sheet.dart`, `rebalance_rules.dart`, `editor_series.dart`, `duration_preview.dart`, `proposal_thread_list.dart`, `proposal_edit_row.dart`, `hint_signals.dart`, `app_lifecycle.dart`
- **File names:**
  - `lib/data/snapshot/wind_down_snapshot.dart`
  - `test/domain/notifications/wind_down_reminder_test.dart`
  - `test/data/snapshot/wind_down_snapshot_test.dart`
- **Tests:**
  - `alerts_editor_test`, `thread_day_test`, `running_late_sheet_test`, `settings_screen_test`, `rebalance_test`, `app_lifecycle_test`, `pickers_golden_test`, `thread_golden_test`, `in_app_alert_banner_test`, `notification_payload_test`, `thread_test`, `reminders_step_test`, `hint_scheduler_test`, `low_energy_plan_test`, `day_summary_test`, `notification_content_test`
  - `tool/parity/parity_rows_f5.dart` and `docs/parity-checklist.md:105`, which cite the test path
- **Native comments:** `macos/Runner/DayDotStatusItem.swift:4,45` and `macos/RunnerTests/DayDotImageTests.swift:24` (`testDayShareFollowsWakeUpToWindDown`).
- **Docs:**
  - `docs/09-implementation-plan.md` (27, all in ticked history items)
  - `docs/adr/0007` (3), `docs/adr/0016:42`, `docs/02-prd.md:36` (the rename note itself)
  - design-reference sources `docs/design-references/src/*.dc.html` (A-android/ios-settings, B-ios-rebalance, routines, reality-thread, mac spread, add-when)
- **Migration comment:** `supabase/migrations/0007_routines.sql:4`. Old migrations are never edited, so this one stays.
- **Copied into doc 15:** `docs/15-wake-up.md:202` "asks for sleep, not for a Wind Down" (generic noun) and §2 "Wind Down mode (Digital Wellbeing)" (Android's own name). Both are intentional.

## 3. Answers

### 1. Recommended cut

Ship W1 on the **existing path first**, then AlarmKit and the Android full-screen activity as the
second W1 PR.

The existing loud-start path is already most of an alarm:

- On Android it already uses the alarm audio usage, a max-importance channel and a full-screen intent.
- On iOS it already uses a time-sensitive notification with the Start sound.

The first PR (W0 + W1a) adds three things:

- `AlarmGateway` with a "time-sensitive / heads-up" implementation that wraps the current path.
- `AndroidScheduleMode.alarmClock` for the Wake Up alarm (already in FLN 18.0.1).
- A Kotlin `canUseFullScreenIntent()` channel and `capabilities()`.

That needs no new dependency and no new target.

The second PR (W1b) is the native work:

- the AlarmKit bridge in Runner, with the countdown view in DottodayWidgets;
- `NSAlarmKitUsageDescription`;
- the Android `WakeUpAlarmActivity` with a 10-minute ringing foreground service (adds `FOREGROUND_SERVICE` and `FOREGROUND_SERVICE_MEDIA_PLAYBACK`).

The rest stays in the doc 15 §13 order:

- **W2, W3 and W4 + W6** need only the existing path, so they ship after W1a.
- **Discovery** follows.
- **W5** needs the alarm tier and new sensor dependencies, so it ships last, after W1b.

### 2. B2's start-escalation trigger

**Not built as an escalation.** The shared *condition* exists:
`noStartAt(o, afterMin: startNudgeAfterMin = 10)` in `lib/domain/scheduling/start_nudge.dart:18`.
Its only consumer is Smallest step (`_smallestSteps`, `notification_planner.dart:166`), which
handles dots with steps only.

The A0 escalation for dots without steps is deferred (`docs/09:227`, `:298`). So W3 builds the
`StartEscalation` scheduler once:

- a `wakeUp(dayRow)` input;
- the deferred `dotStart(occurrence)` input;
- Smallest step folded in as its third consumer.

This follows the spec's "if not, build it once here".

### 3. Minimal mode

**It has landed** (M16, ADR-0016; doc 14, not doc 12). The flag is `Settings.uiLayout`
(`UiLayout.full | minimal`), synced in `profiles.settings`. Widgets never read it directly. They
call `watchFeature` / `watchSimplified(ref, FeatureId.x)` against `layoutPolicyProvider`, and a
policy test enforces that.

### 4. Sleep block after Wind Down

**None.** W4's formula is just `min(configured WindDown, wakeAnchor(D+1) − sleepTarget)`, with
nothing extra to subtract. `docs/14-minimal-mode.md:43` wrongly marks the "Wind Down sleep block"
row as built; `:134` and the code agree it isn't. That row should be fixed when doc 14 is next
touched.

### 5. How the day dot is drawn

**Several painters, not one.**

| Surface | Renderer | What it draws |
|---|---|---|
| Flutter progress dot | `DayDot` / `_DayDotPainter`, `lib/shared/dot/day_dot.dart` | One progress arc from Wake Up to Wind Down, no segments. Used by `today_header.dart:166`, `lock_gate.dart:152` and onboarding `welcome_step.dart:89` / `layout_step.dart:45`. |
| Flutter week review | `WeekDayDot` / `_RingPainter`, `lib/features/timeline/review/week_day_dot.dart` | Coloured per-task segments. Used by `week_dots_row.dart` and `week_share.dart`. It is the only segmented day ring, and the one W2's "ring split by the day's dots" describes. |
| macOS menu bar | `DayDotImage.make`, `macos/Runner/DayDotStatusItem.swift:170` | Swift re-implementation of the progress ring. |
| iOS widgets, Live Activity, Android Glance widgets, web | none | `LiveRing` in `ios/Shared/LiveActivityViews.swift` is a per-task ring, not a day dot. Nothing uses `renderFlutterWidget`. |

For W6 to "land everywhere from one place", I recommend a pure `DayRingGeometry`:

- **Where it lives:** `lib/domain/time/`, computing from `DayShape` plus tomorrow's wake.
- **What it returns:** segment fractions, including the night arc.
- **Flutter consumers:** both Flutter painters (or one painter once W2 needs segments on `DayDot`).
- **macOS:** the snapshot gains `next_wake_ms` (and `night_start_ms` if Wind Down is derived). `DayDotStatusItem.swift` then draws the night from data rather than re-deriving it.

Per your rule, W6 lands only where a day dot already exists: Today header, lock gate, onboarding,
week review, the macOS menu bar and the new W2 card. Doc 15 §7b also lists widgets and the Live
Activity, but those have no day dot today. Adding one is new scope, and the doc should be corrected.

### 6. Onboarding Day shape step

`DayShapeStep` (O2) is in `lib/features/onboarding/steps/day_shape_step.dart`. It uses the shared
**`DayShapeSlider`** (`lib/shared/dot/day_shape_slider.dart:16`): one sun→moon track with two
handles that writes on release. Settings' `weekday_sheet.dart:82` uses the same slider. The step
writes only `withCommonWindow`.

- **Keys:** `onboardingDayShapeTitle`, `onboardingDayShapeBody`, `settingsAwake`, `settingsWakeUp`, `settingsWindDown`.
- **Tests:** `test/features/onboarding/day_shape_step_test.dart`, `onboarding_golden_test.dart:67`.
- **Goldens:** `onboarding_dayShape_{light,dark}_{compact,expanded}_{1x,2x}.png` (8 files).

**Gap:** W6 says "the existing time picker plus one slider". The real component is a two-handle
range slider, not separate time pickers. W6 therefore means one of two things:

- keep the slider's Wake Up handle and make the moon handle follow the sleep target (dragging it back-computes the sleep shown), or
- split into a Wake Up picker plus a sleep slider.

I'd keep `DayShapeSlider` and add the sleep slider under it. That needs no new component.

### 7. Wind Down review and nudge entry points

**Review:**
- **Today card:** `TodayPrompt` (`today_prompt.dart:73`, when `now >= shape.bedUtc` and tasks are left).
- **⋯ menu:** `todayMenuReview` → `showDayReviewSheet` (`today_menu.dart:84`).
- **Body:** `DayReviewBody` (`day_review.dart:28`). Title `reviewTitle` "Day review"; first line `reviewSummary` "{done} of {total} done" (`arb:3624`), then `reviewAskTomorrow` / `reviewAskInbox` / `reviewAllDone`.
- **Notification tap does not open the review.** It opens tomorrow's first task or Today (`notification_responder.dart:52`).
- **Card shows only when tasks are left**, so a fully-done day never shows the §11 existing-user sleep offer. Either the offer's trigger widens, or the card shows on every day at Wind Down.

**Nudge:**
- **Planner:** `DayReminders.bedtime` (`lib/domain/notifications/day_reminders.dart:24`). It fires exactly at `bedUtc`, once a day, with id `bedtime:<date>`, gated by `settings.bedtimeReminder`, and silent in quiet hours.
- **Copy:** `notification_content.dart:35`, using `notifWindDownTitle` "Wind Down", `notifWindDownFirst` "Tomorrow starts with {title} at {time}." and `notifWindDownFree` "Nothing planned for tomorrow yet."
- **Change for W6:** swap the body for "Wind down now for {hours} before your {firstDot}." when a sleep target is set.

### 8. AlarmKit plugin

**Recommendation: a thin in-house bridge**, with `alarm_kit` as a reference only (MIT). Do not
take either plugin as a dependency. Verified on pub.dev 2026-10-31:

| | `alarm_kit` 0.1.1 | `flutter_alarmkit` 0.5.0 |
|---|---|---|
| Age / maintenance | 2 versions, both 2026-10-16; 0 likes, 246 downloads in 30 days; new publisher (ahmadre.com) | 17 versions since 2025-06; 27 likes, 2.4k downloads in 30 days; same author as `alarm` (342 likes) |
| Licence | MIT | MIT |
| Snooze / secondary button | Yes: `countdown` (snooze via `postAlert`) or `custom` (a registered `LiveActivityIntent`) | Not documented (stop / pause / resume only) |
| Widget-extension fit | `alarm_kit:setup --extension ios/<Ext>` copies two Swift files **into an existing extension**, so it fits DottodayWidgets | Generates its **own standalone target** `ios/AlarmkitWidget/`. That is a second widget extension, which is a CLAUDE.md §11 must-ask native target. |
| SDK floor | Flutter ≥ 3.32 | Flutter ≥ 3.38 |

Both plugins only wrap AlarmKit's scheduling and update API, which is small. Either one would be a
new dependency (a must-ask) with bus factor 1 at version 0.x. W1 and W5 also need behaviour neither
fully documents: snooze countdown plus a custom "open the Wake Up screen" secondary, and an
id-reconciling `disarmAll`.

The in-house version is:

- one Swift file in Runner (the AlarmManager calls, `alarmUpdates` events on an EventChannel);
- one `AlarmLiveActivity` view added to `DottodayWidgets`;
- the Dart side as the `AlarmGateway` implementation.

That is roughly the size of the existing `DotIntents.swift` and `DeepWork.kt` bridges. It
adds no pubspec entry and no new target, and ADR-0017 records it.

**Android:** no plugin either. Use FLN 18.0.1's `alarmClock` mode and `fullScreenIntent`, plus an
in-house Kotlin channel for `canUseFullScreenIntent()`, the DND policy, and (in W1b) the ringing
activity and foreground service.

**W5 sensors** (pedometer, light) would be new dependencies, so they need a separate must-ask at W5.

### 9. §13 open questions the codebase already answers

- **"v1.0.0 or v1.1 for M17?"** Obsolete. The app is already at `1.1.0+3`: 1.0.0 came at M12.6, 1.1.0 with M14 (`51dc4647`). M17 is a minor bump, 1.2.0. Whether a store build is live isn't recorded in the repo, so the "don't stall a first submission" concern still needs your word.
- **"Default anchor: Wake Up time or first dot?"** Today's alarm-loud rule already anchors on the **first dot** (`alarm_policy.dart`). "First dot" changes nothing for existing users; "Wake Up time" would ring something new. That matters only once the alarm switch is on, so either fits §11, but the zero-change default is first dot.
- **"Routine-start alarms default on or opt-in?"** Routine starts are **already loud** today (`notification_planner.dart:82-91`). `routineAlarms` therefore only decides whether they go up to the AlarmKit / full-screen tier; off keeps today's loud ring. Opt-in, as written, changes nothing.
- **"Which AlarmKit plugin?"** Answered in 8.
- **"Is there a separate sleep block after Wind Down?"** No, as in 4.
- **"Store listing copy: who writes it?"** The store copy lives in `docs/store/` and is policed by `test/policy/store_listing_test.dart` (including the no-shame words). The Play full-screen-intent declaration is already relevant, because loud starts use full-screen intent today. Writing the copy is still yours to assign.
- **Not answerable from code:**
  - the weather provider and whether a network call at Wind Down is acceptable;
  - whether the iOS light mission is worth the camera permission.

## 4. Spec corrections to make at build time

These are not done in this run, apart from the renumbering:

- **§0, line 9: "Everything is mobile only".** This conflicts with your rule that W4 and W6 apply on every platform. Amend it to "W1–W3 and W5 are mobile only; W4 and W6 are data and rendering, everywhere the day dot, review or nudge exist."
- **§11/§12: dotted ARB keys.** Change them to flat camelCase.
- **§7b: night-arc surfaces.** Limit the list to the surfaces that already have a day dot.
- **§1 / §3: names and paths.** Use `NotificationSync.resync`, and the `lib/domain` + `lib/data` paths.
- **§5: `MarkStarted`.** It is an in-app write, not an intent.
- **§5: "Your usual Saturday?"** The C2 weekday routine match it relies on is not built.
- **`wake_up_days`.** Make it **local-only Drift**: per-device alarm state, a new table, no Supabase migration. `WakeUpSettings` fields go into the synced `profiles.settings` JSON, so no column is added or retyped.

## 5. Owner decisions needed before "go"

1. **The cut in answer 1.** W1a on the existing path first, then AlarmKit and Android full-screen in W1b.
2. **An in-house AlarmKit bridge** with no new dependency, recorded in ADR-0017, instead of `alarm_kit` or `flutter_alarmkit`.
3. **Default anchor:** first dot (no change for existing users) or Wake Up time (as the spec says).
4. **W6 surfaces:** only where a day dot already exists, or add a day ring to the widgets and Live Activity.

## 6. Owner decisions (2026-10-31)

The owner accepted the audit. Their decisions are recorded in `docs/15-wake-up.md` §13 under
"Owner decisions" and in the M17 section of `docs/09-implementation-plan.md`:

- **Cut:** as recommended.
- **AlarmKit:** an in-house bridge.
- **Anchor:** the Wake Up alarm rings at the Wake Up time. A first dot within 30 min of Wake Up then sends a normal notification instead.
- **Night arc:** on Today, the Mac menu bar and the widgets, from one geometry function.
- **Strings:** flat camelCase keys.
- **Release:** 1.2.0.
- **Rename:** Bedtime → Wind Down, keeping `bedtimeReminder` as the stored key.
- **Wind Down review:** widened to fully-done days, and opened from the notification.
- **Release gates:** the Play full-screen-intent declaration is in `docs/08-testing-qa.md` §6.1 C. The brief named `docs/12-release-runbook.md`, which doesn't exist; the owner gates live in 08 §6.1.
