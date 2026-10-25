-- 0005_calendar_oauth.sql — Google and Microsoft calendars (docs/09 M7.4, 04 §7, 06 §1/§3, ADR-0011).
-- One calendar_accounts row per connected Google/Microsoft account. Its OAuth tokens live in
-- Supabase Vault (vault.secrets named 'calendar_account:<id>'), reachable only by the service
-- role through the functions below, i.e. only by the calendar-oauth / calendar-sync Edge
-- Functions. Calendar content is never stored here: calendar-sync reads it on request.

-- Reconnecting the same account updates its row instead of adding a second one.
create unique index calendar_accounts_cloud_unique
  on public.calendar_accounts (user_id, provider, external_account_id)
  where provider in ('google', 'microsoft');

-- Clients read and remove their own connections; only the Edge Functions (service role)
-- create or change them, so a client can never point a row at someone else's token.
-- Device-calendar rows are local only (docs/05) and never reach this table.
drop policy "calendar_accounts: own rows" on public.calendar_accounts;
create policy "calendar_accounts: read own" on public.calendar_accounts
  for select using (user_id = auth.uid());
create policy "calendar_accounts: delete own" on public.calendar_accounts
  for delete using (user_id = auth.uid());

-- The OAuth `state` of a connect in progress: single use, 10 minutes, with its PKCE verifier
-- and where the browser goes afterwards. Service role only.
create table public.calendar_oauth_states (
  state text primary key check (char_length(state) between 32 and 128),
  user_id uuid not null references public.profiles(id) on delete cascade,
  provider public.calendar_provider not null check (provider in ('google', 'microsoft')),
  code_verifier text not null check (char_length(code_verifier) between 43 and 128),
  return_to text not null check (char_length(return_to) <= 512),
  expires_at timestamptz not null default now() + interval '10 minutes'
);
alter table public.calendar_oauth_states enable row level security;
-- Explicit: no client role may read or write a state (the verifier is a secret).
create policy "calendar_oauth_states: no client access" on public.calendar_oauth_states
  for all to anon, authenticated using (false) with check (false);
revoke all on table public.calendar_oauth_states from anon, authenticated;

-- Takes a state once: deletes it and returns it when it hasn't expired. Old ones go too.
create or replace function public.calendar_oauth_take_state(p_state text)
returns table (user_id uuid, provider public.calendar_provider, code_verifier text, return_to text)
language plpgsql security definer set search_path = '' as $$
begin
  delete from public.calendar_oauth_states s where s.expires_at < now();
  return query
    delete from public.calendar_oauth_states s
    where s.state = p_state
    returning s.user_id, s.provider, s.code_verifier, s.return_to;
end $$;

-- Connects (or reconnects) an account and stores its tokens, in one transaction.
create or replace function public.calendar_account_connect(
  p_user uuid,
  p_provider public.calendar_provider,
  p_external text,
  p_label text,
  p_token text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  v_id uuid;
begin
  if p_provider not in ('google', 'microsoft') then
    raise exception 'calendar_account_connect: provider % has no OAuth', p_provider
      using errcode = '22023';
  end if;
  insert into public.calendar_accounts (id, user_id, provider, label, external_account_id)
    values (gen_random_uuid(), p_user, p_provider, left(p_label, 80), p_external)
  on conflict (user_id, provider, external_account_id)
    where provider in ('google', 'microsoft')
    do update set label = excluded.label, enabled = true
  returning id into v_id;
  perform public.calendar_token_put(v_id, p_token);
  return v_id;
end $$;

-- Stores (or replaces, after a refresh) the token JSON of an account.
create or replace function public.calendar_token_put(p_account uuid, p_token text)
returns void
language plpgsql security definer set search_path = '' as $$
declare
  v_name text := 'calendar_account:' || p_account;
  v_secret uuid;
begin
  if not exists (select 1 from public.calendar_accounts a where a.id = p_account) then
    raise exception 'calendar_token_put: no such account' using errcode = '23503';
  end if;
  select s.id into v_secret from vault.secrets s where s.name = v_name;
  if v_secret is null then
    perform vault.create_secret(p_token, v_name, 'Calendar OAuth tokens (M7.4)');
  else
    perform vault.update_secret(v_secret, p_token);
  end if;
end $$;

-- The token JSON of an account, or null.
create or replace function public.calendar_token_get(p_account uuid)
returns text
language sql stable security definer set search_path = '' as $$
  select s.decrypted_secret from vault.decrypted_secrets s
  where s.name = 'calendar_account:' || p_account
$$;

-- Disconnecting, or deleting the account (profiles cascade), takes the token with it.
create or replace function public.calendar_accounts_drop_token()
returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  delete from vault.secrets s where s.name = 'calendar_account:' || old.id;
  return old;
end $$;
create trigger calendar_accounts_drop_token after delete on public.calendar_accounts
  for each row execute function public.calendar_accounts_drop_token();

-- Only the service role (the Edge Functions) may call the token functions.
revoke all on function public.calendar_oauth_take_state(text) from public, anon, authenticated;
revoke all on function public.calendar_account_connect(uuid, public.calendar_provider, text, text, text)
  from public, anon, authenticated;
revoke all on function public.calendar_token_put(uuid, text) from public, anon, authenticated;
revoke all on function public.calendar_token_get(uuid) from public, anon, authenticated;
revoke all on function public.calendar_accounts_drop_token() from public, anon, authenticated;
grant execute on function public.calendar_oauth_take_state(text) to service_role;
grant execute on function public.calendar_account_connect(uuid, public.calendar_provider, text, text, text)
  to service_role;
grant execute on function public.calendar_token_put(uuid, text) to service_role;
grant execute on function public.calendar_token_get(uuid) to service_role;
