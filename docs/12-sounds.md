# 12 · Sounds — "a dot you can hear"

Status: **approved with owner amendments, 2026-10-28** (→ ADR-0014; ADR-0010 is taken). The amendments are folded in below and marked *(owner)*. Extends `11-standout-roadmap.md` §A0 (alert tiers) and `10-ui-concept-a.md`; does not replace them. Builds on the `NotificationGateway` from the `local-notifications-scheduler` skill.

Tags: **built** = exists on main; **new** = this document adds it.

One-line position: every dot has a sound; the user picks it per task; the first dot of the day always sounds like their Start sound. No sound in the app ever means "you failed".

**Guiding rule *(owner)*: add to the existing sound system (docs/02 F6.6, plan M8.4d).** Nothing is removed or remapped, and nothing a current user hears or configured changes on upgrade. The four first-party tones (Dot, Chime, Bell, Ripple), `dot_alarm`, `tool/gen_sounds.dart`, the `Library/Sounds` install step and every existing Android channel stay.

---

## 0. Decisions

| # | Decision | Why |
|---|---|---|
| D1 | Sounds are bundled assets, never downloaded at runtime. | Offline-first; no network on any notification path. |
| D2 | **Per-task sound applies to the normal (time-sensitive) tier only.** The alarm-loud tier (first dot of the day, routine starts — A0) always plays the **Start sound** chosen in Settings › Reminders (default: the existing `dot_alarm` chime *(owner)*). | Halves the Android channel count (see §4) and is explainable in one sentence: "your first dot always sounds like your Start sound". |
| D3 | The per-task alert **tier** stays rule-based (A0: "no per-task settings in v1"). Only the *sound* is per-task. | Bends A0's wording, not its intent; record in ADR-0014. |
| D4 | The **Done sound** is one global setting (Settings › Reminders › Done sound), not per task. | Completion should feel the same every time. |
| D5 | Nothing is gated. If extra packs ever become Pro, they belong beside "themes and icon packs" in the draft split in `11-standout-roadmap.md`. The Start tier is a delivery guarantee and is never gated. | `00-vision.md`: core free forever. |
| D6 | Sources limited to **CC0** and **CC BY 4.0**. No Mixkit, no Zapsplat Standard, no CC BY-NC / BY-SA, nothing without a written licence. | One obligation (a credit line), no revocable or account-bound terms. |
| D7 | No "error", "siren", "annoying" category. | No-shame audit (`11` done criteria). The single insistent option (`start.insistent`) is opt-in and never a default. |
| D8 *(owner)* | Add, never remove: existing tones, keys and channels keep working unchanged (see the guiding rule). | No upgrade changes what a user hears. |
| D9 *(owner)* | No duplicates: ids, display names (across every source, first-party included) and file contents are unique — a policy test. An audible near-twin of an existing sound is dropped in the ear pass; the existing one stays. | One name means one sound. |

## 1. Attribution (the one obligation)

**User-facing, exactly one line**, as the footer of Settings › Reminders › Sounds (Concept A caption style):

> Sounds from notificationsounds.com (CC BY 4.0).

*(owner, phase 1)* "UI sounds by Kenney" is gone with the Kenney sounds (§2.6). The source name is a tappable link (homepage is sufficient per the licence page). Nothing else — no per-sound credits in the UI.

**Licences screen** (the existing third-party notices list) gets the full notice, because CC BY asks that modifications be indicated:

> Notification sounds from notificationsounds.com, © Notification Sounds, licensed CC BY 4.0 (creativecommons.org/licenses/by/4.0). Files were trimmed, downmixed to mono, shortened to 20 seconds where longer, and loudness-normalised.

The text is the `notice` of the source in the manifest; `CREDITS.md` and the licences screen both render it from there.

**Repo**: `assets/sounds/manifest.json` (§5) is the provenance record, one entry per file with the specific source page; `CREDITS.md` is generated from it. Original downloads kept unmodified in `tool/sounds/originals/` (not shipped). The footer and the licences notice are both rendered from the manifest's distinct `sourceName`/`license` values, so adding a source can never ship without its credit.

## 2. Catalogue — 5 first-party + 37 notification sounds + 6 Done sounds (48 entries)

*(owner, phase-1 rebuild)* Duration rules (policy test, `durationMs`): Quiet ≤ 1500 ms; Clear, Playful, Done ≤ 4000 ms; Start 3000–20000 ms. Changes:
- **Dropped:** `quiet.discreet` (8.3 s), `quiet.pristine` (4.28 s after trim: over the 4 s Clear limit), `start.rise` (0.4 s); also `start.direct` (0.4 s) and `start.arpeggio` (2.0 s), which are under the 3 s Start minimum for the same reason as `rise`.
- **Moved:** `quiet.tap` → `clear.tap` (2.4 s).
- **Capped at the category maximum with a 0.5 s fade:** Clear `bright`, `settled`, `opening`, `spark`; Playful `knock`, `dog`, `gulls`. Start sounds over 20 s are cut with a 1 s fade.
- **Looped:** `start.insistent` (2.3 s original), back to back ×8 to 18.3 s with the final repeat faded out; `modified: "looped"` and `loopToMs` in the manifest.

The tables below are the original proposal; the manifest is the shipped list.

Source names are the originals on notificationsounds.com; the slug is the path after `https://notificationsounds.com/`. Dottoday names are proposals; the **ear pass** (§7) may swap any entry for a sibling in the same collection without an ADR.

### 2.0 Dottoday — first-party, listed first *(owner)*

The existing tones, made by `tool/gen_sounds.dart` (source `dottoday`, no credit). Their ids are the keys already stored in `Settings.reminderSound`, unchanged.

| id | Dottoday | File |
|---|---|---|
| `dot` | **Dot** (default normal-tier sound) | `reminder_dot.wav` |
| `chime` | Chime | `reminder_chime.wav` |
| `bell` | Bell | `reminder_bell.wav` |
| `ripple` | Ripple | `reminder_ripple.wav` |
| `dot_alarm` | Dot alarm (**default Start sound**, §2.3) | `dot_alarm.caf` / `.m4a` |

### 2.1 Quiet — short and soft · 8

| id | Dottoday | Source | Slug |
|---|---|---|---|
| `quiet.slip` | Slip *(owner: renamed from "Dot", which the first-party tone already is)* | Slick | soft-subtle-ringtones/slick-notification |
| `quiet.whisper` | Whisper | Sly | application-user-interface-ui-sounds/sly-user-interface-sound |
| `quiet.soft` | Soft | Happy to help | application-user-interface-ui-sounds/happy-to-help-notification-sound |
| `quiet.tap` | Tap | Confident | notification-sounds/confident-543 |
| `quiet.bubble` | Bubble | Bubbling up | notification-sounds/bubbling-up-530 |
| `quiet.pull` | Pull | Pull out | notification-sounds/pull-out-551 |
| `quiet.pristine` | Pristine | Pristine | message-tones/pristine-609 |
| `quiet.discreet` | Discreet | Discreet | wake-up-tones/discreet-492 |

### 2.2 Clear — 1–2 s melodic · 14

| id | Dottoday | Source | Slug |
|---|---|---|---|
| `clear.lift` | Lift | Light hearted | free-jingles-and-logos/light-hearted-message-tone |
| `clear.bright` | Bright | Joyous | free-jingles-and-logos/joyous-chime-notification |
| `clear.smile` | Smile | Smile | free-jingles-and-logos/smile-ringtone |
| `clear.ease` | Ease | Relax | message-tones/relax-message-tone |
| `clear.turn` | Turn | Your turn | message-tones/your-turn-491 |
| `clear.settled` | Settled | Goes without saying | notification-sounds/goes-without-saying-608 |
| `clear.quick` | Quick | That was quick | message-tones/that-was-quick-606 |
| `clear.opening` | Opening | Opening | notification-sounds/opening-message-tone |
| `clear.spark` | Spark | Magic | free-jingles-and-logos/message-ringtone-magic |
| `clear.emerge` | Emerge | Emergence | free-jingles-and-logos/emergence-ringtone |
| `clear.elegant` | Elegant | Elegant | notification-sounds/elegant-notification-sound |
| `clear.dutiful` | Dutiful | Dutifully | free-jingles-and-logos/dutifully-notification-tone |
| `clear.involved` | Involved | Involved | notification-sounds/involved-notification |
| `clear.appear` | Appear | Out of nowhere | message-tones/out-of-nowhere-message-tone |

### 2.3 Start — alarm-loud tier · 12

Only offered in Settings › Reminders › **Start sound** (D2), after the default `dot_alarm` (§2.0). Files may run up to 20 s (the build caps longer originals at 20 s with a 1 s fade); iOS caps a notification sound at 30 s.

| id | Dottoday | Source | Slug |
|---|---|---|---|
| `start.rise` | Rise | Gentle alarm | wake-up-tones/gentle-alarm-474 |
| `start.morning` | Morning | Good morning | wake-up-tones/good-morning-502 |
| `start.bells` | Soft bells *(owner: not "Bells", next to first-party Bell)* | Soft bells | wake-up-tones/soft-bells-495 |
| `start.arpeggio` | Arpeggio | Arpeggio | wake-up-tones/arpeggio-467 |
| `start.sunrise` | Sunrise | Early sunrise | wake-up-tones/early-sunrise-517 |
| `start.solemn` | Solemn | Solemn | wake-up-tones/solemn-522 |
| `start.strike` | Strike | Serious strike | wake-up-tones/serious-strike-533 |
| `start.swing` | Swing | Swinging | wake-up-tones/swinging-617 |
| `start.direct` | Direct | Direct | notification-sounds/direct-545 |
| `start.lovingly` | Lovingly | Lovingly | wake-up-tones/lovingly-618 |
| `start.gentle` | Gentle | Be gentle with yourself | wake-up-tones/be-gentle-with-yourself-485 |
| `start.insistent` | Insistent | Alarm frenzy | wake-up-tones/alarm-frenzy-493 |

`start.insistent` shows a caption "Loud and repeating. Use it if quieter sounds don't reach you." — never "annoying".

### 2.4 Playful · 8

| id | Dottoday | Source | Slug |
|---|---|---|---|
| `play.rooster` | Rooster | Young rooster | animals/young-rooster-cock-a-doodle-doo |
| `play.horse` | Horse | Horse whinnies | wake-up-tones/horse-whinnies-476 |
| `play.knock` | Knock | Door knock | wake-up-tones/door-knock-478 |
| `play.chick` | Chick | Little chicken | animals/little-chicken-sound |
| `play.frog` | Frog | Bullfrog | animals/bullfrog-477 |
| `play.dog` | Dog | Dog barking at the moon | animals/dog-barking-at-the-moon-482 |
| `play.gulls` | Gulls | Seagulls chatting | wake-up-tones/seagulls-chatting-385 |
| `play.drum` | Drum | Stirring drum | toys-sounds/stirring-drum-sound |

### 2.5 Done — global setting · 6 selectable (notificationsounds.com)

| id | Dottoday | Source | Slug |
|---|---|---|---|
| `done.swift` | **Swift** (default) | Swift gesture | notification-sounds/notification-tone-swift-gesture |
| `done.checked` | Checked | Checked off | notification-sounds/message-tone-checked-off |
| `done.done` | Done | Job done | notification-sounds/job-done-501 |
| `done.finished` | Finished | My work is done | notification-sounds/my-work-is-done-message-tone |
| `done.succeeded` | Succeeded | Succeeded | message-tones/succeeded-message-tone |
| `done.achieved` | Achieved | Achievement | message-tones/achievement-message-tone |

### 2.6 Fixed UI feedback — dropped *(owner, phase 1)*

Focus keeps `chime` as its step tick. Nothing else in the app plays a feedback sound today (the ProposalSheet Accept, +15 and the plan/reality toggle are silent), so `ui.switch` and `ui.confirm` have no clear use and `ui.tick` is replaced by the existing tick: no Kenney files ship, and Kenney leaves the credits. The original proposal, for the record:

#### Original proposal (not built)

Not user-selectable. One file each, chosen in the ear pass from `kenney.nl/assets/interface-sounds`:

| id | Used for |
|---|---|
| `ui.tick` | step tick in Focus, subtask check |
| `ui.switch` | plan / reality toggle, low-energy switch |
| `ui.confirm` | ProposalSheet Accept, +15 |

All UI feedback respects the OS silent switch and the in-app "Sounds in app" toggle (default on).

### 2.7 Excluded on purpose

Not good, Upset, That's it (error sounds); Siren wail, Police patrol, Firetruck, Siren yelp (alarms as threat); Capisci?, Credulous, Hold on, Come to daddy, all ASMR/voice tones (tone or privacy). Voice category deferred; the only clean candidate found is *Excuse me (male voice)* — record our own if Voice is ever built.

## 3. Data model — **new** *(owner)*

A sound choice is one text value with three states:

| Value | Means |
|---|---|
| `null` | inherit: nothing chosen at creation or edit |
| `"none"` | explicitly silent (the "None" picker row): vibration / visual only |
| `"<id>"` | that sound (a manifest id) |

- `occurrences.sound_id`, `series.sound_id` — nullable text, synced like other fields, exported. One-off tasks have no series, so both carry it (an occurrence's `null` inherits its series', like `alerts`).
- `Settings.reminderSound` — **kept**, now the default normal-tier sound. It also takes `"system"` (the OS sound, a visible row in the Settings picker only). Existing users whose stored value is `null` get `"system"` written once by the settings migration, so they hear exactly what they hear today; new installs start at `null`, which resolves to `dot`.
- `Settings.startSoundId` — default `dot_alarm`. `Settings.doneSoundId` — default `done.swift`. `Settings.inAppSoundsEnabled` — default true.
- Routine dots (C2) carry their own `soundId` inside the routine's `items` JSON and copy it onto the occurrences they create (routines make occurrences, not series). Saving a selection as a routine copies each task's own `soundId` back.
- Storage shape (device CHECK, server CHECK, import validator): null or 1–64 of `[a-z0-9._]`. Only the shape: an id this version doesn't ship is kept and resolved on read. A sound id never builds a file path; files come only from the catalogue.

**Resolution** for a normal-tier reminder, first non-null wins:

`alert.sound → occurrence.soundId → series.soundId → settings.reminderSound → "dot"`

- `"none"` at any level stops the chain: silent.
- `"system"` is only valid in settings; anywhere else it counts as an unknown id.
- An unknown id (a newer device's, or a sound later dropped) resolves to its category's default; it never crashes and never silences.
- Changing the default later changes every task that inherits it.
- The alarm-loud tier ignores the chain and plays `settings.startSoundId` (D2).

Tests (phase 2): resolve(null, null, null, null) → `dot`; `"none"` at each level → silent; an explicit id beats inherit; `"system"` only valid in settings; `resolveSound(unknown)` never throws and never returns null (property test).

## 4. Platform rules — **new**

**iOS / macOS.** Each sound is a `.caf` (IMA4 ADPCM, mono, 44.1 kHz, ≤ 30 s). The gateway sets the notification's sound to the file name. Time-sensitive level (A0) and custom sounds combine. The existing `Library/Sounds` install step stays and is extended (or `tool/xcode_add_sounds.rb` adds `Runner/Sounds` to the iOS and macOS targets); it is never removed *(owner)*.

**Android 8+.** Sound belongs to the **channel**, not the notification. Therefore:
- One channel per (tier, sound) for the new sounds: `dottoday.alert.<soundId>` for the 28 new normal-tier sounds (Quiet 5 + Clear 15 + Playful 8, after the ear pass), `dottoday.alarm.<soundId>` for the 9 new Start sounds, and `dottoday.alert.none` for "None" (shows and vibrates, no sound): **38 new channels**, created idempotently at start (names/descriptions are localised). `dot_alarm` keeps the legacy `alarms` channel; Done sounds never notify, so they have none.
- **Legacy channels are never deleted *(owner)*:** `alerts`, `alarms`, `summary` and `alerts_<dot|chime|bell|ripple>` keep serving the existing tones. Mixed naming is fine. In total the app owns 45 channels: the 38 new ones, `alerts`, `alarms`, `summary` and the four `alerts_<tone>`.
- Channel ids are **permanent**. Removing a sound keeps its channel id mapped to the category default forever; renaming a sound never changes its id.
- Channel groups: "Dot reminders" (`alerts`, `alerts_*`, `dottoday.alert.*`) and "Start of day" (`alarms`, `dottoday.alarm.*`); `summary` stays outside them.
- The Notification health panel's sound row counts only sounds in use: the default task sound, the Start sound and every pending reminder's. A channel counts as muted below Android's default (sound-making) importance.
- Files are AAC `.m4a` in `res/raw` (like the existing `dot_alarm.m4a`), not `.ogg`: the build machine's ffmpeg has no libvorbis, and Opus in Ogg needs Android 10 (minSdk is 26). `res/raw/keep.xml` keeps every category prefix through resource shrinking.
- The user may mute a channel in OS settings; the Notification health panel (A0) must report "the sound for *Lift* is muted in system settings" rather than falling silent.
- Looping is not a notification feature on either OS, so `start.insistent` is built as a looped 18.3 s file (§2).

**Web.** Previews, the in-app reminder strip and the Done sound play `assets/sounds/<file>.m4a`.

## 5. Manifest — `assets/sounds/manifest.json`

```json
{
  "version": 1,
  "sources": {
    "dottoday": { "name": "Dottoday", "license": "first-party", "modified": false, "credit": false },
    "notificationsounds": { "name": "notificationsounds.com", "url": "https://notificationsounds.com",
      "license": "CC-BY-4.0", "modified": true, "credit": true, "notice": "Notification sounds from …" }
  },
  "sounds": [
    { "id": "dot", "category": "dottoday", "name": "Dot", "file": "reminder_dot",
      "source": "dottoday", "license": "first-party", "modified": false, "durationMs": 900 },
    { "id": "quiet.slip", "category": "quiet", "name": "Slip", "file": "quiet_slip",
      "source": "notificationsounds", "sourceTitle": "Slick",
      "sourceUrl": "https://notificationsounds.com/soft-subtle-ringtones/slick-notification",
      "fileUrl": "https://notificationsounds.com/storage/sounds/file-sounds-1329-slick.ogg",
      "license": "CC-BY-4.0", "modified": true, "durationMs": 347 }
  ]
}
```

Rules:
- `file` is the base name. For each third-party entry, `tool/sounds/build.py` writes `android/app/src/main/res/raw/<file>.m4a`, `ios/Runner/Sounds/<file>.caf` and `assets/sounds/<file>.m4a`. First-party files come from `tool/gen_sounds.dart` and are never rebuilt.
- `fileUrl` is written once by `tool/sounds/fetch.py`. It reads the page's schema.org AudioObject and checks the title and licence against the manifest.
- `durationMs` is written by the build.
- `name` is the l10n key fallback; display names live in ARB (`sound_quiet_slip`).
- Processing, by `build.py` from `originals/` and never by hand:
  - trim leading/trailing silence (70 dB below the loudest 10 ms) with a 20 ms tail fade
  - downmix to mono at 44.1 kHz
  - cap at 20 s with a 1 s fade
  - level per category *(owner)*. Targets: Quiet −20 LUFS; Clear, Playful and Done −16; Start −14. Consistency within a category matters more than a global figure, since the OS sets the absolute volume.
    - Stage 1: linear gain towards the target.
    - Stage 2: a true-peak limiter (`alimiter`, 4× oversampled, −1 dBTP, attack 5 ms, release 50 ms). It may absorb at most 6 dB, because past that a short sound turns into a click.
    - A sound still more than 4 LU under its target is not pushed further. It goes on the build's "quiet outliers" list for the ear pass, with no loop and no noise-floor lift.
  - write the measured `loudnessLufs` and `truePeakDbtp` into the manifest. The policy test asserts every third-party sound is within ±3 LU of its category target, so a sound 3–4 LU under fails the test without being listed as an outlier.
  - **ear pass, 2026-10-28** *(owner)*: all 10 sounds outside ±3 LU are kept as built. These are `quiet.slip`, `quiet.whisper`, `quiet.soft`, `quiet.pull`, `clear.turn`, `clear.involved`, `clear.appear`, `start.swing`, `play.drum` and `done.checked`. Each carries `loudnessAccepted: true`, which the policy test accepts only while the sound is still outside the spread. Any new outlier needs the same explicit decision. No other swaps.
  - first-party tones are measured, never changed: Dot −18.7, Chime −16.5, Bell −19.5, Ripple −17.7, `dot_alarm` −13.9 LUFS.

## 6. Picker UI (Concept A) *(owner layout)*

- **Settings › Reminders › Sounds** (the default normal-tier sound): System sound · None · Dottoday · Quiet · Clear · Playful, then **Start sound** and **Done sound** as separate rows opening their own lists (Start: Dot alarm, then §2.3). Each row: name, play-on-tap preview, check mark. Footer caption = the credit line from §1.
- **Task sheet › Sound** row: Default (shows the resolved name, "Default · Dot") · None · Dottoday · Quiet · Clear · Playful. No System sound, Start or Done here (D2, D4).
- Preview plays through the media channel and honours the mute switch; when muted, show the banner "Your device is muted — you may still get vibration" (no exclamation mark). **Platform exception** *(phase 4)*: only Android can read the ringer (silent or vibrate). iOS has no public API for the ring/silent switch, and a Mac has none, so there the banner never shows. Previews still obey the switch, because they play as system sounds.
- *(phase 4)* The task picker is full height, with Done pinned under the scrolling list. For a repeating task it asks "this one or all", as Alerts does: "all" puts the sound on the series and later instances inherit it.
- *(phase 4)* The Done sound plays after a Done is written (the task sheet, timeline, keyboard and Focus), never after undoing one. Both the Done sound and Focus's tick follow **Sounds in app**; previews always play. The test alarm rings with the Start sound.
- Large text: past 130 % a row's value or fix button moves under its title instead of squeezing it.
- Everything through `AppLocalizations`; EdgeInsetsDirectional only.

## 7. Gates

- **Ear pass** before the branch opens: owner listens to every candidate on a phone speaker at arm's length; swaps noted in the manifest commit message.
- Policy test (`test/policy/sounds_manifest_test.dart`): every sound file in `assets/sounds/`, `res/raw/` and `ios/Runner/Sounds/` has a manifest entry; every third-party entry has `sourceUrl`, `fileUrl` and a `license` in `{CC0-1.0, CC-BY-4.0}` and is built for all three targets; every modified CC BY source has a notice that says so and is in `CREDITS.md`; ids, names and file contents are unique (D9); durations ≤ 30 s; `keep.xml` keeps every category. Phase 4 adds: the credit footer string contains every credited `sources.*.name`.
- Property test: `resolveSound(unknownId)` never throws and never returns `null`.
- Integration test on both simulators: a dot with `soundId = clear.lift` fires on the `dottoday.alert.clear.lift` channel (Android, read from the delivered notification) / is requested with `clear_lift.caf` (iOS can't report a delivered notification's sound, so the iOS test checks the built request and says so in its name); the first dot of the day fires with `settings.startSoundId` regardless of the task's sound.
- Golden: Sounds screen with 0, 1 and 3 muted channels (health panel copy), light/dark, largest text scale.
- No-shame audit: no string in the Sounds feature contains "annoying", "late", "missed", "failed", "error".

## 8. Milestone placement

M6.5 is closed. Sounds is its own milestone in `09-implementation-plan.md` (phases: tooling → data → gateway → ui → docs, one PR each, branch `feat/sounds-<phase>`). It reuses A0's channel work. ADR-0014 records D2–D4 and the owner amendments.

## 9. Follow-ups

- **App size.** The catalogue adds about 7 MB: `.caf` for iOS/macOS, and `.m4a` stored twice, once as an Android raw resource and once as a Flutter asset. The Start files are the bulk (four 20 s files plus the 18 s loop). A 15 s Start cap would roughly halve it. Accepted for now (owner, 2026-10-28).
- **Golden order flake** found during the phase-1 gates: ilearncloud9/dottoday#18 (not a sounds issue).

