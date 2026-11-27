drop policy if exists "Players see memberships in rooms they belong to" on public.room_members;
create policy "Players see memberships in rooms they belong to"
on public.room_members for select to authenticated
using (
  user_id = (select auth.uid())
  or exists (
    select 1 from public.room_members mine
    where mine.room_id = room_members.room_id
      and mine.user_id = (select auth.uid())
  )
);

create or replace function public.prevent_friend_request_identity_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.requester_id <> old.requester_id or new.addressee_id <> old.addressee_id then
    raise exception 'Friend request participants cannot be changed';
  end if;
  return new;
end;
$$;

create trigger friend_request_identity_immutable
before update on public.friend_requests
for each row execute procedure public.prevent_friend_request_identity_change();