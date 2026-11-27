-- Dark World online foundation
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null default 'Aventureiro' check (char_length(username) between 1 and 24),
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.friend_requests (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles(id) on delete cascade,
  addressee_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted','declined','cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint friend_request_not_self check (requester_id <> addressee_id),
  constraint friend_request_unique_pair unique (requester_id, addressee_id)
);

create table public.game_rooms (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  room_code text not null unique check (char_length(room_code) between 6 and 12),
  chapter text not null default 'Floresta Corrompida',
  max_players int not null default 4 check (max_players between 1 and 4),
  status text not null default 'waiting' check (status in ('waiting','playing','closed')),
  created_at timestamptz not null default now()
);

create table public.room_members (
  room_id uuid not null references public.game_rooms(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (room_id, user_id)
);

create index friend_requests_addressee_status_idx on public.friend_requests(addressee_id, status);
create index friend_requests_requester_status_idx on public.friend_requests(requester_id, status);
create index room_members_user_id_idx on public.room_members(user_id);

alter table public.profiles enable row level security;
alter table public.friend_requests enable row level security;
alter table public.game_rooms enable row level security;
alter table public.room_members enable row level security;

create policy "Profiles are readable by signed-in players"
on public.profiles for select to authenticated using (true);
create policy "Players create their own profile"
on public.profiles for insert to authenticated with check ((select auth.uid()) = id);
create policy "Players update their own profile"
on public.profiles for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

create policy "Players read their own friend requests"
on public.friend_requests for select to authenticated
using ((select auth.uid()) = requester_id or (select auth.uid()) = addressee_id);
create policy "Players send friend requests as themselves"
on public.friend_requests for insert to authenticated
with check ((select auth.uid()) = requester_id and status = 'pending');
create policy "Recipients respond to pending requests"
on public.friend_requests for update to authenticated
using ((select auth.uid()) = addressee_id and status = 'pending')
with check ((select auth.uid()) = addressee_id and status in ('accepted','declined'));

create policy "Room members can view their rooms"
on public.game_rooms for select to authenticated
using (
  owner_id = (select auth.uid())
  or exists (
    select 1 from public.room_members rm
    where rm.room_id = id and rm.user_id = (select auth.uid())
  )
);
create policy "Players create rooms as owner"
on public.game_rooms for insert to authenticated
with check (owner_id = (select auth.uid()));
create policy "Owners update their rooms"
on public.game_rooms for update to authenticated
using (owner_id = (select auth.uid()))
with check (owner_id = (select auth.uid()));

create policy "Players see memberships in rooms they belong to"
on public.room_members for select to authenticated
using (
  user_id = (select auth.uid())
  or exists (
    select 1 from public.room_members mine
    where mine.room_id = room_id and mine.user_id = (select auth.uid())
  )
);
create policy "Room owners add themselves as members"
on public.room_members for insert to authenticated
with check (
  user_id = (select auth.uid())
  and exists (
    select 1 from public.game_rooms r
    where r.id = room_id and r.owner_id = (select auth.uid())
  )
);
create policy "Players leave their own rooms"
on public.room_members for delete to authenticated
using (user_id = (select auth.uid()));

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  insert into public.profiles (id, username, avatar_url)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data ->> 'name', ''), nullif(new.raw_user_meta_data ->> 'full_name', ''), 'Aventureiro'),
    new.raw_user_meta_data ->> 'avatar_url'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

grant select, insert, update on public.profiles to authenticated;
grant select, insert, update on public.friend_requests to authenticated;
grant select, insert, update on public.game_rooms to authenticated;
grant select, insert, delete on public.room_members to authenticated;