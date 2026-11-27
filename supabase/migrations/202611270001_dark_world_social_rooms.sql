-- Migration: secure social and room RPCs for Dark World
-- Applied to Supabase project dark-world-online on 2026-11-27.
-- See docs/LOGIN-GOOGLE-LOBBY.md for provider setup. No secrets belong here.

create unique index if not exists friend_requests_active_pair_unique
on public.friend_requests (least(requester_id, addressee_id), greatest(requester_id, addressee_id))
where status in ('pending', 'accepted');

create or replace function public.ensure_dark_world_profile()
returns trigger language plpgsql security definer set search_path = public as $$
declare desired_name text;
begin
  desired_name := coalesce(
    nullif(trim(new.raw_user_meta_data ->> 'preferred_username'), ''),
    nullif(trim(new.raw_user_meta_data ->> 'name'), ''),
    nullif(split_part(coalesce(new.email, ''), '@', 1), ''),
    'Aventureiro'
  );
  insert into public.profiles(id, username) values (new.id, left(desired_name, 24))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_dark_world_profile on auth.users;
create trigger on_auth_user_created_dark_world_profile after insert on auth.users
for each row execute function public.ensure_dark_world_profile();

create or replace function public.dark_world_create_room(p_chapter text default 'Floresta Corrompida')
returns table(room_id uuid, room_code text)
language plpgsql security definer set search_path = public as $$
declare
  current_user_id uuid := auth.uid();
  new_room_id uuid;
  new_room_code text;
  safe_chapter text := coalesce(nullif(trim(p_chapter), ''), 'Floresta Corrompida');
begin
  if current_user_id is null then raise exception 'AUTH_REQUIRED' using errcode = '28000'; end if;
  if char_length(safe_chapter) > 80 then raise exception 'CHAPTER_NAME_TOO_LONG' using errcode = '22023'; end if;
  insert into public.profiles(id) values (current_user_id) on conflict (id) do nothing;
  loop
    new_room_code := upper(substr(encode(gen_random_bytes(8), 'hex'), 1, 8));
    exit when not exists (select 1 from public.game_rooms r where r.room_code = new_room_code);
  end loop;
  insert into public.game_rooms(owner_id, room_code, chapter, max_players, status)
  values (current_user_id, new_room_code, safe_chapter, 4, 'waiting') returning id into new_room_id;
  insert into public.room_members(room_id, user_id) values (new_room_id, current_user_id) on conflict do nothing;
  return query select new_room_id, new_room_code;
end;
$$;

create or replace function public.dark_world_join_room(p_room_code text)
returns table(room_id uuid, room_code text, chapter text, player_count integer, max_players integer)
language plpgsql security definer set search_path = public as $$
declare
  current_user_id uuid := auth.uid();
  selected_room public.game_rooms%rowtype;
  member_count integer;
begin
  if current_user_id is null then raise exception 'AUTH_REQUIRED' using errcode = '28000'; end if;
  if p_room_code is null or char_length(trim(p_room_code)) < 6 or char_length(trim(p_room_code)) > 12 then
    raise exception 'INVALID_ROOM_CODE' using errcode = '22023';
  end if;
  insert into public.profiles(id) values (current_user_id) on conflict (id) do nothing;
  select * into selected_room from public.game_rooms r
  where r.room_code = upper(trim(p_room_code)) for update;
  if not found then raise exception 'ROOM_NOT_FOUND' using errcode = 'P0002'; end if;
  if selected_room.status <> 'waiting' then raise exception 'ROOM_NOT_OPEN' using errcode = '55000'; end if;
  if exists (select 1 from public.room_members rm where rm.room_id = selected_room.id and rm.user_id = current_user_id) then
    select count(*)::integer into member_count from public.room_members rm where rm.room_id = selected_room.id;
    return query select selected_room.id, selected_room.room_code, selected_room.chapter, member_count, selected_room.max_players;
    return;
  end if;
  select count(*)::integer into member_count from public.room_members rm where rm.room_id = selected_room.id;
  if member_count >= selected_room.max_players then raise exception 'ROOM_FULL' using errcode = '54000'; end if;
  insert into public.room_members(room_id, user_id) values (selected_room.id, current_user_id) on conflict do nothing;
  select count(*)::integer into member_count from public.room_members rm where rm.room_id = selected_room.id;
  return query select selected_room.id, selected_room.room_code, selected_room.chapter, member_count, selected_room.max_players;
end;
$$;

create or replace function public.dark_world_send_friend_request(p_username text)
returns uuid language plpgsql security definer set search_path = public as $$
declare current_user_id uuid := auth.uid(); target_id uuid; request_id uuid;
begin
  if current_user_id is null then raise exception 'AUTH_REQUIRED' using errcode = '28000'; end if;
  if p_username is null or char_length(trim(p_username)) < 1 or char_length(trim(p_username)) > 24 then
    raise exception 'INVALID_USERNAME' using errcode = '22023';
  end if;
  select p.id into target_id from public.profiles p where lower(p.username) = lower(trim(p_username)) limit 1;
  if target_id is null then raise exception 'PLAYER_NOT_FOUND' using errcode = 'P0002'; end if;
  if target_id = current_user_id then raise exception 'CANNOT_ADD_SELF' using errcode = '22023'; end if;
  if exists (select 1 from public.friend_requests fr where fr.status in ('pending','accepted')
    and ((fr.requester_id=current_user_id and fr.addressee_id=target_id)
      or (fr.requester_id=target_id and fr.addressee_id=current_user_id))) then
    raise exception 'FRIEND_REQUEST_ALREADY_EXISTS' using errcode = '23505';
  end if;
  insert into public.friend_requests(requester_id, addressee_id, status)
  values (current_user_id, target_id, 'pending') returning id into request_id;
  return request_id;
end;
$$;

create or replace function public.dark_world_respond_friend_request(p_request_id uuid, p_accept boolean)
returns boolean language plpgsql security definer set search_path = public as $$
declare current_user_id uuid := auth.uid(); affected integer;
begin
  if current_user_id is null then raise exception 'AUTH_REQUIRED' using errcode = '28000'; end if;
  update public.friend_requests set status = case when p_accept then 'accepted' else 'declined' end, updated_at = now()
  where id = p_request_id and addressee_id = current_user_id and status = 'pending';
  get diagnostics affected = row_count;
  if affected = 0 then raise exception 'FRIEND_REQUEST_NOT_FOUND' using errcode = 'P0002'; end if;
  return true;
end;
$$;

create or replace function public.dark_world_list_friends()
returns table(user_id uuid, username text, avatar_url text)
language sql stable security definer set search_path = public as $$
  select p.id, p.username, p.avatar_url
  from public.friend_requests fr
  join public.profiles p on p.id = case when fr.requester_id = auth.uid() then fr.addressee_id else fr.requester_id end
  where fr.status = 'accepted' and (fr.requester_id = auth.uid() or fr.addressee_id = auth.uid())
  order by lower(p.username);
$$;

revoke all on function public.dark_world_create_room(text) from public, anon;
revoke all on function public.dark_world_join_room(text) from public, anon;
revoke all on function public.dark_world_send_friend_request(text) from public, anon;
revoke all on function public.dark_world_respond_friend_request(uuid, boolean) from public, anon;
revoke all on function public.dark_world_list_friends() from public, anon;
grant execute on function public.dark_world_create_room(text) to authenticated;
grant execute on function public.dark_world_join_room(text) to authenticated;
grant execute on function public.dark_world_send_friend_request(text) to authenticated;
grant execute on function public.dark_world_respond_friend_request(uuid, boolean) to authenticated;
grant execute on function public.dark_world_list_friends() to authenticated;
