# ADR-0014 · Dictation runs on the device's own recognizer, or the mic is not shown

Status: Accepted · Date: 2026-10-28 · Decided by the owner (D1, D2, D5, D6 — owner, 2026-10-28) · Extends ADR-0009

## Context
Brain dump (11 §B4) and a task's notes are where people pour out text, often on a phone and often
in a hurry; speaking is faster than typing. Every phone keyboard already has a dictation key, but
it is easy to miss, it does not split a dump into lines, and on some keyboards it sends audio to a
server. Our trust line is "data on your device" (00-vision); titles and notes are PII
(CLAUDE.md §4).

## Decision
1. **On-device only (D1).** Dictation uses each platform's own speech recognizer over a platform
   channel, with on-device recognition required:
   - iOS and macOS: `SFSpeechRecognizer(locale:)` with `supportsOnDeviceRecognition` true and
     `SFSpeechAudioBufferRecognitionRequest.requiresOnDeviceRecognition = true`, fed by an
     `AVAudioEngine` input tap. One file, `ios/Runner/SpeechBridge.swift`, compiled into both
     Runners (as `ThinkingBridge.swift`). On iOS the audio session is `.record`/`.measurement`
     while listening and deactivated on stop, so alarms and sounds are unaffected; listening
     stops on an interruption and when the app leaves the foreground.
   - Android: API 31+ only — `SpeechRecognizer.isOnDeviceRecognitionAvailable(context)` and
     `SpeechRecognizer.createOnDeviceSpeechRecognizer(context)`, partial results on. Below API 31
     the bridge answers `unavailable`; the default `createSpeechRecognizer` is never used, because
     the recognition service behind it may send audio to a server.
   - Web: the Web Speech API **only in its on-device mode**. Verified against MDN and Microsoft's
     Edge docs on 2026-10-29: `SpeechRecognition.available({langs: [tag], processLocally: true})`
     resolves to `available` / `downloading` / `downloadable` / `unavailable`; an instance with
     `processLocally = true` recognizes on the device only, and `start()` fails with
     `language-not-supported` when the language pack is missing (it does not fall back to a
     server). `SpeechRecognition.install({langs, processLocally: true})` fetches a pack. The API is
     experimental (Chrome and Edge; access is gated by the `on-device-speech-recognition`
     Permissions-Policy). The web transport feature-detects the static `available` method and the
     `processLocally` property; if either is missing — Safari, Firefox, older Chrome with only
     the server-backed `webkitSpeechRecognition` — the mic is unavailable. `downloadable` and
     `downloading` read as unavailable in v1: Dottoday does not trigger a language-pack download
     the user did not ask for. The probe runs only in Google Chrome and Microsoft Edge
     (`navigator.userAgentData.brands`): in a Chromium without Google's on-device speech
     component (CI's headless Chromium; likely Brave, Opera, plain Chromium) `available()` with
     `processLocally` crashed the whole tab (found on the M14 PR, 2026-10-29), so elsewhere the
     mic stays hidden without asking.
   Audio and transcripts never leave the device, are never stored (only the text the user keeps
   in the field is saved, as typed text is) and are never logged.
2. **Hidden where unavailable (D2).** The mic shows only where the current locale has an
   on-device recognizer. Elsewhere it is hidden and the keyboard's own dictation still works.
   This is an approved exception to R-13 (same features on all platforms), with a follow-up in
   docs/09 to revisit when the platform ships on-device speech.
3. **No new dependency.** Platform channels in the repo (`dottoday/speech` method channel,
   `dottoday/speech/events` event channel); the Android runtime permission is requested through
   the activity after an in-app rationale (ARB), not through `permission_handler`.
4. **Two modes, pure Dart (D6).** `domain/speech/dictation_text.dart` merges recognizer results
   into the field. Brain dump: a pause of `kDictationPause` (1.5 s) or the locale's command word
   (en "next", de "weiter", fr "suivant", es "siguiente", ARB) starts a new line. Notes: insert at
   the cursor only, like the keyboard mic.
5. **Permission copy (D5)**, translated in de/fr/es: Microphone — "Dottoday listens only while the
   mic button is on, to turn your words into text on this device." Speech recognition — "Your
   words are turned into text on this device. Nothing is sent to a server."

## Alternatives rejected
- `speech_to_text` package: a new dependency, and it uses the platform's default recognizer, which
  may stream audio to Google's or Apple's servers; no per-call on-device guarantee on Android.
- A cloud speech-to-text service: sends the user's words off the device (CLAUDE.md §11 must-ask)
  and costs money per minute.
- Showing the mic everywhere with a server fallback: breaks D1.

## Consequences
- Devices without on-device speech (older Android, Safari, Firefox, some locales) get no mic; the
  keyboard's dictation is the path there. Recorded as the D2 follow-up.
- `test/policy/speech_on_device_test.dart` keeps the bridges honest (Swift requires on-device,
  Kotlin creates only the on-device recognizer, the web sets `processLocally`, no network API in
  any bridge); `no_pii_in_logs` covers transcripts.
- Real recognition can't run in CI; it is an owner gate in docs/08 §6.1 E.
