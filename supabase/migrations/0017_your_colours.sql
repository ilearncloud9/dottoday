-- 0017 (owner, M19.4 part 4c-1; design ED-219, ED-220): custom colours.
--
-- 1. color_key on series and occurrences may hold a custom colour's
--    #RRGGBB as well as a name (ED-220); the app derives its ring and dark
--    shades when drawn, so only the hex is stored. A name this server has
--    never heard of stays allowed (a newer app's palette), as for sound_id
--    (0009); only the shape is checked. NOT VALID: rows already stored are
--    not re-read, new and updated ones are.
-- 2. profiles.your_colours: the account's own colours, the "Your colours"
--    row of the colour picker (at most 24 #RRGGBB, newest first), synced
--    so every device shows the same row.
-- 3. profiles.accent_hex: a custom accent from "Custom colour…" (null =
--    the named settings.accent). Mirrors your_colours' shape rule.
--
-- Nothing is dropped or retyped. RLS: both columns sit on profiles, whose
-- "own row" policies (0001) already cover them; sync_push resolves columns
-- by name, so it needs no change. Mirrors checkColorKey and
-- checkYourColours in app/lib/domain/validation/field_rules.dart.

create or replace function public.is_hex_colour(v text)
returns boolean language sql immutable as $$
  select v ~ '^#[0-9A-Fa-f]{6}$';
$$;

create or replace function public.valid_your_colours(v jsonb)
returns boolean language sql immutable as $$
  select jsonb_typeof(v) = 'array'
     and jsonb_array_length(v) <= 24
     and not exists (
       select 1 from jsonb_array_elements(v) e
       where jsonb_typeof(e) <> 'string' or not public.is_hex_colour(e #>> '{}')
     );
$$;

alter table public.series
  add constraint series_color_key_shape
  check (color_key ~ '^[a-z]{1,24}$' or public.is_hex_colour(color_key)) not valid;
alter table public.occurrences
  add constraint occurrences_color_key_shape
  check (color_key ~ '^[a-z]{1,24}$' or public.is_hex_colour(color_key)) not valid;

alter table public.profiles
  add column your_colours jsonb not null default '[]'::jsonb
    constraint profiles_your_colours_shape check (public.valid_your_colours(your_colours)),
  add column accent_hex text
    constraint profiles_accent_hex_shape check (accent_hex is null or public.is_hex_colour(accent_hex));
