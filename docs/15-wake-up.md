# 15 · Wake Up addendum — alarm-grade mornings inside the thread

Oct 31, 2026 · @Kodycio

## 0. Status and scope

Status: **proposed** (needs ADR-0017). This document extends `11-standout-roadmap.md` §A0 and §A1 and `10-ui-concept-a.md`; it replaces nothing. Doc 13 is the learning reveal (M13) and doc 14 is minimal mode (M16); M14 was voice + AI clarity and M15 was sounds (`12-sounds.md`), so this is doc 15 and ships as **M17 Wake Up** — see §13 for the placement question. (Drafted as doc 14 / M15 / ADR-0010; renumbered 2026-10-31 against `09-implementation-plan.md`.)

What it adds, in one line: the first dot of the day becomes an alarm the OS cannot downgrade, dismissing it lands on a Wake Up card that shows the day and offers to replan it, and Wind Down moves itself from tomorrow's first dot. W1–W3 and W5 are **mobile only** (iPhone, Android). W4 and W6 are data and rendering changes and apply on **every platform** wherever the day dot, the Wind Down review or the Wind Down nudge already exist (owner, 2026-10-31). Mac and web read the same data.

Five pieces, each independently shippable, in dependency order:

| Piece | Name | Depends on | New native code |
| --- | --- | --- | --- |
| W1 | Alarm-grade delivery | A0 (built), sound library (built) | AlarmKit bridge (iOS), alarm channel + full-screen activity (Android) |
| W2 | Wake Up card | W1, B5 snapshot, B3 ProposalSheet, C1 Rebalance (all built) | none |
| W3 | Wake Up Check | W1, B1 timestamps, B2 subtasks (built) | none |
| W4 | Wind Down from tomorrow's first dot | Wake Up / Wind Down settings, Wind Down review (built) | none |
| W5 | Missions | W1, W2 | in-house sensor bridge (owner, 2026-11-01): no new dependency |

W6 **The night** (§7b) is a sixth piece: four small visual and copy changes that make the two ends of the thread visible — the sleep slider in onboarding, the night arc on the day dot, the review's opening line and the nudge wording. Depends on W4 only; no native code; ships with W4.

Rules that bind every piece: nothing fires without an alarm-tier opt-in made in Settings or onboarding; every option in §9 has a user-facing switch; every OS gap is stated in plain words with a way to fix it (§2); every screen has a minimal-mode variant (§10); every string passes the no-shame audit (§12). Where this document says "first dot" it means the first non-Wind-Down occurrence after Wake Up on that day; when the day has none, the Wake Up time itself is the alarm.

## 1. Pre-build audit of the current app

The agent runs this inventory first and writes the result to `docs/audits/m17-wake-up-inventory.md` before any code changes; the owner reads it and gives "go". This spec was written without repository access, so every "built" claim below is an assumption to confirm, and the file paths are expected locations, not facts.

- [ ] **Day shape.** Where Wake Up, Wind Down live, and whether a separate sleep block exists after Wind Down (settings table, per-weekday overrides or one value, how Today computes the first occurrence). W2 and W4 attach here.
- [ ] **Notification scheduler (A0).** The `NotificationGateway` port, `syncNotifications()`, the alarm-loud rule for first dot and routine starts, quiet-hours handling, the Android alarm channel id and audio attributes, the iOS interruption level in use. W1 swaps the first-dot path behind this port; confirm the port is the only caller of the plugin.
- [ ] **Notification health panel** (Settings › Reminders) and onboarding **O4 "Send me a test alarm"**: their state model and goldens. W1 adds states to both rather than adding a second panel.
- [ ] **Sound library.** The generated tone set (nudge / ping / alarm / done tiers, palettes), file formats and lengths, how the user picks a sound today. AlarmKit needs `.caf`/`.aiff`/`.wav` under 30 s in the bundle; check which alarm cues qualify and whether any Suno-generated longer cues must be trimmed or kept for the in-app ringing screen only.
- [ ] **B5 snapshot and app-group store.** What the snapshot contains, who writes it and when, whether the first occurrence of the day is derivable from it without the Flutter engine. The W2 card is a snapshot consumer.
- [ ] **B6 intents.** `StartFocus`, `MarkDone`, `AddFifteen` signatures; W2 and W3 call these and nothing else.
- [ ] **B3 ProposalSheet and C1 Rebalance triggers.** How a "Running late" proposal is constructed; W2 needs a `lateStart(offsetMin)` trigger.
- [ ] **B1 timestamps and B2 Smallest step.** Where `actualStartUtc` is set, whether the deferred escalation trigger from A0 was built with B2 or is still a TODO. W3 is that trigger.
- [ ] **Wind Down review.** Its trigger time and how it reads Wind Down. W4 changes the trigger input.
- [ ] **Entitlements service.** The single `isPro` flag; W-features stay ungated.
- [ ] **M13 learning-reveal components** (promise card, soft reveal, explain sheet). §11 reuses them for discovery; confirm their APIs.
- [ ] **Minimal mode (doc 14, M16).** Whether it has landed; which View-layer flag it uses. §10 variants must read the same flag.
- [ ] **Native targets.** Does the iOS project already have a Widget Extension (needed by A1 Live Activity)? AlarmKit's countdown draws through the same kind of extension. Is there an App Group? Android: `targetSdk`, whether `USE_FULL_SCREEN_INTENT` and `SCHEDULE_EXACT_ALARM` are declared, and whether `canUseFullScreenIntent()` is checked anywhere.
- [ ] **Plugin policy.** Which notification plugin is in use and whether it is vendored behind the gateway (dependency-hygiene rule). The AlarmKit plugins below are 0.x; decide vendor-in versus pin.
- [ ] **Strings.** The no-shame audit script from M12 and the ARB layout; every new key in §12 goes through it.

Output of the audit: a table of each checkbox with *found at* / *matches spec* / *gap*, plus a one-paragraph recommendation on whether W1 ships with AlarmKit in the first cut or starts on the existing time-sensitive path with AlarmKit as the second PR.

## 2. OS support: modern and old paths, and what the user is told

One rule: the feature never disappears on an older OS; it steps down one tier, and the app says so in one sentence with a button that leads to the fix. `AlarmGateway.capabilities()` (§3) is the single source of truth; the health panel, Settings › Wake Up, the Wake Up card and onboarding all read it. No screen checks an OS version itself.

| Platform / version | Wake-up alarm tier | What the user gets | What the user is told (health panel + Settings › Wake Up) | Fix button |
| --- | --- | --- | --- | --- |
| iOS 26+ | **Alarm** (AlarmKit) | Full-screen alert, rings through Silent and every Focus, system countdown on lock screen / Dynamic Island / paired Watch, app may be killed | "Alarm-grade wake-up is on." | — |
| iOS 26+, alarm permission denied | Time-sensitive | Banner + sound; silenced by Silent switch | "Wake Up can ring like an alarm, but alarms are off for Dottoday in Settings." | Opens Settings › Dottoday |
| iOS 17–25 | Time-sensitive | Breaks through Focus (not Silent switch); Live Activity countdown via A1 | "Your iPhone can't run alarm-grade wake-ups yet. They need iOS 26." + one line on what still works | "Check for iOS update" → Settings › General › Software Update (deep link where allowed) |
| iOS 15–16 | Time-sensitive, no Live Activity | Banner + sound | same as above | same |
| iOS 26+, time-sensitive entitlement missing (debug / Personal Team) | AlarmKit still works | — | n/a (AlarmKit has no entitlement) | — |
| Android 14+ (API 34+) with FSI + exact alarm granted | **Alarm** | Full-screen wake-up activity over lock screen, alarm audio stream (ignores media volume and DND), exact `setAlarmClock`, re-armed on boot | "Alarm-grade wake-up is on." | — |
| Android 14+, full-screen intent revoked by Play or user | Heads-up | Heads-up notification with alarm sound; no full screen | "Wake Up can take over the screen like an alarm. Android needs you to allow it." | Opens the Manage full-screen intents page for Dottoday |
| Android 12–13 (API 31–33) | Alarm (FSI granted by default) | Same as 14+ | OK, or exact-alarm prompt if missing | `SCHEDULE_EXACT_ALARM` settings page |
| Android 8–11 (API 26–30) | Alarm | Same, no runtime alarm permission | OK | Battery-optimisation exemption prompt |
| Android 7 and below | not supported | App minimum stays whatever it is today | — | — |
| Any Android, battery optimisation on (OEM killers) | Alarm may be delayed |  | "Your phone may delay alarms to save battery." + OEM-specific line where known (Samsung, Xiaomi, Huawei, OnePlus) | Opens the exemption dialog |
| Mac, web | none | Nothing fires; Today unchanged | Settings › Wake Up shows "Wake-up alarms ring on your phone." | — |

**Which modes the wake-up rings through.** The user's own quiet modes and ours, by tier. "Yes" means sound and screen as the tier allows; the W3 check and every normal dot ping follow the ordinary rules and are silenced by all of these.

| Mode | iOS 26+ alarm tier | iOS < 26 time-sensitive | Android alarm tier | Android heads-up tier |
| --- | --- | --- | --- | --- |
| Focus (any), incl. Sleep Focus | Yes | Yes, unless that Focus has "Time Sensitive" turned off | — | — |
| Silent switch / Action button silent | Yes | No sound, vibration only | — | — |
| Do Not Disturb | Yes | Yes (same Focus rule) | Yes while "Alarms" stays an allowed exception | Yes, no full screen |
| Bedtime mode (Digital Wellbeing, Google's name) / OEM sleep modes | — | — | Yes (they allow alarms by default) | Yes, no full screen |
| DND with the "Alarms" exception turned off | — | — | No — nothing rings, stock Clock included | No |
| Volume at zero | Rings at alarm volume | Silent | Rings on the alarm stream | Rings on the alarm stream |
| Dottoday quiet hours | Ignored | Ignored | Ignored | Ignored |
| Dottoday low-energy mode, Wind Down block, deep-work DND (A3) | Ignored | Ignored | Ignored | Ignored |

The Android "Alarms exception off" case is a blocker like the others: `AlarmCapabilities.blockers` carries `dndAlarmsBlocked`, the health panel says "Do Not Disturb is set to silence alarms too. Allow alarms so Wake Up can ring." and the fix button opens the DND settings page. Checked at every `capabilities()` read via `NotificationManager.getNotificationPolicy()` where the app holds notification-policy access, else inferred from the current interruption filter and stated as "may".

How the user is told, by moment:

1. **Onboarding O4** gains a line under "Send me a test alarm": the tier the device can do, in the words above. On a device below the alarm tier the test still runs, so the user sees what they will actually get.
2. **Settings › Wake Up** header: a one-line status chip (Alarm / Time-sensitive / Heads-up) with the same fix button. The chip re-reads capabilities every time the screen opens and after returning from a settings deep link.
3. **Notification health panel** gains a "Wake Up" row alongside permission, exact-alarm, battery and Focus/DND.
4. **After an OS update** (version string changed since last launch) on a device that crosses the iOS 26 / Android 14 line: one soft-reveal card on Today, "Your phone can now ring Dottoday's wake-up like an alarm. Turn it on?" with On / Not now. Shown once.
5. **Update prompts** are suggestions only: the app never blocks, never repeats the prompt more than once per OS version, and the "Check for update" button is hidden on devices whose hardware cannot run the needed version (iPhone models that stop at iOS 18, Android devices with no newer OTA — detected by a small static table, best effort).

Plugin facts behind the table (as of 2026-10-31; re-verify at build time): [alarm\_kit](https://pub.dev/packages/alarm_kit) and [flutter\_alarmkit](https://pub.dev/packages/flutter_alarmkit) both expose AlarmKit from Flutter; AlarmKit is iOS/iPadOS 26+ only, has no entitlement, needs `NSAlarmKitUsageDescription`, custom sounds must be `.caf`/`.aiff`/`.wav` under 30 s in the bundle, and the countdown needs a WidgetKit extension. Android: from 14, [Play revokes `USE_FULL_SCREEN_INTENT` at install for apps without calling or alarm features](https://source.android.com/docs/core/permissions/fsi-limits), so the store listing and the `AndroidManifest` must present a real alarm feature, and the app checks `canUseFullScreenIntent()` at runtime.

## 3. W0 · Shared block: AlarmGateway, Wake Up state, settings

Build W0 first; W1–W5 are consumers. It is one port, one state machine and one settings record, all in pure Dart, with the plugins quarantined in `lib/native/`.

**`AlarmGateway`** (lib/services/alarm/): sits beside the existing `NotificationGateway`, never replaces it. Normal dot pings keep going through `NotificationGateway`; only the wake-up alarm and routine-start alarms go through `AlarmGateway`. Throwing placeholder provider until the composition root overrides it; one live implementation per platform plus a fake for tests.

```dart
abstract interface class AlarmGateway {
  Future<AlarmCapabilities> capabilities();   // tier, reasons, fix actions
  Future<Result<void, AlarmFailure>> requestAuthorization();
  Future<Result<void, AlarmFailure>> arm(WakeUpAlarm alarm);   // idempotent per alarm.id
  Future<void> disarm(WakeUpAlarmId id);
  Future<void> disarmAll();
  Stream<AlarmEvent> events();   // alerting, dismissed, snoozed, missed
}
```

**As built (M17.2–M17.3, ADR-0017).** `wake_up_days` is local-only Drift (schema 10): one row per civil day, with when it rang, when "I'm up" stopped it, snoozes, and when the card showed and the day was started. `AlarmGateway.drainEvents()` stands in for `events()`.

**M17.2 port.**
- The port lives in `lib/domain/notifications/alarm_capabilities.dart`.
- Instead of `arm` / `disarm` / `events`, it has:
  - `sync(alarms)`: makes the list the armed set, leaves a ringing or snoozed alarm alone, and returns the instants armed;
  - `disarmAll()`, `test()` and `requestAuthorization()`.
- The planner leaves out what `sync` armed, so a device that arms nothing rings on the notification path.
- `events()` comes with `wake_up_days` in W2.

`AlarmCapabilities` = `tier` (alarm / timeSensitive / headsUp / none), `blockers` (a sealed list: `osTooOld(required)`, `permissionDenied`, `fullScreenIntentRevoked`, `exactAlarmDenied`, `batteryOptimised`, `dndAlarmsBlocked`, `notAPhone`) and `fixAction` per blocker (a sealed intent the UI turns into a button). `WakeUpAlarm` = id, `fireAt` (civil wall-clock + tz, resolved to an instant at arm time, re-resolved on `TIMEZONE_CHANGED`), `soundId`, `snooze` (allowed, minutes, maxCount), `dismissal` (swipe / mission), `label`, `occurrenceId?`.

**Wake Up state machine** (one per calendar day, persisted in Drift, `wake_up_days` table): `planned → armed → alerting → snoozed(n) → dismissed → started | skipped`. Transitions and who causes them:

| From | Event | To | Side effect |
| --- | --- | --- | --- |
| planned | `syncNotifications()` before Wind Down | armed | `AlarmGateway.arm` |
| armed | OS fires | alerting | OS-side; app may be dead |
| alerting | Snooze (n < max) | snoozed(n+1) | re-arm +N min |
| alerting / snoozed | Dismiss (swipe or mission done) | dismissed | record `dismissedAtUtc`; open W2 card |
| dismissed | Start the day / any `StartFocus` | started | set `actualStartUtc` on the first dot; cancel W3 check |
| dismissed | W3 timer expires with no start | alerting (check) | one re-alarm, then dismissed |
| any | user turns Wake Up alarm off, or day passes | skipped | disarm |

Invariant tested by property test: at most one armed OS alarm per `wake_up_days` row; `disarmAll()` on sign-out and on uninstall-safe reset (the AlarmKit alarms outliving the app is a complaint against Awake; on iOS we cancel on every `syncNotifications()` any alarm whose id is not in the table).

**Settings record** `WakeUpSettings` (Drift, synced like other settings, applied only on phones; §9 lists every field with its default). The day-shape values Wake Up and Wind Down stay where they are; this record only adds *how* Wake Up fires.

**Learned values** (local only, never synced, rule-based): `medianDismissOffsetMin` over the last 10 wake-ups (used by W2's late-start line and the health panel's "you usually get up \~12 min after Wake Up"). Lives with the C3 reality-thread learner, same storage and same reveal rules (doc 13).

## 4. W1 · Alarm-grade delivery

*Problem:* A0 made dot-start reminders time-sensitive, but the Wake Up ping is still a notification: the Silent switch, a dead app or an OEM battery killer can lose it, and a planner whose first dot never arrives has failed before the day starts. W1 makes the wake-up (and, optionally, routine starts) a real alarm on every OS that allows one, through `AlarmGateway`.

**What fires.** Default: the Wake Up time on days with a thread; the user can switch the anchor to "first dot's start" in §9. Routine-start alarms (A0 rule) move to the same gateway behind their own switch, default off, so that W1 changes nothing for routines until the user asks.

**iOS 26+ (AlarmKit).** `arm()` schedules an AlarmKit alarm with: the chosen sound from the Dottoday alarm tier (bundled `.caf` under 30 s; the ringing screen in-app may play the longer cue), a label "Wake Up · Dottoday", a stop button and a secondary button. The secondary button is "Snooze" (countdown behaviour, `postAlert` = snooze minutes) when snooze is allowed, else hidden. Dismissal with a mission (W5) uses the custom secondary behaviour that opens the app's Wake Up screen instead of stopping the alarm. The countdown Live Activity (snooze remaining) renders through the same Widget Extension target as A1; reuse the target, add one activity view.

**iOS below 26.** Unchanged A0 path: time-sensitive notification, `AddFifteen`-style actions "I'm up" and "Snooze", and the A1 Live Activity as the second line of defence. The Wake Up card (W2) still opens on tap.

**Android (API 26+).** A dedicated `wake_up` channel (IMPORTANCE\_HIGH, `USAGE_ALARM` audio attributes, bypass DND where the user has granted it), `AlarmManager.setAlarmClock()` for the fire time (exact, shows the system alarm icon, survives Doze), a `WakeUpAlarmActivity` launched by full-screen intent over the lock screen (`showWhenLocked`, `turnScreenOn`) with Snooze / I'm up / mission, a foreground service that owns the ringing for at most 10 min, and re-arm on `BOOT_COMPLETED`, `TIMEZONE_CHANGED` and `TIME_SET`. When `canUseFullScreenIntent()` is false the same notification posts as heads-up with the two actions; nothing else changes.

**Sound rotation.** `soundMode`: one sound, or rotate through a chosen set (2–6 cues) so the ear does not tune one out. Rotation is deterministic from the civil date (seeded-determinism rule) so a test can assert which cue a given day uses. The "preview" button in Settings plays the cue at the alarm volume on Android and at media volume on iOS, with a one-line note.

**Snooze.** Allowed by default, 9 min, max 3. Each snooze re-arms through `arm()` with a new `fireAt`; the state row records the count. When the max is reached the stop control becomes the only control. Awake's snooze posts a Live Activity countdown; we do the same on iOS 26+ (free with AlarmKit) and a chronometer notification on Android.

**Ringing volume and escalation.** Android: ramp from 40 % to the alarm stream volume over 30 s (setting). iOS: AlarmKit owns volume; no setting is shown. No vibration-only mode beyond the OS's own; `soundId = none` is allowed for Watch-wearers and is explained as "your phone will vibrate and your watch will tap you".

**Stop conditions, written down because Awake users hit the opposite bug:** the alarm stops on dismiss, on reaching the ringing cap (10 min), on sign-out, and on any `syncNotifications()` run that finds its row gone. There is never a second armed alarm for the same day except the single W3 check.

**Health panel additions.** A "Wake Up" row with the tier chip and, per blocker, one sentence and its fix button (§2). A "Last wake-up" line: "Rang 06:30, dismissed 06:41" or "Did not ring — \<reason if known>". The test-alarm button from O4 is repeated here and fires through `AlarmGateway`, so the user tests the real path.

**AC.** Fires on iOS 26 device with app force-quit and Silent on; fires on Android 14 emulator in Doze with app killed; property test: ≤ 1 armed alarm per day row; golden for each capability tier on both platforms; snooze cap enforced; sound rotation deterministic per date; uninstall/sign-out leaves no AlarmKit alarm (manual release gate on device).

## 5. W2 · Wake Up card

*Problem:* Awake's most-loved feature is the morning briefing, and its weakest point is that the day plan is a thumbnail that deep-links to another app. In Dottoday the plan is already here, so the briefing is the thread itself, plus the one thing an alarm app cannot do: replan.

**When it opens.** Immediately after the wake-up alarm is dismissed (W1), when the user taps the Wake Up notification on older OSes, or on the first foreground of the day between Wake Up and Wake Up + 3 h when the day has a thread and the card has not been shown yet (setting `showOnFirstOpen`, default on). It is a full-screen route pushed over Today, dismissible by swipe or the close control; it never opens twice for the same day. Users with the card switched off (§9) land on Today as now.

**What it shows, top to bottom (Concept A components only):**

1. Greeting line with the civil date, no name, no streak: "Good morning. Saturday 31 October."
2. The **day dot** (B5 render) at 96 px, ring split by the day's dots in their colours, all faint because nothing is done yet; centre shows "N planned · ends 21:30".
3. **First dot, large:** title, icon, planned start, duration, and its first subtask when it has one ("first: lay out running clothes · 2 min"). This is the same row component as the Today live dot.
4. **Thread strip:** the next 4 dots as a horizontal mini thread (the B1 mini-thread component), tap any to open its sheet.
5. **Context chips** (each a setting, each off until enabled): calendar events imported for today (M7; count + next one), weather for the device location (new, opt-in, needs location permission, one provider behind a `WeatherGateway`), Inbox count, and "from yesterday: 2 moved here" when C1 pushed tasks. **Owner, 2026-10-31: weather moved to Phase 2** (`11-standout-roadmap.md`, Phase 2: Open-Meteo, coarse location, opt-in); the M17 card has calendar and Inbox lines only.
6. **Late-start line**, only when dismissal is ≥ `lateThresholdMin` (default 10) after planned Wake Up: "You're up 25 min after plan." followed by one button, **Shift the rest?** → opens the C1 ProposalSheet with trigger `lateStart(25)`: shift dots forward, shrink optional ones, push past-Wind Down dots to tomorrow, pinned dots untouched. Accept / Discard, nothing applied before Accept, Undo 30 s. The ghost preview is the existing B3 render.
7. Primary button **Start the day** → `StartFocus(firstDot)` when the first dot is within 15 min, else `MarkStarted` (sets `actualStartUtc` on the day row, not on a dot) and returns to Today. Secondary: **Later** (closes; W3 still runs).

If the day has no thread: the dot is empty, the first-dot slot becomes "Nothing planned yet" with **Plan today** (opens Add) and **Your usual Saturday?** when a routine matches the weekday (C2). Low-energy mode (D2) on: the card shows only the first dot and Start.

**Data and boundaries.** Reads the B5 snapshot and the occurrence repository through the existing providers; the only writes are through B6 intents and the ProposalSheet's transaction. Weather and calendar reads are cached at Wind Down by the same background job that re-arms alarms, so the card paints without network. No new tables; the day row (`wake_up_days`) gains `cardShownAtUtc`.

**Render.** `B-ios-wake-up-card.png` and the Android equivalent, both in set B, derived from the Today live-dot artboard and the Wind Down review artboard; the late-start state and the empty-day state each get a golden.

## 6. W3 · Wake Up Check

*Problem:* dismissing an alarm proves a hand moved, not that the day started. Awake announced a "wake-up check" for this; Dottoday already owns the signal (`actualStartUtc`) and the trigger (B2 Smallest step). W3 is that trigger pointed at the morning.

**Rule.** When the day row is `dismissed` and `checkAfterMin` (default 10, range 5–30) pass with no `started` transition, fire **one** check alarm through `AlarmGateway` at the normal-ping tier, never alarm-loud unless `checkTier = alarm` is set. Its body is the Smallest-step form: "Just \<first subtask> · 2 min?" when the first dot has subtasks, else "Start \<first dot>?". One action, **Start**, which sets `actualStartUtc` and opens Focus (A3). Snoozing the check is not offered; dismissing it ends the check for the day. Never more than one check per day.

**Shared trigger.** Implement as `StartEscalation` (one scheduler, two inputs): `wakeUp(dayRow)` and `dotStart(occurrence)` (the deferred A0 escalation and B2). Both compute "planned anchor + N min with no actualStart" the same way, both are cancelled by the same `StartFocus` / `MarkDone` / `MarkStarted` events. If the audit (§1) finds B2's trigger already built, W3 is one new input to it; if not, build it once here and B2 consumes it.

**As built (M17.4).**
- `escalationAt(WakeUpStart(day, firstDot:))` shares `escalationAt(DotStart(o))` with Smallest step (`domain/scheduling/start_escalation.dart`).
- The OS arms the check when "I'm up" stops the alarm, because the app may be closed. Android uses `WakeUpChecks`; iOS 26 uses `WakeUpAlarms.armCheck`.
- A start in the app calls it off through `AlarmGateway.sync(startedDays:)`.
- The check rides the alarm tier. Where the Wake Up rings as a notification, nothing reports "I'm up", so there is no check.

**AC.** Headless Notifier test: dismissed + 10 min + no start → exactly one check; start at minute 4 → none; two dismissals in a day → one check. Golden for the check notification on both platforms.

## 7. W4 · Wind Down from tomorrow's first dot

*Problem:* Awake computes Wind Down (our Wind Down) from wake time plus desired sleep, and users like that the evening knows about the morning. Dottoday has both ends of the thread already; W4 links them with one number.

**Rule.** Setting `sleepTargetMin` (off, or 6 h–10 h in 15-min steps, default off). When set, Wind Down for day D is derived as `min(configured WindDown, wakeAnchor(D+1) − sleepTarget)` where `wakeAnchor` is tomorrow's Wake Up or its first dot (same anchor choice as W1). If the audit (§1) finds a separate sleep buffer between Wind Down and lights-out, subtract it as well. Derived, never stored: the Wind Down review, the Wind Down nudge and the day card's end all read `effectiveWindDown(D)` from one pure function with an injected Clock.

**What the user sees.** In Settings › Day shape, Wind Down shows "22:45 · from tomorrow's 06:30" with the sleep target chip beside it; tapping explains in one sentence. On Today, when tomorrow's first dot is earlier than usual, the Wind Down dot moves earlier and the day card footer reads "Tomorrow starts 06:00 → wind down 22:15". No other nudge. If the derived Wind Down would fall before the current time plus 1 h, the configured Wind Down wins and nothing is said.

**Edges.** Per-weekday Wind Down overrides keep winning when earlier. Timezone change re-derives. Tomorrow has no thread → configured Wind Down. The Wind Down review's weekly picture (D1) gains nothing; the daily review opens at the effective Wind Down.

**As built (M17.5).** `effectiveDayShape` in `domain/time/wind_down.dart` is anchored on tomorrow's Wake Up time (owner's anchor) and read through the `dayEnds` provider. There is no sleep block (§1), so nothing else is subtracted.

**AC.** Pure-function tests with a table of (Wind Down, tomorrow anchor, target, wind-down) → effective Wind Down, including DST-crossing dates; golden of the Day-shape row in both states.

## 7b. W6 · The night — making the two ends visible

*Position:* the thread has two ends, and the app protects the night between them. Dottoday never measures sleep (no Health data, no pickup heuristics, no sleep score, no week-over-week comparison — each of those is a streak in disguise); it plans the night and shows the plan. Verbs allowed in product and store copy: plan, protect, wind down. Verbs refused: track, improve, score.

Four small changes, all pure consumers of W4's `effectiveWindDown(D)` and the existing Wake Up value:

1. **Onboarding Day shape asks how much sleep, not for an end time.** The step keeps the Wake Up picker and replaces the Wind Down picker with a sleep-target slider (6 h–10 h, 15-min steps, default 8 h); Wind Down is computed live beneath it as "Wind Down 22:45 · 7 h 45 of sleep" and can still be dragged directly, which then shows the resulting sleep. This sets `sleepTargetMin` from day one; existing users get the one-time offer in their next Wind Down review (§11) and stay at "off" until they answer it. The Concept A onboarding render for this step is updated in set B (`B-ios-onboarding-day-shape.png`); the component is the existing time picker plus one slider, nothing new.
2. **The night on the day dot.** The arc from Wind Down round to the next day's Wake Up renders as a faint night segment (token `night`, derived from `surface` at 12 % in light and 18 % in dark; never a colour that reads as a warning). Tap or long-press shows "Night · 7 h 45". Applies everywhere the day dot is drawn: Today, Wake Up card, widgets, menu bar, Live Activity, and the seven dots of the weekly review, where short nights become visible as geometry without a number. One switch, `showNightArc`, default on.
3. **The Wind Down review opens with the night.** First line: "7 h 20 until Wake Up at 06:30", or "7 h 45 if you wind down now" when opened early. Everything after it is unchanged.
4. **The Wind Down nudge names what it protects.** "Wind down now for 7 h 30 before your 06:30 run." — tomorrow's first dot title when there is one, else the Wake Up time. When no sleep target is set, the nudge stays as it is today.

**As built (M17.5).**
- `dayDotGeometry` (`domain/time/day_dot_geometry.dart`) is the one geometry. The snapshot carries `tomorrow_wake_ms` and the derived `night_start`, so the Mac menu bar and the iOS and Android widget day dots only scale by it.
- The night is drawn thinner as well as fainter, so it reads without colour (owner's surfaces: Today, Wake Up card, week review, menu bar, widgets; not the Live Activity).
- The review's opening line follows the minute tick. The sleep offer's decline is "No thanks".

**Learned value allowed:** `medianDismissOffsetMin` (W0) may offer, once, in the Day shape row: "You usually get up \~12 min after Wake Up. Move Wind Down 12 min earlier?" Yes / No; never automatic, never repeated inside 30 days, reveal rules from doc 13.

**Pitch line** (store page and onboarding last screen, under the three pillars, not a fourth pillar): "Starts your morning, ends your evening." Screenshot pair: the Wind Down review with the night arc, the Wake Up card the next morning.

**Minimal mode:** the slider and the night arc stay (they are geometry, not chrome); the review's first line stays; the nudge text stays.

**AC.** Night-arc golden at 5 h, 8 h and 10 h nights in light and dark, on the Today dot and the week review; onboarding golden in both drag directions; pure-function tests for the "until Wake Up" line across midnight and DST; no-shame audit passes with the added words ("short", "debt", "score" added to the rejected list).

**Milestone AC additions for W6** (merge into §13's list): existing-user offer shown exactly once and never after Not now (headless test); night arc present on every dot surface, verified by one golden per surface; store-copy review confirms only plan / protect / wind down verbs.

## 8. W5 · Missions (opt-in, default off)

*Problem:* some users cannot trust a swipe. Awake solves this with missions (math, QR, steps, light); the math and QR ones generate most of its "won't stop ringing" anger. Dottoday offers short missions that are physical, calm or part of planning the day. None of them can be failed, and every one has a way out. Rules, missions and choices below are the owner's (2026-11-01).

**Rules.**

1. **Only the morning wake-up alarm.** Dot starts, routine starts and the W3 check never ask for a mission.
2. **When.** The `missionMode` setting (§9) decides which mornings have a mission:
   - **Off:** never. This is the default.
   - **Only when I ask:** only on mornings the user flagged with "Make sure I'm up" (below).
   - **Only after a snooze:** the first ring dismisses with a swipe as usual; the mission appears only on a ring after the user has snoozed once that morning. People who wake on their first ring never see one. Turning missions on starts here, with Stand up.
   - **Only on chosen days:** the weekdays in `missionDays` (for example Mon–Fri).
   - **Every time:** every wake-up alarm.
   In every mode except Off, a flagged morning gets the mission too.
3. **Never stuck.** The mission is skipped and the alarm dismisses with "I'm up" as usual when:
   - the user taps "Can't right now" and holds it for 5 seconds (recorded as `missionSkipped = true`);
   - the mission's sensor is missing or its permission was denied;
   - the phone is connected to CarPlay or Android Auto;
   - the alarm is not on the alarm tier (§2);
   - the mission cannot run that morning (Pick today's one thing with fewer than 2 dots).
   The alarm stops at the 10-minute ringing cap regardless.
4. **A gentle way out.** After 3 skips in 7 days the app offers once: "Missions seem to get in the way lately. Turn them off?" It never turns them off by itself. No skip counter is ever shown.
5. **"Make sure I'm up".** The user flags an important morning in places they already visit:
   - In the Wind Down review: one toggle, "Tomorrow matters: make sure I'm up."
   - In the task sheet: a switch, "Make sure I'm up for this." When that dot is the first one of its day, that morning gets the mission. Useful for flights added weeks ahead. On a repeating task it flags this occurrence only.
   Each flag applies to one morning and clears afterwards, so a mission is never "always on" by accident. The flags are hidden while `missionMode` is Off.
6. **Sensors only while ringing.** Sensor data is read while the mission screen is open and never stored.

**iOS Stop (owner, 2026-11-01).** On iOS 26.1+ AlarmKit always shows the system's own Stop, and the app cannot hide it. On a mission morning, Stop silences the alarm, opens the app on the mission, and the alarm rings again 1 minute later until an exit: mission done, "Can't right now" (hold 5 s), or the 10-minute cap. After an exit the Wake Up Check still runs, as on every morning. Android behaves the same (R-13). Real-device gate: mission morning, app force-quit, alarm rings, tap Stop → the app opens on the mission and, if left alone, rings again about 1 minute later. If that passes it ships as built; only if it fails is a backup alarm added, with an ADR saying why.

**The missions.** The user picks one (`missionKind`). Stand up is the default because it needs no permission.

| Mission | How | Done when | Fallback |
| --- | --- | --- | --- |
| Stand up | accelerometer + gyroscope, no permission | the phone has been held upright and moving for 3 s | — (every phone has the sensors) |
| Walk | pedometer (Core Motion / Android step counter, `ACTIVITY_RECOGNITION` on API 29+) | step delta ≥ `missionSteps` (10–60, default 20) since the mission began | skipped (rule 3); Settings shows why |
| Light | Android ambient light sensor (`TYPE_LIGHT`); iPhone has no public light API, so it reads the camera's exposure brightness, no image kept. The camera permission is asked once, when the user picks Light in Settings, never while ringing | lux ≥ 200 for 3 s (Android), or brightness ≥ 3× the starting level for 3 s (iPhone) | greyed on devices without a usable sensor, with the reason |
| Breathe | on-screen: hold the ring while it grows, let go while it shrinks, 3 times (about 20 s) | 3 breaths; losing the rhythm just keeps it going | — |
| Catch the dot | on-screen: tap the slowly moving dot 5 times | 5 taps; a miss doesn't count and nothing says so | — |
| Pick today's one thing | on-screen: today's first 3–5 dots; tap the one that matters most. Every answer is right | one tap | skipped with fewer than 2 dots (rule 3) |

- **Wakes you up, doesn't get you up.** Breathe, Catch the dot and Pick today's one thing prove you're awake, not out of bed. Their Settings rows say so: "Wakes you up, doesn't get you up."
- **Breathe** is the option for people who can't walk or stand easily. With reduced motion the ring doesn't grow; a "Hold · Let go" text and the count lead instead.
- **Catch the dot** stays slow and forgiving (no-shame rule): no timer, no score, no fail screen.
- **Pick today's one thing** marks the picked dot as today's one thing: a thin accent ring outside the dot (its fill and state are unchanged) and "Your one thing" in the row's small text, so it never relies on colour. It shows on Today, the Wake Up card and the widgets, and clears when the day ends.
  - Fewer than 2 dots: no pick that morning. With 0 there is nothing to pick; with 1 the app would be deciding for the user, which the mission exists to avoid. The alarm shows the normal "I'm up", and the Wake Up card's empty-day state takes over unchanged ("Nothing planned yet", Plan today). Its Settings row says once: "Needs at least two dots that day."
  - This only happens with explicit weekdays and the Wake Up time anchor; with the first-dot anchor and no dots there is nothing to ring for.
  - A flagged morning with fewer than 2 dots: the evening toggle says so the night before: "Tomorrow has nothing to pick from yet; Walk will be used instead" when a backup mission is set, or "…plan a dot or two first."
- **Backup mission** (`missionBackup`, none / Walk / Stand up, default none): used on a morning the chosen mission can't run. Without one, the alarm dismisses with "I'm up".

**Flow.** The alarm rings as in W1. On iOS 26+ the primary AlarmKit button is "Snooze" (if allowed); on a mission morning the system Stop opens the app on the mission (iOS Stop above). On Android the full-screen activity is the Wake Up screen already. The screen shows the ring at 120 px, the mission as one line ("Walk 20 steps") with its live state, and "Can't right now". When done, the alarm stops and the W2 card opens.

**Why not more.** Math and typing missions contradict the no-shame principle (failing a quiz at 06:30), QR scanning needs the camera at the moment the user is least coordinated, and third-party app missions are a partnership programme, not a feature. If local, opt-in analytics show mission users skipping more than completing, W5 is reduced rather than extended. Tap a spot (NFC), Dock the phone, Reach up and Turn around are Phase 2 ideas (`11-standout-roadmap.md`).

**AC.**
- Fake sensors in tests drive every mission to done and to skip.
- The 10-minute cap stops the ringing for every mission.
- Each `missionMode` decides the right mornings (pure tests, including the snooze rule and flags).
- The skip offer shows once after 3 skips in 7 days and never turns missions off itself.
- Goldens for each mission screen in minimal and full mode, light and dark; the one-thing ring on Today.
- a11y: the step count is announced every 5 steps, the light meter and Breathe have a text state, Catch the dot has a "Tap" button for screen readers.

## 9. Settings › Wake Up — every option

A new Settings section **Wake Up** sits directly under Day shape (Wake Up / Wind Down values stay in Day shape). It opens with the tier chip and fix button from §2, then these rows, in this order. Every row is a `WakeUpSettings` field, synced, applied on phones only; rows whose feature the device cannot do are shown greyed with the one-line reason, never hidden, so the user knows the option exists.

| Row (user label) | Field | Type | Default | Shown when | Note |
| --- | --- | --- | --- | --- | --- |
| Ring like an alarm | `alarmEnabled` | switch | off (on after the O4 opt-in) | always | Master switch for W1; off = A0 behaviour exactly as today |
| Anchor | `anchor` | Wake Up time / first dot | Wake Up time | alarmEnabled | W1 and W4 share it |
| Days | `days` | weekday set | days with a thread | alarmEnabled | "Only days I've planned" is the default option; explicit weekdays optional |
| Sound | `soundId` | picker from the alarm tier | first alarm cue | alarmEnabled | Preview button; "None (vibrate / watch)" allowed |
| Vary the sound | `soundMode` | off / rotate (choose 2–6) | off | alarmEnabled | W1 rotation. As built: `wakeUpVarySound` + `wakeUpRotationIds`, by default the three calmest Start sounds (Gentle, Soft bells, Dawn chorus; owner 2026-11-01) |
| Volume ramp | `rampSeconds` | 0 / 15 / 30 / 60 | 30 | Android only | iOS: hidden, AlarmKit owns volume |
| Snooze | `snoozeAllowed` | switch | on | alarmEnabled |  |
| Snooze length | `snoozeMin` | 5 / 9 / 10 / 15 | 9 | snoozeAllowed |  |
| Snooze limit | `snoozeMax` | 1–5 / unlimited | 3 | snoozeAllowed |  |
| Routine starts ring like an alarm | `routineAlarms` | switch | off | alarmEnabled | moves A0's routine-start rule onto W1 |
| Wake Up card | `cardEnabled` | switch | on | always | W2 master. As built (M17.3): `wakeUpCard`, nullable; unset follows the Wake Up alarm switch, so the card never opens for anyone who hasn't said yes to Wake Up (§11); a flip stores the choice |
| Show it when I first open the app | `showOnFirstOpen` | switch | on | cardEnabled | covers older OS / notification-tap path |
| Calendar on the card | `cardCalendar` | switch | on when a calendar is connected | cardEnabled |  |
| Weather on the card | `cardWeather` | switch | off | cardEnabled | **Phase 2** (owner, 2026-10-31; `11-standout-roadmap.md`): not in M17 |
| Inbox count on the card | `cardInbox` | switch | on | cardEnabled |  |
| Offer to shift the day when I'm up late | `lateStartOffer` | switch | on | cardEnabled | W2 step 6 |
| …after | `lateThresholdMin` | 5 / 10 / 15 / 30 | 10 | lateStartOffer |  |
| Check I've started | `checkEnabled` | switch | on | alarmEnabled or cardEnabled | W3 |
| …after | `checkAfterMin` | 5–30 | 10 | checkEnabled |  |
| …as | `checkTier` | gentle ping / alarm | gentle ping | checkEnabled |  |
| Sleep target | `sleepTargetMin` | off / 6 h–10 h | off | always | W4; shown with the derived Wind Down preview |
| Missions | `missionMode` | off / only when I ask / only after a snooze / only on chosen days / every time | off | alarm tier available | W5 §8 rule 2; greyed with "needs alarm-grade wake-up" otherwise. Turning it on starts at "only after a snooze" |
| …on | `missionDays` | weekday set | Mon–Fri | missionMode = chosen days |  |
| Mission | `missionKind` | stand up / walk / light / breathe / catch the dot / pick today's one thing | stand up | missionMode ≠ off | a mission this device can't do is greyed with its reason; the on-screen three say "Wakes you up, doesn't get you up" |
| Steps | `missionSteps` | 10–60 | 20 | missionKind = walk |  |
| Backup mission | `missionBackup` | none / walk / stand up | none | missionMode ≠ off | used when the chosen mission can't run that morning |
| Offer to turn missions off after repeated skips | `missionSkipOffer` | switch | on | missionMode ≠ off |  |
| Quiet hours apply to the wake-up alarm | — | read-only line | never | always | states the A0 rule: the wake-up and routine-start alarms always break through; the Wake Up Check and every other ping respect quiet hours |
| Send a test alarm | — | button |  | always | fires in 60 s through the real gateway |
| Notification health | — | link |  | always | opens the panel |

Rules for the screen: a switch that cannot take effect on this device is greyed, not hidden, with its reason and fix button inline; changing `alarmEnabled` or `anchor` re-runs `syncNotifications()` immediately; turning `alarmEnabled` off disarms and clears any pending check; defaults are applied per-device on first launch after the M17 update so that nothing rings differently until the user says yes (§11). Minimal mode shows the same screen with rows collapsed into three groups (§10).

Rows added by §7b (same table, after Sleep target): **Show the night on the day dot** (`showNightArc`, switch, default on, always shown) and **Offer to move Wind Down from how I actually get up** (`windDownLearnOffer`, switch, default on, shown when sleep target is set). The sleep-target row's default becomes 8 h for accounts created after this milestone and stays off for existing accounts until they touch it.

## 10. Minimal mode

Every W-surface reads the minimal-mode flag from doc 14 (M16) and renders a reduced variant from the same ViewModel; nothing is removed, only hidden behind one tap. The full and minimal variants share goldens in the same matrix.

| Surface | Full mode | Minimal mode |
| --- | --- | --- |
| Ringing screen (Android activity / iOS in-app) | Ring 120 px, time, label, Snooze, I'm up, mission | Time, one big **I'm up** button, Snooze as a text link; mission line only when enabled |
| Wake Up card (W2) | Day dot, first dot, thread strip, context chips, late-start line, Start / Later | First dot + **Start**. Late-start line only when it applies, as one sentence + one button. Thread strip and chips behind "Show my day" |
| Wake Up Check (W3) | "Just \<step> · 2 min?" + Start | identical (already one line) |
| Day shape row (W4) | "22:45 · from tomorrow's 06:30" + chip | "Wind Down 22:45" — the derivation shows on tap only |
| Settings › Wake Up | 29 rows (§9) | Three grouped rows: **Alarm** (on/off, sound), **Morning card** (on/off), **Missions** (mode); "More options" expands the full list in place |
| Notification health | Full panel | Tier chip + the single most important fix button; "Details" expands |
| Discovery cards (§11) | Promise card + explain sheet | One line with a single button; no illustration |

Minimal-mode defaults differ in one place: `cardEnabled` stays on, but the card opens only from the alarm dismissal, not on first open (`showOnFirstOpen` = off), because an unexpected full-screen route is the kind of thing minimal mode exists to avoid.

## 11. Discovery: how people learn it exists and how to use it

Nothing in M17 rings differently until the user has said yes once, and every entry point teaches the feature in the moment it is useful. Reuse the M13 learning-reveal components (promise card, soft reveal, explain sheet) rather than new ones.

| Moment | Who sees it | What it says and does | Shown |
| --- | --- | --- | --- |
| Onboarding O4 (new users) | everyone | The existing "Send me a test alarm" step gains a second card after the test confirms: "Make Wake Up ring like an alarm?" with the device tier line (§2) and On / Not now. On → requests the alarm permission and sets `alarmEnabled` | once |
| Update to M17 (existing users) | everyone on phone | A promise card at the top of Today the first morning after the update: "New: Wake Up can ring like an alarm, and your morning starts with a card that shows your day." Buttons **Turn on** (goes to Settings › Wake Up with the master switch focused) and **Later**; a third link **See how it works** opens the explain sheet | once; reappears once more after 7 days if neither button was tapped |
| First dismissal of the alarm | users with W1 on | The W2 card opens with a one-line coach mark on **Start the day**: "Tap when you're up — your day's thread starts from here." | first 2 times |
| First late start | users with W2 on | Coach mark on **Shift the rest?**: "This moves what's left; nothing changes until you accept." | once |
| First check ping | users with W3 on | The notification's expanded text adds "You can change or turn this off in Settings › Wake Up." | first 2 times |
| Device gains the alarm tier (OS update) | users with W1 off | Soft reveal on Today: "Your phone can now ring Dottoday's wake-up like an alarm. Turn it on?" | once per OS major |
| 3 wake-ups where dismissal was ≥ 20 min after plan | users with W5 off and the alarm tier | Soft reveal: "Mornings start a while after the alarm lately. Want a short walk or a light to switch it off?" → Settings › Missions | once per 30 days |
| Settings › Wake Up header | everyone | Permanent **How it works** link → explain sheet with four lines: what rings, what the card does, what the check does, where to turn each off | always |
| Help › Wake Up | everyone | The explain sheet plus the §2 table in plain words, per the user's own device | always |
| Mac / web Settings | desktop users | The Wake Up section exists, read-only, saying "These ring on your phone. Change them there or here; they sync." — the switches are editable so a desktop user can configure the phone | always |

Added by §7b for **existing users** (new users set it in onboarding): the first Wind Down review after the update opens with a promise card in place of the night line — "New: tell Dottoday how much sleep you want and Wind Down will move itself from tomorrow's first dot." with a sleep slider inline (default 8 h), **Set** and **Not now**. Set writes `sleepTargetMin` and the review re-renders with the night line; Not now never shows the card again, and the row stays in Settings › Day shape. Shown once; the night arc on the dot appears for everyone regardless, since it only draws the Wind Down → Wake Up gap that already exists.

Copy for every card lives in the ARB files under `wakeUp.discovery.*` and goes through the no-shame audit (§12). No badge counts, no red dots on the Settings tab; the promise card is the only unprompted surface, and it is dismissible.

## 12. No-shame copy

Every string below is the shipped English source (`app_en.arb`, prefix `wakeUp.`); the audit script rejects "late", "missed", "failed", "overslept", "again" and any red token on these keys.

| Key | Text | Not this |
| --- | --- | --- |
| `alarm.label` | Wake Up · Dottoday | Alarm! |
| `alarm.stop` | I'm up | Dismiss |
| `alarm.snooze` | Snooze 9 min |  |
| `alarm.snoozeLast` | Last snooze | No more snoozes |
| `card.greeting` | Good morning. {weekday} {day} {month}. | Rise and shine, {name}! |
| `card.planned` | {count} planned · ends {time} |  |
| `card.first` | First: {title} |  |
| `card.firstStep` | first: {step} · {min} min |  |
| `card.lateLine` | You're up {min} min after plan. | You overslept by {min} min |
| `card.shift` | Shift the rest? | Fix your day |
| `card.start` | Start the day | Let's go! |
| `card.later` | Later | Skip |
| `card.empty` | Nothing planned yet | Your day is empty |
| `check.body` | Just {step} · {min} min? | You haven't started yet |
| `check.bodyNoStep` | Start {title}? | Still in bed? |
| `check.action` | Start |  |
| `windDown.derived` | {time} · from tomorrow's {anchor} |  |
| `windDown.footer` | Tomorrow starts {anchor} → wind down {time} | Go to bed earlier |
| `mission.walk` | Walk {steps} steps | Prove you're awake |
| `mission.light` | Turn on a light |  |
| `mission.cantNow` | Can't right now | Give up |
| `mission.offerOff` | Missions seem to get in the way lately. Turn them off? | You keep skipping missions |
| `tier.alarm` | Alarm-grade wake-up is on. |  |
| `tier.osTooOld` | Your phone can't run alarm-grade wake-ups yet. They need {os}. | Your phone is too old |
| `tier.fsiRevoked` | Wake Up can take over the screen like an alarm. Android needs you to allow it. |  |
| `tier.battery` | Your phone may delay alarms to save battery. |  |
| `health.last` | Rang {ringTime}, dismissed {dismissTime} |  |
| `health.didNotRing` | Did not ring{reason} | Alarm failed |
| `discovery.promise` | New: Wake Up can ring like an alarm, and your morning starts with a card that shows your day. |  |
| `discovery.tierGained` | Your phone can now ring Dottoday's wake-up like an alarm. Turn it on? |  |
| `discovery.missionOffer` | Mornings start a while after the alarm lately. Want a short walk or a light to switch it off? | You keep oversleeping |

Keys added by §7b: `night.label` "Night · {hours}"; `night.untilWakeUp` "{hours} until Wake Up at {time}"; `night.ifNow` "{hours} if you wind down now"; `night.nudge` "Wind down now for {hours} before your {firstDot}."; `night.nudgeNoDot` "Wind down now for {hours} before {time}."; `night.learnOffer` "You usually get up \~{min} min after Wake Up. Move Wind Down {min} min earlier?"; `onboarding.sleepTarget` "How much sleep do you want?"; `onboarding.windDownLive` "Wind Down {time} · {hours} of sleep"; `pitch.ends` "Starts your morning, ends your evening." Not this: "Sleep debt", "Short night", "You slept", "Sleep score".

Tone rules carried from `11-standout-roadmap.md`: counts and times, never judgements; "usually" for learned values; no exclamation marks except none; the user's name is never used in the morning.

## 13. Milestone, gating, acceptance and open questions

**Placement.** M17 Wake Up, after M16 minimal mode. Recommendation: ship v1.0.0 without it and land M17 as v1.1, because W1 adds a new OS permission, a native extension view and a Play-store feature declaration, each of which can stall a first submission. If the owner prefers it in v1.0.0, W1 on the existing time-sensitive path plus W2 and W4 fit before the gates; AlarmKit, W3 and W5 follow in v1.1. The agent proposes the cut in the audit output.

**Order inside M17** (each PR independently mergeable, feature-flagged by its §9 master switch): W0 → W1 (time-sensitive path first, AlarmKit + Android full-screen second) → W2 → W3 → W4 + W6 together (one PR: derivation, onboarding slider, night arc, review line, nudge) → discovery (§11) → W5 last.

**Free / Pro.** Everything ungated, per the roadmap rule; the entitlements flag may be read but no W-feature checks it. If the owner's pricing review wants a hook, the only candidates that fit "core free forever" are weather on the card and sound rotation.

**Acceptance criteria for the milestone** (in addition to each piece's AC):

- [ ] Wake-up alarm fires with the app force-quit on a physical iPhone on iOS 26 with Silent on, and on an Android 14 emulator in Doze; recorded as release gates
- [ ] Property test: never more than one armed OS alarm per day row, never more than one check per day
- [ ] Test proving nothing is written before Accept on the late-start proposal
- [ ] Every §9 row has a golden in enabled, disabled and greyed-with-reason states, light and dark, full and minimal
- [ ] Every §2 tier has a golden of the health panel row and of the Settings header chip
- [ ] Uninstall / sign-out on iOS leaves no AlarmKit alarm (manual gate); `disarmAll()` tested
- [ ] Every `wakeUp.*` string passes the no-shame script; ARB parity across locales
- [ ] a11y sweep per the design-review workflow: ringing screen and mission screen usable with VoiceOver / TalkBack at 200 % text
- [ ] Mac and web unchanged except the read-only Settings section
- [ ] Cold-start budget unchanged: the W2 card paints from cached data in under 300 ms on the floor device

**ADR-0017** records: AlarmKit chosen over time-sensitive as the iOS 26+ path and why (no entitlement, breaks Silent, system countdown); the two-gateway split (`NotificationGateway` for pings, `AlarmGateway` for alarms); plugin choice and vendoring decision; the rule that missions exist only on the wake-up alarm.

**Owner decisions (2026-10-31, after the audit in `docs/audits/m17-wake-up-inventory.md`).** These win over anything above that says otherwise.

- **Release:** M17 ships as **1.2.0** (the app is already 1.1.0).
- **PR order:** W1a → W1b → W2 → W3 → W4 + W6 → W5, one PR each, screenshot sweep before each close.
  - **W1a:** exact alarm-clock scheduling (`AndroidScheduleMode.alarmClock`) and the full-screen-intent permission check (`canUseFullScreenIntent()`), on the existing notification path, with no new dependency.
  - **W1b:** the AlarmKit bridge and the Android ringing screen.
- **AlarmKit:** an in-house bridge, with no package. iOS 26+ only, behind an availability check; below 26 the current time-sensitive path stays untouched. The countdown view goes in the existing `DottodayWidgets` extension, so there is no second native target. Sounds are used as they are (all bundled `.caf`/`.wav` are under 30 s).
- **Anchor:** the Wake Up alarm rings at the **Wake Up time**. The existing first-dot loud alarm stays. When the Wake Up alarm is on and the first dot starts within 30 min of Wake Up, that first dot sends a normal notification instead of a second loud alarm.
- **Where the switch lives:** Settings › Day shape › **Wake Up alarm**. It is off for existing users, and offered in onboarding for new users with on as the default there.
- **Night arc:** one shared geometry function, read by every painter: `DayDot`, `WeekDayDot`, the Mac menu bar and the iOS/Android widgets. The snapshot gains `tomorrowWake`. The arc appears on Today's day dot, the Mac menu bar and the lock-screen/home widgets. The Live Activity stays task-only.
- **Strings:** l10n keys are flat camelCase, as the repo does (`wakeUpAlarmLabel`, not `wakeUp.alarm.label`). Every dotted key in §11–§12 is read that way.
- **Wind Down rename:** code identifiers, comments and docs move to Wind Down. *Superseded 2026-11-01 by the owner ("Wind Down everywhere, whether the customer sees it or not"):* the stored, synced settings key is `windDownReminder` too; schema 11 and Supabase `0011_wind_down_reminder.sql` move the value from the old key.
- **Wind Down review:**
  - It also shows on a fully-done day, because the §11 sleep offer needs it.
  - Tapping the Wind Down notification opens the review.

**Open questions for the owner:**

- [ ] v1.0.0 or v1.1 for M17 (see Placement)?
- [ ] Which AlarmKit plugin, or a thin in-house bridge? The audit compares `alarm_kit` and `flutter_alarmkit` on maintenance, licence and widget-extension fit
- [x] Weather provider for the card. Decided 2026-10-31: Phase 2, Open-Meteo over plain HTTPS behind a `WeatherGateway`, coarse location, opt-in from Morning card settings, off by default, never asked during onboarding (`11-standout-roadmap.md`).
- [ ] Default anchor: Wake Up time (proposed) or first dot?
- [ ] Should routine-start alarms default on for users who turn on the wake-up alarm, or stay opt-in as written?
- [ ] Is the iOS "light" mission worth the camera permission, or iOS ships Walk only?
- [ ] Store listing copy: the alarm feature must appear in the Play description for the full-screen-intent grant; who writes it?

* [ ] Is there a separate sleep block after Wind Down? W4's formula subtracts it only if it exists; the audit confirms
