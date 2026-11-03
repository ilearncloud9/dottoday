# Design principles — Dottoday redesign

**Status: APPROVED by the owner (2026-11-03).** Applies to branch `redesign/design-lab` only. ADR: `adr/RD-0001-one-identity-native-presentations.md` (accepted 2026-11-03). Labels: *Owner* = your decision; *Fact* = from the repo; *Rec* = Claude's proposal, not decided until you say so.

## 1. The principle

*Owner:*

> **Dottoday should feel like Dottoday on every platform, but it should never feel like an iPhone app ported to Android, or an Android app ported to iPhone.**

- **One product identity** and **one feature experience** come first.
- iOS, iPadOS, macOS, Android and web may have **genuinely different interface treatments** where that improves native usability, familiarity, accessibility or quality.
- **No pixel-identical screens** are required across platforms.
- **You don't need to approve each platform difference.** Claude proposes native adaptations freely and shows them at design review. Your approval is needed only when a change **materially affects brand identity, a core workflow or product behaviour** (§4).

## 2. What is shared and what adapts

| Shared on every platform (one meaning) | Adapts per platform (one presentation each) |
|---|---|
| Name, voice, brand palette, signature visuals (whatever the chosen concept defines) | Navigation shell: tab bar, Material navigation bar, rail, sidebar, toolbar, browser-aware nav |
| Every feature and what it does: domain models, business rules, sync, scheduling, notifications, Wake Up, entitlements | Controls: switches, pickers, dialogs, sheets, popovers, menus, context menus, text editing |
| Data, IDs, routes and deep-link destinations (`/day/:date` names the same day everywhere) | Typography mapping, density, control size, chrome icon metaphors |
| Copy vocabulary and the no-shame rule; success, error and empty-state meaning | Motion and transitions, haptics, Back/dismiss model, keyboard shortcuts, pointer/hover/focus |
| Accessibility commitment (WCAG 2.2 AA, 44 pt / 48 dp targets, text to 200 %, reduced motion, screen readers) | Window management, menu bar, drag and drop, sharing, file pickers, system integrations |
| Proposal rule, minimal mode, the overlap look, the must-keep list (`PRODUCT_BRIEF.md` §10) | Responsive composition by **available window width**, not device label |

The test: **the same intention reaches the same feature and the same outcome on every platform**, by a path that feels at home on each one. Tap counts may differ.

## 3. How adaptation is decided

Three separate questions, never one (guide §12.1):
1. **Operating environment** (iOS/iPadOS, macOS, Android, web) decides conventions and integrations.
2. **Available width** (compact / medium / expanded) decides composition.
3. **Input** (touch, pointer, keyboard, stylus) decides interaction details.

When identity and nativeness conflict, apply the guide's order (§1.3):
1. safety, correctness, accessibility, OS policy;
2. task completion and clarity;
3. native conventions;
4. brand expression;
5. pixel matching.

A platform convention may be overridden only for a clear user benefit that doesn't harm accessibility or core OS behaviour. Record the override in the concept or in `PLATFORM_RULES.md` (Step 9).

## 4. What needs owner approval

| Free to propose and show at review (no separate approval) | Needs owner approval |
|---|---|
| Different navigation shell per platform for the same destinations | Removing, merging or renaming a destination, feature or entry point (parity matrix) |
| Native controls, sheets, popovers, menus, context menus, pickers | Changing what a feature does, its defaults or its data |
| Platform transitions, haptics, Back/predictive Back, shortcuts, menu bar items | Changing the brand: name, app icon, palette strategy, signature visuals (the dot/thread or a concept's replacement), type family |
| Density, spacing, chrome icons per platform | Changing a core workflow's steps: Today → Add → Edit/reschedule → Complete → Change day → Reopen, capture, replan, Wake Up |
| Width-driven layouts (rail, list-detail, inspector, multi-pane) | New dependencies, native targets, packages (CLAUDE.md §10–§11 must-ask) |
| Using an adaptive Flutter widget that's already available | Free/Pro, pricing, IDs, signing, backend (owner decisions 6, 11) |

## 5. References and how to use them

- **Primary:** `references/platform-guidelines/premium-native-experience.md` (guide v1.0). It **evaluates** native appropriateness and quality.
- **Supplementary:** the device/browser matrix and Definition of Done in `MASTER_PLAYBOOK.md` (Steps 3 and 14), and the `apple-design` skill (Apple HIG). Where they disagree with the guide, the conflict is listed in §7 and not silently merged.
- **Creative exploration:** use design skills such as `frontend-design` and `ui-ux-pro-max` (where available) to generate and vary concepts. Their output is then checked against the guide. Third-party skill files are never modified.
- **Technical suggestions in the guide are candidates, not architecture.** Its folder layout (§12.3), `Adaptive*` component list (§12.4), widget table (§12.5), `shells/` folders and platform-view escape hatch each need technical verification against this repo, CLAUDE.md §2–§3 and the ADRs before adoption. A change of architecture or a new package still needs an ADR and the must-ask path.

## 6. What does not change

- One Flutter codebase (ADR-0001). No separate per-platform apps. Domain, data, sync, notifications and Wake Up code are shared, and presentation adapts in the view layer.
- Feature parity (R-13, owner decision 11): every platform gets every feature in the same release; only the presentation differs.
- The approved Product Brief and decisions 1–12 and Q1–Q9 stand. §7 shows where they meet this principle.

## 7. Conflicts found and proposed narrow updates

Each row says what conflicts, which rule wins on this branch, and the resolution. Only K1 edited a file (`CLAUDE.md` §11). K6 and K9 are recorded owner decisions, and every other source document is left untouched.

| # | Where | Conflict | Proposed resolution |
|---|---|---|---|
| K1 | `CLAUDE.md` §11 bullet 4: "Mac and web are the same layout at the same width; iPhone and Android differ only in the chrome listed in `10-ui-concept-a.md` §4" | Forbids genuinely different treatments; makes Mac and web identical | **Decided (owner, 2026-11-03): applied.** The redesign-branch note below is now the first bullet of `CLAUDE.md` §11. "Layout by width class, never `Platform.isX` for layout" is kept; it agrees with the guide |
| K2 | `CLAUDE.md` §11 bullets 1–3, 5–6 and "Must ask: changing the nav set/order" | Bind every widget to Concept A renders and one nav order | Already historical on this branch (owner decision 2). The same `CLAUDE.md` note covers it |
| K3 | `docs/10-ui-concept-a.md` §4: "Platform idioms that may differ (and only these)… Everything else… is identical"; "Web = the Mac layout at expanded width and the Android layout at compact" | Directly opposite to the principle | Superseded on this branch by RD-0001. Don't edit doc 10 (`main` still uses it) |
| K4 | ADR-0007 decisions 3 and 6: one nav icon set and order; "platform idioms differ only in chrome" | Same | RD-0001 supersedes them on this branch only. ADR-0007 is not rewritten |
| K5 | `docs/03-ux-spec.md` §6: "iOS/macOS use cupertino-style sheets" | Guide §5.1: Cupertino is not a macOS convention; Mac prefers popovers, inspectors, menus and attached sheets | Read on this branch as superseded by guide §5. No edit |
| K6 | Doc 10 §2.2: Inter bundled on every platform (*Fact:* `pubspec.yaml:76`, `dot_type.dart:55`) | Guide §10.3 recommends system typography for OS chrome | **Decided (owner, 2026-11-03): OS chrome uses system typography** (navigation bars, tab bars, menus, dialogs, system controls): Apple's system font on Apple platforms, Android system typography on Android, a browser-friendly system stack on web. Apple's San Francisco fonts are never bundled (guide §10.3). The brand/content typeface (Inter or a concept's own choice) is still shown per concept and fixed at Step 9 |
| K7 | `PRODUCT_BRIEF.md` §16 + doc 10 §2.1: no Material You wallpaper accent | Guide §6.2: "consider" dynamic colour | **No change.** The approved brief wins; the guide only says "consider". Recorded so Android concepts don't add it |
| K8 | `PRODUCT_BRIEF.md` P2/§16: "current iOS material/glass look" | Guide §3.2 and §20.7: don't fake Apple system materials with a generic blur and call it native | Not a product conflict, a feasibility one. *Fact:* the app has no `BackdropFilter` today. Prompt B checks what Flutter can render, and whether a native view is needed. Concepts label glass as "approximated" or "native" |
| K9 | ADR-0013 + doc 10 §3: one icon set (`DotGlyph`) everywhere | Guide §10.6: SF Symbols on Apple, Material Symbols on Android for chrome | **Decided (owner, 2026-11-03):** task icons stay one library (ADR-0013; they are content and brand). Chrome/nav icons may follow the platform. That is a brand-level choice, so the concepts show it and Step 9 fixes it |
| K10 | `CLAUDE.md` §3 layout (`core/theme`, feature folders) and doc 10 §2 ("no second theme folder") | Guide §12.3 suggests `design_system/`, `shells/`, `integrations/` | CLAUDE.md wins. Prompt E proposes any change of structure as an ADR |
| K11 | `PRODUCT_BRIEF.md` §16 Q7: full iPad/Android-tablet layouts only for shortlisted concepts | Guide §19 Phase 2: prototype six shells | **No change.** Q7 governs concept depth (Prompt D). All six shells are needed by Prompt E/F for the chosen concept |
| K13 | `app/lib/core/theme/dot_idiom.dart`: `DotIdiom` has two values. `cupertino` is iPhone only; `material` covers Android, web **and Mac** ("Mac ≡ web, §4"); iPad shares iPhone's | The principle needs at least iOS/iPadOS, macOS, Android and web conventions, combined with width class and input | **Decided (owner, 2026-11-03):** Prompt B lists every reader of `DotIdiom` and `defaultTargetPlatform` (35 files) to size the change. Prompt E proposes the per-platform idiom set in the existing `DotIdiom` / `WidthClass` pattern, with no new package. No code changes before then |
| K12 | Playbook rule 7 + `CLAUDE.md` §11: never `Platform.isX` | Guide §12.1 uses `defaultTargetPlatform` for conventions | Compatible. Width decides layout; target platform (via `defaultTargetPlatform`/`kIsWeb`, already used in 35 files) decides idiom. The `CLAUDE.md` note says so |

**`CLAUDE.md` addition** (first bullet of §11, redesign branch only; applied 2026-11-03):

> - **On `redesign/design-lab` only:** `docs/redesign/DESIGN_PRINCIPLES.md` and ADR RD-0001 govern UI. Concept A, ADR-0007 and doc 10 §3–§4 are historical references there. Layout still adapts by width class, never `Platform.isX`; platform conventions (navigation shell, controls, motion, Back, menus) may differ by target platform. Material brand, workflow or behaviour changes still need owner approval.

No conflict was found with:
- CLAUDE.md §8 non-negotiables (it asks for feature parity, not pixel parity);
- the proposal, no-shame, minimal-mode or surface rules;
- the approved Q1–Q9 answers.
