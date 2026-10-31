# ADR-0015 · Reminder sounds: a bundled catalogue, a per-task sound, a Start sound

Status: Accepted · Date: 2026-10-30 · Spec docs/12-sounds.md · Amends 11-standout-roadmap A0 ("no
per-task settings in v1"), docs/02 F6.6 · Built in M15 (PRs #19, #29, #32, #33)

## Context
F6.6 (M8.4d) shipped four first-party tones (Dot, Chime, Bell, Ripple, synthesised by
`tool/gen_sounds.dart`), one global `Settings.reminderSound` where null meant the OS sound, and the
`dot_alarm` chime for alarm-loud dots (A0). Users of planners like Structured expect many more
sounds and a sound per task. Android fixes a notification's sound per *channel*, so every sound
needs a channel; iOS takes a file name per notification. The owner's rule for the whole change:
**add to the existing sound system — nothing is removed or remapped, and nothing a current user
hears or configured changes on upgrade.**

## Decision
- **D1 · Bundled, never downloaded.** 48 sounds: the 4 first-party tones, `dot_alarm`, 37
  notification sounds and 6 Done sounds from notificationsounds.com (CC BY 4.0). Sources are CC0 or
  CC BY 4.0 only (D6). No Kenney UI sounds: nothing in the app had a clear use for them.
- **D2 · The alarm-loud tier always plays the Start sound** (`Settings.startSoundId`, default the
  existing `dot_alarm`), whatever the task's own sound. The per-task sound is for the normal tier
  only. This roughly halves the Android channel count and is explainable in one sentence.
- **D3 · Only the sound is per task.** The alert tier stays rule-based (A0), so A0's
  "no per-task settings in v1" is bent in its wording, not its intent.
- **D4 · One global Done sound** (`Settings.doneSoundId`, default `done.swift`).
- **A sound value has three states** (`series.sound_id`, `occurrences.sound_id`, and
  `Settings.reminderSound`): null = inherit, `"none"` = silent (shows and vibrates), or a sound id.
  `Settings.reminderSound` also takes `"system"` (the OS sound). The order is alert → occurrence →
  series → Settings → Dot. `"none"` stops the chain; `"system"` counts only in Settings. An unknown
  id (a newer device's) plays its category's default, never nothing. Storage checks only the shape
  (`^[a-z0-9._]{1,64}$`, device and server alike), so a newer catalogue survives sync.
- **Upgrade without change.** Schema v8 and Supabase `0009` write `"system"` into every profile
  whose `reminderSound` was null, because null meant the OS sound before and means Dot from here.
  A new install keeps null (Dot).
- **Channels.** Legacy `alerts`, `alarms`, `summary` and `alerts_<tone>` are never renamed or
  deleted. The new sounds post on `dottoday.alert.<id>` (28 normal) and `dottoday.alarm.<id>`
  (9 Start), and "None" on `dottoday.alert.none`: 38 new channels, 45 in all. They sit in two
  groups, "Dot reminders" and "Start of day". Ids are permanent.
- **Files.** One pipeline from `assets/sounds/manifest.json` (the provenance record):
  `tool/sounds/fetch.py` downloads and checks the source and licence; `tool/sounds/build.py`
  trims, mono 44.1 kHz, levels per category, and writes `.m4a` (Android raw resources and web
  assets) and IMA4 `.caf` (iOS/macOS, bundled by `tool/xcode_add_sounds.rb`).
  - Android uses AAC, not Ogg: the build's ffmpeg has no libvorbis, Opus-in-Ogg needs API 29, and
    `dot_alarm.m4a` already shipped that way.
  - Levelling: Quiet −20, Clear/Playful/Done −16, Start −14 LUFS, with one linear gain and a
    −1 dBTP limiter allowed to take off at most 6 dB. Sounds more than 3 LU off target stay only
    with the owner's ear-pass mark (`loudnessAccepted`).
- **Every Start-tier sound is authored to be AlarmKit-eligible** *(owner, 2026-10-31)*: in the
  iOS app bundle as IMA4 `.caf`, mono, 44.1 kHz, under 30 s; the long ones as seamless 25–28 s
  loops. The first-party tones get a bundle `.caf` too; the `Library/Sounds` copy stays. Ten CC0
  Start sounds (BigSoundBank, Freesound) join the catalogue: 58 sounds, 20 Start, 48 new
  channels. The alarm engine itself is the Alarms milestone (`docs/15-alarms.md`).
- **Credits.** One line per source on the Sounds page ("Sounds from notificationsounds.com (CC BY
  4.0)."), and the full notice in About › Licences. Both are generated from the manifest, so a new
  source can't ship uncredited.
- **UI.** Settings › Reminders › Sounds (System sound, None, Dottoday, Quiet, Clear, Playful; Start
  sound, Done sound, Sounds in app). Each task has a Sound row (Default · Dot, None, sections); a
  repeating task asks "this one or all", as Alerts does.
- **Platform exception (R-13):** the "your device is muted" banner shows on Android only. iOS has
  no public API for the ring/silent switch, and a Mac has none; previews still obey the switch.

## Consequences
- About 7 MB more app, mostly the Start sounds (`.caf` plus `.m4a` stored twice: Android raw and
  Flutter assets). A 15 s Start cap would roughly halve it (follow-up, M15).
- The policy tests guard the catalogue's rules:
  - every shipped file is in the manifest, with a source page and an allowed licence
  - no duplicate ids, names or file contents
  - per-category duration and loudness
  - every catalogue `.caf` is in both Apple bundles
  - the credits match the manifest
  - no Sounds string says "annoying" or "error"
- Device tests prove the channel on Android (from the delivered notification) and the requested
  file on iOS (iOS can't report a delivered notification's sound).
- Deploy order: Supabase `0009` must be on the hosted project before an app with schema v8 syncs,
  or a full requeue's `sound_id` is refused (it was applied 2026-10-30).
- Rejected:
  - Remapping the old tones' keys onto new sounds (it would change what users hear).
  - A channel per sound for the alarm tier tied to the task's sound (D2).
  - Deleting legacy channels (it would lose users' OS-level settings).
  - Runtime downloads (offline-first).
  - Ogg on Android (the toolchain above).
