-- 0003_web_push.sql — server web push for a closed tab (docs/09 M5.3b, 07 Web).
-- The browser encrypts every payload to its own subscription (RFC 8291), so
-- the server holds an endpoint, fire times, an ID-only plan and ciphertext —
-- never task text (06 §1). The send-push Edge Function delivers due rows.

-- One row per browser that allowed push for this account.
create table public.push_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  endpoint text not null check (endpoint ~ '^https://' and char_length(endpoint) <= 2048),
  created_at timestamptz not null default now(),
  unique (user_id, endpoint)
);
alter table public.push_subscriptions enable row level security;
create policy "push_subscriptions: own rows" on public.push_subscriptions
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- One row per reminder a subscription should receive.
create table public.scheduled_pushes (
  subscription_id uuid not null references public.push_subscriptions(id) on delete cascade,
  notification_id integer not null,
  user_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  fire_at timestamptz not null,
  -- The client's PlannedNotification payload: IDs, timing, content hash.
  plan text not null check (char_length(plan) <= 512),
  -- aes128gcm body for the push service (RFC 8188/8291); 4096 is the limit.
  ciphertext bytea not null check (octet_length(ciphertext) between 1 and 4096),
  sent_at timestamptz,
  primary key (subscription_id, notification_id)
);
alter table public.scheduled_pushes enable row level security;
-- Own rows, and only for an own subscription.
create policy "scheduled_pushes: own rows" on public.scheduled_pushes
  for all using (user_id = auth.uid())
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.push_subscriptions s
      where s.id = subscription_id and s.user_id = auth.uid()
    )
  );
create index scheduled_pushes_due on public.scheduled_pushes (fire_at) where sent_at is null;

-- A client can't flood its own push service: at most 500 unsent per browser.
create or replace function public.limit_scheduled_pushes()
returns trigger language plpgsql as $$
begin
  if (select count(*) from public.scheduled_pushes
      where subscription_id = new.subscription_id and sent_at is null) >= 500 then
    raise exception 'scheduled_pushes: at most 500 pending per subscription'
      using errcode = '54000';
  end if;
  return new;
end $$;
create trigger scheduled_pushes_limit before insert on public.scheduled_pushes
  for each row execute function public.limit_scheduled_pushes();
