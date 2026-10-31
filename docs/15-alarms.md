# 15 · Alarms — a Start sound that rings through silent mode

Status: **stub** (owner, 2026-10-31). Not built; planned as the Alarms milestone in `09-implementation-plan.md`. Extends `11-standout-roadmap.md` §A0 (the alarm-loud tier) and `12-sounds.md` (the Start sounds). Nothing here changes the reminder engine until that milestone starts.

## 1. Why

A0's alarm-loud tier (the first dot of the day, routine starts) is a time-sensitive notification today: it plays once and obeys the silent switch. People who use Dottoday to start the day want it to ring like an alarm: through silent mode, repeating until stopped. The OS alarm paths now allow that without a clock app of our own.

## 2. Direction

- **iOS 26 and later: AlarmKit.** An AlarmKit alarm plays a sound from the **app bundle only**, so every Start-tier sound is authored for it (ADR-0015): a seamless 25–28 s loop with a crossfaded seam, IMA4 `.caf`, mono, 44.1 kHz, under 30 s, in the iOS Runner bundle (`tool/xcode_add_sounds.rb`; `test/policy/ios_bundled_sounds_test.dart`). The `Library/Sounds` copy stays for notifications.
- **Below iOS 26:** the A0 time-sensitive tier, unchanged. Settings › Reminders says "Alarms that ring through silent mode need iOS 26".
- **Android: a foreground service** that plays the Start sound on `USAGE_ALARM`, with the volume ramp done in code (the files carry a 10 s fade-in only where `12-sounds.md` §2.3 says so).
- **macOS and web:** no alarm path; the A0 tier stays. Recorded as an R-13 platform exception when the milestone starts.

## 3. Open questions (answered by the milestone, not here)

- Does AlarmKit repeat a custom `.caf` until stopped, or play it once? A real-device test records the answer before the milestone's design is fixed.
- Stop and snooze actions, and how they map to Done / Running late.
- Permission prompts (AlarmKit authorisation, Android full-screen intent and exact alarms) and where onboarding asks.
- Interaction with Focus modes and the Live Activity.

## 4. Not in scope

The sound catalogue itself (`12-sounds.md`), the per-task sound and the Done sound do not change.
