# ADR-0009 · "Thinking" features run on-device first, cloud second, never auto-apply

Status: Accepted · Date: 2026-10-23 · Filed as 0009 (drafted as 0008, which is the workmanager ADR)

## Context
Break it down, brain-dump to thread, duration suggestions and Rebalance wording need a language model. Competitors route every request through their servers to a paid provider and recover the cost behind a subscription (Structured AI: Pro-only, OpenAI, no bring-your-own-key, no web). Our users are often neurodivergent and privacy-sensitive; our pricing principle is "core free forever".

## Decision
1. One `ThinkingService` interface (`breakDown`, `planFromText`, `suggestDuration`) with three backends, chosen at runtime in this order: **on-device** (Apple Foundation Models on iOS/macOS 26+; Gemini Nano via AICore on supported Android), **cloud** (our metered endpoint, Pro only, explicit opt-in), **user's own API key** (advanced setting, any OpenAI-compatible endpoint).
2. Where no backend is available the feature degrades to rules and history (saved breakdowns, median durations) rather than disappearing.
3. Every model output is a structured proposal rendered by the shared `ProposalSheet`; **nothing is written before the user taps Accept**. A test asserts this for each flow.
4. Prompts and outputs are stored locally only; nothing is used for training; cloud requests carry only the fields the feature needs.

## Consequences
- The on-device path makes Break it down free; the cloud path is a Pro cost we meter with a fair-use cap.
- Android devices without AICore get rules-only unless Pro + opt-in.
- A compliance line in Settings › Privacy explains the three paths in plain words.

## Implementation (docs/09 M10.1, 2026-10-25)
- One Dart `OnDeviceThinkingBackend` over a `ThinkingTransport` per platform: `dottoday/thinking` to Apple Foundation Models (iOS/macOS 26+, guided generation) and to Gemini Nano through ML Kit GenAI's Prompt API (`com.google.mlkit:genai-prompt`, AICore devices), Chrome's built-in Prompt API on the web. Same prompts, same validation (`ModelOutput`), so the four platforms answer alike (R-13).
- Rules path: saved breakdown per title, history medians (real lengths from B1 timestamps), an empty 3-step template, Quick Add's parser for pasted text.
- Cloud and own-key backends are an interface only (`RemoteThinkingBackend`) behind `ThinkingFlags.remoteBackends = false`; wiring one is a must-ask (CLAUDE.md §11).
- Local storage: saved breakdowns and the last 50 exchanges in `local_meta` (encrypted, not synced, not exported), clearable in Settings › Privacy.
- ML Kit brings Google's `transport-*` libraries for its own usage metrics; no prompt or answer is part of them. Recorded for the owner's privacy review (08 §6.1 C).
