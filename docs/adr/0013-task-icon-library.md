# ADR-0013 · Task icon library: Structured's names, drawn in Concept A's stroke

Status: Accepted · Date: 2026-10-27 · Amends docs/10 §3 "Icon set", ADR-0007

## Context
Concept A shipped 26 task icons. Users moving from Structured expect a far larger set: its public
icon list has about 650 entries, and people pick an icon by name ("Laundry Basket", "Dumbbell").
Structured's drawings can't be reused. Most are Apple SF Symbols, which Apple licenses for
Apple-platform UI only, so they can't ship on Android or the web. The rest are its own or come from
paid stock sets. They are also filled, while Concept A icons are 2-unit strokes.

## Decision
- One generated library: `app/assets/design/task_icons.json` → `tool/gen_task_icons.dart` →
  the `TaskIcon` enum with a `TaskIconCategory`, the localized-name lookup and the `taskIcon*` ARB
  keys in en/de/es/fr. `task_icons_test.dart` fails CI when an output is stale, a key is duplicated
  or a drawing leaves the 24-unit grid.
- Names: Structured's English names, so the picker reads the way users remember it. Brand and
  app logos (Instagram, WhatsApp, iPhone, PlayStation and so on, 39 names) are left out because of
  trademarks.
- Drawings, in this order:
  1. Lucide (ISC) or Tabler outline (MIT). Both use a 24-unit grid with stroke 2 and round caps,
     so they match `DotIcon` unchanged. Their path data is copied into the JSON; there is no
     package dependency. Their license texts ship in `assets/licenses/` and appear in About ›
     Licenses.
  2. Concept A's own 26 drawings, kept where they still show their name.
  3. Dottoday's own drawings: the **Planning & rhythm** category, plus gaps neither library covers.
  About 90 Structured names have no fitting drawing yet; they are added only once drawn well,
  never as stand-ins.
- `tool/icons/import_task_icons.py` rebuilds the library rows from the two packages and a name →
  icon mapping. Hand-drawn rows (`source: dottoday` / `concept-a`) are never overwritten.
- Stored data: the 26 Concept A keys stay the persisted `icon_key`s. Only their names change, to
  Structured's ("run" reads "Running", "people" reads "Group"). Three of them now use the library
  drawing that shows that name (run, travel, list). New icons use snake_case keys; the
  `icon_key` shape (docs/05) is unchanged. Retired pre-Concept A keys that are now real icons
  (`bike`, `coffee`, `sleep`) show that icon instead of their old nearest match.
  An older app version shows a new key as the plain dot, as it already does for any unknown key.
- Picker: a full-height sheet with colours, search and lazy category sections. The Search screen's
  icon filter uses the same grid.

## Consequences
- 524 icons cost about 125 KB of Dart source and a few hundred ARB keys per language.
  Glyphs are parsed when first drawn and cached, so there is no start-up cost.
- `svg_path.dart` now also parses `S`/`T` (smooth curves), which both libraries use.
- Rejected: an icon font (it would need a new build step and lose per-icon review in goldens);
  SF Symbols (license); a third-party Flutter icon package (it adds a dependency, and its drawings
  use a different stroke and grid).
