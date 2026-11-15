-- 0016 (owner, Round 2 close-out; design ED-084, R2-19 / ED-314): the
-- account's device list, so only the device chosen in "Alarm sounds on"
-- (settings.alarmDeviceId) arms Wake Up; every other device disarms when it
-- syncs. Mac and web are listed but never ring.
--
-- Numbered 0016 because the open CR-160 change (PR #75) holds 0014 and
-- 0015. This file does not touch sync_push: each install writes only its
-- own row, so it upserts it directly under RLS instead of through the
-- field-versioned outbox, and the two changes can land in either order.
--
-- 1. devices: one row per install, written by that install. No names or
--    model strings (06 §1: nothing that identifies a person); the app labels
--    a row from platform and form ("iPhone", "Android tablet").
-- 2. At most 50 live devices per account, so a client can't flood its list.
-- 3. Realtime includes it, so a picker on another device updates.
-- alarmDeviceId lives in profiles.settings: validate_settings() ignores keys
-- it doesn't know, so it needs no change. Nothing is dropped or retyped.

create table public.devices (
  id uuid primary key,
  user_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  platform text not null check (platform in ('ios','android','macos','web')),
  form text not null check (form in ('phone','tablet','desktop')),
  -- Whether this device can ring Wake Up at all (phones and tablets only).
  can_ring boolean not null default false,
  -- Whether Wake Up alarms are on and allowed on this device right now.
  alarm_on boolean not null default false,
  -- Whether this device has taken over as the one that rings (it read
  -- settings.alarmDeviceId naming it); false while a switch is pending.
  rings boolean not null default false,
  -- The next Wake Up this device has armed, for "Ready · 06:30".
  armed_wake_utc timestamptz,
  last_seen_utc timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint devices_form_matches check (
    (platform in ('ios','android') and form in ('phone','tablet'))
    or (platform in ('macos','web') and form = 'desktop')
  ),
  constraint devices_desktop_never_rings check (
    platform in ('ios','android')
    or (not can_ring and not alarm_on and not rings and armed_wake_utc is null)
  )
);
create index devices_user_updated on public.devices (user_id, updated_at);
alter table public.devices enable row level security;
create policy "devices: own rows" on public.devices
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create trigger devices_updated_at before update on public.devices
  for each row execute function public.set_updated_at();

create or replace function public.limit_devices()
returns trigger language plpgsql as $$
begin
  if (select count(*) from public.devices
      where user_id = new.user_id and deleted_at is null) >= 50 then
    raise exception 'devices: at most 50 per account' using errcode = '54000';
  end if;
  return new;
end $$;
create trigger devices_limit before insert on public.devices
  for each row execute function public.limit_devices();

alter publication supabase_realtime add table public.devices;
