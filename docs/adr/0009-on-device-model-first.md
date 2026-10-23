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
