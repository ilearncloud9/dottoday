# RD-0001 · One product identity, multiple native presentations

Status: **Accepted** by the owner 2026-11-03 (also records owner decision 2 of 2026-11-02) · Scope: branch `redesign/design-lab` only · Numbering: `RD-` keeps redesign ADRs apart from `docs/adr/`, which `main` keeps numbering.

## Context

ADR-0007 and `docs/10-ui-concept-a.md` §4 made Dottoday look the same on every platform. Only chrome could differ: bar shape, sheet handle, switch, chip radius, FAB, menu corners and shortcuts. Web was "the Mac layout at expanded width and the Android layout at compact". The owner's redesign brief asks for something else:
- a real iOS feel (P2);
- no phone UI stretched onto other platforms (§9);
- each platform's own conventions under one brand (§16).

The owner's 2026-11-03 decision states the principle, and `docs/redesign/references/platform-guidelines/premium-native-experience.md` details it.

## Decision

0. **Concept A is historical on this branch** (owner decision 2, 2026-11-02).
   - `docs/10-ui-concept-a.md` and ADR-0007 are reference material here, not binding.
   - The three concepts (A Refined Timeline, B Productivity Workspace, C Focus-First Planner) are all open.
   - The Dot design system and CustomPainters stay for now, to be reused, refactored or replaced once a direction is approved (decision 5).
   - Existing ADRs are never rewritten.
1. **One product identity, multiple native presentations.** Dottoday is recognisable on every platform through its name, voice, palette, signature visuals and content style. Each platform gets its own interface treatment where that improves native usability, familiarity, accessibility or quality.
2. **Shared feature meaning and business logic.**
   - One Flutter codebase (ADR-0001).
   - Domain, data, sync, scheduling, notifications, Wake Up, entitlements and routes are shared and keep their meaning.
   - Every platform has every feature in the same release (R-13).
   - Presentation adapts in the view layer only.
3. **Platform-appropriate presentation.** Navigation, controls, input, motion, Back/dismiss and layouts may differ by platform:
   - Layout follows **available width** (never `Platform.isX`).
   - Conventions follow the **target platform**.
   - Interaction details follow the **input** in use.
4. **No pixel-identical requirement.** Goldens are per platform. Acceptance is the same outcome for the same intention, judged per platform (guide §17, §21).
5. **Approval threshold.**
   - Ordinary platform adaptation is proposed freely and shown at design review.
   - Owner approval is needed for changes that materially affect brand identity, a core workflow or product behaviour (`DESIGN_PRINCIPLES.md` §4).
   - New dependencies, native targets, IDs, signing, pricing and backend stay must-ask.
6. **Precedence on this branch.** This decision supersedes conflicting earlier redesign instructions on `redesign/design-lab` only:
   - ADR-0007 decisions 3 and 6;
   - doc 10 §4;
   - `CLAUDE.md` §11 "differ only in chrome" / "Mac and web are the same layout";
   - doc 03 §6 "cupertino-style sheets on macOS".

   These documents are not edited, and they still govern `main`.

## Consequences

- Prompts B–H check this principle and the guide (`MASTER_PLAYBOOK.md`). Quality is tracked per platform in `PLATFORM_QUALITY_MATRIX.md`.
- Technical suggestions in the guide (folder layout, `Adaptive*` components, packages, platform views) are candidates. Each needs verification and, where it changes architecture or adds a dependency, its own ADR.
- More presentation code per platform: more goldens and more test configurations. That is a cost to weigh against duplication in Prompt E. Shared content widgets plus thin per-platform shells are preferred over per-platform copies of a screen.
- If the redesign merges to `main`, the superseded rules in `CLAUDE.md` §11, doc 10 §4 and ADR-0007 need a matching update on `main` through its own PR. This ADR would then move to `docs/adr/` with a regular number.

## Related

- Owner decision 2 is folded in as Decision 0 (owner, 2026-11-03), so there is no separate RD-0002 for it.
- `DESIGN_PRINCIPLES.md` §7 lists every conflict, K1–K13.
