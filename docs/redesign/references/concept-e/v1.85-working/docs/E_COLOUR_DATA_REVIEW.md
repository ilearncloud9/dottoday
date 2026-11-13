# Colour data-compatibility review (custom colours; brown, plum, olive)

Status: **review only, 2026-11-07.** The owner has approved the full colour palette *design* (ED-155, ED-161) and has **not** authorised any change to stored data, colour identifiers, the schema or migrations. Nothing here is implemented. I read the code without changing it.

## 1. What is stored today (read from the code, not changed)

| Item | Where | Today |
|---|---|---|
| Task colour | `tasks.color_key`, `series.color_key` (`supabase/migrations/0001_init.sql`), local Drift mirror, backups, DaySnapshot (`color_key`) | `text not null default 'indigo'`, only a length check (≤ 24 chars) in SQL |
| Calendar-series override | calendar series `color_key?` (docs/05) | optional, same rule |
| Allowed task keys | `app/lib/domain/entities/task_color_keys.gen.dart`, generated from `app/assets/design/palette.json` | 9 keys: `coral amber mint teal sky indigo violet rose slate`; legacy keys `tangerine lime magenta` are accepted and drawn as the nearest colour |
| Validation | `checkColorKey` in `domain/validation/field_rules.dart`, called by the entity, routine and calendar-series validators | anything outside the 12 keys fails `invalidFormat` |
| Unknown key when drawn | `TaskColor.fromKey` | falls back to `indigo` (drawn only; the stored text is not rewritten) |
| App accent | `settings.accent`, `checkAccentKey` | 4 keys: `indigo teal coral violet` |
| Conflicts | `drift_conflict_store.dart` | `color_key` and `icon_key` form one "colour" conflict field |

## 2. How Concept E's 12 colours relate to the stored keys

| Concept E name (display) | Hex in E | Stored key (unchanged) | Built hex | Data change? |
|---|---|---|---|---|
| Coral | #E2725B | `coral` | #E5674F | none; hex is a theme value |
| Amber | #D9A23A | `amber` | #D99A1F | none |
| Sky | #4A9BD6 | `sky` | #2E8FD6 | none |
| Indigo | #5B5FD6 | `indigo` | #3B6CF6 | none |
| Teal-green | #2A9D8F | `teal` | #1F9E9E | none (display name differs from the key) |
| Rose | #D9668F | `rose` | #D64F86 | none |
| Green | #4CA36B | `mint` | #2FA37A | none (display name differs from the key) |
| Violet | #8B5CF6 | `violet` | #7A5AF8 | none |
| Slate | #6E6A75 | `slate` | #6B6B70 | none |
| Brown | #8C6A4F | none yet | — | **new key needed** |
| Plum | #9E4F8F | none yet | — | **new key needed** |
| Olive | #7F8A3A | none yet | — | **new key needed** |

**Existing saved colours are kept.** Nine of E's colours map to keys the app already stores, so no task's stored value has to change. Following G3-10's rule, internal identifiers keep their names (`teal` is shown as "Teal-green", `mint` as "Green"). Changing a hex in `palette.json` changes how existing tasks *look* in that colour, but not what is stored. That is a visible change to existing tasks, so the owner should approve it when the theme is built.

## 3. Brown, plum, olive

- **Storage:** the strings fit the existing column (text ≤ 24). **No schema migration is needed.**
- **What would have to change (not authorised):** `palette.json` and the generated `TaskColor` / `taskColorKeys`, which also widens `checkColorKey`; docs/05 "Validation"; and the picker order.
- **Compatibility risk with older app versions (to verify before building):** an older client draws an unknown key as indigo. Whether it *rejects* such a row on pull or on a later edit depends on where the entity validators run on incoming rows; this was not traced to the end. *(Traced 2026-11-09, ED-219: pull does not validate; local writes and restore do, so older clients reject edits of such tasks.)* If they run on pull, older clients would need the new keys first (ship the keys in one release, let users start writing them in a later one).
- **No data migration** of existing rows is needed; nothing is rewritten.

## 4. Custom colours ("Your colours", Custom colour…)

Today there is **no representation** for a custom colour, and validation would reject one. Options to decide later (nothing chosen, nothing built):

| Option | Representation | Schema migration? | Older clients | Notes |
|---|---|---|---|---|
| C1 | a hex value in `color_key` (e.g. `#F0A28E`, 7 chars) | no (fits ≤ 24) | draw indigo; validation behaviour as in §3 | simplest; the conflict field already covers it; mixes two kinds of value in one column |
| C2 | a new nullable `color_hex` beside `color_key` (key stays the fallback) | **yes**, plus RLS review and sync columns | ignore the new column, show the key colour | clean separation; older clients degrade gracefully |
| C3 | a per-user palette list ("Your colours") in settings, tasks store a stable palette-entry id | **yes** (settings field or table) | unknown id → fallback | supports renaming and editing a custom colour everywhere at once |

Accessibility applies whichever option is chosen: the derived ring and glyph shades (ED-155, ED-161: ring until 3:1 on the ground, white or ink glyph at 3:1 or better) are computed when the colour is drawn, never stored.

## 5. App colour (Settings › Appearance)

The approved App colour picker (ED-161) differs from the built `settings.accent` (4 keys). Adding colours or a custom App colour needs the same kind of decision as §3 and §4, for `checkAccentKey`. No change is proposed here.

## 6. Decisions the owner will need (later, before any build)

1. Theme hex update for the 9 existing keys: design approved (ED-161; dark ED-174/177); confirm at build with a release note (existing tasks look different, nothing stored changes).
2. ~~Approve adding `brown`, `plum`, `olive`~~ **DECIDED 2026-11-09 (ED-219), option A:** two releases; release N accepts the keys and makes validation forward-compatible (unchanged unknown keys never block an edit or a restore), release N+1 shows them in pickers. No schema change.
3. Choose C1, C2 or C3 for custom colours (C2 and C3 need migrations).
4. The same choices for the App colour (`settings.accent`).
