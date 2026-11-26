create or replace function private.is_room_member(p_room_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $function$
  select exists (
    select 1
    from public.room_members rm
    where rm.room_id = p_room_id
      and rm.user_id = auth.uid()
  );
$function$;

revoke all on function private.is_room_member(uuid) from public, anon;
grant execute on function private.is_room_member(uuid) to authenticated;

drop policy if exists "Players see memberships in rooms they belong to" on public.room_members;
create policy "Players see memberships in rooms they belong to"
on public.room_members for select to authenticated
using (
  user_id = (select auth.uid())
  or private.is_room_member(room_id)
);
