# Flutter App Rebrand & Redesign — Master Playbook v3
## Claude Code + Claude Design | Git Worktree Edition

**Project:** An existing, feature-incomplete Flutter planning/productivity app  
**Targets:** iPhone, iPad, macOS, Android phones, Android tablets, and web (including narrow/mobile browser windows)  
**Primary implementation tool:** Claude Code  
**Visual exploration:** Claude Design, accessible from Claude and, when available in your Claude Code session, through `/design`  
**Version:** 3.0 — November 2026  
**Status:** Operating plan; not a statement that the repository has been inspected or changed.

> **The governing decision:** Keep the current working app intact in its original folder. Develop the redesign in a **separate Git worktree on a dedicated branch**. Investigate feature readiness and architecture first. Approve an actual visual concept before migrating production UI. Continue necessary feature/bug work in the original development flow and integrate it into the redesign deliberately.

---

# QUICK START — READ THIS BEFORE DOING ANYTHING

This is **not** a single prompt to run end-to-end. You are the product owner; Claude Code is your implementation and review partner. Complete one step, inspect its actual output, approve it, then continue. When the agent says “done,” require evidence rather than accepting a summary.

## Your first six actions

1. **Protect the original project.** Record Git status, back up uncommitted work safely, and confirm the app/build baseline. Do not add secrets to Git.
2. **Create a linked worktree** called `app-redesign` on branch `redesign/design-lab` (instructions in Step 1). If that branch already exists, use the alternative command; don't blindly run `-b` again.
3. **Put this document in the redesign worktree** at `docs/redesign/MASTER_PLAYBOOK.md`; optionally commit it on the redesign branch.
4. **Open the new folder**, not the original app folder, in your editor and start Claude Code there.
5. **Install the official Dart/Flutter Claude plugin** and set up a short root-level `CLAUDE.md` (Step 2).
6. **Run Prompt 0, then Prompt A.** First confirm safe setup; then audit unfinished features. **Do not start implementing the UI.**

## What success looks like

- A **single, recognizable product identity**, with different interaction patterns when appropriate.
- High-quality native-feeling **iPhone and Mac** experiences; proper Android conventions; browser-native usability.
- Real iPad/Android tablet support, not merely stretched phones.
- Three **meaningfully different** UX concepts, evaluated with real tasks and visual prototypes.
- Existing models, sync, persistence, notifications, scheduling, purchases/auth (where present), and user data remain intact unless explicitly approved for change.
- A codebase with reusable UI foundations and a safe, incremental migration strategy—not a giant one-shot rewrite.

## Rules that apply to EVERY phase

1. **Never edit the original worktree to implement the redesign.** Only work in the redesign worktree; changes to the original follow its own development process.
2. **Never silently delete, hide or degrade a feature.** Track existing, incomplete and planned capabilities separately.
3. **Do not touch live production databases, app-store releases, production secrets, paid services, or destructive migrations** without explicit approval and a safe test environment.
4. **Do not treat passing `flutter analyze` as visual acceptance.** Capture images on actual targets; compare them to approved prototypes and check interactions.
5. **Do not clone Structured.** Use it as a benchmark for clarity, care, rhythm and interaction polish, not its iconography, art, brand, or distinctive visual assets.
6. **Do not let the old `Dot*` component names or geometry dictate the new look.** Keep the existing system as a reference and refactor/reuse it only when useful.
7. **Respect available viewport and input method**, not only OS name. A narrow Mac window may use compact navigation; a wide Android tablet may use multi-pane navigation.
8. **Ask for product decisions instead of making up missing requirements.** Reversible technical details may be decided by the agent; irreversible product/data decisions need approval.
9. **Keep progress in files** so you can restart Claude Code sessions without losing context.
10. **Do not merge until the feature-parity, quality and platform checklists are satisfied.**
11. **One identity, native presentations** (owner, 2026-11-03): "Dottoday should feel like Dottoday on every platform, but it should never feel like an iPhone app ported to Android, or an Android app ported to iPhone." Prompts B, C, D, E, F and H read `docs/redesign/DESIGN_PRINCIPLES.md` and `docs/redesign/references/platform-guidelines/premium-native-experience.md`, and report per platform in `PLATFORM_QUALITY_MATRIX.md`. Pixel-identical screens are not required. Ordinary platform adaptations are proposed and shown without separate approval. Brand, core-workflow and behaviour changes need approval (`DESIGN_PRINCIPLES.md` §4). The guide's package/widget/folder suggestions are candidates to verify, not mandates.

---

# PART I — SET UP TWO SAFE WORKING COPIES

## Step 1 — Back up, verify, and create the Git worktree

**You do this in a terminal from your EXISTING Flutter app directory.** A Git worktree is not a second independent repository: it shares the underlying Git history while giving each checked-out branch its own working directory. You can maintain the old app and redesign separately.

### 1.1 Inspect and protect the original

```bash
pwd
git status --short
git branch --show-current
git log -1 --oneline
git worktree list
```

- If `git status` shows changes: **review, commit or safely back them up first**. Do **not** run `git add .` blindly, and never commit `.env`, API keys, generated private credentials or user data.
- Record the original branch name; it may be `main`, `master`, `develop`, or something else. This playbook calls it **BASE_BRANCH**.
- Ensure there is a meaningful commit to branch from. A worktree only contains tracked/committed content from the selected commit; ignored/untracked files are not automatically copied.
- If you're not using Git yet, set up/back up the repository before using these commands.

### 1.2 Create the redesign worktree **if the branch does not already exist**

```bash
# From your EXISTING app directory:
git worktree add -b redesign/design-lab ../app-redesign HEAD

# Check the result:
git worktree list
cd ../app-redesign
git branch --show-current
```

If `redesign/design-lab` already exists and is **not** checked out in another worktree, use:

```bash
git worktree add ../app-redesign redesign/design-lab
```

If the target folder or branch is already in use, **stop and inspect `git worktree list`**. Do not delete folders or force checkout until you've verified what exists. The working folder name `app-redesign` is just an example—adapt it to your project.

### 1.3 Verify the worktree's baseline

```bash
flutter --version
flutter doctor -v
flutter pub get
flutter analyze
flutter test
```

Record any pre-existing errors in `docs/redesign/BASELINE.md` instead of casually fixing unrelated problems. Test commands can be narrowed if the project is large, but record what ran and what did not.

**Important:** worktrees isolate checked-out files, **not** production APIs, shared cloud services, signing accounts, databases or local emulator data. **Two builds with the same iOS bundle ID / Android application ID / macOS identity can replace each other when installed on the same device and may access the same stored app data.** First test on dedicated simulators/emulators and test accounts; if you need side-by-side installs, ask Claude to plan an explicit safe dev flavor/identifier and signing approach without changing production identities. Also isolate browser origins/storage and use staging services. Store necessary local configuration safely and use sandbox/test accounts and fixtures. Flutter caches and generated files may need initialization in the new folder.

**Exit gate:** Two working directories exist; the original remains untouched; the redesign is on the intended branch; baseline results and known exceptions are recorded.

---

## Step 2 — Configure Claude Code in the REDESIGN worktree

Install/use Claude Code according to Anthropic's official instructions. Open the **`app-redesign` directory**, then run `claude`.

### Official Flutter support (recommended)

```bash
claude plugin marketplace add flutter/agent-plugins
claude plugin install dart-flutter@dart-flutter
claude plugin marketplace list
```

Check Flutter's current instructions for plugin rules and MCP setup: https://docs.flutter.dev/ai/get-started . The plugin does **not** automatically place all Flutter-specific rules in your project `CLAUDE.md`; follow Flutter's guidance for the rules you need.

### Project-level instructions

Keep a **short** root `CLAUDE.md` with stable rules and link to this playbook. If one already exists, edit it carefully; do not overwrite unrelated project guidance. You can use Claude Code `/init` as a starting point and then review its edits.

Suggested content:

```markdown
# Claude Code — Flutter Redesign Worktree

This checkout is the redesign worktree, not the original app.
Read `docs/redesign/MASTER_PLAYBOOK.md` for phase instructions.

## Non-negotiables
- Work only on the current redesign branch/worktree.
- Preserve data models, scheduling, sync, notifications, auth, subscriptions and existing feature behavior.
- Never use production user data or alter a production service without explicit approval.
- Audit before rewriting. Do not start a later phase without owner approval.
- Keep `docs/redesign/STATUS.md` and `DECISIONS.md` updated.
- One recognizable brand across iPhone/iPad/macOS/Android phones/Android tablets/web.
- Native-feeling interactions on Apple platforms; Android and browser conventions elsewhere.
- Use viewport constraints and input capabilities for adaptation; no phone-stretched-to-desktop layouts.
- Present real screenshots and test evidence. Mark unverifiable checks as NOT VERIFIED.
- Prefer small, reviewable diffs and reversible changes; don't replace the full `Dot*` system all at once.

## Verification
Run relevant formatter, analyzer, automated tests and target-platform screenshot checks.
Record pre-existing failures separately from new regressions.
```

### Optional UI/UX skills

**My recommendation:** Start with the official Flutter plugin + Claude Design. Consider **one** extra UI/UX skill (such as UI UX Pro Max) only if the concepts are generic or design guidance is inconsistent.

**Dottoday (2026-11-03):** where available, use design skills such as `frontend-design` and `ui-ux-pro-max` for creative exploration (Prompts C, D, E). The native-experience guide then evaluates whether the result is native-appropriate and good enough, with `apple-design` as a supplementary HIG check. Never modify third-party skill files. It is optional; additional skills do not replace taste, visual review, real-device testing or UX judgment. Review any third-party skill's repository and script permissions before installation.

### Claude Design vs. Claude Code

- **Claude Code:** inspect repository, audit dependencies, build Flutter components, run apps/tests and implement the accepted UI.
- **Claude Design:** generate and refine interactive visual mockups and compare concept directions before you build them in Flutter.
- Claude's current documentation describes `/design` within Claude Code. Use it if available in your session, or open a Design artifact in Claude. This is **not** a guarantee that an exported prototype becomes native Flutter automatically; verify handoff and implement properly in Flutter.
- `/design-sync` can be useful when a design system can be imported accurately. For this heavily custom-painted Flutter app, **don't assume** it can translate every Dart/CustomPainter component. Use screenshots, design tokens and design specifications as the fallback.

**Note on Claude Code's own worktree option:** Current Claude Code also supports creating worktrees itself. For this project use the **explicit Git worktree above** because its folder and branch are stable across sessions. Do not create a second, nested Claude worktree unless you intentionally need parallel isolated subtasks.

**Exit gate:** Claude Code is running in the right folder, knows the playbook, and has not changed production UI.

---

## Step 3 — Capture evidence of the CURRENT app

Put screenshots and short clips in `docs/redesign/references/baseline/`; do not add sensitive information or published-only assets inadvertently.

| Experience | Screens and behavior to capture |
|---|---|
| **iPhone** | Today/timeline, add/edit task, dense/empty day, navigation, Settings, keyboard-open, light/dark (if supported) |
| **iPad** | Portrait + landscape, compact/resized and expanded layout, panels, multitasking where supported |
| **Mac** | Wide + narrow resizable window, sidebar, task inspector, menus/context menu, shortcuts, Settings |
| **Android phone** | Today, editor, navigation, system back, insets, keyboard, light/dark |
| **Android tablet** | Portrait + landscape, medium and wide layouts, external keyboard/pointer if applicable |
| **Web** | Wide desktop browser and narrow/mobile browser, URL/Back/Forward/refresh, keyboard/hover/scroll |

Capture a busy day with many tasks, an empty day, a long task title, a task being completed, and at least one failure/loading state where relevant. If a real device isn't available, use a simulator/emulator and label the evidence clearly. Separate *visually designed* from *actually tested*.

**Exit gate:** A set of baseline screenshots and five principal flows exist or missing evidence is explicitly documented.

---

## Step 4 — Write the PRODUCT BRIEF and FEATURE INTENT

Create `docs/redesign/PRODUCT_BRIEF.md` using this template. Complete it as the product owner; let Claude suggest wording but **do not let it invent your roadmap**.

```markdown
# Product Brief
Product/working name:
Who is it for:
The three most important user jobs:
What users should feel (3–5 words):
What the current app does well:
What feels unpolished or frustrating:
Things I like about Structured (principles, not copies):
Things I do NOT want the app to feel like:
Absolute must-keep features:
Known incomplete features:
Features planned with confidence:
Ideas I am still unsure about:
Core workflows that must become effortless:
Potential navigation changes I would consider:
Approach to branding/name/icon (retain, refresh, or rename):
Apple-native details I care most about:
Android behavior I care most about:
Web behavior I care most about:
Platforms I personally use/test most:
Accessibility expectations:
Non-negotiable privacy/security constraints:
```

**Exit gate:** You can explain the intended product and its priorities in one or two pages, including incomplete features.

---

# PART II — FEATURE READINESS BEFORE VISUAL DESIGN

## Step 5 — Run PROMPT A: Feature-readiness and product-dependency audit

> **Reason:** Your app is not completely feature-finished. This phase prevents building beautiful screens around an incomplete or incorrect product structure.

**Copy into Claude Code:**

```text
PROMPT A — FEATURE READINESS AUDIT

You are reviewing an EXISTING Flutter planning/productivity app in a dedicated redesign Git worktree.
Read docs/redesign/MASTER_PLAYBOOK.md and PRODUCT_BRIEF.md first.

AUDIT ONLY. Do not edit production features, navigation or UI.

1. Inventory implemented features and core task workflows from repository evidence.
2. Classify each as: working, partially implemented, buggy/unstable, experimental, documented-planned, or owner-decision-required.
3. Distinguish code evidence from intent; never invent planned features.
4. Identify future features that would materially change Today, timeline, task editor, navigation, calendar, settings, onboarding or subscriptions.
5. Identify fragile domain dependencies: task IDs, recurrence, persistence, notifications, sync, authentication, purchases/subscriptions and migrations, where present.
6. Recommend: (a) stabilize before UI migration, (b) design now/build later, (c) complete after selected design system, (d) omit from redesign until owner decides.
7. Flag existing test failures, missing tests, dangerous shared-service assumptions and data-loss risks.

Write:
- docs/redesign/FEATURE_READINESS.md
- docs/redesign/FEATURE_PARITY_MATRIX.md
- docs/redesign/OPEN_PRODUCT_DECISIONS.md

For every finding, cite relevant repository paths and distinguish verified from inferred.
Summarize your top decisions for me. STOP; do not begin Prompt B.
```

### Your review

Resolve only the most consequential product choices now: What must always remain? Which feature will alter the navigation or data model? Which partly working features are too unstable to migrate? Mark unknown ideas as **future/undecided**, not guaranteed launch features.

**Exit gate:** The complete feature scope is understood; significant UX-affecting roadmap items are identified; you have authorized the next audit.

---

## Step 6 — Run PROMPT B: Architecture + UX audit

Your previous code inspection reported a heavily custom-built UI: roughly 110 handwritten components, dozens in `shared/dot`, 16 `CustomPainter` subclasses, `DotTheme`/`DotColors`/`DotType`/`DotSpace`/`DotRadii`/`DotMotion`/`DotGlyphs`/`DotIcon`, plus custom navigation (`DotRail`, `PillTabBar`, `MaterialBarShell`) and custom sheet behavior. **Treat these as reported leads to verify, not guaranteed facts.**

**Copy into Claude Code:**

```text
PROMPT B — FLUTTER ARCHITECTURE + UX AUDIT

Read the playbook, Product Brief, Feature Readiness and Feature Parity Matrix.
AUDIT ONLY — no production UI implementation.

Map actual routes/screens, menus, settings, task capture/edit/complete flows and shared components.
Inspect all custom-painted UI (CustomPainter, CustomPaint, gestures/hit testing,
semantics, scroll/drag behavior, sizes, animation, text metrics and performance).

Verify whether DotTheme, DotColors, DotType, DotSpace, DotRadii, DotMotion,
DotGlyphs, DotIcon, DotRail, PillTabBar, MaterialBarShell and custom sheets exist
and how they connect. Do not assume all prior descriptions are accurate.

Evaluate usability: clarity, navigation depth, unnecessary taps,
information hierarchy, settings discoverability, empty/dense states,
quick task creation, editing, keyboard access, accessibility and visual rhythm.

Evaluate adaptive behavior across iPhone, iPad, Mac, Android phone/tablet,
and web. Check reported width bands around 600 and 840 logical px but do not
assume they are correct or sufficient. Test edge widths and text scaling.

Separate reusable domain behavior from replaceable visual presentation.
Propose an isolated Design Lab that cannot mutate production state.

Read DESIGN_PRINCIPLES.md and the native-experience guide
(references/platform-guidelines/premium-native-experience.md). Audit each
platform against the guide's five layers (§1.2) and its per-platform
checklists (§3.5, §4.4, §5.4, §6.4, §7.3, §8.5). Record where the current
app feels ported from another platform. List every reader of DotIdiom
(core/theme/dot_idiom.dart; today only cupertino vs material, with Mac on
material) and of defaultTargetPlatform/kIsWeb, to size the per-platform
idiom work for Prompt E (DESIGN_PRINCIPLES.md K13). Fill the "Baseline" column of
PLATFORM_QUALITY_MATRIX.md with evidence or NOT VERIFIED. Treat the
guide's package/widget suggestions as candidates to verify against this repo.

Deliver:
- docs/redesign/ARCHITECTURE_AUDIT.md
- docs/redesign/UX_AUDIT.md
- docs/redesign/PLATFORM_BASELINE.md
- docs/redesign/REUSE_VS_REPLACE.md
- docs/redesign/DESIGN_LAB_PLAN.md

Identify real issues, evidence, risks and quick wins, but DO NOT change UI code.
STOP for my review.
```

### Your review

Pay attention to whether all proposed UX complaints are actually supported by screenshots or observations. For the reported wide-screen layout (rail + 300px Inbox + three-day view + task editor): **check if these panes fit comfortably just over 840 logical px**. Don't allow a brittle breakpoint to define the redesign.

**Exit gate:** You agree with the current problem statement and know what can be reused without compromising the new visual identity.

---

# PART III — THE NEW PRODUCT EXPERIENCE (BEFORE FLUTTER REWRITES)

## Step 7 — Run PROMPT C: Three genuine information architectures

**Copy into Claude Code (planning/documentation only):**

```text
PROMPT C — INFORMATION ARCHITECTURE OPTIONS

Using the verified Feature Readiness, Feature Parity, Architecture and UX audits:

Produce three DISTINCT product/navigation proposals:

A. Refined Timeline: recognizable timeline-first approach, much better polish,
menus, task editing and navigation.
B. Productivity Workspace: a different information architecture; Today,
Inbox, calendar and other REAL existing/planned views arranged around task flows.
C. Focus-First: radically new entry point centered on current priorities and
attention, with timeline/calendar accessible without losing capabilities.

For each proposal describe:
- primary and secondary navigation for phones, tablets, Mac and web
- Today, task capture/edit/complete, scheduling and calendar flows
- settings organization and where common actions live
- layout at compact, medium and wide available widths
- native iPhone and Mac interaction details; Android system/back behavior;
  browser URLs/Back/Forward and pointer/keyboard support
- how already-planned but not-yet-built features fit without pretending
  they already work
- existing feature parity and steps/taps for key journeys
- accessibility, usability risks, implementation complexity and tradeoffs

Use realistic examples from this product. Do not simply recolor the same layout.

Apply DESIGN_PRINCIPLES.md and the native-experience guide: for each concept,
state what stays identical (identity, feature meaning, routes) and how each
platform presents it (shell, controls, Back, input, motion), using the guide's
§9 matrix. Mark every change that needs owner approval (brand, core workflow,
behaviour) separately from ordinary platform adaptation.
Write docs/redesign/THREE_UX_CONCEPTS.md and a comparison matrix.
No production UI changes. STOP for review.
```

### Acceptance exercise

Compare each design for six real tasks: capture task rapidly; plan a busy day; edit/reschedule; navigate to another day; find Settings; use the app in a narrow/wide desktop window. Make Claude identify the downside of **each** concept. A concept that is attractive but obscures core planning functionality should not win.

**Exit gate:** All three are genuinely distinct and complete enough to prototype.

---

## Step 8 — Run PROMPT D: Claude Design visual prototypes

**This is design exploration, not final production Flutter development.** Claude Design can be used from an available Design surface in Claude or through `/design` in Claude Code. Provide the audits, brief, screenshots and concept definitions as inputs. If it cannot directly read repository docs, supply the relevant files or summaries.

**Copy into Claude Design / Claude Code with `/design` when available:**

```text
PROMPT D — HIGH-FIDELITY CONCEPT EXPLORATION

Design three high-fidelity, visually distinctive experiences for my existing
cross-platform Flutter planning app. Use PRODUCT_BRIEF.md, THREE_UX_CONCEPTS.md,
FEATURE_PARITY_MATRIX.md, baseline screenshots and the architecture audit.

Concept A: Refined Timeline — minimal structural disruption, major polish.
Concept B: Productivity Workspace — major navigation and layout restructure.
Concept C: Focus-First — radical home experience with timeline available.

For EACH concept show, at minimum:
1. iPhone compact main view
2. macOS desktop main view
3. Android phone main view
4. web desktop main view
= 12 primary concept/platform previews.

Also show navigation/settings and task creation/editing treatment for each
concept, and a responsive behavior map. Shortlisted concepts must include iPad
and Android-tablet layouts and Mac/web narrow-window states.

All concepts share the product's functional meaning but may vary visually
and structurally. Give each a coherent typography, spacing, icon and motion
language. Do not merely generate three color schemes. Use synthetic realistic
planning data, including dense and empty states. Do not copy Structured assets.

Label design-only interactions versus implemented Flutter behavior. For each
concept provide strengths, problems, accessibility concerns, and engineering
tradeoffs. Keep prototypes editable/iterable and export screenshots/specs.

Follow DESIGN_PRINCIPLES.md: iPhone, Mac, Android and web previews of one
concept must be recognisably the same product but must not be the same
screen re-skinned. Show each platform's native shell and controls. Label
effects Flutter may not render natively (e.g. Apple glass) as "approximated"
or "native view needed". Score each preview with the guide's §21 scorecard,
per platform.

Do not rewrite the production Flutter app. Wait for my design decisions.
```

### How to review the concepts

Score each (1–5) on: task clarity, speed of key flows, aesthetic identity, native feel, tablet/desktop use, accessibility, and implementation risk. If beneficial, mix Concept C's Today with Concept A's timeline and Concept B's Mac navigation—but then request a **single coherent fourth 'combined' preview**, not a mashup of inconsistent styles.

**Warning:** Claude Design prototypes may be HTML/canvas-based or otherwise non-Flutter. That is fine for exploration. **Do not equate the preview with a production-ready Flutter implementation.**

**Exit gate:** You have approved a visual/interaction direction after comparing actual screenshots and flows.

---

## Step 9 — Freeze design decisions (not future product development)

Create `docs/redesign/DESIGN_DECISIONS.md`, `APPROVED_UX_FLOWS.md` and `PLATFORM_RULES.md` with:

- Chosen concept or coherent combination and *why*.
- Approved Today, task editor, calendar, navigation and Settings layouts.
- Shared brand: tone, typography, icons, colors, density, spacing, motion, illustration style and accessibility standards.
- Platform-specific shells/controls and input behavior.
- Viewport adaptation, especially near existing or proposed breakpoints.
- Accepted tradeoffs, deferred polish, incomplete features and future expansion slots.
- Links/exports/screenshots of approved design versions.
- UX regression scenarios and acceptance criteria.

**Exit gate:** A developer could implement the design without inventing its central navigation or visual identity.

---

# PART IV — BUILD THE SELECTED DESIGN SAFELY

## Step 10 — Run PROMPT E: A versioned Flutter design system + adaptive shell

**Copy into Claude Code:**

```text
PROMPT E — IMPLEMENT FOUNDATIONS, NOT ALL SCREENS

Read MASTER_PLAYBOOK.md and all approved design documents.
Implement the NEW approved Flutter design foundations in the redesign worktree.

- Reusable design tokens: colors, semantic surfaces, typography, spacing,
  radii, iconography, elevations, motion, focus and accessibility.
- Components: task rows/cards, timeline markers as approved, buttons,
  inputs, menus, navigation items, empty/error/loading states and sheets.
- Adaptive shells: iPhone, iPad, Mac, Android phones/tablets and web.
- Native-feeling behavior for iPhone/macOS while preserving the shared brand;
  Android gestures/back; web URL and keyboard/pointer expectations.
- Responsive logic based on actual available constraints; verify medium-width
  and split-screen behavior; don't blindly reproduce reported 600/840 cutoffs.
- Keep existing domain state, persistence and business logic intact.
- Follow DESIGN_PRINCIPLES.md and the guide's §10–§12: semantic tokens with
  platform mappings; shared content widgets with per-platform shells and
  controls where the interaction contract differs; layout by available
  width, conventions by target platform, details by input. No per-platform
  copies of business logic, no six codebases. Verify any suggested package,
  folder layout or platform view first; propose an ADR before adopting one.

Use an isolated Design Lab / preview route or entrypoint with synthetic fixtures.
Reuse old Dot components only when consistent with approved decisions.
Do NOT globally replace DotTheme or migrate every screen at once.

Add component/gallery tests and screenshot evidence where tools permit.
Deliver DESIGN_SYSTEM.md, PLATFORM_RULES.md and a file-level change log.
STOP before migrating production screens.
```

**Exit gate:** New components exist, can be previewed on small/medium/wide targets, and have not changed core app behavior.

---

## Step 11 — Run PROMPT F: First complete production vertical slice

Implement **one full user journey**, not an isolated decorative screen:

**Today → Add task → Edit/reschedule → Complete → Change day → Reopen task.**

**Copy into Claude Code:**

```text
PROMPT F — FIRST PRODUCTION VERTICAL SLICE

Implement the approved Today + task workflow only, inside the redesign worktree.
Use the approved design system and platform rules.

Keep existing task models, IDs, persistence, sync, notifications, recurrence,
permissions and backend calls unchanged unless a change is essential and
explicitly approved. Preserve current behavior for partially implemented
features; do not claim they are complete.

Implement and visually validate on iPhone, Mac, Android and web;
verify iPad/Android-tablet widths and narrow desktop browser/window states.
Include empty, dense, loading, error, long-text and large-text cases.

Follow DESIGN_PRINCIPLES.md: same outcome on every platform, native path on
each. Check the journey against the guide's per-platform checklists and
§13 Back/dismiss rules; update PLATFORM_QUALITY_MATRIX.md for this slice.

Run formatting, analyzer and relevant widget/integration tests.
Capture actual screenshots; compare with the approved concept; iterate.
Record regressions, unresolved differences and untested targets honestly.
Do not migrate other screens until I approve this workflow.
```

**Exit gate:** You personally use this journey and prefer it to the old one; tests pass or differences are documented; data and feature parity are preserved.

---

## Step 12 — Migrate the rest of the app incrementally

Follow a repeatable migration order based on existing feature dependencies, for example:

1. Calendar/day/week/month views that exist.
2. Inbox, lists/projects, planning or focus views **only if actually present/approved**.
3. Search and navigation/context actions.
4. Settings and preferences (grouped by user mental model, not code modules).
5. Onboarding, account, notifications, subscription and accessibility screens, where present.
6. Empty, offline, error and permission states.
7. Deferred features that are now ready, built using the new design system.

**Per-screen loop:** review feature-parity mapping → implement → compare screenshots → test behavior → review keyboard/touch → check phone/tablet/desktop/browser → approve → commit.

### Reusable prompt for each migration slice

```text
PROMPT G — SINGLE FEATURE MIGRATION

Migrate only [FEATURE/SCREEN] to the approved new design system.
Read the parity matrix, approved design decisions and platform rules.
Preserve domain behavior and user data. Update relevant tests.
Demonstrate compact/medium/wide layouts, interaction states and screenshots.
List what changed, what did NOT change, and any regression risks.
Do not migrate adjacent features without approval. STOP for review.
```

**Exit gate:** Each production screen has been reviewed against old functionality and the accepted visual system. Unfinished features remain explicitly tracked.

---

# PART V — KEEP ORIGINAL FEATURE DEVELOPMENT AND REDESIGN IN SYNC

## Step 13 — Worktree integration discipline

Because the original app is unfinished, avoid leaving the redesign branch isolated for months.

**Branch ownership:**

- **Original/Base branch:** approved domain fixes, new core logic, backend fixes, notifications, sync and bug fixes that need to land in today's app.
- **`redesign/design-lab`:** redesign UX, themes, components, new shell, Design Lab and approved UI migrations.
- **Shared changes:** plan explicitly. Do not independently implement the same behavioral feature in both branches.

**Safe integration routine** (in the redesign worktree after finishing/committing its current work):

```bash
# Example: replace 'main' with your actual base branch.
cd ../app-redesign
git status --short
# Commit or safely save redesign edits before merging.
git fetch origin                # if your repository uses a remote
# Review the incoming changes first:
git log --oneline HEAD..main
# Then intentionally bring the base changes into the redesign branch:
git merge main
flutter pub get
flutter analyze
flutter test
```

If your base branch is `develop` or another name, replace `main` accordingly. If conflicts occur, review both implementations; don't let an agent choose a side indiscriminately. A rebase may be preferable in some workflows, but avoid casually rewriting published/shared history.

**Integration frequency:** after a meaningful group of feature changes or before beginning a major redesign migration—not necessarily every day. Record integration commits and conflict decisions in `docs/redesign/SYNC_LOG.md`.

**Crucial:** Git worktrees share Git history, **not** separate databases. Keep staging/sandbox environments, test users and signing configuration under conscious control.

**Exit gate:** No large silent divergence; new core functionality is reflected in the redesign's parity matrix and prototypes when necessary.

---

# PART VI — QUALITY, REBRANDING AND RELEASE

## Step 14 — Run PROMPT H: Dedicated UX, visual, accessibility and performance pass

**Copy into Claude Code:**

```text
PROMPT H — CROSS-PLATFORM POLISH + VERIFICATION

Audit the redesigned app against approved prototypes and baseline evidence.

Check visual hierarchy, typography, spacing, icon weight, contrast,
state feedback, sheets, gestures, navigation discoverability, settings,
keyboard/pointer focus, hover, semantics/screen readers, and motion settings.

Check iPhone, iPad, Mac, Android phone/tablet and web at compact/medium/wide
widths; include landscape/portrait and resized split-screen when possible.
Test long labels, large text, busy/empty days, dark mode, high latency,
loading/error states, reduced motion and constrained windows.

Profile actual rendering and scrolling on suitable devices; investigate
expensive painters, raster work, rebuilds and frame jank as supported by data.
Do not claim 60/120fps or native performance without measurements.

Capture before/after/target screenshots. Identify differences and fix them
in small changes, not a full restyle. Run analyzer and relevant tests.

Use DESIGN_PRINCIPLES.md and the guide as the acceptance standard: §17 device
matrix and golden journey, §18 P0/P1/P2 gates, §21 scorecard per platform
(no averaging away a weak platform). Per-platform goldens; never compare
iOS pixels to Android pixels. Complete PLATFORM_QUALITY_MATRIX.md.
Create docs/redesign/POLISH_QA_REPORT.md with PASS/FAIL/NOT VERIFIED.
STOP for approval.
```

### Device / browser acceptance matrix

| Target | Required manual visual + interaction checks |
|---|---|
| **iPhone** | safe areas, native-feeling transitions/sheets, haptics where supported, text scaling, VoiceOver, keyboard overlap, compact navigation |
| **iPad** | portrait/landscape, medium/wide layouts, resize/Stage Manager if applicable, multitasking, touch and keyboard, panel collapse |
| **Mac** | wide/narrow windows, menu bar, shortcuts, context menu, pointer/trackpad, selection/focus, system Settings expectations, VoiceOver |
| **Android phone** | system/gesture back, inset/keyboard behavior, Android conventions, TalkBack, touch and task flows |
| **Android tablet** | portrait/landscape, multi-pane layout, resize/split-screen, external keyboard/pointer where available, no overflows |
| **Web** | desktop + mobile browser, Back/Forward/deep link/refresh, zoom, scrolling, keyboard focus, pointer/hover, browser semantics |

**Practical layout probes (logical pixels, adjust to real designs):** 320, 390, 599, 600, 700, 839, 840, 900, 1024, 1280 and 1440. Do not treat breakpoints as guaranteed device categories. Test unusual aspect ratios and high text scale too.

**Automated tests cannot replace device inspection.** Widget/golden tests are useful, but some native menus, OS interactions, font rendering, gestures and performance require actual target testing.

### Useful Flutter commands (only on supported hosts/toolchains)

```bash
dart format .            # Review formatting changes before committing
flutter analyze
flutter test
flutter build apk
flutter build web
# On a Mac configured with Xcode:
flutter build ios --no-codesign
flutter build macos
```

For visual/native performance work, use **profile or release** builds on suitable hardware rather than treating debug-frame performance as representative. Use real browsers for web QA; check a staging deployment when relevant.

**Exit gate:** All critical workflows passed with evidence on target platforms or explicit unresolved blockers. The app is at least as functional as before the redesign.

---

## Step 15 — Complete the new brand carefully

Only after the selected UI direction is stable, finalize:

- App name (if renaming), tagline, icon, launch/splash appearance and onboarding.
- Shared brand palette/type/icons and platform-specific rendering adaptations.
- App Store / Play Store / web marketing screenshots and legal/privacy text.
- Localization if needed; accessibility review and consistent error/permission language.
- Asset licensing and attribution; no copied distinctive artwork from Structured or other products.

**Do not casually change bundle identifiers, package names, signing identities, store listings, purchase/subscription identifiers, deep links or sync endpoints.** These can affect existing user upgrades and data continuity. If a change is necessary, demand a documented migration and rollback plan before making it.

---

## Step 16 — Merge safely and release in stages

1. Confirm all code and QA evidence are committed on `redesign/design-lab`.
2. Sync the base branch once more. Resolve conflicts and rerun regression tests.
3. Compare **complete feature parity**, including newly added features on the base branch.
4. Validate data migration and upgrade behavior on test accounts and non-production data.
5. Create a reviewable pull request to your actual release/base branch; inspect the entire diff and any removed assets/routes/settings.
6. Release to internal/closed test channels first (e.g. TestFlight, internal Android track, web staging, Mac internal build).
7. Verify app upgrade from an existing installed version, not only clean installs.
8. Roll out gradually with crash/error monitoring and rollback options; preserve compatible persistent data.
9. After successful rollout and retention of a recovery point, retire the redesign worktree **using Git**, not by casually deleting its folder.

Example cleanup **only after you know the worktree is no longer needed**:

```bash
# From the original working directory:
git worktree list
# First ensure all work is committed and safely merged or archived.
git worktree remove ../app-redesign
# Delete the branch only after it is fully merged and no longer needed:
# git branch -d redesign/design-lab
```

**Exit gate:** The released app has verified upgrade behavior and no unapproved loss of features or data.

---

# PART VII — HOW TO OPERATE CLAUDE CODE DAY TO DAY

## Step 17 — Use these repeatable session and review prompts

### PROMPT 0 — First session (run after setting up the worktree)

```text
We are in the dedicated redesign Git worktree for an existing Flutter app.

1. Read docs/redesign/MASTER_PLAYBOOK.md completely.
2. Inspect git branch/worktree status, CLAUDE.md and relevant project docs.
3. Verify you are NOT editing the original app worktree.
4. Summarize my supported experiences: iPhone, iPad, macOS, Android
   phones/tablets and web.
5. Explain the next task in the playbook and which files it may create.
6. Do NOT start implementing anything yet.

I will authorize one phase at a time. First report readiness and risks.
```

### Start a fresh session after completing a phase

```text
Read CLAUDE.md, docs/redesign/MASTER_PLAYBOOK.md, STATUS.md,
DECISIONS.md and all approved relevant deliverables.

Summarize: current branch and worktree, completed/approved phases,
outstanding product decisions, latest tests, currently unverified platforms,
and the single next phase. Do not alter production code yet.
```

### When a phase is finished (ask this every time)

```text
Provide a phase completion report:
- Files changed/created and why
- What is verified vs inferred vs NOT VERIFIED
- Before/after screenshots or prototype locations
- Commands/tests run and their actual results
- Feature-parity risks and platform-specific exceptions
- Unresolved questions or regressions
- Recommended next step

Update docs/redesign/STATUS.md, DECISIONS.md and the phase report.
Then STOP for my approval.
```

### When you dislike a design

```text
Do not implement more production screens.
Compare the current preview with the approved goals and my feedback.
Identify whether the problem is visual, navigation, interaction, density,
responsive layout or feature discoverability.
Offer 2–3 materially different solutions, render them, show tradeoffs,
and ask me to approve one before continuing.
```

### When the coding agent claims tablets/web are already handled

```text
Do not infer tablet/browser quality merely from breakpoint code or tests.
Show the actual layouts at edge widths and target environments.
Confirm iPad/Android-tablet portrait, landscape, resizing and input.
Confirm browser Back/Forward, refresh and direct URLs. Label any checks
not performed as NOT VERIFIED, and document a concrete test plan.
```

### When the base/original app gains a feature

```text
Audit the latest incoming base-branch changes before integrating.
Identify model/API/schema/UI implications, conflict risk and required
updates to the parity matrix and approved design flows.
Propose a merge plan and necessary tests. Do not overwrite redesign
screens or silently change the accepted design.
```

---

# PART VIII — FILE STRUCTURE AND RUNNING CHECKLIST

Use this suggested structure, adapting to your actual repository:

```text
app-original/                 # Existing working Flutter app folder
app-redesign/                 # Linked worktree, redesign/design-lab
  ├── lib/                   # Existing app + incremental approved UI
  │   └── design_lab/        # Isolated concepts/previews; actual structure may vary
  ├── CLAUDE.md              # Short persistent instructions
  ├── docs/redesign/
  │   ├── MASTER_PLAYBOOK.md
  │   ├── STATUS.md
  │   ├── DECISIONS.md
  │   ├── BASELINE.md
  │   ├── PRODUCT_BRIEF.md
  │   ├── DESIGN_PRINCIPLES.md
  │   ├── PLATFORM_QUALITY_MATRIX.md
  │   ├── adr/                # redesign-only ADRs (RD-xxxx)
  │   ├── FEATURE_READINESS.md
  │   ├── FEATURE_PARITY_MATRIX.md
  │   ├── OPEN_PRODUCT_DECISIONS.md
  │   ├── ARCHITECTURE_AUDIT.md
  │   ├── UX_AUDIT.md
  │   ├── PLATFORM_BASELINE.md
  │   ├── REUSE_VS_REPLACE.md
  │   ├── DESIGN_LAB_PLAN.md
  │   ├── THREE_UX_CONCEPTS.md
  │   ├── DESIGN_DECISIONS.md
  │   ├── APPROVED_UX_FLOWS.md
  │   ├── DESIGN_SYSTEM.md
  │   ├── PLATFORM_RULES.md
  │   ├── SYNC_LOG.md
  │   ├── POLISH_QA_REPORT.md
  │   └── references/
  │       ├── baseline/
  │       ├── inspiration/
  │       └── approved/
  └── test/
```

Folders and outputs in the plan do not all need to exist on Day 1. Each prompt creates only what it needs. Don't overload a short `CLAUDE.md` with the whole playbook.

## Phases and approval gates at a glance

| Step | Owner's action | Tool | Concrete deliverable | STOP until approved? |
|---|---|---|---|---|
| 1 | Protect work, create worktree | Terminal / Git | Isolated branch + baseline | Yes |
| 2 | Configure Claude Code | Claude Code | Plugin/rules/CLAUDE.md | Yes |
| 3 | Capture evidence | You + simulator/browser | Baseline images/clips | Yes |
| 4 | Define product intent | You + Claude | PRODUCT_BRIEF.md | Yes |
| 5 | Audit feature readiness | Claude Code, Prompt A | Feature readiness/parity | **Yes** |
| 6 | Audit architecture + UX | Claude Code, Prompt B | Evidence-based audits | **Yes** |
| 7 | Generate three UX models | Claude Code, Prompt C | Three UX concepts | **Yes** |
| 8 | Explore actual visuals | Claude Design, Prompt D | ≥12 primary previews + tablet states | **Yes** |
| 9 | Select and freeze UX design | You + Claude | Approved design decisions | **Yes** |
| 10 | Build design foundations | Claude Code, Prompt E | Design system/preview components | **Yes** |
| 11 | Build one real journey | Claude Code, Prompt F | Tested Today/task vertical slice | **Yes** |
| 12 | Migrate screens gradually | Claude Code, Prompt G | Reviewable slices | **Yes per slice** |
| 13 | Bring in base-app changes | Git + Claude Code | SYNC_LOG.md | Yes if conflicts |
| 14 | Polish and platform QA | Claude Code, Prompt H | Evidence and QA report | **Yes** |
| 15 | Brand rollout preparation | You + Claude | Approved branding/assets | Yes |
| 16 | Integrate and release | Git + test channels | Reviewed release + monitoring | **Yes** |
| 17 | Maintain session discipline | You + Claude | Up-to-date STATUS/DECISIONS | Every phase |

## Owner's design-review scorecard (optional)

Rate each candidate 1–5:
- Fast task capture and editing — **20%**
- Clarity of Today/timeline/scheduling — **20%**
- Visual identity and perceptual polish — **20%**
- Navigation consistency and feature discoverability — **15%**
- Quality on iPhone/iPad/Mac/Android/web — **15%**
- Accessibility and implementation risk — **10%**

Use scores to force tradeoff discussion—not as a substitute for your judgment. If one concept scores well but feels wrong, iterate rather than blindly choosing the highest score.

## Definition of DONE for every screen

- [ ] Approved design and flow referenced
- [ ] No lost feature from parity matrix; unknowns called out
- [ ] Compact, medium and wide layout reviewed
- [ ] iPhone and Android phone behavior reviewed
- [ ] iPad and Android tablet layout reviewed where applicable
- [ ] Mac and web window/browser behavior reviewed
- [ ] Mouse, keyboard, touch and focus behavior considered
- [ ] Long text, empty, dense, loading, error and offline states considered
- [ ] Accessibility, contrast, text scale, semantics reviewed
- [ ] Relevant tests run; failures distinguished from pre-existing baseline
- [ ] Real screenshots compared to visual target
- [ ] Changes are reviewable and safely committed
- [ ] You approve the result

---

# COMMON MISTAKES — DON'T DO THESE

- **Do not fork on GitHub just to redesign the same product** unless you actually want a permanent separate product/repository. Use a worktree.
- **Do not run the v2 command `git switch -c redesign/design-lab`** as well as the worktree command. The worktree command already creates the branch.
- **Do not use `git worktree add -b ...` twice** for an already-existing branch.
- **Do not ask Claude to “make everything premium”** with no reference screens or usability criteria.
- **Do not develop several unfinished features in the old visual system** if the new system has already been chosen and they can wait.
- **Do not assume tablet readiness from `TARGETED_DEVICE_FAMILY` or Android manifest flags alone.** Keep the existing adaptive implementation if good, then verify on devices.
- **Do not assume Mac and web should have identical navigation behavior** even when their layouts look similar.
- **Do not ship UI that has been tested only by Flutter widget tests**; verify actual OS and browser behavior.
- **Do not commit production tokens or user data into design fixtures.**
- **Do not let Design previews masquerade as Flutter-native code.**
- **Do not rebrand your app ID/package name casually** and accidentally break upgrades/sync/subscriptions.
- **Do not delete old components in bulk** until feature parity and test coverage justify their removal.

---

# OFFICIAL REFERENCES

- Git worktrees: https://git-scm.com/docs/git-worktree
- Flutter AI agent setup for Claude Code: https://docs.flutter.dev/ai/get-started
- Flutter adaptive/responsive design: https://docs.flutter.dev/ui/adaptive-responsive
- Flutter large screens: https://docs.flutter.dev/ui/adaptive-responsive/large-screens
- Claude Code project instructions (`CLAUDE.md`): https://support.claude.com/en/articles/14553240-give-claude-context-claude-md-and-better-prompts
- Claude Code verification and worktrees: https://support.claude.com/en/articles/14554000-claude-code-power-user-tips
- Claude Design `/design` and handoff: https://support.claude.com/en/articles/14604416-get-started-with-claude-design

---

# WHAT TO DO TODAY — NO GUESSWORK

1. In the **original app** terminal, run `git status --short`, `git branch --show-current`, `git worktree list`; protect any uncommitted work.
2. Create `../app-redesign` from the current committed state using `git worktree add -b redesign/design-lab ../app-redesign HEAD` **only if that branch/folder doesn't already exist**.
3. In the redesign directory, make `docs/redesign/` and place this file at `docs/redesign/MASTER_PLAYBOOK.md`.
4. Start Claude Code from that **new directory**, install/check Flutter plugin, and review/create `CLAUDE.md`.
5. Paste **PROMPT 0**, approve the setup, then complete PRODUCT_BRIEF and give **PROMPT A**.
6. Stop after the feature-readiness report and review it. **Do not begin a UI rewrite yet.**

**Your first milestone is not a new-looking app. It is a protected project, a verified feature/architecture baseline, and enough product clarity to explore three truly better interfaces without throwing away what you have built.**
