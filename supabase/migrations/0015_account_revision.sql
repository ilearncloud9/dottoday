-- 0015 (CR-160 W2, deletion consistency, Stage 1 prototype): a per-account
-- revision that every committed change to exported data moves, and a
-- deletion freeze checked against it. Separate from 0014 and independent of
-- it: sync_push is not redefined. Nothing is dropped or retyped.
--
-- Contract:
-- * account_revisions holds one row per auth user: revision (only ever goes
--   up) and deleting_until (a live freeze while it is in the future).
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
--   the revision the export was made at and, only if equal, freezes for ten
--   minutes, all in one transaction.
-- The Auth Admin deletion that follows is a separate transaction (GoTrue's);
-- the freeze bounds it, it is not atomic with the check.

create table public.account_revisions (
  -- Keyed by the auth user, not the profile: deleting and re-creating a
  -- profile must never reset a revision (no ABA on the deletion check).
  user_id uuid primary key references auth.users(id) on delete cascade,
  revision bigint not null default 0 check (revision >= 0),
  deleting_until timestamptz
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
     set revision = r.revision + 1, deleting_until = null
   where r.user_id = owner
     and (r.deleting_until is null or r.deleting_until <= clock_timestamp());
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
  frozen_until timestamptz;
begin
  if caller is null then return null; end if;  -- service role, cascades from it
  if not exists (select 1 from auth.users u where u.id = caller) then return null; end if;
  insert into public.account_revisions (user_id) values (caller)
    on conflict (user_id) do nothing;
  select r.deleting_until into frozen_until
    from public.account_revisions r where r.user_id = caller
    for update;
  if frozen_until > clock_timestamp() then
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
-- a deletion freeze is live. One statement, one snapshot.
create or replace function public.account_revision()
returns table (revision bigint, frozen boolean)
language sql stable security invoker set search_path = '' as $$
  select coalesce(max(r.revision), 0),
         coalesce(bool_or(r.deleting_until > clock_timestamp()), false)
    from public.account_revisions r
   where r.user_id = auth.uid();
$$;

-- delete-account (service role) before the Auth deletion: freezes [p_user]
-- for ten minutes if its revision is still [p_expected]. 'frozen' (also
-- for a retry of a live freeze at the same revision), 'changed' (nothing
-- frozen) or 'gone' (no such user). Waits at most 5 s for writers.
create or replace function public.begin_account_deletion(p_user uuid, p_expected bigint)
returns text language plpgsql security definer set search_path = '' as $$
declare
  current_rev bigint;
  frozen_until timestamptz;
begin
  if p_user is null or p_expected is null then
    raise exception 'begin_account_deletion: user and expected revision are required'
      using errcode = '22004';
  end if;
  perform set_config('lock_timeout', '5s', true);
  if not exists (select 1 from auth.users u where u.id = p_user) then return 'gone'; end if;
  insert into public.account_revisions (user_id) values (p_user)
    on conflict (user_id) do nothing;
  select r.revision, r.deleting_until into current_rev, frozen_until
    from public.account_revisions r where r.user_id = p_user
    for update;
  if current_rev <> p_expected then return 'changed'; end if;
  if frozen_until > clock_timestamp() then return 'frozen'; end if;
  update public.account_revisions
     set deleting_until = clock_timestamp() + interval '10 minutes'
   where user_id = p_user;
  return 'frozen';
end $$;

-- delete-account (service role) when the Auth deletion failed: the freeze
-- ends and the revision moves, so a review made before it is void.
create or replace function public.abort_account_deletion(p_user uuid)
returns boolean language plpgsql security definer set search_path = '' as $$
begin
  update public.account_revisions
     set deleting_until = null, revision = revision + 1
   where user_id = p_user and deleting_until is not null;
  return found;
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
    and user_id not in (select user_id from public.account_revisions where deleting_until > clock_timestamp());
  delete from public.occurrences where deleted_at < now() - interval '30 days'
    and user_id not in (select user_id from public.account_revisions where deleting_until > clock_timestamp());
  delete from public.series where deleted_at < now() - interval '30 days'
    and user_id not in (select user_id from public.account_revisions where deleting_until > clock_timestamp());
  delete from public.routines where deleted_at < now() - interval '30 days'
    and user_id not in (select user_id from public.account_revisions where deleting_until > clock_timestamp());
$$;

revoke all on function public.account_revision_bump(uuid) from public, anon, authenticated, service_role;
revoke all on function public.account_revision_row() from public, anon, authenticated, service_role;
revoke all on function public.account_revision_statement() from public, anon, authenticated, service_role;
revoke all on function public.account_revision() from public, anon;
grant execute on function public.account_revision() to authenticated;
revoke all on function public.begin_account_deletion(uuid, bigint) from public, anon, authenticated;
grant execute on function public.begin_account_deletion(uuid, bigint) to service_role;
revoke all on function public.abort_account_deletion(uuid) from public, anon, authenticated;
grant execute on function public.abort_account_deletion(uuid) to service_role;
