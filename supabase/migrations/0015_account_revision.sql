-- 0015 (CR-160 W2, deletion consistency, Stage 1 prototype): a per-account
-- revision that every committed change to exported data moves, and a
-- deletion freeze checked against it. Separate from 0014 and independent of
-- it: sync_push is not redefined. Nothing is dropped or retyped.
--
-- Contract:
-- * account_revisions holds one row per auth user: revision (only ever goes
--   up) and the deletion state. An account is frozen exactly while
--   deletion_attempt is set; no clock, timeout or job ever clears it.
-- * On the six exported tables, every inserted, updated or deleted row moves
--   its owner's revision in the same transaction (AFTER ROW), whatever the
--   route: sync_push, direct PostgREST writes, definer functions, the
--   service role and FK cascades. The UPDATE of the revision row holds its
--   row lock until commit, so an owner's revision moves in commit order.
-- * A BEFORE STATEMENT trigger takes the caller's (auth.uid()) revision
--   lock before any data row, so client transactions all lock in one order:
--   revision row, then data rows.
-- * While frozen, inserts, updates and deletes of the owner's exported rows
--   are refused (SQLSTATE DT409). The one exception is the Auth user
--   deletion cascade: once the owner's auth.users row is gone in this
--   transaction, its rows may go too. Clients can't delete auth.users.
-- * begin_account_deletion (service role only) locks the revision row,
--   which waits for every in-flight writer of that owner, compares it with
--   the revision the export was made at and, only if equal, freezes it under
--   a new attempt id (the fencing token), all in one transaction.
-- * The freeze ends only with the account (the Auth deletion cascade removes
--   the row) or through release_account_deletion for the same attempt, when
--   every Auth Admin call recorded for that attempt is known to have been
--   refused. An Admin call whose outcome is unknown (timeout, 5xx, crash)
--   stays unresolved, and the account stays frozen: completing the deletion
--   by retrying is the way out; elapsed time never is.
-- The Auth Admin deletion is a separate transaction (GoTrue's), not atomic
-- with the check; the freeze makes it remove exactly the frozen state.

create table public.account_revisions (
  -- Keyed by the auth user, not the profile: deleting and re-creating a
  -- profile must never reset a revision (no ABA on the deletion check).
  user_id uuid primary key references auth.users(id) on delete cascade,
  revision bigint not null default 0 check (revision >= 0),
  -- The deletion under way: its fencing token, the revision it froze, when
  -- it began (information only: never used to end it) and how many Auth
  -- Admin calls it made whose refusal hasn't been confirmed.
  deletion_attempt uuid,
  deletion_revision bigint,
  deletion_started_at timestamptz,
  deletion_calls_unresolved int not null default 0 check (deletion_calls_unresolved >= 0),
  constraint account_revisions_deletion_state check (
    (deletion_attempt is null and deletion_revision is null and deletion_started_at is null
       and deletion_calls_unresolved = 0)
    or (deletion_attempt is not null and deletion_revision is not null
       and deletion_started_at is not null))
);
alter table public.account_revisions enable row level security;
create policy "account_revisions: read own" on public.account_revisions
  for select to authenticated using (user_id = auth.uid());
-- Writes only through the definer functions below, for every API role.
revoke all on table public.account_revisions from public, anon, authenticated, service_role;
grant select on table public.account_revisions to authenticated, service_role;

insert into public.account_revisions (user_id)
  select id from auth.users
  on conflict (user_id) do nothing;

-- Moves [owner]'s revision for one changed row; refuses while frozen.
create or replace function public.account_revision_bump(owner uuid)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if owner is null then return; end if;
  -- The Auth deletion cascade (or a write for a user that no longer
  -- exists, which the foreign keys refuse anyway): its rows are leaving.
  if not exists (select 1 from auth.users u where u.id = owner) then return; end if;
  insert into public.account_revisions (user_id) values (owner)
    on conflict (user_id) do nothing;
  -- Waits for a running begin_account_deletion; READ COMMITTED re-checks
  -- the WHERE against its committed freeze, so a write racing the freeze
  -- either commits first (and its bump is what the freeze compares) or
  -- finds the freeze and is refused.
  update public.account_revisions r
     set revision = r.revision + 1
   where r.user_id = owner
     and r.deletion_attempt is null;
  if not found then
    raise exception 'account % is being deleted', owner
      using errcode = 'DT409';
  end if;
end $$;

-- AFTER ROW on each exported table. TG_ARGV[0] names the owner column.
create or replace function public.account_revision_row()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  col text := tg_argv[0];
  old_owner uuid;
  new_owner uuid;
begin
  if tg_op in ('UPDATE', 'DELETE') then old_owner := (to_jsonb(old) ->> col)::uuid; end if;
  if tg_op in ('UPDATE', 'INSERT') then new_owner := (to_jsonb(new) ->> col)::uuid; end if;
  if old_owner is not null and new_owner is not null and old_owner <> new_owner then
    -- An owner change touches both; the lower id first, one order for all.
    perform public.account_revision_bump(least(old_owner, new_owner));
    perform public.account_revision_bump(greatest(old_owner, new_owner));
  else
    perform public.account_revision_bump(coalesce(new_owner, old_owner));
  end if;
  return null;
end $$;

-- BEFORE STATEMENT on each exported table: the caller's revision lock
-- first (lock order), and a frozen caller is refused before any row.
create or replace function public.account_revision_statement()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  caller uuid := auth.uid();
  attempt uuid;
begin
  if caller is null then return null; end if;  -- service role, cascades from it
  if not exists (select 1 from auth.users u where u.id = caller) then return null; end if;
  insert into public.account_revisions (user_id) values (caller)
    on conflict (user_id) do nothing;
  select r.deletion_attempt into attempt
    from public.account_revisions r where r.user_id = caller
    for update;
  if attempt is not null then
    raise exception 'account % is being deleted', caller using errcode = 'DT409';
  end if;
  return null;
end $$;

create trigger profiles_account_revision_stmt before insert or update or delete on public.profiles
  for each statement execute function public.account_revision_statement();
create trigger profiles_account_revision after insert or update or delete on public.profiles
  for each row execute function public.account_revision_row('id');
create trigger series_account_revision_stmt before insert or update or delete on public.series
  for each statement execute function public.account_revision_statement();
create trigger series_account_revision after insert or update or delete on public.series
  for each row execute function public.account_revision_row('user_id');
create trigger occurrences_account_revision_stmt before insert or update or delete on public.occurrences
  for each statement execute function public.account_revision_statement();
create trigger occurrences_account_revision after insert or update or delete on public.occurrences
  for each row execute function public.account_revision_row('user_id');
create trigger subtasks_account_revision_stmt before insert or update or delete on public.subtasks
  for each statement execute function public.account_revision_statement();
create trigger subtasks_account_revision after insert or update or delete on public.subtasks
  for each row execute function public.account_revision_row('user_id');
create trigger routines_account_revision_stmt before insert or update or delete on public.routines
  for each statement execute function public.account_revision_statement();
create trigger routines_account_revision after insert or update or delete on public.routines
  for each row execute function public.account_revision_row('user_id');
create trigger reveal_hints_account_revision_stmt before insert or update or delete on public.reveal_hints
  for each statement execute function public.account_revision_statement();
create trigger reveal_hints_account_revision after insert or update or delete on public.reveal_hints
  for each row execute function public.account_revision_row('user_id');

-- TRUNCATE fires no row triggers: no API role may use it on exported data.
revoke truncate on table public.profiles, public.series, public.occurrences,
  public.subtasks, public.routines, public.reveal_hints from anon, authenticated, service_role;

-- The signed-in account's revision (0 before its first change) and whether
-- a deletion freezes it. One statement, one snapshot.
create or replace function public.account_revision()
returns table (revision bigint, frozen boolean)
language sql stable security invoker set search_path = '' as $$
  select coalesce(max(r.revision), 0),
         coalesce(bool_or(r.deletion_attempt is not null), false)
    from public.account_revisions r
   where r.user_id = auth.uid();
$$;

-- delete-account (service role) before any Auth Admin call. Returns
-- ('frozen', attempt) when [p_user]'s revision is [p_expected]: a new freeze,
-- or the unresolved one already frozen at that same revision (a retry joins
-- it, the same attempt id back, nothing overwritten). ('pending', null) when
-- an unresolved deletion froze another revision: it is never taken over.
-- ('changed', null) when the revision moved; ('gone', null) for no such
-- user. Waits at most 5 s for in-flight writers.
create or replace function public.begin_account_deletion(p_user uuid, p_expected bigint)
returns table (outcome text, attempt uuid)
language plpgsql security definer set search_path = '' as $$
declare
  cur public.account_revisions;
begin
  if p_user is null or p_expected is null then
    raise exception 'begin_account_deletion: user and expected revision are required'
      using errcode = '22004';
  end if;
  perform set_config('lock_timeout', '5s', true);
  if not exists (select 1 from auth.users u where u.id = p_user) then
    return query select 'gone'::text, null::uuid; return;
  end if;
  insert into public.account_revisions (user_id) values (p_user)
    on conflict (user_id) do nothing;
  select * into cur from public.account_revisions r where r.user_id = p_user for update;
  if cur.deletion_attempt is not null then
    if cur.deletion_revision = p_expected then
      return query select 'frozen'::text, cur.deletion_attempt; return;
    end if;
    return query select 'pending'::text, null::uuid; return;
  end if;
  if cur.revision <> p_expected then
    return query select 'changed'::text, null::uuid; return;
  end if;
  update public.account_revisions r
     set deletion_attempt = gen_random_uuid(), deletion_revision = cur.revision,
         deletion_started_at = clock_timestamp(), deletion_calls_unresolved = 0
   where r.user_id = p_user
  returning r.deletion_attempt into cur.deletion_attempt;
  return query select 'frozen'::text, cur.deletion_attempt;
end $$;

-- delete-account (service role), committed BEFORE each Auth Admin call of
-- [p_attempt]: one more call whose outcome is not yet known. False (and the
-- caller must not make the call) when [p_attempt] is not the live freeze.
create or replace function public.note_account_deletion_call(p_user uuid, p_attempt uuid)
returns boolean language plpgsql security definer set search_path = '' as $$
begin
  update public.account_revisions r
     set deletion_calls_unresolved = r.deletion_calls_unresolved + 1
   where r.user_id = p_user and r.deletion_attempt = p_attempt;
  return found;
end $$;

-- delete-account (service role), only when one Auth Admin call of
-- [p_attempt] was definitely refused (the response proves it ended without
-- deleting, and the user still exists). Never after a timeout, a 5xx, a
-- lost connection or a crash: those calls stay unresolved.
create or replace function public.note_account_deletion_refused(p_user uuid, p_attempt uuid)
returns boolean language plpgsql security definer set search_path = '' as $$
begin
  update public.account_revisions r
     set deletion_calls_unresolved = r.deletion_calls_unresolved - 1
   where r.user_id = p_user and r.deletion_attempt = p_attempt
     and r.deletion_calls_unresolved > 0;
  return found;
end $$;

-- Ends freeze [p_attempt] of [p_user] (service role): only that attempt
-- (a late or unrelated caller can't end a newer one), only while the user
-- exists, and only when none of its Auth Admin calls is unresolved: then no
-- earlier call can still delete. The revision moves, so any review made
-- before is void. 'released', 'unresolved', 'other_attempt', 'not_frozen'
-- or 'gone'.
create or replace function public.release_account_deletion(p_user uuid, p_attempt uuid)
returns text language plpgsql security definer set search_path = '' as $$
declare
  cur public.account_revisions;
begin
  if not exists (select 1 from auth.users u where u.id = p_user) then return 'gone'; end if;
  select * into cur from public.account_revisions r where r.user_id = p_user for update;
  if not found or cur.deletion_attempt is null then return 'not_frozen'; end if;
  if p_attempt is null or cur.deletion_attempt <> p_attempt then return 'other_attempt'; end if;
  if cur.deletion_calls_unresolved > 0 then return 'unresolved'; end if;
  update public.account_revisions r
     set deletion_attempt = null, deletion_revision = null, deletion_started_at = null,
         revision = r.revision + 1
   where r.user_id = p_user;
  return 'released';
end $$;

-- The tombstone purge skips frozen accounts instead of failing for all.
-- Only its body changes: `create or replace` keeps its existing grants
-- (no earlier migration revoked the default EXECUTE) and its existing
-- `search_path = public`. Both are open concerns, left as they were here on
-- purpose and tracked for review: a definer function with a non-empty
-- search_path, executable by API roles.
create or replace function public.purge_old_tombstones()
returns void language sql security definer set search_path = public as $$
  delete from public.subtasks where deleted_at < now() - interval '30 days'
    and user_id not in (select user_id from public.account_revisions where deletion_attempt is not null);
  delete from public.occurrences where deleted_at < now() - interval '30 days'
    and user_id not in (select user_id from public.account_revisions where deletion_attempt is not null);
  delete from public.series where deleted_at < now() - interval '30 days'
    and user_id not in (select user_id from public.account_revisions where deletion_attempt is not null);
  delete from public.routines where deleted_at < now() - interval '30 days'
    and user_id not in (select user_id from public.account_revisions where deletion_attempt is not null);
$$;

revoke all on function public.account_revision_bump(uuid) from public, anon, authenticated, service_role;
revoke all on function public.account_revision_row() from public, anon, authenticated, service_role;
revoke all on function public.account_revision_statement() from public, anon, authenticated, service_role;
revoke all on function public.account_revision() from public, anon;
grant execute on function public.account_revision() to authenticated;
revoke all on function public.begin_account_deletion(uuid, bigint) from public, anon, authenticated;
grant execute on function public.begin_account_deletion(uuid, bigint) to service_role;
revoke all on function public.note_account_deletion_call(uuid, uuid) from public, anon, authenticated;
grant execute on function public.note_account_deletion_call(uuid, uuid) to service_role;
revoke all on function public.note_account_deletion_refused(uuid, uuid) from public, anon, authenticated;
grant execute on function public.note_account_deletion_refused(uuid, uuid) to service_role;
revoke all on function public.release_account_deletion(uuid, uuid) from public, anon, authenticated;
grant execute on function public.release_account_deletion(uuid, uuid) to service_role;
